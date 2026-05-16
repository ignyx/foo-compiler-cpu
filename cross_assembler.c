#include "asm_table.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#define ARCH_SIZE 8     // bits
#define MEMORY_SIZE 256 // 2^8
#define INSTR_MEMORY_SIZE 256
#define REGISTER_COUNT 16

enum cpu_asm_op_code {
  CPU_ASM_NOP = 0x0,
  CPU_ASM_ADD = 0x1,
  CPU_ASM_MUL = 0x2,
  CPU_ASM_SOU = 0x3,
  CPU_ASM_DIV = 0x4,
  CPU_ASM_COP = 0x5,
  CPU_ASM_AFC = 0x6,
  CPU_ASM_LOAD = 0x7,
  CPU_ASM_STORE = 0x8
};

static void assert_params_in_bounds(struct asm_instr *instr, int count) {
  uint32_t faulty_address = 0;
  if (count >= 1 && instr->arg0 >= MEMORY_SIZE)
    faulty_address = instr->arg0;
  if (count >= 2 && instr->arg1 >= MEMORY_SIZE)
    faulty_address = instr->arg1;
  if (count >= 3 && instr->arg2 >= MEMORY_SIZE)
    faulty_address = instr->arg2;

  if (faulty_address) {
    fprintf(stderr,
            "segfault: out of bounds memory access 0x%x. Could also be a value "
            "greater than 255.\n",
            faulty_address);
    exit(1);
  }
}

struct cpu_asm_op_triplet {
  enum cpu_asm_op_code op;
  char name[6];
  uint8_t params;
};
static const struct cpu_asm_op_triplet CPU_ASM_OPS[] = {
    {CPU_ASM_NOP, "NOP", 0},    {CPU_ASM_ADD, "ADD", 3},
    {CPU_ASM_MUL, "MUL", 3},    {CPU_ASM_SOU, "SOU", 3},
    {CPU_ASM_DIV, "DIV", 3},    {CPU_ASM_COP, "COP", 2},
    {CPU_ASM_AFC, "AFC", 2},    {CPU_ASM_LOAD, "LOAD", 2},
    {CPU_ASM_STORE, "STORE", 2}};

// Prints to out in a VHDL-compatible listing
void cpu_asm_fprintf(FILE *out, struct asm_table *table) {
  for (int i = 0; i < table->instructions_count; i++) {
    const struct asm_instr instr = table->instructions[i];

    // We use a mask for the LSB, because negative values have 0xFF on other
    // bytes. We already performed size checks.
    fprintf(out, "    x\"%02x_%02x_%02x_%02x\", -- %s", (char)instr.op,
            (char)instr.arg0 & 0xFF, (char)instr.arg1 & 0xFF,
            (char)instr.arg2 & 0xFF, CPU_ASM_OPS[instr.op].name);

    if (CPU_ASM_OPS[instr.op].params >= 1)
      fprintf(out, " %d", instr.arg0);
    if (CPU_ASM_OPS[instr.op].params >= 2)
      fprintf(out, " %d", instr.arg1);
    if (CPU_ASM_OPS[instr.op].params >= 3)
      fprintf(out, " %d", instr.arg2);
    fprintf(out, "\n");
  }
}

static void run(struct asm_table *table) {
  assert(table->instructions_count <= INSTR_MEMORY_SIZE);
  uint8_t i = 0;
  struct asm_instr *instr;
  struct asm_table cpu_table;
  asm_init_table(&cpu_table);

  while (cpu_table.instructions_count <= INSTR_MEMORY_SIZE &&
         i < table->instructions_count) {
    instr = &table->instructions[i];

    switch (instr->op) {
    case ASM_NOP:
      asm_append(&cpu_table, CPU_ASM_NOP, 0, 0, 0);
    case ASM_ADD:
    case ASM_MUL:
    case ASM_SOU:
      // ADD, MUL and SOU share the same opcodes in both assembly languages
      assert_params_in_bounds(instr, 3);
      // LOAD reads the address from register.
      // Doing all AFCs first saves two cycles, due to data hazards
      asm_append(&cpu_table, CPU_ASM_AFC, 1, instr->arg1, 0);
      asm_append(&cpu_table, CPU_ASM_AFC, 2, instr->arg2, 0);
      asm_append(&cpu_table, CPU_ASM_LOAD, 1, 1, 0);
      asm_append(&cpu_table, CPU_ASM_LOAD, 2, 2, 0);
      asm_append(&cpu_table, CPU_ASM_AFC, 3, instr->arg0, 0);
      asm_append(&cpu_table, instr->op, 0, 1, 2);
      asm_append(&cpu_table, CPU_ASM_STORE, 3, 0, 0);
      // NOTE: currently memory data hazards aren't handled in the CPU,
      // so there's a one cycle race condition. Luckily, all instructions
      // have some "AFC padding" so it shouldn't be a problem.
      break;
    // ASM_DIV is unsupported
    case ASM_COP:
      assert_params_in_bounds(instr, 2);
      asm_append(&cpu_table, CPU_ASM_AFC, 0, instr->arg0, 0);
      asm_append(&cpu_table, CPU_ASM_AFC, 1, instr->arg1, 0);
      asm_append(&cpu_table, CPU_ASM_LOAD, 0, 0, 0);
      asm_append(&cpu_table, CPU_ASM_STORE, 1, 0, 0);
      break;
    case ASM_AFC:
      assert_params_in_bounds(instr, 1);
      if (instr->arg1 * instr->arg1 > MEMORY_SIZE * MEMORY_SIZE) {
        fprintf(
            stderr,
            "error: can only AFC values between -MEMORY_SIZE and +MEMORY_SIZE");
        exit(1);
      }
      asm_append(&cpu_table, CPU_ASM_AFC, 0, instr->arg0, 0);
      asm_append(&cpu_table, CPU_ASM_AFC, 1, instr->arg1, 0);
      asm_append(&cpu_table, CPU_ASM_STORE, 0, 1, 0);
      break;
    // case ASM_JMP:
    //   pc = instr->arg0;
    //   break;
    // case ASM_JMF:
    //   assert_params_in_bounds(instr, 1);
    //   if (memory[instr->arg0] == 0)
    //     pc = instr->arg1;
    //   break;
    // case ASM_PRI:
    //   assert_params_in_bounds(instr, 1);
    //   printf("%d\n", memory[instr->arg0]);
    //   break;
    case ASM_LOAD:
      assert_params_in_bounds(instr, 2);
      // On charge l'adresse de l'adresse dans r1
      asm_append(&cpu_table, CPU_ASM_AFC, 1, instr->arg1, 0);
      asm_append(&cpu_table, CPU_ASM_AFC, 0, instr->arg0, 0);
      // On charge l'adresse dans r1
      asm_append(&cpu_table, CPU_ASM_LOAD, 1, 1, 0);
      // On charge la valeur dans r1
      asm_append(&cpu_table, CPU_ASM_LOAD, 1, 1, 0);
      asm_append(&cpu_table, CPU_ASM_STORE, 0, 1, 0);
      break;
    case ASM_STORE:
      assert_params_in_bounds(instr, 2);
      // On charge l'adresse de l'adresse dans r1
      asm_append(&cpu_table, CPU_ASM_AFC, 1, instr->arg0, 0);
      asm_append(&cpu_table, CPU_ASM_AFC, 0, instr->arg1, 0);
      // On charge l'adresse dans r1
      asm_append(&cpu_table, CPU_ASM_LOAD, 1, 1, 0);
      asm_append(&cpu_table, CPU_ASM_STORE, 1, 0, 0);
      break;
    default:
      fprintf(stderr, "unsupported op 0x%x at pc=0x%x\n", instr->op, i);
      exit(2);
    }
    i++;
  }

  if (i < table->instructions_count - 1)
    fprintf(stderr, "error: Couldn't cross-assemble in under 256 instructions");

  cpu_asm_fprintf(stdout, &cpu_table);
  asm_free_table(&cpu_table);
}

int main(int argc, char **argv) {
  if (argc != 2) {
    fprintf(stderr, "usage: %s <bytecode_file>\n", argv[0]);
    return 1;
  }

  FILE *in = fopen(argv[1], "rb");
  if (in == NULL) {
    perror("couldn't open file");
    return 1;
  }

  struct asm_table table;
  asm_init_table(&table);
  asm_read_bytecode(in, &table);
  fclose(in);

  asm_fprintf(stderr, &table);

  fprintf(stderr, "Cross-assembling bytecode (%d instructions) from %s\n",
          table.instructions_count, argv[1]);
  run(&table);

  asm_free_table(&table);
  return 0;
}

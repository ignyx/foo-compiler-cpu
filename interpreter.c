#include "asm_table.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#define MEMORY_SIZE 32

static void assert_params_in_bounds(struct asm_instr *instr, int count) {
  uint32_t faulty_address = 0;
  if (count >= 1 && instr->arg0 >= MEMORY_SIZE)
    faulty_address = instr->arg0;
  if (count >= 2 && instr->arg1 >= MEMORY_SIZE)
    faulty_address = instr->arg1;
  if (count >= 3 && instr->arg2 >= MEMORY_SIZE)
    faulty_address = instr->arg2;

  if (faulty_address) {
    fprintf(stderr, "segfault: out of bounds memory access 0x%x\n",
            faulty_address);
    exit(1);
  }
}

static void mem_dump(uint32_t memory[MEMORY_SIZE]) {
  for (int i = 0; i < MEMORY_SIZE; i++) {
    printf("%d\t:\t%d\n", i, memory[i]);
  }
}

static void run(struct asm_table *table) {
  uint32_t memory[MEMORY_SIZE];
  uint32_t pc = 0;
  struct asm_instr *instr;

  while (pc != table->instructions_count) {
    if (pc > table->instructions_count) {
      fprintf(stderr,
              "segfault: attempting to read instruction beyond code: pc=0x%x\n",
              pc);
      exit(1);
    }
    instr = &table->instructions[pc];
    pc++;

    switch (instr->op) {
    case ASM_ADD:
      assert_params_in_bounds(instr, 3);
      memory[instr->arg0] = memory[instr->arg1] + memory[instr->arg2];
      break;
    case ASM_MUL:
      assert_params_in_bounds(instr, 3);
      memory[instr->arg0] = memory[instr->arg1] * memory[instr->arg2];
      break;
    case ASM_SOU:
      assert_params_in_bounds(instr, 3);
      memory[instr->arg0] = memory[instr->arg1] - memory[instr->arg2];
      break;
    case ASM_DIV:
      assert_params_in_bounds(instr, 3);
      memory[instr->arg0] = memory[instr->arg1] / memory[instr->arg2];
      break;
    case ASM_COP:
      assert_params_in_bounds(instr, 2);
      memory[instr->arg0] = memory[instr->arg1];
      break;
    case ASM_AFC:
      assert_params_in_bounds(instr, 1);
      memory[instr->arg0] = instr->arg1;
      break;
    case ASM_JMP:
      pc = instr->arg0;
      break;
    case ASM_JMF:
      assert_params_in_bounds(instr, 1);
      if (memory[instr->arg0] == 0)
        pc = instr->arg1;
      break;
    case ASM_INF:
      assert_params_in_bounds(instr, 3);
      memory[instr->arg0] = memory[instr->arg1] < memory[instr->arg2] ? 1 : 0;
      break;
    case ASM_SUP:
      assert_params_in_bounds(instr, 3);
      memory[instr->arg0] = memory[instr->arg1] > memory[instr->arg2] ? 1 : 0;
      break;
    case ASM_EQU:
      assert_params_in_bounds(instr, 3);
      memory[instr->arg0] = memory[instr->arg1] == memory[instr->arg2] ? 1 : 0;
      break;
    // TODO INF SUP EQU
    case ASM_PRI:
      assert_params_in_bounds(instr, 1);
      printf("%d\n", memory[instr->arg0]);
      break;
    case ASM_LOAD:
      assert_params_in_bounds(instr, 2);
      assert(memory[instr->arg1] < MEMORY_SIZE);
      memory[instr->arg0] = memory[memory[instr->arg1]];
      break;
    case ASM_STORE:
      assert_params_in_bounds(instr, 2);
      assert(memory[instr->arg1] < MEMORY_SIZE);
      memory[memory[instr->arg0]] = memory[instr->arg1];
      break;
    default:
      fprintf(stderr, "unsupported op 0x%x at pc=0x%x\n", instr->op, pc);
      exit(2);
    }
  }
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

  fprintf(stderr, "Running bytecode (%d instructions) from %s\n",
          table.instructions_count, argv[1]);
  run(&table);

  asm_free_table(&table);
  return 0;
}

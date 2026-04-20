#include "asm_table.h"
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#define ASM_TABLE_INIT_SIZE 16

void asm_init_table(struct asm_table *table) {
  table->instructions = malloc(ASM_TABLE_INIT_SIZE * sizeof(struct asm_instr));
  table->instructions_size = ASM_TABLE_INIT_SIZE;
  table->instructions_count = 0;
}

void asm_free_table(struct asm_table *table) { free(table->instructions); }

struct asm_op_triplet {
  enum asm_op_code op;
  char name[4];
  uint32_t params;
};
static const struct asm_op_triplet ASM_OPS[] = {
    {ASM_PRI, "NUL", 0}, // Because spec doesn't include any instruction with
                         // opcode 0
    {ASM_ADD, "ADD", 3},
    {ASM_MUL, "MUL", 3},
    {ASM_SOU, "SOU", 3},
    {ASM_DIV, "DIV", 3},
    {ASM_COP, "COP", 2},
    {ASM_AFC, "AFC", 2},
    {ASM_JMP, "JMP", 1},
    {ASM_JMF, "JMF", 2},
    {ASM_INF, "INF", 3},
    {ASM_SUP, "SUP", 3},
    {ASM_EQU, "EQU", 3},
    {ASM_PRI, "PRI", 1}};

// Prints to out in a human-readible ASM listing
void asm_fprintf(FILE *out, struct asm_table *table) {
  for (int i = 0; i < table->instructions_count; i++) {
    const struct asm_instr instr = table->instructions[i];
    fprintf(out, "%s", ASM_OPS[instr.op].name);
    if (ASM_OPS[instr.op].params >= 1)
      fprintf(out, " %d", instr.arg0);
    if (ASM_OPS[instr.op].params >= 2)
      fprintf(out, " %d", instr.arg1);
    if (ASM_OPS[instr.op].params >= 3)
      fprintf(out, " %d", instr.arg2);
    fprintf(out, "\n");
  }
}

void asm_write_bytecode(FILE *out, struct asm_table *table) {
  for (int i = 0; i < table->instructions_count; i++) {
    const struct asm_instr instr = table->instructions[i];
    fwrite(&instr.op, sizeof(enum asm_op_code), 1, out);
    fwrite(&instr.arg0, sizeof(uint32_t), 1, out);
    fwrite(&instr.arg1, sizeof(uint32_t), 1, out);
    fwrite(&instr.arg2, sizeof(uint32_t), 1, out);
  }
}

void asm_read_bytecode(FILE *in, struct asm_table *table) {
  enum asm_op_code op;
  uint32_t arg[3];
  while (fread(&op, sizeof(enum asm_op_code), 1, in) == 1) {
    assert(fread(&arg, sizeof(uint32_t), 3, in) == 3);
    asm_append(table, op, arg[0], arg[1], arg[2]);
  }
  assert(table->instructions_count > 0);
}

// Appends instruction to table, returns the index.
uint32_t asm_append(struct asm_table *table, enum asm_op_code op, uint32_t arg0,
                    uint32_t arg1, uint32_t arg2) {
  if (table->instructions_count >= table->instructions_size) {
    // Increase array size
    table->instructions =
        realloc(table->instructions,
                (table->instructions_size * 2) * sizeof(struct asm_instr));
    table->instructions_size = table->instructions_size * 2;
  }

  table->instructions[table->instructions_count].op = op;
  table->instructions[table->instructions_count].arg0 = arg0;
  table->instructions[table->instructions_count].arg1 = arg1;
  table->instructions[table->instructions_count].arg2 = arg2;

  return table->instructions_count++;
}

// Updates the target instruction number of an existing JMP or JMF instruction.
void asm_set_jump_target(struct asm_table *table, uint32_t jump_index,
                         uint32_t target_index) {
  assert(jump_index < table->instructions_size);
  assert(target_index < table->instructions_size);
  assert(table->instructions[jump_index].op == ASM_JMP ||
         table->instructions[jump_index].op == ASM_JMF);

  if (table->instructions[jump_index].op == ASM_JMP) {
    // JMP <numero d’instruction>
    table->instructions[jump_index].arg0 = target_index;
  } else {
    // JMF @X <numero d’instruction>
    table->instructions[jump_index].arg1 = target_index;
  }
}

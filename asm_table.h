#include <stdint.h>
#include <stdio.h>

#ifndef ASM_TABLE

enum asm_op_code {
  ASM_ADD = 0x1,
  ASM_MUL = 0x2,
  ASM_SOU = 0x3,
  ASM_DIV = 0x4,
  ASM_COP = 0x5,
  ASM_AFC = 0x6,
  ASM_JMP = 0x7,
  ASM_JMF = 0x8,
  ASM_INF = 0x9,
  ASM_SUP = 0xA,
  ASM_EQU = 0xB,
  ASM_PRI = 0xC
};

struct asm_instr {
  enum asm_op_code op;
  uint32_t arg0;
  uint32_t arg1;
  uint32_t arg2;
};

struct asm_table {
  struct asm_instr* instructions;
  uint32_t instructions_count; // Stack pointer
  uint32_t instructions_size; // Initially at 10, increased dynamically.
};

void asm_init_table(struct asm_table* table);
void asm_free_table(struct asm_table* table);
// Prints to out in a human-readible ASM listing
void asm_fprintf(FILE* out, struct asm_table* table);

// Appends instruction to table, returns the index.
uint32_t asm_append(struct asm_table* table, enum asm_op_code op, uint32_t arg0, uint32_t arg1, uint32_t arg2);

// Updates the target instruction number of an existing JMP or JMF instruction.
void asm_set_jump_target(struct asm_table* table, uint32_t jump_index, uint32_t target_index);

#endif

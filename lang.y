%{
#include <stdlib.h>
#include <stdio.h>
#include "symbol_table.h"
#include "asm_table.h"

void yyerror(char *s);
uint32_t print_arithm_instr(enum asm_op_code op, uint32_t left, uint32_t right);

static struct st_table table;
static struct asm_table asmt;
%}

%union { int number; char* var; }
%token tEOF tCONST tINT tMAIN tIF tWHILE tBRACKET_LEFT tBRACKET_RIGHT tPARENTHISIS_LEFT tPARENTHISIS_RIGHT tCOMMA tSEMICOLON tEGAL tSOU tADD tMUL tDIV tREF tERROR tPRINTF
%token <number> tINTEGER
%token <var> tIDENTIFIER
/* Used to tell appart constants and variables in symbol table */
%type <number> DECLARE_MODIFIER Term DivMul expr IDENTIFIER_ACU BLOCK BLOCK_END CONDITION WHILE_START
%start START

%%

/* TODO Steps:
- [X] Write lexical parser
- [X] Write symbol table in separate file (probably using a linked list; in report explain why not redimensional arr)
- [X] Use symbol table in yacc file
- [X] Print assembly instructions
- [X] Rewrite so asm instr are added to tab, then output
- [ ] If/While
- [ ] Refactor to use proper I/O streams
- [ ] Update main.c to take in params (there's a util for that)
- [ ] Print error line (not prio)
*/

/* recognize `main () { ... }` */
START : tMAIN tPARENTHISIS_LEFT tPARENTHISIS_RIGHT BLOCK tEOF
  { return 0; };

BLOCK: BLOCK_START BLOCK_DECLARE BLOCK_INSTRUCTIONS BLOCK_END
    { $$ = $4; };
BLOCK_DECLARE: DECLARE BLOCK_DECLARE | DECLARE_UNINIT BLOCK_DECLARE | /* empty */ ;
BLOCK_START: tBRACKET_LEFT
    { st_increase_depth(&table); };
BLOCK_END: tBRACKET_RIGHT
    { st_decrease_depth_free(&table);
      // return address of next instruction
      $$ = asmt.instructions_count; };

/* recognize `const a = 2;` */
DECLARE_MODIFIER: 
  tCONST { $$=0; }
  | tINT { $$=1; };
// Returns the number of allocated symbols
IDENTIFIER_ACU:
    /* empty */
    { $$ = 0; }
  | IDENTIFIER_ACU tCOMMA tIDENTIFIER
    { if (st_find(&table, $3) != NULL) yyerror("symbol $3 already declared in context");
      st_alloc_imm(&table);
      // type isn't known at this time but will be overwitten
      st_become_type(&table, ST_CONST, $3);
      { $$ = $1 + 1; } };
DECLARE_UNINIT: DECLARE_MODIFIER tIDENTIFIER IDENTIFIER_ACU tSEMICOLON
  { if (st_find(&table, $2) != NULL) yyerror("symbol $2 already declared in context");
    const enum st_entry_type type = $1 ? ST_VAR : ST_CONST;
    const uint32_t top = st_alloc_imm(&table);
    st_become_type(&table, type, $2);
    for (int i = 1; i <= $3; i++) {
      // correct type
      table.locals[top - i].type = type;
    }
  };
DECLARE: DECLARE_MODIFIER tIDENTIFIER IDENTIFIER_ACU tEGAL expr tSEMICOLON
  { // First symbol reuses the immediate value
    if (st_find(&table, $2) != NULL) yyerror("symbol $2 already declared in context");
    const enum st_entry_type type = $1 ? ST_VAR : ST_CONST;
    st_become_type(&table, type, $2);

    // copy value to comma-ed vars
    for (int i = 1; i <= $3; i++) {
      asm_append(&asmt, ASM_COP, $5 - i, $5, 0);
      // correct type
      table.locals[$5 - i].type = type;
    }
  };

BLOCK_INSTRUCTIONS:
    MATH_INSRUCTION BLOCK_INSTRUCTIONS
  | POINTER_AFFECT BLOCK_INSTRUCTIONS
  | PRINTF BLOCK_INSTRUCTIONS
  | IF BLOCK_INSTRUCTIONS
  | WHILE BLOCK_INSTRUCTIONS
  | /* empty */;
MATH_INSRUCTION: tIDENTIFIER tEGAL expr tSEMICOLON
    { const struct st_entry* entry = st_find(&table, $1);
      if (entry == NULL) yyerror("symbol $2 unknown");
      else if (entry->type == ST_CONST) yyerror("can't modify $2 as it's a constant");
      asm_append(&asmt, ASM_COP, entry->addr, $3, 0);
      if (table.locals[$3].type == ST_IMMEDIATE) st_free_top(&table);
      };
POINTER_AFFECT: tMUL Term tEGAL expr tSEMICOLON
    { // store and free immediates
      asm_append(&asmt, ASM_STORE, $2, $4, 0);
      if (table.locals[$4].type == ST_IMMEDIATE) st_free_top(&table);
      if (table.locals[$2].type == ST_IMMEDIATE) st_free_top(&table);
    }
expr :
    expr tADD DivMul
    { $$ = print_arithm_instr(ASM_ADD, $1, $3); }
  | expr tSOU DivMul
    { $$ = print_arithm_instr(ASM_SOU, $1, $3); }
  | DivMul;
DivMul :
    DivMul tMUL Term
    { $$ = print_arithm_instr(ASM_MUL, $1, $3); }
  | DivMul tDIV Term
    { $$ = print_arithm_instr(ASM_DIV, $1, $3); }
  | tMUL Term
    { // Load the value into an immediate.
      // Re-use immediate from the address, or allocate a new one.
      // Example: `*(a+2)` (immediate from the sum) vs `*a` (no immediate because `a` is a variable).
      const uint32_t addr = table.locals[$2].type == ST_IMMEDIATE ? $2 : st_alloc_imm(&table);
      asm_append(&asmt, ASM_LOAD, addr, $2, 0);
      $$ = addr; }
  | Term
    { $$ = $1; };
Term :
    tREF tIDENTIFIER
    { // store the address as an immediate and return it
      const struct st_entry* entry = st_find(&table, $2);
      if (entry == NULL) yyerror("symbol $2 unknown");
      const uint32_t addr = st_alloc_imm(&table);
      asm_append(&asmt, ASM_AFC, addr, entry->addr, 0);
      $$ = addr; }
  | tIDENTIFIER
    { // return address
      const struct st_entry* entry = st_find(&table, $1);
      if (entry == NULL) yyerror("symbol $2 unknown");
      $$ = entry->addr; }
  | tINTEGER
    { // Assign an immediate to the value
      const uint32_t addr = st_alloc_imm(&table);
      asm_append(&asmt, ASM_AFC, addr, $1, 0);
      $$ = addr; }
  | tPARENTHISIS_LEFT expr tPARENTHISIS_RIGHT
    { $$ = $2; };
;
PRINTF: tPRINTF tPARENTHISIS_LEFT tIDENTIFIER tPARENTHISIS_RIGHT tSEMICOLON
    { const struct st_entry* entry = st_find(&table, $3);
      if (entry == NULL) yyerror("symbol $3 unknown");
      else asm_append(&asmt, ASM_PRI, entry->addr, 0, 0); };
IF: tIF CONDITION BLOCK
    { asm_set_jump_target(&asmt, $2, $3);
      // free condition immediate
      if (st_get_top(&table)->type == ST_IMMEDIATE) st_free_top(&table); };
WHILE: WHILE_START CONDITION BLOCK
    { asm_append(&asmt, ASM_JMP, $1, 0, 0);
      asm_set_jump_target(&asmt, $2, $3 + 1);
      // free condition immediate
      if (st_get_top(&table)->type == ST_IMMEDIATE) st_free_top(&table); };
WHILE_START: tWHILE
    { // Return address of expression start, as it needs to be evaluated at every iteration
    $$ = asmt.instructions_count; };
CONDITION: tPARENTHISIS_LEFT expr tPARENTHISIS_RIGHT
    { // return the code address of the jump
    $$ = asm_append(&asmt, ASM_JMF, $2, 0, 0); };

%%

void yyerror(char *s) { fprintf(stderr, "%s\n", s); }

// Allocates an address for the result and prints the ASM instruction.
// Frees immediate operands and reuses them where possible.
// Returns the allocated address.
uint32_t print_arithm_instr(enum asm_op_code op, uint32_t left, uint32_t right) {
  // Reuse left-most immediate, or create one if needed
  uint32_t dest;
  if (table.locals[left].type == ST_IMMEDIATE) {
    // reuse consumed left immediate, and free right immediate
    dest = left;
    if (table.locals[right].type == ST_IMMEDIATE) st_free_top(&table);
  } else if (table.locals[right].type == ST_IMMEDIATE) {
    // reuse consumed immediate
    dest = right;
    // don't free;
  } else {
    // both operands are var/const so create a new immediate
    dest = st_alloc_imm(&table);
  }

  asm_append(&asmt, op, dest, left, right);
  return dest;
}


extern FILE *yyin;
int compile(FILE* in, FILE* outlst, FILE* outcod, FILE* err) {
  yyin = in;
  st_init_table(&table);
  asm_init_table(&asmt);
  yyparse();
  st_printf(&table);
  st_free_table(&table);
  asm_fprintf(outlst, &asmt);
  asm_write_bytecode(outcod, &asmt);
  asm_free_table(&asmt);
  return 0;
}


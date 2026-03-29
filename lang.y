%{
#include <stdlib.h>
#include <stdio.h>
#include "symbol_table.h"
void yyerror(char *s);
uint32_t print_arithm_instr(char* op, uint32_t left, uint32_t right);

struct st_table table;
%}

%union { int number; char* var; }
%token tEOF tCONST tINT tMAIN tBRACKET_LEFT tBRACKET_RIGHT tPARENTHISIS_LEFT tPARENTHISIS_RIGHT tCOMMA tSEMICOLON tEGAL tSOU tADD tMUL tDIV tERROR tPRINTF
%token <number> tINTEGER
%token <var> tIDENTIFIER
/* Used to tell appart constants and variables in symbol table */
%type <number> DECLARE_MODIFIER Term DivMul expr IDENTIFIER_ACU
%start START

%%

/* Steps:
- [X] Write lexical parser
- [X] Write symbol table in separate file (probably using a linked list; in report explain why not redimensional arr)
- [ ] Use symbol table in yacc file
- [ ] Print assembly instructions

Symbol table:
- linked list of struct containing: name, addr, type (const, var, immediate)
- immediate values are stored in the first two adresses

*/

/* recognize `main () { ... }` */
START : tMAIN tPARENTHISIS_LEFT tPARENTHISIS_RIGHT tBRACKET_LEFT FUNCTION_BODY tBRACKET_RIGHT tEOF
  { return 0; };

FUNCTION_BODY: FUNCTION_DECLARE FUNCTION_INSTRUCTIONS ;
FUNCTION_DECLARE: DECLARE FUNCTION_DECLARE | DECLARE_UNINIT FUNCTION_DECLARE | /* empty */ ;

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
      printf("COP %d %d\n", $5 - i, $5);
      // correct type
      table.locals[$5 - i].type = type;
    }
  };

FUNCTION_INSTRUCTIONS: MATH_INSRUCTION FUNCTION_INSTRUCTIONS | PRINTF FUNCTION_INSTRUCTIONS | /* empty */;
MATH_INSRUCTION: tIDENTIFIER tEGAL expr tSEMICOLON
    { const struct st_entry* entry = st_find(&table, $1);
      if (entry == NULL) yyerror("symbol $2 unknown");
      else if (entry->type == ST_CONST) yyerror("can't modify $2 as it's a constant");
      printf("COP %d %d\n", entry->addr, $3);
      if (table.locals[$3].type == ST_IMMEDIATE) st_free_top(&table);
      };
expr : 
    expr tADD DivMul
    { $$ = print_arithm_instr("ADD", $1, $3); }
  | expr tSOU DivMul
    { $$ = print_arithm_instr("SOU", $1, $3); }
  | DivMul;
DivMul :
    DivMul tMUL Term
    { $$ = print_arithm_instr("MUL", $1, $3); }
  | DivMul tDIV Term
    { $$ = print_arithm_instr("DIV", $1, $3); }
  | Term
    { $$ = $1; };
Term :
    tIDENTIFIER
    { // return address
      const struct st_entry* entry = st_find(&table, $1);
      if (entry == NULL) yyerror("symbol $2 unknown");
      $$ = entry->addr; }
  | tINTEGER
    { // Assign an immediate to the value
      const uint32_t addr = st_alloc_imm(&table);
      printf("AFC %d %d\n", addr, $1);
      $$ = addr; }
  | tPARENTHISIS_LEFT expr tPARENTHISIS_RIGHT
    { $$ = $2; };
;
PRINTF: tPRINTF tPARENTHISIS_LEFT tIDENTIFIER tPARENTHISIS_RIGHT tSEMICOLON
    { const struct st_entry* entry = st_find(&table, $3);
      if (entry == NULL) yyerror("symbol $3 unknown");
      else printf("PRI %d\n", entry->addr); };

%%

void yyerror(char *s) { fprintf(stderr, "%s\n", s); }

// Allocates an address for the result and prints the ASM instruction.
// Frees immediate operands and reuses them where possible.
// Returns the allocated address.
uint32_t print_arithm_instr(char* op, uint32_t left, uint32_t right) {
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

  printf("%s %d %d %d\n", op, dest, left, right);
  return dest;
}

int main(void) {
  st_init_table(&table);
  printf("parsing stdin in FOO lang!\n"); // yydebug=1;
  yyparse();
  printf("done parsing FOO lang !\n"); // yydebug=1;
  st_printf(&table);
  st_free_table(&table);
  return 0;
}


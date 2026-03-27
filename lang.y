%{
#include <stdlib.h>
#include <stdio.h>
#include "symbol_table.h"
void yyerror(char *s);

struct st_table table;
%}

%union { int number; char* var; }
/* TODO remove tab and related tokens */
%token tTAB tSPACE tLF tCONST tINT tMAIN tBRACKET_LEFT tBRACKET_RIGHT tPARENTHISIS_LEFT tPARENTHISIS_RIGHT tCOMMA tSEMICOLON tEGAL tSOU tADD tMUL tDIV tERROR tPRINTF
%token <number> tINTEGER
%token <var> tIDENTIFIER
/* Used to tell appart constants and variables in symbol table */
%type <number> DECLARE_MODIFIER Term
%start START

/* TODO see if this is necessary */
%right tEGAL
%left tADD tSOU
%left tMUL tDIV

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
START : tMAIN tPARENTHISIS_LEFT tPARENTHISIS_RIGHT tBRACKET_LEFT FUNCTION_BODY tBRACKET_RIGHT
  { return 0; };

FUNCTION_BODY: FUNCTION_DECLARE FUNCTION_INSTRUCTIONS ;
FUNCTION_DECLARE: DECLARE FUNCTION_DECLARE | /* empty */ ;

/* recognize `const a = 2;` */
DECLARE: DECLARE_MODIFIER tIDENTIFIER tEGAL expr tSEMICOLON 
  {/* TODO handle case with comma, maybe using yymore() (ctrl+f concat) */ 
    if (st_find(&table, $2) != NULL) yyerror("symbol $2 already declared in context");
    const uint32_t addr = st_alloc_const(&table, $2);
    printf("COP %d %d\n", addr, 0); // TODO
    };
    //printf("AFC %d %d\n", 1, 0 /*$4*/); }; 
DECLARE_MODIFIER: 
  /* TODO store this data inside the symbol table */
  tCONST { $$=0; }
  | tINT { $$=1; };

FUNCTION_INSTRUCTIONS: MATH_INSRUCTION FUNCTION_INSTRUCTIONS | PRINTF FUNCTION_INSTRUCTIONS | /* empty */;
MATH_INSRUCTION: tIDENTIFIER tEGAL expr tSEMICOLON;
expr : 
    expr tADD DivMul
  | expr tSOU DivMul
  | DivMul;
DivMul :
    DivMul tMUL Term
  | DivMul tDIV Term
  | Term;
Term :
    tIDENTIFIER {
      // TODO
      $$ = 1; }
  | tINTEGER
    { // Assign an immediate to the value
      const uint32_t addr = st_alloc_imm(&table);
      printf("AFC %d %d\n", addr, $1);
      $$ = addr; }
  | tPARENTHISIS_LEFT expr tPARENTHISIS_RIGHT
    { // TODO
      $$ = 1; };
  /* TODO try to do the calculations, store immediates in first two addr */
;
PRINTF: tPRINTF tPARENTHISIS_LEFT tIDENTIFIER tPARENTHISIS_RIGHT tSEMICOLON;

%%

void yyerror(char *s) { fprintf(stderr, "%s\n", s); }
int main(void) {
  st_init_table(&table);
  printf("parsing stdin in FOO lang!\n"); // yydebug=1;
  yyparse();
  printf("done parsing FOO lang !\n"); // yydebug=1;
  st_printf(&table);
  st_free_table(&table);
  return 0;
}


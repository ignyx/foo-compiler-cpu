%{
#include <stdlib.h>
#include <stdio.h>
void yyerror(char *s);
%}

%union { int number; char* var; }
/* TODO remove tab and related tokens */
%token tTAB tSPACE tLF tCONST tINT tMAIN tBRACKET_LEFT tBRACKET_RIGHT tPARENTHISIS_LEFT tPARENTHISIS_RIGHT tCOMMA tSEMICOLON tEGAL tSOU tADD tMUL tDIV tERROR 
%token <number> tINTEGER
%token <var> tIDENTIFIER
/* Used to tell appart constants and variables in symbol table */
%type <number> DECLARE_MODIFIER
%start START

%%

/* Steps:
- [ ] Write lexical parser
- [ ] Write symbol table in separate file (probably using a linked list; in report explain why not redimensional arr)
- [ ] Print assembly instructions
*/

/* recognize `main () { ... }` */
START : tMAIN tPARENTHISIS_LEFT tPARENTHISIS_RIGHT tBRACKET_LEFT FUNCTION_BODY tBRACKET_RIGHT
  { return 0; };

FUNCTION_BODY: FUNCTION_DECLARE /*FUNCTION_INSTRUCTIONS */;
FUNCTION_DECLARE: DECLARE FUNCTION_DECLARE | /*DECLARE_VAR FUNCTION_DECLARE | /* empty */ ;

/* recognize `const a = 2;` */
DECLARE: DECLARE_MODIFIER tIDENTIFIER tEGAL tINTEGER tSEMICOLON 
  { printf("AFC %d %d\n", 1, $4); }; /* TODO handle case with comma */
DECLARE_MODIFIER: 
  /* TODO store this data inside the symbol table */
  tCONST { $$=0; }
  | tINT { $$=1; };






%%

void yyerror(char *s) { fprintf(stderr, "%s\n", s); }
int main(void) {
  printf("FOO lang!\n"); // yydebug=1;
  yyparse();
  return 0;
}


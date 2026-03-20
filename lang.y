%{
#include <stdlib.h>
#include <stdio.h>
void yyerror(char *s);
%}

%union { int number; char* var; }
/* TODO remove tab and related tokens */
%token tTAB tSPACE tLF tCONST tINT tMAIN tBRACKET_LEFT tBRACKET_RIGHT tPARENTHISIS_LEFT tPARENTHISIS_RIGHT tCOMMA tSEMICOLON tEGAL tSOU tADD tMUL tDIV tERROR tPRINTF
%token <number> tINTEGER
%token <var> tIDENTIFIER
/* Used to tell appart constants and variables in symbol table */
%type <number> DECLARE_MODIFIER
%start START

%right tEGAL
%left tADD tSOU
%left tMUL tDIV

%%

/* Steps:
- [ ] Write lexical parser
- [ ] Write symbol table in separate file (probably using a linked list; in report explain why not redimensional arr)
- [ ] Print assembly instructions
*/

/* recognize `main () { ... }` */
START : tMAIN tPARENTHISIS_LEFT tPARENTHISIS_RIGHT tBRACKET_LEFT FUNCTION_BODY tBRACKET_RIGHT
  { return 0; };

FUNCTION_BODY: FUNCTION_DECLARE FUNCTION_INSTRUCTIONS ;
FUNCTION_DECLARE: DECLARE FUNCTION_DECLARE | /* empty */ ;

/* recognize `const a = 2;` */
DECLARE: DECLARE_MODIFIER tIDENTIFIER tEGAL expr tSEMICOLON 
  { printf("AFC %d %d\n", 1, 0 /*$4*/); }; /* TODO handle case with comma, maybe using yymore() (ctrl+f concat) */
DECLARE_MODIFIER: 
  /* TODO store this data inside the symbol table */
  tCONST { $$=0; }
  | tINT { $$=1; };

FUNCTION_INSTRUCTIONS: MATH_INSRUCTION FUNCTION_INSTRUCTIONS | PRINTF FUNCTION_INSTRUCTIONS | /* empty */;
MATH_INSRUCTION: tIDENTIFIER tEGAL expr tSEMICOLON;
expr : 
    expr tADD expr
  | expr tSOU expr
  | expr tMUL expr
  | expr tDIV expr
  | tIDENTIFIER
  | tINTEGER
;
PRINTF: tPRINTF tPARENTHISIS_LEFT tIDENTIFIER tPARENTHISIS_RIGHT tSEMICOLON;





%%

void yyerror(char *s) { fprintf(stderr, "%s\n", s); }
int main(void) {
  printf("parsing stdin in FOO lang!\n"); // yydebug=1;
  yyparse();
  printf("FOO lang parsed with success!\n"); // yydebug=1;
  return 0;
}


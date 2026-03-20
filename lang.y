%{
#include <stdlib.h>
#include <stdio.h>
void yyerror(char *s);
%}

%token tTAB tSPACE tLF tCONST tINT tMAIN tINTEGER tIDENTIFIER tBRACKET_LEFT tBRACKET_RIGHT tPARENTHISIS_LEFT tPARENTHISIS_RIGHT tCOMMA tSEMICOLON tEGAL tSOU tADD tMUL tDIV tERROR 
%start START

%%

START : tMAIN;

%%

void yyerror(char *s) { fprintf(stderr, "%s\n", s); }
int main(void) {
  printf("FOO lang!\n"); // yydebug=1;
  yyparse();
  return 0;
}


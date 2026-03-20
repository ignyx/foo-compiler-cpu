%{
#include <stdlib.h>
#include <stdio.h>
//#include "calc.tab.h"
%}


%%

[\t]+ { printf("tTAB"); }
[ ]+ { printf("tSPACE"); }
[\n]+ { printf("tLF\n"); }
const { printf("tCONST"); }
int { printf("tINT"); }
main { printf("tMAIN"); }
-?[0-9]+e[0-9]+ { printf("tINTEGER"); }
-?[0-9]+ { printf("tINTEGER"); }
[A-Za-z0-9_]+ { printf("tIDENTIFIER"); }
"{" { printf("tBRACKET_LEFT"); }
"}" { printf("tBRACKET_RIGHT"); }
"(" { printf("tPARENTHISIS_LEFT"); }
")" { printf("tPARENTHISIS_RIGHT"); }
"," { printf("tCOMMA"); }
";" { printf("tSEMICOLON"); }
"="	{ printf("tEGAL"); }
"-"	{ printf("tSOU"); }
"+"	{ printf("tADD"); }
"*"	{ printf("tMUL"); }
"/"	{ printf("tDIV"); }
. { printf("unknown"); 
/*
printf { printf("tP
//%option noyywrap
[0-9]+	{
	  yylval.nb = atoi(yytext);
	  return tNB;
	}
"="	{ return tEGAL; }
"-"	{ return tSOU; }
"+"	{ return tADD; }
"*"	{ return tMUL; }
"/"	{ return tDIV; }
"("	{ return tPO; }
")"	{ return tPF; }
[a-z]	{
	  yylval.var = yytext[0];
	  return tID;
	}
\n	{ return tFL; }
.	{ return tERROR; }
*/}

%%

int yywrap() {
return 1 ;
}

int main () {
  yylex() ;
  return 1 ;
}

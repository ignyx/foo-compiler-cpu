%{
#include <stdlib.h>
#include <stdio.h>
#include "lang.tab.h"
%}


%%

[\t]+ { /*return tTAB;*/ }
[ ]+ { /*return tSPACE;*/ }
[\n]+ { /*return tLF;*/ }
const { return tCONST; }
int { return tINT; }
main { return tMAIN; }
-?[0-9]+e[0-9]+ { return tINTEGER; }
-?[0-9]+ { yylval.number = atoi(yytext); return tINTEGER; }
[A-Za-z0-9_]+ { return tIDENTIFIER; }
"{" { return tBRACKET_LEFT; }
"}" { return tBRACKET_RIGHT; }
"(" { return tPARENTHISIS_LEFT; }
")" { return tPARENTHISIS_RIGHT; }
"," { return tCOMMA; }
";" { return tSEMICOLON; }
"="	{ return tEGAL; }
"-"	{ return tSOU; }
"+"	{ return tADD; }
"*"	{ return tMUL; }
"/"	{ return tDIV; }
. { return tERROR; }
%%

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
*/


int yywrap() {
return 1 ;
}

/*
int main () {
  yylex() ;
  return 1 ;
}
*/

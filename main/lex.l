%option noyywrap
%option yylineno

%{
#include<bits/stdc++.h>
#include"symbol_info.h"
#include"symbol_table.h"
#define YYSTYPE symbol_info*
#include "y.tab.h"
extern YYSTYPE yylval;
using namespace std;
void yyerror(char *); 
string loglist;
extern int lines;
extern ofstream outlog;
%}

/* Regular Definitions */

digit [0-9]
letter [a-zA-Z]
alphanumeric [a-zA-Z0-9_]

%%

[ \t]+ { }
\n { lines++; }

"if" { return IF; }
"else" { return ELSE; }
"for" { return FOR; }
"while" { return WHILE; }
"int" { return INT; }
"float" { return FLOAT; }
"void" { return VOID; }
"return" { return RETURN; }
"printf" { return PRINTF; }

"+"|"-" { yylval = new symbol_info((string)yytext, "ADDOP"); return ADDOP; }
"*"|"/"|"%" { yylval = new symbol_info((string)yytext, "MULOP"); return MULOP; }
"++" { yylval = new symbol_info((string)yytext, "INCOP"); return INCOP; }
"--" { yylval = new symbol_info((string)yytext, "DECOP"); return INCOP; }
"<"|"<="|">"|">="|"=="|"!=" { yylval = new symbol_info((string)yytext, "RELOP"); return RELOP; }
"=" { return ASSIGNOP; }
"&&"|"||" { yylval = new symbol_info((string)yytext, "LOGICOP"); return LOGICOP; }
"!" { return NOT; }
"(" { return LPAREN; }
")" { return RPAREN; }
"{" { return LCURL; }
"}" { return RCURL; }
"[" { return LTHIRD; }
"]" { return RTHIRD; }
"," { return COMMA; }
";" { return SEMICOLON; }

{digit}+ { yylval = new symbol_info((string)yytext, "CONST_INT"); return CONST_INT; }
{digit}*\.{digit}+ { yylval = new symbol_info((string)yytext, "CONST_FLOAT"); return CONST_FLOAT; }
{letter}{alphanumeric}* { yylval = new symbol_info((string)yytext, "ID"); return ID; }

. ;

%%

void yyerror(char *s)
{
    outlog << "Error at line " << lines << ": " << s << endl;
}
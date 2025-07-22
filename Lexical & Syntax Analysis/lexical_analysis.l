%option noyywrap

%{
#include<bits/stdc++.h>
using namespace std;

ofstream yyoutlog; //output filestream for log file

string loglist = ""; //list of tokens along with line numbers

// define necessary c++ variables and functions here (if any)
int lines = 1;

#define IF 1
#define FOR 2
#define DO 3
#define ELSE 4
#define WHILE 5
#define BREAK 6
#define INT 7
#define CHAR 8
#define FLOAT 9
#define DOUBLE 10
#define VOID 11
#define RETURN 12
#define SWITCH 13
#define CASE 14
#define DEFAULT 15
#define CONTINUE 16
#define GOTO 17
#define PRINTF 18
#define CONST_INT 19
#define ID 20
#define CONST_FLOAT 21
#define ADDOP 22
#define MULOP 23
#define INCOP 24
#define RELOP 25
#define ASSIGNOP 26
#define LOGICOP 27
#define NOT 28
#define LPAREN 29
#define RPAREN 30
#define LCURL 31
#define RCURL 32
#define LTHIRD 33
#define RTHIRD 34
#define COMMA 35
#define COLON 36
#define SEMICOLON 37

%}

/* Regular Definitions */

delim	 [ \t\v\r]

/* write regular expressions for whitespace and newline */
ws [ \t\r]+

newline  [\n]


/* write regular expressions for id, float and integers */
id [a-zA-Z][a-zA-Z0-9]*
integers [0-9]+
float [0-9]*\.[0-9]+(e[+-]?[0-9]+)?



%%

{ws}		{ /* ignore whitespace */ }
{newline}	{ /* do necessary bookkeeping (line number tracking etc.) */ 
				lines += 1;
			}

if     {
			loglist="Line no "+to_string(lines)+": Token <IF> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return IF;
		}

for     {
			loglist="Line no "+to_string(lines)+": Token <FOR> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return FOR;
		}


do    {
			loglist="Line no "+to_string(lines)+": Token <DO> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return DO;
		}


else   {
			loglist="Line no "+to_string(lines)+": Token <ELSE> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return ELSE;
		}


while  {
			loglist="Line no "+to_string(lines)+": Token <WHILE> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return WHILE;
		}


break  {
			loglist="Line no "+to_string(lines)+": Token <BREAK> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return BREAK;
		}


int    {
			loglist="Line no "+to_string(lines)+": Token <INT> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return INT;
		}


char    {
			loglist="Line no "+to_string(lines)+": Token <CHAR> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return CHAR;
		}


float    {
			loglist="Line no "+to_string(lines)+": Token <FLOAT> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return FLOAT;
		}


double    {
			loglist="Line no "+to_string(lines)+": Token <DOUBLE> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return DOUBLE;
		}


void    {
			loglist="Line no "+to_string(lines)+": Token <VOID> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return VOID;
		}


return    {
			loglist="Line no "+to_string(lines)+": Token <RETURN> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return RETURN;
		}


switch    {
			loglist="Line no "+to_string(lines)+": Token <SWITCH> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return SWITCH;
		}


case    {
			loglist="Line no "+to_string(lines)+": Token <CASE> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return CASE;
		}


default    {
			loglist="Line no "+to_string(lines)+": Token <DEFAULT> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return DEFAULT;
		}


continue   {
			loglist="Line no "+to_string(lines)+": Token <CONTINUE> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return CONTINUE;
		}


goto    {
			loglist="Line no "+to_string(lines)+": Token <GOTO> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return GOTO;
		}


printf    {
			loglist="Line no "+to_string(lines)+": Token <PRINTF> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return PRINTF;
		}


{integers} {
			loglist="Line no "+to_string(lines)+": Token <CONST_INT> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return CONST_INT;
		}


{id} {
			loglist="Line no "+to_string(lines)+": Token <ID> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return ID;
		}


{float}    {
			loglist="Line no "+to_string(lines)+": Token <CONST_FLOAT> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return CONST_FLOAT;
		}


"+"|"-" {
			loglist="Line no "+to_string(lines)+": Token <ADDOP> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return ADDOP;
		}


"*"|"/"|"%" {
			loglist="Line no "+to_string(lines)+": Token <MULOP> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return MULOP;
		}


"++"|"--" {
			loglist="Line no "+to_string(lines)+": Token <INCOP> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return INCOP;
		}


"<"|">"|"=="|"<="|">="|"!=" {
			loglist="Line no "+to_string(lines)+": Token <RELOP> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return RELOP;
		}


"="     {
			loglist="Line no "+to_string(lines)+": Token <ASSIGNOP> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return ASSIGNOP;
		}


"&&"|"||" {
			loglist="Line no "+to_string(lines)+": Token <LOGICOP> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return LOGICOP;
		}


"!"     {
			loglist="Line no "+to_string(lines)+": Token <NOT> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return NOT;
		}


"("     {
			loglist="Line no "+to_string(lines)+": Token <LPAREN> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return LPAREN;
		}


")"     {
			loglist="Line no "+to_string(lines)+": Token <RPAREN> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return RPAREN;
		}


"{"     {
			loglist="Line no "+to_string(lines)+": Token <LCURL> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return LCURL;
		}


"}"     {
			loglist="Line no "+to_string(lines)+": Token <RCURL> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return RCURL;
		}


"["     {
			loglist="Line no "+to_string(lines)+": Token <LTHIRD> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return LTHIRD;
		}


"]"     {
			loglist="Line no "+to_string(lines)+": Token <RTHIRD> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return RTHIRD;
		}


","     {
			loglist="Line no "+to_string(lines)+": Token <COMMA> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return COMMA;
		}


":"     {
			loglist="Line no "+to_string(lines)+": Token <COLON> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return COLON;
		}


";"     {
			loglist="Line no "+to_string(lines)+": Token <SEMICOLON> Lexeme "+yytext+" found"+"\n"+"\n";
			yyoutlog<<loglist;
			return SEMICOLON;
		}


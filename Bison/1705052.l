%option noyywrap

%x CHAR_CONST_STATE
%x CHAR_CONST_EXP_STATE
%x CHAR_CONST_EXP_STATE_END
%x CHAR_CONST_STATE_END
%x STRING_START_STATE
%x STRING_EXP_STATE
%x STRING_EXP_STATE_1
%x STRING_EXP_STATE_2
%x STRING_END_STATE
%x ERROR_STATE_STRING
%x COMMENT_STATE_START
%x COMMENT_STATE_CONTINUE
%x COMMENT_STATE_START_1
%x COMMENT_CONTINUE
%x COMMENT_STATE_START_2
%x MULTI
%x MULTI_1
%x MULTI_ERROR
%x FLOAT1_STATE
%x FLOAT1_ERROR
%x FLOAT2_STATE
%x FLOAT2_ERROR
%x CHAR_E_STATE
%x MULTI_CHAR_E_STATE
%x MULTI_2
%x MULTI_3
%x OPEN



%{
#include<iostream>
#include<stdlib.h>
#include<string.h>
#include "main.cpp"

#include "y.tab.h"


using namespace std;

extern YYSTYPE yylval;
extern SymbolTable *table;
void yyerror(char *);


int line_count=1;
int number_of_errors=0;
string str;
string str2;
string str3;
string str4;
string c;
char *t;
extern ofstream ol;
//ofstream ot;

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
CHARACTERS [a-zA-Z0-9]
CHARACTERSE [ a-zA-Z0-9]
MULTIERROR [']+{CHARACTERSE}+({CHARACTERSE}+)+[']
MULTIERRORE ({CHARACTERSE}+)+[']
LETTER2 [a-zA-Z_]
ASCII [ \t//#!@#$%^&*();{}]
ASCII2 [ \t*#!@$%^&\//();{}]
ASCII3 [ \t*#!@$%^&*();]
ADDOP[+-]
DIGIT [0-9]
NEWLINE [\n]
ID {LETTER2}({LETTER2}|{DIGIT})*
ID2 {DIGIT}({LETTER2}|{DIGIT})*
STRING ({ASCII}|{CHARACTERS})+
COMMENT ({ASCII2}|{CHARACTERS})+
COMMENT2 ({ASCII3}|{CHARACTERS})+
FLOAT {DIGIT}+(\.{DIGIT}+)?(E[+-]?{DIGIT}+)?
ERROR_FLOAT1 {DIGIT}+(\.{DIGIT}+)+(\.{DIGIT}+)+
FLOAT2 {DIGIT}+(\.{DIGIT}+)?(e[+-]?{DIGIT}+)?
ERROR_FLOAT2 {DIGIT}+(E[+-]?{DIGIT}+)+(\.{DIGIT}+)+
ERROR_FLOAT3 {DIGIT}+(e[+-]?{DIGIT}+)+(\.{DIGIT}+)+

%%

{NEWLINE} {line_count=line_count+1;}
{WHITESPACE}+


"if"	{
			return IF;
		}
		
"else"	{
			return ELSE;
		}
"for"	{		
			return FOR;
		}
"while"	{
			return WHILE;
			
		}
"do"	{	
			return DO;
		}
"break"	{
			return BREAK;
		}
"int"	{	//cout<<"p"<<endl;
			return INT;
		}
"char"	{
			return CHAR;
		}
"float"	{
			return FLOAT;
		}
"double" {
			return DOUBLE;
		}
"void"		{
			return VOID;
		}
"return"	{
			return RETURN;
		}
"switch"	{
			return SWITCH;
		}
"case"		{
			 return CASE;
		}
"default"	{
			return DEFAULT;
		}
"continue"	{
			return CONTINUE;
		}

"printf"	{return PRINTLN;}

"`"		{
			
			number_of_errors++;
			BEGIN INITIAL;
		}

{DIGIT}+	{
			SymbolInfo *s= new  SymbolInfo(yytext, "CONST_INT");
				yylval.si= s;
				return CONST_INT;
			}
		
{FLOAT}	{	
			str4=yytext;
			SymbolInfo *s= new  SymbolInfo(str4, "CONST_FLOAT");
			yylval.si = s;
			return CONST_FLOAT; 
			
			
		}
{FLOAT2}	{	
			str4=yytext;
			SymbolInfo *s= new  SymbolInfo(str4, "CONST_FLOAT");
			yylval.si = s;
			return CONST_FLOAT; 
			
		}
		
{ERROR_FLOAT1}		{

				number_of_errors++;
				BEGIN INITIAL;
			}
{ERROR_FLOAT2}		{
				number_of_errors++;
				BEGIN INITIAL;
			}
{ERROR_FLOAT3}		{
				number_of_errors++;
				BEGIN INITIAL;
			}
{MULTIERROR}			{
					
					BEGIN INITIAL;
				}

"'"		{	
			str2=yytext;
			BEGIN CHAR_CONST_STATE;	
		}			

<CHAR_CONST_STATE>{CHARACTERS}	{
					c=yytext;
					str = yytext;
					str2+=yytext;
					BEGIN CHAR_E_STATE;
				}
		
<CHAR_CONST_STATE>"\\"		{	
					
					str2+=yytext;
					BEGIN CHAR_CONST_EXP_STATE;
				
				}				

<CHAR_CONST_STATE>"'"		{
					
					number_of_errors++;
					BEGIN INITIAL;
				}			
<CHAR_CONST_STATE>[\n]		{
					
					line_count++;
					number_of_errors++;
					BEGIN INITIAL;
				}
<CHAR_CONST_STATE>[\t]		{	
					number_of_errors++;
					BEGIN INITIAL;

				}
<CHAR_CONST_STATE>.		{	
					str2+=yytext;
					line_count++;
					number_of_errors++;
					BEGIN INITIAL;
				}		

					
<CHAR_E_STATE>"'"	{
					
					SymbolInfo *s= new  SymbolInfo(c, (char *)"CONST_CHAR");
					yylval.si = s;
					BEGIN INITIAL;
					return CONST_CHAR;
					
					
					}
<CHAR_E_STATE>[^"'"]	{
					
					str2+=yytext;
					number_of_errors++;
					BEGIN INITIAL;
				}
<CHAR_CONST_EXP_STATE>"n" 	{
				
				str2+=yytext;
				str3=yytext;
				BEGIN CHAR_CONST_EXP_STATE_END;
				
			}
<CHAR_CONST_EXP_STATE>"t" 	{
				
				str2+=yytext;
				str3=yytext;
				BEGIN CHAR_CONST_EXP_STATE_END;
				
			}
			
<CHAR_CONST_EXP_STATE>"\\" 	{
				
				str2+=yytext;
				str3=yytext;
				BEGIN CHAR_CONST_EXP_STATE_END;
				
			}
			
<CHAR_CONST_EXP_STATE>"'"	{
				
				str2+=yytext;
				str3=yytext;
				BEGIN CHAR_CONST_EXP_STATE_END;
				
			}
			
<CHAR_CONST_EXP_STATE>"\""	{
				
				str2+=yytext;
				str3=yytext;
				BEGIN CHAR_CONST_EXP_STATE_END;
				
			}
<CHAR_CONST_EXP_STATE>"a"	{
				str2+=yytext;
				str3=yytext;
				BEGIN CHAR_CONST_EXP_STATE_END;
				
			}

<CHAR_CONST_EXP_STATE>"f"	{
				str2+=yytext;
				str3=yytext;
				BEGIN CHAR_CONST_EXP_STATE_END;
				
			}
			

			
<CHAR_CONST_EXP_STATE>"b"	{
				str2+=yytext;
				str3=yytext;
				BEGIN CHAR_CONST_EXP_STATE_END;
				
			}
			
<CHAR_CONST_EXP_STATE>"v"	{
				str2+=yytext;
				str3=yytext;
				BEGIN CHAR_CONST_EXP_STATE_END;
				
			}
<CHAR_CONST_EXP_STATE>"r"	{
				str2+=yytext;
				str3=yytext;
				BEGIN CHAR_CONST_EXP_STATE_END;
				
			}
<CHAR_CONST_EXP_STATE>"0"	{
				str2+=yytext;
				str3=yytext;
				BEGIN CHAR_CONST_EXP_STATE_END;
				
			}	



<CHAR_CONST_EXP_STATE_END>"'"	{
				if(str3=="n"){
				SymbolInfo *s= new  SymbolInfo("\n", (char *)"CONST_CHAR");
				yylval.si = s;
				BEGIN INITIAL;
				return CONST_CHAR;
				
			}
				else if(str3=="t"){
				SymbolInfo *s= new  SymbolInfo("\t" ,(char *)"CONST_CHAR");
				yylval.si = s;
				BEGIN INITIAL;
				return CONST_CHAR;
				}
				else if(str3=="\\"){
				SymbolInfo *s= new  SymbolInfo("\\", (char *)"CONST_CHAR");
				yylval.si= s;
				BEGIN INITIAL;
				return CONST_CHAR;
				}
				else if(str3=="'"){
				SymbolInfo *s= new  SymbolInfo("\'", (char *)"CONST_CHAR");
				yylval.si = s;
				BEGIN INITIAL;
				return CONST_CHAR;
				}
				else if(str3=="\""){
				SymbolInfo *s= new  SymbolInfo("\"" ,(char *)"CONST_CHAR");
				yylval.si = s;
				BEGIN INITIAL;
				return CONST_CHAR;
				}
				else if(str3=="a"){
				SymbolInfo *s= new  SymbolInfo("\a" ,(char *)"CONST_CHAR");
				yylval.si = s;
				BEGIN INITIAL;
				return CONST_CHAR;
				}
				else if(str3=="f"){
				SymbolInfo *s= new  SymbolInfo("\f" ,(char *)"CONST_CHAR");
				yylval.si= s;
				BEGIN INITIAL;
				return CONST_CHAR;
				}
				
				else if(str3=="b"){
				SymbolInfo *s= new  SymbolInfo("\b" ,(char *)"CONST_CHAR");
				yylval.si = s;
				BEGIN INITIAL;
				return CONST_CHAR;
				}
				else if(str3=="v"){
				SymbolInfo *s= new  SymbolInfo("\v" ,(char *)"CONST_CHAR");
				yylval.si = s;
				BEGIN INITIAL;
				return CONST_CHAR;			
				}
				else if(str3=="r"){
				SymbolInfo *s= new  SymbolInfo("\r" ,(char *)"CONST_CHAR");
				yylval.si = s;
				BEGIN INITIAL;
				return CONST_CHAR;
				}

				else if(str3=="0"){
				SymbolInfo *s= new  SymbolInfo("\0" ,(char *)"CONST_CHAR");
				yylval.si = s;
				BEGIN INITIAL;
				return CONST_CHAR;		
				}


			}
<CHAR_CONST_EXP_STATE_END>[^"'"]		{
					str2+=yytext;
					number_of_errors++;
					BEGIN INITIAL;
				}			

{ADDOP}		{
			SymbolInfo *s= new  SymbolInfo(yytext, "ADDOP");
			yylval.si = s;
			return ADDOP;
			
		}
"/"		|
"*"		|
"%"             {
			SymbolInfo *s= new  SymbolInfo(yytext, "MULOP");
			yylval.si= s;
			return MULOP;
		}
"++"     {	return INCOP;	}
"--"     {
			return DECOP;
		}
"<"            |
"<="           |
">"            |
">="           |
"=="           |
"!="           {
			SymbolInfo *s= new  SymbolInfo(yytext, "RELOP");
			yylval.si = s;
			return RELOP;
		}
"="      {	return ASSIGNOP;	}
			
"&&"		|
"||"           {
			SymbolInfo *s= new  SymbolInfo(yytext, "LOGICOP");
			yylval.si= s;
			return LOGICOP;
		}
"!"         {	return NOT;	}
"("	        {	return LPAREN;	}
			
")"	        {	return RPAREN;	}
			
"{" 	{return LCURL;}
"}" 	{return RCURL;}
"[" 	{return LTHIRD;}
"]" 	{return RTHIRD;}
";" 	{return SEMICOLON;}
"," 	{return COMMA;	}	
{ID2}		{	
			
			number_of_errors++;
			BEGIN INITIAL;

		}
{ID}		{	
				yylval.si= new SymbolInfo(yytext, "ID");
				//yylval.si= s;
							
				return ID;					
			}	


		
"\""		{	
			str = "\"";
			str2 = "\"";
			BEGIN STRING_START_STATE;
			
		}
		

					
<STRING_START_STATE>"\""			{
						str += "\"";
						str2 += "\"";
						str = "\"";
						BEGIN INITIAL;
						return STRING;
						
					}
<STRING_START_STATE>(([\\])+([n]))+	{
						str2 +="\n";
						str+=yytext;
						BEGIN STRING_START_STATE;
					}
<STRING_START_STATE>(([\\])+([t]))+	{
						str2 +="\t";
						str +=yytext;
						BEGIN STRING_START_STATE;
					}

<STRING_START_STATE>"\\"		{
						
						str += yytext;
						BEGIN STRING_EXP_STATE;
					}

<STRING_START_STATE>[\n]	{
						
						
						
						number_of_errors++;
						line_count++;
						
						BEGIN INITIAL;
				}

<STRING_START_STATE>.		{
					
					str += yytext;
					str2 += yytext;
					BEGIN STRING_START_STATE;
					
					}

<STRING_EXP_STATE>[\n]		{
						
						str += yytext;
						//cout<<str2;
						//str2 += yytext;
						line_count++;
						BEGIN STRING_START_STATE;
					}
					



					
<STRING_EXP_STATE>.			{
						str += yytext;
						str2 += yytext;
						BEGIN STRING_START_STATE;
					}
				
"//"				{	
					str=yytext;
					BEGIN COMMENT_STATE_START;
				}
				
<COMMENT_STATE_START>([^\\|^\n])+|.       {	
					str+=yytext;
					BEGIN COMMENT_STATE_CONTINUE;
					
					}
<COMMENT_STATE_CONTINUE>"\\"	{	
					str+=yytext;	
					BEGIN COMMENT_STATE_START_2;
				
					
				}
	
<COMMENT_STATE_CONTINUE>"\n"	{	
					
					BEGIN INITIAL;
					
					
					
					
				}
<COMMENT_STATE_START_2>([^\\|^\n])+|. {	
					str+=yytext; 
					BEGIN COMMENT_STATE_CONTINUE;
					}									
<MULTI>"*/"			{
					str+=yytext;
			
					BEGIN INITIAL;
					
				}

<MULTI>([^*|^\n])+|.		{
					str+=yytext;
					BEGIN MULTI;	
				}
<MULTI>"\n"			{
					str+=yytext;
					line_count++;
					BEGIN MULTI;
				}	

<MULTI><<EOF>>			{	str+=yytext;
					number_of_errors++;
					BEGIN INITIAL;
				}
					
%%

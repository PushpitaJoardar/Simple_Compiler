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
#include<cstdlib>
#include<cstring>
#include<cstdio>
#include<fstream>
#include"main.cpp"
SymbolTable *st=new SymbolTable(7);
//extern "c" int yylex();



int line_count=1;
int number_of_errors=0;
string str;
string str2;
string str3;
string str4;
char c;
//char *t;
ofstream ol;
ofstream ot;

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
POINTDIGIT {DIGIT}+(\.[^{DIGIT}])
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
			ot<<"<IF>";
			ol<<"Line no "<<line_count<<": TOKEN <IF> Lexeme "<<yytext<<" found"<<endl;
		}
		
"else"	{
			ot<<"<ELSE>";
			ol<<"Line no "<<line_count<<": TOKEN <ELSE> Lexeme "<<yytext<<" found"<<endl;
		}
"for"	{		
			ot<<"<FOR>";
			ol<<"Line no "<<line_count<<": TOKEN <FOR> Lexeme "<<yytext<<" found"<<endl;
		}
"while"	{
			ot<<"<WHILE>";
			ol<<"Line no "<<line_count<<": TOKEN <WHILE> Lexeme "<<yytext<<" found"<<endl;	
		}
"do"		{	
			ot<<"<DO>";
			ol<<"Line no "<<line_count<<": TOKEN <DO> Lexeme "<<yytext<<" found"<<endl;
		}
"break"	{
			ot<<"<BREAK>";
			ol<<"Line no "<<line_count<<": TOKEN <BREAK> Lexeme "<<yytext<<" found"<<endl;
		}
"int"		{
			ot<<"<INT>";
			ol<<"Line no "<<line_count<<": TOKEN <INT> Lexeme "<<yytext<<" found"<<endl;
		}
"char"		{
			ot<<"<CHAR>";
			ol<<"Line no "<<line_count<<": TOKEN <CHAR> Lexeme "<<yytext<<" found"<<endl;
		}
"float"	{
			ot<<"<FLOAT>";
			ol<<"Line no "<<line_count<<": TOKEN <FLOAT> Lexeme "<<yytext<<" found"<<endl;
		}
"double"	{
			ot<<"<DOUBLE>";
			ol<<"Line no "<<line_count<<": TOKEN <DOUBLE> Lexeme "<<yytext<<" found"<<endl;
		}
"void"		{
			ot<<"<VOID>";
			ol<<"Line no "<<line_count<<": TOKEN <VOID> Lexeme "<<yytext<<" found"<<endl;
		}
"return"	{
			ot<<"<RETURN>";
			ol<<"Line no "<<line_count<<": TOKEN <RETURN> Lexeme "<<yytext<<" found"<<endl;
		}
"switch"	{
			ot<<"<SWITCH>";
			ol<<"Line no "<<line_count<<": TOKEN <SWITCH> Lexeme "<<yytext<<" found"<<endl;
		}
"case"		{
			ot<<"<CASE>";
			ol<<"Line no "<<line_count<<": TOKEN <CASE> Lexeme "<<yytext<<" found"<<endl;
		}
"default"	{
			ot<<"<DEFAULT>";
			ol<<"Line no "<<line_count<<": TOKEN <DEFAULT> Lexeme "<<yytext<<" found"<<endl;
		}
"continue"	{
			ot<<"<CONTINUE>";
			ol<<"Line no "<<line_count<<": TOKEN <CONTINUE> Lexeme "<<yytext<<" found"<<endl;
		}
"`"		{
			ol<<"Error at line no "<<line_count<<": Unrecognized character "<<yytext<<endl;
			number_of_errors++;
			BEGIN INITIAL;
		}
{POINTDIGIT}	{
			ol<<"Error at line no "<<line_count<<": Ill Formed Number "<<yytext<<endl;
			number_of_errors++;
			BEGIN INITIAL;
		}		
{DIGIT}+	{
			ot<<"<CONST_INT,"<<yytext<<">";
			ol<<"Line no "<<line_count<<": TOKEN <CONST_INT> Lexeme "<<yytext<<" found"<<endl;
			st->insertSymbol(yytext,"CONST_INT");
			st->printAllScopeTable(ol,7);
		}

{FLOAT}	{	
			str4=yytext;
			
			//BEGIN FLOAT1_STATE;
			ot<<"<CONST_FLOAT,"<<str4<<">";
			ol<<"Line no "<<line_count<<": TOKEN <CONST_FLOAT> Lexeme "<<str4<<" found"<<endl;
			st->insertSymbol(yytext,"CONST_FLOAT");
			st->printAllScopeTable(ol,7);
		}
{FLOAT2}	{	
			str4=yytext;
			
			//BEGIN FLOAT1_STATE;
			ot<<"<CONST_FLOAT,"<<str4<<">";
			ol<<"Line no "<<line_count<<": TOKEN <CONST_FLOAT> Lexeme "<<str4<<" found"<<endl;
			st->insertSymbol(yytext,"CONST_FLOAT");
			st->printAllScopeTable(ol,7);
		}
		
{ERROR_FLOAT1}		{

				
				ol<<"Error at line no "<<line_count<<": Too many decimal points "<<yytext<<endl;
				number_of_errors++;
				BEGIN INITIAL;
			}
{ERROR_FLOAT2}		{
				ol<<"Error at line no "<<line_count<<": Ill Formed Number "<<yytext<<endl;
				number_of_errors++;
				BEGIN INITIAL;
			}
{ERROR_FLOAT3}		{
				ol<<"Error at line no "<<line_count<<": Ill Formed Number "<<yytext<<endl;
				number_of_errors++;
				BEGIN INITIAL;
			}
{MULTIERROR}			{
					ol<<"Error at line no "<<line_count<<": Multi character constant error "<<yytext<<endl;
					number_of_errors++;
					BEGIN INITIAL;
				}

			
"'"		{	
			str2=yytext;
		
			BEGIN CHAR_CONST_STATE;
			//fprintf(tokenout,"CHAR_CONST_STATE HAS STARTED AT %s\n",yytext);
			
		}			

		
<CHAR_CONST_STATE>{CHARACTERS}	{
					c=yytext[0];
					//strcpy(str,&c);
					str = yytext;
					str2+=yytext;
					//printf("ccc %s\n",str);
					BEGIN CHAR_E_STATE;
				}
		
				
<CHAR_CONST_STATE>"\\"		{	//fprintf("CHAR_CONST_EXP_STATE HAS STARTED AT %s\n",yytext);
					str2+=yytext;
					
					BEGIN CHAR_CONST_EXP_STATE;
				
				}
<CHAR_CONST_STATE>"'"		{
					ol<<"Error at line no "<<": Empty character constant error ' ' "<<endl;
					number_of_errors++;
					BEGIN INITIAL;
				}			
<CHAR_CONST_STATE>[\n]		{
					ol<<"Error at line no "<<line_count<<": Unrecognized character "<<str2<<endl;
					line_count++;
					number_of_errors++;
					BEGIN INITIAL;
				}
<CHAR_CONST_STATE>[\t]		{	ol<<"Error at line no "<<line_count<<": Unrecognized character "<<str2<<endl;
					number_of_errors++;
					BEGIN INITIAL;

				}
<CHAR_CONST_STATE>.		{	str2+=yytext;
					ol<<"Error at line no "<<line_count<<": Unrecognized character "<<str2<<endl;
					line_count++;
					number_of_errors++;
					BEGIN INITIAL;
				}		

					
<CHAR_E_STATE>"'"			{
					//printf("%s",yytext);
					string s="";
					s+=c;
					ot<<"<CONST_CHAR,"<<c<<">";
					ol<<"Line no "<<line_count<<": TOKEN <CONST_CHAR> Lexeme "<<c<<" found"<<endl;
					st->insertSymbol(s,"CONST_CHAR");
					st->printAllScopeTable(ol,7);
					BEGIN INITIAL;
					
					}
<CHAR_E_STATE>[^"'"]	{
					str2+=yytext;
					ol<<"Error at line no "<<line_count<<": Unterminated character"<<str2<<endl;
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
			
<CHAR_CONST_EXP_STATE>"r"	{
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
<CHAR_CONST_EXP_STATE>"0"	{
				str2+=yytext;
				str3=yytext;
				BEGIN CHAR_CONST_EXP_STATE_END;
				
			}


		
			


<CHAR_CONST_EXP_STATE_END>"'"	{
				if(str3=="n"){
				ot<<"<CONST_CHAR,\n>";
				ol<<"Line no "<<line_count<<": TOKEN <CONST_CHAR> Lexeme '\n' found"<<endl;
				st->insertSymbol("\n","CONST_CHAR");
				line_count++;
				st->printAllScopeTable(ol,7);
				BEGIN INITIAL;
			}
				else if(str3=="t"){
				ot<<"<CONST_CHAR,\t>";
				ol<<"Line no "<<line_count<<": TOKEN <CONST_CHAR> Lexeme \t found"<<endl;
				st->insertSymbol("\t","CONST_CHAR");
				st->printAllScopeTable(ol,7);
				BEGIN INITIAL;
				}
				else if(str3=="\\"){
				ot<<"<CONST_CHAR,\\\\>";
				ol<<"Line no "<<line_count<<": TOKEN <CONST_CHAR> Lexeme '\\\\' found"<<endl;
				st->insertSymbol("\\","CONST_CHAR");
				st->printAllScopeTable(ol,7);
				BEGIN INITIAL;
				}
				else if(str3=="'"){
				ot<<"<CONST_CHAR,\\'>";
				ol<<"Line no "<<line_count<<": TOKEN <CONST_CHAR> Lexeme '\\'' found"<<endl;
				st->insertSymbol("\'","CONST_CHAR");
				st->printAllScopeTable(ol,7);
				BEGIN INITIAL;
				}
				else if(str3=="\""){
				ot<<"<CONST_CHAR,\\\">";
				ol<<"Line no "<<line_count<<": TOKEN <CONST_CHAR> Lexeme '\\\"' found"<<endl;
				st->insertSymbol("\'","CONST_CHAR");
				st->printAllScopeTable(ol,7);
				BEGIN INITIAL;
				}
				else if(str3=="a"){
				ot<<"<CONST_CHAR,\a>";
				ol<<"Line no "<<line_count<<": TOKEN <CONST_CHAR> Lexeme '\a' found"<<endl;
				st->insertSymbol("\a","CONST_CHAR");
				st->printAllScopeTable(ol,7);
				BEGIN INITIAL;
				}
				else if(str3=="f"){
				ot<<"<CONST_CHAR,\f>";
				ol<<"Line no "<<line_count<<": TOKEN <CONST_CHAR> Lexeme '\f' found"<<endl;
				st->insertSymbol("\f","CONST_CHAR");
				st->printAllScopeTable(ol,7);
				BEGIN INITIAL;
				}
				else if(str3=="r"){
				ot<<"\n";
				ot<<"<CONST_CHAR,\r>";
				ol<<"Line no "<<line_count<<": TOKEN <CONST_CHAR> Lexeme slash r found"<<endl;
				st->insertSymbol("\r","CONST_CHAR");
				st->printAllScopeTable(ol,7);
				BEGIN INITIAL;
				}
				else if(str3=="b"){
				ot<<"<CONST_CHAR,\b>";
				ol<<"Line no "<<line_count<<": TOKEN <CONST_CHAR> Lexeme '\b' found"<<endl;
				st->insertSymbol("\b","CONST_CHAR");
				st->printAllScopeTable(ol,7);
				BEGIN INITIAL;
				}
				else if(str3=="v"){
				ot<<"<CONST_CHAR,\v>";
				ol<<"Line no "<<line_count<<": TOKEN <CONST_CHAR> Lexeme '\v' found"<<endl;
				st->insertSymbol("\v","CONST_CHAR");
				st->printAllScopeTable(ol,7);
				BEGIN INITIAL;				
				}
				else if(str3=="0"){
				ot<<"<CONST_CHAR,\0>";
				ot<<"\n";
				ol<<"Line no "<<line_count<<": TOKEN <CONST_CHAR> Lexeme slash 0 found"<<endl;
				st->insertSymbol("\0","CONST_CHAR");
				st->printAllScopeTable(ol,7);
				BEGIN INITIAL;				
				}
			}
<CHAR_CONST_EXP_STATE_END>[^"'"]		{
					str2+=yytext;
					ol<<"Error at line no "<<line_count<<": Unterminated character"<<str2<<endl;
					number_of_errors++;
					BEGIN INITIAL;
				}

{ADDOP}		{
			ot<<"<ADDOP,"<<yytext<<">";
			ol<<"Line no "<<line_count<<": TOKEN <ADDOP> Lexeme "<<yytext<<" found"<<endl;
			//insert in symbol table and print symbol table content(only non empty buckets)
			// There is a '|' in "+"'s rule, this means match execute the action for following rule
		}
"/"		|
"*"		|
"%"             {
			ot<<"<MULOP,"<<yytext<<">";
			ol<<"Line no "<<line_count<<": TOKEN <MULOP> Lexeme "<<yytext<<" found"<<endl;
		}
"++"           |
"--"           {
			ot<<"<INCOP,"<<yytext<<">";
			ol<<"Line no "<<line_count<<": TOKEN <INCOP> Lexeme "<<yytext<<" found"<<endl;
		}
"<"            |
"<="           |
">"            |
">="           |
"=="           |
"!="           {
			ot<<"<RELOP,"<<yytext<<">";
			ol<<"Line no "<<line_count<<": TOKEN <RELOP> Lexeme "<<yytext<<" found"<<endl;
		}
"="            {
			ot<<"<ASSIGNOP,"<<yytext<<">";
			ol<<"Line no "<<line_count<<": TOKEN <ASSIGNOP> Lexeme "<<yytext<<" found"<<endl;
		}
"&&"		|
"||"           {
			ot<<"<LOGICOP,"<<yytext<<">";
			ol<<"Line no "<<line_count<<": TOKEN <LOGICOP> Lexeme "<<yytext<<" found"<<endl;
		}
"!"            {
			ot<<"<NOT,"<<yytext<<">";
			ol<<"Line no "<<line_count<<": TOKEN <NOT> Lexeme "<<yytext<<" found"<<endl;
	        }
"("	        {	
			ot<<"<LPAREN,"<<yytext<<">";
			ol<<"Line no "<<line_count<<": TOKEN <LPAREN> Lexeme "<<yytext<<" found"<<endl;
	        }
")"	        {	
			ot<<"<RPAREN,"<<yytext<<">";
			ol<<"Line no "<<line_count<<": TOKEN <RPAREN> Lexeme "<<yytext<<" found"<<endl;
	        }
"{"	        {	
			ot<<"<LCURL,"<<yytext<<">";
			ol<<"Line no "<<line_count<<": TOKEN <LCURL> Lexeme "<<yytext<<" found"<<endl;
			st->enterScope(7);
	        }
"}"	        {	
			ot<<"<RPAREN,"<<yytext<<">";
			ol<<"Line no "<<line_count<<": TOKEN <RCURL> Lexeme "<<yytext<<" found"<<endl;
			st->exit();
	        }
"["	        {	
			ot<<"<LTHIRD,"<<yytext<<">";
			ol<<"Line no "<<line_count<<": TOKEN <LTHIRD> Lexeme "<<yytext<<" found"<<endl;
	        }
"]"	        {	
			ot<<"<RTHIRD,"<<yytext<<">";
			ol<<"Line no "<<line_count<<": TOKEN <RTHIRD> Lexeme "<<yytext<<" found"<<endl;
	        }
","	        {	
			ot<<"<COMMA,"<<yytext<<">";
			ol<<"Line no "<<line_count<<": TOKEN <COMMA> Lexeme "<<yytext<<" found"<<endl;
	        }
";"	        {	
			ot<<"<SEMICOLON,"<<yytext<<">";
			ol<<"Line no "<<line_count<<": TOKEN <SEMICOLON> Lexeme "<<yytext<<" found"<<endl;
	        }
{ID2}		{	
			ol<<"Error at line no "<<line_count<<": Invalid prefix on ID or invalid suffix on Number "<<yytext<<endl;
			number_of_errors++;
			BEGIN INITIAL;

		}
{ID}		{	ot<<"<ID,"<<yytext<<">";
			ol<<"Line no "<<line_count<<": TOKEN <ID> Lexeme "<<yytext<<" found"<<endl;
			st->insertSymbol(yytext,"ID");
			st->printAllScopeTable(ol,7);
		}
		
"\""		{	
			//printf("rrt %s",yytext);
			str = "\"";
			str2 = "\"";
			BEGIN STRING_START_STATE;
			
		}
		

					
<STRING_START_STATE>"\""			{
						str += "\"";
						str2 += "\"";
						ot<<"<STRING,"<<str2<<">";
						ol<<"Line no "<<line_count<<": TOKEN <STRING> Lexeme "<<str<<" found  ";
						ol<<"-->"<<"<STRING,"<<str2<<">"<<endl;
						BEGIN INITIAL;
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
						//printf("xcfdcfv   %s",yytext);
						str += yytext;
						BEGIN STRING_EXP_STATE;
					}

<STRING_START_STATE>[\n]	{
						
						
						ol<<"Error at line no "<<line_count<<": Unterminated String "<<str<<endl;
						number_of_errors++;
						line_count++;
						
						BEGIN INITIAL;
				}

<STRING_START_STATE>.		{
					//strcpy(str,yytext);
					str += yytext;
					str2 += yytext;
					BEGIN STRING_START_STATE;
					
					}

<STRING_EXP_STATE>[\n]		{
						//printf("xcfdcfv   %s",yytext);
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
					//ol<<"Line no "<<line_count<<": TOKEN <COMMENT> Lexeme "<<str<<" found"<<endl;	
					BEGIN COMMENT_STATE_START_2;
				
					
				}
	
<COMMENT_STATE_CONTINUE>"\n"	{	ol<<"Line no "<<line_count<<": TOKEN <COMMENT> Lexeme "<<str<<" found"<<endl;
					line_count++;
					BEGIN INITIAL;
					
				}
<COMMENT_STATE_START_2>([^\\|^\n])+|. {	//ol<<"Line no "<<line_count<<": TOKEN <COMMENT> Lexeme "<<str<<" found"<<endl;
					str+=yytext; 
					BEGIN COMMENT_STATE_CONTINUE;
					}									

					

"/*"				{
					str=yytext;
					BEGIN MULTI;
				}

<MULTI>"*/"			{
					str+=yytext;
					ol<<"Line no "<<line_count<<": TOKEN <COMMENT> Lexeme "<<str<<endl;
					BEGIN INITIAL;
					//BEGIN MULTI_2;
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
					ol<<"Error at line no "<<line_count<<": Unterminated Comment "<<str<<endl;
					number_of_errors++;
					BEGIN INITIAL;
				}











%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	//ifstream in;
    	//in.open("demo2.txt");
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	//logout= fopen("log.txt","w");
	//tokenout= fopen("token.txt","w");
	//ol.open("logout.txt");
	//ot.open("token.txt");
	ol.open("1705052_log.txt",ios::out);
	ot.open("1705052_token.txt",ios::out);


	yyin= fin;
	//yyin=in;
	yylex();
	
	fclose(yyin);
	st->printAllScopeTable(ol,7);
	ol<<"Total lines:" <<line_count<<endl;
	ol<<"Total errors: "<<number_of_errors<<endl;
	ot.close();
	ol.close();
	return 0;
}

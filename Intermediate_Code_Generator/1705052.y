%{

#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<vector>
#include <sstream>
#include "main.cpp"


using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int line_count;
extern int number_of_errors;
SymbolTable *table = new SymbolTable(30);
ofstream cl;
ofstream ol;
ofstream el;
vector<SymbolInfo*> array;
vector<SymbolInfo*> arguL;
vector<string> id;
char newl='\n';
string var="";
bool ary=false;
bool fun=false;
string funcid="";
//int yydebug;
//int yyparse(void);
//int yylex(void);
//double var[26];

int labelCount=0;
int tempCount=0;


char *newLabel()
{
	char *lb= new char[4];
	strcpy(lb,"L");
	char b[3];
	sprintf(b,"%d", labelCount);
	labelCount++;
	strcat(lb,b);
	return lb;
}

char *newTemp()
{
	char *t= new char[4];
	strcpy(t,"t");
	char b[3];
	sprintf(b,"%d", tempCount);
	tempCount++;
	strcat(t,b);
	string temp=t;
	var+=temp+" DW 0H \n";
	return t;
}

void yyerror(char *s)
{
	fprintf(stderr,"%s\n",s);
	return;
}

%}
%union{
	SymbolInfo* si;
	int it;
	//char *str;
}
%token <it> IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE MAIN PRINTLN
%token <si> CONST_INT 
%token <si> CONST_FLOAT 
%token <si> CONST_CHAR 
%token <si> ADDOP 
%token <si> MULOP 
%token <it> INCOP 
%token <it> DECOP 
%token <si> RELOP ASSIGNOP LOGICOP 
%token <it> NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD SEMICOLON COMMA 
%token <si> ID 
%token <it> STRING
%type <si> program unit func_declaration func_definition parameter_list compound_statement var_declaration statement statements
%type <si> declaration_list
%type <si> expression_statement expression variable logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments
%type <si> type_specifier 
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE 

%%
start : program
	{	
		{ol<<"Line "<<line_count<<": start : program  "<<endl;
		ol<<endl;ol<<endl;ol<<endl;
		} 
		table->printAllScopeTable(ol,30);
		ol<<endl;
		cl<<".MODEL SMALL"<<endl;
		cl<<".STACK 100H "<<endl;
		cl<<".DATA"<<endl;
		cl<<endl;
		cl<<"CR EQU 0DH"<<endl;
    	cl<<"LF EQU 0AH"<<endl;
		cl<<endl;
		cl<<"SPACING DB CR, LF , '$'"<<endl;
		cl<<endl;
		cl<<var;
		cl<<endl;
		cl<<".Code"<<endl;
		cl<<endl;
		cl<<$1->Code;
		cl<<"OUTPUT PROC"<<endl; 
    	cl<<"CMP AX,0       ;CHECK IF AX<0"<<endl;
    	cl<<"JGE POSITIVE_"<<endl;
   		cl<<"PUSH AX"<<endl;
    	cl<<"MOV DL,'-'     ;WHEN THE NUMBER IS MINUS"<<endl;
    	cl<<"MOV AH,2"<<endl;
    	cl<<"INT 21H"<<endl;
    	cl<<"POP AX"<<endl;
    	cl<<"NEG AX         ;2'S COMPLIMENT OF THE INPUT"<<endl;
		cl<<"POSITIVE_:"<<endl;
   		cl<<"MOV CX,0       ;CLEAR THE COUNT REGISTER"<<endl;
    	cl<<"MOV BX,10"<<endl;
		cl<<"TOP:"<<endl; 
    	cl<<"MOV DX,0       ;CLEARING DX TO PUT VALUE"<<endl;
    	cl<<"DIV BX         ;AX VAGFOL,VAGSESH DX"<<endl;
    	cl<<"PUSH DX"<<endl;
	    cl<<"INC CX"<<endl;
    	cl<<"CMP AX,0"<<endl;
    	cl<<"JNE TOP      ;AS LONG AS THERE IS SOMETHING TO DIVIDE"<<endl;
   		cl<<"MOV AH,2"<<endl;
		cl<<"P_LOOP:"<<endl;
    	cl<<"POP DX        ;POPPING THE REMAINDER IN A LOOP"<<endl;
    	cl<<"OR DL,30H"<<endl;
    	cl<<"INT 21H"<<endl;
    	cl<<"LOOP P_LOOP"<<endl;
		cl<<endl;
		cl<<"LEA DX, SPACING"<<endl;          
    	//cl<<"MOV AH, 9"<<endl;
    	cl<<"INT 21H"<<endl;
		cl<<endl;
    	cl<<"RET"<<endl;
		cl<<endl;
		cl<<"OUTPUT ENDP"<<endl; cl<<endl; cl<<endl;
    	cl<<"END MAIN"<<endl;
    
		//write your code in this block in all the similar blocks below
	}
	;

program : program unit 		{ol<<"Line "<<line_count<<": program : program unit "<<endl;
							ol<<endl;
							$$=new SymbolInfo($1->getName()+"\n"+$2->getName(),"");
							ol<<$1->getName()<<endl;
							ol<<$2->getName()<<endl;
							ol<<endl; ol<<endl; 
							$$->Code=$1->Code+$2->Code;
							delete $1,$2;
							} 
	| unit		{ol<<"Line "<<line_count<<": program : unit "<<endl;
				ol<<endl;
				$$=$1;
				ol<<$1->getName()<<endl;
				ol<<endl;
				$$->Code=$1->Code;
				}
	;
	
unit : var_declaration	{ol<<"Line "<<line_count<<": unit : var_declaration "<<endl;
						ol<<endl;
						$$=$1;
						ol<<$$->getName()<<endl;
						ol<<endl;
						$$->Code=$1->Code;
						} 
     | func_declaration		{ol<<"Line "<<line_count<<": unit : func_declaration "<<endl; 
	 						ol<<endl;
	 						$$=$1;
							 ol<<$$->getName()<<endl;
							 ol<<endl;
							 $$->Code=$1->Code;
							 } 
     | func_definition		{ol<<"Line "<<line_count<<": unit : func_definition "<<endl; 
	 						ol<<endl;
	 						$$=$1;
							 ol<<$$->getName()<<endl;
							 ol<<endl;
							 $$->Code=$1->Code;
							 } 
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN {
	
	SymbolInfo *s= table->LookUpSymbol($2->getName());
	if(s==NULL)
	{					
		table->insertSymbol($2->getName(),"ID");
		SymbolInfo *t= table->LookUpSymbol($2->getName());
		t->setVariableType("function");
		int np=array.size();
		string rT=$1->getName();
		vector<string> para;
		for(int i=0; i<array.size(); i++)
		{
			para.push_back(array[i]->getType());
		}
		t->setrTpLnP(np, rT, para);
		array.clear();
	}
	else
	{	
		ol<<"Error at line "<<line_count-1<<": Multiple declaration of "<<$2->getName()<<endl;
		ol<<endl;
		el<<"Error at line "<<line_count-1<<": Multiple declaration of "<<$2->getName()<<endl;
		el<<endl;
		number_of_errors++;
		
	}
																					
	}
	SEMICOLON		
	{ol<<"Line "<<line_count<<": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON "<<endl; 
			ol<<endl;																		
			ol<<$1->getName()<<" "<<$2->getName()<<"("<<$4->getName()<<")"<<";"<<endl;
			ol<<endl;
			$$=new SymbolInfo($1->getName()+" "+$2->getName()+"("+$4->getName()+")"+";","");
			delete $1,$2,$4;
	} 
	| type_specifier ID LPAREN RPAREN
	 {
		SymbolInfo *s= table->LookUpSymbol($2->getName());
		if(s==NULL)
		{					
			table->insertSymbol($2->getName(),"ID");
			SymbolInfo *t= table->LookUpSymbol($2->getName());
			t->setVariableType("function");
			int np= 0;
			string rT=$1->getName();
			vector<string> para;
			t->setrTpLnP(np, rT, para);
			
		}
		else
		{	
			ol<<"Error at line "<<line_count-1<<": Multiple declaration of "<<$2->getName()<<endl;
			ol<<endl;
			el<<"Error at line "<<line_count-1<<": Multiple declaration of "<<$2->getName()<<endl;
			el<<endl;
			number_of_errors++;
		}
	
		
	}SEMICOLON		{ol<<"Line "<<line_count<<": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON "<<endl;
					ol<<endl;
					ol<<$1->getName()<<" "<<$2->getName()<<"("<<")"<<";"<<endl;
					ol<<endl;
					$$=new SymbolInfo($1->getName()+" "+$2->getName()+"("+")"+";","");
					delete $1,$2;
					} 
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN {
	SymbolInfo *s= table->LookUpSymbol($2->getName());
	if(s==NULL)
	{					
	table->insertSymbol($2->getName(),"ID");
	SymbolInfo *t= table->LookUpSymbol($2->getName());
	t->setVariableType("function");
	int np=array.size();
	vector<string> para;
	string rT=$1->getName();
	for(int i=0; i<array.size(); i++)
	{
		para.push_back(array[i]->getType());
	}
	t->setrTpLnP(np, rT, para);
	}
	else
	{
		vector<string> pm = s->getParameterList();
		if(s->getVariableType().compare("function") != 0){
			ol<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->getName()<<endl;
			ol<<endl;
			el<<"Error at line "<<line_count<<": Multiple declaration of "<<$2->getName()<<endl;
			el<<endl;
			number_of_errors++;
		}
		else{
			if(s->getNumberOfparameters()!=array.size())
			{
				ol<<"Error at line "<<line_count<<": Total number of arguments mismatch with declaration in function "<<$2->getName()<<endl;
				ol<<endl;
				el<<"Error at line "<<line_count<<": Total number of arguments mismatch with declaration in function "<<$2->getName()<<endl;
				el<<endl;
				number_of_errors++;
			}
			else if(s->getReturnType().compare($1->getName()) != 0)
			{
				ol<<"Error at line "<<line_count<<": Return type mismatch with function declaration in function "<<$2->getName()<<endl;
				ol<<endl;
				el<<"Error at line "<<line_count<<": Return type mismatch with function declaration in function "<<$2->getName()<<endl;
				el<<endl;
				number_of_errors++;
			}
			else {
				for(int i=0; i<pm.size();i++)
				{
					if(pm[i].compare(array[i]->getType())!=0)
					{
						ol<<"Error at line "<<line_count<<": parameters don't match "<<endl;
						ol<<endl;
						el<<"Error at line "<<line_count<<": parameters don't match "<<endl;
						el<<endl;
						number_of_errors++;
					}
				}
			}


		}
		
	}
}
	compound_statement			{ol<<"Line "<<line_count<<": func_definition  : type_specifier ID LPAREN parameter_list RPAREN compound_statement "<<endl;
								ol<<endl;
								//SymbolInfo *s= table->LookUpSymbol($2->getName());
								//vector<string> pm = s->getParameterList();		
								ol<<$1->getName()<<" "<<$2->getName()<<"("<<$4->getName()<<")"<<$7->getName()<<endl;
								ol<<endl;
								$$=new SymbolInfo($1->getName()+" "+$2->getName()+"("+$4->getName()+")"+$7->getName(),"");
								$$->Code+=$2->getName()+"  PROC"+"\n";
								$$->Code+="POP BX \n";
								for(int i=array.size()-1;i>=0;i--){
									$$->Code+="POP "+array[i]->getName()+funcid+"\n";
									var+=array[i]->getName()+funcid+" DW 0H \n";
								}
								$$->Code+="PUSH BX \n";
								
								$$->Code+=$7->Code+"RET \n"+$2->getName()+"  ENDP \n";

								array.clear();
								funcid="";
								delete $1,$2,$4,$7;
								} 
		| type_specifier ID LPAREN RPAREN {
			SymbolInfo *s= table->LookUpSymbol($2->getName());
				if(s==NULL)
			{					
				table->insertSymbol($2->getName(),"ID");
				SymbolInfo *t= table->LookUpSymbol($2->getName());
				t->setVariableType("function");
				int np= 0;
				string rT=$1->getName();
				vector<string> para;
				t->setrTpLnP(np, rT, para);
			}
			else
			{
				if(s->getVariableType().compare("function") != 0){
				ol<<"Error at line "<<line_count-1<<": Multiple declaration of "<<$2->getName()<<endl;
				ol<<endl;
		        el<<"Error at line "<<line_count-1<<": Multiple declaration of "<<$2->getName()<<endl;
				el<<endl;
				number_of_errors++;
			}
				else{
					if(s->getNumberOfparameters()!=0)
					{	
						ol<<"Error at line "<<line_count<<": Total number of arguments mismatch with declaration in function "<<$2->getName()<<endl;
						ol<<endl;
						el<<"Error at line "<<line_count<<": Total number of arguments mismatch with declaration in function "<<$2->getName()<<endl;
						el<<endl;
						number_of_errors++;
					}
					else if(s->getReturnType().compare($1->getName()) != 0)
					{
						ol<<"Error at line "<<line_count<<": return type doesn't match "<<endl;
						ol<<endl;
						el<<"Error at line "<<line_count<<": return type doesn't match "<<endl;
						el<<endl;
						number_of_errors++;
					}
				
				}
				
			}
			}
			compound_statement	
				{ol<<"Line "<<line_count<<": func_definition : type_specifier ID LPAREN RPAREN compound_statement "<<endl; 
				ol<<endl;
				ol<<$1->getName()<<" "<<$2->getName()<<"("<<")"<<$6->getName()<<endl;
				ol<<endl;
				$$=new SymbolInfo($1->getName()+" "+$2->getName()+"("+")"+$6->getName(),"");
				$$->Code+=$2->getName()+"  PROC"+"\n";
				$$->Code+=$6->Code;
				if($2->getName().compare("main")==0)
				{
					$$->Code+="EXIT: \n" ;
    				$$->Code+="MOV AH,4CH \n";      
    				$$->Code+="INT 21H \n";
				}
				else{
					$$->Code+="RET \n";
				}
				$$->Code+=$2->getName()+"  ENDP \n";
				array.clear();
				delete $1,$2,$6;
				} 
 		;				


parameter_list  : parameter_list COMMA type_specifier ID	{ol<<"Line "<<line_count<<": parameter_list : parameter_list COMMA type_specifier ID "<<endl;
															ol<<endl;
															array.push_back(new SymbolInfo($4->getName(),$3->getName()));			
															$$=new SymbolInfo($1->getName()+","+$3->getName()+" "+$4->getName(),"");
															ol<<$1->getName()<<","<<$3->getName()<<" "<<$4->getName()<<endl;
															ol<<endl;
															delete $1,$3,$4;
															} 
		| parameter_list COMMA type_specifier	{ol<<"Line "<<line_count<<": parameter_list : parameter_list COMMA type_specifier"<<endl; 
												ol<<endl;			
												array.push_back(new SymbolInfo("",$3->getName()));
												ol<<$1->getName()<<","<<$3->getName()<<endl;
												ol<<endl;
												$$=new SymbolInfo($1->getName()+","+$3->getName(),"");
												delete $1,$3;
												} 
 		| type_specifier ID			{ol<<"Line "<<line_count<<": parameter_list : type_specifier ID"<<endl;	
		 							ol<<endl;
									array.push_back(new SymbolInfo($2->getName(),$1->getName()));
		 							ol<<$1->getName()<<" "<<$2->getName()<<endl;
									ol<<endl;
									$$=new SymbolInfo($1->getName()+" "+$2->getName(),"");
									delete $1,$2;
									  } 
		| type_specifier			{ol<<"Line "<<line_count<<": parameter_list : type_specifier"<<endl;
									ol<<endl;			
									array.push_back(new SymbolInfo("",$1->getName()));
									$$=new SymbolInfo($1->getName(),"");
									ol<<$1->getName()<<endl;
									ol<<endl;
									delete $1;
									} 
 		;

 		
compound_statement : LCURL {
	table->enterScope(30);
	funcid=table->currentScopeId();
		for(int i = 0; i < array.size(); i++)
       	{	
			SymbolInfo *s= table->LookUpSymbolCurrent(array[i]->getName());
				if(s==NULL)
				{
				table->insertSymbol(array[i]->getName(),"ID");
				SymbolInfo *t= table->LookUpSymbol(array[i]->getName());
				t->setVariableType(array[i]->getType());
				}
				else
				{
				ol<<"Error at line "<<line_count-1<<": Multiple declaration of "<<array[i]->getName()<<" in parameter"<<endl;
				ol<<endl;
				el<<"Error at line "<<line_count-1<<": Multiple declaration of "<<array[i]->getName()<<" in parameter"<<endl;
				el<<endl;
				number_of_errors++;
				}
		}
		//array.clear();
	}
	statements RCURL		{ ol<<"Line "<<line_count<<": compound_statement : LCURL statements RCURL  "<<endl; //somossha 
							  ol<<endl;
							  $$=new SymbolInfo("{"+$3->getName()+"\n"+"}","");
							  ol<<"{"<<endl;
							  ol<<endl;
							  ol<<$3->getName()<<endl; ol<<endl;
							  ol<<"}"<<endl; 
							  table->printAllScopeTable(ol,30);
							  table->exit();
							  ol<<endl;
							  $$->Code+=$3->Code;
							  //ol<<$$->Code<<endl;
							  delete $3;
							}
 		    | LCURL{
				 table->enterScope(30); 
				 funcid=table->currentScopeId();
				 for(int i = 0; i < array.size(); i++)
       			 {	
					SymbolInfo *s= table->LookUpSymbolCurrent(array[i]->getName());
					if(s==NULL)
					{
					table->insertSymbol(array[i]->getName(),"ID");
					SymbolInfo *t= table->LookUpSymbol(array[i]->getName());
					t->setVariableType(array[i]->getType());
					}
					else
					{
						ol<<"Error at line "<<line_count-1<<": Multiple declaration of "<<array[i]->getName()<<" in parameter"<<endl;
						ol<<endl;
						el<<"Error at line "<<line_count-1<<": Multiple declaration of "<<array[i]->getName()<<" in parameter"<<endl;
						el<<endl;
						number_of_errors++;
					}
				}
				//array.clear();
				} RCURL
					
			 		{ ol<<"Line "<<line_count<<": compound_statement : LCURL RCURL "<<endl; ol<<endl;
			 		  $$=new SymbolInfo("{ }","");
					  ol<<"{"<<" "<<"}"<<endl; ol<<endl;
					  table->printAllScopeTable(ol,30);
					  table->exit();
					  ol<<endl;
				    }
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON		{ol<<"Line "<<line_count<<": var_declaration : type_specifier declaration_list SEMICOLON "<<endl;
																ol<<endl;
																ol<<$1->getName()<<" "<<$2->getName()<<";"<<endl; ol<<endl;
																$$=new SymbolInfo($1->getName()+" "+$2->getName()+";","");
																if($1->getName().compare("void")==0)
																{
																		ol<<"Error at line "<<line_count<<": Variable type cannot be void"<<endl;
																		ol<<endl;
																		el<<"Error at line "<<line_count<<": Variable type cannot be void"<<endl;
																		el<<endl;
																		number_of_errors++;
																		for(int i = 0; i < id.size(); i++)
       			 														{	
																			table->Remove(id[i]);
																		}
																		
																}
																else{

																	for(int i = 0; i < id.size(); i++)
       			 													{	
																		SymbolInfo *t= table->LookUpSymbolCurrent(id[i]);
																		if(t->getVariableType().compare("")==0)
																		{
																			t->setVariableType($1->getName());
																		}
																	}
																}
																id.clear();
																delete $1,$2;
																	} 
 		 ;
 		 
type_specifier	: INT	{ 
					ol<<"Line "<<line_count<<": type_specifier : INT "<<endl; ol<<endl;
					$$=new SymbolInfo("int",""); 
					ol<<$$->getName()<<endl; ol<<endl;
					}
 		| FLOAT			{ ol<<"Line "<<line_count<<": type_specifier : FLOAT "<<endl; ol<<endl;
		 				$$=new SymbolInfo("float","");
						ol<<$$->getName()<<endl; ol<<endl;
						 }
 		| VOID			{ ol<<"Line "<<line_count<<": type_specifier : VOID "<<endl; ol<<endl;
		 				$$=new SymbolInfo("void","");
						ol<<$$->getName()<<endl; ol<<endl;
						 }
 		;
 		
declaration_list : declaration_list COMMA ID	{ol<<"Line "<<line_count<<": declaration_list : declaration_list COMMA ID "<<endl;
												ol<<endl;
												SymbolInfo *s= table->LookUpSymbolCurrent($3->getName());
												if(s==NULL)
												{					
													table->insertSymbol($3->getName(),"ID");
													var+=$3->getName()+table->LookUpID($3->getName())+" DW 0H \n" ;
												}
												else
												{
													ol<<"Error at line "<<line_count<<": Multiple declaration of "<<$3->getName()<<endl;
													ol<<endl;
													el<<"Error at line "<<line_count<<": Multiple declaration of "<<$3->getName()<<endl;
													el<<endl;
													number_of_errors++;
												}
												id.push_back($3->getName());
												ol<<$1->getName()<<","<<$3->getName()<<endl;
												ol<<endl;
												$$=new SymbolInfo($1->getName()+","+$3->getName(),"");
												delete $1,$3;
												}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD	{	ol<<"Line "<<line_count<<": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD "<<endl;
		   															ol<<endl;
		   															SymbolInfo *s= table->LookUpSymbolCurrent($3->getName());
																	if(s==NULL)
																	{					
																		table->insertSymbol($3->getName(),"ID");
																	}
																	else
																	{
																		ol<<"Error at line "<<line_count<<": Multiple declaration of "<<$3->getName()<<endl;
																		ol<<endl;
																		el<<"Error at line "<<line_count<<": Multiple declaration of "<<$3->getName()<<endl;
																		el<<endl;
																		number_of_errors++;
																	}
																	SymbolInfo *t= table->LookUpSymbolCurrent($3->getName());
																	stringstream geek($5->getName());
 																	int x = 0;
   																	geek >> x;
																	t->setArr(x);
																	var+=$3->getName()+table->LookUpID($3->getName())+" DW ";
																	for(int i=0;i<x;i++)
																	{	
																		if(i==(x-1))
																		{
																			var+="0 \n";
																		}
																		else{
																			var+="0 ,";
																		}
																	}
																	id.push_back($3->getName());
		   															$$=new SymbolInfo($1->getName()+","+$3->getName()+"["+$5->getName()+"]","");
																	ol<<$1->getName()<<","<<$3->getName()<<"["<<$5->getName()<<"]"<<endl;
																	ol<<endl;
																	delete $1,$3,$5;
																 }
 		  | ID		{ 
			   		ol<<"Line "<<line_count<<": declaration_list : ID "<<endl;
					ol<<endl;
					SymbolInfo *s= table->LookUpSymbolCurrent($1->getName());
					if(s==NULL)
					{					
						table->insertSymbol($1->getName(),"ID");
						var+=$1->getName()+table->LookUpID($1->getName())+" DW 0H \n" ;
						
					}
					else
					{
						ol<<"Error at line "<<line_count<<": Multiple declaration of "<<$1->getName()<<endl;
						ol<<endl;
						el<<"Error at line "<<line_count<<": Multiple declaration of "<<$1->getName()<<endl;
						el<<endl;
						number_of_errors++;
					}
					id.push_back($1->getName());
					$$=new SymbolInfo($1->getName(),"");
					ol<<$1->getName()<<endl;
					ol<<endl;
					delete $1;
		   			}
 		  | ID LTHIRD CONST_INT RTHIRD	{	ol<<"Line "<<line_count<<": declaration_list : ID LTHIRD CONST_INT RTHIRD "<<endl;
		   									ol<<endl;
		   									SymbolInfo *s= table->LookUpSymbolCurrent($1->getName());
											if(s==NULL)
											{					
												table->insertSymbol($1->getName(),"ID");
											}
											else
											{
												ol<<"Error at line "<<line_count<<": Multiple declaration of "<<$1->getName()<<endl;
												ol<<endl;
												el<<"Error at line "<<line_count<<": Multiple declaration of "<<$1->getName()<<endl;
												el<<endl;
												number_of_errors++;
											}
											SymbolInfo *t= table->LookUpSymbolCurrent($1->getName());
											stringstream geek($3->getName());
 											int x = 0;
   											geek >> x;
											t->setArr(x);
											var+=$1->getName()+table->LookUpID($1->getName())+" DW ";
											for(int i=0;i<x;i++)
											{	
												if(i==(x-1))
													{
														var+="0 \n";
													}
												else{
														var+="0 ,";
													}
											}
											id.push_back($1->getName());
		   									$$=new SymbolInfo($1->getName()+"["+$3->getName()+"]","");
											ol<<$1->getName()<<"["<<$3->getName()<<"]"<<endl;	
											ol<<endl;
											delete $1,$3;
										}
 		  ;
 		  
statements : statement		{ ol<<"Line "<<line_count<<": statements : statement "<<endl;
							  ol<<endl;
								$$=new SymbolInfo($1->getName()+newl,"");
								ol<<$1->getName()<<endl;
								ol<<endl;
								$$->Code+=$1->Code;
								//ol<<$$->Code<<endl;
								delete $1;
								 }
	   | statements statement		{ ol<<"Line "<<line_count<<": statements : statements statement"<<endl;
	   								  ol<<endl;
	   									$$=new SymbolInfo($1->getName()+$2->getName()+newl,"");
										ol<<$1->getName()<<endl; ol<<$2->getName()<<endl;
										ol<<endl;
										$$->Code+=$1->Code+$2->Code;
										//ol<<$$->Code<<endl;
										delete $1,$2;
									}
	   ;
	   
statement : var_declaration		{ ol<<"Line "<<line_count<<": statement : var_declaration"<<endl; 
								  ol<<endl;
									$$=new SymbolInfo($1->getName(),"");
									ol<<$1->getName()<<endl;
									ol<<endl;
									delete $1;
									}
	  | expression_statement	{ ol<<"Line "<<line_count<<": statement : expression_statement"<<endl;
	  							  ol<<endl;
	  								$$=new SymbolInfo($1->getName(),"");
									ol<<$1->getName()<<endl;
									ol<<endl;
									$$->Code=$1->Code;
									//ol<<$$->Code<<endl;
									delete $1;
									   }
	  | compound_statement		{ ol<<"Line "<<line_count<<": statement : compound_statement"<<endl;
	  							  ol<<endl;
	  							  $$=new SymbolInfo($1->getName(),"");
								  ol<<$1->getName()<<endl;
								  ol<<endl;
								  $$->Code=$1->Code;
								  //ol<<$$->Code<<endl;
								  delete $1;
	 							 }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement	{ ol<<"Line "<<line_count<<": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement"<<endl;
	  																						  ol<<endl;
	  																						  $$=new SymbolInfo("for("+$3->getName()+$4->getName()+$5->getName()+")"+$7->getName(),"");		
																							  ol<<"for"<<"("<<$3->getName()<<$4->getName()<<$5->getName()<<")"<<$7->getName()<<endl;	
																							  ol<<endl;
																							  string l1=newLabel();
																							  string l2=newLabel();
																			 				  $$->Code+="; for ("+$3->getName()+$4->getName()+$5->getName()+")"+"\n";
																							  $$->Code+=$3->Code;
																							  $$->Code+=l1+": \n";
																							  $$->Code+=$4->Code+"\n";
																							  $$->Code+="CMP AX ,0 \n";
																							  $$->Code+="JE "+l2+"\n";
																							  $$->Code+=$7->Code+"\n";
																							  $$->Code+=$5->Code+"\n";
																							  $$->Code+="JMP "+l1+"\n";
																							  $$->Code+=l2+":\n";
																							   //ol<<$$->Code<<endl;
																							   
																							  delete $3,$4,$5,$7;
																							}
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE 		{ ol<<"Line "<<line_count<<": statement : IF LPAREN expression RPAREN statement"<<endl;
	  																		  ol<<endl;
	  																		  $$=new SymbolInfo("if("+$3->getName()+")"+$5->getName(),"");
																			  ol<<"if"<<"("<<$3->getName()<<")"<<$5->getName()<<endl;
																			  ol<<endl;
																			  string l1=newLabel();
																			  $$->Code+="; if ("+$3->getName()+")"+$5->getName()+"\n";
																			  $$->Code+=$3->Code;
																			  $$->Code+="CMP AX,0 \n";
																			  $$->Code+="JE "+l1+"\n";
																			  $$->Code+=$5->Code;
																			  $$->Code+=l1+": \n";
																			  

																			  delete $3,$5;
														  					 }
	  | IF LPAREN expression RPAREN statement ELSE statement		{ ol<<"Line "<<line_count<<": statement : IF LPAREN expression RPAREN statement ELSE statement"<<endl;
	  																  ol<<endl;
	  																  $$=new SymbolInfo("if("+$3->getName()+")"+$5->getName()+"else"+$7->getName(),"");
																	  ol<<"if"<<"("<<$3->getName()<<")"<<$5->getName()<<"else"<<$7->getName()<<endl;
																	  ol<<endl;
																	  string l2=newLabel();
																	  string l1=newLabel();
																	  $$->Code+="; if ("+$3->getName()+")"+$5->getName()+"\n";
																	  $$->Code+=$3->Code;
																	  $$->Code+="CMP AX,0 \n";
																	  $$->Code+="JE "+l1+"\n";
																	  $$->Code+=$5->Code;
																	  $$->Code+="JMP "+l2+" \n";
																	  $$->Code+=l1+": \n";
																	  $$->Code+=$7->Code;
																	  $$->Code+=l2+": \n";
																	  delete $3,$5,$7;
																	 }
	  | WHILE LPAREN expression RPAREN statement		{ ol<<"Line "<<line_count<<": statement : WHILE LPAREN expression RPAREN statement"<<endl; //chamged
	  													  ol<<endl;
	  													  $$=new SymbolInfo("while("+$3->getName()+")"+$5->getName(),"");
														  ol<<endl;
						
														  ol<<"while" << "("<<$3->getName()<<")"<<$5->getName()<<endl;
														  $$->Code+="; while ("+$3->getName()+") \n";
														  string l1=newLabel();
														  string l2=newLabel();
														  $$->Code+=l1+": \n";
														  $$->Code+=$3->Code;
														  $$->Code+="\n";
														  $$->Code+=$5->Code;
														  $$->Code+="\n";
														  $$->Code+="CMP BX , 0 \n";
														  $$->Code+="JE "+l2+"\n";
														  $$->Code+="JMP "+l1+"\n";
														  $$->Code+=l2+": \n";
														  $$->Code+=$3->Code+"\n";
														  ol<<$$->Code<<endl;
														  delete $3,$5;
														}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON			{ ol<<"Line "<<line_count<<": statement : PRINTLN LPAREN ID RPAREN SEMICOLON"<<endl;
	  												  ol<<endl;
														SymbolInfo *s= table->LookUpSymbol($3->getName());
														if(s==nullptr)
														{
															ol<<"Error at line "<<line_count<<": Undeclared variable "<<$3->getName()<<endl;
															ol<<endl;
															el<<"Error at line "<<line_count<<": Undeclared variable "<<$3->getName()<<endl;
															el<<endl;
															number_of_errors++;
														}
	  													$$=new SymbolInfo("println("+$3->getName()+")"+";","");
														$$->Code+="MOV AX, ";
														$$->Code+=$3->getName()+table->LookUpID($3->getName())+"\n";
														$$->Code+="CALL OUTPUT \n";
														ol<<"println"<<"("<<$3->getName()<<")"<<";"<<endl;
														ol<<endl;
														delete $3;
														   }
	  | RETURN expression SEMICOLON			{ ol<<"Line "<<line_count<<": statement : RETURN expression SEMICOLON "<<endl;
	  										  ol<<endl;
	  										  $$=new SymbolInfo("return "+$2->getName()+";","");
											  ol<<"return "<<$2->getName()<<";"<<endl;
											  ol<<endl;
											  $$->Code+=$2->Code+"\n";
											  $$->Code+="MOV BX ,"+$2->varAssem+"\n";
											  delete $2;
											}
	  ;
	  
expression_statement 	: SEMICOLON		{ ol<<"Line "<<line_count<<": expression_statement : SEMICOLON	"<<endl; 
										  ol<<endl;
											$$=new SymbolInfo(";","");
											ol<<";"<<endl;  ol<<endl;
											}	
			| expression SEMICOLON 		{ ol<<"Line "<<line_count<<": expression_statement : expression SEMICOLON "<<endl;
										  ol<<endl;
											$$=new SymbolInfo($1->getName()+";","");
											ol<<$1->getName()<<";"<<endl; 
											ol<<endl;
											$$->Code+=$1->Code;
											//ol<<$1->Code;
											delete $1;
										}
			;
	  
variable : ID 		{ ol<<"Line "<<line_count<<": variable : ID 	"<<endl;
					  ol<<endl;
						SymbolInfo *s= table->LookUpSymbol($1->getName());
						if(s==NULL)
						{					
							ol<<"Error at line "<<line_count<<": Undeclared variable "<<$1->getName()<<endl;
							ol<<endl;
							el<<"Error at line "<<line_count<<": Undeclared variable "<<$1->getName()<<endl;
							el<<endl;
							number_of_errors++;
							$$=new SymbolInfo($1->getName(),"");
							
						}
						else{
							if(s->getArr()!= 0)
							{	
								ol<<"Error at line "<<line_count<<": Type mismatch, "<<$1->getName()<<" is an array "<<endl;
								ol<<endl;
								el<<"Error at line "<<line_count<<": Type mismatch, "<<$1->getName()<<" is an array "<<endl;
								el<<endl;
								number_of_errors++;
								$$=new SymbolInfo($1->getName(),s->getVariableType()); 
							}
					   		$$=new SymbolInfo($1->getName(),s->getVariableType());
							}
						ol<<$1->getName()<<endl; ol<<endl;
						$$->varAssem=$1->getName()+table->LookUpID($1->getName());
						delete $1;
						}	
	 | ID LTHIRD expression RTHIRD 		{ ol<<"Line "<<line_count<<": variable : ID LTHIRD expression RTHIRD "<<endl;
	 									  ol<<endl;
	 										SymbolInfo *s= table->LookUpSymbol($1->getName());
											if(s==NULL)
											{					
												ol<<"Error at line "<<line_count<<": Undeclared variable "<<$1->getName()<<endl;
												ol<<endl;
												el<<"Error at line "<<line_count<<": Undeclared variable "<<$1->getName()<<endl;
												el<<endl;
												number_of_errors++;
												$$=new SymbolInfo($1->getName()+"["+$3->getName()+"]","");
											}
											else{
												if(s->getArr()== 0)
												{
													ol<<"Error at line "<<line_count<<": "<<$1->getName()<<" not an array "<<endl;
													ol<<endl;
													el<<"Error at line "<<line_count<<": "<<$1->getName()<<" not an array "<<endl;
													el<<endl;
													number_of_errors++;
													$$=new SymbolInfo($1->getName()+"["+$3->getName()+"]",s->getVariableType());
												}
					   							$$=new SymbolInfo($1->getName()+"["+$3->getName()+"]",s->getVariableType());
											}
											if($3->getType()!="int")
											{
												ol<<"Error at line "<<line_count<<": Expression inside third brackets not an integer"<<endl;
												ol<<endl;
												el<<"Error at line "<<line_count<<": Expression inside third brackets not an integer"<<endl;
												el<<endl;
												number_of_errors++;

											}
	 										
											ol<<$1->getName()<<"["<<$3->getName()<<"]"<<endl; 
											ol<<endl;
											$$->varAssem=$1->getName()+table->LookUpID($1->getName());
											$$->Code+="MOV SI, "+$3->varAssem+"\n";
											ary=true;
											delete $1,$3;
										}	
	 ;
	 
 expression : logic_expression			{ ol<<"Line "<<line_count<<": expression : logic_expression "<<endl; 
										  ol<<endl;
 											$$=new SymbolInfo($1->getName(),$1->getType());
											ol<<$1->getName()<<endl;
											ol<<endl;
											$$->varAssem=$1->varAssem;
											$$->Code+=$1->Code;
											//ol<<$$->Code<<endl;
											delete $1;
										}	
	   | variable ASSIGNOP logic_expression 		{ ol<<"Line "<<line_count<<": expression : variable ASSIGNOP logic_expression "<<endl; 
	   												  ol<<endl;
														if($1->getType().compare("")==0||$3->getType().compare("")==0)
														{
															$$=new SymbolInfo($1->getName()+" = "+$3->getName(),"");
															ol<<$1->getName()<<" = "<<$3->getName()<<endl;
															ol<<endl;
														}
														else if($3->getType().compare("void")==0)
														{
															ol<<"Error at line "<<line_count<<": Void function used in expression"<<endl;
															ol<<endl;
												 			el<<"Error at line "<<line_count<<": Void function used in expression"<<endl;
															el<<endl;
												 			number_of_errors++;
															$$=new SymbolInfo($1->getName()+" = "+$3->getName(),"");
															ol<<$1->getName()<<" = "<<$3->getName()<<endl;
															ol<<endl;
														}
														else if($1->getType()=="float"||$3->getType()=="int")
														{	
															$$=new SymbolInfo($1->getName()+" = "+$3->getName(),"");
															ol<<$1->getName()<<" = "<<$3->getName()<<endl;
															ol<<endl;
														}
														else if($1->getType()=="int"||$3->getType()=="float")
														{	
															ol<<$1->getType()<<endl; ol<<$3->getType()<<endl;
															ol<<endl;
															ol<<"Error at line "<<line_count<<": Type Mismatch"<<endl;
															ol<<endl;
															el<<"Error at line "<<line_count<<": Type Mismatch"<<endl;
															el<<endl;
															number_of_errors++;
															$$=new SymbolInfo($1->getName()+" = "+$3->getName(),"");
															ol<<$1->getName()<<" = "<<$3->getName()<<endl;
															ol<<endl;
														}

														else{
															$$=new SymbolInfo($1->getName()+" = "+$3->getName(),"");
															ol<<$1->getName()<<" = "<<$3->getName()<<endl;
															ol<<endl;
														}
														$$->Code+="; "+$1->getName()+" = "+$3->getName()+"\n";
														$$->Code+=$1->Code;
														$$->Code+=$3->Code;
														//ol<<$1->Code<<endl;
														//ol<<$3->Code<<endl;
														if(ary==true)
														{	
															ary=false;
															$$->Code+="MOV "+$1->varAssem+"[SI],"+$3->varAssem+"\n";
														}
														else {
															$$->Code+="MOV "+$1->varAssem+","+$3->varAssem+"\n";
														}
														
														//ol<<$$->Code<<endl;
														delete $1,$3;
													}		
	   ;
			
logic_expression : rel_expression 		{ ol<<"Line "<<line_count<<": logic_expression : rel_expression "<<endl;
										  ol<<endl;
											$$=new SymbolInfo($1->getName(),$1->getType());
											ol<<$1->getName()<<endl;
											ol<<endl;
											$$->varAssem=$1->varAssem;
											$$->Code=$1->Code;
											//ol<<$$->Code<<endl;
											delete $1;
										}
		 | rel_expression LOGICOP rel_expression 	{ ol<<"Line "<<line_count<<": logic_expression : rel_expression LOGICOP rel_expression "<<endl;
		 											  ol<<endl;
		 											  $$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"int");
													  ol<<$1->getName()<<$2->getName()<<$3->getName()<<endl; 
													  ol<<endl;
													  string t1=newTemp();
													  string l1=newLabel();
													  string l2=newLabel();
													  $$->Code+="; "+$1->getName()+$2->getName()+$3->getName()+"\n";
													  $$->Code+=$1->Code+"MOV AX , "+$1->varAssem+"\n";
													  $$->Code+="MOV "+t1+" , AX \n";

													  $$->Code+=$3->Code+"MOV AX , "+$3->varAssem+"\n";
													  
													  if($2->getName().compare("&&")==0)
													 {	
														$$->Code+="CMP "+t1+", 1 \n";
														$$->Code+="JL "+l1+"\n";
														$$->Code+="CMP AX,1 \n";
														$$->Code+="JL "+l1+"\n";
														$$->Code+="MOV AX,1 \n";
														$$->Code+="JMP "+l2+"\n";
														$$->Code+=l1+": \n";
														$$->Code+="MOV AX,0 \n";
														$$->Code+=l2+": \n";
														
													 }
													 else if($2->getName().compare("||")==0)
													 {
														$$->Code+="CMP "+t1+", 1 \n";
														$$->Code+="JGE "+l1+"\n";
														$$->Code+="CMP AX,1 \n";
														$$->Code+="JGE "+l1+"\n";
														$$->Code+="MOV AX,0 \n";
														$$->Code+="JMP "+l2+"\n";
														$$->Code+=l1+": \n";
														$$->Code+="MOV AX,1 \n";
														$$->Code+=l2+": \n";		
													 }
															
													$$->varAssem="AX";
													//ol<<$$->Code<<endl;
													delete $1,$2,$3;
													 }
		 ;
			
rel_expression	: simple_expression 		{ ol<<"Line "<<line_count<<": rel_expression	: simple_expression "<<endl;
											  ol<<endl;
												$$=new SymbolInfo($1->getName(),$1->getType());
												ol<<$1->getName()<<endl;
												ol<<endl;
												$$->varAssem=$1->varAssem;
												$$->Code=$1->Code;
												//ol<<$$->Code<<endl;
												delete $1;
											}
		| simple_expression RELOP simple_expression			{ ol<<"Line "<<line_count<<": rel_expression	: simple_expression RELOP simple_expression	 "<<endl;
															  ol<<endl;
																$$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"int");
																ol<<$1->getName()<<$2->getName()<<$3->getName()<<endl; 
																ol<<endl;
																string t1=newTemp();
																string l1=newLabel();
																string l2=newLabel();
																$$->Code+="; "+$1->getName()+$2->getName()+$3->getName()+"\n";
																$$->Code+="MOV CX , "+$1->varAssem+"\n";  //change
																$$->Code+=$1->Code+"MOV "+t1+" , CX \n";
																$$->Code+=$3->Code+"MOV AX , "+$3->varAssem+"\n";
																$$->Code+="CMP "+t1+", AX \n";
																if($2->getName().compare("<")==0)
																{	
																	$$->Code+="JL "+l1+"\n";
																}
																else if($2->getName().compare("<=")==0)
																{
																	$$->Code+="JLE "+l1+"\n";
																}
																else if($2->getName().compare(">")==0)
																{
																	$$->Code+="JG "+l1+"\n";
																}
																else if($2->getName().compare(">=")==0)
																{
																	$$->Code+="JGE "+l1+"\n";
																}
																else if($2->getName().compare("==")==0)
																{
																	$$->Code+="JE "+l1+"\n";
																}
																else if($2->getName().compare("!=")==0)
																{
																	$$->Code+="JNE "+l1+"\n";
																}
																$$->Code+="MOV AX, 0 \n";
																$$->Code+="JMP "+l2+"\n";
																$$->Code+=l1+": \n";
																$$->Code+="MOV AX, 1 \n";
																$$->Code+=l2+": \n";
																$$->varAssem="AX";
																//ol<<$$->Code<<endl;
																delete $1,$2,$3;
															}
		;
				
simple_expression : term 		{ ol<<"Line "<<line_count<<": simple_expression : term "<<endl;
								  ol<<endl;
									$$=new SymbolInfo($1->getName(),$1->getType());
									ol<<$$->getName()<<endl;
									ol<<endl;
									$$->varAssem=$1->varAssem;
									$$->Code=$1->Code;
									//ol<<$$->Code<<endl;
									//ol<<$1->Code<<endl;
									delete $1;
								}
		  | simple_expression ADDOP term 		{ ol<<"Line "<<line_count<<": simple_expression : simple_expression ADDOP term "<<endl;
		  										  ol<<endl;
													string to;
													if($1->getType().compare("")==0||$3->getType().compare("")==0)
													{
														//$$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"");
														to="";
														ol<<$1->getName()<<$2->getName()<<$3->getName()<<endl;
														ol<<endl;
													}
		  											else if($1->getType().compare($3->getType())!= 0 )	
													{	
														to="float";
														//$$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"float");
														ol<<$1->getName()<<$2->getName()<<$3->getName()<<endl;
														ol<<endl;
													}
													else{
														to=$1->getType();
														//$$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),$1->getType());
														ol<<$1->getName()<<$2->getName()<<$3->getName()<<endl;
														ol<<endl;
													}
													string t1=newTemp();
													$$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),to);
													$$->Code+="; "+$1->getName()+$2->getName()+$3->getName()+"\n";
													$$->Code+=$1->Code+"MOV "+t1+" , "+$1->varAssem+"\n";
													$$->Code+=$3->Code+"MOV AX , "+$3->varAssem+"\n";
													if($2->getName().compare("+")==0)
													{	

														$$->Code+="ADD AX, "+t1+"\n";

												
													}
													else if($2->getName().compare("-")==0)
													{
														$$->Code+="SUB AX, "+t1+"\n";
													}
													$$->varAssem="AX";
													//ol<<$$->Code<<endl;
		  											delete $1,$2,$3;
												}
		  ;
					
term :	unary_expression		{ ol<<"Line "<<line_count<<": term : unary_expression "<<endl;
								  ol<<endl;
									$$=new SymbolInfo($1->getName(),$1->getType());
									ol<<$$->getName()<<endl;
									ol<<endl;
									$$->varAssem=$1->varAssem;
									$$->Code=$1->Code;
									delete $1;
								}
     |  term MULOP unary_expression		{ ol<<"Line "<<line_count<<": term : term MULOP unary_expression "<<endl; 
	 									  ol<<endl;
										   string to;
	 										if($3->getType().compare("void")==0||$1->getType().compare("void")==0)
											 {	
												 
												 ol<<"Error at line "<<line_count<<": Void function used in expression"<<endl;
												 ol<<endl;
												 el<<"Error at line "<<line_count<<": Void function used in expression"<<endl;
												 el<<endl;
												 number_of_errors++;
												 //$$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"");
												 to="";
												 ol<<$1->getName()<<$2->getName()<<$3->getName()<<endl;
												 ol<<endl;
											 }
											else if($2->getName().compare("%")== 0)
											{	
												if($3->getName().compare("0")==0)
												{
													ol<<"Error at line "<<line_count<<": Modulus by Zero "<<endl;
													ol<<endl;
													el<<"Error at line "<<line_count<<": Modulus by Zero"<<endl;
													el<<endl;
													number_of_errors++;
													to="int";
													//$$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"int");
													ol<<$1->getName()<<$2->getName()<<$3->getName()<<endl;
													ol<<endl;
												}
												else if($1->getType().compare("int")!= 0 || $3->getType().compare("int")!= 0)
												{
													ol<<"Error at line "<<line_count<<": Non-Integer operand on modulus operator "<<endl;
													ol<<endl;
													el<<"Error at line "<<line_count<<": Non-Integer operand on modulus operator"<<endl;
													el<<endl;
													number_of_errors++;
													to="int";
													//$$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"int");
													ol<<$1->getName()<<$2->getName()<<$3->getName()<<endl;
													ol<<endl;
												}
											}
											else{
												if($1->getType().compare($3->getType())!= 0 )	
												{
													//$$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"float");
													to="float";
													ol<<$1->getName()<<$2->getName()<<$3->getName()<<endl;
													ol<<endl;
												}
												else{
													
													to=$1->getType();
													//$$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),$1->getType());
													ol<<$1->getName()<<$2->getName()<<$3->getName()<<endl;
													ol<<endl;
												}
											}
											$$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),to);
											string t1=newTemp();
											$$->Code="; "+$1->getName()+$2->getName()+$3->getName()+"\n";
											$$->Code+=$1->Code+"MOV "+t1+" , "+$1->varAssem+"\n";
											$$->Code+=$3->Code+"MOV AX , "+$3->varAssem+"\n";
											if($2->getName().compare("*")==0)
											{	

												$$->Code+="IMUL "+t1+"\n";

												
											}
											else if($2->getName().compare("/")==0)
											{
												$$->Code+="MOV BX,AX \n";
												$$->Code+="MOV AX, "+t1+"\n";
												$$->Code+="IDIV BX \n";
											}
											else if($2->getName().compare("%")==0)
											{
												$$->Code+="MOV BX,AX \n";
												$$->Code+="MOV AX, "+t1+"\n";
												$$->Code+="IDIV BX \n";
												$$->Code+="MOV AX,DX \n";
											}
											$$->varAssem="AX";
											//ol<<$$->Code<<endl;
											delete $1,$2,$3;
									}
     ;

unary_expression : ADDOP unary_expression  { ol<<"Line "<<line_count<<": unary_expression : ADDOP unary_expression"<<endl;
											 ol<<endl;
												$$=new SymbolInfo($1->getName()+$2->getName(),$2->getType());
												ol<<$1->getName()<<$2->getName()<<endl;
												ol<<endl;
												delete $1,$2;
												 }
		 | NOT unary_expression 	{ ol<<"Line "<<line_count<<": unary_expression : NOT unary_expression"<<endl;
		 							  ol<<endl;
		 							  $$=new SymbolInfo("!"+$2->getName(),$2->getType());
									  ol<<"!"<<$2->getName()<<endl;
									  ol<<endl;
									  delete $2;
							}
		 | factor 	{ ol<<"Line "<<line_count<<": unary_expression : factor"<<endl; 
		 			  ol<<endl;
		 			  $$=new SymbolInfo($1->getName(),$1->getType());
					  ol<<$1->getName()<<endl;
					  ol<<endl;
					  $$->varAssem=$1->varAssem;
					  $$->Code=$1->Code;
					  delete $1;
					}
		 ;
	
factor	: variable 		{ ol<<"Line "<<line_count<<": factor : variable "<<endl; 
						  ol<<endl;
						  $$=new SymbolInfo($1->getName(),$1->getType());
						  ol<<$1->getName()<<endl;
						  ol<<endl;
						  $$->Code=$1->Code;
						  $$->varAssem=$1->varAssem;
						  if(ary==true)
						  {
							  $$->Code+="MOV AX,"+$1->varAssem+"[SI] \n";
							  ary=false;
							  $$->varAssem="AX";
						  }
						  delete $1;
							}
	| ID LPAREN argument_list RPAREN		{ ol<<"Line "<<line_count<<": factor : ID LPAREN argument_list RPAREN"<<endl; 
											  ol<<endl;
												SymbolInfo *p= table->LookUpSymbol($1->getName());
												
												if(p==nullptr)
												{	
													ol<<"Error at line "<<line_count<<": Undeclared function "<<$1->getName()<<endl;
													ol<<endl;
													el<<"Error at line "<<line_count<<": Undeclared function "<<$1->getName()<<endl;
													el<<endl;
													number_of_errors++;
												}
												else
												{
													if(p->getNumberOfparameters()!=arguL.size())
													{
														ol<<"Error at line "<<line_count<<": Total number of arguments mismatch in function "<<$1->getName()<<endl;
														ol<<endl;
														el<<"Error at line "<<line_count<<": Total number of arguments mismatch in function "<<$1->getName()<<endl;
														el<<endl;
														number_of_errors++;
													}
													else
													{
														for(int i=0;i<arguL.size();i++)
														{	
															//push argul[i]
															//ol<<p->getParameterList()[i]<<endl;
															//ol<<arguL[i]<<endl;

															if(p->getParameterList()[i].compare(arguL[i]->getType())!=0)
															{
																ol<<"Error at line "<<line_count<<": "<<i+1<<"th argument mismatch in function "<<$1->getName()<<endl;
																ol<<endl;
																el<<"Error at line "<<line_count<<": "<<i+1<<"th argument mismatch in function "<<$1->getName()<<endl;
																el<<endl;
																number_of_errors++;
																break;
															}
														}
													}
												}
												
												if(p!=nullptr)
												{
													$$=new SymbolInfo($1->getName()+"("+$3->getName()+")",p->getReturnType());
												}
												else
												{
													$$=new SymbolInfo($1->getName()+"("+$3->getName()+")","");
												}
												for(int i=0;i<arguL.size();i++){
													$$->Code+="PUSH "+arguL[i]->varAssem+"\n";
												}
												arguL.clear();
												ol<<$1->getName()<<"("<<$3->getName()<<")"<<endl;
												ol<<endl;
												//string t1=newTemp();
												//$$->Code+="MOV AX,"+t1+""
												$$->varAssem="BX"; 
												
												$$->Code+="CALL "+$1->getName()+"\n";
												//fun =true;
												delete $1,$3;
											}
	| LPAREN expression RPAREN		{ ol<<"Line "<<line_count<<": factor : LPAREN expression RPAREN"<<endl; 
										ol<<endl;
										$$=new SymbolInfo("("+$2->getName()+")",$2->getType());
										ol<<"("<<$2->getName()<<")"<<endl;
										ol<<endl;
										$$->Code+=$2->Code;
										$$->varAssem=$2->varAssem;
										delete $2;
										}
	| CONST_INT 		{ ol<<"Line "<<line_count<<": factor : CONST_INT "<<endl; 
							ol<<endl; 
							$$=new SymbolInfo($1->getName(),"int");
							ol<<$1->getName()<<endl;
							ol<<endl;
							$$->varAssem=$1->getName();
							delete $1;
							}
	| CONST_FLOAT		{ ol<<"Line "<<line_count<<": factor : CONST_FLOAT"<<endl; 
							ol<<endl;
							$$=new SymbolInfo($1->getName(),"float");
							ol<<$1->getName()<<endl;
							ol<<endl;
							$$->varAssem=$1->getName();
							delete $1;
							}
	| variable INCOP 		{ ol<<"Line "<<line_count<<": factor : variable INCOP "<<endl; //chamged
							  ol<<endl;
								$$=new SymbolInfo($1->getName()+" ++ ","");
								ol<<$1->getName()<<" ++ "<<endl;
								ol<<endl;
								$$->Code=$1->Code;
						  		$$->varAssem=$1->varAssem;
								$$->Code+="ADD "+$1->varAssem+" , 1 \n";
								delete $1;
							}
	| variable DECOP		{ ol<<"Line "<<line_count<<": factor : variable DECOP"<<endl; //chamged
								ol<<endl;
								$$=new SymbolInfo($1->getName()+" -- ","");
								ol<<$1->getName()<<" -- "<<endl;
								ol<<endl;
								$$->Code=$1->Code;
						  		$$->varAssem=$1->varAssem;
								$$->Code+="SUB "+$1->varAssem+" , 1 \n";
								$$->Code+="; "+$1->varAssem+" is saved in BX \n";
								$$->Code+="MOV BX, "+$1->varAssem+"\n";
								delete $1;
								}
	;
	
argument_list : arguments		{ ol<<"Line "<<line_count<<": argument_list : arguments"<<endl;
								ol<<endl;
								$$=new SymbolInfo($1->getName(),$1->getType());
								ol<<$1->getName()<<endl; 
								ol<<endl;
								delete $1;
								}
			  |					{ ol<<"Line "<<line_count<<": argument_list : arguments"<<endl;
			  					$$=new SymbolInfo("","");
								//ol<<$1->getName()<<endl;
								}
			  ;
	
arguments : arguments COMMA logic_expression		{ ol<<"Line "<<line_count<<": arguments : arguments COMMA logic_expression"<<endl;
														ol<<endl;
														$$=new SymbolInfo($1->getName()+","+$3->getName(),"");
														arguL.push_back($3);
														ol<<$1->getName()<<","<<$3->getName()<<endl;
														ol<<endl;
														//delete $1,$3;
													 }
	      | logic_expression			{ ol<<"Line "<<line_count<<": arguments : logic_expression"<<endl;
		  									ol<<endl;
		  									$$=new SymbolInfo($1->getName(),"");
											  arguL.push_back($1);
											ol<<$1->getName()<<endl;
											ol<<endl;
											//delete $1;
										}
	      ;
 

%%

int main(int argc,char *argv[]){
	/*yydebug=1;*/
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
	cl.open("Code.asm");
	ol.open("log.txt");
	el.open("error.txt");

	yyin= fin;
	yyparse();
	fclose(yyin);
	
	// table->printAllScopeTable(ol,7);
	ol<<endl;
	ol<<"Total lines: " <<line_count<<endl;
	ol<<"Total errors: "<<number_of_errors<<endl;
	ol.close();
	cl.close();
	return 0;
}

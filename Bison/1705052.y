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
ofstream ol;
ofstream el;
vector<SymbolInfo*> array;
vector<string> arguL;
vector<string> id;
char newl='\n';
//int yydebug;
//int yyparse(void);
//int yylex(void);
//double var[26];

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
		//write your code in this block in all the similar blocks below
	}
	;

program : program unit 		{ol<<"Line "<<line_count<<": program : program unit "<<endl;
							ol<<endl;
							$$=new SymbolInfo($1->getName()+"\n"+$2->getName(),"");
							ol<<$1->getName()<<endl;
							ol<<$2->getName()<<endl;
							ol<<endl; ol<<endl; 
							delete $1,$2;
							} 
	| unit		{ol<<"Line "<<line_count<<": program : unit "<<endl;
				ol<<endl;
				$$=$1;
				ol<<$1->getName()<<endl;
				ol<<endl;
				}
	;
	
unit : var_declaration	{ol<<"Line "<<line_count<<": unit : var_declaration "<<endl;
						ol<<endl;
						$$=$1;
						ol<<$$->getName()<<endl;
						ol<<endl;
						} 
     | func_declaration		{ol<<"Line "<<line_count<<": unit : func_declaration "<<endl; 
	 						ol<<endl;
	 						$$=$1;
							 ol<<$$->getName()<<endl;
							 ol<<endl;
							 } 
     | func_definition		{ol<<"Line "<<line_count<<": unit : func_definition "<<endl; 
	 						ol<<endl;
	 						$$=$1;
							 ol<<$$->getName()<<endl;
							 ol<<endl;
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
								ol<<$1->getName()<<" "<<$2->getName()<<"("<<$4->getName()<<")"<<$7->getName()<<endl;
								ol<<endl;
								$$=new SymbolInfo($1->getName()+" "+$2->getName()+"("+$4->getName()+")"+$7->getName(),"");
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
		array.clear();
	}
	statements RCURL		{ ol<<"Line "<<line_count<<": compound_statement : LCURL statements RCURL  "<<endl;
							  ol<<endl;
							  $$=new SymbolInfo("{"+$3->getName()+"\n"+"}","");
							  ol<<"{"<<endl;
							  ol<<endl;
							  ol<<$3->getName()<<endl; ol<<endl;
							  ol<<"}"<<endl; 
							  table->printAllScopeTable(ol,30);
							  table->exit();
							  ol<<endl;
							  delete $3;
							}
 		    | LCURL{
				 table->enterScope(30); 
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
				array.clear();
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
								delete $1;
								 }
	   | statements statement		{ ol<<"Line "<<line_count<<": statements : statements statement"<<endl;
	   								  ol<<endl;
	   									$$=new SymbolInfo($1->getName()+$2->getName()+newl,"");
										ol<<$1->getName()<<endl; ol<<$2->getName()<<endl;
										ol<<endl;
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
									delete $1;
									   }
	  | compound_statement		{ ol<<"Line "<<line_count<<": statement : compound_statement"<<endl;
	  							  ol<<endl;
	  							  $$=new SymbolInfo($1->getName(),"");
								  ol<<$1->getName()<<endl;
								  ol<<endl;
								  delete $1;
	 							 }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement	{ ol<<"Line "<<line_count<<": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement"<<endl;
	  																						  ol<<endl;
	  																						  $$=new SymbolInfo("for("+$3->getName()+$4->getName()+$5->getName()+")"+$7->getName(),"");		
																							  ol<<"for"<<"("<<$3->getName()<<$4->getName()<<$5->getName()<<")"<<$7->getName()<<endl;	
																							  ol<<endl;
																							  delete $3,$4,$5,$7;
																							}
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE 		{ ol<<"Line "<<line_count<<": statement : IF LPAREN expression RPAREN statement"<<endl;
	  																		  ol<<endl;
	  																		  $$=new SymbolInfo("if("+$3->getName()+")"+$5->getName(),"");
																			  ol<<"if"<<"("<<$3->getName()<<")"<<$5->getName()<<endl;
																			  ol<<endl;
																			  delete $3,$5;
														  					 }
	  | IF LPAREN expression RPAREN statement ELSE statement		{ ol<<"Line "<<line_count<<": statement : IF LPAREN expression RPAREN statement ELSE statement"<<endl;
	  																  ol<<endl;
	  																  $$=new SymbolInfo("if("+$3->getName()+")"+$5->getName()+"else"+$7->getName(),"");
																	  ol<<"if"<<"("<<$3->getName()<<")"<<$5->getName()<<"else"<<$7->getName()<<endl;
																	  ol<<endl;
																	  delete $3,$5,$7;
																	 }
	  | WHILE LPAREN expression RPAREN statement		{ ol<<"Line "<<line_count<<": statement : WHILE LPAREN expression RPAREN statement"<<endl; 
	  													  ol<<endl;
	  													  $$=new SymbolInfo("while("+$3->getName()+")"+$5->getName(),"");
														  ol<<"while" << "("<<$3->getName()<<")"<<$5->getName()<<endl;
														  ol<<endl;
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
	  													$$=new SymbolInfo("printf("+$3->getName()+")"+";","");
														ol<<"printf"<<"("<<$3->getName()<<")"<<";"<<endl;
														ol<<endl;
														delete $3;
														   }
	  | RETURN expression SEMICOLON			{ ol<<"Line "<<line_count<<": statement : RETURN expression SEMICOLON "<<endl;
	  										  ol<<endl;
	  										  $$=new SymbolInfo("return "+$2->getName()+";","");
											  ol<<"return "<<$2->getName()<<";"<<endl;
											  ol<<endl;
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
											delete $1,$3;
										}	
	 ;
	 
 expression : logic_expression			{ ol<<"Line "<<line_count<<": expression : logic_expression "<<endl; 
										  ol<<endl;
 											$$=new SymbolInfo($1->getName(),$1->getType());
											ol<<$1->getName()<<endl;
											ol<<endl;
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
														delete $1,$3;
													}		
	   ;
			
logic_expression : rel_expression 		{ ol<<"Line "<<line_count<<": logic_expression : rel_expression "<<endl;
										  ol<<endl;
											$$=new SymbolInfo($1->getName(),$1->getType());
											ol<<$1->getName()<<endl;
											ol<<endl;
											delete $1;
										}
		 | rel_expression LOGICOP rel_expression 	{ ol<<"Line "<<line_count<<": logic_expression : rel_expression LOGICOP rel_expression "<<endl;
		 											  ol<<endl;
		 											  $$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"int");
													  ol<<$1->getName()<<$2->getName()<<$3->getName()<<endl; 
													  ol<<endl;
													  delete $1,$2,$3;
													 }
		 ;
			
rel_expression	: simple_expression 		{ ol<<"Line "<<line_count<<": rel_expression	: simple_expression "<<endl;
											  ol<<endl;
												$$=new SymbolInfo($1->getName(),$1->getType());
												ol<<$1->getName()<<endl;
												ol<<endl;
												delete $1;
											}
		| simple_expression RELOP simple_expression			{ ol<<"Line "<<line_count<<": rel_expression	: simple_expression RELOP simple_expression	 "<<endl;
															  ol<<endl;
																$$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"int");
																ol<<$1->getName()<<$2->getName()<<$3->getName()<<endl; 
																ol<<endl;
																delete $1,$2,$3;
																 }
		;
				
simple_expression : term 		{ ol<<"Line "<<line_count<<": simple_expression : term "<<endl;
								  ol<<endl;
									$$=new SymbolInfo($1->getName(),$1->getType());
									ol<<$$->getName()<<endl;
									ol<<endl;
									delete $1;
								}
		  | simple_expression ADDOP term 		{ ol<<"Line "<<line_count<<": simple_expression : simple_expression ADDOP term "<<endl;
		  										  ol<<endl;
													if($1->getType().compare("")==0||$3->getType().compare("")==0)
													{
														$$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"");
														ol<<$1->getName()<<$2->getName()<<$3->getName()<<endl;
														ol<<endl;
													}
		  											else if($1->getType().compare($3->getType())!= 0 )	
													{
														$$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"float");
														ol<<$1->getName()<<$2->getName()<<$3->getName()<<endl;
														ol<<endl;
													}
													else{
														$$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),$1->getType());
														ol<<$1->getName()<<$2->getName()<<$3->getName()<<endl;
														ol<<endl;
													}
		  											delete $1,$2,$3;
												}
		  ;
					
term :	unary_expression		{ ol<<"Line "<<line_count<<": term : unary_expression "<<endl;
								  ol<<endl;
									$$=new SymbolInfo($1->getName(),$1->getType());
									ol<<$$->getName()<<endl;
									ol<<endl;
									delete $1;
								}
     |  term MULOP unary_expression		{ ol<<"Line "<<line_count<<": term : term MULOP unary_expression "<<endl; 
	 									  ol<<endl;
	 										if($3->getType().compare("void")==0||$1->getType().compare("void")==0)
											 {	
												 
												 ol<<"Error at line "<<line_count<<": Void function used in expression"<<endl;
												 ol<<endl;
												 el<<"Error at line "<<line_count<<": Void function used in expression"<<endl;
												 el<<endl;
												 number_of_errors++;
												 $$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"");
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
													$$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"int");
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
													$$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"int");
													ol<<$1->getName()<<$2->getName()<<$3->getName()<<endl;
													ol<<endl;
												}
											}
											else{
												if($1->getType().compare($3->getType())!= 0 )	
												{
													$$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),"float");
													ol<<$1->getName()<<$2->getName()<<$3->getName()<<endl;
													ol<<endl;
												}
												else{
													$$=new SymbolInfo($1->getName()+$2->getName()+$3->getName(),$1->getType());
													ol<<$1->getName()<<$2->getName()<<$3->getName()<<endl;
													ol<<endl;
												}
											}
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
					  delete $1;
					}
		 ;
	
factor	: variable 		{ ol<<"Line "<<line_count<<": factor : variable "<<endl; 
						  ol<<endl;
						  $$=new SymbolInfo($1->getName(),$1->getType());
						  ol<<$1->getName()<<endl;
						  ol<<endl;
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
															//ol<<p->getParameterList()[i]<<endl;
															//ol<<arguL[i]<<endl;

															if(p->getParameterList()[i].compare(arguL[i])!=0)
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
												arguL.clear();
												if(p!=nullptr)
												{
													$$=new SymbolInfo($1->getName()+"("+$3->getName()+")",p->getReturnType());
												}
												else
												{
													$$=new SymbolInfo($1->getName()+"("+$3->getName()+")","");
												}
												ol<<$1->getName()<<"("<<$3->getName()<<")"<<endl;
												ol<<endl;
												delete $1,$3;
											}
	| LPAREN expression RPAREN		{ ol<<"Line "<<line_count<<": factor : LPAREN expression RPAREN"<<endl; 
										ol<<endl;
										$$=new SymbolInfo("("+$2->getName()+")",$2->getType());
										ol<<"("<<$2->getName()<<")"<<endl;
										ol<<endl;
										delete $2;
										}
	| CONST_INT 		{ ol<<"Line "<<line_count<<": factor : CONST_INT "<<endl; 
							ol<<endl; 
							$$=new SymbolInfo($1->getName(),"int");
							ol<<$1->getName()<<endl;
							ol<<endl;
							delete $1;
							}
	| CONST_FLOAT		{ ol<<"Line "<<line_count<<": factor : CONST_FLOAT"<<endl; 
							ol<<endl;
							$$=new SymbolInfo($1->getName(),"float");
							ol<<$1->getName()<<endl;
							ol<<endl;
							delete $1;
							}
	| variable INCOP 		{ ol<<"Line "<<line_count<<": factor : variable INCOP "<<endl; 
							  ol<<endl;
								$$=new SymbolInfo($1->getName()+" ++ ","");
								ol<<$1->getName()<<" ++ "<<endl;
								ol<<endl;
								delete $1;
							}
	| variable DECOP		{ ol<<"Line "<<line_count<<": factor : variable DECOP"<<endl; 
								ol<<endl;
								$$=new SymbolInfo($1->getName()+" -- ","");
								ol<<$1->getName()<<" -- "<<endl;
								ol<<endl;
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
														arguL.push_back($3->getType());
														ol<<$1->getName()<<","<<$3->getName()<<endl;
														ol<<endl;
														delete $1,$3;
													 }
	      | logic_expression			{ ol<<"Line "<<line_count<<": arguments : logic_expression"<<endl;
		  									ol<<endl;
		  									$$=new SymbolInfo($1->getName(),"");
											  arguL.push_back($1->getType());
											ol<<$1->getName()<<endl;
											ol<<endl;
											delete $1;
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
	return 0;
}

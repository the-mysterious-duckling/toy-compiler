%{
#include "symbol_info.h"
#include "symbol_table.h"
#define YYSTYPE symbol_info*

#include <vector>
#include <utility>
#include <sstream>
#include <algorithm>
#include <iostream>
#include <cstdio>

using namespace std;

extern int yylex(void);
extern int yyparse(void);
void yyerror(const char *s);

extern FILE *yyin;
ofstream outlog;
int lines = 1;

const int BUCKET_SIZE = 10;                 
symbol_table symtab(BUCKET_SIZE);

// Collect params first; insert them when the function body scope opens
vector<pair<string,string>> pending_params; // {type, name}
bool inserting_func_params = false;

%}

%token IF ELSE FOR DO INT FLOAT VOID SWITCH DEFAULT GOTO WHILE BREAK CHAR DOUBLE RETURN CASE CONTINUE PRINTF
%token CONST_INT CONST_FLOAT
%token ADDOP MULOP INCOP RELOP ASSIGNOP LOGICOP NOT
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA COLON SEMICOLON
%token ID
%nonassoc UNARY
%nonassoc ELSE

%%

start : program 
    {
        outlog<<"At line no: "<<lines<<" start : program "<<endl<<endl;
        outlog<<"Symbol Table"<<endl<<endl;  // keep this header for log3
        outlog<<"################################"<<endl<<endl;
        symtab.print_all_scopes(outlog);
        outlog<<"################################"<<endl<<endl;
        outlog<<"Total lines: "<<lines<<endl;
    }
    ;

program : program unit 
    {
        outlog<<"At line no: "<<lines<<" program : program unit "<<endl<<endl;
        outlog<<$1->getname()<<"\n"<<$2->getname()<<endl<<endl;
        $$ = new symbol_info($1->getname()+"\n"+$2->getname(),"program");
    }
    | unit 
    {
        outlog<<"At line no: "<<lines<<" program : unit "<<endl<<endl;
        outlog<<$1->getname()<<endl<<endl;
        $$ = $1;
    }
    ;

unit : var_declaration 
    {
        outlog<<"At line no: "<<lines<<" unit : var_declaration "<<endl<<endl;
        outlog<<$1->getname()<<endl<<endl;
        $$ = $1;
    }
    | func_definition 
    {
        outlog<<"At line no: "<<lines<<" unit : func_definition "<<endl<<endl;
        outlog<<$1->getname()<<endl<<endl;
        $$ = $1;
    }
    ;

func_definition
  : type_specifier ID LPAREN parameter_list RPAREN
    {
      // Insert the FUNCTION symbol in the GLOBAL scope BEFORE parsing body
      symbol_info *func = new symbol_info($2->getname(), "ID");
      func->set_id_type("FUNC");
      func->set_return_type($1->getname());

      func->set_param_count((int)pending_params.size());
      string details;
      for (size_t i=0;i<pending_params.size();++i) {
        if (i) details += ", ";
        details += pending_params[i].first + " " + pending_params[i].second;
      }
      func->set_param_details(details);

      symtab.insert(func);           // ensures Scope #1 shows func in subsequent dumps
      inserting_func_params = true;  // body will place params into the new scope
    }
    compound_statement 
    {   
        outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement "<<endl<<endl;
        outlog<<$1->getname()<<" "<<$2->getname()<<"("<<$4->getname()<<")\n"<<$7->getname()<<endl<<endl;

        $$ = new symbol_info($1->getname()+" "+$2->getname()+"("+$4->getname()+")\n"+$7->getname(),"func_def");

        pending_params.clear();
        inserting_func_params = false;
    }
  | type_specifier ID LPAREN RPAREN
    {
      // No params, but still insert function in global scope BEFORE body
      symbol_info *func = new symbol_info($2->getname(), "ID");
      func->set_id_type("FUNC");
      func->set_return_type($1->getname());
      func->set_param_count(0);
      func->set_param_details("");
      symtab.insert(func);

      inserting_func_params = true; // consistent flow (no params to insert later)
    }
    compound_statement 
    {
        outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN RPAREN compound_statement "<<endl<<endl;
        outlog<<$1->getname()<<" "<<$2->getname()<<"()\n"<<$6->getname()<<endl<<endl;  

        $$ = new symbol_info($1->getname()+" "+$2->getname()+"()\n"+$6->getname(),"func_def");    

        pending_params.clear();
        inserting_func_params = false;
    }
  ;

parameter_list 
    : parameter_list COMMA type_specifier ID 
    {
        outlog<<"At line no: "<<lines<<" parameter_list : parameter_list COMMA type_specifier ID "<<endl<<endl;
        outlog<<$1->getname()<<","<<$3->getname()<<" "<<$4->getname()<<endl<<endl;

        // collect only; we insert into function scope on '{'
        pending_params.push_back({$3->getname(), $4->getname()});

        $$ = new symbol_info($1->getname()+","+$3->getname()+" "+$4->getname(),"param_list");
    }
    | parameter_list COMMA type_specifier 
    {
        outlog<<"At line no: "<<lines<<" parameter_list : parameter_list COMMA type_specifier "<<endl<<endl;
        outlog<<$1->getname()<<","<<$3->getname()<<endl<<endl;
        $$ = new symbol_info($1->getname()+","+$3->getname(),"param_list");
    }
    | type_specifier ID 
    {
        outlog<<"At line no: "<<lines<<" parameter_list : type_specifier ID "<<endl<<endl;
        outlog<<$1->getname()<<" "<<$2->getname()<<endl<<endl;

        // collect only; we insert into function scope on '{'
        pending_params.push_back({$1->getname(), $2->getname()});

        $$ = new symbol_info($1->getname()+" "+$2->getname(),"param_list");
    }
    | type_specifier 
    {
        outlog<<"At line no: "<<lines<<" parameter_list : type_specifier "<<endl<<endl;
        outlog<<$1->getname()<<endl<<endl;
        $$ = new symbol_info($1->getname(),"param_list");
    }
    ;

compound_statement 
    : LCURL {
        symtab.enter_scope();
        outlog<<"New ScopeTable with ID "<<symtab.get_current_scope_id()<<" created"<<endl<<endl;

        // If we are entering a function body, insert pending params NOW
        if (inserting_func_params) {
            for (auto &pr : pending_params) {
                symbol_info *param = new symbol_info(pr.second,"ID");
                param->set_id_type("VAR");
                param->set_data_type(pr.first);
                symtab.insert(param);
            }
            // keep pending_params intact until func_definition finishes printing; it clears later
        }
    } statements RCURL 
    {
        outlog<<"At line no: "<<lines<<" compound_statement : LCURL statements RCURL "<<endl<<endl;
        outlog<<"{\n"<<$3->getname()<<"\n}"<<endl<<endl;

        outlog<<"################################"<<endl<<endl;
        symtab.print_all_scopes(outlog);
        outlog<<"################################"<<endl<<endl;

        int removed_id = symtab.get_current_scope_id();
        symtab.exit_scope();
        outlog<<"Scopetable with ID "<<removed_id<<" removed"<<endl<<endl;

        $$ = new symbol_info("{\n"+$3->getname()+"\n}","compound_stmt");
    }
    | LCURL {
        symtab.enter_scope();
        outlog<<"New ScopeTable with ID "<<symtab.get_current_scope_id()<<" created"<<endl<<endl;

        if (inserting_func_params) {
            for (auto &pr : pending_params) {
                symbol_info *param = new symbol_info(pr.second,"ID");
                param->set_id_type("VAR");
                param->set_data_type(pr.first);
                symtab.insert(param);
            }
        }
    } RCURL 
    {
        outlog<<"At line no: "<<lines<<" compound_statement : LCURL RCURL "<<endl<<endl;
        outlog<<"{ }"<<endl<<endl;

        outlog<<"################################"<<endl<<endl;
        symtab.print_all_scopes(outlog);
        outlog<<"################################"<<endl<<endl;

        int removed_id = symtab.get_current_scope_id();
        symtab.exit_scope();
        outlog<<"Scopetable with ID "<<removed_id<<" removed"<<endl<<endl;

        $$ = new symbol_info("{ }","compound_stmt");
    }
    ;

var_declaration : type_specifier declaration_list SEMICOLON 
    {
        outlog<<"At line no: "<<lines<<" var_declaration : type_specifier declaration_list SEMICOLON "<<endl<<endl;
        outlog<<$1->getname()<<" "<<$2->getname()<<";"<<endl<<endl;

        // Parse declaration list and insert variables
        stringstream ss($2->getname());
        string item;
        while(getline(ss, item, ',')) {
            // Remove spaces
            item.erase(remove(item.begin(), item.end(), ' '), item.end());
            
            // Check if it's an array
            size_t bracket_pos = item.find('[');
            if(bracket_pos != string::npos) {
                string varname = item.substr(0, bracket_pos);
                string size_str = item.substr(bracket_pos+1, item.find(']')-bracket_pos-1);
                
                symbol_info *arr = new symbol_info(varname, "ID");
                arr->set_id_type("ARRAY");
                arr->set_data_type($1->getname());
                arr->set_array_size(atoi(size_str.c_str()));
                symtab.insert(arr);
            } else {
                symbol_info *var = new symbol_info(item, "ID");
                var->set_id_type("VAR");
                var->set_data_type($1->getname());
                symtab.insert(var);
            }
        }
        
        $$ = new symbol_info($1->getname()+" "+$2->getname()+";","var_decl");
    }
    ;

type_specifier : INT 
    {
        outlog<<"At line no: "<<lines<<" type_specifier : INT "<<endl<<endl;
        outlog<<"int"<<endl<<endl;
        $$ = new symbol_info("int","type");
    }
    | FLOAT 
    {
        outlog<<"At line no: "<<lines<<" type_specifier : FLOAT "<<endl<<endl;
        outlog<<"float"<<endl<<endl;
        $$ = new symbol_info("float","type");
    }
    | VOID 
    {
        outlog<<"At line no: "<<lines<<" type_specifier : VOID "<<endl<<endl;
        outlog<<"void"<<endl<<endl;
        $$ = new symbol_info("void","type");
    }
    ;

declaration_list 
    : declaration_list COMMA ID 
    {
        outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID "<<endl<<endl;
        outlog<<$1->getname()<<","<<$3->getname()<<endl<<endl;
        $$ = new symbol_info($1->getname()+","+$3->getname(),"decl_list");
    }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD 
    {
        outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
        outlog<<$1->getname()<<","<<$3->getname()<<"["<<$5->getname()<<"]"<<endl<<endl;
        $$ = new symbol_info($1->getname()+","+$3->getname()+"["+$5->getname()+"]","decl_list");
    }
    | ID 
    {
        outlog<<"At line no: "<<lines<<" declaration_list : ID "<<endl<<endl;
        outlog<<$1->getname()<<endl<<endl;
        $$ = new symbol_info($1->getname(),"decl_list");
    }
    | ID LTHIRD CONST_INT RTHIRD 
    {
        outlog<<"At line no: "<<lines<<" declaration_list : ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
        outlog<<$1->getname()<<"["<<$3->getname()<<"]"<<endl<<endl;
        $$ = new symbol_info($1->getname()+"["+$3->getname()+"]","decl_list");
    }
    ;

statements 
    : statement 
    {
        outlog<<"At line no: "<<lines<<" statements : statement "<<endl<<endl;
        outlog<<$1->getname()<<endl<<endl;
        $$ = $1;
    }
    | statements statement 
    {
        outlog<<"At line no: "<<lines<<" statements : statements statement "<<endl<<endl;
        outlog<<$1->getname()<<"\n"<<$2->getname()<<endl<<endl;
        $$ = new symbol_info($1->getname()+"\n"+$2->getname(),"stmnts");
    }
    ;

statement 
    : var_declaration { outlog<<"At line no: "<<lines<<" statement : var_declaration "<<endl<<endl; outlog<<$1->getname()<<endl<<endl; $$ = $1; }
    | expression_statement { outlog<<"At line no: "<<lines<<" statement : expression_statement "<<endl<<endl; outlog<<$1->getname()<<endl<<endl; $$ = $1; }
    | compound_statement { outlog<<"At line no: "<<lines<<" statement : compound_statement "<<endl<<endl; outlog<<$1->getname()<<endl<<endl; $$ = $1; }
    | FOR LPAREN expression_statement expression_statement expression RPAREN statement 
      { outlog<<"At line no: "<<lines<<" statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<<endl<<endl;
        outlog<<"for("<<$3->getname()<<$4->getname()<<$5->getname()<<")\n"<<$7->getname()<<endl<<endl;
        $$ = new symbol_info("for("+$3->getname()+$4->getname()+$5->getname()+")\n"+$7->getname(),"stmnt"); }
    | IF LPAREN expression RPAREN statement ELSE statement 
      { outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement ELSE statement "<<endl<<endl;
        outlog<<"if("<<$3->getname()<<")\n"<<$5->getname()<<"\nelse\n"<<$7->getname()<<endl<<endl;
        $$ = new symbol_info("if("+$3->getname()+")\n"+$5->getname()+"\nelse\n"+$7->getname(),"stmnt"); }
    | WHILE LPAREN expression RPAREN statement 
      { outlog<<"At line no: "<<lines<<" statement : WHILE LPAREN expression RPAREN statement "<<endl<<endl;
        outlog<<"while("<<$3->getname()<<")\n"<<$5->getname()<<endl<<endl;
        $$ = new symbol_info("while("+$3->getname()+")\n"+$5->getname(),"stmnt"); }
    | PRINTF LPAREN ID RPAREN SEMICOLON 
      { outlog<<"At line no: "<<lines<<" statement : PRINTF LPAREN ID RPAREN SEMICOLON "<<endl<<endl;
        outlog<<"printf("<<$3->getname()<<");"<<endl<<endl;
        $$ = new symbol_info("printf("+$3->getname()+");","stmnt"); }
    | RETURN expression SEMICOLON 
      { outlog<<"At line no: "<<lines<<" statement : RETURN expression SEMICOLON "<<endl<<endl;
        outlog<<"return "<<$2->getname()<<";"<<endl<<endl;
        $$ = new symbol_info("return "+$2->getname()+";","stmnt"); }
    | IF LPAREN expression RPAREN statement %prec UNARY
      { outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement "<<endl<<endl;
        outlog<<"if("<<$3->getname()<<")\n"<<$5->getname()<<endl<<endl;
        $$ = new symbol_info("if("+$3->getname()+")\n"+$5->getname(),"stmnt"); }
    ;

expression_statement 
    : SEMICOLON 
    {
        outlog<<"At line no: "<<lines<<" expression_statement : SEMICOLON "<<endl<<endl;
        outlog<<";"<<endl<<endl;
        $$ = new symbol_info(";","expr_stmnt");
    }
    | expression SEMICOLON 
    {
        outlog<<"At line no: "<<lines<<" expression_statement : expression SEMICOLON "<<endl<<endl;
        outlog<<$1->getname()<<";"<<endl<<endl;
        $$ = new symbol_info($1->getname()+";","expr_stmnt");
    }
    ;

variable 
    : ID 
    {
        outlog<<"At line no: "<<lines<<" variable : ID "<<endl<<endl;
        outlog<<$1->getname()<<endl<<endl;
        $$ = $1;
    }
    | ID LTHIRD expression RTHIRD 
    {
        outlog<<"At line no: "<<lines<<" variable : ID LTHIRD expression RTHIRD "<<endl<<endl;
        outlog<<$1->getname()<<"["<<$3->getname()<<"]"<<endl<<endl;
        $$ = new symbol_info($1->getname()+"["+$3->getname()+"]","var");
    }
    ;

expression 
    : logic_expression 
    {
        outlog<<"At line no: "<<lines<<" expression : logic_expression "<<endl<<endl;
        outlog<<$1->getname()<<endl<<endl;
        $$ = $1;
    }
    | variable ASSIGNOP logic_expression 
    {
        outlog<<"At line no: "<<lines<<" expression : variable ASSIGNOP logic_expression "<<endl<<endl;
        outlog<<$1->getname()<<"="<<$3->getname()<<endl<<endl;
        $$ = new symbol_info($1->getname()+"="+$3->getname(),"expr");
    }
    ;

logic_expression 
    : rel_expression 
    {
        outlog<<"At line no: "<<lines<<" logic_expression : rel_expression "<<endl<<endl;
        outlog<<$1->getname()<<endl<<endl;
        $$ = $1;
    }
    | rel_expression LOGICOP rel_expression 
    {
        outlog<<"At line no: "<<lines<<" logic_expression : rel_expression LOGICOP rel_expression "<<endl<<endl;
        outlog<<$1->getname()<<" "<<$2->getname()<<" "<<$3->getname()<<endl<<endl;
        $$ = new symbol_info($1->getname()+" "+$2->getname()+" "+$3->getname(),"logic_expr");
    }
    ;

rel_expression 
    : simple_expression 
    {
        outlog<<"At line no: "<<lines<<" rel_expression : simple_expression "<<endl<<endl;
        outlog<<$1->getname()<<endl<<endl;
        $$ = $1;
    }
    | simple_expression RELOP simple_expression 
    {
        outlog<<"At line no: "<<lines<<" rel_expression : simple_expression RELOP simple_expression "<<endl<<endl;
        outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;
        $$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"rel_expr");
    }
    ;

simple_expression 
    : term 
    {
        outlog<<"At line no: "<<lines<<" simple_expression : term "<<endl<<endl;
        outlog<<$1->getname()<<endl<<endl;
        $$ = $1;
    }
    | simple_expression ADDOP term 
    {
        outlog<<"At line no: "<<lines<<" simple_expression : simple_expression ADDOP term "<<endl<<endl;
        outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;
        $$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"simple_expr");
    }
    ;

term 
    : unary_expression 
    {
        outlog<<"At line no: "<<lines<<" term : unary_expression "<<endl<<endl;
        outlog<<$1->getname()<<endl<<endl;
        $$ = $1;
    }
    | term MULOP unary_expression 
    {
        outlog<<"At line no: "<<lines<<" term : term MULOP unary_expression "<<endl<<endl;
        outlog<<$1->getname()<<" "<<$2->getname()<<" "<<$3->getname()<<endl<<endl;
        $$ = new symbol_info($1->getname()+" "+$2->getname()+" "+$3->getname(),"term");
    }
    ;

unary_expression 
    : ADDOP unary_expression 
    {
        outlog<<"At line no: "<<lines<<" unary_expression : ADDOP unary_expression "<<endl<<endl;
        outlog<<$1->getname()<<$2->getname()<<endl<<endl;
        $$ = new symbol_info($1->getname()+$2->getname(),"unary_expr");
    }
    | NOT unary_expression 
    {
        outlog<<"At line no: "<<lines<<" unary_expression : NOT unary_expression "<<endl<<endl;
        outlog<<"!"<<$2->getname()<<endl<<endl;
        $$ = new symbol_info("!"+$2->getname(),"unary_expr");
    }
    | factor 
    {
        outlog<<"At line no: "<<lines<<" unary_expression : factor "<<endl<<endl;
        outlog<<$1->getname()<<endl<<endl;
        $$ = $1;
    }
    ;

factor 
    : variable 
    {
        outlog<<"At line no: "<<lines<<" factor : variable "<<endl<<endl;
        outlog<<$1->getname()<<endl<<endl;
        $$ = $1;
    }
    | ID LPAREN argument_list RPAREN 
    {
        outlog<<"At line no: "<<lines<<" factor : ID LPAREN argument_list RPAREN "<<endl<<endl;
        outlog<<$1->getname()<<"("<<$3->getname()<<")"<<endl<<endl;
        $$ = new symbol_info($1->getname()+"("+$3->getname()+")","factor");
    }
    | LPAREN expression RPAREN 
    {
        outlog<<"At line no: "<<lines<<" factor : LPAREN expression RPAREN "<<endl<<endl;
        outlog<<"("<<$2->getname()<<")"<<endl<<endl;
        $$ = new symbol_info("("+$2->getname()+")","factor");
    }
    | CONST_INT 
    {
        outlog<<"At line no: "<<lines<<" factor : CONST_INT "<<endl<<endl;
        outlog<<$1->getname()<<endl<<endl;
        $$ = $1;
    }
    | CONST_FLOAT 
    {
        outlog<<"At line no: "<<lines<<" factor : CONST_FLOAT "<<endl<<endl;
        outlog<<$1->getname()<<endl<<endl;
        $$ = $1;
    }
    | variable INCOP 
    {
        outlog<<"At line no: "<<lines<<" factor : variable INCOP "<<endl<<endl;
        outlog<<$1->getname()<<$2->getname()<<endl<<endl;
        $$ = new symbol_info($1->getname()+$2->getname(),"factor");
    }
    ;

argument_list 
    : arguments 
    {
        outlog<<"At line no: "<<lines<<" argument_list : arguments "<<endl<<endl;
        outlog<<$1->getname()<<endl<<endl;
        $$ = $1;
    }
    | 
    {
        outlog<<"At line no: "<<lines<<" argument_list : "<<endl<<endl;
        $$ = new symbol_info("","arg_list");
    }
    ;

arguments 
    : arguments COMMA logic_expression 
    {
        outlog<<"At line no: "<<lines<<" arguments : arguments COMMA logic_expression "<<endl<<endl;
        outlog<<$1->getname()<<","<<$3->getname()<<endl<<endl;
        $$ = new symbol_info($1->getname()+","+$3->getname(),"args");
    }
    | logic_expression 
    {
        outlog<<"At line no: "<<lines<<" arguments : logic_expression "<<endl<<endl;
        outlog<<$1->getname()<<endl<<endl;
        $$ = $1;
    }
    ;

%%

void yyerror(const char *s)
{
    outlog<<"Error at line "<<lines<<": "<<s<<endl;
}

int main(int argc, char *argv[])
{
    if(argc != 2) 
    {
        cout<<"Usage: "<<argv[0]<<" <input_file>"<<endl;
        return 1;
    }
    yyin = fopen(argv[1], "r");
    outlog.open("22101198_log.txt", ios::trunc);

    if(yyin == NULL)
    {
        cout<<"Couldn't open file"<<endl;
        return 0;
    }

    outlog<<"New ScopeTable with ID 1 created"<<endl<<endl;
    yyparse();

    outlog.close();
    fclose(yyin);

    return 0;
}

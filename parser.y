%{

#include "nodes.hpp"
#include "output.hpp"

// bison declarations
extern int yylineno;
extern int yylex();

void yyerror(const char*);

// root of the AST, set by the parser and used by other parts of the compiler
std::shared_ptr<ast::Node> program;

using namespace std;

// TODO: Place any additional declarations here
%}
// TODO: Define tokens here

%token VOID INT BYTE BOOL AND OR NOT TRUE FALSE RETURN IF ELSE WHILE BREAK CONTINUE SC COMMA LPAREN RPAREN LBRACE RBRACE ASSIGN
%token ID NUM NUM_B STRING PLUS MINUS MULT DIV LESS GREATER LEQ GEQ EQUAL NEQUAL


// TODO: Define precedence and associativity here

%left OR
%left AND
%left EQUAL NEQUAL
%left LESS GREATER LEQ GEQ 
%left PLUS MINUS
%left MULT DIV
%right NOT
%left LPAREN RPAREN
%%

// While reducing the start variable, set the root of the AST
Program: Funcs {program = $1; }
;
// TODO: Define grammar here
Funcs:
     {
        $$ = std::make_shared<ast::FuncList>();
    }
    | FuncDecl Funcs {
        $$ = $2;
        $$->addFunc($1);
    }
;

FuncDecl:
    RetType ID LPAREN Formals RPAREN LBRACE Statements RBRACE {
        $$ = std::make_shared<ast::FuncDecl>($1, $2, $4, $7);
    }
;

RetType:
    Type {
        $$ = $1;
    }
    | VOID {
        $$ = std::make_shared<ast::VoidType>();
    }
;

Formals:
    /* Empty */ {
        $$ = std::make_shared<ast::FormalList>();
    }
    | FormalsList {
        $$ = $1;
    }
;

FormalsList:
    FormalDecl {
        $$ = std::make_shared<ast::FormalList>();
        $$->addFormal($1);
    }
    | FormalDecl COMMA FormalsList {
        $$ = $3;
        $$->addFormal($1);
    }
;

FormalDecl:
    Type ID {
        $$ = std::make_shared<ast::FormalDecl>($1, $2);
    }
;

Statements:
    Statement {
        $$ = std::make_shared<ast::StatementList>($1);
    }
    | Statements Statement {
        $$ = $1;
        $$->addStatement($2);
    }
;

Statement:
    LBRACE Statements RBRACE {
        $$ = $2;
    }
    | Type ID SC {
        $$ = std::make_shared<ast::VarDecl>($1, $2);
    }
    | Type ID ASSIGN Exp SC {
        $$ = std::make_shared<ast::VarDecl>($1, $2, $4);
    }
    | ID ASSIGN Exp SC {
        $$ = std::make_shared<ast::Assign>($1, $3);
    }
    | Call SC {
        $$ = $1;
    }
    | RETURN SC {
        $$ = std::make_shared<ast::Return>();
    }
    | RETURN Exp SC {
        $$ = std::make_shared<ast::Return>($2);
    }
    | IF LPAREN Exp RPAREN Statement {
        $$ = std::make_shared<ast::If>($3, $5);
    }
    | IF LPAREN Exp RPAREN Statement ELSE Statement {
        $$ = std::make_shared<ast::IfElse>($3, $5, $7);
    }
    | WHILE LPAREN Exp RPAREN Statement {
        $$ = std::make_shared<ast::While>($3, $5);
    }
    | BREAK SC {
        $$ = std::make_shared<ast::Break>();
    }
    | CONTINUE SC {
        $$ = std::make_shared<ast::Continue>();
    }
;

Call:
    ID LPAREN Explist RPAREN {
        $$ = std::make_shared<ast::Call>($1, $3);
    }
    | ID LPAREN RPAREN {
        $$ = std::make_shared<ast::Call>($1);
    }
;

Explist:
    Exp {
        $$ = std::make_shared<ast::ExpList>($1);
    }
    | Exp COMMA Explist {
        $$ = $3;
        $$->addExp($1);
    }
;

Type:
    INT {
        $$ = std::make_shared<ast::IntType>();
    }
    | BYTE {
        $$ = std::make_shared<ast::ByteType>();
    }
    | BOOL {
        $$ = std::make_shared<ast::BoolType>();
    }
;

Exp:
    LPAREN Exp RPAREN {
        $$ = $2;
    }
    | Exp '+' Exp {
        $$ = std::make_shared<ast::BinOp>($1, "+", $3);
    }
    | Exp '-' Exp {
        $$ = std::make_shared<ast::BinOp>($1, "-", $3);
    }
    | Exp '*' Exp {
        $$ = std::make_shared<ast::BinOp>($1, "*", $3);
    }
    | Exp '/' Exp {
        $$ = std::make_shared<ast::BinOp>($1, "/", $3);
    }
    | ID {
        $$ = std::make_shared<ast::Var>($1);
    }
    | Call {
        $$ = $1;
    }
    | NUM {
        $$ = std::make_shared<ast::Num>($1);
    }
    | NUM_B {
        $$ = std::make_shared<ast::Num>($1, true);
    }
    | STRING {
        $$ = std::make_shared<ast::String>($1);
    }
    | TRUE {
        $$ = std::make_shared<ast::Bool>(true);
    }
    | FALSE {
        $$ = std::make_shared<ast::Bool>(false);
    }
    | NOT Exp {
        $$ = std::make_shared<ast::Not>($2);
    }
    | Exp AND Exp {
        $$ = std::make_shared<ast::LogicalAnd>($1, $3);
    }
    | Exp OR Exp {
        $$ = std::make_shared<ast::LogicalOr>($1, $3);
    }
    | Exp EQUAL Exp {
        $$ = std::make_shared<ast::RelOp>($1, $2, $3);
    }
    | Exp NEQUAL Exp {
        $$ = std::make_shared<ast::RelOp>($1, $2, $3);
    }
    | Exp GREATER Exp {
        $$ = std::make_shared<ast::RelOp>($1, $2, $3);
    }
    | Exp LESS Exp {
        $$ = std::make_shared<ast::RelOp>($1, $2, $3);
    }
    | Exp LEQ Exp {
        $$ = std::make_shared<ast::RelOp>($1, $2, $3);
    }
    | Exp GEQ Exp {
        $$ = std::make_shared<ast::RelOp>($1, $2, $3);
    }
    | LPAREN Type RPAREN Exp {
        $$ = std::make_shared<ast::TypeCast>($2, $4);
    }
;

%%
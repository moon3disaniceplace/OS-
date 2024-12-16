%{
#include "tokens.hpp"
#include "output.hpp"
%}

%option noyywrap

digit [0-9]
first_digit [1-9]
whitespace [ \t\r]+  
letter [a-zA-Z]
string \"([^\n\r\"\\]|\\[rnt\"\\])+\"  
comment \/\/[^\r\n]*[\r|\n|\r\n]?

%%

void        return VOID;
int         return INT;
byte        return BYTE;
bool        return BOOL;
and         return AND;
or          return OR;
not         return NOT;
true        return TRUE;
false       return FALSE;
return      return RETURN;
if          return IF;
else        return ELSE;
while       return WHILE;
break       return BREAK;
continue    return CONTINUE;

;           return SC;
,           return COMMA;
\(          return LPAREN;
\)          return RPAREN;
\{          return LBRACE;
\}          return RBRACE;
=           return ASSIGN;

\+              return PLUS;
\-              return MINUS;
\*              return MULT;
\/              return DIV;

==              return EQUAL;
!=              return NEQUAL;
\<               return LESS;
>               return GREATER;
\<=              return LEQ;
>=              return GEQ;

[a-zA-Z][a-zA-Z0-9]*   return ID;

[1-9][0-9]*b|0b        return NUM_B;  // Binary numbers
[1-9][0-9]*|0          return NUM;    // Decimal numbers

{string}    return STRING;
{comment}   {  }
{whitespace} {  }

\n { yylineno++; }

. { output::errorLex(yylineno); }

%%


%{
#include "tokens.hpp"
#include "output.hpp"
%}

%option noyywrap

digit [0-9]
first_digit [1-9]
whitespace [ \t\r]  
letter [a-zA-Z]
relop "=="|"!="|"<"|">"|"<="|">="
binop "-"|"*"|"+"|"/"

%x comment id string hexa escape


%%

void    return VOID;
int     return INT;
byte     return BYTE;
bool     return BOOL;
and     return AND;
or     return OR;
not     return NOT;
true     return TRUE;
false     return FALSE;
return     return RETURN;
if     return IF;
else     return ELSE;
while     return WHILE;
break     return BREAK;
continue     return CONTINUE;
;           return SC;
,           return COMMA;
\(           return LPAREN;
\)           return RPAREN;
\{          return LBRACE;
\}          return RBRACE;
=           return ASSIGN;
{relop}     return RELOP;
{binop}     return BINOP;
"//"         {
    BEGIN (comment);
}
<comment>[^\n\r]*     {
    BEGIN (INITIAL);
    return COMMENT;
}

[a-zA-Z]+[a-zA-Z0-9]*     return ID;


[1-9][0-9]*b|0b       return NUM_B;
[1-9][0-9]*|0         return NUM;


\"([^\"]*\\\")*[^\"]*\"            return STRING; 
\"              output::errorUnclosedString();




{whitespace}+ ;


\n  {yylineno++;}
. {output::errorUnknownChar(*yytext);}

%%


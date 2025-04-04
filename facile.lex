%{
#include <assert.h>
#include <glib.h>

#include "facile.y.h"
%}

%option yylineno

%%

if {
    assert(printf("'if' found\n"));
    return TOK_IF;
}

then {
    assert(printf("'then' found\n"));
    return TOK_THEN;
}

while {
    assert(printf("'while' found\n"));
    return TOK_WHILE;
}

else {
    assert(printf("'else' found\n"));
    return TOK_ELSE;
}

elseif {
    assert(printf("'elseif' found\n"));
    return TOK_ELSEIF;
}

end {
    assert(printf("'end' found\n"));
    return TOK_END;
}

endif {
    assert(printf("'endif' found\n"));
    return TOK_ENDIF;
}

endwhile {
    assert(printf("'endwhile' found\n"));
    return TOK_ENDWHILE;
}

read {
    assert(printf("'read' found\n"));
    return TOK_READ;
}

print {
    assert(printf("'print' found\n"));
    return TOK_PRINT;
}

do {
    assert(printf("'do' found\n"));
    return TOK_DO;
}

continue {
    assert(printf("'continue' found\n"));
    return TOK_CONTINUE;
}

break {
    assert(printf("'break' found\n"));
    return TOK_BREAK;
}

and {
    assert(printf("'and' found\n"));
    return TOK_AND;
}

or {
    assert(printf("'or' found\n"));
    return TOK_OR;
}

not {
    assert(printf("'not' found\n"));
    return TOK_NOT;
}

true {
    assert(printf("'true' found\n"));
    return TOK_TRUE;
}

false {
    assert(printf("'false' found\n"));
    return TOK_FALSE;
}

";" {
    assert(printf("';' found\n"));
    return TOK_SEMI_COLON;
}

":=" {
    assert(printf("':=' found\n"));
    return TOK_AFFECTATION;
}

"+" {
    assert(printf("'+' found\n"));
    return TOK_ADD;
}

"-" {
    assert(printf("'-' found\n"));
    return TOK_SUB;
}

"*" {
    assert(printf("'*' found\n"));
    return TOK_MUL;
}

"/" {
    assert(printf("'/' found\n"));
    return TOK_DIV;
}

"(" {
    assert(printf("'(' found\n"));
    return TOK_OPEN_PARENTHESIS;
}

")" {
    assert(printf("')' found\n"));
    return TOK_CLOSE_PARENTHESIS;
}

">" {
    assert(printf("'>' found\n"));
    return TOK_GT;
}

"<" {
    assert(printf("'<' found\n"));
    return TOK_LT;
}

"=" {
    assert(printf("'=' found\n"));
    return TOK_EQ;
}

">=" {
    assert(printf("'>=' found\n"));
    return TOK_GE;
}

"<=" {
    assert(printf("'<=' found\n"));
    return TOK_LE;
}

"#" {
    assert(printf("'#' found\n"));
    return TOK_COMMENT;
}

"!=" {
    assert(printf("'!=' found\n"));
    return TOK_NEQ;
}

[a-zA-Z][a-zA-Z0-9_]* {
    assert(printf("identifier '%s(%d)' found", yytext, yyleng));
    yylval.string = yytext;
    return TOK_IDENTIFIER;
}

0|[1-9][0-9]* {
    assert(printf("number '%s(%d)' found", yytext, yyleng));
    sscanf(yytext, "%lu", &yylval.number);
    return TOK_NUMBER;
}

[ \t\n] {
    /* ignore white spaces */
}

. {
    return yytext[0];
}

%%
/*
* file: facile.lex
* version: 0.3.0 (exos 1-2-3 OK)
*/

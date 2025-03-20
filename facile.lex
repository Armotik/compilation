%{
#include <assert.h>
#define TOK_IF 258
#define TOK_THEN 259
#define TOK_WHILE 260
#define TOK_ELSE 261
#define TOK_ELSEIF 262
#define TOK_END 263
#define TOK_ENDIF 264
#define TOK_ENDWHILE 265
#define TOK_READ 266
#define TOK_PRINT 267
#define TOK_DO 268
#define TOK_CONTINUE 269
#define TOK_BREAK 270
#define TOK_AND 286
#define TOK_OR 287

#define TOK_SEMICOLON 271
#define TOK_AFFECTATION 272
#define TOK_ADD 273
#define TOK_SUB 274
#define TOK_MUL 275
#define TOK_DIV 276
#define TOK_OPEN_PARENTHESIS 277
#define TOK_CLOSE_PARENTHESIS 278
#define TOK_GREATER_THAN 279
#define TOK_LESS_THAN 280
#define TOK_EQUAL 281
#define TOK_DIFFERENT 282
#define TOK_GREATER_OR_EQUAL 283
#define TOK_LESS_OR_EQUAL 284
#define TOK_COMMENT 285

#define TOK_IDENTIFIER 288
#define TOK_NUMBER 289
%}

%%

if {
    assert(printf("'if' found"));
    return TOK_IF;
}

then {
    assert(printf("'then' found"));
    return TOK_THEN;
}

while {
    assert(printf("'while' found"));
    return TOK_WHILE;
}

else {
    assert(printf("'else' found"));
    return TOK_ELSE;
}

elseif {
    assert(printf("'elseif' found"));
    return TOK_ELSEIF;
}

end {
    assert(printf("'end' found"));
    return TOK_END;
}

endif {
    assert(printf("'endif' found"));
    return TOK_ENDIF;
}

endwhile {
    assert(printf("'endwhile' found"));
    return TOK_ENDWHILE;
}

read {
    assert(printf("'read' found"));
    return TOK_READ;
}

print {
    assert(printf("'print' found"));
    return TOK_PRINT;
}

do {
    assert(printf("'do' found"));
    return TOK_DO;
}

continue {
    assert(printf("'continue' found"));
    return TOK_CONTINUE;
}

break {
    assert(printf("'break' found"));
    return TOK_BREAK;
}

and {
    assert(printf("'and' found"));
    return TOK_AND;
}

or {
    assert(printf("'or' found"));
    return TOK_OR;
}

";" {
    assert(printf("';' found"));
    return TOK_SEMICOLON;
}

":=" {
    assert(printf("':=' found"));
    return TOK_AFFECTATION;
}

"+" {
    assert(printf("'+' found"));
    return TOK_ADD;
}

"-" {
    assert(printf("'-' found"));
    return TOK_SUB;
}

"*" {
    assert(printf("'*' found"));
    return TOK_MUL;
}

"/" {
    assert(printf("'/' found"));
    return TOK_DIV;
}

"(" {
    assert(printf("'(' found"));
    return TOK_OPEN_PARENTHESIS;
}

")" {
    assert(printf("')' found"));
    return TOK_CLOSE_PARENTHESIS;
}

">" {
    assert(printf("'>' found"));
    return TOK_GREATER_THAN;
}

"<" {
    assert(printf("'<' found"));
    return TOK_LESS_THAN;
}

"=" {
    assert(printf("'=' found"));
    return TOK_EQUAL;
}

"!" {
    assert(printf("'!' found"));
    return TOK_DIFFERENT;
}

">=" {
    assert(printf("'>=' found"));
    return TOK_GREATER_OR_EQUAL;
}

"<=" {
    assert(printf("'<=' found"));
    return TOK_LESS_OR_EQUAL;
}

"#" {
    assert(printf("'#' found"));
    return TOK_COMMENT;
}

[a-zA-Z][a-zA-Z0-9_]* {
    assert(printf("identifier '%s(%d)' found", yytext, yyleng));
    return TOK_IDENTIFIER;
}

0|[1-9][0-9]* {
    assert(printf("number '%s(%d)' found", yytext, yyleng));
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
* version: 0.2.0
*/
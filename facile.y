%{
#include <stdlib.h>
#include <stdio.h>
#include <glib.h>
#include <ctype.h>

extern int yylex(void);
extern int yyerror(const char *msg);
extern int yylineno;

void begin_code(void);
void produce_code(GNode* node);
void end_code(void);

GHashTable *table;
FILE *stream;
char *module_name;

int label_id = 0;
GList *break_labels = NULL;
GList *continue_labels = NULL;
%}

%define parse.error verbose

%union {
    gulong number;
    gchar *string;
    GNode *node;
}

%left TOK_ADD TOK_SUB
%left TOK_MUL TOK_DIV

%token<number> TOK_NUMBER
%token<string> TOK_IDENTIFIER
%token TOK_AFFECTATION
%token TOK_SEMI_COLON
%token TOK_ADD
%token TOK_SUB
%token TOK_MUL
%token TOK_DIV
%token TOK_OPEN_PARENTHESIS
%token TOK_CLOSE_PARENTHESIS
%token TOK_EQ
%token TOK_NEQ
%token TOK_LT
%token TOK_GT
%token TOK_LE
%token TOK_GE

%token TOK_IF
%token TOK_THEN
%token TOK_ELSE
%token TOK_ELSEIF
%token TOK_ENDIF
%token TOK_WHILE
%token TOK_DO
%token TOK_ENDWHILE
%token TOK_READ
%token TOK_PRINT
%token TOK_CONTINUE
%token TOK_BREAK
%token TOK_AND
%token TOK_OR
%token TOK_NOT
%token TOK_TRUE
%token TOK_FALSE

%type<node> code
%type<node> expression
%type<node> instruction
%type<node> identifier
%type<node> print
%type<node> read
%type<node> affectation
%type<node> number
%type<node> if_instruction
%type<node> while_instruction
%type<node> elseif_blocks
%type<node> optional_else

%%

program: code {
    begin_code();
    produce_code($1);
    end_code();
    g_node_destroy($1);
}
;

code:
    instruction code {
        $$ = g_node_new("code");
        g_node_append($$, $1);
        g_node_append($$, $2);
    }
    |
    instruction {
        $$ = g_node_new("code");
        g_node_append($$, $1);
    }
;

instruction:
    affectation |
    print |
    read |
    if_instruction |
    while_instruction |
    TOK_CONTINUE TOK_SEMI_COLON {
        $$ = g_node_new("continue");
    }
    |
    TOK_BREAK TOK_SEMI_COLON {
        $$ = g_node_new("break");
    }
;

affectation:
    identifier TOK_AFFECTATION expression TOK_SEMI_COLON {
        $$ = g_node_new("affectation");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
;

print:
    TOK_PRINT expression TOK_SEMI_COLON {
        $$ = g_node_new("print");
        g_node_append($$, $2);
    }
;

read:
    TOK_READ identifier TOK_SEMI_COLON {
        $$ = g_node_new("read");
        g_node_append($$, $2);
    }
;

expression:
    identifier
    |
    number
    |
    expression TOK_ADD expression {
        $$ = g_node_new("add");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    |
    expression TOK_SUB expression {
        $$ = g_node_new("sub");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    |
    expression TOK_MUL expression {
        $$ = g_node_new("mul");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    |
    expression TOK_DIV expression {
        $$ = g_node_new("div");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    |
    TOK_OPEN_PARENTHESIS expression TOK_CLOSE_PARENTHESIS {
        $$ = $2;
    }
    |
    expression TOK_EQ expression {
        $$ = g_node_new("eq");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    |
    expression TOK_NEQ expression {
        $$ = g_node_new("neq");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    |
    expression TOK_LT expression {
        $$ = g_node_new("lt");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    |
    expression TOK_GT expression {
        $$ = g_node_new("gt");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    |
    expression TOK_LE expression {
        $$ = g_node_new("le");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    |
    expression TOK_GE expression {
        $$ = g_node_new("ge");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    |
    expression TOK_AND expression {
        $$ = g_node_new("and");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    |
    expression TOK_OR expression {
        $$ = g_node_new("or");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
    |
    TOK_TRUE {
        $$ = g_node_new("true");
        g_node_append_data($$, (gpointer)1);
    }
    |
    TOK_FALSE {
        $$ = g_node_new("false");
        g_node_append_data($$, (gpointer)0);
    }
    |
    TOK_NOT expression {
        $$ = g_node_new("not");
        g_node_append($$, $2);
    }
;

identifier:
    TOK_IDENTIFIER {
        $$ = g_node_new("identifier");
        gulong value = (gulong) g_hash_table_lookup(table, $1);
        if (!value) {
            value = g_hash_table_size(table) + 1;
            g_hash_table_insert(table, strdup($1), (gpointer) value);
        }
        g_node_append_data($$, (gpointer)value);
    }
;

number:
    TOK_NUMBER {
        $$ = g_node_new("number");
        g_node_append_data($$, (gpointer)$1);
    }
;

if_instruction:
      TOK_IF expression TOK_THEN code elseif_blocks optional_else TOK_ENDIF TOK_SEMI_COLON {
          $$ = g_node_new("if_complex");
          g_node_append($$, $2); // condition principale
          g_node_append($$, $4); // code principal
          g_node_append($$, $5); // elseif blocks
          if ($6 != NULL) g_node_append($$, $6); // else block
      }
    | TOK_IF expression TOK_THEN code TOK_ENDIF TOK_SEMI_COLON {
        $$ = g_node_new("if_endif");
        g_node_append($$, $2);
        g_node_append($$, $4);
    }
;

elseif_blocks:
    { $$ = g_node_new("elseif_blocks"); }
    | elseif_blocks TOK_ELSEIF expression TOK_THEN code {
        GNode *node = g_node_new("elseif");
        g_node_append(node, $3);
        g_node_append(node, $5);
        g_node_append($1, node);
        $$ = $1;
    }
;

optional_else:
    { $$ = NULL; }
    | TOK_ELSE code {
        $$ = g_node_new("else");
        g_node_append($$, $2);
    }
;



while_instruction:
    TOK_WHILE expression TOK_DO code TOK_ENDWHILE TOK_SEMI_COLON {
        $$ = g_node_new("while");
        g_node_append($$, $2);
        g_node_append($$, $4);
    }
;

%%

/*
* file: facile.y
* version: 0.8.0
*/

int yyerror(const char *msg) {
    fprintf(stderr, "Line %d: %s\n", yylineno, msg);
}

void begin_code(void) {
    fprintf(stream, ".assembly extern mscorlib {}\n");
    fprintf(stream, ".assembly %s {}\n", module_name);
    fprintf(stream, ".module %s.exe\n", module_name);
    fprintf(stream, ".method static void Main() cil managed\n");
    fprintf(stream, "{\n");
    fprintf(stream, "    .entrypoint\n");

    if (g_hash_table_size(table) > 0) {
        fprintf(stream, "    .locals init (");

        GHashTableIter iter;
        gpointer key, value;
        gboolean first = TRUE;

        g_hash_table_iter_init(&iter, table);
        while (g_hash_table_iter_next(&iter, &key, &value)) {
            if (!first) {
                fprintf(stream, ", ");
            }
            first = FALSE;
            fprintf(stream, "int32 V_%ld", (gulong)value - 1);
        }

        fprintf(stream, ")\n");
    }
}

void end_code(void) {
    fprintf(stream, "    ret\n");
    fprintf(stream, "}\n");
}

void produce_code(GNode* node) {
    if (strcmp(node->data, "code") == 0) {
        for (GNode *child = g_node_first_child(node); child != NULL; child = g_node_next_sibling(child)) {
            produce_code(child);
        }

    } else if (strcmp(node->data, "affectation") == 0) {
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " stloc\t%ld\n", (long)g_node_nth_child(g_node_nth_child(node, 0), 0)->data - 1);

    } else if (strcmp(node->data, "add") == 0) {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " add\n");

    } else if (strcmp(node->data, "sub") == 0) {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " sub\n");

    } else if (strcmp(node->data, "mul") == 0) {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " mul\n");

    } else if (strcmp(node->data, "div") == 0) {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " div\n");

    } else if (strcmp(node->data, "number") == 0) {
        fprintf(stream, " ldc.i4\t%ld\n", (long)g_node_nth_child(node, 0)->data);

    } else if (strcmp(node->data, "identifier") == 0) {
        fprintf(stream, " ldloc\t%ld\n", (long)g_node_nth_child(node, 0)->data - 1);

    } else if (strcmp(node->data, "print") == 0) {
        produce_code(g_node_nth_child(node, 0));
        fprintf(stream, " call void class [mscorlib]System.Console::WriteLine(int32)\n");

    } else if (strcmp(node->data, "read") == 0) {
        fprintf(stream, " call string class [mscorlib]System.Console::ReadLine()\n");
        fprintf(stream, " call int32 int32::Parse(string)\n");
        fprintf(stream, " stloc\t%ld\n", (long)g_node_nth_child(g_node_nth_child(node, 0), 0)->data - 1);

    } else if (strcmp(node->data, "gt") == 0) {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " cgt\n");

    } else if (strcmp(node->data, "lt") == 0) {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " clt\n");

    } else if (strcmp(node->data, "eq") == 0) {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " ceq\n");
   
    } else if (strcmp(node->data, "neq") == 0) {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " ceq\n");
        fprintf(stream, " ldc.i4.0\n");
        fprintf(stream, " ceq\n");

    } else if (strcmp(node->data, "le") == 0) {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " cgt\n");
        fprintf(stream, " ldc.i4.0\n");
        fprintf(stream, " ceq\n");

    } else if (strcmp(node->data, "ge") == 0) {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " clt\n");
        fprintf(stream, " ldc.i4.0\n");
        fprintf(stream, " ceq\n");

    } else if (strcmp(node->data, "or") == 0) {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " or\n");
    
    } else if (strcmp(node->data, "and") == 0) {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " and\n");
    
    } else if (strcmp(node->data, "if_endif") == 0) {
        int label_end = label_id++;

        produce_code(g_node_nth_child(node, 0));
        fprintf(stream, " brfalse L%d\n", label_end);
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, "L%d:\n", label_end);
        fprintf(stream, " nop\n");

    } else if (strcmp(node->data, "if_else") == 0) {
        int label_else = label_id++;
        int label_end = label_id++;

        produce_code(g_node_nth_child(node, 0));
        fprintf(stream, " brfalse L%d\n", label_else);
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " br L%d\n", label_end);
        fprintf(stream, "L%d:\n", label_else);
        fprintf(stream, " nop\n");
        produce_code(g_node_nth_child(node, 2));
        fprintf(stream, "L%d:\n", label_end);
        fprintf(stream, " nop\n");

    } else if (strcmp(node->data, "while") == 0) {
        int label_start = label_id++;
        int label_end = label_id++;
    
        continue_labels = g_list_prepend(continue_labels, GINT_TO_POINTER(label_start));
        break_labels = g_list_prepend(break_labels, GINT_TO_POINTER(label_end));
    
        fprintf(stream, "L%d:\n", label_start);
        produce_code(g_node_nth_child(node, 0));
        fprintf(stream, " brfalse L%d\n", label_end);
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " br L%d\n", label_start);
        fprintf(stream, "L%d:\n", label_end);
        fprintf(stream, " nop\n");
    
        continue_labels = g_list_delete_link(continue_labels, continue_labels);
        break_labels = g_list_delete_link(break_labels, break_labels);
    
    } else if (strcmp(node->data, "not") == 0) {
        produce_code(g_node_nth_child(node, 0));
        fprintf(stream, " ldc.i4.0\n");
        fprintf(stream, " ceq\n");
    
    } else if (strcmp(node->data, "break") == 0) {
        if (!break_labels) {
            fprintf(stderr, "Error: 'break' used outside of loop\n");
            exit(EXIT_FAILURE);
        }
        int target = GPOINTER_TO_INT(break_labels->data);
        fprintf(stream, " br L%d\n", target);
    
    } else if (strcmp(node->data, "continue") == 0) {
        if (!continue_labels) {
            fprintf(stderr, "Error: 'continue' used outside of loop\n");
            exit(EXIT_FAILURE);
        }
        int target = GPOINTER_TO_INT(continue_labels->data);
        fprintf(stream, " br L%d\n", target);
    
    } else if (strcmp(node->data, "if_complex") == 0) {
        int label_end = label_id++;
        int label_next = label_id++;
    
        produce_code(g_node_nth_child(node, 0));
        fprintf(stream, " brfalse L%d\n", label_next);
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, " br L%d\n", label_end);
    
        fprintf(stream, "L%d:\n", label_next);
        GNode *elseif_blocks = g_node_nth_child(node, 2);
        for (GNode *child = g_node_first_child(elseif_blocks); child != NULL; child = g_node_next_sibling(child)) {
            int label_elseif_next = label_id++;
            produce_code(g_node_nth_child(child, 0));
            fprintf(stream, " brfalse L%d\n", label_elseif_next);
            produce_code(g_node_nth_child(child, 1));
            fprintf(stream, " br L%d\n", label_end);
            fprintf(stream, "L%d:\n", label_elseif_next);
        }
    
        if (g_node_n_children(node) == 4) {
            GNode *else_node = g_node_nth_child(node, 3);
            produce_code(g_node_first_child(else_node));
        }
    
        fprintf(stream, "L%d:\n", label_end);
        fprintf(stream, " nop\n");
    }
}

int main(int argc, char *argv[]) {
    if (argc == 2) {
        char *file_name_input = argv[1];
        char *extension;
        char *directory_delimiter;
        char *basename;
        extension = rindex(file_name_input, '.');

        if (!extension || strcmp(extension, ".facile") != 0) {
            fprintf(stderr, "Input filename extension must be '.facile'\n");
            return EXIT_FAILURE;
        }

        directory_delimiter = rindex(file_name_input, '/');

        if (!directory_delimiter) {
            directory_delimiter = rindex(file_name_input, '\\');
        }

        if (directory_delimiter) {
            basename = strdup(directory_delimiter + 1);
        } else {
            basename = strdup(file_name_input);
        }
        
        module_name = strdup(basename);
        *rindex(module_name, '.') = '\0';
        strcpy(rindex(basename, '.'), ".il");
        char *onechar = module_name;

        if (!isalpha(*onechar) && *onechar != '_') {
            free(basename);
            fprintf(stderr, "Base input filename must start with a letter or an underscore\n");
            return EXIT_FAILURE;
        }

        onechar++;

        while (*onechar) {
            if (!isalnum(*onechar) && *onechar != '_') {
                free(basename);
                fprintf(stderr, "Base input filename cannot contains special characters\n");
                return EXIT_FAILURE;
            }

            onechar++;
        }

        if (stdin = fopen(file_name_input, "r")) {
            if (stream = fopen(basename, "w")) {
                table = g_hash_table_new_full(g_str_hash, g_str_equal, free, NULL);
                yyparse();
                g_hash_table_destroy(table);
                fclose(stream);
                fclose(stdin);
            } else {
                free(basename);
                fclose(stdin);
                fprintf(stderr, "Output filename cannot be opened\n");
                return EXIT_FAILURE;
            }
        } else {
            free(basename);
            fprintf(stderr, "Input filename cannot be opened\n");
            return EXIT_FAILURE;
        }
        free(basename);
    } else {
        fprintf(stderr, "No input filename given\n");
        return EXIT_FAILURE;
    }
    
    return EXIT_SUCCESS;
}
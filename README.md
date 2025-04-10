# Compilation - Projet

## Objectif

TP et Projet Flex-Bison
Durant les TPs de cette partie, vous allez travailler sur un projet de conception d'un langage dit Facile, veuillez
trouver les détailler dans le cahier d'apprentissage ci-dessous.

## Structure du projet

```
.
├── build/
├── tests/
├── CMakeLists.txt
├── facile.lex
├── facile.y
└── README.md
```

- Le dossier [build](build) contient les fichiers générés par CMake lors de la compilation du projet.
- Le dossier [tests](tests) contient les fichiers de tests du projet.
- Le fichier [CMakeLists.txt](CMakeLists.txt) contient les instructions de compilation du projet.
- Le fichier [facile.lex](facile.lex) contient les règles de définition des tokens du langage Facile.
- Le fichier [facile.y](facile.y) contient les règles de syntaxe du langage Facile.

## Exercices

### Exercice 1

Ajoutez dans le fichier [facile.lex](facile.lex) les autres mots clés du langage. Nous verrons par la suite
comment gérer les chaines contenant des caractères spéciaux, les identificateurs et les nombres.

Les mots clés rajoutés sont les suivants :

- `read` -> pour lire une valeur à partir de l'entrée standard.
- `print` -> pour afficher une valeur sur la sortie standard.
- `endif` -> pour terminer une condition.
- `else` -> pour gérer le cas où la condition n'est pas vérifiée.
- `elseif` -> pour gérer un autre cas de condition.
- `while` -> pour gérer une boucle.
- `do` -> pour gérer une boucle.
- `endwhile` -> pour terminer une boucle.
- `continue` -> pour passer à l'itération suivante.
- `break` -> pour sortir de la boucle.

---

### Exercice 2

Ajoutez dans le fichier facile.lex les autres ponctuations du langage.

Les ponctuations rajoutées sont les suivantes :

- `>=` -> pour vérifier si une valeur est supérieure ou égale à une autre.
- `<=` -> pour vérifier si une valeur est inférieure ou égale à une autre.
- `>` -> pour vérifier si une valeur est supérieure à une autre.
- `<` -> pour vérifier si une valeur est inférieure à une autre.
- `=` -> pour vérifier si une valeur est égale à une autre.
- `#` -> pour commenter une ligne.
- `(` -> pour ouvrir une parenthèse.
- `)` -> pour fermer une parenthèse.
- `!` -> pour vérifier si une valeur est différente d'une autre.

---

### Exercice 3

Ajoutez dans le fichier facile.lex l’analyse des nombres tels qu’ils sont définis dans la norme du
langage facile.

Les nombres sont définis comme suit :

- `0|[1-9][0-9]*` -> pour les nombres entiers.

---

### Exercice 4

Ajoutez des règles au langage facile pour qu’il puisse gérer les instructions if sans l’utilisation
des mots-clés else et elseif et sans tests imbriqués.

#### Gestion des instructions `if_endif`

Le code suivant permet de gérer les instructions `if` simples sans `else`, `elseif` ou tests imbriqués

#### Étapes principales :

1. **Évaluation de la condition** :
   
   - La condition est évaluée en générant le code correspondant au premier enfant du nœud.
   - Si la condition est fausse, le programme saute directement à l'étiquette de fin (`L<label_end>`).

2. **Exécution du bloc d'instructions** :
   
   - Si la condition est vraie, le code du bloc d'instructions est généré pour le deuxième enfant du nœud.

3. **Étiquette de fin** :
   
   - Une étiquette unique (`L<label_end>`) est ajoutée pour marquer la fin de l'instruction `if`.

#### Code correspondant :

```c
} else if (strcmp(node->data, "if_endif") == 0) {
    int label_end = label_id++;

    // Génération du code pour la condition
    produce_code(g_node_nth_child(node, 0));
    fprintf(stream, " brfalse L%d\n", label_end);

    // Génération du code pour le bloc d'instructions
    produce_code(g_node_nth_child(node, 1));

    // Étiquette de fin
    fprintf(stream, "L%d:\n", label_end);
    fprintf(stream, " nop\n");
}
```

#### Exemple

```facile
read a;
read b;

if a > b then
    print a;
endif;

if b > a then
    print b;
endif;

print 999;
```

#### Résultat

Pour :

- `a = 10`
- `b = 5`

Le résultat est le suivant :

```
10
999
```

---

### Exercice 5

Ajoutez des règles au langage facile pour qu’il puisse gérer les instructions `if` avec l’utilisation des mots-clés
`else` et `elseif`.

#### Gestion des instructions `if_else`

Le code suivant permet de gérer les instructions `if` avec un bloc `else`.

#### Étapes principales :

1. **Évaluation de la condition** :
   
   - La condition est évaluée en générant le code correspondant au premier enfant du nœud.
   - Si la condition est fausse, le programme saute au bloc `else` via une étiquette (`L<label_else>`).

2. **Exécution du bloc `if`** :
   
   - Si la condition est vraie, le code du bloc d'instructions est généré pour le deuxième enfant du nœud.
   - Une fois terminé, le programme saute à la fin de l'instruction (`L<label_end>`).

3. **Exécution du bloc `else`** :
   
   - Si la condition est fausse, le code du bloc `else` est généré pour le troisième enfant du nœud.

4. **Étiquette de fin** :
   
   - Une étiquette unique (`L<label_end>`) est ajoutée pour marquer la fin de l'instruction.

#### Code correspondant :

```c
} else if (strcmp(node->data, "if_else") == 0) {
    int label_else = label_id++;
    int label_end = label_id++;

    // Génération du code pour la condition
    produce_code(g_node_nth_child(node, 0));
    fprintf(stream, " brfalse L%d\n", label_else);

    // Génération du code pour le bloc `if`
    produce_code(g_node_nth_child(node, 1));
    fprintf(stream, " br L%d\n", label_end);

    // Génération du code pour le bloc `else`
    fprintf(stream, "L%d:\n", label_else);
    produce_code(g_node_nth_child(node, 2));

    // Étiquette de fin
    fprintf(stream, "L%d:\n", label_end);
    fprintf(stream, " nop\n");
}
```

#### Gestion des instructions `if_complex` (avec `elseif`)

Le code suivant permet de gérer les instructions `if` avec des blocs `elseif` et éventuellement un bloc `else`.

#### Étapes principales :

1. Évaluation de la condition principale :
   
   - La condition principale est évaluée.
   - Si elle est fausse, le programme saute au premier bloc `elseif` ou au bloc `else` via une étiquette (
     `L<label_next>`).

2. Gestion des blocs elseif :
   
   - Chaque bloc `elseif` est évalué séquentiellement.
   - Si une condition `elseif` est vraie, le code correspondant est exécuté, et le programme saute à la fin de
     l'instruction (`L<label_end>`).

3. Gestion du bloc else :
   
   - Si aucun bloc `if` ou `elseif` n'est exécuté, le bloc `else` est évalué (s'il existe).

4. Étiquette de fin :
   
   - Une étiquette unique (`L<label_end>`) est ajoutée pour marquer la fin de l'instruction.

#### Code correspondant :

```c
} else if (strcmp(node->data, "if_complex") == 0) {
    int label_end = label_id++;
    int label_next = label_id++;

    // Génération du code pour la condition principale
    produce_code(g_node_nth_child(node, 0));
    fprintf(stream, " brfalse L%d\n", label_next);

    // Génération du code pour le bloc `if`
    produce_code(g_node_nth_child(node, 1));
    fprintf(stream, " br L%d\n", label_end);

    // Gestion des blocs `elseif`
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

    // Gestion du bloc `else` (s'il existe)
    if (g_node_n_children(node) == 4) {
        GNode *else_node = g_node_nth_child(node, 3);
        produce_code(g_node_first_child(else_node));
    }

    // Étiquette de fin
    fprintf(stream, "L%d:\n", label_end);
    fprintf(stream, " nop\n");
}
```

#### Exemple

```facile
read note;

if note >= 16 then
    print 1;
elseif note >= 14 then
    print 2;
elseif note >= 10 then
    print 3;
else
    print 4;
endif;

print 999;
```

#### Résultat

Pour :

- `note = 10`

Le résultat est le suivant :

```
3
999
```

---

### Exercice 6

Ajoutez des règles au langage facile pour qu’il puisse gérer les instructions `if` avec des tests imbriqués.

#### Gestion des instructions `if_nested`

Le code suivant permet de gérer les instructions `if` imbriquées, c’est-à-dire des blocs `if` à l’intérieur d’autres
blocs `if`.

#### Étapes principales :

1. **Évaluation de la condition principale** :
   
   - La condition principale est évaluée.
   - Si elle est fausse, le programme saute directement à l’étiquette de fin (`L<label_end>`).

2. **Exécution du bloc principal** :
   
   - Si la condition principale est vraie, le code du bloc d’instructions est généré.
   - Ce bloc peut contenir d’autres instructions `if`, qui seront elles-mêmes évaluées et générées récursivement.

3. **Étiquette de fin** :
   
   - Une étiquette unique (`L<label_end>`) est ajoutée pour marquer la fin de l’instruction principale.

#### Code correspondant :

```c
} else if (strcmp(node->data, "if_nested") == 0) {
    int label_end = label_id++;

    // Génération du code pour la condition principale
    produce_code(g_node_nth_child(node, 0));
    fprintf(stream, " brfalse L%d\n", label_end);

    // Génération du code pour le bloc principal (peut contenir des `if` imbriqués)
    produce_code(g_node_nth_child(node, 1));

    // Étiquette de fin
    fprintf(stream, "L%d:\n", label_end);
    fprintf(stream, " nop\n");
}
```

#### Exemple

```facile
read note;

if note >= 10 then
    print 1;
    if note >= 15 then
        print 2;
    endif;
else
    print 0;
endif;

if note < 10 then
    print 100;
else
    if note < 13 then
        print 200;
    else
        print 300;
    endif;
endif;

print 999;
```

#### Résultat

Pour :

- `note = 12`

Le résultat est le suivant :

```
1
200
999
```

---

### Exercice 7

Ajoutez des règles au langage facile pour qu’il puisse gérer les instructions `while` sans l’utilisation des mots-clés
`break` et `continue` et sans boucles imbriquées.

#### Gestion des instructions `while`

Le code suivant permet de gérer les boucles `while` simples.

#### Étapes principales :

1. **Étiquette de début** :
   
   - Une étiquette unique (`L<label_start>`) est ajoutée pour marquer le début de la boucle.

2. **Évaluation de la condition** :
   
   - La condition est évaluée.
   - Si elle est fausse, le programme saute directement à l’étiquette de fin (`L<label_end>`).

3. **Exécution du bloc d’instructions** :
   
   - Si la condition est vraie, le code du bloc d’instructions est généré.

4. **Retour au début** :
   
   - Une instruction est ajoutée pour revenir à l’étiquette de début.

5. **Étiquette de fin** :
   
   - Une étiquette unique (`L<label_end>`) est ajoutée pour marquer la fin de la boucle.

#### Code correspondant :

```c
} else if (strcmp(node->data, "while") == 0) {
    int label_start = label_id++;
    int label_end = label_id++;

    // Étiquette de début
    fprintf(stream, "L%d:\n", label_start);

    // Génération du code pour la condition
    produce_code(g_node_nth_child(node, 0));
    fprintf(stream, " brfalse L%d\n", label_end);

    // Génération du code pour le bloc d’instructions
    produce_code(g_node_nth_child(node, 1));

    // Retour au début
    fprintf(stream, " br L%d\n", label_start);

    // Étiquette de fin
    fprintf(stream, "L%d:\n", label_end);
    fprintf(stream, " nop\n");
}
```

#### Exemple

```facile
read x;

while x > 0 do
    print x;
    x := x - 1;
endwhile;

print 999;
```

#### Résultat

Pour :

- `x = 5`

Le résultat est le suivant :

```
5
4
3
2
1
999
```

---

### Exercice 8

Ajoutez des règles au langage facile pour qu’il puisse gérer les instructions `while` avec l’utilisation des mots-clés
`break` et `continue`.

#### Gestion des instructions `while` avec `break` et `continue`

Le code suivant permet de gérer les boucles `while` avec les mots-clés `break` et `continue`.

#### Étapes principales :

1. **Étiquette de début** :
   
   - Une étiquette unique (`L<label_start>`) est ajoutée pour marquer le début de la boucle.

2. **Évaluation de la condition** :
   
   - La condition est évaluée.
   - Si elle est fausse, le programme saute directement à l’étiquette de fin (`L<label_end>`).

3. **Exécution du bloc d’instructions** :
   
   - Si la condition est vraie, le code du bloc d’instructions est généré.
   - Les instructions `break` et `continue` sont gérées :
     - `break` saute directement à l’étiquette de fin.
     - `continue` saute directement à l’étiquette de début.

4. **Retour au début** :
   
   - Une instruction est ajoutée pour revenir à l’étiquette de début.

5. **Étiquette de fin** :
   
   - Une étiquette unique (`L<label_end>`) est ajoutée pour marquer la fin de la boucle.

#### Code correspondant :

```c
} else if (strcmp(node->data, "while") == 0) {
    int label_start = label_id++;
    int label_end = label_id++;

    // Étiquette de début
    fprintf(stream, "L%d:\n", label_start);

    // Génération du code pour la condition
    produce_code(g_node_nth_child(node, 0));
    fprintf(stream, " brfalse L%d\n", label_end);

    // Génération du code pour le bloc d’instructions
    GNode *body = g_node_nth_child(node, 1);
    for (GNode *child = g_node_first_child(body); child != NULL; child = g_node_next_sibling(child)) {
        if (strcmp(child->data, "break") == 0) {
            fprintf(stream, " br L%d\n", label_end);
        } else if (strcmp(child->data, "continue") == 0) {
            fprintf(stream, " br L%d\n", label_start);
        } else {
            produce_code(child);
        }
    }

    // Retour au début
    fprintf(stream, " br L%d\n", label_start);

    // Étiquette de fin
    fprintf(stream, "L%d:\n", label_end);
    fprintf(stream, " nop\n");
}
```

#### Exemple

```facile
read x;
print x;

while x > 0 do
    if x = 5 then
        x := x - 1;
        continue;
    endif;
    if x = 2 then
        break;
    endif;
    print x;
    x := x - 1;
endwhile;
```

#### Résultat

Pour :

- `x = 6`

Le résultat est le suivant :

```
6
6
4
3
```

---

### Exercice 9

Ajoutez des règles au langage facile pour qu’il puisse gérer les instructions `while` avec des boucles imbriquées.

#### Gestion des instructions `while` imbriquées

Le code suivant permet de gérer les boucles `while` imbriquées, c’est-à-dire des boucles à l’intérieur d’autres boucles.

#### Étapes principales :

1. **Étiquette de début** :
   
   - Une étiquette unique (`L<label_start>`) est ajoutée pour marquer le début de chaque boucle.

2. **Évaluation de la condition** :
   
   - La condition de chaque boucle est évaluée.
   - Si elle est fausse, le programme saute directement à l’étiquette de fin correspondante (`L<label_end>`).

3. **Exécution du bloc d’instructions** :
   
   - Si la condition est vraie, le code du bloc d’instructions est généré.
   - Ce bloc peut contenir d’autres boucles `while`, qui seront elles-mêmes évaluées et générées récursivement.

4. **Retour au début** :
   
   - Une instruction est ajoutée pour revenir à l’étiquette de début de la boucle.

5. **Étiquette de fin** :
   
   - Une étiquette unique (`L<label_end>`) est ajoutée pour marquer la fin de chaque boucle.

#### Code correspondant :

```c
} else if (strcmp(node->data, "while_nested") == 0) {
    int label_start = label_id++;
    int label_end = label_id++;

    // Étiquette de début
    fprintf(stream, "L%d:\n", label_start);

    // Génération du code pour la condition
    produce_code(g_node_nth_child(node, 0));
    fprintf(stream, " brfalse L%d\n", label_end);

    // Génération du code pour le bloc d’instructions (peut contenir des boucles imbriquées)
    produce_code(g_node_nth_child(node, 1));

    // Retour au début
    fprintf(stream, " br L%d\n", label_start);

    // Étiquette de fin
    fprintf(stream, "L%d:\n", label_end);
    fprintf(stream, " nop\n");
}
```

#### Exemple

```facile
read i;

while i > 0 do
    read j;
    while j > 0 do
        print i;
        print j;
        j := j - 1;
    endwhile;
    i := i - 1;
endwhile;

print 999;
```

#### Résultat

Pour :

- `i = 2`
- `j = 2`

Le résultat est le suivant :

```
2
2
2
1
1
1
999
```

---

### Exercice 10

Écrivez un programme dans le langage facile permettant de calculer le plus grand commun diviseur
de deux nombres saisis au clavier.

#### Exemple

```facile
read a;
read b;

while a != b do
    if a > b then
        a := a - b;
    else
        b := b - a;
    endif;
endwhile;

print a;
```

#### Résultat

Pour :

- `a = 12`
- `b = 8`

Le résultat est le suivant :

```
4
```

---

## Détail du code

### facile.lex

Le fichier [facile.lex](facile.lex) est responsable de l’analyse lexicale du langage **Facile**. Il permet d’identifier
et de transformer
les chaînes de caractères présentes dans le code source en tokens qui seront ensuite traités par l’analyseur syntaxique
défini dans [facile.y](facile.y).

1. Inclusion des dépendances :

```c
%{
#include <assert.h>
#include <glib.h>
#include "facile.y.h"
%}
```

On commence par inclure les bibliothèques nécessaires, notamment `glib` pour la gestion des chaînes et des structures,
et
l'en-tête généré par Bison pour accéder aux types et tokens définis dans [facile.y](facile.y).

2. Déclaration d'options :

```lex
%option yylineno
```

L’option `yylineno` permet de suivre le numéro de ligne du fichier source analysé, ce qui est utile pour les messages
d'erreur.

3. Définition des tokens :

Chaque règle correspond à une expression régulière associée à une action à effectuer lorsqu'elle est reconnue.

Par exemple :

```lex
if { return TOK_IF; }
```

Cette ligne permet de reconnaître le mot-clé `if` dans le langage et de le transformer en token `TOK_IF` pour l’analyse
syntaxique.

Tous les mots-clés (`if`, `then`, `else`, `read`, `print`, etc.), opérateurs (`+`, `-`, `*`, `/`, `:=`, etc.) et
symboles (`(`, `)`, `;`, etc.) sont gérés dans ce fichier.

4. Affichage de débogage avec `assert(printf(...))`

Chaque règle contient une instruction comme

```c
assert(printf("'if' found\n"));
```

Cela permet de suivre en temps réel l'identification des tokens lors du parsing, ce qui facilite énormément le débogage.
Si une règle est mal reconnue ou ignorée, ces messages sont très utiles pour corriger rapidement.

5. Gestion des identifiants et des nombres

```c
[a-zA-Z][a-zA-Z0-9_]* {
    yylval.string = strdup(yytext);
    return TOK_IDENTIFIER;
}

0|[1-9][0-9]* {
    sscanf(yytext, "%lu", &yylval.number);
    return TOK_NUMBER;
}
```

- Les identifiants sont des mots qui commencent par une lettre et peuvent contenir lettres, chiffres et underscores.

- Les nombres entiers sont reconnus via une expression régulière standard (zéro ou une suite de chiffres ne commençant
  pas par 0).
6. Espaces et caractères inconnus

```c
[ \t\n] { /* ignore white spaces */ }

. {
    return yytext[0];
}
```

- Les espaces, tabulations et nouvelles lignes sont ignorés.
- Tout caractère non reconnu est retourné tel quel pour que le parser puisse éventuellement le signaler comme erreur.

### facile.y

Le fichier [facile.y](facile.y) constitue la **grammaire du langage Facile**, définie avec **Bison**. C’est le cœur de
l’analyse
syntaxique : il construit un **arbre de syntaxe abstraite** (AST) à partir des tokens reconnus
par [facile.lex](facile.lex) et permet de
**générer du code CIL** à partir de cet arbre.

1. En-tête et variables globales

```c
%{
#include <stdlib.h>
#include <stdio.h>
#include <glib.h>
...
%}
```

Cette section contient les **inclusions de bibliothèques**, les **prototypes de fonctions** utiles à la compilation (
`begin_code`,
`produce_code`, `end_code`), et les **structures globales** : la table de symboles (`table`), le fichier de sortie (
`stream`), le
nom du module (`module_name`) et les compteurs d’étiquettes (`label_id`).

2. Déclarations de Bison

```bison
%union {
    gulong number;
    gchar *string;
    GNode *node;
}
```

Cela définit les types de valeurs que les tokens ou règles peuvent manipuler (`number`, `string`, `node`).

Il y a ensuite :

- les **tokens lexicaux** (`TOK_IF`, `TOK_ADD`, etc.),

- les **associations de types** (`%type<node> expression`, etc.),

- les **priorités des opérateurs** (`%left` pour `+`, `-`, etc.),

- la **gestion des erreurs explicites** (`%define parse.error verbose`).
3. Grammaire du langage

La section centrale contient les **règles de production**, qui décrivent la **structure syntaxique du langage**. Chaque
règle construit un **nœud de l’AST**.

Exemples :

- Programme principal :

```c
program: code { ... }
```

Le point d'entrée du programme génère le code à partir de l’AST.

- Instructions

```c
instruction:
    affectation |
    print |
    read |
    if_instruction |
    while_instruction |
    ...
```

Chaque type d’instruction (lecture, écriture, condition, boucle, etc.) est défini comme une règle de syntaxe.

- Expressions

```c
expression:
    expression TOK_ADD expression { $$ = g_node_new("add"); ... }
```

Les expressions arithmétiques et booléennes sont analysées récursivement et traduites en nœuds d’AST (`add`, `mul`,
`lt`, `or`, etc.).

4. Conditions `if` et Boucles `while`

Les instructions conditionnelles sont gérées avec plusieurs types de nœuds :

- `if_endif` (condition simple),

- `if_else` (condition avec un bloc alternatif),

- `if_complex` (avec elseif et else imbriqués).

Les boucles sont définies avec :

```c
while_instruction:
    TOK_WHILE expression TOK_DO code TOK_ENDWHILE TOK_SEMI_COLON { ... }
```

Elles peuvent contenir des instructions `break` et `continue`, qui sont gérées dans le code généré.

5. Fonctions de génération de code

Les fonctions `begin_code`, `produce_code`, `end_code` sont responsables de la **traduction de l’AST en code CIL (.il)**
compatible avec le compilateur `ilasm` de .NET.

Par exemple, un `if_else` produit un code comme :

```c
brfalse L1
...
br L2
L1:
...
L2:
nop
```

Chaque structure (arithmétique, logique, conditionnelle, boucle) est traduite en instructions CIL avec sa propre logique d’étiquettes.

6. Fonction `main`

La fonction `main` permet de :

- valider le fichier source (extension `.facile`, nom valide),

- ouvrir le fichier source en lecture et `.il` en écriture,

- lancer le parsing via `yyparse()`,

- libérer la mémoire allouée (table de symboles, fichiers, etc.).

---

## Compilation et exécution

Pour compiler le projet, exécutez les commandes suivantes :

```bash
mkdir build
cd build
cmake ..
make
```

Pour compiler et exécuter un fichier de test, exécutez la commande suivante :

```bash
./facile tests/<test_file>.facile
ilasm <test_file>.il
chmod 777 <test_file>.exe
./<test_file>.exe
```

## Difficultés rencontrées

### facile.lex

Je n'ai pas vraiment eu de soucis pour la création de ce fichier, les explications dans le cahier d'apprentissage
étaient très claires et m'ont permis de comprendre rapidement comment le langage fonctionnait.

### facile.y

- Pas trop de soucis au départ, mais par la suite pour compléter la fonction `produce_code` avec la gestion des nodes de
  l'arbre syntaxique, mais après plusieurs tests, erreurs et débogages, j'ai réussi à comprendre comment cela
  fonctionnait.
- Quelques erreurs de débutant aussi, dans les calculs qui ne prenaient pas la multiplication ou la division avec le bon
  ordre de priorité.

### Génération des fichiers .il

La génération du code CIL a aussi été un vrai défi. Chaque saut conditionnel (les `brfalse`, `brtrue`, etc.) devait être
bien pensé, et la moindre erreur de label pouvait rendre le programme non valide, voire crasher. Quand j’ai attaqué les
boucles avec break et continue, il a fallu que je crée des piles pour gérer les labels de fin ou de reprise de boucle —
ce qui était loin d’être évident au début.

## Tests

- Chaque test est dans un fichier séparé dans le dossier [tests](tests).
- Les fichiers de tests sont au format `.facile` et contiennent le code source du langage Facile.
- Les résultats des tests sont dans le fichier [res.md](tests/res.md).
- Chaque test a été reproduit en python pour vérifier la validité du code généré et du résultat. (le tout en prenant des
  valeurs identiques à celles du langage Facile).
- Dans le fichier [res.md](tests/res.md), vous trouverez les résultats des tests, ainsi que les valeurs d'entrée et de
  sortie.
  - Les valeurs de sorties correspondent aux valeurs affichées par le programme python affin de vérifier la validité
    des résultats du langage Facile.

### Tests d'exercices

- Chaques exercices (à partir de l'exercice 4) a son propre fichier de test.
- Pour l'exercice 8, il faut regarder le code de [essaie 4](tests/essaie4.facile)

### Test d'essai

- Les fichiers d'essai sont des tests plus complexes, qui permettent de tester plusieurs fonctionnalités du langage
  Facile.
1. [essaie 1](tests/essaie1.facile)
   
   - affectation
   - addition
   - soustraction (avec nombre négatif)
   - multiplication
   - affichage

2. [essaie 2](tests/essaie2.facile)
   
   - affectation
   - addition
   - comparaison simple (if/else)
   - boucle while simple
   - affichage

3. [essaie 3](tests/essaie3.facile)
   
   - affectation
   - multiplication
   - addition
   - comparaison imbriguée (if/else)
   - comparaison simple (if/else)
   - boucle while simple
   - affichage

4. [essaie 4](tests/essaie4.facile)
   
   - affectation
   - soustraction
   - boucle while simple
   - comparaison simple (if/else)

## Fonctionnalités prises en charge

Le langage Facile, tel qu'implémenté, permet de gérer :

- Les types de données : `entiers` (positifs/négatifs).
- Les opérations arithmétiques : `+`, `-`, `*`, `/`.
- Les comparaisons : `=`, `!=`, `<`, `>`, `<=`, `>=`.
- Les opérateurs logiques : `and`, `or`, `not`.
- Les structures conditionnelles :
  - `if` simple.
  - `if` avec `else`.
  - `if` avec `elseif` (simples ou en cascade).
  - `if` imbriqués.
- Les boucles :
  - `while` simples.
  - `while` imbriquées.
  - `while` avec `break` et `continue`.
- Les instructions :
  - `read` pour lire une entrée clavier.
  - `print` pour afficher une valeur.
  - `break` et `continue` dans les boucles.

## Pistes d'amélioration

Voici quelques idées d'amélioration possibles :

- Ajouter une gestion des **chaînes de caractères**.
- Implémenter des **fonctions** et la **portée des variables locales/globales**.
- Ajouter une gestion de **tableaux ou structures de données simples**.
- Ajouter un système de **fichiers d’entrée/sortie** en plus de `read`/`print`.
- Générer des **erreurs plus explicites** pour faciliter le debug.
- Implémenter une **analyse sémantique** plus poussée pour éviter les usages incorrects de variables non initialisées.
- Gestion des **boucles for**.

## Répartition du travail / Temps estimé

- Analyse du cahier des charges et mise en place du projet : ~2h
- Implémentation du fichier `facile.lex` (tokens, mots-clés, symboles) : ~3h
- Implémentation de `facile.y` (expressions, instructions simples) : ~2h
- Ajout des structures `if`, `elseif`, `else`, imbriquées : ~5h
- Ajout des boucles `while`, `break`, `continue` + gestion des labels : ~5h
- Tests, essais, corrections et documentation : ~10h

**Temps total estimé : ~27 heures**

## Conclusion

Le projet a été une bonne introduction à la création d'un langage de programmation simple. J'ai appris à utiliser Flex
et Bison pour analyser et générer du code, ainsi qu'à gérer les structures de contrôle de flux. Les défis rencontrés
m'ont permis de mieux comprendre la compilation et l'interprétation des langages de programmation.

---

- MUDET Anthony
- Licence 3e année
- Université de La Rochelle
- Compilation FLEX/BISON
- 2025
- Compte Rendu écrit en Markdown | PDF généré le 11/04/2025

---

## Annexes

### CMakeLists.txt

```cmake
# file: CMakeLists.txt
# version: 0.1.0
cmake_minimum_required(VERSION 4.0)
project(facile VERSION 0.6.0 LANGUAGES C)

# Search for the flex cmake package
find_package(FLEX)
# Definition of a scanner
flex_target(
    FACILE_SCANNER
    facile.lex
    "${CMAKE_CURRENT_BINARY_DIR}/facile.lex.c"
)

# Definition of a parser
find_package(BISON)
bison_target(
    FACILE_PARSER
    facile.y
    "${CMAKE_CURRENT_BINARY_DIR}/facile.y.c"
)

# Add glib
find_package(PkgConfig REQUIRED)
pkg_check_modules(GLIB2 REQUIRED glib-2.0)
include_directories(${GLIB2_INCLUDE_DIRS})
link_directories(${GLIB2_LIBRARY_DIRS})
add_definitions(${GLIB2_CFLAGS_OTHER})

# Define the executable
add_executable(
    facile
    ${FLEX_FACILE_SCANNER_OUTPUTS}
    ${BISON_FACILE_PARSER_OUTPUTS}
)

# Add glib and flex libraries to the "facile" executable
target_link_libraries(facile ${GLIB2_LIBRARIES} fl)

# Add zip generator
set(CPACK_SOURCE_GENERATOR "ZIP")
set(CPACK_SOURCE_IGNORE_FILES "build;~$;${CPACK_SOURCE_IGNORE_FILES}")
set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
include(CPack)
```
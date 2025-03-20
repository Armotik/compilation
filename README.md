# Compilation - Projet

## Objectif

TP et Projet Flex-Bison
Durant les TPs de cette partie, vous allez travailler sur un projet de conception d'un langage dit Facile, veuillez
trouver les détailler dans le cahier d'apprentissage ci-dessous. 

## Structure du projet

```
.
├── build
│   ├── CMakeFiles
│   ├── cmake_install.cmake
│   ├── CMakeCache.txt
│   ├── CPackConfig.cmake
│   ├── CPackSourceConfig.cmake
│   ├── facile
│   ├── facile.lex.c
│   └── Makefile
├── CMakeLists.txt
├── facile.lex
└── README.md
```

- Le dossier [build](build) contient les fichiers générés par CMake lors de la compilation du projet.
- Le fichier [CMakeLists.txt](CMakeLists.txt) contient les instructions de compilation du projet.
- Le fichier [facile.lex](facile.lex) contient les règles de définition des tokens du langage Facile.

## Exercices

### Exercice 1

Ajoutez dans le fichier [facile.lex](facile.lex) les autres mots clés du langage. Nous verrons par la suite
comment gérer les chaines contenant des caractères spéciaux, les identificateurs et les nombres.

Les mots clés rajoutés sont les suivants :
- `read` -> pour lire une valeur à partir de l'entrée standard.
- `print` -> pour afficher une valeur sur la sortie standard.
- `end` -> pour terminer l'exécution du programme.
- `endif` -> pour terminer une condition.
- `else` -> pour gérer le cas où la condition n'est pas vérifiée.
- `elseif` -> pour gérer un autre cas de condition.
- `while` -> pour gérer une boucle.
- `do` -> pour gérer une boucle.
- `endwhile` -> pour terminer une boucle.
- `continue` -> pour passer à l'itération suivante.
- `break` -> pour sortir de la boucle.

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

### Exercice 3

Ajoutez dans le fichier facile.lex l’analyse des nombres tels qu’ils sont définis dans la norme du
langage facile.

Les nombres sont définis comme suit :
-  `0|[1-9][0-9]*` -> pour les nombres entiers.
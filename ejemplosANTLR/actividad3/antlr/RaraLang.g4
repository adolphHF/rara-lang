grammar RaraLang;

// RaraLang — Iteración 1: literales enteros, números en otras bases, strings y print.

prog : stmt* EOF ;

stmt
    : PRINT expr        #printStmt
    | ID ASSIGN expr    #assignStmt
    ;

expr
    : INT           #int
    | BASED_NUMBER  #based
    | STRING        #string
    | ID            #id
    ;

// ─── Keywords ─────────────────────────────────────────────────────────────────

PRINT : 'print' ;
ASSIGN : '<--' ;

// ─── Literales ────────────────────────────────────────────────────────────────

INT         : [0-9]+ ;
BASED_NUMBER : '[' [0-9a-fA-F]+ ':' [0-9]+ ']' ;
STRING      : '"' (~["\r\n])* '"' ;
ID          : [a-zA-Z] [a-zA-Z0-9_]* ;

// ─── Infraestructura ──────────────────────────────────────────────────────────

NEWLINE : [\r\n]+ -> skip ;
COMMENT : '#' ~[\r\n]* -> skip ;
WS      : [ \t]+  -> skip ;

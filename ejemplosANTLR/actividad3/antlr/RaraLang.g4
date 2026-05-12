grammar RaraLang;

// RaraLang — Iteración 1: literales enteros, números en otras bases, strings y print.

prog : stmt* EOF ;

stmt
    : PRINT expr    #printStmt
    ;

expr
    : INT           #int
    | BASED_NUMBER  #based
    | STRING        #string
    ;

// ─── Keywords ─────────────────────────────────────────────────────────────────

PRINT : 'print' ;

// ─── Literales ────────────────────────────────────────────────────────────────

INT         : [0-9]+ ;
BASED_NUMBER : '[' [0-9a-fA-F]+ ':' [0-9]+ ']' ;
STRING      : '"' (~["\r\n])* '"' ;

// ─── Infraestructura ──────────────────────────────────────────────────────────

NEWLINE : [\r\n]+ -> skip ;
COMMENT : '#' ~[\r\n]* -> skip ;
WS      : [ \t]+  -> skip ;

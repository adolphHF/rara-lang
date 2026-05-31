grammar RaraLang;

// RaraLang — Iteración 1: literales enteros, números en otras bases, strings y print.

prog : (funcDecl | stmt)* EOF ;

funcDecl
    : FUNC ID LPAREN paramList? RPAREN blockStmt
    ;

paramList
    : ID (COMMA ID)*
    ;

stmt
    : PRINT expr        #printStmt
    | ID ASSIGN expr    #assignStmt
    | RETURN expr       #returnStmt
    | IF expr THEN stmt (ELSE stmt)? #ifStmt
    | WHILE expr DO stmt #whileStmt
    | blockStmt         #blockAsStmt
    ;

blockStmt
    : LBRACE stmt* RBRACE
    ;

argList
    : expr (COMMA expr)*
    ;

expr
    : compExpr
    ;

compExpr
    : addExpr ((EQ | NEQ | LT | GT) addExpr)?
    ;

addExpr
    : mulExpr ((PLUS | MINUS | DOUBLE_PLUS | AVG) mulExpr)*
    ;

mulExpr
    : unaryExpr ((TIMES | DIVIDE | MOD) unaryExpr)*
    ;

unaryExpr
    : NEG unaryExpr
    | atom
    ;

atom
    : ID LPAREN argList? RPAREN
    | INT
    | BASED_NUMBER
    | STRING
    | ID
    | LPAREN expr RPAREN
    ;

// ─── Keywords ─────────────────────────────────────────────────────────────────

PRINT : 'print' ;
FUNC : 'func' ;
RETURN : 'return' ;
IF : 'if' ;
THEN : 'then' ;
ELSE : 'else' ;
WHILE : 'while' ;
DO : 'do' ;
ASSIGN : '<--' ;
EQ : '==' ;
NEQ : '!=' ;
LT : '<' ;
GT : '>' ;
PLUS : '+' ;
MINUS : '-' ;
TIMES : '×' ;
DIVIDE : '÷' ;
MOD : '⊞' ;
DOUBLE_PLUS : '⊠' ;
AVG : '≈' ;
NEG : '±' ;
LPAREN : '(' ;
RPAREN : ')' ;
COMMA : ',' ;
LBRACE : '{' ;
RBRACE : '}' ;

// ─── Literales ────────────────────────────────────────────────────────────────

INT         : [0-9]+ ;
BASED_NUMBER : '[' [0-9a-fA-F]+ ':' [0-9]+ ']' ;
STRING      : '"' (~["\r\n])* '"' ;
ID          : [a-zA-Z] [a-zA-Z0-9_]* ;

// ─── Infraestructura ──────────────────────────────────────────────────────────

NEWLINE : [\r\n]+ -> skip ;
COMMENT : '#' ~[\r\n]* -> skip ;
WS      : [ \t]+  -> skip ;

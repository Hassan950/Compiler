/* simplest version of calculator */
%{
# include <stdarg.h>
# include "structs.h"

Node *constructOperationNode(int oper, int nops, ...);
Node *constructIdentifierNode(char*, int = -1, int = -1);
Node *constructConstantNode(int, ...);
void freeNode(Node *p);
int exec(Node *p, int = -1, int = -1, int = 0, ...);
int yylex(void);

void yyerror(const char *s);
map<string, int> sym;

#define YYERROR_VERBOSE 1
%}

%union {
  int iValue;                         /* integer value */
  float dValue;                      /* double value */
  char cValue;                        /* char value */
  bool bValue;                        /* boolean value */
  char *sIndex;                        /* symbol table index */
  char *varType;                      /* variable type */
  Node *nPtr;
}

/* declare tokens */
%token <iValue> INTEGER
%token <dValue> FLOAT
%token <cValue> CHAR
%token <bValue> BOOL
%token <sIndex> VARIABLE
%token WHILE FOR IF PRINT REPEAT UNTIL SWITCH CASE DEFAULT BREAK CONTINUE
%token CONST TYPE_INT TYPE_FLOAT TYPE_CHAR TYPE_BOOL
%token SWITCH_BODY
%nonassoc IFX
%nonassoc ELSE

%right '='
%left OR
%left AND
%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%right NOT 
%nonassoc UMINUS

%type <nPtr> stmt single_stmt expr stmt_list rhs
%type <nPtr> declaration opt_declaration assignment opt_assignment
%type <nPtr> switch_body cases default_stmt case_stmt
%type <iValue> type

%%

program: 
  function { exit(0); }
  ;

function:
  function stmt { exec($2); freeNode($2); }
  |
  ;



stmt: 
  ';' { $$ = constructOperationNode(';', 2, NULL, NULL); }
  | expr ';' { $$ = $1; }
  | PRINT expr ';' { $$ = constructOperationNode(PRINT, 1, $2); }
  | declaration ';' { $$ = $1; }
  | WHILE '(' expr ')' stmt { $$ = constructOperationNode(WHILE, 2, $3, $5); }
  | assignment ';' { $$ = $1; }
  | FOR '(' opt_declaration ';' single_stmt ';' opt_assignment ')' stmt { $$ = constructOperationNode(FOR, 4, $3, $5, $7, $9); }
  | IF '(' expr ')' stmt %prec IFX { $$ = constructOperationNode(IF, 2, $3, $5); }
  | IF '(' expr ')' stmt ELSE stmt { $$ = constructOperationNode(IF, 3, $3, $5, $7); }
  | REPEAT stmt_list UNTIL expr ';' { $$ = constructOperationNode(REPEAT, 2, $2, $4); }
  | SWITCH '(' VARIABLE ')' '{' switch_body '}'  { $$ = constructOperationNode(SWITCH, 2, constructIdentifierNode($3), $6); }
  | '{' stmt_list '}' { $$ = $2; }
  | BREAK ';' { $$ = constructOperationNode(BREAK, 1, NULL); }
  | CONTINUE ';' { $$ = constructOperationNode(CONTINUE, 1, NULL); }
  ;

switch_body:
  cases { $$ = constructOperationNode(SWITCH_BODY, 1, $1); }
  | cases default_stmt { $$ = constructOperationNode(SWITCH_BODY, 2, $1, $2); }
  ;

cases:
  CASE INTEGER ':' case_stmt cases { $$ = constructOperationNode(CASE, 3, constructConstantNode(INTEGER, $2), $4, $5); }
  | { $$ = constructOperationNode(';', 2, NULL, NULL); }
  ;

default_stmt:
  DEFAULT ':' case_stmt { $$ = constructOperationNode(DEFAULT, 1, $3); }
  ;

case_stmt: 
  stmt_list { $$ = $1; }
  | { $$ = constructOperationNode(';', 2, NULL, NULL); }
  ;

single_stmt:
  { $$ = constructOperationNode(';', 2, NULL, NULL); }
  | PRINT expr { $$ = constructOperationNode(PRINT, 1, $2); }
  | declaration { $$ = $1; }
  | expr { $$ = $1; }
  ;

assignment: 
  VARIABLE '=' rhs { $$ = constructOperationNode('=', 2, constructIdentifierNode($1), $3); }
  ;

opt_assignment:
  { $$ = constructOperationNode(';', 2, NULL, NULL); }
  | assignment { $$ = $1; }
  ;

declaration:
  type VARIABLE { $$ = constructIdentifierNode($2, 1, $1); }
  | type VARIABLE '=' rhs { $$ = constructOperationNode('=', 2, constructIdentifierNode($2, $1), $4); }
  | CONST type VARIABLE '=' rhs { $$ = constructOperationNode('=', 2, constructIdentifierNode($3, $2, CONST), $5); }
  ;

type: 
  TYPE_INT { $$ = TYPE_INT } 
  | TYPE_FLOAT { $$ = TYPE_FLOAT }
  | TYPE_CHAR { $$ = TYPE_CHAR }
  | TYPE_BOOL { $$ = TYPE_BOOL }
  ;

opt_declaration:
  { $$ = constructOperationNode(';', 2, NULL, NULL); }
  | declaration { $$ = $1; }
  ;

rhs:
  expr { $$ = $1; }
  | VARIABLE '=' rhs { $$ = constructOperationNode('=', 2, constructIdentifierNode($1), $3); }
  | '(' VARIABLE '=' rhs ')' { $$ = constructOperationNode('=', 2, constructIdentifierNode($2), $4); }
  ;

stmt_list:
  stmt { $$ = $1; }
  | stmt_list stmt { $$ = constructOperationNode(';', 2, $1, $2); }
  ;

expr:
  INTEGER { $$ = constructConstantNode(INTEGER, $1); }
  | FLOAT { $$ = constructConstantNode(FLOAT, $1); }
  | CHAR { $$ = constructConstantNode(CHAR, $1); }
  | VARIABLE { $$ = constructIdentifierNode($1); }
  | BOOL { $$ = constructConstantNode(BOOL, $1); }
  | '-' expr %prec UMINUS { $$ = constructOperationNode(UMINUS, 1, $2); }
  | NOT expr { $$ = constructOperationNode(NOT, 1, $2); }
  | expr '+' expr { $$ = constructOperationNode('+', 2, $1, $3); }
  | expr '-' expr { $$ = constructOperationNode('-', 2, $1, $3); }
  | expr '*' expr { $$ = constructOperationNode('*', 2, $1, $3); }
  | expr '/' expr { $$ = constructOperationNode('/', 2, $1, $3); }
  | expr '<' expr { $$ = constructOperationNode('<', 2, $1, $3); }
  | expr '>' expr { $$ = constructOperationNode('>', 2, $1, $3); }
  | expr GE expr { $$ = constructOperationNode(GE, 2, $1, $3); }
  | expr LE expr { $$ = constructOperationNode(LE, 2, $1, $3); }
  | expr NE expr { $$ = constructOperationNode(NE, 2, $1, $3); }
  | expr EQ expr { $$ = constructOperationNode(EQ, 2, $1, $3); }
  | expr AND expr { $$ = constructOperationNode(AND, 2, $1, $3); }
  | expr OR expr { $$ = constructOperationNode(OR, 2, $1, $3); }
  | '(' expr ')' { $$ = $2; }
%%

Node *constructConstantNode(int type, ...) {
  va_list ap;
  Node *p;
  size_t nodeSize;

  /* allocate Node */
  nodeSize = SIZEOF_NODETYPE + sizeof(ConstantNode);
  if ((p = (Node*)malloc(nodeSize)) == NULL)
    yyerror("out of memory");

  /* copy information */
  p->type = CONSTANT;
  p->con.dataType = type;
  va_start(ap, type);
  p->con.value = va_arg(ap, valType);
  va_end(ap);

  return p;
}

Node *constructIdentifierNode(char* i, int dataType, int qualifier) {
  Node *p;
  size_t nodeSize;
  /* allocate Node */
  nodeSize = SIZEOF_NODETYPE + sizeof(IdentifierNode);
  if ((p = (Node*)malloc(nodeSize)) == NULL)
    yyerror("out of memory");

  /* copy information */
  p->type = IDENTIFIER;
  p->id.name = strdup(i);
  p->id.dataType = dataType;
  p->id.qualifier = qualifier;
  return p;
}

Node *constructOperationNode(int oper, int nops, ...) {
  va_list ap;
  Node *p;
  size_t nodeSize;
  int i;
  
  /* allocate Node */
  nodeSize = SIZEOF_NODETYPE + sizeof(OperationNode) +
    (nops - 1) * sizeof(Node*);
  if ((p = (Node*)malloc(nodeSize)) == NULL)
    yyerror("out of memory");

  /* copy information */
  p->type = OPERATION;
  p->opr.symbol = oper;
  p->opr.numberOfOperands = nops;
  va_start(ap, nops);
  for (i = 0; i < nops; i++)
    p->opr.p_operands[i] = va_arg(ap, Node*);
  va_end(ap);
  return p;
}

void freeNode(Node *p) {
  int i;

  if (!p) return;
  if (p->type == OPERATION) {
    for (i = 0; i < p->opr.numberOfOperands; i++)
      freeNode(p->opr.p_operands[i]);
  }
  free (p);
}

void yyerror(const char *s) {
  fprintf(stdout, "%s\n", s);
}
int main(void) {
  yyparse();
  return 0;
}
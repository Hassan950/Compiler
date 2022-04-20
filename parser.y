/* simplest version of calculator */
%{
# include <stdio.h>
# include <stdlib.h>
# include <stdarg.h>
# include "structs.h"

Node *constructOperationNode(int oper, int nops, ...);
Node *constructIdentifierNode(char*);
Node *constructConstantNode(int value);
void freeNode(Node *p);
int exec(Node *p);
int yylex(void);

void yyerror(const char *s);
map<string, int> sym;
%}

%union {
  int iValue;
  char *sIndex;
  Node *nPtr;
}

/* declare tokens */
%token <iValue> INTEGER
%token <sIndex> VARIABLE
%token WHILE FOR IF PRINT
%token CONST VAR
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

%type <nPtr> stmt single_stmt expr stmt_list rhs declaration opt_declaration assignment

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
  | FOR '(' opt_declaration ';' single_stmt ';' assignment ')' stmt { $$ = constructOperationNode(FOR, 4, $3, $5, $7, $9); }
  | IF '(' expr ')' stmt %prec IFX { $$ = constructOperationNode(IF, 2, $3, $5); }
  | IF '(' expr ')' stmt ELSE stmt { $$ = constructOperationNode(IF, 3, $3, $5, $7); }
  | '{' stmt_list '}' { $$ = $2; }
  ;

single_stmt:
  { $$ = constructOperationNode(';', 2, NULL, NULL); }
  | PRINT expr { $$ = constructOperationNode(PRINT, 1, $2); }
  | declaration { $$ = $1; }
  | expr { $$ = $1; }
  ;

assignment: { $$ = constructOperationNode(';', 2, NULL, NULL); }
  | VARIABLE '=' rhs { $$ = constructOperationNode('=', 2, constructIdentifierNode($1), $3); }
  ;

declaration:
  VAR VARIABLE { $$ = constructIdentifierNode($2); }
  | VAR VARIABLE '=' rhs { $$ = constructOperationNode('=', 2, constructIdentifierNode($2), $4); }
  | VARIABLE '=' rhs { $$ = constructOperationNode('=', 2, constructIdentifierNode($1), $3); }
  | CONST VARIABLE '=' rhs { $$ = constructOperationNode('=', 2, constructIdentifierNode($2), $4); }
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
  INTEGER { $$ = constructConstantNode($1); }
  | VARIABLE { $$ = constructIdentifierNode($1); }
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
#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)

Node *constructConstantNode(int value) {
  Node *p;
  size_t nodeSize;

  /* allocate Node */
  nodeSize = SIZEOF_NODETYPE + sizeof(ConstantNode);
  if ((p = (Node*)malloc(nodeSize)) == NULL)
    yyerror("out of memory");

  /* copy information */
  p->type = CONSTANT;
  p->con.value = value;
  return p;
}

Node *constructIdentifierNode(char* i) {
  Node *p;
  size_t nodeSize;
  /* allocate Node */
  nodeSize = SIZEOF_NODETYPE + sizeof(IdentifierNode);
  if ((p = (Node*)malloc(nodeSize)) == NULL)
    yyerror("out of memory");

  /* copy information */
  p->type = IDENTIFIER;
  p->id.name = strdup(i);
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
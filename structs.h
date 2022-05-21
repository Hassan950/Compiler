#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string>
#include <map>
#include <iostream>
using std::map;
using std::string;

#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)

struct valType
{
  union
  {
    int valInt;
    double valFloat;
    bool valBool;
    char valChar;
  };
};

typedef enum
{
  CONSTANT,
  IDENTIFIER,
  OPERATION
} NodeTypes;

/* constants */
typedef struct
{
  valType value; /* value of constant */
  int dataType;  /* type of constant */

} ConstantNode;
/* identifiers */
typedef struct
{
  char *name;
  int dataType;
  int qualifier;
} IdentifierNode;
/* operators */
typedef struct
{
  int symbol;
  int numberOfOperands;
  struct NodeTag *p_operands[1]; /* expandable */
} OperationNode;
typedef struct NodeTag
{
  NodeTypes type; /* type of Node */
  /* union must be last entry in Node */
  /* because OperationNode may dynamically increase */
  union
  {
    ConstantNode con;  /* constants */
    IdentifierNode id; /* identifiers */
    OperationNode opr; /* operators */
  };
} Node;
extern map<string, int> sym;
extern Node *constructConstantNode(int value);
extern void freeNode(Node *p);
extern void yyerror(const char *s);
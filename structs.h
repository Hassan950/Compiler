#include <string.h>
#include <string>
#include <map>
#include <iostream>
using std::map;
using std::string;

typedef enum
{
  CONSTANT,
  IDENTIFIER,
  OPERATION
} NodeTypes;
/* constants */
typedef struct
{
  int value; /* value of constant */
} ConstantNode;
/* identifiers */
typedef struct
{
  char *name;
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
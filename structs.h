#include <string.h>

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
  int operator;
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
extern int sym[1024];
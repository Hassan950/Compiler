#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string>
#include <map>
#include <iostream>
#include <vector>
using std::map;
using std::string;
using std::vector;

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
  char* name;
  int dataType;
  int qualifier;
} IdentifierNode;
/* operators */
typedef struct
{
  int symbol;
  int numberOfOperands;
  struct NodeTag* p_operands[1]; /* expandable */
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

struct SymbolEntry
{
  std::string name;
  int type;               // int, float, ..
  int symbolType; // variable, constant
  int scope;
  int timestamp;
  bool used;
  bool isInitialized;
  SymbolEntry(std::string nm, int ty, int sty, int sc, int ts, bool init)
  {
    name = nm, type = ty, symbolType = sty, scope = sc, timestamp = ts;
    used = false;
    isInitialized = init;
  }
};

static vector<map<string, SymbolEntry*> > sym(1, map<string, SymbolEntry*>());
extern Node* constructConstantNode(int value);
extern void freeNode(Node* p);
extern void yyerror(const char* s);
extern void getUnusedVariables();
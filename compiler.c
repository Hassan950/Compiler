#include <stdio.h>
#include <stdarg.h>
#include <vector>
#include "structs.h"
#include "build/parser.tab.h"

using std::vector;

static int lbl;
Node *constructLabelNode(int value);

int exec(Node *p, int continueLabel = -1, int breakLabel = -1, int args = 0, ...)
{
  va_list ap;
  int lbl1, lbl2, lbl3;
  Node *lblNode;

  vector<Node *> argsVector;
  va_start(ap, args);
  for (int i = 0; i < args; i++)
    argsVector.push_back(va_arg(ap, Node *));
  va_end(ap);

  if (!p)
    return 0;
  switch (p->type)
  {
  case CONSTANT:
    switch (p->con.dataType)
    {
    case INTEGER:
      printf("\tpush\t%d\n", p->con.value.valInt);
      break;
    case CHAR:
      printf("\tpush\t'%c'\n", p->con.value.valChar);
      break;
    case BOOL:
      printf("\tpush\t%s\n", p->con.value.valBool ? "true" : "false");
      break;
    case FLOAT:
      printf("\tpush\t%f\n", p->con.value.valFloat);
      break;
    }
    break;
  case IDENTIFIER:
    printf("\tpush\t%s\n", p->id.name);
    break;
  case OPERATION:
    switch (p->opr.symbol)
    {
    case WHILE:
      printf("L%03d:\n", lbl1 = lbl++);
      exec(p->opr.p_operands[0]); // expression
      printf("\tjz\tL%03d\n", lbl2);
      exec(p->opr.p_operands[1], lbl1, lbl2);
      printf("\tjmp\tL%03d\n", lbl1);
      printf("L%03d:\n", lbl2);
      break;
    case FOR:
      exec(p->opr.p_operands[0]); // declaration / initialization
      printf("L%03d:\n", lbl1 = lbl++);

      exec(p->opr.p_operands[1]);            // expression (condition)
      printf("\tjz\tL%03d\n", lbl2 = lbl++); // if condition not fullfilled jump

      exec(p->opr.p_operands[3], lbl3 = lbl++, lbl2); // statement

      printf("L%03d:\n", lbl3);   // label for continueing
      exec(p->opr.p_operands[2]); // assignment (increment/decrement)
      printf("\tjmp\tL%03d\n", lbl1);
      printf("L%03d:\n", lbl2);
      break;
    case REPEAT:
      printf("L%03d:\n", lbl1 = lbl++);
      exec(p->opr.p_operands[0], lbl1, lbl2 = lbl++);
      exec(p->opr.p_operands[1]);
      printf("\tjz\tL%03d\n", lbl1); // if condition not fullfilled repeat
      printf("L%03d:\n", lbl2);
      break;
    case IF:
      exec(p->opr.p_operands[0]);
      if (p->opr.numberOfOperands > 2)
      {
        /* if else */
        printf("\tjz\tL%03d\n", lbl1 = lbl++);
        exec(p->opr.p_operands[1], continueLabel, breakLabel);
        printf("\tjmp\tL%03d\n", lbl2 = lbl++);
        printf("L%03d:\n", lbl1);
        exec(p->opr.p_operands[2], continueLabel, breakLabel);
        printf("L%03d:\n", lbl2);
      }
      else
      {
        /* if */
        printf("\tjz\tL%03d\n", lbl1 = lbl++);
        exec(p->opr.p_operands[1], continueLabel, breakLabel);
        printf("L%03d:\n", lbl1);
      }
      break;
    case PRINT:
      exec(p->opr.p_operands[0], continueLabel, breakLabel);
      printf("\tprint\n");
      break;
    case '=':
      exec(p->opr.p_operands[1]);
      if (p->opr.p_operands[1]->type == OPERATION && p->opr.p_operands[1]->opr.symbol == '=')
      {
        printf("\tpush\t%s\n", p->opr.p_operands[1]->opr.p_operands[0]->id.name);
      }
      printf("\tpop\t%s\n", p->opr.p_operands[0]->id.name);
      break;
    case UMINUS:
      exec(p->opr.p_operands[0]);
      printf("\tneg\n");
      break;
    case NOT:
      exec(p->opr.p_operands[0]);
      printf("\tnot\n");
      break;
    case SWITCH:
      lbl1 = lbl++;
      exec(p->opr.p_operands[1], -1, lbl1, 1, p->opr.p_operands[0]);
      printf("L%03d:\n", lbl1);
      break;
    case SWITCH_BODY:
      for (int i = 0; i < p->opr.numberOfOperands; i++)
        exec(p->opr.p_operands[i], continueLabel, breakLabel, 1, argsVector[0]);
      break;
    case CASE:
      exec(argsVector[0]);        // the variable
      exec(p->opr.p_operands[0]); // the constant
      printf("\tcompEQ\n");
      printf("\tjz\tL%03d\n", lbl1 = lbl++); // if condition not fullfilled jump
      if (argsVector.size() > 1)             // after-condition label
        printf("L%03d:\n", argsVector[1]->con.value);
      exec(p->opr.p_operands[1], continueLabel, breakLabel); // execute statements
      // exec(p->opr.p_operands[2], continueLabel, breakLabel, 1, argsVector[0]); // break (if exists)
      // skip next conditions until you find break only if there's a next case
      // ow it is the default case
      if (p->opr.p_operands[2]->type == OPERATION && p->opr.p_operands[2]->opr.symbol == CASE)
        printf("\tjmp\tL%03d\n", lbl2 = lbl++);
      printf("L%03d:\n", lbl1); // next case label
      lblNode = constructLabelNode(lbl2);
      exec(p->opr.p_operands[2], continueLabel, breakLabel, 2, argsVector[0], lblNode); // next case
      break;
    case BREAK:
      if (breakLabel == -1)
      {
        yyerror("break outside of loop or switch");
        break;
      }
      printf("\tjmp\tL%03d\n", breakLabel);
      break;
    case CONTINUE:
      if (continueLabel == -1)
      {
        yyerror("continue outside of loop");
        break;
      }
      printf("\tjmp\tL%03d\n", continueLabel);
    case DEFAULT:
      exec(p->opr.p_operands[0], continueLabel, breakLabel);
      break;
    default:
      exec(p->opr.p_operands[0], continueLabel, breakLabel);
      exec(p->opr.p_operands[1], continueLabel, breakLabel);
      switch (p->opr.symbol)
      {
      case '+':
        printf("\tadd\n");
        break;
      case '-':
        printf("\tsub\n");
        break;
      case '*':
        printf("\tmul\n");
        break;
      case '/':
        printf("\tdiv\n");
        break;
      case '<':
        printf("\tcompLT\n");
        break;
      case '>':
        printf("\tcompGT\n");
        break;
      case GE:
        printf("\tcompGE\n");
        break;
      case LE:
        printf("\tcompLE\n");
        break;
      case NE:
        printf("\tcompNE\n");
        break;
      case EQ:
        printf("\tcompEQ\n");
        break;
      case AND:
        printf("\tand\n");
        break;
      case OR:
        printf("\tor\n");
        break;
      }
    }
  }
  return 0;
}

Node *constructLabelNode(int value)
{
  Node *p;
  size_t nodeSize;

  /* allocate Node */
  nodeSize = SIZEOF_NODETYPE + sizeof(ConstantNode);
  if ((p = (Node *)malloc(nodeSize)) == NULL)
    yyerror("out of memory");

  /* copy information */
  p->type = CONSTANT;
  p->con.value.valInt = value;
  return p;
}
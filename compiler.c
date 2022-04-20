#include <stdio.h>
#include "structs.h"
#include "build/parser.tab.h"

static int lbl;

int exec(Node *p)
{
  int lbl1, lbl2;
  if (!p)
    return 0;
  switch (p->type)
  {
  case CONSTANT:
    printf("\tpush\t%d\n", p->con.value);
    break;
  case IDENTIFIER:
    printf("\tpush\t%s\n", p->id.name);
    break;
  case OPERATION:
    switch (p->opr.symbol)
    {
    case WHILE:
      printf("L%03d:\n", lbl1 = lbl++);
      exec(p->opr.p_operands[0]);
      printf("\tjz\tL%03d\n", lbl2 = lbl++);
      exec(p->opr.p_operands[1]);
      printf("\tjmp\tL%03d\n", lbl1);
      printf("L%03d:\n", lbl2);
      break;
    case IF:
      exec(p->opr.p_operands[0]);
      if (p->opr.numberOfOperands > 2)
      {
        /* if else */
        printf("\tjz\tL%03d\n", lbl1 = lbl++);
        exec(p->opr.p_operands[1]);
        printf("\tjmp\tL%03d\n", lbl2 = lbl++);
        printf("L%03d:\n", lbl1);
        exec(p->opr.p_operands[2]);
        printf("L%03d:\n", lbl2);
      }
      else
      {
        /* if */
        printf("\tjz\tL%03d\n", lbl1 = lbl++);
        exec(p->opr.p_operands[1]);
        printf("L%03d:\n", lbl1);
      }
      break;
    case PRINT:
      exec(p->opr.p_operands[0]);
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
    default:
      exec(p->opr.p_operands[0]);
      exec(p->opr.p_operands[1]);
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
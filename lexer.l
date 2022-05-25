%{
# include "structs.h"
# include "parser.tab.h"
%}


%option yylineno

%%

[0-9]+ { 
    /* Integers */
    yylval.iValue = atoi(yytext);
    return INTEGER; 
  }

(0|[1-9][0-9]*)\.[0-9]*  {
    char * tmp = strdup(yytext);
    yylval.dValue = atof(tmp);
    return FLOAT;
  }

"true" {
  return BOOL;
}

"false" {
  return BOOL;
}

[-()<>=+*/;{}.:] { return *yytext; }

">=" { return GE; }
"<=" { return LE; }
"==" { return EQ; } 
"!=" { return NE; }
"and" { return AND; }
"or" { return OR; }
"not" { return NOT; }
"while" { return WHILE; }
"for" { return FOR; }
"if" { return IF; }
"else" { return ELSE; }
"print" { return PRINT; }
"repeat" { return REPEAT; }
"until" { return UNTIL; }
"switch" { return SWITCH; }
"case" { return CASE; }
"default" { return DEFAULT; }
"break" { return BREAK; }
"continue" { return CONTINUE; }

"const" { return CONST; }

"int" {
  return TYPE_INT;
}
"float" {
  return TYPE_FLOAT;
} 
"bool" {
  return TYPE_BOOL;
}

[a-zA-Z_][a-zA-Z0-9_]* { 
    /* variables */
    yylval.sIndex = strdup(yytext);
    return VARIABLE; 
}


[ \t\n]+  { /* ignore whitespace */ }

"//".*/\n { 
    printf("%s\n", yytext);
    yylineno--;
  }
"//".* { printf("%s\n", yytext); }


.      { 
    char msg[1024];
    sprintf(msg, "Unknown character: %s", yytext);
    yyerror(msg);
  }


%%

int yywrap(void) {
  return 1;
}

void yyerror(const char *s) {
  fprintf(stderr, "Line %d: %s\n", yylineno, s);
  exit(0);
}
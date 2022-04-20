%{
# include "structs.h"
# include "parser.tab.h"

int identifiersIndex = 0;
%}


%%

[0-9]+ { 
    /* Integers */
    yylval.iValue = atoi(yytext);
    return INTEGER; 
  }

[-()<>=+*/;{}.] { return *yytext; }

">=" { return GE; }
"<=" { return LE; }
"==" { return EQ; }
"!=" { return NE; }
"while" { return WHILE; }
"if" { return IF; }
"else" { return ELSE; }
"print" { return PRINT; }

"const" { return CONST; }
"var" { return VAR; }
[a-zA-Z_][a-zA-Z0-9_]* { 
    /* variables */
    yylval.sIndex = strdup(yytext);
    return VARIABLE; 
}

[ \t\n]+  { /* ignore whitespace */ }
.      { printf("Mystery character %c\n", *yytext); }
%%

int yywrap(void) {
  return 1;
}
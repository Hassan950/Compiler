%{
# include "structs.h"
# include "parser.tab.h"
%}


%%

[0-9]+ { 
    /* Integers */
    yylval.iValue = atoi(yytext);
    return INTEGER; 
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

"const" { return CONST; }
"var" { return VAR; }
[a-zA-Z_][a-zA-Z0-9_]* { 
    /* variables */
    yylval.sIndex = strdup(yytext);
    sym[yylval.sIndex] = 0;
    return VARIABLE; 
}

[ \t\n]+  { /* ignore whitespace */ }
.      { printf("Mystery character %c\n", *yytext); }
%%

int yywrap(void) {
  return 1;
}
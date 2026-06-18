# Electronic hourglass kit page definition grammar

This folder contains lex and yacc files for electronic hourglass kit pages defintion format.

## Debian Trixie configuration

```bash
sudo mkdir /usr/lib/fpc
sudo ln -s /usr/lib/x86_64-linux-gnu/fpc/lexyacc /usr/lib/fpc/
```

## Generate Pascal parser file
```bash
# Generate lexer
plex pd.l
```

## Generate C parser program

Lets start with lexer defintion below. This lexer outputs the contents of a file and adds line numbers to the beginning of each line.. The file name is passed as a command line argument.

Lexer description is placed in lineno.l file

```flex
%{
    int yylineno;
%}
%%
^(.*)\n printf("%4d\t%s", yylineno++, yytext);
%%
int yywrap(void) {
    return 1;
}

int main(int argc, char *argv[]) {
    yyin = fopen(argv[1], "r");
    yylex();
    fclose(yyin);
}
```

```bash
# Generate lex.yy.c
flex lineno.l 

# Make lexer
gcc lex.yy.c -o lexer
```

And lets test lexer on pd.l as an input file
```bash
./lexer lineno.l
1    %{
   2        int yylineno;
   3    %}
   4    %%
   5    ^(.*)\n printf("%4d\t%s", yylineno++, yytext);
   6    %%
   7    int yywrap(void) {
   8        return 1;
   9    }
  10
  11    int main(int argc, char *argv[]) {
  12        yyin = fopen(argv[1], "r");
  13        yylex();
  14        fclose(yyin);
  15    }
```


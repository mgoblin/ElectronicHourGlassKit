%{
program pd_parser;

uses SysUtils, yacclib, lexlib;

procedure yyerror(s: string);  // Called by yyparse on error <- overload !
begin
  WriteLn(Format('Error: %s', [s]));
end;

%}    

%start led
%token LED

%%

led: LED;

%%

{$include pd_lexer.pas}

begin
  yyparse ();
end.


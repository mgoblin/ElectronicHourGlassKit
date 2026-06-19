%{
program pd_parser;

uses SysUtils, yacclib, lexlib;

procedure yyerror(s: string);  // Called by yyparse on error <- overload !
begin
  WriteLn(Format('Error: %s', [s]));
end;

%}    

%start leds
%token <Integer> LED
%type <Integer> led

%%
leds: led
      | leds '|' led;
      
led: LED { $$ := $1; };

%%

{$include pd_lexer.pas}

begin
  yyparse ();
end.


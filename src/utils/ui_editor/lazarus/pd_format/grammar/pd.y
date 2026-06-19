%{
program pd_parser;

uses SysUtils, yacclib, lexlib;

procedure yyerror(s: string);  // Called by yyparse on error <- overload !
begin
  WriteLn(Format('Error: %s', [s]));
end;

%}    

%start leds

%token <Integer> LED EMPTY_PAGE

%type <Integer> led
%type <Integer> empty

%%
leds: empty
      | led 
      | leds '|' led;
      
led: LED { $$ := $1; };

empty: EMPTY_PAGE;

%%

{$include pd_lexer.pas}

begin
  yyparse ();
end.


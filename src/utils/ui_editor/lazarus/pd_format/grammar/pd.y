%{
program pd_parser;

uses SysUtils, yacclib, lexlib;

procedure yyerror(s: string);  // Called by yyparse on error <- overload !
begin
  WriteLn(Format('Error: %s', [s]));
end;

%}    

%start page

%token <Integer> LED EMPTY_PAGE

%type <Integer> led
%type <Integer> empty

%%
page: page_line
      | page ',' page_line;

page_line: leds | empty;

leds: led 
      | leds '|' led;
      
led: LED { $$ := $1; };

empty: EMPTY_PAGE { $$ := $1; };

%%

{$include pd_lexer.pas}

begin
  yyparse ();
end.


%{
program pd_parser;

uses SysUtils, yacclib, lexlib;

procedure yyerror(s: string);  // Called by yyparse on error <- overload !
begin
  WriteLn(Format('Error: %s', [s]));
end;

%}    

%start start

%token <Integer> LED EMPTY_PAGE

%type <UInt64> led
%type <UInt64> empty

%%
start : pages { Writeln('Done'); yyaccept; }
      ;

pages :   page_line
        | pages ',' page_line
      ;

page_line :   leds 
            | empty
          ;

leds  :   led 
        | leds '|' led
      ;
      
led: LED { if ($1 > 0) and ($1 < 58) then
              begin
                $$ := 1 shl ($1 - 1); 
                WriteLn(Format('L%d value: %d', [$1, $$])); 
              end else
              begin
                yyerror(Format('LED index %d is out of bounds 1..56', [$1]));
              end;  };

empty: EMPTY_PAGE { $$ := $1; WriteLn(Format('EMPTY_PAGE value: %d', [$$])); };

%%

{$include pd_lexer.pas}

begin
  yyparse ();
end.


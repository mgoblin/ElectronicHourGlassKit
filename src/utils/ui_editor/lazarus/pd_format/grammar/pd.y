%{
program pd_parser;

{$mode ObjFPC}
{$inline on}

{$push}
{$WARN 6058 off}

uses SysUtils, yacclib, lexlib, fgl;

type
  TPagesList = class(specialize TFPGList<UInt64>);

var
  PagesList: TPagesList;   

procedure yyerror(s: string);  // Called by yyparse on error <- overload !
begin
  WriteLn(Format('Error: %s', [s]));
end;

%}    

%start start

%token <Integer> LED EMPTY_PAGE

%type <UInt64> led
%type <UInt64> empty
%type <UInt64> leds
%type <UInt64> page_line

%%
start : pages { Writeln('Done'); yyaccept; }
      ;

pages :   page_line             { 
                                  PagesList := TPagesList.Create(); 
                                  PagesList.Add($1);
                                }
        | pages ',' page_line   {  
                                  PagesList.Add($3);
                                }
      ;

page_line :   leds 
            | empty { 
                $$ := $1; 
                WriteLn(Format('Empty LEDs line: %d', [$$])); 
              }
          ;

leds  :   led   { 
                  $$ := $1;
                  WriteLn(Format('One LED line: %d', [$$])); 
                }
        | leds '|' led  
                { 
                  $$ := $1 + $3;
                  WriteLn(Format('Multi LEDs line: %d', [$$])); 
                }
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

var
  i: Integer;
begin
  yyparse ();
  
  WriteLn(Format('%d pages parsed', [PagesList.Count]));
  for i := 0 to PagesList.Count-1 do
  begin
    WriteLn(Format('%d => %d', [i + 1, PagesList[i]]));
  end;
end.


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

function ReadStdin(): String;
var
  FullInput: String;
  Line: String;
begin
  FullInput := '';

  while not EOF do
  begin
    Readln(Line);
    FullInput := FullInput + Line + LineEnding;
  end;
  Result := FullInput;
end;

procedure ParsePages(inputString: String; pages: TPagesList);
const
  fileName: String = 'parse.txt';
var 
  srcText: TextFile;
  i: Integer;
begin
  Assign(srcText, fileName);
  try
    Rewrite(srcText);
    Write(srcText, inputString);
  finally
    CloseFile(srcText);
  end;

  Reset(srcText);

  PagesList := TPagesList.Create();
  try
    yyinput := srcText;
    yyparse ();
    
    for i := 0 to PagesList.Count-1 do
    begin
      pages.Add(PagesList[i]);
    end;
  finally
    FreeAndNil(PagesList);
  end;  
end;

var
  i: Integer;
  inputString: String;
  pages: TPagesList; 
begin
  pages := TPagesList.Create();
  try
    inputString := ReadStdin();
    ParsePages(inputString, pages);
    
    WriteLn(Format('%d pages parsed', [pages.Count]));
    for i := 0 to pages.Count-1 do
    begin
      WriteLn(Format('%d => %d', [i + 1, pages[i]]));
    end;
  finally
    FreeAndNil(pages);
  end;  
end.


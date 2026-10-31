%{
program pd_parser;

{$mode ObjFPC}
{$inline on}

{$push}
{$WARN 6058 off}

uses SysUtils, yacclib, lexlib, fgl;

type
  TPagesList = class(specialize TFPGList<UInt64>);
  UnterminatedBlockCommentException = class(Exception)
  end; 

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
start : pages { Writeln('Done'); }
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
                  $$ := $1 or $3;
                  WriteLn(Format('Multi LEDs line: %d', [$$])); 
                }
      ;
      
led	  : LED { if ($1 > 0) and ($1 < 58) then
              begin
                $$ := UInt64(1) shl ($1 - 1); 
                WriteLn(Format('L%d value: %d', [$1, $$])); 
              end else
              begin
                $$ := 0;
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
  srcWrite, srcRead: TextFile;  
  i: Integer;
begin
 
  Assign(srcWrite, fileName);
  try
    Rewrite(srcWrite);
    Write(srcWrite, inputString);
  finally
    CloseFile(srcWrite);
  end;

 
  Assign(srcRead, fileName);
  try
    Reset(srcRead);
    PagesList := TPagesList.Create();
    try
      yyinput := srcRead;
      yyparse();
      
      if InBlockComment then
        raise UnterminatedBlockCommentException.Create('Unterminated block comment');
      
      for i := 0 to PagesList.Count-1 do
        pages.Add(PagesList[i]);
    finally
      FreeAndNil(PagesList);
    end;
  finally
    // CloseFile(srcRead); <- lexlib close file
  end;
end;

var
  i: Integer;
  inputString: String;
  pages: TPagesList; 
begin
  pages := TPagesList.Create();
  try
	  try
		inputString := ReadStdin();
		ParsePages(inputString, pages);
		
		WriteLn(Format('%d pages parsed', [pages.Count]));
		for i := 0 to pages.Count-1 do
		begin
		  WriteLn(Format('%d => %d', [i + 1, pages[i]]));
		end;
	  except
		on E: UnterminatedBlockCommentException do
		  WriteLn(Format('Error: %s', [E.Message]));
	  end;
  finally
    FreeAndNil(pages);
  end;  
end.


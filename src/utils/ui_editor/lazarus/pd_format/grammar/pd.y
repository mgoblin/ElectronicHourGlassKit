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
  InvalidLedException = class(Exception)
  end;

var
  PagesList: TPagesList;   
  InvalidLedReason: string = '';       // shared with lexer via {$include}
  LineNo: Integer = 1;                 // current line number
  BlockCommentStartLine: Integer = 0;  // line where /* started

procedure yyerror(s: string);  // Called by yyparse on error
begin
  WriteLn(Format('Error at line %d: %s', [LineNo, s]));
end;

// Debug logging — enabled only when compiled with -dDEBUG.
// Kept outside grammar actions because P Yacc does not understand
// {$IFDEF} directives inside { ... } action blocks.
procedure DebugLog(const msg: string);
begin
  {$IFDEF DEBUG}
  WriteLn(msg);
  {$ENDIF}
end;

%}    

%start start

%token <Integer> LED EMPTY_PAGE

%type <UInt64> led
%type <UInt64> empty
%type <UInt64> leds
%type <UInt64> page_line

%%
start : pages { DebugLog('Done'); }
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
                DebugLog(Format('Empty LEDs line: %d', [$$])); 
              }
          ;

leds  :   led   { 
                  $$ := $1;
                  DebugLog(Format('One LED line: %d', [$$])); 
                }
        | leds '|' led  
                { 
                  $$ := $1 or $3;
                  DebugLog(Format('Multi LEDs line: %d', [$$])); 
                }
      ;
      
led   : LED { if $1 >= 1 then
                $$ := UInt64(1) shl ($1 - 1)
              else
                $$ := 0;
            };

empty: EMPTY_PAGE { $$ := $1; DebugLog(Format('EMPTY_PAGE value: %d', [$$])); };

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

function ParsePages(inputString: String; pages: TPagesList): Boolean;
const
  fileName: String = 'parse.txt';
var 
  srcWrite, srcRead: TextFile;  
  i: Integer;
begin
  Result := False;
  InvalidLedReason := '';   // reset before parsing

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
      if yyparse() = 0 then
      begin
        if InvalidLedReason <> '' then
          raise InvalidLedException.Create(InvalidLedReason);
        
        if InBlockComment then
          raise UnterminatedBlockCommentException.Create(
            Format('Line %d: Unterminated block comment', [BlockCommentStartLine]));
        
        for i := 0 to PagesList.Count-1 do
          pages.Add(PagesList[i]);
        
        Result := True;
      end;
    finally
      FreeAndNil(PagesList);
    end;
  finally
    // CloseFile(srcRead); <- lexlib closes yyinput itself
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
      if ParsePages(inputString, pages) then
      begin
        WriteLn(Format('%d pages parsed', [pages.Count]));
        for i := 0 to pages.Count-1 do
        begin
          WriteLn(Format('%d => %d', [i + 1, pages[i]]));
        end;
      end;
    except
      on E: InvalidLedException do
        WriteLn(Format('Error: %s', [E.Message]));
      on E: UnterminatedBlockCommentException do
        WriteLn(Format('Error: %s', [E.Message]));
      on E: Exception do
        WriteLn(Format('Unexpected error (%s): %s', [E.ClassName, E.Message]));
    end;
  finally
    FreeAndNil(pages);
  end;  
end.

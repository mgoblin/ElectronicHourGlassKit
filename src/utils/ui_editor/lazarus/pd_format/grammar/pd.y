%{
unit pd_parser;

{$mode ObjFPC}
{$inline on}

{$push}
{$WARN 6058 off}

interface

uses SysUtils, fgl;

type
  TPagesList = class(specialize TFPGList<UInt64>);
  UnterminatedBlockCommentException = class(Exception)
  end; 
  InvalidLedException = class(Exception)
  end;

function ParsePages(const inputFileName: String; pages: TPagesList): Boolean;

implementation

uses yacclib, lexlib;

type
  TGetCharFunc = function: Char;

var
  PagesList: TPagesList;   
  InvalidLedReason: string = '';       // shared with lexer via {$include}
  LineNo: Integer = 1;                 // current line number
  BlockCommentStartLine: Integer = 0;  // line where /* started
  ParserOriginalGetChar: TGetCharFunc;
  ParserAtEndOfInput: Boolean = False;

function ParserGetChar: Char;
begin
  if ParserAtEndOfInput then
    Exit(#0);
  Result := ParserOriginalGetChar();
  ParserAtEndOfInput := Result = #0;
end;

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

function ParserYyWrap: Boolean;
begin
  Result := True;
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

function ParsePages(const inputFileName: String; pages: TPagesList): Boolean;
var 
  i: Integer;
  PreviousYyWrap: yywrap_t;
begin
  Result := False;
  InvalidLedReason := '';   // reset before parsing

  if not FileExists(inputFileName) then
  begin
    WriteLn(Format('Error: file not found: %s', [inputFileName]));
    Exit;
  end;

  Assign(yyinput, inputFileName);
  Reset(yyinput);
  yyclear;
  LineNo := 1;
  BlockCommentStartLine := 0;
  InBlockComment := False;
  ParserAtEndOfInput := False;
  ParserOriginalGetChar := get_char;
  get_char := @ParserGetChar;
  PreviousYyWrap := yywrap;
  yywrap := @ParserYyWrap;
  try
    PagesList := TPagesList.Create();
    try
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
    try
      CloseFile(yyinput);
    finally
      ParserAtEndOfInput := False;
      get_char := ParserOriginalGetChar;
      yywrap := PreviousYyWrap;
    end;
  end;
end;

end.

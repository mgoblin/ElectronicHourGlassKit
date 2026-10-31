program pd_main;

{$mode ObjFPC}

uses SysUtils, pd_parser;

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
          WriteLn(Format('%d => %d', [i + 1, pages[i]]));
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

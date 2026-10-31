program pd_main;

{$mode ObjFPC}

uses SysUtils, pd_parser;

function ReadStdinToFile(const fileName: String): Boolean;
var
  f: TextFile;
  line: String;
begin
  Result := False;
  Assign(f, fileName);
  try
    Rewrite(f);
    while not EOF do
    begin
      Readln(line);
      WriteLn(f, line);
    end;
    Result := True;
  finally
    CloseFile(f);
  end;
end;

var
  i: Integer;
  pages: TPagesList; 
  inputFileName: String;
  tmpFileName: String;
  useStdin: Boolean;
begin
  useStdin := ParamCount < 1;

  if useStdin then
  begin
    tmpFileName := GetTempFileName('', 'pd_parser_');
    if not ReadStdinToFile(tmpFileName) then
    begin
      WriteLn('Error: cannot read stdin');
      Halt(1);
    end;
    inputFileName := tmpFileName;
  end
  else
    inputFileName := ParamStr(1);

  pages := TPagesList.Create();
  try
    try
      if ParsePages(inputFileName, pages) then
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
    if useStdin then
      DeleteFile(tmpFileName);
  end;  
end.

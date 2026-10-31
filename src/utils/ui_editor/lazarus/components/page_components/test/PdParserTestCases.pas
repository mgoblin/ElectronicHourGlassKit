unit PdParserTestCases;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, pd_parser;

type
  TPdParserTestCase = class(TTestCase)
  private
    FInputFileName: string;
    function ParseInput(const Input: string; Pages: TPagesList): Boolean;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestParseLedList;
    procedure TestParseEmptyPages;
    procedure TestParseCommentsAndWhitespace;
    procedure TestRejectInvalidLedIndex;
    procedure TestRejectIncompletePageList;
  end;

implementation

procedure TPdParserTestCase.SetUp;
begin
  inherited SetUp;
  FInputFileName := GetTempFileName(GetTempDir, 'pd');
end;

procedure TPdParserTestCase.TearDown;
begin
  if FileExists(FInputFileName) then
    DeleteFile(FInputFileName);
  inherited TearDown;
end;

function TPdParserTestCase.ParseInput(const Input: string;
  Pages: TPagesList): Boolean;
var
  InputLines: TStringList;
begin
  InputLines := TStringList.Create;
  try
    InputLines.Text := Input;
    InputLines.SaveToFile(FInputFileName);
  finally
    InputLines.Free;
  end;

  Result := ParsePages(FInputFileName, Pages);
end;

procedure TPdParserTestCase.TestParseLedList;
var
  Pages: TPagesList;
begin
  Pages := TPagesList.Create;
  try
    AssertTrue('A valid LED list should parse', ParseInput('L1|L3,L57', Pages));
    AssertEquals('Two pages should be parsed', 2, Pages.Count);
    AssertEquals('LEDs in a page should combine into bits',
      '5', UIntToStr(Pages[0]));
    AssertEquals('The highest supported LED should map to bit 56',
      '72057594037927936', UIntToStr(Pages[1]));
  finally
    Pages.Free;
  end;
end;

procedure TPdParserTestCase.TestParseEmptyPages;
var
  Pages: TPagesList;
begin
  Pages := TPagesList.Create;
  try
    AssertTrue('EMPTY_PAGE should parse as an empty page',
      ParseInput('EMPTY_PAGE,L2,EMPTY_PAGE', Pages));
    AssertEquals('Three pages should be parsed', 3, Pages.Count);
    AssertEquals('The first page should be empty', '0', UIntToStr(Pages[0]));
    AssertEquals('The middle page should contain LED 2', '2',
      UIntToStr(Pages[1]));
    AssertEquals('The last page should be empty', '0', UIntToStr(Pages[2]));
  finally
    Pages.Free;
  end;
end;

procedure TPdParserTestCase.TestParseCommentsAndWhitespace;
var
  Pages: TPagesList;
begin
  Pages := TPagesList.Create;
  try
    AssertTrue('Comments and whitespace should be ignored',
      ParseInput('  L1 | L2, // line comment' + LineEnding +
        '/* block' + LineEnding + 'comment */ L4', Pages));
    AssertEquals('Two pages should be parsed', 2, Pages.Count);
    AssertEquals('The first page should contain LEDs 1 and 2', '3',
      UIntToStr(Pages[0]));
    AssertEquals('The second page should contain LED 4', '8',
      UIntToStr(Pages[1]));
  finally
    Pages.Free;
  end;
end;

procedure TPdParserTestCase.TestRejectInvalidLedIndex;
var
  Pages: TPagesList;
begin
  Pages := TPagesList.Create;
  try
    try
      ParseInput('L0', Pages);
      Fail('LED index 0 should raise InvalidLedException');
    except
      on E: InvalidLedException do
        ;
    end;

    try
      ParseInput('L58', Pages);
      Fail('LED index 58 should raise InvalidLedException');
    except
      on E: InvalidLedException do
        ;
    end;
  finally
    Pages.Free;
  end;
end;

procedure TPdParserTestCase.TestRejectIncompletePageList;
var
  Pages: TPagesList;
begin
  Pages := TPagesList.Create;
  try
    AssertFalse('A page list ending with a comma should fail to parse',
      ParseInput('L1,', Pages));
    AssertEquals('A failed parse should not append pages', 0, Pages.Count);
  finally
    Pages.Free;
  end;
end;

initialization
  RegisterTest(TPdParserTestCase);
end.

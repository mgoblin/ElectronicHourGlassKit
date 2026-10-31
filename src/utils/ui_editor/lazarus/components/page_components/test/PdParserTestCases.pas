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
    procedure AssertInvalidLed(const Input, ExpectedMessage: string);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestParseLedList;
    procedure TestParseEmptyPages;
    procedure TestParseCommentsAndWhitespace;
    procedure TestParseTrailingComments;
    procedure TestParseLedBoundaries;
    procedure TestRejectInvalidLedIndex;
    procedure TestRejectInvalidLedIndexInPageList;
    procedure TestRejectIncompletePageList;
    procedure TestRejectUnterminatedBlockComment;
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

procedure TPdParserTestCase.AssertInvalidLed(const Input,
  ExpectedMessage: string);
var
  Pages: TPagesList;
begin
  Pages := TPagesList.Create;
  try
    try
      ParseInput(Input, Pages);
      Fail('Invalid LED index should raise InvalidLedException');
    except
      on E: InvalidLedException do
        AssertEquals('The invalid LED should be reported',
          ExpectedMessage, E.Message);
    end;
    AssertEquals('An invalid LED should not append pages', 0, Pages.Count);
  finally
    Pages.Free;
  end;
end;

procedure TPdParserTestCase.TestParseLedList;
var
  Pages: TPagesList;
begin
  Pages := TPagesList.Create;
  try
    AssertTrue('A valid LED list should parse',
      ParseInput('L1|L2,L1,L2', Pages));
    AssertEquals('Three pages should be parsed', 3, Pages.Count);
    AssertEquals('LEDs in a page should combine into bits', '3',
      UIntToStr(Pages[0]));
    AssertEquals('The second page should contain LED 1', '1',
      UIntToStr(Pages[1]));
    AssertEquals('The third page should contain LED 2', '2',
      UIntToStr(Pages[2]));
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

procedure TPdParserTestCase.TestParseTrailingComments;
var
  Pages: TPagesList;
begin
  Pages := TPagesList.Create;
  try
    AssertTrue('A trailing line comment should be ignored',
      ParseInput('L1 // c', Pages));
    AssertEquals('The LED before the line comment should be parsed', '1',
      UIntToStr(Pages[0]));

    Pages.Clear;
    AssertTrue('A trailing block comment should be ignored',
      ParseInput('L1 /* c */', Pages));
    AssertEquals('The LED before the block comment should be parsed', '1',
      UIntToStr(Pages[0]));
  finally
    Pages.Free;
  end;
end;

procedure TPdParserTestCase.TestParseLedBoundaries;
var
  Pages: TPagesList;
begin
  Pages := TPagesList.Create;
  try
    AssertTrue('LED indices 33, 56, and 57 should parse',
      ParseInput('L33,L56,L57', Pages));
    AssertEquals('Three boundary LEDs should be parsed', 3, Pages.Count);
    AssertEquals('LED 33 should map to bit 32', '4294967296',
      UIntToStr(Pages[0]));
    AssertEquals('LED 56 should map to bit 55', '36028797018963968',
      UIntToStr(Pages[1]));
    AssertEquals('LED 57 should map to bit 56', '72057594037927936',
      UIntToStr(Pages[2]));
  finally
    Pages.Free;
  end;
end;

procedure TPdParserTestCase.TestRejectInvalidLedIndex;
begin
  AssertInvalidLed('L0', 'Line 1: LED index out of bounds 1..57: L0');
  AssertInvalidLed('L58', 'Line 1: LED index out of bounds 1..57: L58');
  AssertInvalidLed('L99999999999',
    'Line 1: LED index out of bounds 1..57: L99999999999');
end;

procedure TPdParserTestCase.TestRejectInvalidLedIndexInPageList;
begin
  AssertInvalidLed('L1,L58',
    'Line 1: LED index out of bounds 1..57: L58');
  AssertInvalidLed('L1,L99,L2',
    'Line 1: LED index out of bounds 1..57: L99');
end;

procedure TPdParserTestCase.TestRejectIncompletePageList;
var
  Pages: TPagesList;
  InvalidInputs: array[0..2] of string;
  i: Integer;
begin
  InvalidInputs[0] := 'L1,';
  InvalidInputs[1] := 'L1 L2';
  InvalidInputs[2] := ',L1';

  Pages := TPagesList.Create;
  try
    for i := Low(InvalidInputs) to High(InvalidInputs) do
    begin
      AssertFalse('Malformed page list should fail to parse: ' +
        InvalidInputs[i], ParseInput(InvalidInputs[i], Pages));
      AssertEquals('A failed parse should not append pages', 0, Pages.Count);
    end;
  finally
    Pages.Free;
  end;
end;

procedure TPdParserTestCase.TestRejectUnterminatedBlockComment;
var
  Pages: TPagesList;
begin
  Pages := TPagesList.Create;
  try
    try
      ParseInput('L1' + LineEnding + '/* unfinished', Pages);
      Fail('An unterminated block comment should raise its exception');
    except
      on E: UnterminatedBlockCommentException do
        AssertEquals('The opening line should be reported',
          'Line 2: Unterminated block comment', E.Message);
    end;
    AssertEquals('An invalid input should not append pages', 0, Pages.Count);
  finally
    Pages.Free;
  end;
end;

initialization
  RegisterTest(TPdParserTestCase);
end.

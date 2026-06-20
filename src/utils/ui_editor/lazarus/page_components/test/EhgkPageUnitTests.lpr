program EhgkPageUnitTests;

{$mode objfpc}{$H+}

uses
  Interfaces, SysUtils, Forms, GuiTestRunner,
  EhgkPageTestCases, EhgkPageValuePropertyTestCase,
  EhgkPageLedsIndexedPropertyTestCase, EhgkPagesContainerTestCase;

{$R *.res}
const
  TestsDurationSeconds: Integer = 10;
  ResultFileName: String = 'result.xml';

var
  StartTime: TDateTime;

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
    TestRunner.Show;
  TestRunner.RunExecute(TestRunner);
  TestRunner.XMLSynEdit.Lines.SaveToFile(ResultFileName);

  StartTime := Now;
  while (Now - StartTime) < (TestsDurationSeconds / 86400) do
  begin
    Application.ProcessMessages;  // Keep UI responsive
    Sleep(10);
  end;

  // Programmatically close
  TestRunner.Close;

  // Or force application termination
  Application.Terminate;
end.


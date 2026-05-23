program EhgkPageUnitTests;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, TestCases;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.


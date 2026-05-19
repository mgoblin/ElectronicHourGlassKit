program led_unittests;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner,
  SimplifiedLedConstructorTestCase,
  SimplifiedLedClickTestCase;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.


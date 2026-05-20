program led_unittests;

{$mode objfpc}{$H+}

uses
  Classes, Interfaces, SimplifiedLedClickTestCase, SimplifiedLedConstructorTestCase,
  consoletestrunner, fpcunittestinsight, jsonparser;

type

  { TMyTestRunner }

  TMyTestRunner = class(TTestRunner)
  protected
  // override the protected methods of TTestRunner to customize its behavior
  end;

var
  Application: TMyTestRunner;

begin
  if IsTestInsightListening() then
    RunRegisteredTests('','')
  else
    begin
    DefaultRunAllTests:=True;
    DefaultFormat:=fXML;
    Application := TMyTestRunner.Create(nil);
    Application.Initialize;
    Application.Title := 'FPCUnit Console test runner';
    Application.Run;
    Application.Free;
    end;
end.

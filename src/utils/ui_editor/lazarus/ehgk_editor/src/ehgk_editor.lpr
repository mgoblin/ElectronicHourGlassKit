program ehgk_editor;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Main, DataModule,
  { you can add units after this }
  LazLogger;

{$R *.res}

{$RANGECHECKS ON}

begin
  // Disable standard console output
  DebugLogger.UseStdOut := False;
  // Flush after each write (useful to avoid losing data on crashes)
  DebugLogger.CloseLogFileBetweenWrites := True;

  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  {$PUSH}{$WARN 5044 OFF}
  Application.MainFormOnTaskbar:=True;
  {$POP}
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TMainDataModule, MainDataModule);
  Application.Run;
end.


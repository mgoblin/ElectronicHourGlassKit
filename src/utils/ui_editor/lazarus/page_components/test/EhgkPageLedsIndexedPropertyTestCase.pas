unit EhgkPageLedsIndexedPropertyTestCase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, EhgkPage;

type

  { TEhgkPageLedsIndexedPropertyTestCase }

  TEhgkPageLedsIndexedPropertyTestCase = class(TTestCase)
  protected
    EhgkPage: TEhgkPage;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestReadEmpty;
    procedure TestReadAfterTurnLedOn;
    procedure TestReadAfterTurnOnAllLeds;
  end;

implementation

procedure TEhgkPageLedsIndexedPropertyTestCase.SetUp;
begin
  EhgkPage := TEhgkPage.Create(Nil);
end;

procedure TEhgkPageLedsIndexedPropertyTestCase.TearDown;
begin
  FreeAndNil(EhgkPage);
end;

procedure TEhgkPageLedsIndexedPropertyTestCase.TestReadEmpty;
var
  i: Integer;
begin
  for i := 1 to EhgkPage.LedCount do
  begin
    AssertFalse('On empty value all Leds must be off', EhgkPage.Led[i]);
  end;
end;

procedure TEhgkPageLedsIndexedPropertyTestCase.TestReadAfterTurnLedOn;
begin
  AssertFalse('All leds are turned off after construction', EhgkPage.Led[EhgkPage.LedCount]);
  EhgkPage.TurnOnLed(EhgkPage.LedCount);
  AssertTrue('LED57 must be on after TurnOnLed call' , EhgkPage.Led[EhgkPage.LedCount]);
end;

procedure TEhgkPageLedsIndexedPropertyTestCase.TestReadAfterTurnOnAllLeds;
var
  i: Integer;
begin
  for i := 1 to EhgkPage.LedCount do
  begin
    AssertFalse('All leds are turned off after construction', EhgkPage.Led[EhgkPage.LedCount]);
  end;

  EhgkPage.TurnOnAllLeds;

  for i := 1 to EhgkPage.LedCount do
  begin
    AssertTrue('All leds are turned on after TurnOnAllLeds call', EhgkPage.Led[EhgkPage.LedCount]);
  end;

end;



initialization

  RegisterTest(TEhgkPageLedsIndexedPropertyTestCase);
end.


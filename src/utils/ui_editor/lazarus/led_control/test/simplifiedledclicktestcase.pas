unit SimplifiedLedClickTestCase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, jsonparser, SimplifiedLed;

type
  
  { TSimplifiedLedClickTestCase }

  TSimplifiedLedClickTestCase = class(TTestCase)
  published
    procedure TestCreateAndDblClick;
    procedure TestSetStateOffAndDblClick;
    procedure TestSetStateOnAndDblClick;
    procedure TestDblClickTwice;
  end;


implementation

procedure TSimplifiedLedClickTestCase.TestCreateAndDblClick;
var
  LED: TSimplifiedLed;
begin
     LED := TSimplifiedLed.Create(Nil);
     try
        AssertTrue('Start LED state is led off', LED.State = TLEDState.ledOff);

        LED.DblClick;
        AssertTrue('LED state after dblClick should be led on', LED.State = TLEDState.ledOn);

     finally
       FreeAndNil(LED);
     end;
end;

procedure TSimplifiedLedClickTestCase.TestSetStateOffAndDblClick;
var
  LED: TSimplifiedLed;
begin
     LED := TSimplifiedLed.Create(Nil);
     try
       LED.State := TLEDState.ledOff;
       LED.DblClick;

       AssertTrue('LED state should be toggled after dbl click', LED.State = TLEDState.ledOn);
     finally
       FreeAndNil(LED);
     end;
end;

procedure TSimplifiedLedClickTestCase.TestSetStateOnAndDblClick;
var
   LED: TSimplifiedLed;
begin
     LED := TSimplifiedLed.Create(Nil);
     try
       LED.State := TLEDState.ledOn;
       LED.DblClick;

       AssertTrue('LED state should be toggled after dbl click', LED.State = TLEDState.ledOff);
     finally
       FreeAndNil(LED);
     end;
end;

procedure TSimplifiedLedClickTestCase.TestDblClickTwice;
var
   LED: TSimplifiedLed;
begin
   LED := TSimplifiedLed.Create(Nil);
   try
     LED.DblClick;
     AssertTrue('LED state should be toggled after first dbl click', LED.State = TLEDState.ledOn);

     LED.DblClick;
     AssertTrue('LED state should be toggled back after second dbl click', LED.State = TLEDState.ledOff);
   finally
     FreeAndNil(LED);
   end;
end;

initialization
  RegisterTest(TSimplifiedLedClickTestCase);


end.


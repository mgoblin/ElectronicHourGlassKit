unit SimplifiedLedTestCases;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, jsonparser, SimplifiedLed;

type

  TSimplifiedLedConstructorTestCase = class(TTestCase)
  published
    procedure TestConstructor;
  end;

  { TSimplifiedLedClickTestCase }

  TSimplifiedLedClickTestCase = class(TTestCase)
  protected
    LED: TSimplifiedLed;
    procedure SetUp; override;    // Called before each test
    procedure TearDown; override; // Called after each test
  published
    procedure TestCreateAndDblClick;
    procedure TestSetStateOffAndDblClick;
    procedure TestSetStateOnAndDblClick;
    procedure TestDblClickTwice;
  end;


implementation

procedure TSimplifiedLedConstructorTestCase.TestConstructor;
var
  LED: TSimplifiedLed;
begin
  try
     LED := TSimplifiedLed.Create(Nil);
     try
        AssertEquals(
          'LED control should be created with default width',
          SimplifiedLed.DefaultWidth,
          LED.Width
        );

        AssertEquals(
          'LED control should be created with default heigth',
          SimplifiedLed.DefaultHeight,
          LED.Height
        );

        AssertTrue(
          'LED control should be created in the ledOff state',
          LED.State = TLEDState.ledOff
        );

     finally
       FreeAndNil(LED);
     end;
  except
    on E: Exception do Fail(Format('Exception %s is raised: %s', [E.ClassName, E.Message]));
  end;
end;

procedure TSimplifiedLedClickTestCase.SetUp;
begin
  LED := TSimplifiedLed.Create(Nil);
end;

procedure TSimplifiedLedClickTestCase.TearDown;
begin
  FreeAndNil(LED);
end;

procedure TSimplifiedLedClickTestCase.TestCreateAndDblClick;
begin
  AssertTrue('Start LED state is led off', LED.State = TLEDState.ledOff);

  LED.DblClick;
  AssertTrue('LED state after dblClick should be led on', LED.State = TLEDState.ledOn);
end;

procedure TSimplifiedLedClickTestCase.TestSetStateOffAndDblClick;
begin
   LED.State := TLEDState.ledOff;
   LED.DblClick;

   AssertTrue('LED state should be toggled after dbl click', LED.State = TLEDState.ledOn);
end;

procedure TSimplifiedLedClickTestCase.TestSetStateOnAndDblClick;
begin
   LED.State := TLEDState.ledOn;
   LED.DblClick;

   AssertTrue('LED state should be toggled after dbl click', LED.State = TLEDState.ledOff);
end;

procedure TSimplifiedLedClickTestCase.TestDblClickTwice;
begin
  LED.DblClick;
  AssertTrue('LED state should be toggled after first dbl click', LED.State = TLEDState.ledOn);

  LED.DblClick;
  AssertTrue('LED state should be toggled back after second dbl click', LED.State = TLEDState.ledOff);
end;

initialization
  RegisterTest(TSimplifiedLedClickTestCase);


end.


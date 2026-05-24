unit EhgkPageTestCases;

{$mode objfpc}{$H+}
{$R+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, EhgkPage;

type

  { TCreateEhgkPageTestCase }

  TCreateEhgkPageTestCase = class(TTestCase)
  published
    procedure TestCreate;
  end;

  { TBitsEhgkPageTestCase }

  TBitsEhgkPageTestCase = class(TTestCase)
  protected
    EhgkPage: TEhgkPage;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestLedOn;
    procedure TestLedOff;
    procedure TestLedToggle;
    procedure TestIsLedOn;
    procedure TestLedCount;
    procedure TestTurnAllLedsOn();
    procedure TestTurnAllLedsOff();
  end;

implementation

procedure TCreateEhgkPageTestCase.TestCreate;
var
  EhgkPageLocal: TEhgkPage;
begin
  EhgkPageLocal := TEhgkPage.Create(Nil);
  AssertNotNull('EhgkPage should be not nil after creation', EhgkPageLocal);
end;

{ TBitsEhgkPageTestCase }

procedure TBitsEhgkPageTestCase.SetUp;
begin
  EhgkPage := TEhgkPage.Create(Nil);
end;

procedure TBitsEhgkPageTestCase.TearDown;
begin
  FreeAndNil(EhgkPage);
end;


procedure TBitsEhgkPageTestCase.TestLedOn;
const
  BitIndex: TEhgkLedNumber = 57;
begin
  AssertEquals('Initial value should be equals to 0', 0, EhgkPage.Value);

  EhgkPage.TurnLedOn(1);
  AssertEquals('Value for LED1 should be equals to 1', 1, EhgkPage.Value);

  EhgkPage.TurnLedOn(2);
  AssertEquals('Value for LED1 and LED2 should be equals to 3', 3, EhgkPage.Value);

  EhgkPage.Value := 0;
  EhgkPage.TurnLedOn(BitIndex);
  AssertEquals(
    'Value for LED57 should be equals to maximum',
    QWord($0100000000000000),
    EhgkPage.Value
  );

end;

procedure TBitsEhgkPageTestCase.TestLedOff;
begin
  EhgkPage.Value := 1;
  AssertEquals('Value should be equals to 1', 1, EhgkPage.Value);

  EhgkPage.TurnLedOff(1);
  AssertEquals('Value should be equals to 0 after LED1 off', 0, EhgkPage.Value);

  EhgkPage.TurnLedOn(EHGK_LED_COUNT_MAX);
  EhgkPage.TurnLedOff(EHGK_LED_COUNT_MAX);
  AssertEquals('Value should be equals to 0 after LED1 off', 0, EhgkPage.Value);
end;

procedure TBitsEhgkPageTestCase.TestLedToggle;
begin
  EhgkPage.ToggleLed(3);
  AssertEquals('For LED3 on value should be equals to 4', 4, EhgkPage.Value);
  EhgkPage.ToggleLed(3);
  AssertEquals('For LED3 off value should be equals to 0', 0, EhgkPage.Value);

end;

procedure TBitsEhgkPageTestCase.TestIsLedOn;
const
  LedNumber: TEhgkLedNumber = 5;
begin
  AssertFalse('LED5 should be off', EhgkPage.IsLedOn(LedNumber));

  EhgkPage.ToggleLed(LedNumber);
  AssertTrue('LED5 should be on', EhgkPage.IsLedOn(LedNumber));

  EhgkPage.ToggleLed(LedNumber);
  AssertFalse('LED5 should be on', EhgkPage.IsLedOn(LedNumber));
end;

procedure TBitsEhgkPageTestCase.TestLedCount;
begin
  AssertEquals('LED count must be 57', 57, EhgkPage.LedCount);
end;

procedure TBitsEhgkPageTestCase.TestTurnAllLedsOn();
begin
  AssertEquals('After construction all Leds must be off', 0, EhgkPage.Value);

  EhgkPage.TurnAllLedsOn();
  AssertEquals('After construction all Leds must be on', EHGK_PAGE_VALUE_MAX, EhgkPage.Value);
end;

procedure TBitsEhgkPageTestCase.TestTurnAllLedsOff();
begin
  EhgkPage.TurnAllLedsOn();
  AssertEquals('After construction all Leds must be on', EHGK_PAGE_VALUE_MAX, EhgkPage.Value);

  EhgkPage.TurnAllLedsOff();
  AssertEquals('After TurnAllLedsOff() all Leds must be off', 0, EhgkPage.Value);
end;


initialization

  RegisterTest(TCreateEhgkPageTestCase);
  RegisterTest(TBitsEhgkPageTestCase);
end.


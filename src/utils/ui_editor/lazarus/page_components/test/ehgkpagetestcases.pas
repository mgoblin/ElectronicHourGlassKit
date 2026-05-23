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
    procedure TestLefOff;
    procedure TestLedToggle;
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

  EhgkPage.LedByIndexOn(1);
  AssertEquals('Value for LED1 should be equals to 1', 1, EhgkPage.Value);

  EhgkPage.LedByIndexOn(2);
  AssertEquals('Value for LED1 and LED2 should be equals to 3', 3, EhgkPage.Value);

  EhgkPage.Value := 0;
  EhgkPage.LedByIndexOn(BitIndex);
  AssertEquals(
    'Value for LED57 should be equals to maximum',
    QWord($0100000000000000),
    EhgkPage.Value
  );

end;

procedure TBitsEhgkPageTestCase.TestLefOff;
begin
  EhgkPage.Value := 1;
  AssertEquals('Value should be equals to 1', 1, EhgkPage.Value);

  EhgkPage.LedByIndexOff(1);
  AssertEquals('Value should be equals to 0 after LED1 off', 0, EhgkPage.Value);

  EhgkPage.LedByIndexOn(EhgkLedCountMax);
  EhgkPage.LedByIndexOff(EhgkLedCountMax);
  AssertEquals('Value should be equals to 0 after LED1 off', 0, EhgkPage.Value);
end;

procedure TBitsEhgkPageTestCase.TestLedToggle;
begin
  EhgkPage.LedByIndexToggle(3);
  AssertEquals('For LED3 on value should be equals to 4', 4, EhgkPage.Value);
  EhgkPage.LedByIndexToggle(3);
  AssertEquals('For LED3 off value should be equals to 0', 0, EhgkPage.Value);

end;


initialization

  RegisterTest(TCreateEhgkPageTestCase);
  RegisterTest(TBitsEhgkPageTestCase);
end.


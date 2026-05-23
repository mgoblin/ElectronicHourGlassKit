unit TestCases;

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
  end;

implementation

procedure TCreateEhgkPageTestCase.TestCreate;
var
  EhgkPage: TEhgkPage;
begin
  EhgkPage := TEhgkPage.Create(Nil);
  AssertNotNull('EhgkPage should be not nil after creation', EhgkPage);
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
  BitIndex: TEhgkPageIndex = 57;
begin
  AssertEquals('Initial value should be equals to 0', 0, EhgkPage.Value);

  EhgkPage.Value.LedByIndexOn(1);
  AssertEquals('Value for LED1 should be equals to 1', 1, EhgkPage.Value);

  EhgkPage.Value.LedByIndexOn(2);
  AssertEquals('Value for LED1 and LED2 should be equals to 3', 3, EhgkPage.Value);

  EhgkPage.Value := 0;
  EhgkPage.Value.LedByIndexOn(BitIndex);
  AssertEquals(
    'Value for LED57 should be equals to maximum',
    $0100000000000000,
    EhgkPage.Value
  );
end;


initialization

  RegisterTest(TCreateEhgkPageTestCase);
  RegisterTest(TBitsEhgkPageTestCase);
end.


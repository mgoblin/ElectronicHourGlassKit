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

  { TEqualsAndHashCodeTestCase }

  TEqualsAndHashCodeTestCase = class(TTestCase)
  published
    procedure TestEquals_SameObject;
    procedure TestEquals_Null;
    procedure TestEquals_DifferentType;
    procedure TestEquals_SameValue;
    procedure TestEquals_DifferentValue;
    procedure TestEquals_SelfEquality;
    procedure TestGetHashCode_SameValueSameHash;
    procedure TestGetHashCode_DifferentValueDifferentHash;
    procedure TestGetHashCode_ZeroValue;
    procedure TestGetHashCode_MaxValue;
    procedure TestGetHashCode_NoCollisions;
  end;

implementation

procedure TCreateEhgkPageTestCase.TestCreate;
var
  EhgkPageLocal: TEhgkPage;
begin
  EhgkPageLocal := TEhgkPage.Create(Nil);
  AssertNotNull('EhgkPage should be not nil after creation', EhgkPageLocal);
  FreeAndNil(EhgkPageLocal);
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

  EhgkPage.TurnOnLed(1);
  AssertEquals('Value for LED1 should be equals to 1', 1, EhgkPage.Value);

  EhgkPage.TurnOnLed(2);
  AssertEquals('Value for LED1 and LED2 should be equals to 3', 3, EhgkPage.Value);

  EhgkPage.Value := 0;
  EhgkPage.TurnOnLed(BitIndex);
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

  EhgkPage.TurnOffLed(1);
  AssertEquals('Value should be equals to 0 after LED1 off', 0, EhgkPage.Value);

  EhgkPage.TurnOnLed(EHGK_LED_COUNT_MAX);
  EhgkPage.TurnOffLed(EHGK_LED_COUNT_MAX);
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

  EhgkPage.TurnOnAllLeds();
  AssertEquals('After construction all Leds must be on', EHGK_PAGE_VALUE_MAX, EhgkPage.Value);
end;

procedure TBitsEhgkPageTestCase.TestTurnAllLedsOff();
begin
  EhgkPage.TurnOnAllLeds();
  AssertEquals('After construction all Leds must be on', EHGK_PAGE_VALUE_MAX, EhgkPage.Value);

  EhgkPage.TurnOffAllLeds();
  AssertEquals('After TurnAllLedsOff() all Leds must be off', 0, EhgkPage.Value);
end;


{ TEqualsAndHashCodeTestCase }

procedure TEqualsAndHashCodeTestCase.TestEquals_SameObject;
var
  Page: TEhgkPage;
begin
  Page := TEhgkPage.Create(nil);
  try
    Page.Value := 12345;
    AssertTrue('Equals(Self) must return True', Page.Equals(Page));
  finally
    Page.Free;
  end;
end;

procedure TEqualsAndHashCodeTestCase.TestEquals_Null;
var
  Page: TEhgkPage;
begin
  Page := TEhgkPage.Create(nil);
  try
    AssertFalse('Equals(nil) must return False', Page.Equals(nil));
  finally
    Page.Free;
  end;
end;

procedure TEqualsAndHashCodeTestCase.TestEquals_DifferentType;
var
  Page: TEhgkPage;
  Other: TObject;
begin
  Page := TEhgkPage.Create(nil);
  Other := TObject.Create;
  try
    Page.Value := 999;
    AssertFalse('Equals(different type) must return False', Page.Equals(Other));
  finally
    Page.Free;
    Other.Free;
  end;
end;

procedure TEqualsAndHashCodeTestCase.TestEquals_SameValue;
var
  PageA, PageB: TEhgkPage;
begin
  PageA := TEhgkPage.Create(nil);
  PageB := TEhgkPage.Create(nil);
  try
    PageA.Value := $AABBCCDD;
    PageB.Value := $AABBCCDD;
    AssertTrue('Pages with same Value must be equal', PageA.Equals(PageB));
  finally
    PageA.Free;
    PageB.Free;
  end;
end;

procedure TEqualsAndHashCodeTestCase.TestEquals_DifferentValue;
var
  PageA, PageB: TEhgkPage;
begin
  PageA := TEhgkPage.Create(nil);
  PageB := TEhgkPage.Create(nil);
  try
    PageA.Value := $11111111;
    PageB.Value := $22222222;
    AssertFalse('Pages with different Value must not be equal', PageA.Equals(PageB));
  finally
    PageA.Free;
    PageB.Free;
  end;
end;

procedure TEqualsAndHashCodeTestCase.TestEquals_SelfEquality;
var
  Page: TEhgkPage;
begin
  Page := TEhgkPage.Create(nil);
  try
    Page.Value := 0;
    AssertTrue('Value=0: Equals(Self) must return True', Page.Equals(Page));

    Page.Value := EHGK_PAGE_VALUE_MAX;
    AssertTrue('Value=MAX: Equals(Self) must return True', Page.Equals(Page));
  finally
    Page.Free;
  end;
end;

procedure TEqualsAndHashCodeTestCase.TestGetHashCode_SameValueSameHash;
var
  PageA, PageB: TEhgkPage;
begin
  PageA := TEhgkPage.Create(nil);
  PageB := TEhgkPage.Create(nil);
  try
    PageA.Value := $DEADBEEF;
    PageB.Value := $DEADBEEF;
    AssertEquals(
      'Equal pages must have equal hashes',
      PageA.GetHashCode,
      PageB.GetHashCode
    );
  finally
    PageA.Free;
    PageB.Free;
  end;
end;

procedure TEqualsAndHashCodeTestCase.TestGetHashCode_DifferentValueDifferentHash;
var
  PageA, PageB: TEhgkPage;
begin
  PageA := TEhgkPage.Create(nil);
  PageB := TEhgkPage.Create(nil);
  try
    PageA.Value := 1;
    PageB.Value := 2;
    AssertFalse(
      'Different values must produce different hashes',
      PageA.GetHashCode = PageB.GetHashCode
    );
  finally
    PageA.Free;
    PageB.Free;
  end;
end;

procedure TEqualsAndHashCodeTestCase.TestGetHashCode_ZeroValue;
var
  Page: TEhgkPage;
begin
  Page := TEhgkPage.Create(nil);
  try
    Page.Value := 0;
    AssertEquals('Hash of Value=0 must be 0', 0, Page.GetHashCode);
  finally
    Page.Free;
  end;
end;

procedure TEqualsAndHashCodeTestCase.TestGetHashCode_MaxValue;
var
  Page: TEhgkPage;
begin
  Page := TEhgkPage.Create(nil);
  try
    Page.Value := EHGK_PAGE_VALUE_MAX;
    AssertEquals(
      'Hash of Value=MAX must equal the Value',
      PtrInt(EHGK_PAGE_VALUE_MAX),
      Page.GetHashCode
    );
  finally
    Page.Free;
  end;
end;

procedure TEqualsAndHashCodeTestCase.TestGetHashCode_NoCollisions;
var
  PageA, PageB: TEhgkPage;
  V1, V2: TEhgkPageValue;
begin
  PageA := TEhgkPage.Create(nil);
  PageB := TEhgkPage.Create(nil);
  try
    // Test several value pairs to verify no collisions
    V1 := 0;
    V2 := 1;
    PageA.Value := V1;
    PageB.Value := V2;
    AssertFalse('No collision: 0 vs 1', PageA.GetHashCode = PageB.GetHashCode);

    V1 := $FF;
    V2 := $100;
    PageA.Value := V1;
    PageB.Value := V2;
    AssertFalse('No collision: $FF vs $100', PageA.GetHashCode = PageB.GetHashCode);

    V1 := $FFFFFFFF;
    V2 := $100000000;
    PageA.Value := V1;
    PageB.Value := V2;
    AssertFalse('No collision: high bits', PageA.GetHashCode = PageB.GetHashCode);

    V1 := EHGK_PAGE_VALUE_MAX;
    V2 := EHGK_PAGE_VALUE_MAX - 1;
    PageA.Value := V1;
    PageB.Value := V2;
    AssertFalse('No collision: MAX vs MAX-1', PageA.GetHashCode = PageB.GetHashCode);
  finally
    PageA.Free;
    PageB.Free;
  end;
end;

initialization

  RegisterTest(TCreateEhgkPageTestCase);
  RegisterTest(TBitsEhgkPageTestCase);
  RegisterTest(TEqualsAndHashCodeTestCase);
end.


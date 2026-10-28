unit SimplifiedLedTestCases;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, jsonparser, SimplifiedLed,
  LCLType, Controls;

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

  { TSimplifiedLedEditableTestCase }

  TSimplifiedLedEditableTestCase = class(TTestCase)
  protected
    LED: TSimplifiedLed;
    procedure SetUp; override;    // Called before each test
    procedure TearDown; override; // Called after each test
  published
    procedure TestEditableDefaultsToTrue;
    procedure TestDblClickWithEditableTrue;
    procedure TestDblClickWithEditableFalse;
    procedure TestKeyDownSpaceWithEditableTrue;
    procedure TestKeyDownSpaceWithEditableFalse;
    procedure TestKeyDownOtherKeyIgnored;
  end;

  { TSimplifiedLedAccess — friend class to access protected KeyDown }

  TSimplifiedLedAccess = class(TSimplifiedLed)
  public
    procedure TestKeyDown(var Key: Word; Shift: TShiftState);
  end;

implementation

{ TSimplifiedLedAccess }

procedure TSimplifiedLedAccess.TestKeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
end;

procedure TSimplifiedLedConstructorTestCase.TestConstructor;
var
  LED: TSimplifiedLed;
begin
  try
     LED := TSimplifiedLed.Create(Nil);
     try
        AssertEquals(
          'LED control should be created with default width',
          SimplifiedLed.DefaultW,
          LED.Width
        );

        AssertEquals(
          'LED control should be created with default heigth',
          SimplifiedLed.DefaultH,
          LED.Height
        );

        AssertTrue(
          'LED control should be created in the ledOff state',
          LED.State = TLEDState.lsOff
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
  AssertTrue('Start LED state is led off', LED.State = TLEDState.lsOff);

  LED.DblClick;
  AssertTrue('LED state after dblClick should be led on', LED.State = TLEDState.lsOn);
end;

procedure TSimplifiedLedClickTestCase.TestSetStateOffAndDblClick;
begin
   LED.State := TLEDState.lsOff;
   LED.DblClick;

   AssertTrue('LED state should be toggled after dbl click', LED.State = TLEDState.lsOn);
end;

procedure TSimplifiedLedClickTestCase.TestSetStateOnAndDblClick;
begin
   LED.State := TLEDState.lsOn;
   LED.DblClick;

   AssertTrue('LED state should be toggled after dbl click', LED.State = TLEDState.lsOff);
end;

procedure TSimplifiedLedClickTestCase.TestDblClickTwice;
begin
  LED.DblClick;
  AssertTrue('LED state should be toggled after first dbl click', LED.State = TLEDState.lsOn);

  LED.DblClick;
  AssertTrue('LED state should be toggled back after second dbl click', LED.State = TLEDState.lsOff);
end;

procedure TSimplifiedLedEditableTestCase.SetUp;
begin
  LED := TSimplifiedLed.Create(Nil);
end;

procedure TSimplifiedLedEditableTestCase.TearDown;
begin
  FreeAndNil(LED);
end;

procedure TSimplifiedLedEditableTestCase.TestEditableDefaultsToTrue;
begin
  AssertTrue('Editable property should default to True', LED.Editable);
end;

procedure TSimplifiedLedEditableTestCase.TestDblClickWithEditableTrue;
begin
  LED.Editable := True;
  LED.State := lsOff;

  LED.DblClick;
  AssertTrue('LED should toggle on double-click when Editable=True', LED.State = lsOn);
end;

procedure TSimplifiedLedEditableTestCase.TestDblClickWithEditableFalse;
begin
  LED.Editable := False;
  LED.State := lsOff;

  LED.DblClick;
  AssertTrue('LED should NOT toggle on double-click when Editable=False', LED.State = lsOff);
end;

procedure TSimplifiedLedEditableTestCase.TestKeyDownSpaceWithEditableTrue;
var
  LedAccess: TSimplifiedLedAccess;
  Key: Word;
begin
  LedAccess := TSimplifiedLedAccess.Create(Nil);
  try
    LedAccess.Editable := True;
    LedAccess.State := lsOff;
    Key := VK_SPACE;

    LedAccess.TestKeyDown(Key, []);
    AssertTrue('LED should toggle on Space when Editable=True', LedAccess.State = lsOn);
  finally
    LedAccess.Free;
  end;
end;

procedure TSimplifiedLedEditableTestCase.TestKeyDownSpaceWithEditableFalse;
var
  LedAccess: TSimplifiedLedAccess;
  Key: Word;
begin
  LedAccess := TSimplifiedLedAccess.Create(Nil);
  try
    LedAccess.Editable := False;
    LedAccess.State := lsOff;
    Key := VK_SPACE;

    LedAccess.TestKeyDown(Key, []);
    AssertTrue('LED should NOT toggle on Space when Editable=False', LedAccess.State = lsOff);
  finally
    LedAccess.Free;
  end;
end;

procedure TSimplifiedLedEditableTestCase.TestKeyDownOtherKeyIgnored;
var
  LedAccess: TSimplifiedLedAccess;
  Key: Word;
begin
  LedAccess := TSimplifiedLedAccess.Create(Nil);
  try
    LedAccess.Editable := True;
    LedAccess.State := lsOff;
    Key := Ord('A');

    LedAccess.TestKeyDown(Key, []);
    AssertTrue('LED should NOT toggle on non-Space key', LedAccess.State = lsOff);
  finally
    LedAccess.Free;
  end;
end;

initialization
  RegisterTest(TSimplifiedLedConstructorTestCase);
  RegisterTest(TSimplifiedLedClickTestCase);
  RegisterTest(TSimplifiedLedEditableTestCase);


end.

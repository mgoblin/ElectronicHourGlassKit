{
 Electronic hourglass kit page (Ehgk) components unit.

 An electronic hourglass is a simple electronic device you can assemble yourself.
 It contains 57 LEDs located on a circuit board LED count can not be changed
 due to circuit board design.

 The LEDs are sequentially switched on and off according to the firmware.
 The state of all the LEDs is called a Page.

 This unit implements page components.
}
unit EhgkPage;


{$mode ObjFPC}{$H+}

{$R+}

interface

uses
  Classes, SysUtils, PropEdits;

const

  { Circuit board LED count }
  EHGK_LED_COUNT_MAX = 57;

  { Maximum value: all 57 LEDs are turned on }
  EHGK_PAGE_VALUE_MAX = $01FFFFFFFFFFFFFF; // 57 ones: 2^57 - 1

type

  { LEDs on circuit board enumerated from 1 to 57 }
  TEhgkLedNumber = 1..EHGK_LED_COUNT_MAX;

  { LED 1 corresponds to bit 0 (LSB), LED 57 to bit 56 — total 57 bits }
  TEhgkPageValue = 0..EHGK_PAGE_VALUE_MAX;

  { The state of all the LEDs is called a EhgkPage }

  {
   Represents the state of all 57 LEDs on the electronic hourglass circuit board.
   Each LED corresponds to one bit in the Value property (LED 1 = bit 0, LED 57 = bit 56).
   Provides methods to manipulate individual LEDs or all LEDs at once.
  }
  TEhgkPage = class(TComponent)
  private
    FValue: TEhgkPageValue;
    FOnChange: TNotifyEvent;

    procedure SetValue(const AValue: TEhgkPageValue);
    procedure SetLedState(const Index: TEhgkLedNumber; AValue: Boolean);
    function LedMask(const Index: TEhgkLedNumber): UInt64; inline;

  protected
    procedure DoOnChange; virtual;

  public
    { Total number of LEDs on the circuit board }
    const LedCount = EHGK_LED_COUNT_MAX;
    { Creates an instance of TEhgkPage with initial Value set to 0 (all LEDs off) }
    constructor Create(AOwner: TComponent); override;

    { Compares this page with another object. Returns True if the other object is a TEhgkPage
      with the same LED state (Value). Owner, name, and other TComponent fields are ignored. }
    function Equals(Obj: TObject): Boolean; override;
    { Returns the current LED state (Value) as the hash code. Two equal pages always have the same hash. }
    function GetHashCode: PtrInt; override;

    { Turns on the LED at the specified index (1..57) }
    procedure TurnOnLed(const Index: TEhgkLedNumber);
    { Turns off the LED at the specified index (1..57) }
    procedure TurnOffLed(const Index: TEhgkLedNumber);
    { Toggles the state of the LED at the specified index (1..57): on becomes off, off becomes on }
    procedure ToggleLed(const Index: TEhgkLedNumber);
    { Returns True if the LED at the specified index (1..57) is currently turned on }
    function IsLedOn(const Index: TEhgkLedNumber): Boolean;
    { Turns on all 57 LEDs on the circuit board }
    procedure TurnOnAllLeds;
    { Turns off all 57 LEDs on the circuit board }
    procedure TurnOffAllLeds;

    property Led[Index: TEhgkLedNumber]: Boolean read IsLedOn write SetLedState;

  published // Properties
    property Value: TEhgkPageValue read FValue write SetValue;

  published // Events
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  {
   TEhgkPageValuePropertyEditor can not be created in fpcunit environment.
   Validation logic moved to this class for unit testing purposes.
  }
  TEhgkValueValidator = class(TObject)
  public
    class function IsValid(const AValue: String): Boolean;
  end;

  TEhgkPageValuePropertyEditor = class(TQWordPropertyEditor)
  public
    procedure SetValue(const NewValue: String);  override;
  end;

procedure Register;

implementation

uses TypInfo, RtlConsts, LResources;

procedure Register;
begin
  RegisterComponents('EHGK',[TEhgkPage]);
  RegisterPropertyEditor(TypeInfo(TEhgkPageValue), TEhgkPage, 'Value', TEhgkPageValuePropertyEditor);
end;


{ TEhgkPage }

constructor TEhgkPage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FValue := 0;
end;

// Two pages are equal if they have the same LED state (Value).
// Owner, name, and other TComponent fields are not considered.
function TEhgkPage.Equals(Obj: TObject): Boolean;
begin
  if Obj = Self then
    Exit(True);
  if not (Obj is TEhgkPage) then
    Exit(False);
  Result := FValue = TEhgkPage(Obj).FValue;
end;

function TEhgkPage.GetHashCode: PtrInt;
begin
  Result := PtrInt(FValue);
end;

procedure TEhgkPage.SetValue(const AValue: TEhgkPageValue);
begin
  if AValue > EHGK_PAGE_VALUE_MAX then
    raise ERangeError.CreateResFmt(@SOutOfRange, [0, EHGK_PAGE_VALUE_MAX]);

  if (FValue <> AValue) then
  begin
    FValue := AValue;
    DoOnChange;
  end;
end;

function TEhgkPage.LedMask(const Index: TEhgkLedNumber): UInt64; inline;
begin
  Result := (UInt64(1) shl (Index - 1));
end;

procedure TEhgkPage.DoOnChange;
begin
  if Assigned(FOnChange) then
  begin
    FOnChange(Self);
  end;
end;

procedure TEhgkPage.SetLedState(const Index: TEhgkLedNumber; AValue: Boolean);
begin
  if AValue then
  begin
    SetValue(FValue or LedMask(Index));
  end
  else
  begin
    SetValue(FValue and not LedMask(Index));
  end;
end;

procedure TEhgkPage.TurnOnLed(const Index: TEhgkLedNumber);
begin
  SetValue(FValue or LedMask(Index));
end;

procedure TEhgkPage.TurnOffLed(const Index: TEhgkLedNumber);
begin
  SetValue(FValue and not LedMask(Index));
end;

procedure TEhgkPage.ToggleLed(const Index: TEhgkLedNumber);
begin
  SetValue(FValue xor LedMask(Index));
end;

function TEhgkPage.IsLedOn(const Index: TEhgkLedNumber): Boolean;
begin
  Result := (FValue and LedMask(Index)) <> 0;
end;

procedure TEhgkPage.TurnOnAllLeds;
begin
  SetValue(EHGK_PAGE_VALUE_MAX);
end;

procedure TEhgkPage.TurnOffAllLeds;
begin
  SetValue(0);
end;

{ TEhgkValueValidator }

class function TEhgkValueValidator.IsValid(const AValue: String): Boolean;
var
  Trimmed: String;
  Value: UInt64;
begin
  Trimmed := Trim(AValue);
  if Trimmed = '' then Exit(False);
  if not TryStrToUInt64(Trimmed, Value) then Exit(False);
  Result := Value <= EHGK_PAGE_VALUE_MAX;
end;

{ TEhgkPageValuePropertyEditor }

procedure TEhgkPageValuePropertyEditor.SetValue(const NewValue: String);
begin
    if TEhgkValueValidator.IsValid(NewValue) then
    begin
      inherited SetValue(NewValue);
    end else
    begin
       raise EPropertyError.CreateResFmt(@SOutOfRange, [0, EHGK_PAGE_VALUE_MAX]);
    end;
end;

initialization
  {$I ehgkpage.lrs}

end.

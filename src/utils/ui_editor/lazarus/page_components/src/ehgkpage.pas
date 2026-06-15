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
  EHGK_PAGE_VALUE_MAX = $01FFFFFFFFFFFFFFF; // 57 ones in binary

type

  { LEDs on circuit board enumerated from 1 to 57 }
  TEhgkLedNumber = 1..EHGK_LED_COUNT_MAX;

  { LED 1 corresponds to bit 0 (LSB), LED 57 to bit 56 — total 57 bits }
  TEhgkPageValue = 0..EHGK_PAGE_VALUE_MAX;

  { The state of all the LEDs is called a EhgkPage }

  { TEhgkPage }

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
    const LedCount = EHGK_LED_COUNT_MAX;
    constructor Create(AOwner: TComponent); override;

    procedure TurnOnLed(const Index: TEhgkLedNumber);
    procedure TurnOffLed(const Index: TEhgkLedNumber);
    procedure ToggleLed(const Index: TEhgkLedNumber);
    function IsLedOn(const Index: TEhgkLedNumber): Boolean;
    procedure TurnOnAllLeds;
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

uses TypInfo, RtlConsts;

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

end.

{
 Electronic hourglass kit page (Ehgk) components unit.

 An electronic hourglass is a simple electronic device you can assemble yourself.
 It contains 57 LEDs located on a circuit board.
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

  // Electrical houglass kit has 57 LEDs on circuit board
  EHGK_LED_COUNT_MAX = 57;

  { Maximum value: all 57 LEDs on → (1 shl 57) - 1 }
  EHGK_PAGE_VALUE_MAX = (UInt64(1) shl EHGK_LED_COUNT_MAX) - 1;

type

  { Represents LED numbers in range 1..57 }
  TEhgkLedNumber = 1..EHGK_LED_COUNT_MAX;

  { The on/off state of the LEDs is encoded in the positional value of the bit }
  TEhgkPageValue = 0..EHGK_PAGE_VALUE_MAX;

  { TEhgkPage represents 57 LEDs on/off state }

  TEhgkPage = class(TComponent)
  private
    FValue: TEhgkPageValue;
    function GetLedCount: Integer;
    procedure SetLed(Index: TEhgkLedNumber; AValue: Boolean);

  public
    procedure TurnOnLed(const Index: TEhgkLedNumber);
    procedure TurnOffLed(const Index: TEhgkLedNumber);
    procedure ToggleLed(const Index: TEhgkLedNumber);
    function IsLedOn(const Index: TEhgkLedNumber): Boolean;
    procedure TurnOnAllLeds;
    procedure TurnOffAllLeds;

    property LedCount: Integer read GetLedCount stored False default EHGK_LED_COUNT_MAX;
    property Led[Index: TEhgkLedNumber]: Boolean read IsLedOn write SetLed;

  published
    property Value: TEhgkPageValue read FValue write FValue;
  end;

  TEhgkValueValidator = class(TObject)
  public
    class function IsValid(const AValue: ansistring): Boolean;
  end;

  TEhgkPageValuePropertyEditor = class(TQWordPropertyEditor)
  public
    procedure SetValue(const NewValue: ansistring);  override;
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

function TEhgkPage.GetLedCount: Integer;
begin
  Result := EHGK_LED_COUNT_MAX;
end;

procedure TEhgkPage.SetLed(Index: TEhgkLedNumber; AValue: Boolean);
begin
  if AValue <> IsLedOn(Index) then
  begin
    if AValue then TurnOnLed(Index) else TurnOffLed(Index);
  end;
end;

procedure TEhgkPage.TurnOnLed(const Index: TEhgkLedNumber);
begin
  FValue := FValue or (UInt64(1) shl (Index - 1));
end;

procedure TEhgkPage.TurnOffLed(const Index: TEhgkLedNumber);
begin
  FValue := FValue and not (UInt64(1) shl (Index - 1));
end;

procedure TEhgkPage.ToggleLed(const Index: TEhgkLedNumber);
begin
  FValue := FValue xor (UInt64(1) shl (Index - 1));
end;

function TEhgkPage.IsLedOn(const Index: TEhgkLedNumber): Boolean;
begin
  Result := (FValue and (UInt64(1) shl (Index - 1))) <> 0;
end;

procedure TEhgkPage.TurnOnAllLeds();
begin
  FValue := EHGK_PAGE_VALUE_MAX;
end;

procedure TEhgkPage.TurnOffAllLeds();
begin
  FValue := 0;
end;

{ TEhgkValueValidator }

class function TEhgkValueValidator.IsValid(const AValue: ansistring): Boolean;
var
  Value: UInt64;
begin
    try
       Value := StrToUInt64(AValue);
       Result := Value <= EHGK_PAGE_VALUE_MAX;
    except
      on E: Exception do
         Result := False;
    end;
end;

{ TEhgkPageValuePropertyEditor }

procedure TEhgkPageValuePropertyEditor.SetValue(const NewValue: ansistring);
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

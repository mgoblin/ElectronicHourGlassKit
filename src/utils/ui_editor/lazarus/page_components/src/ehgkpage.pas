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

  { Maximum value: all 57 LEDs are turned on → (1 shl 57) - 1 }
  EHGK_PAGE_VALUE_MAX = (UInt64(1) shl EHGK_LED_COUNT_MAX) - 1;

type

  { LEDs on circuit board enumerated from 1 to 57 }
  TEhgkLedNumber = 1..EHGK_LED_COUNT_MAX;

  { The on/off state of the LEDs is encoded in the positional value of the bit }
  TEhgkPageValue = 0..EHGK_PAGE_VALUE_MAX;

  { The state of all the LEDs is called a EhgkPage }

  TEhgkPage = class(TComponent)
  private
    FValue: TEhgkPageValue;
    procedure SetValue(const AValue: TEhgkPageValue);

    function GetLedCount: Integer;
    procedure SetLedState(const Index: TEhgkLedNumber; AValue: Boolean);

    function LedMask(const Index: TEhgkLedNumber): UInt64; inline;

  public
    constructor Create(AOwner: TComponent); override;

    procedure TurnOnLed(const Index: TEhgkLedNumber);
    procedure TurnOffLed(const Index: TEhgkLedNumber);
    procedure ToggleLed(const Index: TEhgkLedNumber);
    function IsLedOn(const Index: TEhgkLedNumber): Boolean;
    procedure TurnOnAllLeds;
    procedure TurnOffAllLeds;

    property LedCount: Integer read GetLedCount stored False default EHGK_LED_COUNT_MAX;
    property Led[Index: TEhgkLedNumber]: Boolean read IsLedOn write SetLedState;

  published
    property Value: TEhgkPageValue read FValue write SetValue;
  end;

  { Separated only for propery editor value validation testability purposes }
  TEhgkValueValidator = class(TObject)
  public
    class function IsValid(const AValue: String): Boolean;
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

constructor TEhgkPage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FValue := 0;
end;

procedure TEhgkPage.SetValue(const AValue: TEhgkPageValue);
begin
  if AValue > EHGK_PAGE_VALUE_MAX then
    raise ERangeError.Create('Value exceeds maximum allowed LED pattern');

  FValue := AValue;
end;

function TEhgkPage.GetLedCount: Integer;
begin
  Result := EHGK_LED_COUNT_MAX;
end;

procedure TEhgkPage.SetLedState(const Index: TEhgkLedNumber; AValue: Boolean);
begin
  if AValue then TurnOnLed(Index) else TurnOffLed(Index);
end;

function TEhgkPage.LedMask(const Index: TEhgkLedNumber): UInt64; inline;
begin
  Result := (UInt64(1) shl (Index - 1));
end;

procedure TEhgkPage.TurnOnLed(const Index: TEhgkLedNumber);
begin
  FValue := FValue or LedMask(Index);
end;

procedure TEhgkPage.TurnOffLed(const Index: TEhgkLedNumber);
begin
  FValue := FValue and not LedMask(Index);
end;

procedure TEhgkPage.ToggleLed(const Index: TEhgkLedNumber);
begin
  FValue := FValue xor LedMask(Index);
end;

function TEhgkPage.IsLedOn(const Index: TEhgkLedNumber): Boolean;
begin
  Result := (FValue and LedMask(Index)) <> 0;
end;

procedure TEhgkPage.TurnOnAllLeds;
begin
  FValue := EHGK_PAGE_VALUE_MAX;
end;

procedure TEhgkPage.TurnOffAllLeds;
begin
  FValue := 0;
end;

{ TEhgkValueValidator }

class function TEhgkValueValidator.IsValid(const AValue: ansistring): Boolean;
begin
    try
       Result := StrToUInt64(AValue) <= EHGK_PAGE_VALUE_MAX;
    except
      on EConvertError do Exit(False);
      on ERangeError do Exit(False);
      on EOverflow do Exit(False);
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

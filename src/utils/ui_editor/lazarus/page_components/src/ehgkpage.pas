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
{$modeswitch typehelpers}
{$R+}

interface

uses
  Classes, SysUtils, Dialogs, PropEdits;

const

  EHGK_LED_COUNT_MAX = 57;
  EHGK_PAGE_VALUE_MAX = (UInt64(1) shl EHGK_LED_COUNT_MAX) - 1;

type

  { LED numbers in range 1..57 }
  TEhgkLedNumber = 1..EHGK_LED_COUNT_MAX;

  { The on/off state of the LEDs is encoded in the positional value of the bit }
  TEhgkPageValue = 0..EHGK_PAGE_VALUE_MAX;

  { TEhgkPage describes 57 LEDs on/off state }

  TEhgkPage = class(TComponent)
  private
    FValue: TEhgkPageValue;
    function GetLedCount: Integer;
  public
    procedure TurnLedOn(const Index: TEhgkLedNumber);
    procedure TurnLedOff(const Index: TEhgkLedNumber);
    procedure ToggleLed(const Index: TEhgkLedNumber);
    function IsLedOn(const Index: TEhgkLedNumber): Boolean;
    procedure TurnAllLedsOn();
    procedure TurnAllLedsOff();

    property LedCount: Integer read GetLedCount;

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

procedure TEhgkPage.TurnLedOn(const Index: TEhgkLedNumber);
begin
  FValue := UInt64(FValue).SetBit(Index - 1);
end;

procedure TEhgkPage.TurnLedOff(const Index: TEhgkLedNumber);
begin
  FValue := UInt64(FValue).ClearBit(Index - 1);
end;

procedure TEhgkPage.ToggleLed(const Index: TEhgkLedNumber);
begin
  FValue := UInt64(FValue).ToggleBit(Index - 1);
end;

function TEhgkPage.IsLedOn(const Index: TEhgkLedNumber): Boolean;
begin
  Result := UInt64(FValue).TestBit(Index - 1);
end;

procedure TEhgkPage.TurnAllLedsOn();
begin
  FValue := EHGK_PAGE_VALUE_MAX;
end;

procedure TEhgkPage.TurnAllLedsOff();
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
       Result := Value < EHGK_PAGE_VALUE_MAX + 1;
    except
      on E: EConvertError do
         Result := False;
    end;
end;

{ TEhgkPageValuePropertyEditor }

procedure TEhgkPageValuePropertyEditor.SetValue(const NewValue: ansistring);

  procedure Error(const Args: array of const);
  begin
    raise EPropertyError.CreateResFmt(@SOutOfRange, Args);
  end;

begin
    if TEhgkValueValidator.IsValid(NewValue) then
    begin
      inherited SetValue(NewValue);
    end
    else
    begin
       raise EPropertyError.CreateResFmt(@SOutOfRange, [QWord.MinValue, EHGK_PAGE_VALUE_MAX]);
    end;
end;

end.

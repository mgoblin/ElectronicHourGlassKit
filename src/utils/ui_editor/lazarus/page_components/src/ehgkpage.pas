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

  { Describes 57 LEDs on/off state }

  { TEhgkPage }

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

    property LedCount: Integer read GetLedCount;

  published
    property Value: TEhgkPageValue read FValue write FValue;
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

{ TEhgkPageValuePropertyEditor }

procedure TEhgkPageValuePropertyEditor.SetValue(const NewValue: ansistring);

  procedure Error(const Args: array of const);
  begin
    raise EPropertyError.CreateResFmt(@SOutOfRange, Args);
  end;

var
  L: UInt64;
begin
    if (not TryStrToUInt64(NewValue, L)) or (L > EHGK_PAGE_VALUE_MAX) then
    begin
      Error([QWord.MinValue, EHGK_PAGE_VALUE_MAX]);
    end
    else
    begin
       inherited SetValue(NewValue);
    end;
end;

end.

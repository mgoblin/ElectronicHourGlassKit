unit EhgkPage;

{$mode ObjFPC}{$H+}
{$modeswitch typehelpers}
{$R+}

interface

uses
  Classes, SysUtils, Dialogs, PropEdits;

const
  EhgkLedCountMax = 57;
  EGHK_MAX_PAGE_VALUE = $01FFFFFFFFFFFFFF;

type

  TEhgkLedNumber = 1..EhgkLedCountMax;
  TEhgkPageValue = 0..EGHK_MAX_PAGE_VALUE;

  { TEhgkPage }

  TEhgkPage = class(TComponent)
  private
    FValue: TEhgkPageValue;

  public
    procedure LedByIndexOn(const Index: TEhgkLedNumber);
    procedure LedByIndexOff(const Index: TEhgkLedNumber);
    procedure LedByIndexToggle(const Index: TEhgkLedNumber);

  published
    property Value: TEhgkPageValue read FValue write FValue;
  end;

  { TEhgkPageValuePropertyEditor }

  TEhgkPageValuePropertyEditor = class(TIntegerPropertyEditor)
  public
    function OrdValueToVisualValue(OrdValue: longint): string; override;
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

procedure TEhgkPage.LedByIndexOn(const Index: TEhgkLedNumber);
var
  val: UInt64;
begin
  val := FValue;
  FValue := val.SetBit(Index - 1);
end;

procedure TEhgkPage.LedByIndexOff(const Index: TEhgkLedNumber);
var
  val: UInt64;
begin
  val := FValue;
  FValue := val.ClearBit(Index - 1);
end;

procedure TEhgkPage.LedByIndexToggle(const Index: TEhgkLedNumber);
var
  val: UInt64;
begin
  val := FValue;
  FValue := val.ToggleBit(Index - 1);
end;

{ TEhgkPage }

{ TEhgkPageValuePropertyEditor }

function TEhgkPageValuePropertyEditor.OrdValueToVisualValue(OrdValue: longint): string;
begin
  Result:= UIntToStr(QWord(OrdValue));
end;

procedure TEhgkPageValuePropertyEditor.SetValue(const NewValue: ansistring);

  procedure Error(const Args: array of const);
  begin
    raise EPropertyError.CreateResFmt(@SOutOfRange, Args);
  end;

var
  L: UInt64;
begin
  with GetTypeData(GetPropType)^ do
    if TryStrToUInt64(NewValue, L) and not ((L < MinQWordValue) or (L > EGHK_MAX_PAGE_VALUE)) then
    begin
       SetOrdValue(UInt64(L));
    end else
    begin
       Error([MinQWordValue, EGHK_MAX_PAGE_VALUE]);
       Exit;
    end;
end;

end.

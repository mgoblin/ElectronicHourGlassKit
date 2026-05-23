unit EhgkPage;

{$mode ObjFPC}{$H+}
{$modeswitch typehelpers}
{$R+}

interface

uses
  Classes, SysUtils, Dialogs, PropEdits;

const
  EhgkLedCountMax = 57;
  EhgkPageValueMax = $01FFFFFFFFFFFFFF;

type

  TEhgkLedNumber = 1..EhgkLedCountMax;
  TEhgkPageValue = 0..EhgkPageValueMax;

  { TEhgkPage }

  TEhgkPage = class(TComponent)
  private
    FValue: TEhgkPageValue;
    procedure SetValue(AValue: TEhgkPageValue);

  public
    procedure LedByIndexOn(const Index: TEhgkLedNumber);
    procedure LedByIndexOff(const Index: TEhgkLedNumber);
    procedure LedByIndexToggle(const Index: TEhgkLedNumber);

  published
    property Value: TEhgkPageValue read FValue write SetValue;
  end;

  TEhgkPageValuePropertyEditor = class(TIntegerPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('EHGK',[TEhgkPage]);
  RegisterPropertyEditor(TypeInfo(TEhgkPageValue), TEhgkPage, 'Value', TEhgkPageValuePropertyEditor);
end;



procedure TEhgkPage.SetValue(AValue: TEhgkPageValue);
begin
  if AValue = FValue then Exit;

  FValue := AValue;
end;

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

{ TEhgkPageValuePropertyEditor }

procedure TEhgkPageValuePropertyEditor.Edit;
var
  NewValue: String;
begin
  // Create a simple input dialog
  NewValue := GetValue;

  if InputQuery('Edit Page Value', 'Enter value (0..$01FFFFFFFFFFFFFF)', NewValue) then
     SetValue(NewValue);
end;

function TEhgkPageValuePropertyEditor.GetAttributes: TPropertyAttributes;
begin
  // paDialog shows the "..." button
  Result := [paDialog];
end;

end.

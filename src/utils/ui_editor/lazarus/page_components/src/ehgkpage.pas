unit EhgkPage;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type

  EIndexOutOfBounds = class(Exception);

  { TEhgkPage }

  TEhgkPage = class(TComponent)
  private
    FValue: UInt64;
    function GetLed(Index: UInt8): Boolean;
    procedure SetLed(Index: UInt8; AValue: Boolean);
  protected
    procedure SetValueBit(BitIndex: UInt8); inline;
    procedure ClearValueBit(BitIndex: UInt8); inline;
    function IsValueBitSet(BitIndex: UInt8): Boolean; inline;

  public
    property LED[Index: UInt8]: Boolean read GetLed write SetLed;

  published
    property Value: UInt64 read FValue write FValue;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('EHGK',[TEhgkPage]);
end;

{ TEhgkPage }

procedure TEhgkPage.SetValueBit(BitIndex: UInt8);
begin
  FValue := FValue or (1 shl BitIndex);
end;

procedure TEhgkPage.ClearValueBit(BitIndex: UInt8);
begin
  FValue := FValue and not (1 shl BitIndex);
end;

function TEhgkPage.IsValueBitSet(BitIndex: UInt8): Boolean;
begin
  Result := (FValue or (1 shl BitIndex)) <> 0;
end;

function TEhgkPage.GetLed(Index: UInt8): Boolean;
begin
  {TODO Implement me}
  Result := False;
end;

procedure TEhgkPage.SetLed(Index: UInt8; AValue: Boolean);
begin
  if (Index < 1) or (Index > 57) then
     raise EIndexOutOfBounds.CreateFmt('Index %d is out of bounds [1..57]', [Index]);

  if AValue then
  begin
    SetValueBit(Index - 1);
  end
  else
  begin
    ClearValueBit(Index - 1);
  end;
end;

end.

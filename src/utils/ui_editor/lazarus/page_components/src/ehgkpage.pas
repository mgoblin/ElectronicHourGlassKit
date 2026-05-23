unit EhgkPage;

{$mode ObjFPC}{$H+}
{$modeswitch typehelpers}{$R+}

interface

uses
  Classes, SysUtils;

const
  EhgkLedCountMax = 57;
  EhgkPageValueMax = $01FFFFFFFFFFFFFF;

type

  EIndexOutOfBounds = class(Exception);

  TEhgkPageIndex = 1..EhgkLedCountMax;
  TEhgkPageValue = 0..EhgkPageValueMax;

  { TEhgkPageValueHelper }

  TEhgkPageValueHelper = Type Helper for TEhgkPageValue
  public
    function LedByIndexOn(const Index: TEhgkPageIndex): TEhgkPageValue;
  end;

  { TEhgkPage }

  TEhgkPage = class(TComponent)
  private
    FValue: TEhgkPageValue;

  published
    property Value: TEhgkPageValue read FValue write FValue;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('EHGK',[TEhgkPage]);
end;

{ TEhgkPageValueHelper }

function TEhgkPageValueHelper.LedByIndexOn(const Index: TEhgkPageIndex): TEhgkPageValue; inline;
begin
     Result := UInt64(Self).SetBit(Index - 1);
end;

{ TEhgkPageValueHelper }

{ TEhgkPage }


{ TEhgkPage }

end.

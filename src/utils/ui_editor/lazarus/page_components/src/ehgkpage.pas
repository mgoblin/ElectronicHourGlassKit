unit EhgkPage;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  Led = (
      LED1 = 0,
      LED2 = 1,
      LED3 = 2
  );
  LedSet = Set of LED;

  TEhgkPage = class(TComponent)
  private
    FLEDs: LedSet;
  protected

  public

  published
    property LEDS: LedSet read FLEDs write FLEDs;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('EHGK',[TEhgkPage]);
end;

end.

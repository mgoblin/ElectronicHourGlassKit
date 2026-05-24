unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SimplifiedLed, Forms, Controls, Graphics, Dialogs,
  StdCtrls;

type

  { TMainForm }

  TMainForm = class(TForm)
    Button1: TButton;
    LED29: TSimplifiedLed;
    LED30: TSimplifiedLed;
    LED31: TSimplifiedLed;
    LED32: TSimplifiedLed;
    LED33: TSimplifiedLed;
    LED34: TSimplifiedLed;
    LED35: TSimplifiedLed;
    LED36: TSimplifiedLed;
    LED37: TSimplifiedLed;
    LED38: TSimplifiedLed;
    LED39: TSimplifiedLed;
    LED40: TSimplifiedLed;
    LED41: TSimplifiedLed;
    LED42: TSimplifiedLed;
    LED43: TSimplifiedLed;
    LED44: TSimplifiedLed;
    LED45: TSimplifiedLed;
    LED46: TSimplifiedLed;
    LED47: TSimplifiedLed;
    LED48: TSimplifiedLed;
    LED49: TSimplifiedLed;
    LED50: TSimplifiedLed;
    LED51: TSimplifiedLed;
    LED52: TSimplifiedLed;
    LED53: TSimplifiedLed;
    LED54: TSimplifiedLed;
    LED55: TSimplifiedLed;
    LED56: TSimplifiedLed;
    LED57: TSimplifiedLed;
    LED8: TSimplifiedLed;
    LED17: TSimplifiedLed;
    LED18: TSimplifiedLed;
    LED19: TSimplifiedLed;
    LED20: TSimplifiedLed;
    LED21: TSimplifiedLed;
    LED22: TSimplifiedLed;
    LED23: TSimplifiedLed;
    LED24: TSimplifiedLed;
    LED25: TSimplifiedLed;
    LED26: TSimplifiedLed;
    LED9: TSimplifiedLed;
    LED27: TSimplifiedLed;
    LED28: TSimplifiedLed;
    LED1: TSimplifiedLed;
    LED2: TSimplifiedLed;
    LED3: TSimplifiedLed;
    LED4: TSimplifiedLed;
    LED5: TSimplifiedLed;
    LED6: TSimplifiedLed;
    LED7: TSimplifiedLed;
    LED10: TSimplifiedLed;
    LED11: TSimplifiedLed;
    LED12: TSimplifiedLed;
    LED13: TSimplifiedLed;
    LED14: TSimplifiedLed;
    LED15: TSimplifiedLed;
    LED16: TSimplifiedLed;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  DataModule;

{ TMainForm }


procedure TMainForm.Button1Click(Sender: TObject);
  function BoolToLedState(Value: Boolean): TLedState;
  begin
    if Value then Result:= TLEDState.ledOn else Result:= TLEDState.ledOff;
  end;

var
  i: Integer;
  LED: TComponent;
begin
  for i := 1 to DataModule.MainDataModule.EhgkPage1.LedCount do
  begin
    LED := MainForm.FindComponent(Format('LED%u', [i]));
    if LED <> Nil then
    begin
      (LED as TSimplifiedLed).State := BoolToLedState(DataModule.MainDataModule.EhgkPage1.IsLedOn(i));
    end;
  end;
end;

end.


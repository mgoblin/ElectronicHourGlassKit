unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SimplifiedLed, Forms, Controls, Graphics, Dialogs,
  StdCtrls, DataModule;

type

  { TMainForm }

  TMainForm = class(TForm)
    ButtonView: TButton;
    EditPageValue: TEdit;
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
    procedure ButtonViewClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure LoadFromContainer;

  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  EhgkPage;

{ TMainForm }

procedure TMainForm.ButtonViewClick(Sender: TObject);
var
  PageValue: TEhgkPageValue;
begin
  if Trim(EditPageValue.Text) = '' then
  begin
    ShowMessage('Enter the number');
  end
  else
  begin
    try
      PageValue := TEhgkPageValue(StrToUInt64(EditPageValue.Text));
      MainDataModule.PageContainer.Page[0].Value := PageValue;
      LoadFromContainer;
    except
      on E: EConvertError do
      begin
        ShowMessage('Error: ' + E.Message);
      end;
    end;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  MainDataModule.PageContainer.Page[0].Value := 127;
  EditPageValue.Text := UIntToStr(MainDataModule.PageContainer.Page[0].Value);
  LoadFromContainer;
end;

procedure TMainForm.LoadFromContainer;
const
  NamePrefix = 'LED';
var
  LedNumber: Cardinal;
  Component: TComponent;
  Led: TSimplifiedLed;
  Page: TEhgkPage;
begin
  Page := MainDataModule.PageContainer.Page[0];
  for LedNumber in [1 .. EHGK_LED_COUNT_MAX] do
  begin
    Component := FindComponent(Format('%s%u', [NamePrefix, LedNumber]));
    if Component is TSimplifiedLed then
    begin
      Led := Component as TSimplifiedLed;
      if Page.IsLedOn(LedNumber) then
      begin
        Led.State := TLEDState.ledOn;
      end
      else
      begin
        Led.State := TLEDState.ledOff;
      end;
    end;
  end;
end;

end.


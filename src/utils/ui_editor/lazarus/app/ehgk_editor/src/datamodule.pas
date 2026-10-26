unit DataModule;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, LazSerial, EhgkPage, EhgkPageContainer;

type

  { TMainDataModule }

  TMainDataModule = class(TDataModule)
    LazSerial1: TLazSerial;
    PageContainer: TEhgkPageNavigatableContainer;
    procedure LazSerial1RxData(Sender: TObject);
  private

  public

  end;

var
  MainDataModule: TMainDataModule;

implementation

{$R *.lfm}

{ TMainDataModule }

procedure TMainDataModule.LazSerial1RxData(Sender: TObject);
begin
  ShowMessage(LazSerial1.ReadData);
end;

end.


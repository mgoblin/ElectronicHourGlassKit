unit DataModule;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, EhgkPage;

type

  { TMainDataModule }

  TMainDataModule = class(TDataModule)
    EhgkPage1: TEhgkPage;
    procedure EhgkPage1Change(Sender: TObject);
  private

  public

  end;

var
  MainDataModule: TMainDataModule;

implementation

{$R *.lfm}

{ TMainDataModule }

procedure TMainDataModule.EhgkPage1Change(Sender: TObject);
begin
     ShowMessage('Page changed');
end;

end.


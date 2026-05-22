unit DataModule;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, EhgkPage;

type

  { TMainDataModule }

  TMainDataModule = class(TDataModule)
    EhgkPage1: TEhgkPage;
  private

  public

  end;

var
  MainDataModule: TMainDataModule;

implementation

{$R *.lfm}

end.


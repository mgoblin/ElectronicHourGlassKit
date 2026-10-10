unit DataModule;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, EhgkPage, EhgkPageContainer;

type

  { TMainDataModule }

  TMainDataModule = class(TDataModule)
    PageContainer: TEhgkPageNavigatableContainer;
  private

  public

  end;

var
  MainDataModule: TMainDataModule;

implementation

{$R *.lfm}

{ TMainDataModule }

end.


unit EhgkPagesContainer;

{$mode ObjFPC}{$H+}
{$inline on}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, fgl, EhgkPage;

type
  TEhgkPagesList = specialize TFPGObjectList<TEhgkPage>;

  TEmptyContainerError = class(Exception);

  { TEhgkPagesContainer }

  TEhgkPagesContainer = class(TComponent)
  private
    FPagesList: TEhgkPagesList;
    function GetPageByIndex(Index: UInt8): TEhgkPage;

  protected

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function Count: Integer;

    function Add: Integer;
    procedure Delete(Index: Integer);

    property Page[Index: UInt8]: TEhgkPage read GetPageByIndex;
  published

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('EHGK',[TEhgkPagesContainer]);
end;

{ TEhgkPagesContainer }

function TEhgkPagesContainer.GetPageByIndex(Index: UInt8): TEhgkPage;
begin
  Result := FPagesList.Items[Index];
end;

constructor TEhgkPagesContainer.Create(AOwner: TComponent);
var
  EhgkPage: TEhgkPage;
begin
  inherited Create(AOwner);
  FPagesList := TEhgkPagesList.Create();

  // FPageList is responsible for destruction of its items.
  // Container is not direct owner of pages
  EhgkPage := TEhgkPage.Create(Nil);
  FPagesList.Add(EhgkPage);
end;

destructor TEhgkPagesContainer.Destroy;
begin
  FreeAndNil(FPagesList);
  inherited Destroy;
end;

function TEhgkPagesContainer.Count: Integer;
begin
  Result := FPagesList.Count;
end;

function TEhgkPagesContainer.Add: Integer;
begin
  Result := FPagesList.Add(TEhgkPage.Create(Nil));
end;

procedure TEhgkPagesContainer.Delete(Index: Integer);
begin
  if (FPagesList.Count = 1) and (Index = 0) then
  begin
    raise TEmptyContainerError.CreateFmt('Container %s can not be empty', [Self.Name]);
  end;
  FPagesList.Delete(Index);

end;

initialization
  {$I ehgkpagescontainer.lrs}

end.

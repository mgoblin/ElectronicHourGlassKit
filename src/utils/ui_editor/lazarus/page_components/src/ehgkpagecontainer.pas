{
 Electronic hourglass kit pages container (Ehgk) components unit.

 An electronic hourglass is a simple electronic device you can assemble yourself.
 It contains 57 LEDs located on a circuit board LED count can not be changed
 due to circuit board design.
 LED is drived by microcontroller (STC15W201 or STC15W2024)

 Page is LEDs state description.

 Pages container manage sequence of pages. Pages container size is limtited by
 microcontroller EEPROM size. Pages container can hold 256 pages maximum.
}
unit EhgkPageContainer;

{$mode ObjFPC}{$H+}

{$inline on}

// Suppress warning:
// procedure or function marked with the inline directive cannot actually be inlined
{$warn 6058 off}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, fgl, EhgkPage;

type
  TEhgkPagesList = specialize TFPGObjectList<TEhgkPage>;

  TContainerEmptyError = class(Exception);
  TContainerFullError = class(Exception);


  { TEhgkPagesContainer }

  TEhgkPagesContainer = class(TComponent)
  private
    FPagesList: TEhgkPagesList;
    function GetPageByIndex(Index: UInt8): TEhgkPage;

  protected

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function Count: UInt8; inline;

    function Add: UInt8; inline;
    procedure Delete(Index: UInt8); inline;

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

  // FPagesList own pages and responsible for free containing objectss
  FPagesList := TEhgkPagesList.Create(True);

  EhgkPage := TEhgkPage.Create(Nil);
  FPagesList.Add(EhgkPage);
end;

destructor TEhgkPagesContainer.Destroy;
begin
  FreeAndNil(FPagesList);
  inherited Destroy;
end;

function TEhgkPagesContainer.Count: UInt8; inline;
begin
  Result := FPagesList.Count;
end;

function TEhgkPagesContainer.Add: UInt8; inline;
begin
  if FPagesList.Count < UInt8.MaxValue then
  begin
    Result := FPagesList.Add(TEhgkPage.Create(Nil));
  end
  else
  begin
    raise TContainerFullError.CreateFmt('Container %s is full', [Self.Name]);
  end;
end;

procedure TEhgkPagesContainer.Delete(Index: UInt8); inline;
begin
  if (FPagesList.Count = 1) and (Index = 0) then
  begin
    raise TContainerEmptyError.CreateFmt('Container %s can not be empty', [Self.Name]);
  end;
  FPagesList.Delete(Index);

end;

initialization
  {$I ehgkpagecontainer.lrs}

end.

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

// Suppress warning:
// procedure or function marked with the inline directive cannot actually be inlined
{$warn 6058 off}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, fgl, EhgkPage;

type
  TEhgkPageList = specialize TFPGObjectList<TEhgkPage>;

  TContainerEmptyError = class(Exception);
  TContainerFullError = class(Exception);
  TContainerIndexOutOfBounds = class(Exception);


  { TEhgkPageContainer }

  TEhgkPageContainer = class(TComponent)
  private
    FPagesList: TEhgkPageList;
    procedure EnsureIndexIsValid(Index: UInt8);
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

const
  msgEmptyError: String = 'Container %s can not be empty';
  msgOutOfBoundsError: String = 'Index (%d) is out of bounds for container %s';
  msgFullError: String = 'Container %s is full';

procedure Register;
begin
  RegisterComponents('EHGK',[TEhgkPageContainer]);
end;

{ TEhgkPageContainer }

procedure TEhgkPageContainer.EnsureIndexIsValid(Index: UInt8);
begin
  if (FPagesList.Count > 0) and (Index > (FPagesList.Count-1)) then
  begin
    raise TContainerIndexOutOfBounds.CreateFmt(msgOutOfBoundsError, [Index, Self.Name]);
  end;
end;

function TEhgkPageContainer.GetPageByIndex(Index: UInt8): TEhgkPage;
begin
  EnsureIndexIsValid(Index);
  Result := FPagesList.Items[Index];
end;

constructor TEhgkPageContainer.Create(AOwner: TComponent);
var
  EhgkPage: TEhgkPage;
begin
  inherited Create(AOwner);

  // FPagesList responsible for free containing objects
  FPagesList := TEhgkPageList.Create(True);

  EhgkPage := TEhgkPage.Create(Nil);
  FPagesList.Add(EhgkPage);
end;

destructor TEhgkPageContainer.Destroy;
begin
  FreeAndNil(FPagesList);
  inherited Destroy;
end;

function TEhgkPageContainer.Count: UInt8; inline;
begin
  Result := FPagesList.Count;
end;

function TEhgkPageContainer.Add: UInt8; inline;
begin
  if FPagesList.Count < UInt8.MaxValue then
  begin
    Result := FPagesList.Add(TEhgkPage.Create(Nil));
  end
  else
  begin
    raise TContainerFullError.CreateFmt(msgFullError, [Self.Name]);
  end;
end;

procedure TEhgkPageContainer.Delete(Index: UInt8); inline;
begin
  EnsureIndexIsValid(Index);

  if (FPagesList.Count = 1) and (Index = 0) then
  begin
    raise TContainerEmptyError.CreateFmt(msgEmptyError, [Self.Name]);
  end;
  FPagesList.Delete(Index);

end;

initialization
  {$I ehgkpagecontainer.lrs}

end.

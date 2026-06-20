{
 Electronic hourglass kit pages container (Ehgk) components unit.

 An electronic hourglass is a simple electronic device you can assemble yourself.
 It contains 57 LEDs located on a circuit board LED count can not be changed
 due to circuit board design.
 LED state is driven by microcontroller (STC15W201 or STC15W2024)

 Page is LEDs state description.

 Pages container manage sequence of pages. Pages container size is limited by
 microcontroller EEPROM size. Pages container can hold 255 pages maximum.
}
unit EhgkPageContainer;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LResources, fgl, EhgkPage;

type
  TEhgkPageList = specialize TFPGObjectList<TEhgkPage>;

  TContainerEmptyError = class(Exception);
  TContainerFullError = class(Exception);
  TContainerIndexOutOfBounds = class(Exception);


  {
   TEhgkPageContainer owns Ehgk device pages.
   Container have at least one page and
   the 255 pages maximum.
  }

  TEhgkPageContainer = class(TComponent)
  private
    FPagesList: TEhgkPageList;
    procedure CheckIndexRange(Index: UInt8);
    function GetPageByIndex(Index: UInt8): TEhgkPage;
    function GetCount: UInt8;

  protected

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function Add: UInt8;
    procedure Delete(Index: UInt8);

    property Page[Index: UInt8]: TEhgkPage read GetPageByIndex;
    property Count: UInt8 read GetCount;
  published

  end;

procedure Register;

implementation

const
  MsgEmptyError: String = 'Container %s can not be empty';
  MsgOutOfBoundsError: String = 'Index (%d) is out of bounds for container %s';
  MsgFullError: String = 'Container %s is full';

procedure Register;
begin
  RegisterComponents('EHGK',[TEhgkPageContainer]);
end;

{ TEhgkPageContainer }

procedure TEhgkPageContainer.CheckIndexRange(Index: UInt8);
begin
  if (Index >= GetCount) then
    raise TContainerIndexOutOfBounds.CreateFmt(MsgOutOfBoundsError, [Index, Self.Name]);
end;

function TEhgkPageContainer.GetPageByIndex(Index: UInt8): TEhgkPage;
begin
  CheckIndexRange(Index);
  Result := FPagesList.Items[Index];
end;

// Enforces at least one page. Do not remove.
constructor TEhgkPageContainer.Create(AOwner: TComponent);
var
  ehgkPage: TEhgkPage;
begin
  inherited Create(AOwner);

  FPagesList := TEhgkPageList.Create(True);

  ehgkPage := TEhgkPage.Create(Nil);
  FPagesList.Add(ehgkPage);
end;

destructor TEhgkPageContainer.Destroy;
begin
  FreeAndNil(FPagesList);
  inherited Destroy;
end;

function TEhgkPageContainer.GetCount: UInt8;
begin
  Result := UInt8(FPagesList.Count);
end;

function TEhgkPageContainer.Add: UInt8;
begin
  if GetCount < UInt8.MaxValue then
  begin
    Result := UInt8(FPagesList.Add(TEhgkPage.Create(Nil)));
  end
  else
  begin
    raise TContainerFullError.CreateFmt(MsgFullError, [Self.Name]);
  end;
end;

procedure TEhgkPageContainer.Delete(Index: UInt8);
begin
  if (GetCount <= 1) then
  begin
    raise TContainerEmptyError.CreateFmt(MsgEmptyError, [Self.Name]);
  end;

  CheckIndexRange(Index);
  FPagesList.Delete(Index);
end;

initialization
  {$I ehgkpagecontainer.lrs}

end.

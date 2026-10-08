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
{$WARN 6058 off : Call to subroutine "$1" marked as inline is not inlined}

interface

uses
  Classes, SysUtils, LResources, fgl, EhgkPage;

type
  {
   Typed object list for storing TEhgkPage instances used by page containers.
   Object ownership follows the TFPGObjectList ownership setting.
  }
  TEhgkPageList = specialize TFPGObjectList<TEhgkPage>;

  { Raised when an operation would leave a page container with no pages. }
  TContainerEmptyError = class(Exception);

  { Raised when adding a page would exceed the container's 255-page limit. }
  TContainerFullError = class(Exception);

  { Raised when a page index is outside the container's valid index range. }
  TContainerIndexOutOfBoundsError = class(Exception);

  {
   Event type called after a page is removed from a container and before it
   is freed. Sender is the container; Page is the removed page and must not
   be freed by the event handler.
  }
  TAfterDeletePageEvent = procedure(Sender: TObject; Page: TEhgkPage) of object;


  {
   TEhgkPageContainer owns Ehgk device pages.
   Container have at least one page and
   the 255 pages maximum.
  }
  TEhgkPageContainer = class(TComponent)
  private
    FPagesList: TEhgkPageList;

    FAfterPageAdd: TNotifyEvent;
    FAfterPageDelete: TAfterDeletePageEvent;

    function GetPageByIndex(Index: UInt8): TEhgkPage;
    function GetCount: UInt8;

  protected
    procedure CheckIndexRange(Index: UInt8);
    function DoDeletePage(Index: UInt8): TEhgkPage;

    procedure DoAfterPageAdd;
    procedure DoAfterPageDelete(Page: TEhgkPage);

  public
    {
     Creates the container and initializes it with one page whose LEDs are
     all off. The container owns and frees its pages; it always contains at
     least one page and can hold up to 255 pages.

     AOwner is the component that owns this container, or Nil if it has no
     component owner.
    }
    constructor Create(AOwner: TComponent); override;

    {
     Frees all pages owned by the container, releases its internal page list,
     and then destroys the inherited component state.
    }
    destructor Destroy; override;

    {
     Creates a new page with all LEDs off, adds it to the container, and
     returns its zero-based index. AfterPageAdd is fired once the page has
     been added. Raises TContainerFullError if the container already holds
     255 pages.
    }
    function AddPage: UInt8; virtual;

    {
     Deletes the page at the specified zero-based index and frees it after
     AfterPageDelete is called. The container must retain at least one page;
     attempting to delete its only page raises TContainerEmptyError. An
     invalid index raises TContainerIndexOutOfBoundsError.
    }
    procedure DeletePage(Index: UInt8); virtual;

    {
     Provides access to the page at the specified zero-based index.
     Raises TContainerIndexOutOfBoundsError if Index is outside the
     container's current page range. The returned page is owned by the
     container and must not be freed by the caller.
    }
    property Page[Index: UInt8]: TEhgkPage read GetPageByIndex;

    {
     Returns the number of pages currently in the container. The count is
     always between 1 and 255.
    }
    property PageCount: UInt8 read GetCount;
  published
      {
       Event called after a new page has been added to the container.
       Sender is the TEhgkPageContainer instance.
      }
      property AfterPageAdd: TNotifyEvent read FAfterPageAdd write FAfterPageAdd;

      {
       Event called after a page has been removed from the container and
       before it is freed. Sender is the container; Page is the removed page,
       which is valid only for the duration of this callback and must not be
       freed by the handler.
      }
      property AfterPageDelete: TAfterDeletePageEvent read FAfterPageDelete write FAfterPageDelete;
  end;

  { TEhgkPageNavigatableContainer add navigation to TEhgkPageContainer}

  TEhgkPageNavigatableContainer = class(TEhgkPageContainer)
  private
    FCurrentPageIndex: UInt8;
    FOnPageIndexChange: TNotifyEvent;

    procedure SetCurrentPageIndex(AValue: UInt8);

  protected
    procedure DoPageIndexChange;

  public
    constructor Create(AOwner: TComponent); override;

    procedure DeletePage(Index: UInt8); override;

    procedure First;
    procedure Last;

  published
    { Events }
    property OnPageIndexChange: TNotifyEvent read FOnPageIndexChange write FOnPageIndexChange;

    { Properties }
    property PageCount;
    property CurrentPageIndex: UInt8 read FCurrentPageIndex write SetCurrentPageIndex;

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
  RegisterComponents('EHGK',[TEhgkPageNavigatableContainer]);
end;

{ TEhgkPageContainer }

procedure TEhgkPageContainer.CheckIndexRange(Index: UInt8);
begin
  if (Index >= GetCount) then
    raise TContainerIndexOutOfBoundsError.CreateFmt(MsgOutOfBoundsError, [Index, Self.Name]);
end;

function TEhgkPageContainer.DoDeletePage(Index: UInt8): TEhgkPage;
var
  DeletedPage: TEhgkPage;
begin
  CheckIndexRange(Index);

  if (GetCount <= 1) then
  begin
    raise TContainerEmptyError.CreateFmt(MsgEmptyError, [Self.Name]);
  end;

  DeletedPage := FPagesList.Items[Index];

  Result := FPagesList.Extract(DeletedPage);
end;

procedure TEhgkPageContainer.DoAfterPageAdd;
begin
  if Assigned(FAfterPageAdd) then
  begin
       FAfterPageAdd(Self);
  end;
end;

procedure TEhgkPageContainer.DoAfterPageDelete(Page: TEhgkPage);
begin
  if Assigned(FAfterPageDelete) then
  begin
    FAfterPageDelete(Self, Page);
  end;
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

  FPagesList := TEhgkPageList.Create(False);

  ehgkPage := TEhgkPage.Create(Nil);
  FPagesList.Add(ehgkPage);
end;

destructor TEhgkPageContainer.Destroy;
begin
  FPagesList.FreeObjects := True;
  FPagesList.Clear;
  FreeAndNil(FPagesList);
  inherited Destroy;
end;

function TEhgkPageContainer.GetCount: UInt8;
begin
  Result := UInt8(FPagesList.Count);
end;

function TEhgkPageContainer.AddPage: UInt8;
begin
  if GetCount < UInt8.MaxValue then
  begin
    Result := UInt8(FPagesList.Add(TEhgkPage.Create(Nil)));
  end
  else
  begin
    raise TContainerFullError.CreateFmt(MsgFullError, [Self.Name]);
  end;

  DoAfterPageAdd;
end;

procedure TEhgkPageContainer.DeletePage(Index: UInt8);
var
  P: TEhgkPage;
begin
  P := DoDeletePage(Index);
  try
     DoAfterPageDelete(P);
  finally
    FreeAndNil(P);
  end;
end;

{ TEhgkPageNavigatableContainer }

procedure TEhgkPageNavigatableContainer.SetCurrentPageIndex(AValue: UInt8);
begin
  if FCurrentPageIndex = AValue then Exit;
  CheckIndexRange(AValue);
  FCurrentPageIndex := AValue;

  DoPageIndexChange;
end;

procedure TEhgkPageNavigatableContainer.DoPageIndexChange;
begin
  if Assigned(FOnPageIndexChange) then
    FOnPageIndexChange(Self);
end;

constructor TEhgkPageNavigatableContainer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCurrentPageIndex := 0;
end;

procedure TEhgkPageNavigatableContainer.DeletePage(Index: UInt8);
var
  DeletedPage: TEhgkPage;
begin
  DeletedPage := DoDeletePage(Index);

  if (PageCount > 0) and (FCurrentPageIndex >= PageCount) then
    SetCurrentPageIndex(PageCount - 1);

  try
     DoAfterPageDelete(DeletedPage);
  finally
    FreeAndNil(DeletedPage);
  end;
end;

procedure TEhgkPageNavigatableContainer.First;
begin
   SetCurrentPageIndex(0);
end;

procedure TEhgkPageNavigatableContainer.Last;
begin
     SetCurrentPageIndex(PageCount - 1);
end;

initialization
  {$I ehgkpagecontainer.lrs}

end.

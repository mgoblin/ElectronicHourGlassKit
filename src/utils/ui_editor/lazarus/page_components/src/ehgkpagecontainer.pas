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
   Event type called before a new page is added to a container.

   Sender is the TEhgkPageContainer instance that is about to accept the page.
   Page is a newly created page object that has not yet been inserted into the
   container. The handler may inspect or initialize the page before it becomes
   part of the container, but it must not free the page or transfer ownership to
   another object. If the handler raises an exception, AddPage aborts and the
   page is discarded without being added to the container.

   This event is fired only when AddPage creates a new page. It does not run for
   pages already present in the container or when the container is created.
  }
  TBeforeAddPageEvent = procedure(Sender: TObject; Page: TEhgkPage) of object;

  {
   Event type called after a page is removed from a container and before it
   is freed. Sender is the container; Page is the removed page and must not
   be freed by the event handler.
  }
  TAfterDeletePageEvent = procedure(Sender: TObject; Page: TEhgkPage) of object;

  {
   Event type called before a page is deleted from the container.

   Sender is the TEhgkPageContainer instance. PageIndex is the zero-based index
   of the page that is about to be removed. The page still exists at that index
   and is still owned by the container, but it has not yet been extracted or
   destroyed. Handlers may inspect the page via Page[PageIndex] or use the index
   to prepare UI state or update navigation. They must not free the page or
   mutate the container in a way that invalidates the pending delete operation.
  }
  TBeforeDeletePageEvent = procedure(Sender: TObject; PageIndex: Cardinal) of object;


  {
   TEhgkPageContainer owns Ehgk device pages.
   Container have at least one page and
   the 255 pages maximum.
  }
  TEhgkPageContainer = class(TComponent)
  private
    FPagesList: TEhgkPageList;

    FBeforePageAdd: TBeforeAddPageEvent;
    FBeforePageDelete: TBeforeDeletePageEvent;

    FAfterPageAdd: TNotifyEvent;
    FAfterPageDelete: TAfterDeletePageEvent;

    function GetPageByIndex(const Index: Cardinal): TEhgkPage;
    function GetCount: Cardinal; inline;

  protected
    procedure CheckIndexRange(const Index: Cardinal);
    function DoDeletePage(const Index: Cardinal): TEhgkPage;

    procedure FireBeforePageAddEvent(const Page: TEhgkPage);
    procedure FireBeforePageDeleteEvent(const PageIndex: Cardinal);

    procedure FireAfterPageAddEvent;
    procedure FireAfterPageDeleteEvent(const Page: TEhgkPage);

  public
    {
     Minimum number of pages that a container must retain.

     The container always owns at least one page, so deleting the last page is
     forbidden and raises TContainerEmptyError.
    }
    const MinPages: Cardinal = 1;

    {
     Maximum number of pages that a container may hold.

     This limit matches the device design constraint for the page sequence and is
     enforced by AddPage. Attempting to add a page when the count is already at
     this value raises TContainerFullError.
    }
    const MaxPageCount: Cardinal = 255;

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
     Creates a new page with all LEDs switched off and appends it to the
     container.

     The returned value is the zero-based index of the newly inserted page.
     Once the page has been added, AfterPageAdd is fired. The operation fails
     with TContainerFullError when the container already contains
     MaxPageCount pages.

     Before the page is inserted, BeforeAddPage is raised so handlers can
     inspect or initialize the new page instance. If a BeforeAddPage handler
     raises an exception, the page is discarded and the add operation is
     aborted.
    }
    function AddPage: Cardinal; virtual;

    {
     Removes the page at the specified zero-based index from the container.

     The container always keeps at least one page, so deleting the only page
     raises TContainerEmptyError. An invalid index raises
     TContainerIndexOutOfBoundsError.

     The page is removed from the internal list, AfterPageDelete is fired with
     the removed page as its argument, and the page object is then freed. The
     handler may inspect the page during this callback, but must not free it.
    }
    procedure DeletePage(Index: Cardinal); virtual;

    {
     Provides access to the page at the specified zero-based index.
     Raises TContainerIndexOutOfBoundsError if Index is outside the
     container's current page range. The returned page is owned by the
     container and must not be freed by the caller.
    }
    property Page[Index: Cardinal]: TEhgkPage read GetPageByIndex;

    {
     Returns the number of pages currently in the container. The count is
     always between 1 and 255.
    }
    property PageCount: Cardinal read GetCount;
  published

    {
     Event called before a new page is inserted into the container.

     The event is fired from AddPage after the page object is created and before
     it is appended to the container. The handler can initialize the page (for
     example, set its default LED state or assign metadata), but it must not
     destroy the page, free it, or re-own it. If the handler raises an
     exception, AddPage aborts, the page is released, and the container remains
     unchanged.
    }
    property BeforeAddPage: TBeforeAddPageEvent read FBeforePageAdd write FBeforePageAdd;

    {
     Event called before a page is deleted from the container.

     Sender is the TEhgkPageContainer instance. PageIndex identifies the page
     that is about to be removed, before the page is extracted from the internal
     list. During this callback the page is still available through the current
     container state, but it has not yet been destroyed. The handler may use this
     event for validation or UI updates, but it must not free the page or change
     the container in a way that interferes with the pending deletion.
    }
    property BeforePageDelete: TBeforeDeletePageEvent read FBeforePageDelete write FBeforePageDelete;

    {
     Event called after a new page has been successfully inserted into the
     container.

     Sender is the TEhgkPageContainer instance. This event is fired after
     AddPage has appended the new page to the container and completed the
     insertion. At this point, the page is owned by the container and can be
     accessed through Page[PageCount - 1] or by inspecting the container's
     current state. Handlers must not free the page or remove it from the
     container; they may use this event to update UI state, refresh selection,
     or perform dependent initialization.
    }
    property AfterPageAdd: TNotifyEvent read FAfterPageAdd write FAfterPageAdd;

    {
     Event called after a page has been removed from the container and before
     it is freed.

     Sender is the TEhgkPageContainer instance. Page is the removed page,
     already extracted from the internal list but not yet destroyed, so it is
     still valid for the duration of the callback. The handler may inspect the
     page or update related state, but it must not free the page or keep a
     reference beyond the callback lifetime. After the handler returns, the
     container destroys the removed page automatically.
    }
    property AfterPageDelete: TAfterDeletePageEvent read FAfterPageDelete write FAfterPageDelete;
  end;

  {
   Extends TEhgkPageContainer with a current-page index and navigation to
   the pages. Changing the current page raises OnPageIndexChange;
   deleting a page adjusts the current index when necessary.

   Destroy is inherited from TEhgkPageContainer, which frees all pages owned
   by the container.

   Navigation methods (First, Last) are no-ops when the container is already
   at the target page; they do not fire OnPageIndexChange. Use CanFirst and
   CanLast to check whether navigation is possible before calling First or
   Last.

   When a page is deleted, CurrentPageIndex is adjusted automatically:
   if the deleted page precedes the current index, the index is decremented;
   if the deleted page is the current page or the last page, the index moves
   to PageCount - 1. OnPageIndexChange fires only when the index actually
   changes after deletion.
  }

  { TEhgkPageNavigatableContainer }

  TEhgkPageNavigatableContainer = class(TEhgkPageContainer)
  private
    FCurrentPageIndex: Cardinal;
    FOnPageIndexChange: TNotifyEvent;

    procedure SetCurrentPageIndex(AValue: Cardinal);

    function GetCanFirst: Boolean;
    function GetCanLast: Boolean;

  protected
    procedure FirePageIndexChangeEvent;

  public
    {
     Creates the navigatable container with the initial page provided by
     TEhgkPageContainer and sets CurrentPageIndex to zero.

     AOwner is the component that owns this container, or Nil if it has no
     component owner.
    }
    constructor Create(AOwner: TComponent); override;

    {
      Deletes the page at the specified zero-based index. If deleting that
      page leaves CurrentPageIndex beyond the new last index, selects the new
      last page and fires OnPageIndexChange. AfterPageDelete is called before
      the removed page is freed. Raises TContainerIndexOutOfBoundsError for an
      invalid index and TContainerEmptyError if the only page would be deleted.

      Event ordering: CurrentPageIndex is adjusted (and OnPageIndexChange is
      fired, if the index changed) **before** AfterPageDelete is raised. This
      ensures that AfterPageDelete handlers observe the container in its final
      state -- the removed page is still valid but not yet freed, and
      CurrentPageIndex already reflects the post-deletion layout. This ordering
      differs from the base TEhgkPageContainer, where AfterPageDelete fires
      immediately after extraction with no index adjustment.
     }
    procedure DeletePage(Index: Cardinal); override;

    {
     Selects the first page by setting CurrentPageIndex to zero. Fires
     OnPageIndexChange only if the current index changes.
    }
    procedure First;

    {
     Selects the last page by setting CurrentPageIndex to PageCount - 1.
     Fires OnPageIndexChange only if the current index changes.
    }
    procedure Last;

    {
     Selects the next page by incrementing CurrentPageIndex by one.
     Fires OnPageIndexChange only if the current index changes.
    }
    procedure Next;

  published
    { Events }

    {
     Event called after CurrentPageIndex changes. Sender is this navigatable
     container. No event is fired when assigning the current index its
     existing value.
    }
    property OnPageIndexChange: TNotifyEvent read FOnPageIndexChange write FOnPageIndexChange;

    
    { Properties }
    
    {
     Inherited from TEhgkPageContainer. Returns the number of pages currently
     in the container, always between 1 and 255.
    }
    property PageCount;

    {
     Zero-based index of the currently selected page. Valid values range from
     zero to PageCount - 1. Assigning a different valid index fires
     OnPageIndexChange; assigning an invalid index raises
     TContainerIndexOutOfBoundsError.
    }
    property CurrentPageIndex: Cardinal read FCurrentPageIndex write SetCurrentPageIndex;

    {
     Returns True if the current page index can be changed to the first page
     (i.e., the current page is not already the first one).
    }
    property CanFirst: Boolean read GetCanFirst;

    {
     Returns True if the current page index can be changed to the last page
     (i.e., the current page is not already the last one).
    }
    property CanLast: Boolean read GetCanLast;

  end;

procedure Register;

implementation

const
  MsgEmptyError: String = 'Container [Name: "%s", Class: "%s"] can not be empty';
  MsgOutOfBoundsError: String = 'Index (%u) is out of bounds for container [Name: "%s", Class: "%s"]';
  MsgFullError: String = 'Container [Name: "%s", Class: "%s"] is full';

procedure Register;
begin
  RegisterComponents('EHGK',[TEhgkPageContainer, TEhgkPageNavigatableContainer]);
end;

{ TEhgkPageContainer }

procedure TEhgkPageContainer.CheckIndexRange(const Index: Cardinal);
begin
  if (Index >= GetCount) then
  begin
    raise TContainerIndexOutOfBoundsError.CreateFmt(MsgOutOfBoundsError,
          [Index, Self.Name, Self.ClassName]
    );
  end;
end;

function TEhgkPageContainer.DoDeletePage(const Index: Cardinal): TEhgkPage;
var
  DeletedPage: TEhgkPage;
begin
  CheckIndexRange(Index);

  if (GetCount <= MinPages) then
  begin
    raise TContainerEmptyError.CreateFmt(MsgEmptyError, [Self.Name, Self.ClassName]);
  end;

  FireBeforePageDeleteEvent(Index);

  DeletedPage := FPagesList.Items[Index];

  Result := FPagesList.Extract(DeletedPage);
end;

procedure TEhgkPageContainer.FireBeforePageAddEvent(const Page: TEhgkPage);
begin
  if Assigned(FBeforePageAdd) then
  begin
    FBeforePageAdd(Self, Page);
  end;
end;

procedure TEhgkPageContainer.FireBeforePageDeleteEvent(const PageIndex: Cardinal);
begin
  if Assigned(FBeforePageDelete) then
  begin
    FBeforePageDelete(Self, PageIndex);
  end;
end;

procedure TEhgkPageContainer.FireAfterPageAddEvent;
begin
  if Assigned(FAfterPageAdd) then
  begin
    FAfterPageAdd(Self);
  end;
end;

procedure TEhgkPageContainer.FireAfterPageDeleteEvent(const Page: TEhgkPage);
begin
  if Assigned(FAfterPageDelete) then
  begin
    FAfterPageDelete(Self, Page);
  end;
end;

function TEhgkPageContainer.GetPageByIndex(const Index: Cardinal): TEhgkPage;
begin
  CheckIndexRange(Index);
  Result := FPagesList.Items[Index];
end;

constructor TEhgkPageContainer.Create(AOwner: TComponent);
var
  i: Cardinal;
begin
  inherited Create(AOwner);

  FPagesList := TEhgkPageList.Create(True);

  for i := 1 to MinPages do
    FPagesList.Add(TEhgkPage.Create(Nil));
end;

destructor TEhgkPageContainer.Destroy;
begin
  FreeAndNil(FPagesList);
  inherited Destroy;
end;

function TEhgkPageContainer.GetCount: Cardinal;
begin
  Result := Cardinal(FPagesList.Count);
end;

function TEhgkPageContainer.AddPage: Cardinal;
var
  AddedPage: TEhgkPage;
begin
  if GetCount < MaxPageCount then
  begin
    AddedPage := TEhgkPage.Create(Nil);

    try
      FireBeforePageAddEvent(AddedPage);
    except
      FreeAndNil(AddedPage);
      raise;
    end;

    FPagesList.Add(AddedPage);
    Result := FPagesList.Count - 1;
    FireAfterPageAddEvent;
  end
  else
  begin
    raise TContainerFullError.CreateFmt(MsgFullError, [Self.Name, Self.ClassName]);
  end;
end;

procedure TEhgkPageContainer.DeletePage(Index: Cardinal);
var
  P: TEhgkPage;
begin
  P := DoDeletePage(Index);
  try
    FireAfterPageDeleteEvent(P);
  finally
    FreeAndNil(P);
  end;
end;

procedure TEhgkPageNavigatableContainer.SetCurrentPageIndex(AValue: Cardinal);
begin
  if FCurrentPageIndex = AValue then Exit;
  CheckIndexRange(AValue);
  FCurrentPageIndex := AValue;

  FirePageIndexChangeEvent;
end;

procedure TEhgkPageNavigatableContainer.FirePageIndexChangeEvent;
begin
  if Assigned(FOnPageIndexChange) then
    FOnPageIndexChange(Self);
end;

constructor TEhgkPageNavigatableContainer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCurrentPageIndex := 0;
end;

procedure TEhgkPageNavigatableContainer.DeletePage(Index: Cardinal);
var
  DeletedPage: TEhgkPage;
  Idx: Cardinal;
begin
  Idx := FCurrentPageIndex;

  DeletedPage := DoDeletePage(Index);

  if (FCurrentPageIndex >= PageCount) then
  begin
    FCurrentPageIndex := PageCount - 1;
  end
  else if (FCurrentPageIndex > Index) then
  begin
    FCurrentPageIndex := FCurrentPageIndex - 1;
  end;

  if Idx <> FCurrentPageIndex then
  begin
    FirePageIndexChangeEvent;
  end;

  try
    FireAfterPageDeleteEvent(DeletedPage);
  finally
    FreeAndNil(DeletedPage);
  end;
end;

procedure TEhgkPageNavigatableContainer.First;
begin
  if GetCanFirst then
    SetCurrentPageIndex(0);
end;

function TEhgkPageNavigatableContainer.GetCanFirst: Boolean;
begin
  Result := FCurrentPageIndex <> 0;
end;

procedure TEhgkPageNavigatableContainer.Last;
begin
  if GetCanLast then
    SetCurrentPageIndex(PageCount - 1);
end;

procedure TEhgkPageNavigatableContainer.Next;
begin
  if CanLast then
    SetCurrentPageIndex(FCurrentPageIndex + 1);
end;

function TEhgkPageNavigatableContainer.GetCanLast: Boolean;
begin
  Result := FCurrentPageIndex < GetCount - 1;
end;

initialization
  {$I ehgkpagecontainer.lrs}

end.

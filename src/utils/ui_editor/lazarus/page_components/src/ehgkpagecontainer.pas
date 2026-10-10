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
   Event type called before a new page is added to a container.

   Sender is the TEhgkPageContainer instance that is about to accept the page.
   Page is a newly created page instance that has not yet been inserted into
   the container. The handler may inspect or initialize it, but must not free
   it or transfer ownership elsewhere. If the handler raises an exception, the
   add operation is aborted and the page is discarded.
  }
  TBeforeAddPageEvent = procedure(Sender: TObject; Page: TEhgkPage) of object;


  {
   TEhgkPageContainer owns Ehgk device pages.
   Container have at least one page and
   the 255 pages maximum.
  }
  TEhgkPageContainer = class(TComponent)
  private
    FPagesList: TEhgkPageList;

    FBeforePageAdd: TBeforeAddPageEvent;

    FAfterPageAdd: TNotifyEvent;
    FAfterPageDelete: TAfterDeletePageEvent;

    function GetPageByIndex(Index: Cardinal): TEhgkPage;
    function GetCount: Cardinal;

  protected
    procedure CheckIndexRange(Index: Cardinal);
    function DoDeletePage(Index: Cardinal): TEhgkPage;

    procedure DoBeforePageAdd(const Page: TEhgkPage);

    procedure DoAfterPageAdd;
    procedure DoAfterPageDelete(const Page: TEhgkPage);

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

    property BeforeAddPage: TBeforeAddPageEvent read FBeforePageAdd write FBeforePageAdd;

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

  {
   Extends TEhgkPageContainer with a current-page index and navigation to
   the first or last page. Changing the current page raises OnPageIndexChange;
   deleting a page adjusts the current index when necessary.

   Destroy is inherited from TEhgkPageContainer, which frees all pages owned
   by the container.
  }
  TEhgkPageNavigatableContainer = class(TEhgkPageContainer)
  private
    FCurrentPageIndex: Cardinal;
    FOnPageIndexChange: TNotifyEvent;

    procedure SetCurrentPageIndex(AValue: Cardinal);

  protected
    procedure DoPageIndexChange;

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

  end;

procedure Register;

implementation

const
  MsgEmptyError: String = 'Container %s can not be empty';
  MsgOutOfBoundsError: String = 'Index (%u) is out of bounds for container [Name: "%s", Class: "%s"]';
  MsgFullError: String = 'Container %s is full';

procedure Register;
begin
  RegisterComponents('EHGK',[TEhgkPageContainer]);
  RegisterComponents('EHGK',[TEhgkPageNavigatableContainer]);
end;

{ TEhgkPageContainer }

procedure TEhgkPageContainer.CheckIndexRange(Index: Cardinal);
begin
  if (Index >= GetCount) then
  begin
    raise TContainerIndexOutOfBoundsError.CreateFmt(MsgOutOfBoundsError,
          [Index, Self.Name, Self.ClassName]
    );
  end;
end;

function TEhgkPageContainer.DoDeletePage(Index: Cardinal): TEhgkPage;
var
  DeletedPage: TEhgkPage;
begin
  CheckIndexRange(Index);

  if (GetCount <= MinPages) then
  begin
    raise TContainerEmptyError.CreateFmt(MsgEmptyError, [Self.Name]);
  end;

  DeletedPage := FPagesList.Items[Index];

  Result := FPagesList.Extract(DeletedPage);
end;

procedure TEhgkPageContainer.DoBeforePageAdd(const Page: TEhgkPage);
begin
  if Assigned(FBeforePageAdd) then
  begin
    FBeforePageAdd(Self, Page);
  end;
end;

procedure TEhgkPageContainer.DoAfterPageAdd;
begin
  if Assigned(FAfterPageAdd) then
  begin
    FAfterPageAdd(Self);
  end;
end;

procedure TEhgkPageContainer.DoAfterPageDelete(const Page: TEhgkPage);
begin
  if Assigned(FAfterPageDelete) then
  begin
    FAfterPageDelete(Self, Page);
  end;
end;

function TEhgkPageContainer.GetPageByIndex(Index: Cardinal): TEhgkPage;
begin
  CheckIndexRange(Index);
  Result := FPagesList.Items[Index];
end;

constructor TEhgkPageContainer.Create(AOwner: TComponent);
var
  ehgkPage: TEhgkPage;
begin
  inherited Create(AOwner);

  FPagesList := TEhgkPageList.Create(True);

  while FPagesList.Count < MinPages do
  begin
    ehgkPage := TEhgkPage.Create(Nil);
    FPagesList.Add(ehgkPage);
  end;
end;

destructor TEhgkPageContainer.Destroy;
begin
  FPagesList.Clear;
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
       DoBeforePageAdd(AddedPage);
    except
      FreeAndNil(AddedPage);
      raise;
    end;

    Result := Cardinal(FPagesList.Add(AddedPage));
    DoAfterPageAdd;
  end
  else
  begin
    raise TContainerFullError.CreateFmt(MsgFullError, [Self.Name]);
  end;
end;

procedure TEhgkPageContainer.DeletePage(Index: Cardinal);
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

procedure TEhgkPageNavigatableContainer.SetCurrentPageIndex(AValue: Cardinal);
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

procedure TEhgkPageNavigatableContainer.DeletePage(Index: Cardinal);
var
  DeletedPage: TEhgkPage;
begin
  DeletedPage := DoDeletePage(Index);

  if (FCurrentPageIndex >= PageCount) then
  begin
    SetCurrentPageIndex(PageCount - 1);
  end
  else if (FCurrentPageIndex > Index) then
  begin
     SetCurrentPageIndex(FCurrentPageIndex - 1);
  end;

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

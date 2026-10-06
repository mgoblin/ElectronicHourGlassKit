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
  TEhgkPageList = specialize TFPGObjectList<TEhgkPage>;

  TContainerEmptyError = class(Exception);
  TContainerFullError = class(Exception);
  TContainerIndexOutOfBoundsError = class(Exception);

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
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function AddPage: UInt8; virtual;
    procedure DeletePage(Index: UInt8); virtual;

    property Page[Index: UInt8]: TEhgkPage read GetPageByIndex;
    property PageCount: UInt8 read GetCount;
  published
    { Events }
    property AfterPageAdd: TNotifyEvent read FAfterPageAdd write FAfterPageAdd;
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
  if GetCount = 0 then
    raise TContainerEmptyError.CreateFmt(MsgEmptyError, [Self.Name]);

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

  DeletedPage := GetPageByIndex(Index);

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
  P: TEhgkPage;
begin
  P := DoDeletePage(Index);

  try
    if (PageCount > 0) and (FCurrentPageIndex >= PageCount) then
    begin
      SetCurrentPageIndex(PageCount - 1);
    end
    else if (Index <= FCurrentPageIndex) and (FCurrentPageIndex > 0) then
    begin
      SetCurrentPageIndex(FCurrentPageIndex - 1);
    end;

    DoAfterPageDelete(P);
  finally
    FreeAndNil(P);
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

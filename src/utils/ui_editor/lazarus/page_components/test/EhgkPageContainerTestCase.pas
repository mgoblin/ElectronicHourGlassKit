unit EhgkPageContainerTestCase;

{$mode objfpc}{$H+}

{$inline on}
{$warn 6058 off}


interface

uses
  Classes, SysUtils, fpcunit, testregistry, EhgkPage, EhgkPageContainer;

type

  { TEhgkPageContainerTestCase }

  TEhgkPageContainerTestCase = class(TTestCase)
  private
    FBeforeAddPageHandlerCalled: Boolean;
    FBeforeAddSender: TObject;
    FPageCountAtBeforeAddEvent: UInt8;
    FAddedPageRef: TEhgkPage;

    FAfterAddPageHandlerCalled: Boolean;
    FAfterAddSender: TObject;
    FPageCountAtAddEvent: UInt8;

    FAfterDeletePageHandlerCalled: Boolean;
    FAfterDeleteSender: TObject;
    FDeletedPageRef: TEhgkPage;
    FPageCountAtDeleteEvent: UInt8;
    FDeletedPage: TEhgkPage;

    procedure BeforeAddPageHandler(Sender: TObject; Page: TEhgkPage);
    procedure AfterAddPageHandler(Sender: TObject);
    procedure AfterDeletePageHandler(Sender: TObject; Page: TEhgkPage);
  protected
    PageContainer: TEhgkPageContainer;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCreate;
    procedure TestDestroyFreesOwnedPages;

    procedure TestGetIndex;
    procedure TestGetIndexOutOfBounds;

    procedure TestAdd;
    procedure TestAddToFull;
    procedure TestAfterAddEvent;

    procedure TestDeleteFirst;
    procedure TestDeleteLast;
    procedure TestDeleteExisting;
    procedure TestDeleteIndexOutOfBounds;
    procedure TestDeleteSingle;

    procedure TestAfterAddPageNotAssigned;
    procedure TestAfterDeletePageNotAssigned;

    procedure TestBeforeAddPageNotAssigned;
  end;

implementation

uses
  Dialogs;

type
  TPageDestructionObserver = class(TComponent)
  public
    DestroyedPageCount: Integer;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  end;

procedure TPageDestructionObserver.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
    Inc(DestroyedPageCount);
end;

procedure TEhgkPageContainerTestCase.TestCreate;
var
  Container: TEhgkPageContainer;
  Page: TEhgkPage;
begin
  Container := TEhgkPageContainer.Create(Nil);
  try
    AssertNotNull('EhgkPageContainer should be not nil after creation', Container);
    AssertEquals('EhgkPageContainer count must be 1 after creation', 1, Container.PageCount);
    Page := Container.Page[0];
    AssertNotNull('EhgkPageContainer first page must not be null after creation', Page);
    AssertEquals('Initial page LEDs should all be off', 0, Page.Value);
  finally
    FreeAndNil(Container);
  end;
end;

procedure TEhgkPageContainerTestCase.TestDestroyFreesOwnedPages;
var
  Container: TEhgkPageContainer;
  Observer: TPageDestructionObserver;
  Index: Integer;
begin
  Container := TEhgkPageContainer.Create(Nil);
  Observer := TPageDestructionObserver.Create(Nil);
  try
    Container.AddPage;
    for Index := 0 to Container.PageCount - 1 do
      Container.Page[Index].FreeNotification(Observer);

    Container.Free;
    Container := Nil;

    AssertEquals('Container should free every owned page', 2,
      Observer.DestroyedPageCount);
  finally
    Container.Free;
    Observer.Free;
  end;
end;

procedure TEhgkPageContainerTestCase.TestGetIndex;
var
  Page: TEhgkPage;
begin
  Page := PageContainer.Page[0];
  AssertNotNull('Page[0] must not be Nil', Page);
end;

procedure TEhgkPageContainerTestCase.TestGetIndexOutOfBounds;
begin
  try
    PageContainer.Page[1];
    Fail('Index out of bounds exception must be raised');
  except
    on E: TContainerIndexOutOfBoundsError do
    begin
      AssertEquals(
        'Incorrect exception message',
        'Index (1) is out of bounds for container EhgkPageContainer1',
        E.Message
      );
    end
    else Fail('fgl.EListError must be raised');
  end;
end;

procedure TEhgkPageContainerTestCase.TestAdd;
var
  Index: Integer;
begin
  Index := PageContainer.AddPage;
  AssertEquals('Second added page must have index 1', 1, Index);

  PageContainer.Page[0].Value := 0;
  PageContainer.Page[1].Value := 1;

  AssertEquals('Page[0] should be equals to 0', 0, PageContainer.Page[0].Value);
  AssertEquals('Page[1] should be equals to 1', 1, PageContainer.Page[1].Value);
end;

procedure TEhgkPageContainerTestCase.TestAddToFull;
var
  i: Integer;
begin
  for i:= 0 to UInt8.MaxValue - 3 do
  begin
    PageContainer.AddPage;
  end;

  FAfterAddPageHandlerCalled := False;

  AssertEquals('Page container must be filled', 254, PageContainer.PageCount);

  try
     PageContainer.AddPage;
     Fail('TContainerFullError must be raised');
  except
    on E: TContainerFullError do
    begin
      AssertEquals(
        'Wrong error message',
        'Container EhgkPageContainer1 is full',
        E.Message
      );
      AssertFalse('After page add event should not be called', FAfterAddPageHandlerCalled);
    end
    else
    begin
      Fail('TContainerFullError must be raised');
    end;
  end;
end;

procedure TEhgkPageContainerTestCase.TestAfterAddEvent;
begin
  AssertFalse('AfterPageAddEvent should not be called', FAfterAddPageHandlerCalled);

  PageContainer.AddPage;
  AssertTrue('AfterPageAddEvent should be called', FAfterAddPageHandlerCalled);
  AssertSame('Sender should be the page container', PageContainer, FAfterAddSender);
  AssertEquals('Event should run after the new page is added', 2,
    FPageCountAtAddEvent);
end;

procedure TEhgkPageContainerTestCase.TestDeleteFirst;
const
  Page1Value: TEhgkPageValue = 5;
  Page0Value: TEhgkPageValue = 10;
var
  Page: TEhgkPage;
  Index: Integer;
begin
  PageContainer.Page[0].Value := Page0Value;

  Index := PageContainer.AddPage;
  AssertEquals('PageContainer must have 2 pages', 2, PageContainer.PageCount);
  Page := PageContainer.Page[Index];
  Page.Value := Page1Value;

  AssertFalse('After delete page event should not be called', FAfterDeletePageHandlerCalled);
  PageContainer.DeletePage(0);
  AssertEquals('PageContainer must have 1 page', 1, PageContainer.PageCount);
  AssertTrue('After delete page event should be called', FAfterDeletePageHandlerCalled);
  AssertEquals('Removed page invalid', Page0Value, FDeletedPage.Value);
  AssertEquals(
    Format('Page value must be %d', [Page1Value]),
    Page1Value,
    PageContainer.Page[0].Value
  );
end;

procedure TEhgkPageContainerTestCase.TestDeleteLast;
const
  Page0Value: TEhgkPageValue = 3;
  DeletedPageValue: TEhgkPageValue = 7;
var
  Index: Integer;
  Page0: TEhgkPage;
begin
  Page0 := PageContainer.Page[0];
  Page0.Value := Page0Value;

  Index := PageContainer.AddPage;
  AssertEquals('PageContainer must have 2 pages', 2, PageContainer.PageCount);
  PageContainer.Page[Index].Value := DeletedPageValue;

  PageContainer.DeletePage(Index);
  AssertEquals('PageContainer must have 1 page', 1, PageContainer.PageCount);
  AssertEquals('Page[0] valued should not be changed', Page0.Value, PageContainer.Page[0].Value);

  AssertTrue('After delete page event should be called', FAfterDeletePageHandlerCalled);
  AssertEquals('Delete page invalid value', DeletedPageValue, FDeletedPage.Value);
end;

procedure TEhgkPageContainerTestCase.TestDeleteExisting;
var
  Index: Integer;
  DeletedPage: TEhgkPage;
begin
  PageContainer.AddPage;
  PageContainer.AddPage;
  for Index := 0 to PageContainer.PageCount-1 do
  begin
    PageContainer.Page[Index].Value := Index;
  end;
  AssertEquals('PageContainer must have 3 pages', 3, PageContainer.PageCount);
  DeletedPage := PageContainer.Page[1];

  AssertFalse('After delete page event should not be called', FAfterDeletePageHandlerCalled);

  PageContainer.DeletePage(1); // Delete not first and not last page
  AssertEquals('PageContainer must have 2 pages', 2, PageContainer.PageCount);

  AssertEquals('Page[0] value must be equals to 0', 0, PageContainer.Page[0].Value);
  AssertEquals('Page[1] value must be equals to 2', 2, PageContainer.Page[1].Value);

  AssertEquals('Deleted page value invalid', 1, FDeletedPage.Value);
  AssertSame('Delete event should receive the removed page', DeletedPage,
    FDeletedPageRef);
  AssertSame('Delete event sender should be the page container', PageContainer,
    FAfterDeleteSender);
  AssertEquals('Delete event should run after removal', 2,
    FPageCountAtDeleteEvent);
end;

procedure TEhgkPageContainerTestCase.TestDeleteIndexOutOfBounds;
var
  ExistingPage: TEhgkPage;
begin
  PageContainer.AddPage;
  PageContainer.Page[0].Value := 3;
  PageContainer.Page[1].Value := 7;
  ExistingPage := PageContainer.Page[0];

  try
     PageContainer.DeletePage(10);
     Fail('TContainerIndexOutOfBounds should be raised');
  except
    on E: TContainerIndexOutOfBoundsError do
    begin
      AssertEquals(
        'Wrong error message',
        'Index (10) is out of bounds for container EhgkPageContainer1',
        E.Message
      );

      AssertFalse('After delete page event should not be called', FAfterDeletePageHandlerCalled);
      AssertEquals('Failed deletion must preserve the page count', 2,
        PageContainer.PageCount);
      AssertSame('Failed deletion must preserve existing pages', ExistingPage,
        PageContainer.Page[0]);
      AssertEquals('Failed deletion must preserve page values', 7,
        PageContainer.Page[1].Value);
    end;
    on E: Exception do
      Fail(Format('TContainerIndexOutOfBounds should be raised but %s raised', [E.QualifiedClassName]));
  end;
end;

procedure TEhgkPageContainerTestCase.TestDeleteSingle;
var
  ExistingPage: TEhgkPage;
begin
  ExistingPage := PageContainer.Page[0];
  ExistingPage.Value := 42;

  try
    PageContainer.DeletePage(0);
    Fail('TEmptyContainerError should be raised');
  except
    on E: TContainerEmptyError do
    begin
      AssertEquals(
        'Wrong error message',
        'Container EhgkPageContainer1 can not be empty',
        E.Message
      );

      AssertFalse('After delete page event should not be called', FAfterDeletePageHandlerCalled);
      AssertEquals('Failed deletion must preserve the only page', 1,
        PageContainer.PageCount);
      AssertSame('Failed deletion must retain the same page', ExistingPage,
        PageContainer.Page[0]);
      AssertEquals('Failed deletion must preserve the page value', 42,
        PageContainer.Page[0].Value);
    end else Fail('TEmptyContainerError should be raised');
  end;
end;

procedure TEhgkPageContainerTestCase.TestAfterAddPageNotAssigned;
begin
  PageContainer.AfterPageAdd := Nil;

  PageContainer.AddPage;
  AssertFalse('After page add event should not be called', FAfterAddPageHandlerCalled);
end;

procedure TEhgkPageContainerTestCase.TestAfterDeletePageNotAssigned;
begin
  PageContainer.AddPage;
  PageContainer.AfterPageDelete := Nil;

  PageContainer.DeletePage(0);
  AssertFalse('After delete page event should not be called', FAfterDeletePageHandlerCalled);
end;

procedure TEhgkPageContainerTestCase.TestBeforeAddPageNotAssigned;
begin
  PageContainer.BeforAddPage := Nil;

  PageContainer.AddPage;
  AssertFalse('Before add page event should not be called', FBeforeAddPageHandlerCalled);
  AssertNull('Before add page event should not be called', FBeforeAddSender);
  AssertEquals('Before add page event should not be called', 0, FPageCountAtBeforeAddEvent);
  AssertNull('Before add page event should not be called', FAddedPageRef);
end;

procedure TEhgkPageContainerTestCase.BeforeAddPageHandler(Sender: TObject;
  Page: TEhgkPage);
begin
  FBeforeAddPageHandlerCalled := True;
  FBeforeAddSender := Sender;
  FPageCountAtBeforeAddEvent := PageContainer.PageCount;
  FAddedPageRef := Page;
end;

procedure TEhgkPageContainerTestCase.AfterAddPageHandler(Sender: TObject);
begin
  FAfterAddPageHandlerCalled := True;
  FAfterAddSender := Sender;
  FPageCountAtAddEvent := PageContainer.PageCount;
end;

procedure TEhgkPageContainerTestCase.AfterDeletePageHandler(Sender: TObject;
  Page: TEhgkPage);
begin
  FreeAndNil(FDeletedPage);
  FDeletedPage := TEhgkPage.Create(Nil);
  FDeletedPage.Value := Page.Value;
  FAfterDeletePageHandlerCalled := True;
  FAfterDeleteSender := Sender;
  FDeletedPageRef := Page;
  FPageCountAtDeleteEvent := PageContainer.PageCount;
end;

procedure TEhgkPageContainerTestCase.SetUp;
begin
  PageContainer := TEhgkPageContainer.Create(Nil);
  PageContainer.Name := 'EhgkPageContainer1';

  FBeforeAddPageHandlerCalled := False;
  FBeforeAddSender := Nil;
  FAddedPageRef := Nil;
  FPageCountAtBeforeAddEvent := 0;
  PageContainer.BeforAddPage := @BeforeAddPageHandler;

  FAfterAddPageHandlerCalled := False;
  FAfterAddSender := Nil;
  FPageCountAtAddEvent := 0;
  PageContainer.AfterPageAdd := @AfterAddPageHandler;

  FAfterDeletePageHandlerCalled := False;
  FAfterDeleteSender := Nil;
  FDeletedPageRef := Nil;
  FPageCountAtDeleteEvent := 0;
  FDeletedPage := Nil;
  PageContainer.AfterPageDelete := @AfterDeletePageHandler;
end;

procedure TEhgkPageContainerTestCase.TearDown;
begin
  FreeAndNil(PageContainer);
  if Assigned(FDeletedPage) then
     FreeAndNil(FDeletedPage);
end;

initialization

  RegisterTest(TEhgkPageContainerTestCase);
end.

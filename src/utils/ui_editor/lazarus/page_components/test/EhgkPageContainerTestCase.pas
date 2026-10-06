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
    FAfterAddPageHandlerCalled: Boolean;
    FAfterDeletePageHandlerCalled: Boolean;
    FDeletedPage: TEhgkPage;

    procedure AfterAddPageHandler(Sender: TObject);
    procedure AfterDeletePageHandler(Sender: TObject; Page: TEhgkPage);
  protected
    PageContainer: TEhgkPageContainer;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCreate;

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
  end;

implementation

uses
  Dialogs;

procedure TEhgkPageContainerTestCase.TestCreate;
var
  Container: TEhgkPageContainer;
  Page: TEhgkPage;
begin
  Container := TEhgkPageContainer.Create(Nil);
  AssertNotNull('EhgkPageContainer should be not nil after creation', Container);
  AssertEquals('EhgkPageContainer count must be 1 after creation', 1, Container.PageCount);
  Page := Container.Page[0];
  AssertNotNull('EhgkPageContainer first page must not be null after creation', Page);
  FreeAndNil(Container);
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
  for i:= 1 to UInt8.MaxValue-1 do
  begin
    PageContainer.AddPage;
  end;

  FAfterAddPageHandlerCalled := False;

  AssertEquals('Page container nust be filled', UInt8.MaxValue, PageContainer.PageCount);

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
begin
  PageContainer.AddPage;
  PageContainer.AddPage;
  for Index := 0 to PageContainer.PageCount-1 do
  begin
    PageContainer.Page[Index].Value := Index;
  end;
  AssertEquals('PageContainer must have 3 pages', 3, PageContainer.PageCount);

  AssertFalse('After delete page event should not be called', FAfterDeletePageHandlerCalled);

  PageContainer.DeletePage(1); // Delete not first and not last page
  AssertEquals('PageContainer must have 2 pages', 2, PageContainer.PageCount);

  AssertEquals('Page[0] value must be equals to 0', 0, PageContainer.Page[0].Value);
  AssertEquals('Page[1] value must be equals to 2', 2, PageContainer.Page[1].Value);

  AssertEquals('Deleted page value invalid', 1, FDeletedPage.Value);
end;

procedure TEhgkPageContainerTestCase.TestDeleteIndexOutOfBounds;
begin
  try
     PageContainer.AddPage;
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
    end;
    on E: Exception do
      Fail(Format('TContainerIndexOutOfBounds should be raised but %s raised', [E.QualifiedClassName]));
  end;
end;

procedure TEhgkPageContainerTestCase.TestDeleteSingle;
begin
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

procedure TEhgkPageContainerTestCase.AfterAddPageHandler(Sender: TObject);
begin
  FAfterAddPageHandlerCalled := True;
end;

procedure TEhgkPageContainerTestCase.AfterDeletePageHandler(Sender: TObject;
  Page: TEhgkPage);
begin
  FDeletedPage := Page;
  FAfterDeletePageHandlerCalled := True;
end;

procedure TEhgkPageContainerTestCase.SetUp;
begin
  PageContainer := TEhgkPageContainer.Create(Nil);
  PageContainer.Name := 'EhgkPageContainer1';
  FAfterAddPageHandlerCalled := False;
  PageContainer.AfterPageAdd := @AfterAddPageHandler;

  FAfterDeletePageHandlerCalled := False;
  FDeletedPage := Nil;
  PageContainer.AfterPageDelete := @AfterDeletePageHandler;
end;

procedure TEhgkPageContainerTestCase.TearDown;
begin
  FreeAndNil(PageContainer);
  FAfterAddPageHandlerCalled := False;

  FAfterDeletePageHandlerCalled := False;
  FDeletedPage := Nil;
end;

initialization

  RegisterTest(TEhgkPageContainerTestCase);
end.


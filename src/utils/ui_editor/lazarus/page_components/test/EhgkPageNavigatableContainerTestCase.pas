unit EhgkPageNavigatableContainerTestCase;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, EhgkPage, EhgkPageContainer;

type

  { TEhgkPageNavigatableContainerTestCase }

  TEhgkPageNavigatableContainerTestCase = class(TTestCase)
  private
    FPageIndexChangedHandlerCalled: Boolean;
    FAfterDeletePageHandlerCalled: Boolean;
    FDeletedPage: TEhgkPage;

    procedure OnPageIndexChangedHandler(Sender: TObject);
    procedure AfterDeletePageHandler(Sender: TObject; Page: TEhgkPage);
  protected
    PageContainer: TEhgkPageNavigatableContainer;
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure TestCreate;

    procedure TestCurrentIndexAfterConstruction;
    procedure TestCurrentIndexAfterAdd;
    procedure TestCurrentIndexOnDeletePage;
    procedure TestCurrentIndexOutOfBounds;

    procedure TestFirstSinglePageNavigate;
    procedure TestFirstMultiplePagesNavigate;

    procedure TestLastSinglePageNavigate;
    procedure TestLastMultiplePagesNavigate;

    procedure TestAfterDeleteFirstPage;
    procedure TestAfterDeleteLastPage;
    procedure TestAfterDeleteExistingPage;
    procedure TestAfterTryToDeleteIndexOutOfBounds;
    procedure TestAfterTryToDeleteSingle;

    procedure TestAfterDeletePageNotAssigned;

    procedure TestCurrentIndexAfterAddMultiple;
    procedure TestCurrentIndexOnDeleteFirstPage;
    procedure TestCurrentIndexOnDeleteLastPage;
    procedure TestCurrentIndexOnMultipleDeletes;
    procedure TestCurrentIndexOnDeleteWithIndexEqualToCurrent;
    procedure TestCurrentIndexAfterAddThenDelete;
    procedure TestCurrentIndexOnDeletePreservesPageValue;
  end;

implementation

{ TEhgkPageNavigatableContainerTestCase }

procedure TEhgkPageNavigatableContainerTestCase.OnPageIndexChangedHandler(
  Sender: TObject);
begin
  FPageIndexChangedHandlerCalled := True;
end;

procedure TEhgkPageNavigatableContainerTestCase.AfterDeletePageHandler(
  Sender: TObject; Page: TEhgkPage);
begin
  FreeAndNil(FDeletedPage);
  FAfterDeletePageHandlerCalled := True;
  FDeletedPage := TEhgkPage.Create(Nil);
  FDeletedPage.Value := Page.Value;
end;

procedure TEhgkPageNavigatableContainerTestCase.SetUp;
begin
     PageContainer := TEhgkPageNavigatableContainer.Create(Nil);
     PageContainer.Name := 'PageContainer1';

     FPageIndexChangedHandlerCalled := False;
     PageContainer.OnPageIndexChange := @OnPageIndexChangedHandler;

     FAfterDeletePageHandlerCalled := False;
     FDeletedPage := Nil;
     PageContainer.AfterPageDelete := @AfterDeletePageHandler;
end;

procedure TEhgkPageNavigatableContainerTestCase.TearDown;
begin
     FreeAndNil(PageContainer);

     FPageIndexChangedHandlerCalled := False;

     FreeAndNil(FDeletedPage);
     FAfterDeletePageHandlerCalled := False;
end;

procedure TEhgkPageNavigatableContainerTestCase.TestCreate;
var
  pnc: TEhgkPageNavigatableContainer;
begin
     pnc := TEhgkPageNavigatableContainer.Create(Nil);
     try
       AssertNotNull('After construction object should not be Nil', pnc);
       AssertEquals('Current index should be 0 after object construction', 0, pnc.CurrentPageIndex);
       AssertEquals('Page count should be 1', 1, PageContainer.PageCount);
       AssertEquals('Page index change event should not be called', False, FPageIndexChangedHandlerCalled);
     finally
       FreeAndNil(pnc);
     end;
end;

procedure TEhgkPageNavigatableContainerTestCase.TestCurrentIndexAfterConstruction;
begin
     AssertEquals('Current index should be 0 after object construction', 0, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 1', 1, PageContainer.PageCount);
     AssertEquals('Page index change event should not be called', False, FPageIndexChangedHandlerCalled);
end;

procedure TEhgkPageNavigatableContainerTestCase.TestCurrentIndexAfterAdd;
begin
     AssertEquals('Current index should be 0', 0, PageContainer.CurrentPageIndex);
     PageContainer.AddPage;
     AssertEquals('Current index should be 0', 0, PageContainer.CurrentPageIndex);

     PageContainer.CurrentPageIndex := 1;
     AssertEquals('Current index should be 1', 1, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 2', 2, PageContainer.PageCount);
     AssertEquals('Page index change event should be called', True, FPageIndexChangedHandlerCalled);
     FPageIndexChangedHandlerCalled := False;

     PageContainer.AddPage;
     AssertEquals('Current index should be 1', 1, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 3', 3, PageContainer.PageCount);
     AssertEquals('Page index change event should not be called', False, FPageIndexChangedHandlerCalled)
end;

procedure TEhgkPageNavigatableContainerTestCase.TestCurrentIndexOnDeletePage;
begin
     AssertEquals('Current index should be 0', 0, PageContainer.CurrentPageIndex);
     PageContainer.AddPage;
     AssertEquals('Current index should be 0', 0, PageContainer.CurrentPageIndex);

     PageContainer.CurrentPageIndex := 1;
     AssertEquals('Current index should be 1', 1, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 2', 2, PageContainer.PageCount);
     AssertEquals('Page index change event should be called', True, FPageIndexChangedHandlerCalled);
     FPageIndexChangedHandlerCalled := False;

     // DeletePage above current page index
     PageContainer.DeletePage(0);
     AssertEquals('Current index should be 0', 0, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 1', 1, PageContainer.PageCount);
     AssertEquals('Page index change event should be called', True, FPageIndexChangedHandlerCalled);
     FPageIndexChangedHandlerCalled := False;

     // DeletePage on current page index
     PageContainer.AddPage;
     PageContainer.CurrentPageIndex := 1;
     PageContainer.DeletePage(1);
     AssertEquals('Current index should be 0', 0, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 1', 1, PageContainer.PageCount);
     AssertEquals('Page index change event should be called', True, FPageIndexChangedHandlerCalled);
     FPageIndexChangedHandlerCalled := False;

     // Test DeletePage below current page index
     PageContainer.AddPage;
     PageContainer.AddPage;
     PageContainer.CurrentPageIndex := 1;
     AssertEquals('Current index should be 1', 1, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 3', 3, PageContainer.PageCount);
     AssertEquals('Page index change event should be called', True, FPageIndexChangedHandlerCalled);
     FPageIndexChangedHandlerCalled := False;
     PageContainer.DeletePage(2);
     AssertEquals('Current index should be 1', 1, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 2', 2, PageContainer.PageCount);
     AssertEquals('Page index change event should not be called', False, FPageIndexChangedHandlerCalled);
end;

procedure TEhgkPageNavigatableContainerTestCase.TestCurrentIndexOutOfBounds;
begin
     try
        PageContainer.CurrentPageIndex := 1;
        Fail('TContainerIndexOutOfBounds should be raised');
     except
       on E:TContainerIndexOutOfBoundsError do
       begin
         AssertEquals(
          'Wrong error message',
          'Index (1) is out of bounds for container PageContainer1',
          E.Message
         );
         AssertEquals('Page index change event should not be called', False, FPageIndexChangedHandlerCalled);
       end;
       on E: Exception do
          Fail('Exception should be a TContainerIndexOutOfBounds');
     end;

end;

procedure TEhgkPageNavigatableContainerTestCase.TestFirstSinglePageNavigate;
begin
     AssertEquals('Page index change event should not be called', False, FPageIndexChangedHandlerCalled);
     PageContainer.First;
     AssertEquals('Page index change event should not be called', False, FPageIndexChangedHandlerCalled);
     AssertEquals('Page index should be 0', 0, PageContainer.CurrentPageIndex);
end;

procedure TEhgkPageNavigatableContainerTestCase.TestFirstMultiplePagesNavigate;
begin
     PageContainer.AddPage;
     PageContainer.CurrentPageIndex := 1;
     AssertEquals('Page index change event should be called', True, FPageIndexChangedHandlerCalled);
     AssertEquals('Page index should be 1', 1, PageContainer.CurrentPageIndex);

     FPageIndexChangedHandlerCalled := False;
     PageContainer.First;
     AssertEquals('Page index should be 0', 0, PageContainer.CurrentPageIndex);
     AssertEquals('Page index change event should be called', True, FPageIndexChangedHandlerCalled);
end;

procedure TEhgkPageNavigatableContainerTestCase.TestLastSinglePageNavigate;
begin
     AssertEquals('Page index change event should not be called', False, FPageIndexChangedHandlerCalled);
     PageContainer.Last;
     AssertEquals('Page index change event should not be called', False, FPageIndexChangedHandlerCalled);
     AssertEquals('Page index should be 0', 0, PageContainer.CurrentPageIndex);
end;

procedure TEhgkPageNavigatableContainerTestCase.TestLastMultiplePagesNavigate;
begin
     PageContainer.AddPage;
     AssertEquals('Page index change event should not be called', False, FPageIndexChangedHandlerCalled);
     AssertEquals('Page index should be 0', 0, PageContainer.CurrentPageIndex);

     PageContainer.Last;
     AssertEquals('Page index should be 1', 1, PageContainer.CurrentPageIndex);
     AssertEquals('Page index change event should be called', True, FPageIndexChangedHandlerCalled);
end;

procedure TEhgkPageNavigatableContainerTestCase.TestAfterDeleteFirstPage;
var
  Index: UInt8;
  Value: TEhgkPageValue;
begin
    PageContainer.AddPage;

    for Index := 0 to PageContainer.PageCount - 1 do
    begin
      PageContainer.Page[Index].Value := Index;
    end;
    Value := PageContainer.Page[0].Value;

    AssertFalse('After page delete event should not be called', FAfterDeletePageHandlerCalled);
    PageContainer.DeletePage(0);
    AssertTrue('After page delete event should be called', FAfterDeletePageHandlerCalled);
    AssertEquals('Invalid deleted page value', Value, FDeletedPage.Value);
end;

procedure TEhgkPageNavigatableContainerTestCase.TestAfterDeleteLastPage;
var
  Index: UInt8;
  Value: TEhgkPageValue;
begin
    PageContainer.AddPage;

    for Index := 0 to PageContainer.PageCount - 1 do
    begin
      PageContainer.Page[Index].Value := Index;
    end;
    Value := PageContainer.Page[1].Value;

    AssertFalse('After page delete event should not be called', FAfterDeletePageHandlerCalled);
    PageContainer.DeletePage(1);

    AssertTrue('After page delete event should be called', FAfterDeletePageHandlerCalled);
    AssertEquals('Invalid deleted page value', Value, FDeletedPage.Value);
end;

procedure TEhgkPageNavigatableContainerTestCase.TestAfterDeleteExistingPage;
var
  Index: UInt8;
  Value: TEhgkPageValue;
begin
    PageContainer.AddPage;
    PageContainer.AddPage;

    for Index := 0 to PageContainer.PageCount - 1 do
    begin
      PageContainer.Page[Index].Value := Index;
    end;
    Value := PageContainer.Page[1].Value;

    AssertFalse('After page delete event should not be called', FAfterDeletePageHandlerCalled);
    PageContainer.DeletePage(1);

    AssertTrue('After page delete event should be called', FAfterDeletePageHandlerCalled);
    AssertEquals('Invalid deleted page value', Value, FDeletedPage.Value);
end;

procedure TEhgkPageNavigatableContainerTestCase.TestAfterTryToDeleteIndexOutOfBounds;
begin
  try
     PageContainer.DeletePage(10);
     Fail('TContainerIndexOutOfBounds should be raised');
  except
    on E: TContainerIndexOutOfBoundsError do
    begin
      AssertEquals(
        'Wrong error message',
        'Index (10) is out of bounds for container PageContainer1',
        E.Message
      );

      AssertFalse('After delete page event should not be called', FAfterDeletePageHandlerCalled);
    end;
    on E:Exception do
       Fail(Format('TContainerIndexOutOfBounds should be raised but %s raised', [E.QualifiedClassName]));
  end;
end;

procedure TEhgkPageNavigatableContainerTestCase.TestAfterTryToDeleteSingle;
begin
  try
     PageContainer.DeletePage(0);
     Fail('TContainerEmptyError should be raised');
  except
    on E: TContainerEmptyError do
    begin
      AssertFalse('After page delete event should not be called', FAfterDeletePageHandlerCalled);
    end;
    on E:Exception do
       Fail(Format('TContainerEmptyError should be raised but %s raised', [E.QualifiedClassName]));
  end;
end;

procedure TEhgkPageNavigatableContainerTestCase.TestAfterDeletePageNotAssigned;
begin
  PageContainer.AddPage;
  PageContainer.AfterPageDelete := Nil;

  PageContainer.DeletePage(0);
  AssertFalse('After delete page event should not be called', FAfterDeletePageHandlerCalled);
end;

procedure TEhgkPageNavigatableContainerTestCase.TestCurrentIndexAfterAddMultiple;
var
  Index: Cardinal;
begin
  // Начальное состояние
  AssertEquals('Initial CurrentPageIndex', 0, PageContainer.CurrentPageIndex);
  AssertEquals('Initial PageCount', 1, PageContainer.PageCount);
  FPageIndexChangedHandlerCalled := False;

  // Добавляем 3 страницы
  for Index := 1 to 3 do
  begin
    PageContainer.AddPage;
    AssertEquals(
      'CurrentPageIndex should remain 0 after AddPage',
      0,
      PageContainer.CurrentPageIndex
    );
    AssertEquals(
      'PageIndexChanged should not be called on AddPage',
      False,
      FPageIndexChangedHandlerCalled
    );
  end;

  AssertEquals('Final PageCount should be 4', 4, PageContainer.PageCount);
end;

procedure TEhgkPageNavigatableContainerTestCase.TestCurrentIndexOnDeleteFirstPage;
begin
  PageContainer.AddPage;
  PageContainer.AddPage;
  AssertEquals('PageCount should be 3', 3, PageContainer.PageCount);

  PageContainer.CurrentPageIndex := 2;
  AssertEquals('CurrentPageIndex should be 2', 2, PageContainer.CurrentPageIndex);
  FPageIndexChangedHandlerCalled := False;

  PageContainer.DeletePage(0);
  AssertEquals(
    'CurrentPageIndex should decrease by 1 when deleting page below it',
    1,
    PageContainer.CurrentPageIndex
  );
  AssertEquals('PageCount should be 2', 2, PageContainer.PageCount);
  AssertTrue(
    'PageIndexChanged should be called when CurrentPageIndex changes',
    FPageIndexChangedHandlerCalled
  );
end;

procedure TEhgkPageNavigatableContainerTestCase.TestCurrentIndexOnDeleteLastPage;
begin
  PageContainer.AddPage;
  AssertEquals('PageCount should be 2', 2, PageContainer.PageCount);

  PageContainer.CurrentPageIndex := 1;
  AssertEquals('CurrentPageIndex should be 1', 1, PageContainer.CurrentPageIndex);
  FPageIndexChangedHandlerCalled := False;

  PageContainer.DeletePage(1);
  AssertEquals(
    'CurrentPageIndex should wrap to last page when deleting current last',
    0,
    PageContainer.CurrentPageIndex
  );
  AssertEquals('PageCount should be 1', 1, PageContainer.PageCount);
  AssertTrue(
    'PageIndexChanged should be called when CurrentPageIndex changes (1 -> 0)',
    FPageIndexChangedHandlerCalled
  );
end;

procedure TEhgkPageNavigatableContainerTestCase.TestCurrentIndexOnMultipleDeletes;
var
  Index: Cardinal;
begin
  for Index := 1 to 3 do
    PageContainer.AddPage;
  AssertEquals('PageCount should be 4', 4, PageContainer.PageCount);

  PageContainer.CurrentPageIndex := 3;
  FPageIndexChangedHandlerCalled := False;

  PageContainer.DeletePage(0);
  AssertEquals('After delete[0]: CurrentPageIndex', 2, PageContainer.CurrentPageIndex);
  AssertEquals('After delete[0]: PageCount', 3, PageContainer.PageCount);
  FPageIndexChangedHandlerCalled := False;

  PageContainer.DeletePage(1);
  AssertEquals('After delete[1]: CurrentPageIndex', 1, PageContainer.CurrentPageIndex);
  AssertEquals('After delete[1]: PageCount', 2, PageContainer.PageCount);
  FPageIndexChangedHandlerCalled := False;

  PageContainer.DeletePage(1);
  AssertEquals(
    'After delete[current]: CurrentPageIndex wraps to last',
    0,
    PageContainer.CurrentPageIndex
  );
  AssertEquals('After delete[current]: PageCount', 1, PageContainer.PageCount);
  AssertTrue('PageIndexChanged should be called', FPageIndexChangedHandlerCalled);
end;

procedure TEhgkPageNavigatableContainerTestCase.TestCurrentIndexOnDeleteWithIndexEqualToCurrent;
begin
  PageContainer.AddPage;
  PageContainer.CurrentPageIndex := 1;
  FPageIndexChangedHandlerCalled := False;

  PageContainer.DeletePage(1);
  AssertEquals(
    'CurrentPageIndex should stay at 0 after deleting page at same index',
    0,
    PageContainer.CurrentPageIndex
  );
  AssertEquals('PageCount should be 1', 1, PageContainer.PageCount);
  AssertTrue(
    'PageIndexChanged should be called when CurrentPageIndex changes (1 -> 0)',
    FPageIndexChangedHandlerCalled
  );
end;

procedure TEhgkPageNavigatableContainerTestCase.TestCurrentIndexAfterAddThenDelete;
begin
  PageContainer.AddPage;
  PageContainer.AddPage;
  PageContainer.CurrentPageIndex := 2;
  AssertEquals('PageCount should be 3', 3, PageContainer.PageCount);
  FPageIndexChangedHandlerCalled := False;

  PageContainer.DeletePage(1);
  AssertEquals(
    'CurrentPageIndex should decrease when deleting below it',
    1,
    PageContainer.CurrentPageIndex
  );
  AssertEquals('PageCount should be 2', 2, PageContainer.PageCount);
  AssertTrue('PageIndexChanged should be called', FPageIndexChangedHandlerCalled);
  FPageIndexChangedHandlerCalled := False;

  PageContainer.AddPage;
  AssertEquals(
    'CurrentPageIndex should remain unchanged after AddPage',
    1,
    PageContainer.CurrentPageIndex
  );
  AssertEquals('PageCount should be 3', 3, PageContainer.PageCount);
  AssertFalse(
    'PageIndexChanged should not be called on AddPage',
    FPageIndexChangedHandlerCalled
  );
end;

procedure TEhgkPageNavigatableContainerTestCase.TestCurrentIndexOnDeletePreservesPageValue;
begin
  PageContainer.AddPage;
  PageContainer.AddPage;
  AssertEquals('PageCount should be 3', 3, PageContainer.PageCount);

  PageContainer.Page[0].Value := 10;
  PageContainer.Page[1].Value := 20;
  PageContainer.Page[2].Value := 30;

  PageContainer.CurrentPageIndex := 2;

  PageContainer.DeletePage(0);

  AssertEquals('CurrentPageIndex should be 1', 1, PageContainer.CurrentPageIndex);
  AssertEquals(
    'Page[1] should have value from original Page[2]',
    30,
    PageContainer.Page[1].Value
  );
  AssertEquals(
    'Page[0] should have value from original Page[0]',
    20,
    PageContainer.Page[0].Value
  );
end;


initialization

  RegisterTest(TEhgkPageNavigatableContainerTestCase);

end.


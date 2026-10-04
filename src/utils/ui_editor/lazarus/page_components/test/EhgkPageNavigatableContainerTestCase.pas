unit EhgkPageNavigatableContainerTestCase;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, EhgkPageContainer;

type

  { TEhgkPageNavigatableContainerTestCase }

  TEhgkPageNavigatableContainerTestCase = class(TTestCase)
  private
    FHandlerCalled: Boolean;
    procedure OnPageIndexChangedHandler(Sender: TObject);
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
  end;

implementation

{ TEhgkPageNavigatableContainerTestCase }

procedure TEhgkPageNavigatableContainerTestCase.OnPageIndexChangedHandler(
  Sender: TObject);
begin
  FHandlerCalled := True;
end;

procedure TEhgkPageNavigatableContainerTestCase.SetUp;
begin
     FHandlerCalled := False;
     PageContainer := TEhgkPageNavigatableContainer.Create(Nil);
     PageContainer.Name := 'PageContainer1';
     PageContainer.OnPageIndexChange := @OnPageIndexChangedHandler;
end;

procedure TEhgkPageNavigatableContainerTestCase.TearDown;
begin
     FreeAndNil(PageContainer);
     FHandlerCalled := False;
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
       AssertEquals('Page index change event should not be called', False, FHandlerCalled);
     finally
       FreeAndNil(pnc);
     end;
end;

procedure TEhgkPageNavigatableContainerTestCase.TestCurrentIndexAfterConstruction;
begin
     AssertEquals('Current index should be 0 after object construction', 0, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 1', 1, PageContainer.PageCount);
     AssertEquals('Page index change event should not be called', False, FHandlerCalled);
end;

procedure TEhgkPageNavigatableContainerTestCase.TestCurrentIndexAfterAdd;
begin
     AssertEquals('Current index should be 0', 0, PageContainer.CurrentPageIndex);
     PageContainer.AddPage;
     AssertEquals('Current index should be 0', 0, PageContainer.CurrentPageIndex);

     PageContainer.CurrentPageIndex := 1;
     AssertEquals('Current index should be 1', 1, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 2', 2, PageContainer.PageCount);
     AssertEquals('Page index change event should be called', True, FHandlerCalled);
     FHandlerCalled := False;

     PageContainer.AddPage;
     AssertEquals('Current index should be 1', 1, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 3', 3, PageContainer.PageCount);
     AssertEquals('Page index change event should not be called', False, FHandlerCalled)
end;

procedure TEhgkPageNavigatableContainerTestCase.TestCurrentIndexOnDeletePage;
begin
     AssertEquals('Current index should be 0', 0, PageContainer.CurrentPageIndex);
     PageContainer.AddPage;
     AssertEquals('Current index should be 0', 0, PageContainer.CurrentPageIndex);

     PageContainer.CurrentPageIndex := 1;
     AssertEquals('Current index should be 1', 1, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 2', 2, PageContainer.PageCount);
     AssertEquals('Page index change event should be called', True, FHandlerCalled);
     FHandlerCalled := False;

     // DeletePage above current page index
     PageContainer.DeletePage(0);
     AssertEquals('Current index should be 0', 0, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 1', 1, PageContainer.PageCount);
     AssertEquals('Page index change event should be called', True, FHandlerCalled);
     FHandlerCalled := False;

     // DeletePage on current page index
     PageContainer.AddPage;
     PageContainer.CurrentPageIndex := 1;
     PageContainer.DeletePage(1);
     AssertEquals('Current index should be 0', 0, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 1', 1, PageContainer.PageCount);
     AssertEquals('Page index change event should be called', True, FHandlerCalled);
     FHandlerCalled := False;

     // Test DeletePage below current page index
     PageContainer.AddPage;
     PageContainer.AddPage;
     PageContainer.CurrentPageIndex := 1;
     AssertEquals('Current index should be 1', 1, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 3', 3, PageContainer.PageCount);
     AssertEquals('Page index change event should be called', True, FHandlerCalled);
     FHandlerCalled := False;
     PageContainer.DeletePage(2);
     AssertEquals('Current index should be 1', 1, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 2', 2, PageContainer.PageCount);
     AssertEquals('Page index change event should not be called', False, FHandlerCalled);
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
         AssertEquals('Page index change event should not be called', False, FHandlerCalled);
       end;
       on E: Exception do
          Fail('Exception should be a TContainerIndexOutOfBounds');
     end;

end;

procedure TEhgkPageNavigatableContainerTestCase.TestFirstSinglePageNavigate;
begin
     AssertEquals('Page index change event should not be called', False, FHandlerCalled);
     PageContainer.First;
     AssertEquals('Page index change event should not be called', False, FHandlerCalled);
     AssertEquals('Page index should be 0', 0, PageContainer.CurrentPageIndex);
end;

procedure TEhgkPageNavigatableContainerTestCase.TestFirstMultiplePagesNavigate;
begin
     PageContainer.AddPage;
     PageContainer.CurrentPageIndex := 1;
     AssertEquals('Page index change event should be called', True, FHandlerCalled);
     AssertEquals('Page index should be 1', 1, PageContainer.CurrentPageIndex);

     FHandlerCalled := False;
     PageContainer.First;
     AssertEquals('Page index should be 0', 0, PageContainer.CurrentPageIndex);
     AssertEquals('Page index change event should be called', True, FHandlerCalled);
end;

procedure TEhgkPageNavigatableContainerTestCase.TestLastSinglePageNavigate;
begin
     AssertEquals('Page index change event should not be called', False, FHandlerCalled);
     PageContainer.Last;
     AssertEquals('Page index change event should not be called', False, FHandlerCalled);
     AssertEquals('Page index should be 0', 0, PageContainer.CurrentPageIndex);
end;

procedure TEhgkPageNavigatableContainerTestCase.TestLastMultiplePagesNavigate;
begin
     PageContainer.AddPage;
     AssertEquals('Page index change event should not be called', False, FHandlerCalled);
     AssertEquals('Page index should be 0', 0, PageContainer.CurrentPageIndex);

     PageContainer.Last;
     AssertEquals('Page index should be 1', 1, PageContainer.CurrentPageIndex);
     AssertEquals('Page index change event should be called', True, FHandlerCalled);
end;

initialization

  RegisterTest(TEhgkPageNavigatableContainerTestCase);

end.


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

    procedure TestCurrentIndex;
    procedure TestCurrentIndexOutOfBounds;

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

procedure TEhgkPageNavigatableContainerTestCase.TestCurrentIndex;
begin
     AssertEquals('Current index should be 0 after object construction', 0, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 1', 1, PageContainer.PageCount);
     AssertEquals('Page index change event should not be called', False, FHandlerCalled);

     PageContainer.AddPage;
     PageContainer.CurrentPageIndex := 1;
     AssertEquals('Current index should be 1', 1, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 2', 2, PageContainer.PageCount);
     AssertEquals('Page index change event should be called', True, FHandlerCalled);
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

initialization

  RegisterTest(TEhgkPageNavigatableContainerTestCase);

end.


unit EhgkPageNavigatableContainerTestCase;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, EhgkPageContainer;

type

  { TEhgkPageNavigatableContainerTestCase }

  TEhgkPageNavigatableContainerTestCase = class(TTestCase)
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

procedure TEhgkPageNavigatableContainerTestCase.SetUp;
begin
  PageContainer := TEhgkPageNavigatableContainer.Create(Nil);
  PageContainer.Name := 'PageContainer1';
end;

procedure TEhgkPageNavigatableContainerTestCase.TearDown;
begin
  FreeAndNil(PageContainer);
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
     finally
       FreeAndNil(pnc);
     end;
end;

procedure TEhgkPageNavigatableContainerTestCase.TestCurrentIndex;
begin
     AssertEquals('Current index should be 0 after object construction', 0, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 1', 1, PageContainer.PageCount);

     PageContainer.AddPage;
     PageContainer.CurrentPageIndex := 1;
     AssertEquals('Current index should be 1', 1, PageContainer.CurrentPageIndex);
     AssertEquals('Page count should be 2', 2, PageContainer.PageCount);
end;

procedure TEhgkPageNavigatableContainerTestCase.TestCurrentIndexOutOfBounds;
begin
     try
        PageContainer.CurrentPageIndex := 1;
        Fail('TContainerIndexOutOfBounds should be raised');
     except
       on E:TContainerIndexOutOfBounds do
       begin
         AssertEquals(
          'Wrong error message',
          'Index (1) is out of bounds for container PageContainer1',
          E.Message
        );
       end;
       on E: Exception do
          Fail('Exception should be a TContainerIndexOutOfBounds');
     end;

end;

initialization

  RegisterTest(TEhgkPageNavigatableContainerTestCase);

end.


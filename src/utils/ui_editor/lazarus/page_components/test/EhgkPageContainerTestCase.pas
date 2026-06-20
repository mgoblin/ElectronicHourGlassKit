unit EhgkPageContainerTestCase;

{$mode objfpc}{$H+}

{$inline on}
{$warn 6058 off}


interface

uses
  Classes, SysUtils, fpcunit, testregistry, EhgkPageContainer;

type

  { TEhgkPageContainerTestCase }

  TEhgkPageContainerTestCase = class(TTestCase)
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
    procedure TestDeleteFirst;
    procedure TestDeleteLast;
    procedure TestDeleteExisting;
    procedure TestDeleteIndexOutOfBounds;
    procedure TestDeleteSingle;
  end;

implementation

uses
  Dialogs, EhgkPage;

procedure TEhgkPageContainerTestCase.TestCreate;
var
  Container: TEhgkPageContainer;
  Page: TEhgkPage;
begin
  Container := TEhgkPageContainer.Create(Nil);
  AssertNotNull('EhgkPageContainer should be not nil after creation', Container);
  AssertEquals('EhgkPageContainer count must be 1 after creation', 1, Container.Count);
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
    on E: TContainerIndexOutOfBounds do
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
  Index := PageContainer.Add;
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
    PageContainer.Add;
  end;

  AssertEquals('Page container nust be filled', UInt8.MaxValue, PageContainer.Count);

  try
     PageContainer.Add;
     Fail('TContainerFullError must be raised');
  except
    on E: TContainerFullError do
    begin
      AssertEquals(
        'Wrong error message',
        'Container EhgkPageContainer1 is full',
        E.Message
      );
    end
    else
    begin
      Fail('TContainerFullError must be raised');
    end;
  end;
end;

procedure TEhgkPageContainerTestCase.TestDeleteFirst;
const
  Page1Value: TEhgkPageValue = 5;
var
  Page: TEhgkPage;
  Index: Integer;
begin
  Index := PageContainer.Add;
  AssertEquals('PageContainer must have 2 pages', 2, PageContainer.Count);
  Page := PageContainer.Page[Index];
  Page.Value := Page1Value;

  PageContainer.Delete(0);
  AssertEquals('PageContainer must have 1 page', 1, PageContainer.Count);
  AssertEquals(
    Format('Page value must be %d', [Page1Value]),
    Page1Value,
    PageContainer.Page[0].Value
  );
end;

procedure TEhgkPageContainerTestCase.TestDeleteLast;
const
  Page0Value: TEhgkPageValue = 3;
var
  Index: Integer;
  Page0: TEhgkPage;
begin
  Page0 := PageContainer.Page[0];
  Page0.Value := Page0Value;

  Index := PageContainer.Add;
  AssertEquals('PageContainer must have 2 pages', 2, PageContainer.Count);

  PageContainer.Delete(Index);
  AssertEquals('PageContainer must have 1 page', 1, PageContainer.Count);
  AssertEquals('', Page0.Value, PageContainer.Page[0].Value);
end;

procedure TEhgkPageContainerTestCase.TestDeleteExisting;
var
  Index: Integer;
begin
  PageContainer.Add;
  PageContainer.Add;
  for Index := 0 to PageContainer.Count-1 do
  begin
    PageContainer.Page[Index].Value := Index;
  end;
  AssertEquals('PageContainer must have 3 pages', 3, PageContainer.Count);

  PageContainer.Delete(1); // Delete not first and not last page
  AssertEquals('PageContainer must have 2 pages', 2, PageContainer.Count);

  AssertEquals('Page[0] value must be equals to 0', 0, PageContainer.Page[0].Value);
  AssertEquals('Page[1] value must be equals to 2', 2, PageContainer.Page[1].Value);
end;

procedure TEhgkPageContainerTestCase.TestDeleteIndexOutOfBounds;
begin
  try
     PageContainer.Delete(10);
     Fail('TContainerIndexOutOfBounds should be raised');
  except
    on E: TContainerIndexOutOfBounds do
    begin
      AssertEquals(
        'Wrong error message',
        'Index (10) is out of bounds for container EhgkPageContainer1',
        E.Message
      );
    end;
    on E: Exception do
      Fail(Format('TContainerIndexOutOfBounds should be raised but %s raised', [E.QualifiedClassName]));
  end;
end;

procedure TEhgkPageContainerTestCase.TestDeleteSingle;
begin
  try
    PageContainer.Delete(0);
    Fail('TEmptyContainerError should be raised');
  except
    on E: TContainerEmptyError do
    begin
      AssertEquals(
        'Wrong error message',
        'Container EhgkPageContainer1 can not be empty',
        E.Message
      );
    end else Fail('TEmptyContainerError should be raised');
  end;
end;

procedure TEhgkPageContainerTestCase.SetUp;
begin
  PageContainer := TEhgkPageContainer.Create(Nil);
  PageContainer.Name := 'EhgkPageContainer1';
end;

procedure TEhgkPageContainerTestCase.TearDown;
begin
  FreeAndNil(PageContainer);
end;

initialization

  RegisterTest(TEhgkPageContainerTestCase);
end.


unit EhgkPagesContainerTestCase;

{$mode objfpc}{$H+}

{$inline on}
{$warn 6058 off}


interface

uses
  Classes, SysUtils, fpcunit, testregistry, EhgkPageContainer;

type

  { TEhgkPagesContainerTestCase }

  TEhgkPagesContainerTestCase = class(TTestCase)
  protected
    PagesContainer: TEhgkPagesContainer;
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
  Dialogs, EhgkPage, fgl;

procedure TEhgkPagesContainerTestCase.TestCreate;
var
  Container: TEhgkPagesContainer;
  Page: TEhgkPage;
begin
  Container := TEhgkPagesContainer.Create(Nil);
  AssertNotNull('EhgkPagesContainer should be not nil after creation', Container);
  AssertEquals('EhgkPagesContainer count must be 1 after creation', 1, Container.Count);
  Page := Container.Page[0];
  AssertNotNull('EhgkPagesContainer first page must not be null after creation', Page);
  FreeAndNil(Container);
end;

procedure TEhgkPagesContainerTestCase.TestGetIndex;
var
  Page: TEhgkPage;
begin
  Page := PagesContainer.Page[0];
  AssertNotNull('Page[0] must not be Nil', Page);
end;

procedure TEhgkPagesContainerTestCase.TestGetIndexOutOfBounds;
begin
  try
    PagesContainer.Page[1];
    Fail('Index out of bounds exception must be raised');
  except
    on E: fgl.EListError do
    begin
      AssertEquals('Incorrect exception message', 'List index (1) out of bounds', E.Message);
    end
    else Fail('fgl.EListError must be raised');
  end;
end;

procedure TEhgkPagesContainerTestCase.TestAdd;
var
  Index: Integer;
begin
  Index := PagesContainer.Add;
  AssertEquals('Second added page must have index 1', 1, Index);

  PagesContainer.Page[0].Value := 0;
  PagesContainer.Page[1].Value := 1;

  AssertEquals('Page[0] should be equals to 0', 0, PagesContainer.Page[0].Value);
  AssertEquals('Page[1] should be equals to 1', 1, PagesContainer.Page[1].Value);
end;

procedure TEhgkPagesContainerTestCase.TestAddToFull;
var
  i: Integer;
begin
  for i:= 1 to UInt8.MaxValue-1 do
  begin
    PagesContainer.Add;
  end;

  AssertEquals('Pages container nust be filled', UInt8.MaxValue, PagesContainer.Count);

  try
     PagesContainer.Add;
     Fail('TContainerFullError must be raised');
  except
    on E: TContainerFullError do
    begin
      AssertEquals(
        'Wrong error message',
        'Container EhgkPagesContainer1 is full',
        E.Message
      );
    end
    else
    begin
      Fail('TContainerFullError must be raised');
    end;
  end;
end;

procedure TEhgkPagesContainerTestCase.TestDeleteFirst;
const
  Page1Value: TEhgkPageValue = 5;
var
  Page: TEhgkPage;
  Index: Integer;
begin
  Index := PagesContainer.Add;
  AssertEquals('PagesContainer must have 2 pages', 2, PagesContainer.Count);
  Page := PagesContainer.Page[Index];
  Page.Value := Page1Value;

  PagesContainer.Delete(0);
  AssertEquals('PagesContainer must have 1 page', 1, PagesContainer.Count);
  AssertEquals(
    Format('Page value must be %d', [Page1Value]),
    Page1Value,
    PagesContainer.Page[0].Value
  );
end;

procedure TEhgkPagesContainerTestCase.TestDeleteLast;
const
  Page0Value: TEhgkPageValue = 3;
var
  Index: Integer;
  Page0: TEhgkPage;
begin
  Page0 := PagesContainer.Page[0];
  Page0.Value := Page0Value;

  Index := PagesContainer.Add;
  AssertEquals('PagesContainer must have 2 pages', 2, PagesContainer.Count);

  PagesContainer.Delete(Index);
  AssertEquals('PagesContainer must have 1 page', 1, PagesContainer.Count);
  AssertEquals('', Page0.Value, PagesContainer.Page[0].Value);
end;

procedure TEhgkPagesContainerTestCase.TestDeleteExisting;
var
  Index: Integer;
begin
  PagesContainer.Add;
  PagesContainer.Add;
  for Index := 0 to PagesContainer.Count-1 do
  begin
    PagesContainer.Page[Index].Value := Index;
  end;
  AssertEquals('PagesContainer must have 3 pages', 3, PagesContainer.Count);

  PagesContainer.Delete(1); // Delete not first and not last page
  AssertEquals('PagesContainer must have 2 pages', 2, PagesContainer.Count);

  AssertEquals('Page[0] value must be equals to 0', 0, PagesContainer.Page[0].Value);
  AssertEquals('Page[1] value must be equals to 2', 2, PagesContainer.Page[1].Value);
end;

procedure TEhgkPagesContainerTestCase.TestDeleteIndexOutOfBounds;
begin
  try
     PagesContainer.Delete(10);
     Fail('fgl.EListError should be raised');
  except
    on E: fgl.EListError do
    begin
      AssertEquals(
        'Wrong error message',
        'List index (10) out of bounds',
        E.Message
      );
    end;
    on E: Exception do
      Fail(Format('fgl.EListError should be raised but %s raised', [E.QualifiedClassName]));
  end;
end;

procedure TEhgkPagesContainerTestCase.TestDeleteSingle;
begin
  try
    PagesContainer.Delete(0);
    Fail('TEmptyContainerError should be raised');
  except
    on E: TContainerEmptyError do
    begin
      AssertEquals(
        'Wrong error message',
        'Container EhgkPagesContainer1 can not be empty',
        E.Message
      );
    end else Fail('TEmptyContainerError should be raised');
  end;
end;

procedure TEhgkPagesContainerTestCase.SetUp;
begin
  PagesContainer := TEhgkPagesContainer.Create(Nil);
  PagesContainer.Name := 'EhgkPagesContainer1';
end;

procedure TEhgkPagesContainerTestCase.TearDown;
begin
  FreeAndNil(PagesContainer);
end;

initialization

  RegisterTest(TEhgkPagesContainerTestCase);
end.


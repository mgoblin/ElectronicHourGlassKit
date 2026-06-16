unit EhgkPagesContainerTestCase;

{$mode objfpc}{$H+}{$inline on}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, EhgkPagesContainer;

type

  { TEhgkPagesContainerTestCase }

  TEhgkPagesContainerTestCase = class(TTestCase)
  protected
    PagesContainer: TEhgkPagesContainer;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCreate;

    procedure TestIndex;
    procedure TestIndexOutOfBounds;
    procedure TestAdd;
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

procedure TEhgkPagesContainerTestCase.TestIndex;
var
  Page: TEhgkPage;
begin
  Page := PagesContainer.Page[0];
  AssertNotNull('Page[0] must not be Nil', Page);
end;

procedure TEhgkPagesContainerTestCase.TestIndexOutOfBounds;
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

procedure TEhgkPagesContainerTestCase.SetUp;
begin
  PagesContainer := TEhgkPagesContainer.Create(Nil);
end;

procedure TEhgkPagesContainerTestCase.TearDown;
begin
  FreeAndNil(PagesContainer);
end;

initialization

  RegisterTest(TEhgkPagesContainerTestCase);
end.


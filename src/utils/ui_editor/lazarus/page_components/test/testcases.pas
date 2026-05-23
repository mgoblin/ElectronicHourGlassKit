unit TestCases;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, EhgkPage;

type

  TCreateEhgkPageTestCase= class(TTestCase)
  published
    procedure TestCreate;
  end;

implementation

procedure TCreateEhgkPageTestCase.TestCreate;
var
  EhgkPage: TEhgkPage;
begin
  EhgkPage := TEhgkPage.Create(Nil);
  AssertNotNull('EhgkPage should be not nil after creation', EhgkPage);
end;



initialization

  RegisterTest(TCreateEhgkPageTestCase);
end.


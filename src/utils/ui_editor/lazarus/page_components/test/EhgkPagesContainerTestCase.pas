unit EhgkPagesContainerTestCase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, EhgkPagesContainer;

type

  TEhgkPagesContainerTestCase = class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestHookUp;
  end;

implementation

procedure TEhgkPagesContainerTestCase.TestHookUp;
begin
  // Fail('Write your own test');
end;

procedure TEhgkPagesContainerTestCase.SetUp;
begin

end;

procedure TEhgkPagesContainerTestCase.TearDown;
begin

end;

initialization

  RegisterTest(TEhgkPagesContainerTestCase);
end.


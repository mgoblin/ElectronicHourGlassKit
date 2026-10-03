unit EhgkPageNavigatableContainerTestCase;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, EhgkPageContainer;

type

  { TEhgkPageNavigatableContainerTestCase }

  TEhgkPageNavigatableContainerTestCase = class(TTestCase)

  published
    procedure TestCreate;

  end;

implementation

{ TEhgkPageNavigatableContainerTestCase }

procedure TEhgkPageNavigatableContainerTestCase.TestCreate;
begin

end;

initialization

  RegisterTest(TEhgkPageNavigatableContainerTestCase);

end.


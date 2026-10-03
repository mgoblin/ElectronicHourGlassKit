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
var
  pnc: TEhgkPageNavigatableContainer;
begin
     pnc := TEhgkPageNavigatableContainer.Create(Nil);
     try
       AssertNotNull('After construction object should not be Nil', pnc);
       AssertEquals('Current index should be 0 after object construction', 0, pnc.CurrentPageIndex);
     finally
       FreeAndNil(pnc);
     end;
end;

initialization

  RegisterTest(TEhgkPageNavigatableContainerTestCase);

end.


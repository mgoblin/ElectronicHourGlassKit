unit SimplifiedLedConstructorTestCase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, jsonparser, SimplifiedLed;

type

  TSimplifiedLedConstructorTestCase = class(TTestCase)
  published
    procedure TestConstructor;
  end;

implementation

procedure TSimplifiedLedConstructorTestCase.TestConstructor;
var
  LED: TSimplifiedLed;
begin
  try
     LED := TSimplifiedLed.Create(Nil);
     try
        AssertEquals(
          'LED control should be created with default width',
          SimplifiedLed.DefaultWidth,
          LED.Width
        );

        AssertEquals(
          'LED control should be created with default heigth',
          SimplifiedLed.DefaultHeight,
          LED.Height
        );

        AssertTrue(
          'LED control should be created in the ledOff state',
          LED.State = TLEDState.ledOff
        );

     finally
       FreeAndNil(LED);
     end;
  except
    on E: Exception do Fail(Format('Exception %s is raised: %s', [E.ClassName, E.Message]));
  end;

end;



initialization
  RegisterTest(TSimplifiedLedConstructorTestCase);
end.


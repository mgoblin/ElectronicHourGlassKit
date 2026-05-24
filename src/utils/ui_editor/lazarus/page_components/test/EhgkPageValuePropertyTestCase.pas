unit EhgkPageValuePropertyTestCase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, EhgkPage;

type

  { TEhgkValueValidatorTestCase }

  TEhgkValueValidatorTestCase = class(TTestCase)
  published
    procedure TestValidate_0;
    procedure TestValidate_1;
    procedure TestValidateMax;
    procedure TestValidateNagative;
    procedure TestValidateEmptySring;
    procedure TestValidateBlankString;
    procedure TestValdiateOverflow;
  end;

implementation

procedure TEhgkValueValidatorTestCase.TestValidate_0;
begin
  AssertTrue('0 is a valid value', TEhgkValueValidator.IsValid('0'));
end;

procedure TEhgkValueValidatorTestCase.TestValidate_1;
begin
  AssertTrue('1 is a valid value', TEhgkValueValidator.IsValid('0'));
end;

procedure TEhgkValueValidatorTestCase.TestValidateMax;
begin
  AssertTrue(
    'EHGK_PAGE_VALUE_MAX is a valid value',
    TEhgkValueValidator.IsValid(UIntToStr(UInt64(EHGK_PAGE_VALUE_MAX)))
  );
end;

procedure TEhgkValueValidatorTestCase.TestValidateNagative;
begin
  AssertFalse('-1 is not a valid value', TEhgkValueValidator.IsValid('-1'));
end;

procedure TEhgkValueValidatorTestCase.TestValidateEmptySring;
begin
  AssertFalse('Empty string is not a valid value', TEhgkValueValidator.IsValid(''));
end;

procedure TEhgkValueValidatorTestCase.TestValidateBlankString;
begin
  AssertFalse('Blank string is not a valid value', TEhgkValueValidator.IsValid(' '));
end;

procedure TEhgkValueValidatorTestCase.TestValdiateOverflow;
begin
  AssertFalse(
    'Numbers with non zero 57-63 bits  is not a valid value',
    TEhgkValueValidator.IsValid(UIntToStr(UInt64(EHGK_PAGE_VALUE_MAX + 1)))
  );
end;

initialization

  RegisterTest(TEhgkValueValidatorTestCase);
end.


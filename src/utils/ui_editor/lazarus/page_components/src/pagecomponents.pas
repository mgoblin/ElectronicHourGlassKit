{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit PageComponents;

{$warn 5023 off : no warning about unused units}
interface

uses
  EhgkPage, EhgkPagesContainer, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('EhgkPage', @EhgkPage.Register);
  RegisterUnit('EhgkPagesContainer', @EhgkPagesContainer.Register);
end;

initialization
  RegisterPackage('PageComponents', @Register);
end.

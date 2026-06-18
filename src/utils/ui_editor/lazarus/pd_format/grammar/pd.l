%{
program lexer;

uses SysUtils, lexlib;

procedure yyerror(s: string);  // Called by yyparse on error <- overload !
begin
  WriteLn(Format('Error: %s', [s]));
end;

%}

%x C_LINE_COMMENT 
%x C_BLOCK_COMMENT 

%%

"//"                    begin start(C_LINE_COMMENT); end;
<C_LINE_COMMENT>\n      begin start(0); end;
<C_LINE_COMMENT>.       begin end;

"/*"                    begin start(C_BLOCK_COMMENT); end;
<C_BLOCK_COMMENT>"*/"   begin start(0); end;
<C_BLOCK_COMMENT>\n     begin end;
<C_BLOCK_COMMENT>.      begin end;

L[0-9]+                 begin WriteLn(Format('LED:%s', [yytext])); end;

EMPTY_PAGE              begin WriteLn(yytext) end;

[ \t\n]                 begin end;

.                       yyerror('Character unexpected');

%%

begin
  WriteLn('Hello pd');
  yylex();
end.
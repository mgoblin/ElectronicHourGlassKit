%{

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

L[0-9]+                 begin 
                          WriteLn(Format('LED: %s', [yytext]));
                          yylval.yyInteger := StrToInt(yytext[2..Length(yytext)]);
                          return(LED);
                        end;

EMPTY_PAGE              begin 
                          WriteLn(yytext);
                          yylval.yyInteger := 0;
                          return(EMPTY_PAGE);
                        end; 

"|"                     begin
                          returnc(yytext[1]);
                        end;
","                     begin
                          returnc(yytext[1]);
                        end;                        

[ \t\n]                 ;

.                       yyerror('Character unexpected');

%%
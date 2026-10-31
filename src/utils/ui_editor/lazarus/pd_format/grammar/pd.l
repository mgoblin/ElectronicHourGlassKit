%{
(* 
  Definitions section.
  Pascal code placed here (types, constants, helper functions)
  becomes available to the rules below.
  In our case the section is intentionally empty: the tokens
  (LED, EMPTY_PAGE) and yylval come from the Yacc file (pd_parser.y)
  via {$include pd_lexer.pas}.
*)  

function ParseLedIndex(const s: string): Integer;
const
  MAX_LED_INDEX = 57;
begin
  if not TryStrToInt(Copy(s, 2, Length(s) - 1), Result) then
  begin
    yyerror(Format('Invalid LED index: %s', [s]));
    Result := 0;
  end
  else if (Result < 1) or (Result > MAX_LED_INDEX) then
  begin
    yyerror(Format('LED index out of bounds 1..%d: %s', [MAX_LED_INDEX, s]));
    Result := 0;
  end;
end;

var
  InBlockComment: Boolean = False;

 (* 
  Exclusive states LINE_COMMENT and BLOCK_COMMENT are declared below.
 *)
%}

%x LINE_COMMENT 
%x BLOCK_COMMENT 

%%
  { Rules section: comments and tokens }

"//"                  begin start(LINE_COMMENT); end;
<LINE_COMMENT>\n      begin start(0); end;
<LINE_COMMENT>.       begin end;

"/*"                  begin InBlockComment := True; start(BLOCK_COMMENT); end;
<BLOCK_COMMENT>"*/"   begin InBlockComment := False; start(0); end;
<BLOCK_COMMENT>\n     begin end;
<BLOCK_COMMENT>.      begin end;

L[0-9]+               begin
						{$IFDEF DEBUG} WriteLn(Format('LED: %s', [yytext])); {$ENDIF}
                        yylval.yyInteger := ParseLedIndex(yytext);
						return(LED);
                      end;

EMPTY_PAGE            begin 
					    {$IFDEF DEBUG} WriteLn(yytext); {$ENDIF}
					    yylval.yyInteger := 0;
					    return(EMPTY_PAGE);
                      end; 

"|"                   begin
                        returnc(yytext[1]);
                      end;
                      
","                   begin
                        returnc(yytext[1]);
                      end;                        

[ \t\n]               ;

.   				  begin yyerror('Character unexpected'); end;

%%


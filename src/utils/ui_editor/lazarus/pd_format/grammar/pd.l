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
var
  LedIndex: Int64;
begin
  if not TryStrToInt64(Copy(s, 2, Length(s) - 1), LedIndex) then
  begin
    if InvalidLedReason = '' then
      InvalidLedReason := Format('Line %d: LED index out of bounds 1..%d: %s',
                                 [LineNo, MAX_LED_INDEX, s]);
    Result := 0;
  end
  else if (LedIndex < 1) or (LedIndex > MAX_LED_INDEX) then
  begin
    if InvalidLedReason = '' then
      InvalidLedReason := Format('Line %d: LED index out of bounds 1..%d: %s',
                                 [LineNo, MAX_LED_INDEX, s]);
    Result := 0;
  end
  else
    Result := Integer(LedIndex);
end;

var
  InBlockComment: Boolean = False;
  // LineNo and BlockCommentStartLine are declared in pd_parser.y

 (* 
  Exclusive states LINE_COMMENT and BLOCK_COMMENT are declared below.
 *)
%}

%x LINE_COMMENT 
%x BLOCK_COMMENT 

NL (\r\n|\r|\n)

%%
  { Rules section: comments and tokens }

"//"                  begin start(LINE_COMMENT); end;
<LINE_COMMENT>{NL}    begin Inc(LineNo); start(0); end;
<LINE_COMMENT>.       begin end;

"/*"                  begin
                        InBlockComment := True;
                        BlockCommentStartLine := LineNo;
                        start(BLOCK_COMMENT);
                      end;
<BLOCK_COMMENT>"*/"   begin InBlockComment := False; start(0); end;
<BLOCK_COMMENT>{NL}   begin Inc(LineNo); end;
<BLOCK_COMMENT>.      begin end;

L[0-9]+               begin
                        {$IFDEF DEBUG} WriteLn(Format('LED: %s (line %d)', [yytext, LineNo])); {$ENDIF}
                        yylval.yyInteger := ParseLedIndex(yytext);
                        return(LED);
                      end;

EMPTY_PAGE            begin 
                        {$IFDEF DEBUG} WriteLn(Format('EMPTY_PAGE (line %d)', [LineNo])); {$ENDIF}
                        yylval.yyInteger := 0;
                        return(EMPTY_PAGE);
                      end; 

"|"                   begin
                        returnc(yytext[1]);
                      end;
                      
","                   begin
                        returnc(yytext[1]);
                      end;                        

[ \t]                 ;                          // spaces and tabs — ignore
{NL}                  begin Inc(LineNo); end;   // newline — bump line counter

.                     begin yyerror('Character unexpected'); end;

%%

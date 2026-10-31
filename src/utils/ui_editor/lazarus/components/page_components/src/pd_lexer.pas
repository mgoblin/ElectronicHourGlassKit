
(* lexical analyzer template (TP Lex V3.0), V1.0 3-2-91 AG *)

(* global definitions: *)
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

const LINE_COMMENT = 2;
const BLOCK_COMMENT = 4;



function yylex : Integer;

procedure yyaction ( yyruleno : Integer );
  (* local definitions: *)
  { Rules section: comments and tokens }

begin
  (* actions: *)
  case yyruleno of
  1:
                      begin start(LINE_COMMENT); end;
  2:
                      begin Inc(LineNo); start(0); end;
  3:
                      begin end;

  4:
                      begin
                        InBlockComment := True;
                        BlockCommentStartLine := LineNo;
                        start(BLOCK_COMMENT);
                      end;
  5:
                      begin InBlockComment := False; start(0); end;
  6:
                      begin Inc(LineNo); end;
  7:
                      begin end;

  8:
                      begin
                        {$IFDEF DEBUG} WriteLn(Format('LED: %s (line %d)', [yytext, LineNo])); {$ENDIF}
                        yylval.yyInteger := ParseLedIndex(yytext);
                        return(LED);
                      end;

  9:
                      begin 
                        {$IFDEF DEBUG} WriteLn(Format('EMPTY_PAGE (line %d)', [LineNo])); {$ENDIF}
                        yylval.yyInteger := 0;
                        return(EMPTY_PAGE);
                      end; 

  10:
                      begin
                        returnc(yytext[1]);
                      end;
                      
  11:
                      begin
                        returnc(yytext[1]);
                      end;                        

  12:
                      ;                          // spaces and tabs — ignore
  13:
                      begin Inc(LineNo); end;   // newline — bump line counter

  14:
                      begin yyerror('Character unexpected'); end;

  end;
end(*yyaction*);

(* DFA table: *)

type YYTRec = record
                cc : set of Char;
                s  : Integer;
              end;

const

yynmarks   = 27;
yynmatches = 27;
yyntrans   = 49;
yynstates  = 35;

yyk : array [1..yynmarks] of Integer = (
  { 0: }
  { 1: }
  { 2: }
  { 3: }
  { 4: }
  { 5: }
  { 6: }
  14,
  { 7: }
  14,
  { 8: }
  14,
  { 9: }
  10,
  14,
  { 10: }
  11,
  14,
  { 11: }
  12,
  14,
  { 12: }
  13,
  14,
  { 13: }
  13,
  { 14: }
  14,
  { 15: }
  2,
  3,
  { 16: }
  2,
  { 17: }
  3,
  { 18: }
  7,
  { 19: }
  6,
  7,
  { 20: }
  6,
  { 21: }
  7,
  { 22: }
  1,
  { 23: }
  4,
  { 24: }
  8,
  { 25: }
  { 26: }
  5,
  { 27: }
  { 28: }
  { 29: }
  { 30: }
  { 31: }
  { 32: }
  { 33: }
  { 34: }
  9
);

yym : array [1..yynmatches] of Integer = (
{ 0: }
{ 1: }
{ 2: }
{ 3: }
{ 4: }
{ 5: }
{ 6: }
  14,
{ 7: }
  14,
{ 8: }
  14,
{ 9: }
  10,
  14,
{ 10: }
  11,
  14,
{ 11: }
  12,
  14,
{ 12: }
  13,
  14,
{ 13: }
  13,
{ 14: }
  14,
{ 15: }
  2,
  3,
{ 16: }
  2,
{ 17: }
  3,
{ 18: }
  7,
{ 19: }
  6,
  7,
{ 20: }
  6,
{ 21: }
  7,
{ 22: }
  1,
{ 23: }
  4,
{ 24: }
  8,
{ 25: }
{ 26: }
  5,
{ 27: }
{ 28: }
{ 29: }
{ 30: }
{ 31: }
{ 32: }
{ 33: }
{ 34: }
  9
);

yyt : array [1..yyntrans] of YYTrec = (
{ 0: }
  ( cc: [ #1..#8,#11,#12,#14..#31,'!'..'+','-','.',
            '0'..'D','F'..'K','M'..'{','}'..#255 ]; s: 14),
  ( cc: [ #9,' ' ]; s: 11),
  ( cc: [ #10 ]; s: 13),
  ( cc: [ #13 ]; s: 12),
  ( cc: [ ',' ]; s: 10),
  ( cc: [ '/' ]; s: 6),
  ( cc: [ 'E' ]; s: 8),
  ( cc: [ 'L' ]; s: 7),
  ( cc: [ '|' ]; s: 9),
{ 1: }
  ( cc: [ #1..#8,#11,#12,#14..#31,'!'..'+','-','.',
            '0'..'D','F'..'K','M'..'{','}'..#255 ]; s: 14),
  ( cc: [ #9,' ' ]; s: 11),
  ( cc: [ #10 ]; s: 13),
  ( cc: [ #13 ]; s: 12),
  ( cc: [ ',' ]; s: 10),
  ( cc: [ '/' ]; s: 6),
  ( cc: [ 'E' ]; s: 8),
  ( cc: [ 'L' ]; s: 7),
  ( cc: [ '|' ]; s: 9),
{ 2: }
  ( cc: [ #1..#9,#11,#12,#14..#255 ]; s: 17),
  ( cc: [ #10 ]; s: 16),
  ( cc: [ #13 ]; s: 15),
{ 3: }
  ( cc: [ #1..#9,#11,#12,#14..#255 ]; s: 17),
  ( cc: [ #10 ]; s: 16),
  ( cc: [ #13 ]; s: 15),
{ 4: }
  ( cc: [ #1..#9,#11,#12,#14..')','+'..#255 ]; s: 21),
  ( cc: [ #10 ]; s: 20),
  ( cc: [ #13 ]; s: 19),
  ( cc: [ '*' ]; s: 18),
{ 5: }
  ( cc: [ #1..#9,#11,#12,#14..')','+'..#255 ]; s: 21),
  ( cc: [ #10 ]; s: 20),
  ( cc: [ #13 ]; s: 19),
  ( cc: [ '*' ]; s: 18),
{ 6: }
  ( cc: [ '*' ]; s: 23),
  ( cc: [ '/' ]; s: 22),
{ 7: }
  ( cc: [ '0'..'9' ]; s: 24),
{ 8: }
  ( cc: [ 'M' ]; s: 25),
{ 9: }
{ 10: }
{ 11: }
{ 12: }
  ( cc: [ #10 ]; s: 13),
{ 13: }
{ 14: }
{ 15: }
  ( cc: [ #10 ]; s: 16),
{ 16: }
{ 17: }
{ 18: }
  ( cc: [ '/' ]; s: 26),
{ 19: }
  ( cc: [ #10 ]; s: 20),
{ 20: }
{ 21: }
{ 22: }
{ 23: }
{ 24: }
  ( cc: [ '0'..'9' ]; s: 24),
{ 25: }
  ( cc: [ 'P' ]; s: 27),
{ 26: }
{ 27: }
  ( cc: [ 'T' ]; s: 28),
{ 28: }
  ( cc: [ 'Y' ]; s: 29),
{ 29: }
  ( cc: [ '_' ]; s: 30),
{ 30: }
  ( cc: [ 'P' ]; s: 31),
{ 31: }
  ( cc: [ 'A' ]; s: 32),
{ 32: }
  ( cc: [ 'G' ]; s: 33),
{ 33: }
  ( cc: [ 'E' ]; s: 34)
{ 34: }
);

yykl : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 1,
{ 2: } 1,
{ 3: } 1,
{ 4: } 1,
{ 5: } 1,
{ 6: } 1,
{ 7: } 2,
{ 8: } 3,
{ 9: } 4,
{ 10: } 6,
{ 11: } 8,
{ 12: } 10,
{ 13: } 12,
{ 14: } 13,
{ 15: } 14,
{ 16: } 16,
{ 17: } 17,
{ 18: } 18,
{ 19: } 19,
{ 20: } 21,
{ 21: } 22,
{ 22: } 23,
{ 23: } 24,
{ 24: } 25,
{ 25: } 26,
{ 26: } 26,
{ 27: } 27,
{ 28: } 27,
{ 29: } 27,
{ 30: } 27,
{ 31: } 27,
{ 32: } 27,
{ 33: } 27,
{ 34: } 27
);

yykh : array [0..yynstates-1] of Integer = (
{ 0: } 0,
{ 1: } 0,
{ 2: } 0,
{ 3: } 0,
{ 4: } 0,
{ 5: } 0,
{ 6: } 1,
{ 7: } 2,
{ 8: } 3,
{ 9: } 5,
{ 10: } 7,
{ 11: } 9,
{ 12: } 11,
{ 13: } 12,
{ 14: } 13,
{ 15: } 15,
{ 16: } 16,
{ 17: } 17,
{ 18: } 18,
{ 19: } 20,
{ 20: } 21,
{ 21: } 22,
{ 22: } 23,
{ 23: } 24,
{ 24: } 25,
{ 25: } 25,
{ 26: } 26,
{ 27: } 26,
{ 28: } 26,
{ 29: } 26,
{ 30: } 26,
{ 31: } 26,
{ 32: } 26,
{ 33: } 26,
{ 34: } 27
);

yyml : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 1,
{ 2: } 1,
{ 3: } 1,
{ 4: } 1,
{ 5: } 1,
{ 6: } 1,
{ 7: } 2,
{ 8: } 3,
{ 9: } 4,
{ 10: } 6,
{ 11: } 8,
{ 12: } 10,
{ 13: } 12,
{ 14: } 13,
{ 15: } 14,
{ 16: } 16,
{ 17: } 17,
{ 18: } 18,
{ 19: } 19,
{ 20: } 21,
{ 21: } 22,
{ 22: } 23,
{ 23: } 24,
{ 24: } 25,
{ 25: } 26,
{ 26: } 26,
{ 27: } 27,
{ 28: } 27,
{ 29: } 27,
{ 30: } 27,
{ 31: } 27,
{ 32: } 27,
{ 33: } 27,
{ 34: } 27
);

yymh : array [0..yynstates-1] of Integer = (
{ 0: } 0,
{ 1: } 0,
{ 2: } 0,
{ 3: } 0,
{ 4: } 0,
{ 5: } 0,
{ 6: } 1,
{ 7: } 2,
{ 8: } 3,
{ 9: } 5,
{ 10: } 7,
{ 11: } 9,
{ 12: } 11,
{ 13: } 12,
{ 14: } 13,
{ 15: } 15,
{ 16: } 16,
{ 17: } 17,
{ 18: } 18,
{ 19: } 20,
{ 20: } 21,
{ 21: } 22,
{ 22: } 23,
{ 23: } 24,
{ 24: } 25,
{ 25: } 25,
{ 26: } 26,
{ 27: } 26,
{ 28: } 26,
{ 29: } 26,
{ 30: } 26,
{ 31: } 26,
{ 32: } 26,
{ 33: } 26,
{ 34: } 27
);

yytl : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 10,
{ 2: } 19,
{ 3: } 22,
{ 4: } 25,
{ 5: } 29,
{ 6: } 33,
{ 7: } 35,
{ 8: } 36,
{ 9: } 37,
{ 10: } 37,
{ 11: } 37,
{ 12: } 37,
{ 13: } 38,
{ 14: } 38,
{ 15: } 38,
{ 16: } 39,
{ 17: } 39,
{ 18: } 39,
{ 19: } 40,
{ 20: } 41,
{ 21: } 41,
{ 22: } 41,
{ 23: } 41,
{ 24: } 41,
{ 25: } 42,
{ 26: } 43,
{ 27: } 43,
{ 28: } 44,
{ 29: } 45,
{ 30: } 46,
{ 31: } 47,
{ 32: } 48,
{ 33: } 49,
{ 34: } 50
);

yyth : array [0..yynstates-1] of Integer = (
{ 0: } 9,
{ 1: } 18,
{ 2: } 21,
{ 3: } 24,
{ 4: } 28,
{ 5: } 32,
{ 6: } 34,
{ 7: } 35,
{ 8: } 36,
{ 9: } 36,
{ 10: } 36,
{ 11: } 36,
{ 12: } 37,
{ 13: } 37,
{ 14: } 37,
{ 15: } 38,
{ 16: } 38,
{ 17: } 38,
{ 18: } 39,
{ 19: } 40,
{ 20: } 40,
{ 21: } 40,
{ 22: } 40,
{ 23: } 40,
{ 24: } 41,
{ 25: } 42,
{ 26: } 42,
{ 27: } 43,
{ 28: } 44,
{ 29: } 45,
{ 30: } 46,
{ 31: } 47,
{ 32: } 48,
{ 33: } 49,
{ 34: } 49
);


var yyn : Integer;

label start, scan, action;

begin

start:

  (* initialize: *)

  yynew;

scan:

  (* mark positions and matches: *)

  for yyn := yykl[yystate] to     yykh[yystate] do yymark(yyk[yyn]);
  for yyn := yymh[yystate] downto yyml[yystate] do yymatch(yym[yyn]);

  if yytl[yystate]>yyth[yystate] then goto action; (* dead state *)

  (* get next character: *)

  yyscan;

  (* determine action: *)

  yyn := yytl[yystate];
  while (yyn<=yyth[yystate]) and not (yyactchar in yyt[yyn].cc) do inc(yyn);
  if yyn>yyth[yystate] then goto action;
    (* no transition on yyactchar in this state *)

  (* switch to new state: *)

  yystate := yyt[yyn].s;

  goto scan;

action:

  (* execute action: *)

  if yyfind(yyrule) then
    begin
      yyaction(yyrule);
      if yyreject then goto action;
    end
  else if not yydefault and yywrap() then
    begin
      yyclear;
      return(0);
    end;

  if not yydone then goto start;

  yylex := yyretval;

end(*yylex*);



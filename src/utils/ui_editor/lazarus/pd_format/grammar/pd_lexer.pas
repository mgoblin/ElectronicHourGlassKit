
(* lexical analyzer template (TP Lex V3.0), V1.0 3-2-91 AG *)

(* global definitions: *)


const C_LINE_COMMENT = 2;
const C_BLOCK_COMMENT = 4;


function yylex : Integer;

procedure yyaction ( yyruleno : Integer );
  (* local definitions: *)

begin
  (* actions: *)
  case yyruleno of
  1:
                        begin start(C_LINE_COMMENT); end;
  2:
                        begin start(0); end;
  3:
                        begin end;

  4:
                        begin start(C_BLOCK_COMMENT); end;
  5:
                        begin start(0); end;
  6:
                        begin end;
  7:
                        begin end;

  8:
                        begin 
                          WriteLn(Format('LED: %s', [yytext]));
                          yylval.yyInteger := StrToInt(yytext[2..Length(yytext)]);
                          return(LED);
                        end;

  9:
                        begin 
                          WriteLn(yytext);
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
                        ;

  13:
                        yyerror('Character unexpected');

  end;
end(*yyaction*);

(* DFA table: *)

type YYTRec = record
                cc : set of Char;
                s  : Integer;
              end;

const

yynmarks   = 21;
yynmatches = 21;
yyntrans   = 40;
yynstates  = 32;

yyk : array [1..yynmarks] of Integer = (
  { 0: }
  { 1: }
  { 2: }
  { 3: }
  { 4: }
  { 5: }
  { 6: }
  13,
  { 7: }
  13,
  { 8: }
  13,
  { 9: }
  10,
  13,
  { 10: }
  11,
  13,
  { 11: }
  12,
  { 12: }
  12,
  13,
  { 13: }
  13,
  { 14: }
  2,
  { 15: }
  3,
  { 16: }
  7,
  { 17: }
  6,
  { 18: }
  7,
  { 19: }
  1,
  { 20: }
  4,
  { 21: }
  8,
  { 22: }
  { 23: }
  5,
  { 24: }
  { 25: }
  { 26: }
  { 27: }
  { 28: }
  { 29: }
  { 30: }
  { 31: }
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
  13,
{ 7: }
  13,
{ 8: }
  13,
{ 9: }
  10,
  13,
{ 10: }
  11,
  13,
{ 11: }
  12,
{ 12: }
  12,
  13,
{ 13: }
  13,
{ 14: }
  2,
{ 15: }
  3,
{ 16: }
  7,
{ 17: }
  6,
{ 18: }
  7,
{ 19: }
  1,
{ 20: }
  4,
{ 21: }
  8,
{ 22: }
{ 23: }
  5,
{ 24: }
{ 25: }
{ 26: }
{ 27: }
{ 28: }
{ 29: }
{ 30: }
{ 31: }
  9
);

yyt : array [1..yyntrans] of YYTrec = (
{ 0: }
  ( cc: [ #1..#8,#11..#31,'!'..'+','-','.','0'..'D',
            'F'..'K','M'..'{','}'..#255 ]; s: 13),
  ( cc: [ #9,' ' ]; s: 12),
  ( cc: [ #10 ]; s: 11),
  ( cc: [ ',' ]; s: 10),
  ( cc: [ '/' ]; s: 6),
  ( cc: [ 'E' ]; s: 8),
  ( cc: [ 'L' ]; s: 7),
  ( cc: [ '|' ]; s: 9),
{ 1: }
  ( cc: [ #1..#8,#11..#31,'!'..'+','-','.','0'..'D',
            'F'..'K','M'..'{','}'..#255 ]; s: 13),
  ( cc: [ #9,' ' ]; s: 12),
  ( cc: [ #10 ]; s: 11),
  ( cc: [ ',' ]; s: 10),
  ( cc: [ '/' ]; s: 6),
  ( cc: [ 'E' ]; s: 8),
  ( cc: [ 'L' ]; s: 7),
  ( cc: [ '|' ]; s: 9),
{ 2: }
  ( cc: [ #1..#9,#11..#255 ]; s: 15),
  ( cc: [ #10 ]; s: 14),
{ 3: }
  ( cc: [ #1..#9,#11..#255 ]; s: 15),
  ( cc: [ #10 ]; s: 14),
{ 4: }
  ( cc: [ #1..#9,#11..')','+'..#255 ]; s: 18),
  ( cc: [ #10 ]; s: 17),
  ( cc: [ '*' ]; s: 16),
{ 5: }
  ( cc: [ #1..#9,#11..')','+'..#255 ]; s: 18),
  ( cc: [ #10 ]; s: 17),
  ( cc: [ '*' ]; s: 16),
{ 6: }
  ( cc: [ '*' ]; s: 20),
  ( cc: [ '/' ]; s: 19),
{ 7: }
  ( cc: [ '0'..'9' ]; s: 21),
{ 8: }
  ( cc: [ 'M' ]; s: 22),
{ 9: }
{ 10: }
{ 11: }
{ 12: }
{ 13: }
{ 14: }
{ 15: }
{ 16: }
  ( cc: [ '/' ]; s: 23),
{ 17: }
{ 18: }
{ 19: }
{ 20: }
{ 21: }
  ( cc: [ '0'..'9' ]; s: 21),
{ 22: }
  ( cc: [ 'P' ]; s: 24),
{ 23: }
{ 24: }
  ( cc: [ 'T' ]; s: 25),
{ 25: }
  ( cc: [ 'Y' ]; s: 26),
{ 26: }
  ( cc: [ '_' ]; s: 27),
{ 27: }
  ( cc: [ 'P' ]; s: 28),
{ 28: }
  ( cc: [ 'A' ]; s: 29),
{ 29: }
  ( cc: [ 'G' ]; s: 30),
{ 30: }
  ( cc: [ 'E' ]; s: 31)
{ 31: }
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
{ 12: } 9,
{ 13: } 11,
{ 14: } 12,
{ 15: } 13,
{ 16: } 14,
{ 17: } 15,
{ 18: } 16,
{ 19: } 17,
{ 20: } 18,
{ 21: } 19,
{ 22: } 20,
{ 23: } 20,
{ 24: } 21,
{ 25: } 21,
{ 26: } 21,
{ 27: } 21,
{ 28: } 21,
{ 29: } 21,
{ 30: } 21,
{ 31: } 21
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
{ 11: } 8,
{ 12: } 10,
{ 13: } 11,
{ 14: } 12,
{ 15: } 13,
{ 16: } 14,
{ 17: } 15,
{ 18: } 16,
{ 19: } 17,
{ 20: } 18,
{ 21: } 19,
{ 22: } 19,
{ 23: } 20,
{ 24: } 20,
{ 25: } 20,
{ 26: } 20,
{ 27: } 20,
{ 28: } 20,
{ 29: } 20,
{ 30: } 20,
{ 31: } 21
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
{ 12: } 9,
{ 13: } 11,
{ 14: } 12,
{ 15: } 13,
{ 16: } 14,
{ 17: } 15,
{ 18: } 16,
{ 19: } 17,
{ 20: } 18,
{ 21: } 19,
{ 22: } 20,
{ 23: } 20,
{ 24: } 21,
{ 25: } 21,
{ 26: } 21,
{ 27: } 21,
{ 28: } 21,
{ 29: } 21,
{ 30: } 21,
{ 31: } 21
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
{ 11: } 8,
{ 12: } 10,
{ 13: } 11,
{ 14: } 12,
{ 15: } 13,
{ 16: } 14,
{ 17: } 15,
{ 18: } 16,
{ 19: } 17,
{ 20: } 18,
{ 21: } 19,
{ 22: } 19,
{ 23: } 20,
{ 24: } 20,
{ 25: } 20,
{ 26: } 20,
{ 27: } 20,
{ 28: } 20,
{ 29: } 20,
{ 30: } 20,
{ 31: } 21
);

yytl : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 9,
{ 2: } 17,
{ 3: } 19,
{ 4: } 21,
{ 5: } 24,
{ 6: } 27,
{ 7: } 29,
{ 8: } 30,
{ 9: } 31,
{ 10: } 31,
{ 11: } 31,
{ 12: } 31,
{ 13: } 31,
{ 14: } 31,
{ 15: } 31,
{ 16: } 31,
{ 17: } 32,
{ 18: } 32,
{ 19: } 32,
{ 20: } 32,
{ 21: } 32,
{ 22: } 33,
{ 23: } 34,
{ 24: } 34,
{ 25: } 35,
{ 26: } 36,
{ 27: } 37,
{ 28: } 38,
{ 29: } 39,
{ 30: } 40,
{ 31: } 41
);

yyth : array [0..yynstates-1] of Integer = (
{ 0: } 8,
{ 1: } 16,
{ 2: } 18,
{ 3: } 20,
{ 4: } 23,
{ 5: } 26,
{ 6: } 28,
{ 7: } 29,
{ 8: } 30,
{ 9: } 30,
{ 10: } 30,
{ 11: } 30,
{ 12: } 30,
{ 13: } 30,
{ 14: } 30,
{ 15: } 30,
{ 16: } 31,
{ 17: } 31,
{ 18: } 31,
{ 19: } 31,
{ 20: } 31,
{ 21: } 32,
{ 22: } 33,
{ 23: } 33,
{ 24: } 34,
{ 25: } 35,
{ 26: } 36,
{ 27: } 37,
{ 28: } 38,
{ 29: } 39,
{ 30: } 40,
{ 31: } 40
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



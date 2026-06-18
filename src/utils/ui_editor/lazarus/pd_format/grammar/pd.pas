
(* lexical analyzer template (TP Lex V3.0), V1.0 3-2-91 AG *)

(* global definitions: *)

function yylex : Integer;

procedure yyaction ( yyruleno : Integer );
  (* local definitions: *)
begin
  (* actions: *)
  case yyruleno of
  1:
    ECHO;
  2:
    ECHO;
  end;
end(*yyaction*);

(* DFA table: *)

type YYTRec = record
                cc : set of Char;
                s  : Integer;
              end;

const

yynmarks   = 2;
yynmatches = 2;
yyntrans   = 4;
yynstates  = 4;

yyk : array [1..yynmarks] of Integer = (
  { 0: }
  { 1: }
  { 2: }
  1,
  { 3: }
  2
);

yym : array [1..yynmatches] of Integer = (
{ 0: }
{ 1: }
{ 2: }
  1,
{ 3: }
  2
);

yyt : array [1..yyntrans] of YYTrec = (
{ 0: }
  ( cc: [ #1..#9,#11..#255 ]; s: 2),
  ( cc: [ #10 ]; s: 3),
{ 1: }
  ( cc: [ #1..#9,#11..#255 ]; s: 2),
  ( cc: [ #10 ]; s: 3)
{ 2: }
{ 3: }
);

yykl : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 1,
{ 2: } 1,
{ 3: } 2
);

yykh : array [0..yynstates-1] of Integer = (
{ 0: } 0,
{ 1: } 0,
{ 2: } 1,
{ 3: } 2
);

yyml : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 1,
{ 2: } 1,
{ 3: } 2
);

yymh : array [0..yynstates-1] of Integer = (
{ 0: } 0,
{ 1: } 0,
{ 2: } 1,
{ 3: } 2
);

yytl : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 3,
{ 2: } 5,
{ 3: } 5
);

yyth : array [0..yynstates-1] of Integer = (
{ 0: } 2,
{ 1: } 4,
{ 2: } 4,
{ 3: } 4
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



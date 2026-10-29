unit EhgkParser;

{$mode ObjFPC}{$H+}
{$inline on}

{$push}
{$WARN 6058 off}

interface

uses
  SysUtils, fgl;

type
  TPagesList = class(specialize TFPGList<UInt64>);

const
  LED        = 257;
  EMPTY_PAGE = 258;

type
  YYSType = record
    case Integer of
      1: (yyInteger: Integer);
      2: (yyUInt64: UInt64);
  end;

procedure ParsePages(const InputString: String; Pages: TPagesList);
procedure yyerror(s: string);

var
  yylval: YYSType;

implementation

uses
  Classes, yacclib, lexlib, StreamIO, EhgkLexer;

var
  PagesList: TPagesList;

  // Shared between yyparse and yyaction
  yyv: array [1..yymaxdepth] of YYSType;
  yysp: Integer;
  yyval: YYSType;

procedure yyerror(s: string);
begin
  WriteLn(Format('Error: %s', [s]));
end;

{ ---- parser tables ---- }

const
  _error = 256;

type
  YYARec = record
    sym, act: Integer;
  end;
  YYRRec = record
    len, sym: Integer;
  end;

const
  yynacts   = 11;
  yyngotos  = 11;
  yynstates = 13;
  yynrules  = 9;

  yya: array [1..yynacts] of YYARec = (
    { 0: }
    (sym: 257; act: 7),
    (sym: 258; act: 8),
    { 1: }
    (sym: 44; act: 9),
    (sym: 0; act: -1),
    { 2: }
    { 3: }
    (sym: 124; act: 10),
    (sym: 0; act: -4),
    (sym: 44; act: -4),
    { 4: }
    { 5: }
    { 6: }
    (sym: 0; act: 0),
    { 7: }
    { 8: }
    { 9: }
    (sym: 257; act: 7),
    (sym: 258; act: 8),
    { 10: }
    (sym: 257; act: 7)
    { 11: }
    { 12: }
  );

  yyg: array [1..yyngotos] of YYARec = (
    { 0: }
    (sym: -7; act: 1),
    (sym: -6; act: 2),
    (sym: -5; act: 3),
    (sym: -4; act: 4),
    (sym: -3; act: 5),
    (sym: -2; act: 6),
    { 1: }
    { 2: }
    { 3: }
    { 4: }
    { 5: }
    { 6: }
    { 7: }
    { 8: }
    { 9: }
    (sym: -6; act: 11),
    (sym: -5; act: 3),
    (sym: -4; act: 4),
    (sym: -3; act: 5),
    { 10: }
    (sym: -3; act: 12)
    { 11: }
    { 12: }
  );

  yyd: array [0..yynstates-1] of Integer = (
    { 0: } 0,
    { 1: } 0,
    { 2: } -2,
    { 3: } 0,
    { 4: } -5,
    { 5: } -6,
    { 6: } 0,
    { 7: } -8,
    { 8: } -9,
    { 9: } 0,
    { 10: } 0,
    { 11: } -3,
    { 12: } -7
  );

  yyal: array [0..yynstates-1] of Integer = (
    { 0: } 1,
    { 1: } 3,
    { 2: } 5,
    { 3: } 5,
    { 4: } 8,
    { 5: } 8,
    { 6: } 8,
    { 7: } 9,
    { 8: } 9,
    { 9: } 9,
    { 10: } 11,
    { 11: } 12,
    { 12: } 12
  );

  yyach: array [0..yynstates-1] of Integer = (
    { 0: } 2,
    { 1: } 4,
    { 2: } 4,
    { 3: } 7,
    { 4: } 7,
    { 5: } 7,
    { 6: } 8,
    { 7: } 8,
    { 8: } 8,
    { 9: } 10,
    { 10: } 11,
    { 11: } 11,
    { 12: } 11
  );

  yygl: array [0..yynstates-1] of Integer = (
    { 0: } 1,
    { 1: } 7,
    { 2: } 7,
    { 3: } 7,
    { 4: } 7,
    { 5: } 7,
    { 6: } 7,
    { 7: } 7,
    { 8: } 7,
    { 9: } 7,
    { 10: } 11,
    { 11: } 12,
    { 12: } 12
  );

  yygh: array [0..yynstates-1] of Integer = (
    { 0: } 6,
    { 1: } 6,
    { 2: } 6,
    { 3: } 6,
    { 4: } 6,
    { 5: } 6,
    { 6: } 6,
    { 7: } 6,
    { 8: } 6,
    { 9: } 10,
    { 10: } 11,
    { 11: } 11,
    { 12: } 11
  );

  yyr: array [1..yynrules] of YYRRec = (
    { 1: } (len: 1; sym: -2),
    { 2: } (len: 1; sym: -7),
    { 3: } (len: 3; sym: -7),
    { 4: } (len: 1; sym: -6),
    { 5: } (len: 1; sym: -6),
    { 6: } (len: 1; sym: -5),
    { 7: } (len: 3; sym: -5),
    { 8: } (len: 1; sym: -3),
    { 9: } (len: 1; sym: -4)
  );

function yyact(state, sym: Integer; var act: Integer): Boolean;
var
  k: Integer;
begin
  k := yyal[state];
  while (k <= yyach[state]) and (yya[k].sym <> sym) do
    Inc(k);
  if k > yyach[state] then
    yyact := False
  else
  begin
    act := yya[k].act;
    yyact := True;
  end;
end;

function yygoto(state, sym: Integer; var nstate: Integer): Boolean;
var
  k: Integer;
begin
  k := yygl[state];
  while (k <= yygh[state]) and (yyg[k].sym <> sym) do
    Inc(k);
  if k > yygh[state] then
    yygoto := False
  else
  begin
    nstate := yyg[k].act;
    yygoto := True;
  end;
end;

procedure yyaction(yyruleno: Integer);
begin
  case yyruleno of
    1: begin
         WriteLn('Done');
         yyaccept;
       end;
    2: begin
         PagesList.Add(yyv[yysp-0].yyUInt64);
       end;
    3: begin
         PagesList.Add(yyv[yysp-0].yyUInt64);
       end;
    4: begin
         yyval := yyv[yysp-0];
       end;
    5: begin
         yyval.yyUInt64 := yyv[yysp-0].yyUInt64;
         WriteLn(Format('Empty LEDs line: %d', [yyval.yyUInt64]));
       end;
    6: begin
         yyval.yyUInt64 := yyv[yysp-0].yyUInt64;
         WriteLn(Format('One LED line: %d', [yyval.yyUInt64]));
       end;
    7: begin
         yyval.yyUInt64 := yyv[yysp-2].yyUInt64 + yyv[yysp-0].yyUInt64;
         WriteLn(Format('Multi LEDs line: %d', [yyval.yyUInt64]));
       end;
    8: begin
         if (yyv[yysp-0].yyInteger > 0) and (yyv[yysp-0].yyInteger < 58) then
         begin
           yyval.yyUInt64 := 1 shl (yyv[yysp-0].yyInteger - 1);
           WriteLn(Format('L%d value: %d', [yyv[yysp-0].yyInteger, yyval.yyUInt64]));
         end
         else
         begin
           yyerror(Format('LED index %d is out of bounds 1..56',
             [yyv[yysp-0].yyInteger]));
         end;
       end;
    9: begin
         yyval.yyUInt64 := yyv[yysp-0].yyInteger;
         WriteLn(Format('EMPTY_PAGE value: %d', [yyval.yyUInt64]));
       end;
  end;
end;

function yyparse: Integer;
var
  yystate, yyn: Integer;
  yys: array [1..yymaxdepth] of Integer;
label
  parse, next, error, errlab, shift, reduce, accept, abort;
begin
  yystate := 0; yychar := -1; yynerrs := 0; yyerrflag := 0; yysp := 0;

{$ifdef yydebug}
  yydebug := True;
{$else}
  yydebug := False;
{$endif}

parse:
  Inc(yysp);
  if yysp > yymaxdepth then
  begin
    yyerror('yyparse stack overflow');
    goto abort;
  end;
  yys[yysp] := yystate;
  yyv[yysp] := yyval;

next:
  if (yyd[yystate] = 0) and (yychar = -1) then
  begin
    yychar := yylex;
    if yychar < 0 then
      yychar := 0;
  end;

  if yydebug then
    WriteLn('state ', yystate, ', char ', yychar);

  yyn := yyd[yystate];
  if yyn <> 0 then
    goto reduce;

  if not yyact(yystate, yychar, yyn) then
    goto error
  else if yyn > 0 then
    goto shift
  else if yyn < 0 then
    goto reduce
  else
    goto accept;

error:
  if yyerrflag = 0 then
    yyerror('syntax error');

errlab:
  if yyerrflag = 0 then
    Inc(yynerrs);

  if yyerrflag <= 2 then
  begin
    yyerrflag := 3;
    while (yysp > 0) and not (yyact(yys[yysp], _error, yyn) and (yyn > 0)) do
    begin
      if yydebug then
        if yysp > 1 then
          WriteLn('error recovery pops state ', yys[yysp],
            ', uncovers ', yys[yysp-1])
        else
          WriteLn('error recovery fails ... abort');
      Dec(yysp);
    end;
    if yysp = 0 then
      goto abort;
    yystate := yyn;
    goto parse;
  end
  else
  begin
    if yydebug then
      WriteLn('error recovery discards char ', yychar);
    if yychar = 0 then
      goto abort;
    yychar := -1;
    goto next;
  end;

shift:
  yystate := yyn;
  yychar := -1;
  yyval := yylval;
  if yyerrflag > 0 then
    Dec(yyerrflag);
  goto parse;

reduce:
  if yydebug then
    WriteLn('reduce ', -yyn);
  yyflag := yyfnone;
  yyaction(-yyn);
  Dec(yysp, yyr[-yyn].len);
  if yygoto(yys[yysp], yyr[-yyn].sym, yyn) then
    yystate := yyn;

  case yyflag of
    yyfaccept: goto accept;
    yyfabort:  goto abort;
    yyferror:  goto errlab;
  end;
  goto parse;

accept:
  yyparse := 0;
  Exit;

abort:
  yyparse := 1;
  Exit;
end;

procedure ParsePages(const InputString: String; Pages: TPagesList);
var
  Stream: TStringStream;
  i: Integer;
begin
  PagesList := TPagesList.Create;
  Stream := TStringStream.Create(InputString);
  try
    AssignStream(yyinput, Stream);
    Reset(yyinput);

    yyparse;

    for i := 0 to PagesList.Count - 1 do
      Pages.Add(PagesList[i]);
  finally
    CloseFile(yyinput);
    Stream.Free;
    FreeAndNil(PagesList);
  end;
end;
end.

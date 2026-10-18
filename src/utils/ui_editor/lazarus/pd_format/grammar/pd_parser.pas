
(* Yacc parser template (TP Yacc V3.0), V1.2 6-17-91 AG *)

(* global definitions: *)

program pd_parser;

{$mode ObjFPC}
{$inline on}

{$push}
{$WARN 6058 off}

uses SysUtils, yacclib, lexlib, fgl;

type
  TPagesList = class(specialize TFPGList<UInt64>);

var
  PagesList: TPagesList;   

procedure yyerror(s: string);  // Called by yyparse on error <- overload !
begin
  WriteLn(Format('Error: %s', [s]));
end;

const LED = 257;
const EMPTY_PAGE = 258;

type YYSType = record case Integer of
                 1 : ( yyInteger : Integer );
                 2 : ( yyUInt64 : UInt64 );
               end(*YYSType*);

var yylval : YYSType;

function yylex : Integer; forward;

function yyparse : Integer;

var yystate, yysp, yyn : Integer;
    yys : array [1..yymaxdepth] of Integer;
    yyv : array [1..yymaxdepth] of YYSType;
    yyval : YYSType;

procedure yyaction ( yyruleno : Integer );
  (* local definitions: *)
begin
  (* actions: *)
  case yyruleno of
   1 : begin
         Writeln('Done'); yyaccept; 
       end;
   2 : begin
         
         PagesList.Add(yyv[yysp-0].yyUInt64);
         
       end;
   3 : begin
         
         PagesList.Add(yyv[yysp-0].yyUInt64);
         
       end;
   4 : begin
         yyval := yyv[yysp-0];
       end;
   5 : begin
         
         yyval.yyUInt64 := yyv[yysp-0].yyUInt64; 
         WriteLn(Format('Empty LEDs line: %d', [yyval.yyUInt64])); 
         
       end;
   6 : begin
         
         yyval.yyUInt64 := yyv[yysp-0].yyUInt64;
         WriteLn(Format('One LED line: %d', [yyval.yyUInt64])); 
         
       end;
   7 : begin
         
         yyval.yyUInt64 := yyv[yysp-2].yyUInt64 + yyv[yysp-0].yyUInt64;
         WriteLn(Format('Multi LEDs line: %d', [yyval.yyUInt64])); 
         
       end;
   8 : begin
         if (yyv[yysp-0].yyInteger > 0) and (yyv[yysp-0].yyInteger < 58) then
         begin
         yyval.yyUInt64 := 1 shl (yyv[yysp-0].yyInteger - 1); 
         WriteLn(Format('L%d value: %d', [yyv[yysp-0].yyInteger, yyval.yyUInt64])); 
         end else
         begin
         yyerror(Format('LED index %d is out of bounds 1..56', [yyv[yysp-0].yyInteger]));
         end;  
       end;
   9 : begin
         yyval.yyUInt64 := yyv[yysp-0].yyInteger; WriteLn(Format('EMPTY_PAGE value: %d', [yyval.yyUInt64])); 
       end;
  end;
end(*yyaction*);

(* parse table: *)

type YYARec = record
                sym, act : Integer;
              end;
     YYRRec = record
                len, sym : Integer;
              end;

const

yynacts   = 11;
yyngotos  = 11;
yynstates = 13;
yynrules  = 9;

yya : array [1..yynacts] of YYARec = (
{ 0: }
  ( sym: 257; act: 7 ),
  ( sym: 258; act: 8 ),
{ 1: }
  ( sym: 44; act: 9 ),
  ( sym: 0; act: -1 ),
{ 2: }
{ 3: }
  ( sym: 124; act: 10 ),
  ( sym: 0; act: -4 ),
  ( sym: 44; act: -4 ),
{ 4: }
{ 5: }
{ 6: }
  ( sym: 0; act: 0 ),
{ 7: }
{ 8: }
{ 9: }
  ( sym: 257; act: 7 ),
  ( sym: 258; act: 8 ),
{ 10: }
  ( sym: 257; act: 7 )
{ 11: }
{ 12: }
);

yyg : array [1..yyngotos] of YYARec = (
{ 0: }
  ( sym: -7; act: 1 ),
  ( sym: -6; act: 2 ),
  ( sym: -5; act: 3 ),
  ( sym: -4; act: 4 ),
  ( sym: -3; act: 5 ),
  ( sym: -2; act: 6 ),
{ 1: }
{ 2: }
{ 3: }
{ 4: }
{ 5: }
{ 6: }
{ 7: }
{ 8: }
{ 9: }
  ( sym: -6; act: 11 ),
  ( sym: -5; act: 3 ),
  ( sym: -4; act: 4 ),
  ( sym: -3; act: 5 ),
{ 10: }
  ( sym: -3; act: 12 )
{ 11: }
{ 12: }
);

yyd : array [0..yynstates-1] of Integer = (
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

yyal : array [0..yynstates-1] of Integer = (
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

yyah : array [0..yynstates-1] of Integer = (
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

yygl : array [0..yynstates-1] of Integer = (
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

yygh : array [0..yynstates-1] of Integer = (
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

yyr : array [1..yynrules] of YYRRec = (
{ 1: } ( len: 1; sym: -2 ),
{ 2: } ( len: 1; sym: -7 ),
{ 3: } ( len: 3; sym: -7 ),
{ 4: } ( len: 1; sym: -6 ),
{ 5: } ( len: 1; sym: -6 ),
{ 6: } ( len: 1; sym: -5 ),
{ 7: } ( len: 3; sym: -5 ),
{ 8: } ( len: 1; sym: -3 ),
{ 9: } ( len: 1; sym: -4 )
);


const _error = 256; (* error token *)

function yyact(state, sym : Integer; var act : Integer) : Boolean;
  (* search action table *)
  var k : Integer;
  begin
    k := yyal[state];
    while (k<=yyah[state]) and (yya[k].sym<>sym) do inc(k);
    if k>yyah[state] then
      yyact := false
    else
      begin
        act := yya[k].act;
        yyact := true;
      end;
  end(*yyact*);

function yygoto(state, sym : Integer; var nstate : Integer) : Boolean;
  (* search goto table *)
  var k : Integer;
  begin
    k := yygl[state];
    while (k<=yygh[state]) and (yyg[k].sym<>sym) do inc(k);
    if k>yygh[state] then
      yygoto := false
    else
      begin
        nstate := yyg[k].act;
        yygoto := true;
      end;
  end(*yygoto*);

label parse, next, error, errlab, shift, reduce, accept, abort;

begin(*yyparse*)

  (* initialize: *)

  yystate := 0; yychar := -1; yynerrs := 0; yyerrflag := 0; yysp := 0;

{$ifdef yydebug}
  yydebug := true;
{$else}
  yydebug := false;
{$endif}

parse:

  (* push state and value: *)

  inc(yysp);
  if yysp>yymaxdepth then
    begin
      yyerror('yyparse stack overflow');
      goto abort;
    end;
  yys[yysp] := yystate; yyv[yysp] := yyval;

next:

  if (yyd[yystate]=0) and (yychar=-1) then
    (* get next symbol *)
    begin
      yychar := yylex; if yychar<0 then yychar := 0;
    end;

  if yydebug then writeln('state ', yystate, ', char ', yychar);

  (* determine parse action: *)

  yyn := yyd[yystate];
  if yyn<>0 then goto reduce; (* simple state *)

  (* no default action; search parse table *)

  if not yyact(yystate, yychar, yyn) then goto error
  else if yyn>0 then                      goto shift
  else if yyn<0 then                      goto reduce
  else                                    goto accept;

error:

  (* error; start error recovery: *)

  if yyerrflag=0 then yyerror('syntax error');

errlab:

  if yyerrflag=0 then inc(yynerrs);     (* new error *)

  if yyerrflag<=2 then                  (* incomplete recovery; try again *)
    begin
      yyerrflag := 3;
      (* uncover a state with shift action on error token *)
      while (yysp>0) and not ( yyact(yys[yysp], _error, yyn) and
                               (yyn>0) ) do
        begin
          if yydebug then
            if yysp>1 then
              writeln('error recovery pops state ', yys[yysp], ', uncovers ',
                      yys[yysp-1])
            else
              writeln('error recovery fails ... abort');
          dec(yysp);
        end;
      if yysp=0 then goto abort; (* parser has fallen from stack; abort *)
      yystate := yyn;            (* simulate shift on error *)
      goto parse;
    end
  else                                  (* no shift yet; discard symbol *)
    begin
      if yydebug then writeln('error recovery discards char ', yychar);
      if yychar=0 then goto abort; (* end of input; abort *)
      yychar := -1; goto next;     (* clear lookahead char and try again *)
    end;

shift:

  (* go to new state, clear lookahead character: *)

  yystate := yyn; yychar := -1; yyval := yylval;
  if yyerrflag>0 then dec(yyerrflag);

  goto parse;

reduce:

  (* execute action, pop rule from stack, and go to next state: *)

  if yydebug then writeln('reduce ', -yyn);

  yyflag := yyfnone; yyaction(-yyn);
  dec(yysp, yyr[-yyn].len);
  if yygoto(yys[yysp], yyr[-yyn].sym, yyn) then yystate := yyn;

  (* handle action calls to yyaccept, yyabort and yyerror: *)

  case yyflag of
    yyfaccept : goto accept;
    yyfabort  : goto abort;
    yyferror  : goto errlab;
  end;

  goto parse;

accept:

  yyparse := 0; exit;

abort:

  yyparse := 1; exit;

end(*yyparse*);


{$include pd_lexer.pas}

function ReadStdin(): String;
var
  FullInput: String;
  Line: String;
begin
  FullInput := '';

  while not EOF do
  begin
    Readln(Line);
    FullInput := FullInput + Line + LineEnding;
  end;
  Result := FullInput;
end;

procedure ParsePages(inputString: String; pages: TPagesList);
const
  fileName: String = 'parse.txt';
var 
  srcText: TextFile;
  i: Integer;
begin
  Assign(srcText, fileName);
  try
    Rewrite(srcText);
    Write(srcText, inputString);
  finally
    CloseFile(srcText);
  end;

  Reset(srcText);

  PagesList := TPagesList.Create();
  try
    yyinput := srcText;
    yyparse ();
    
    for i := 0 to PagesList.Count-1 do
    begin
      pages.Add(PagesList[i]);
    end;
  finally
    FreeAndNil(PagesList);
  end;  
end;

var
  i: Integer;
  inputString: String;
  pages: TPagesList; 
begin
  pages := TPagesList.Create();
  try
    inputString := ReadStdin();
    ParsePages(inputString, pages);
    
    WriteLn(Format('%d pages parsed', [pages.Count]));
    for i := 0 to pages.Count-1 do
    begin
      WriteLn(Format('%d => %d', [i + 1, pages[i]]));
    end;
  finally
    FreeAndNil(pages);
  end;  
end.

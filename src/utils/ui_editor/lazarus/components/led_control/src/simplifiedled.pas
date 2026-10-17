unit SimplifiedLed;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LResources, LCLType;

const
  // Fallback size used while bitmaps are not loaded yet
  DefaultW = 32;
  DefaultH = 32;

type
  TLedState = (lsOff, lsOn);

  TSimplifiedLed = class(TCustomControl)
  private
    FBitmaps: array[TLedState] of TBitmap;
    FState: TLedState;
    procedure SetState(AValue: TLedState);
    procedure BitmapChanged(Sender: TObject);
    procedure AdjustSizeToBitmap;
    procedure LoadBitmapsFromResources;
  protected
    procedure Paint; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure DoExit; override;
    procedure DoEnter; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure DblClick; override;
  published
    property State: TLedState read FState write SetState default lsOff;
    property TabStop default True;
    property OnKeyDown;
    property OnKeyUp;
    property OnClick;
    property OnDblClick;
  end;

procedure Register;

implementation

const
  // Resource names inside the .lrs file
  ResNameOff = 'led_off';
  ResNameOn  = 'led_on';

{ TSimplifiedLed }

constructor TSimplifiedLed.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  // Make sure the control is allowed to receive focus
  ControlStyle := ControlStyle - [csNoFocus];

  // Create the two internal bitmaps and hook their change notifications
  FBitmaps[lsOff] := TBitmap.Create;
  FBitmaps[lsOn]  := TBitmap.Create;
  FBitmaps[lsOff].OnChange := @BitmapChanged;
  FBitmaps[lsOn].OnChange  := @BitmapChanged;

  FState := lsOff;
  TabStop := True;
  DoubleBuffered := True;

  // Load the fixed bitmap set from Lazarus resources
  LoadBitmapsFromResources;

  // Initial size matches the "off" bitmap (or fallback if empty)
  if (FBitmaps[lsOff].Width > 0) and (FBitmaps[lsOff].Height > 0) then
    inherited SetBounds(0, 0, FBitmaps[lsOff].Width, FBitmaps[lsOff].Height)
  else
    inherited SetBounds(0, 0, DefaultW, DefaultH);
end;

destructor TSimplifiedLed.Destroy;
begin
  FBitmaps[lsOff].Free;
  FBitmaps[lsOn].Free;
  inherited Destroy;
end;

procedure TSimplifiedLed.LoadBitmapsFromResources;
begin
  // Missing resources are tolerated so the component does not crash at design time
  try
    FBitmaps[lsOff].LoadFromLazarusResource(ResNameOff);
  except
    // Leave the bitmap empty
  end;
  try
    FBitmaps[lsOn].LoadFromLazarusResource(ResNameOn);
  except
    // Leave the bitmap empty
  end;
end;

procedure TSimplifiedLed.BitmapChanged(Sender: TObject);
begin
  AdjustSizeToBitmap;
  Invalidate;
end;

procedure TSimplifiedLed.AdjustSizeToBitmap;
var
  Bmp: TBitmap;
begin
  Bmp := FBitmaps[FState];
  if (Bmp.Width > 0) and (Bmp.Height > 0) then
    inherited SetBounds(Left, Top, Bmp.Width, Bmp.Height);
end;

procedure TSimplifiedLed.SetState(AValue: TLedState);
begin
  if FState = AValue then Exit;
  FState := AValue;
  AdjustSizeToBitmap;
  Invalidate;
end;

{ The size is fixed: any external attempt to change it is overridden. }
procedure TSimplifiedLed.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  Bmp: TBitmap;
  W, H: Integer;
begin
  Bmp := FBitmaps[FState];
  if (Bmp.Width > 0) and (Bmp.Height > 0) then
  begin
    W := Bmp.Width;
    H := Bmp.Height;
  end
  else
  begin
    W := DefaultW;
    H := DefaultH;
  end;
  // Position is honored, size is forced
  inherited SetBounds(ALeft, ATop, W, H);
end;

procedure TSimplifiedLed.Paint;
const
  CrossMargin = 4;   // inset from each edge
var
  Bmp: TBitmap;
  cx, cy: Integer;
  x1, x2, y1, y2: Integer;
begin
  inherited Paint;

  // Draw the current bitmap 1:1, no stretching
  Bmp := FBitmaps[FState];
  if (Bmp.Width > 0) and (Bmp.Height > 0) then
    Canvas.Draw(0, 0, Bmp);

  // Focus indicator: straight red cross, inset by CrossMargin
  // Focus indicator: straight red cross, inset by CrossMargin
  if Focused then
  begin
    // Shortened ray ends (inset by CrossMargin)
    x1 := CrossMargin;
    x2 := DefaultW - 1 - CrossMargin;
    y1 := CrossMargin;
    y2 := DefaultH - 1 - CrossMargin;

    // Vertical bar: 2 px wide, centered
    // Occupies cx-1 .. cx (for even width), clamped inside [x1, x2]
    cx := DefaultW div 2;
    if cx < x1 + 1 then cx := x1 + 1;
    if cx > x2 then cx := x2;

    // Horizontal bar: 2 px tall, centered
    cy := DefaultH div 2;
    if cy < y1 + 1 then cy := y1 + 1;
    if cy > y2 then cy := y2;

    Canvas.Brush.Color := clRed;
    Canvas.Brush.Style := bsSolid;

    // Vertical bar: x from cx-1 to cx (2 px), y from y1 to y2
    Canvas.FillRect(cx - 1, y1, cx + 1, y2 + 1);

    // Horizontal bar: x from x1 to x2, y from cy-1 to cy (2 px)
    Canvas.FillRect(x1, cy - 1, x2 + 1, cy + 1);

    Canvas.Brush.Style := bsSolid;
  end;
end;

procedure TSimplifiedLed.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  // Clicking the control gives it focus
  if CanFocus then SetFocus;
end;

procedure TSimplifiedLed.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);

  // Toggle state on Space only
  if Key = VK_SPACE then
  begin
    if FState = lsOff then State := lsOn
    else State := lsOff;
    Key := 0; // Consume the key
  end;
end;

procedure TSimplifiedLed.DoExit;
begin
  inherited DoExit;
  Invalidate;
end;

procedure TSimplifiedLed.DoEnter;
begin
  inherited DoEnter;
  Invalidate;
end;

procedure TSimplifiedLed.DblClick;
begin
  inherited DblClick;

  // Toggle state on double click
  if FState = lsOff then State := lsOn
  else State := lsOff;
end;

procedure Register;
begin
  RegisterComponents('LED', [TSimplifiedLed]);
end;

initialization
  {$I ledbitmaps.lrs}

end.

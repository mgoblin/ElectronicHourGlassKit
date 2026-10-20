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
  /// Enumerated states of the LED control.
  TLedState = (lsOff, lsOn);

  /// Custom control that displays a fixed-size LED indicator using bitmaps
  /// loaded from LRS resources (``led_off`` and ``led_on``). The component
  /// size is locked to the bitmap dimensions. The current state is toggled
  /// via the Space key (when focused) or by double-clicking. A red cross
  /// overlay indicates keyboard focus.
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
    /// Creates an instance of TSimplifiedLed, initialises bitmaps from
    /// Lazarus resources, and sets the default size.
    constructor Create(AOwner: TComponent); override;
    /// Frees the internal bitmaps.
    destructor Destroy; override;
    /// Overrides the control bounds but keeps the width and height locked
    /// to the current bitmap's dimensions. Only the position (Left, Top)
    /// is honoured.
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    /// Toggles the LED state between ``On`` and ``Off``.
    procedure DblClick; override;
  published
    /// Current LED state. Defaults to ``lsOff``.
    property State: TLedState read FState write SetState default lsOff;
    /// Indicates whether the control can receive focus via tab navigation.
    /// Defaults to ``True``.
    property TabStop default True;
    /// Event fired when a key is pressed while the control has focus.
    property OnKeyDown;
    /// Event fired when a key is released while the control has focus.
    property OnKeyUp;
    /// Event fired when the control is clicked.
    property OnClick;
    /// Event fired when the control is double-clicked.
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
  if Focused and (Bmp.Width > 0) and (Bmp.Height > 0) then
  begin
    // Shortened ray ends (inset by CrossMargin)
    x1 := CrossMargin;
    x2 := Bmp.Width - 1 - CrossMargin;
    y1 := CrossMargin;
    y2 := Bmp.Height - 1 - CrossMargin;

    // Vertical bar: 2 px wide, centered
    // Occupies cx-1 .. cx (for even width), clamped inside [x1, x2]
    cx := Bmp.Width div 2;
    if cx < x1 + 1 then cx := x1 + 1;
    if cx > x2 then cx := x2;

    // Horizontal bar: 2 px tall, centered
    cy := Bmp.Height div 2;
    if cy < y1 + 1 then cy := y1 + 1;
    if cy > y2 then cy := y2;

    Canvas.Brush.Color := clRed;
    Canvas.Brush.Style := bsSolid;

    // Vertical bar: x from cx-1 to cx (2 px), y from y1 to y2
    Canvas.FillRect(cx - 1, y1, cx + 1, y2 + 1);

    // Horizontal bar: x from x1 to x2, y from cy-1 to cy (2 px)
    Canvas.FillRect(x1, cy - 1, x2 + 1, cy + 1);
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

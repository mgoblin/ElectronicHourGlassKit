unit SimplifiedLed;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LResources, LCLType;

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
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    property State: TLedState read FState write SetState default lsOff;
    property TabStop default True;
  end;

procedure Register;

implementation

const
  // Resource names inside the .lrs file (change to match your resources)
  ResNameOff = 'led_off';
  ResNameOn  = 'led_on';

  // Fallback size used while bitmaps are not loaded yet
  DefaultW = 32;
  DefaultH = 32;

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

procedure TSimplifiedLed.Paint;
var
  Bmp: TBitmap;
begin
  inherited Paint;

  // Opaque background
  Canvas.Brush.Color := clBtnFace;
  Canvas.FillRect(ClientRect);

  // Draw the current bitmap 1:1, no stretching
  Bmp := FBitmaps[FState];
  if (Bmp.Width > 0) and (Bmp.Height > 0) then
    Canvas.Draw(0, 0, Bmp);

  // Focus indicator
  if Focused then
  begin
    Canvas.Pen.Color := clHighlight;
    Canvas.Pen.Width := 2;
    Canvas.Brush.Style := bsClear;
    Canvas.Rectangle(0, 0, Width, Height);
    Canvas.Brush.Style := bsSolid;
  end;
end;

procedure Register;
begin
  RegisterComponents('LED', [TSimplifiedLed]);
end;

initialization
  {$I ledbitmaps.lrs}


end.

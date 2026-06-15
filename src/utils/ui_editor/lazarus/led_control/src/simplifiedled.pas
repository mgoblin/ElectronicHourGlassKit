unit SimplifiedLed;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, Math;

const
  DefaultWidth:Integer = 30;
  DefaultHeight:Integer = 30;

type

  TLEDState = (ledOff, ledOn);

  TSimplifiedLed = class(TCustomControl)
  private
    FState: TLEDState;
    FOnChange: TNotifyEvent;
    procedure SetState(AValue: TLEDState);
  protected
    procedure DoOnChange; virtual;
    procedure DoOnChangeBounds; override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure DblClick; override;
  published // Properties
    property Align;
    property Anchors;
    property State: TLEDState read FState write SetState default ledOff;
    property Visible;
  published // Events
    property OnDblClick;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

procedure Register;

implementation

uses LResources;

const
  DefaultPenWidth: Integer = 1;


procedure Register;
begin
  RegisterComponents('LED',[TSimplifiedLed]);
end;


constructor TSimplifiedLED.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := DefaultWidth;
  Height := DefaultHeight;
  FState := ledOff;
end;

procedure TSimplifiedLED.SetState(AValue: TLEDState);
begin
  if FState <> AValue then
  begin
    FState := AValue;
    DoOnChange;
    Invalidate;  // triggers repaint
  end;
end;

procedure TSimplifiedLed.DblClick;
var
  NewState: TLEDState;
begin
  // Toggle LED state and repaint
  case FState of
    ledOff: NewState := ledOn;
    ledOn: NewState := ledOff;
  end;
  SetState(NewState);

  inherited DblClick; // This calls the user-assigned OnDblClick event
end;

procedure TSimplifiedLED.DoOnChangeBounds;
begin
  inherited DoOnChangeBounds; // Handles the internal LCL changes

  // Triggers the Paint method on the next cycle
  Invalidate;
end;

procedure TSimplifiedLED.DoOnChange;
begin
  if Assigned(FOnChange) then
  begin
    FOnChange(Self);
  end;
end;

procedure TSimplifiedLED.Paint;
var
  LEDColor: TColor;
  R: TRect;
  CenterX, CenterY, Radius: Integer;
begin
  inherited Paint;

  // Decide LED color based on state
  case FState of
    ledOff: LEDColor := clGray;
    ledOn: LEDColor := clLime;      // bright green
  end;

  // Clear background
  Canvas.Brush.Color := Self.Color;
  Canvas.FillRect(ClientRect);

  // Draw a filled circle in center
  R := ClientRect;
  CenterX := (R.Left + R.Right) div 2;
  CenterY := (R.Top + R.Bottom) div 2;
  Radius := Min(Width, Height) div 2 - 2 * DefaultPenWidth;

  Canvas.Pen.Width := DefaultPenWidth;

  Canvas.Pen.Color := clBlack;
  Canvas.Brush.Color := LEDColor;
  Canvas.Ellipse(CenterX - Radius, CenterY - Radius, CenterX + Radius, CenterY + Radius);
end;

initialization
  {$I simplifiedled.lrs}

end.

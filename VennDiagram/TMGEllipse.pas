unit TMGEllipse;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Dialogs, ExtCtrls, math, Pointf, Rectf;

const
  TWO_PI = 3.14159 * 2;
  ELLIPSE_DRAW_FREQ_RAD = 0.1;  //Draw a point around ellipse every X radians
  ELLIPSE_NUM_SEGS = Round((TWO_PI / ELLIPSE_DRAW_FREQ_RAD))+1;
  ZERO_POINT : TPoint = (X: 0; Y: 0);
  NULL_RECT : TRect = (Left: 0; Top : 0; Right: 0; Bottom: 0);
  TEXT_SPACE = 3;

type
  TBoundingCorner = (bcTOP_LEFT        =1,
                     bcBOTTOM_LEFT     =2,
                     bcBOTTOM_RIGHT    =3,
                     bcTOP_RIGHT       =4);

  TResizeRectPts  = (rrpTopLeft        =3,
                     rrpMidLeft        =4,
                     rrpBottomLeft     =5,
                     rrpMidBottom      =6,
                     rrpBottomRight    =7,
                     rrpMidRight       =8,
                     rrpTopRight       =9,
                     rrpMidTop         =10);

  THandleSelected = (hselNone          =0,
                     hselX             =1,
                     hselY             =2,
                     hselTopLeft       =3,
                     hselMidLeft       =4,
                     hselBottomLeft    =5,
                     hselMidBottom     =6,
                     hselBottomRight   =7,
                     hselMidRight      =8,
                     hselTopRight      =9,
                     hselMidTop        =10,
                     hselLabel         =11,
                     hselInfo          =12,
                     hselPinhead       =13,
                     hselOther1        =15,
                     hselOther2        =16);

  tCorner =         (cNone,
                     cTopLeft,
                     cBottomLeft,
                     cBottomRight,
                     cTopRight);


  TEllipse = class(TObject)
    Protected
      FRect : TRectf;  //this is the bounding rect for the object
      FResizeRectPts : array[rrpTopLeft .. rrpMidTop] of TPointf;
      FCorner : array [bcTOP_LEFT..bcTOP_RIGHT] of TPointf;
      RegionPt : array [0 .. ELLIPSE_NUM_SEGS] of TPoint;
      RegionPointNum : word;
      FWinRegion : HRGN;
      FPos : TPointf;
      FRotation : single;  //Radians.  Angle between the X-axis and the major axis of the ellipse
      FXRadius, FYRadius : single;
      FXHandlePt : TPointf;
      FYHandlePt : TPointf;
      FPinBitmap : TBitmap;
      FPinRect : TRectf;
      FPinHeadPos : TPointf;
      procedure GetLenAngle(Vect : TPointf; var Len : integer; var Angle : single);
      function GetBoundingCorner(Corner : TBoundingCorner) : TPoint;
      procedure SetXHandlePt (Value : TPointf);
      procedure SetYHandlePt (Value : TPointf);
      procedure SetXRadius(Value : single);
      procedure SetXRadiusDynamic(Value : single); dynamic;
      procedure SetYRadius(Value : single);
      procedure SetYRadiusDynamic(Value : single); dynamic;
      procedure SetHandlePt(SelHandle : THandleSelected; value : TPointf);
      procedure SetHandlePtDynamic(SelHandle : THandleSelected; value : TPointf); dynamic;
      function GetHandlePt(SelHandle : THandleSelected) : TPointf;
      procedure CalcRegionPoints;
      procedure SetGeometry;
      function GetIntPoint : TPoint;
      function CreateWinRegion : THandle; //User SHOULD call FreeWinRegion when done with handle
      procedure FreeWinRegion(Region: THandle);
      procedure SetPos(Value : TPointf);
      procedure SetPosDynamic(Value : TPointf); dynamic;
      procedure SetRotation(Value : Single);
      procedure SetRotationDynamic(Value : Single);dynamic;
      procedure AnimateLabel(IntervalTimeMs : Extended);
    public
      Name : string;
      Vel  : TPointf;
      Color : TColor;
      DataValue1, DataValue2 : single;  //misc storage for user use.
      DataP1, DataP2 : TPointf;         //misc storage for user use.
      BorderThickness : byte;
      BorderColor : TColor;
      ShowBorder : boolean;
      ShowHandles : boolean;
      ShowBoundingRect : boolean;
      ShowCorners : boolean;
      AllowEllipseShape : boolean; //if false, object will always be round.
      ShowLabel : boolean;
      LabelPos : TPointf;
      LabelVel : TPointf;
      LabelAccel : TPointf;
      LabelForce : TPointf;
      LabelSpringLength : single;
      LabelTextRect : TRectf;
      LabelPinned : Boolean;
      procedure DrawHandles(Bitmap : TBitmap);
      procedure DrawBoundingRect(Bitmap : TBitmap); dynamic;
      function ContainsPoint(Pt : TPoint) : boolean; dynamic;
      function WhichHandleSelected(Pt : TPoint) : THandleSelected; dynamic;
      procedure MovePos(DeltaPos : TPointf);
      procedure TraceOutline(Bitmap : TBitmap; Color : TColor; Thickness : byte);
      procedure Render(Bitmap : TBitmap); Dynamic;
      procedure RenderLabel(Bitmap : TBitmap); dynamic;
      property Pos : TPointf read FPos write SetPos;
      property IntPos : TPoint read GetIntPoint;
      property Rotation : single read FRotation write SetRotation;
      property BoundingRect : TRectf read FRect;
      property WinRegion : HRGN read FWinRegion;    //Owned by this object
      property XHandlePt : TPointf read FXHandlePt write SetXHandlePt;
      property YHandlePt : TPointf read FYHandlePt write SetYHandlePt;
      property HandlePt[SelHandle : THandleSelected] : TPointf read GetHandlePt write SetHandlePt;
      property BoundingCorner[Corner : TBoundingCorner] : TPoint read GetBoundingCorner;
      property XRadius : single read FXRadius write SetXRadius;
      property YRadius : single read FYRadius write SetYRadius;
      procedure Animate(IntervalTimeMs : extended); dynamic;
      constructor Create;
      destructor Destroy;
  end;

function RotatePoint(P : TPointf; Alpha : single) : TPointf;
procedure ColorToRGB16(Color : TColor; var Red, Blue, Green : Color16); forward;
function  RGB16ToColor (Red, Blue, Green : Color16) : TColor; forward;
function  DarkerColor (Color : TColor; Factor : single = 1.5) : TColor; forward;
function ColorBlend (ColorA, ColorB : TColor; PctA : byte) : TColor; forward;
procedure GradientFill(Bitmap : TBitmap; Color1, Color2 : TColor; Rect : TRect); forward;
procedure DrawBall(ABitmap : TBitmap; X, Y : integer; Color : TColor; Radius : word = 5; Filled : boolean = true); overload;
procedure DrawBall(ABitmap : TBitmap; P : TPointf; Color : TColor; Radius : word = 5;Filled : boolean = true); overload;
procedure DrawSquare(ABitmap : TBitmap; X, Y : integer; Color : TColor; Radius : word = 5; Filled : boolean = true); overload;
procedure DrawSquare(ABitmap : TBitmap; P : TPointf; Color : TColor; Radius : word = 5; Filled : boolean = true); overload;
procedure DrawFilledRect(ABitmap : TBitmap; Rect : TRect; FillColor : TColor;
                         BorderColor : TColor = clBlack; BorderThickness : integer = 1;
                         FillStyle : TBrushStyle = bsSolid);
//function  BottomLeft(Rect : TRect) : TPoint;
//function  TopRight(Rect : TRect) : TPoint;
//function  MidLeft(Rect : TRectf) : TPointf;
//function  MidBottom(Rect : TRectf) : TPointf;
//function  MidRight(Rect : TRectf) : TPointf;
//function  MidTop(Rect : TRectf) : TPointf;
function AddPoint(P1, P2 : TPoint) : TPoint;
function SubtractPoint(P1, P2 : TPoint) : TPoint; //Return P1 - P2
function InRect(P1 : TPoint; Rect : TRect) : boolean;
function EqualRects(R1, R2 : TRect) : boolean;
function Between(A, N1, N2 : integer) : boolean;
//function InRectXDir(P : TPoint; R : TRectf) : boolean;
//function InRectYDir(P : TPoint; R : TRectf) : boolean;
function OppositeCorner(Corner : tCorner) : tCorner;
function CornerPt(Corner : tCorner; R : TRectf) : TPointf;
function RectOverlapV(ExistRect,MovingRect: TRectf):TPointf;
function OffsetRect(Rect : TRectf; P : TPoint) : TRectf;

Const
  HANDLE_KNOB_RADIUS = 5;
  HANDLE_SHRINK_FACTOR = 0.9;
  RESIZE_SQR_SIZE = 4;
  RESIZE_SQR_COLOR = clBlack;
  RESIZE_SPACE = 5;


implementation

{$R ELLIPSE.RES}


function OffsetRect(Rect : TRectf; P : TPoint) : TRectf;
begin
  //Result.TopLeft := AddPoint(Rect.TopLeft, P);
  Result.TopLeft := Rect.TopLeft + P;
  //Result.BottomRight := AddPoint(Rect.BottomRight, P);
  Result.BottomRight := Rect.BottomRight + P;
end;

function RectOverlapV(ExistRect,MovingRect: TRectf):TPointf;

var Corner : tCorner;
begin
  Result := ZERO_VECT;
  Corner := cNone;
  //if InRectXDir(MovingRect.TopLeft, ExistRect) then begin
  if ExistRect.ContainsPtXDir(MovingRect.TopLeft) then begin
    //if InRectYDir(MovingRect.TopLeft, ExistRect) then begin
    if ExistRect.ContainsPtYDir(MovingRect.TopLeft) then begin
      Corner := cTopLeft;
    //end else if InRectYDir(BottomLeft(MovingRect), ExistRect) then begin
    end else if ExistRect.ContainsPtYDir(MovingRect.BottomLeft) then begin
      Corner := cBottomLeft;
    end;
  //end else if InRectXDir(TopRight(MovingRect), ExistRect) then begin
  end else if ExistRect.ContainsPtXDir(MovingRect.TopRight) then begin
    //if InRectYDir(TopRight(MovingRect), ExistRect) then begin
    if ExistRect.ContainsPtYDir(MovingRect.TopRight) then begin
      Corner := cTopRight;
    //end else if InRectYDir(MovingRect.BottomRight, ExistRect) then begin
    end else if ExistRect.ContainsPtYDir(MovingRect.BottomRight) then begin
      Corner := cBottomRight;
    end;
  end;
  if Corner <> cNone then begin
    Result := CornerPt(OppositeCorner(Corner), ExistRect) - CornerPt(Corner, MovingRect);
  end;
end;




function Between(A, N1, N2 : integer) : boolean;
begin
  Result := (A >= N1) and (A <= N2);
end;

{
function InRectXDir(P : TPoint; R : TRectf) : boolean;
begin
  Result := Between(P.X, R.Left, R.Right);
end;

function InRectYDir(P : TPoint; R : TRectf) : boolean;
begin
  Result := Between(P.Y, R.Top, R.Bottom);
end;
}

function OppositeCorner(Corner : tCorner) : tCorner;
begin
  case Corner of
    cTopLeft:    Result := cBottomRight;
    cBottomLeft: Result := cTopRight;
    cBottomRight:Result := cTopLeft;
    cTopRight:   Result := cBottomLeft;
  end;
end;

function CornerPt(Corner : tCorner; R : TRectf) : TPointf;
begin
  case Corner of
    cTopLeft:    Result := R.TopLeft;
    cBottomLeft: Result := R.BottomLeft;
    cBottomRight:Result := R.BottomRight ;
    cTopRight:   Result := R.TopRight
  end;
end;


function RotatePoint(P : TPointf; Alpha : single) : TPointf;
var Cos, Sin : extended;
begin
  SinCos(Alpha, Sin, Cos);
  Result.X := Round((P.X * Cos) - (P.Y * Sin));
  Result.Y := Round((P.X * Sin) + (P.Y * Cos));
end;

{
function BottomLeft(Rect : TRect) : TPoint;
begin
  Result.X := Rect.Left;
  Result.Y := Rect.Bottom;
end;

function TopRight(Rect : TRect) : TPoint;
begin
  Result.X := Rect.Right;
  Result.Y := Rect.Top;
end;

function  MidLeft(Rect : TRectf) : TPointf;
begin
  Result.X := Rect.Left;
  Result.Y := ((Rect.Bottom - Rect.Top) div 2) + Rect.Top;
end;

function  MidBottom(Rect : TRectf) : TPointf;
begin
  Result.Y := Rect.Bottom;
  Result.X := ((Rect.Right - Rect.Left) div 2) + Rect.Left;
end;

function  MidRight(Rect : TRectf) : TPointf;
begin
  Result.X := Rect.Right;
  Result.Y := ((Rect.Bottom - Rect.Top) div 2) + Rect.Top;
end;

function  MidTop(Rect : TRectf) : TPointf;
begin
  Result.Y := Rect.Top;
  Result.X := ((Rect.Right - Rect.Left) div 2) + Rect.Left;
end;
}

procedure ColorToRGB16(Color : TColor; var Red, Blue, Green : Color16);
var AColor : longint;
begin
  AColor := Graphics.ColorToRGB(Color);
  Red   := (AColor and $0000FF) shl 8;
  Blue  := (AColor and $00FF00);
  Green := (AColor and $FF0000) shr 8;
end;

function RGB16ToColor (Red, Blue, Green : Color16) : TColor;
var AColor : longint;
begin
  //AColor := (Green shl 8) and Blue and (Red shr 8);
  AColor := (Green shl 8);
  AColor := AColor or Blue;
  AColor := AColor or (Red shr 8);
  Result := TColor(AColor);
end;

function DarkerColor (Color : TColor; Factor : single = 1.5) : TColor;
var R,G,B : Color16;
begin
  ColorToRGB16(Color, R, G, B);
  R := Round(R / Factor); //R div 2;
  G := Round(G / Factor); //G div 2;
  B := Round(B / Factor); //B div 2;
  Result := RGB16ToColor(R, G, B);
end;

function ColorBlend (ColorA, ColorB : TColor; PctA : byte) : TColor;
  function Blend1(PartA, PartB : Color16; bPct : byte) : Color16;
  var
    Pct : single;
    wA,wB : word;
    R : word;
  begin
    Pct := bPct/100;
    wA := PartA shr 8;
    wB := PartB shr 8;
    R := Round(wA*Pct + wB*(1 - Pct));
    Result := R shl 8;
  end;

//Pct should be between 1-100
var RA,GA,BA : Color16;
    RB,GB,BB : Color16;
    RC,GC,BC : Color16;
begin
  if PctA > 100 then PctA := 100;
  ColorToRGB16(ColorA, RA, GA, BA);
  ColorToRGB16(ColorB, RB, GB, BB);
  RC := Blend1(RA, RB, PctA);
  GC := Blend1(GA, GB, PctA);
  BC := Blend1(BA, BB, PctA);
  Result := RGB16ToColor(RC, GC, BC);
end;


procedure GradientFill(Bitmap : TBitmap; Color1, Color2 : TColor; Rect : TRect);

  procedure SetVertex(var vert : TRIVERTEX; Pos : TPoint; Color : TColor);
  var R,G,B : Color16;
  begin
    ColorToRGB16(Color, R,G,B);
    vert.x      := Pos.X;
    vert.y      := Pos.Y;
    vert.Red    := R;
    vert.Green  := G;
    vert.Blue   := B;
    vert.Alpha  := $FFFF;
  end;

var
 vert : array[0..1] of TRIVERTEX;
 gRect   : GRADIENT_RECT;
 APt : TPoint;

begin
  APt := Rect.TopLeft;
  SetVertex(vert[0], APt, Color1);
  APt := Rect.BottomRight;
  SetVertex(vert[1], APt, Color2);

  gRect.UpperLeft  := 0;
  gRect.LowerRight := 1;
  Windows.GradientFill(Bitmap.Canvas.Handle, @vert,2, @gRect,1, GRADIENT_FILL_RECT_H);
end;


procedure DrawSquare(ABitmap : TBitmap; X, Y : integer;
                     Color : TColor;
                     Radius : word = 5;
                     Filled : boolean = true);
var Rect : TRect;
begin
  Rect.Top := Y - Radius;
  Rect.Left := X - Radius;
  Rect.Right := X + Radius;
  Rect.Bottom := Y + Radius;

  ABitmap.Canvas.Brush.Color := Color;
  if Filled then begin
    ABitmap.Canvas.Brush.Style := bsSolid;
  end else begin
    ABitmap.Canvas.Brush.Style := bsClear;
  end;
  ABitmap.Canvas.Pen.Color := clWhite;
  ABitmap.Canvas.Pen.Width := 1;
  ABitmap.Canvas.Rectangle(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
end;

procedure DrawSquare(ABitmap : TBitmap; P : TPointf;
                     Color : TColor;
                     Radius : word = 5;
                     Filled : boolean = true);
begin
  DrawSquare(ABitmap, P.IntX, P.IntY, Color, Radius, Filled);
end;


procedure DrawBall(ABitmap : TBitmap; X, Y : integer;
                   Color : TColor;
                   Radius : word = 5;
                   Filled : boolean = true); overload;
var Rect : TRect;
begin
  Rect.Top := Y - Radius;
  Rect.Left := X - Radius;
  Rect.Right := X + Radius;
  Rect.Bottom := Y + Radius;

  ABitmap.Canvas.Brush.Color := Color;
  if Filled then begin
    ABitmap.Canvas.Brush.Style := bsSolid;
  end else begin
    //ABitmap.Canvas.Brush.Style := bsClear;
  end;
  ABitmap.Canvas.Pen.Color := Color;
  ABitmap.Canvas.Pen.Width := 1;
  ABitmap.Canvas.Ellipse(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
end;

procedure DrawBall(ABitmap : TBitmap; P : TPointf;
                   Color : TColor;
                   Radius : word = 5;
                   Filled : boolean = true); overload;
begin
  DrawBall(ABitmap, P.IntX, P.IntY, Color, Radius, Filled);
end;

procedure DrawFilledRect(ABitmap : TBitmap; Rect : TRect; FillColor : TColor;
                   BorderColor : TColor = clBlack; BorderThickness : integer = 1;
                   FillStyle : TBrushStyle = bsSolid);
begin
  ABitmap.Canvas.Pen.Color := BorderColor;
  ABitmap.Canvas.Pen.Width := BorderThickness;
  if BorderThickness = 0 then begin
    ABitmap.Canvas.Pen.Style := psClear;
  end else begin
    ABitmap.Canvas.Pen.Style := psSolid;
  end;
  ABitmap.Canvas.Brush.Color := FillColor;
  ABitmap.Canvas.Brush.Style := bsSolid;
  ABitmap.Canvas.Rectangle(Rect);
end;


function AddPoint(P1, P2 : TPoint) : TPoint;
begin
  Result.X := P1.X + P2.X;
  Result.Y := P1.Y + P2.Y;
end;

function SubtractPoint(P1, P2 : TPoint) : TPoint;
//Return P1 - P2
begin
  Result.X := P1.X - P2.X;
  Result.Y := P1.Y - P2.Y;
end;

function InRect(P1 : TPoint; Rect : TRect) : boolean;
begin
  result := false;
  if P1.X < Rect.Left   then exit;
  if P1.X > Rect.Right  then exit;
  if P1.Y < Rect.Top    then exit;
  if P1.Y > Rect.Bottom then exit;
  result := true;
end;

function EqualRects(R1, R2 : TRect) : boolean;
begin
  Result := (R1.Top  = R2.Top) and
            (R1.Left = R2.Left) and
            (R1.Right = R2.Right) and
            (R1.Bottom = R2.Bottom);
end;



//=================================================
constructor TEllipse.Create;
begin
  Inherited Create;
  FWinRegion := HRGN(0);
  ShowBorder := false;
  ShowHandles := false;
  ShowBoundingRect := false;
  ShowCorners := false;
  AllowEllipseShape := true;
  ShowLabel := false;
  //LabelTextRect := NULL_RECT;
  LabelTextRect.TopLeft := ZERO_VECT;
  LabelTextRect.BottomRight := ZERO_VECT;
  LabelPinned := False;
  FPinBitmap := TBitmap.Create;
  FPinBitmap.LoadFromResourceName(hInstance,'THUMBTACK');
  FPinBitmap.PixelFormat:= pf24bit;
  FPinBitmap.Transparent:= true;
  FPinBitmap.TransparentColor:= RGB(255, 0, 255);
end;

destructor TEllipse.Destroy;
begin
  FreeWinRegion(FWinRegion);
  FPinBitmap.Free;
  inherited Destroy;
end;


procedure TEllipse.CalcRegionPoints;
var
 SinRot, CosRot : extended;

  function GetPoint(Alpha : single) : TPointf;
  var
    Sin, Cos : Extended;
  begin
    SinCos(Alpha, Sin, Cos);
    Result.X := (FXRadius * Cos * CosRot) - (FYRadius * Sin * SinRot);
    Result.Y := (FXRadius * Cos * SinRot) + (FYRadius * Sin * CosRot);
  end;

var
  Angle : single;
  OnePoint : TPointf;
begin
  SinCos(FRotation, SinRot, CosRot);
  Angle := 0;
  RegionPointNum := 0;
  repeat
    OnePoint := GetPoint(Angle) + FPos;
    RegionPt[RegionPointNum] := OnePoint.IntPoint;
    Angle := Angle + ELLIPSE_DRAW_FREQ_RAD;
    Inc(RegionPointNum);
  until Angle > TWO_PI + ELLIPSE_DRAW_FREQ_RAD;
end;

function TEllipse.GetBoundingCorner(Corner : TBoundingCorner) : TPoint;
begin Result := FCorner[Corner].IntPoint; end;


procedure TEllipse.SetXRadiusDynamic(Value : single);
begin
  FXRadius := Value;
  SetGeometry;
end;

procedure TEllipse.SetXRadius(Value : single);
begin
  SetXRadiusDynamic(Value);
  if not AllowEllipseShape then SetYRadiusDynamic(Value);
end;

procedure TEllipse.SetYRadiusDynamic(Value : single);
begin
  FYRadius := Value;
  SetGeometry;
end;

procedure TEllipse.SetYRadius(Value : single);
begin
  SetYRadiusDynamic(Value);
  if not AllowEllipseShape then SetXRadiusDynamic(Value);
end;

procedure TEllipse.GetLenAngle(Vect : TPointf; var Len : integer; var Angle : single);
begin
  Len := Round(Vect.Length);
  if Vect.x <> 0 then begin
    Angle := ArcTan2(Vect.Y, Vect.X);
  end else begin
    if Vect.y > 0 then Angle := TWO_PI / 4
    else Angle := 3 * TWO_PI / 4;
  end;
end;

procedure TEllipse.SetXHandlePt (Value : TPointf);
//Accept new user Xhandle position, and use to establish rotation
//  and X radius
begin
  SetHandlePt(hselX,Value);
end;

procedure TEllipse.SetYHandlePt (Value : TPointf);
//Accept new user Yhandle position, and use to establish rotation
//  and Y radius
begin
  SetHandlePt(hselY,Value);
end;

procedure TEllipse.SetHandlePtDynamic(SelHandle : THandleSelected; value : TPointf);
var Vect : TPointf;
    Len : integer;
    Angle : single;
    XChanged, YChanged : boolean;

begin
  if SelHandle = hselNone then exit;
  XChanged := false;
  YChanged := false;
  Vect := Value - Self.Pos;
  case SelHandle of
    hselX:         begin
                     Vect := Vect / HANDLE_SHRINK_FACTOR;
                     GetLenAngle(Vect, Len, Angle);
                     XRadius := Len;
                     XChanged := true;
                     Self.Rotation := Angle;
                   end;
    hselY:         begin
                     Vect := Vect / HANDLE_SHRINK_FACTOR;
                     GetLenAngle(Vect, Len, Angle);
                     YRadius := Len;
                     YChanged := true;
                     Self.Rotation := Angle + (TWO_PI / 4);
                   end;
    hselTopLeft,
    hselMidLeft,
    hselBottomLeft,
    hselTopRight,
    hselMidRight,
    hselBottomRight:begin
                     XRadius := Round(Abs(Vect.x));
                     XChanged := true;
                   end;
    hselMidTop,
    hselMidBottom: begin
                     YRadius := Round(Abs(Vect.y));
                     YChanged := True;
                   end;
    hselLabel:     begin
                     LabelPos := Value;
                     LabelPinned := True;
                   end;
  end;
  if AllowEllipseShape = false then begin
    if XChanged then FYRadius := FXRadius;
    if YChanged then FXRadius := FYRadius;

  end;

  SetGeometry;
end;

procedure TEllipse.SetHandlePt(SelHandle : THandleSelected; Value : TPointf);
begin
  SetHandlePtDynamic(SelHandle, Value);
end;

function TEllipse.GetHandlePt(SelHandle : THandleSelected) : TPointf;
begin
  case SelHandle of
    hselNone: begin
                Result.X := 0;
                Result.Y := 0;
              end;
    hselX:            Result := FXHandlePt;
    hselY:            Result := FYHandlePt;
    hselTopLeft :     Result := FResizeRectPts[rrpTopLeft];
    hselMidLeft :     Result := FResizeRectPts[rrpMidLeft];
    hselBottomLeft :  Result := FResizeRectPts[rrpBottomLeft];
    hselMidBottom :   Result := FResizeRectPts[rrpMidBottom];
    hselBottomRight : Result := FResizeRectPts[rrpBottomRight];
    hselMidRight :    Result := FResizeRectPts[rrpMidRight];
    hselTopRight :    Result := FResizeRectPts[rrpTopRight];
    hselMidTop :      Result := FResizeRectPts[rrpMidTop];
  end;
end;


procedure TEllipse.SetGeometry;
  function ShrinkVect(P : TPointf; Factor : single) : TPointf;
  var Vect : TPointf;
  begin
    Vect := P - Self.Pos;
    Vect := Vect * Factor;
    Vect := Self.Pos + Vect;
    Result := Vect;
  end;

var APoint, P : TPoint;
    Ptf : TPointf;
    X,Y  : single;
    i : TBoundingCorner;

begin
  P := FPos.IntPoint;
  FRect.Top    := - FYRadius;
  FRect.Left   := - FXRadius;
  FRect.Bottom := + FYRadius;
  FRect.Right  := + FXRadius;
  FCorner[bcTOP_LEFT]       := FRect.TopLeft;
  FCorner[bcBOTTOM_LEFT]    := FRect.BottomLeft;  //2 = BottomLeft
  FCorner[bcBOTTOM_RIGHT]   := FRect.BottomRight;
  FCorner[bcTOP_RIGHT]      := FRect.TopRight;
  if FRotation <> 0 then begin
    for i:= bcTOP_LEFT to bcTOP_RIGHT do begin
      FCorner[i] := RotatePoint(FCorner[i], FRotation);
    end;
    //Find smallest X and Y
    x := 99999;  y := 99999;
    for i:= bcTOP_LEFT to bcTOP_RIGHT do begin
      if FCorner[i].X < X then X := FCorner[i].X;
      if FCorner[i].Y < Y then Y := FCorner[i].Y;
    end;
    FRect.Top := Y; FRect.Left := X;
    //Find largest X and Y
    x := -99999;  y := -99999;
    for i:= bcTOP_LEFT to bcTOP_RIGHT do begin
      if FCorner[i].X > X then X := FCorner[i].X;
      if FCorner[i].Y > Y then Y := FCorner[i].Y;
    end;
    FRect.Bottom := Y;
    FRect.Right  := X;
  end;
  FRect     := OffsetRect(FRect,P);

  //Setup points for bounding rect;
  FResizeRectPts[rrpTopLeft].x     := FRect.Left   - RESIZE_SPACE;
  FResizeRectPts[rrpTopLeft].y     := FRect.Top    - RESIZE_SPACE;
  FResizeRectPts[rrpBottomLeft].x  := FRect.Left   - RESIZE_SPACE;
  FResizeRectPts[rrpBottomLeft].y  := FRect.Bottom + RESIZE_SPACE;
  FResizeRectPts[rrpBottomRight].x := FRect.Right  + RESIZE_SPACE;
  FResizeRectPts[rrpBottomRight].y := FRect.Bottom + RESIZE_SPACE;
  FResizeRectPts[rrpTopRight].x    := FRect.Right  + RESIZE_SPACE;
  FResizeRectPts[rrpTopRight].y    := FRect.Top    - RESIZE_SPACE;
  FResizeRectPts[rrpMidLeft].x     := FRect.Left   - RESIZE_SPACE;
  FResizeRectPts[rrpMidLeft].y     := FRect.MidLeft.y; //  MidLeft(FRect).Y;
  FResizeRectPts[rrpMidBottom].x   := FRect.MidBottom.x; // MidBottom(FRect).X;
  FResizeRectPts[rrpMidBottom].y   := FRect.Bottom + RESIZE_SPACE;
  FResizeRectPts[rrpMidRight].x    := FRect.Right  + RESIZE_SPACE;
  FResizeRectPts[rrpMidRight].y    := FRect.MidRight.y; // MidRight(FRect).Y;
  FResizeRectPts[rrpMidTop].x      := FRect.MidTop.x;  //MidTop(FRect).X;
  FResizeRectPts[rrpMidTop].y      := FRect.Top    - RESIZE_SPACE;

  for i:= bcTOP_LEFT to bcTOP_RIGHT do begin
    //FCorner[i] := AddPoint(FCorner[i],P);
    FCorner[i] := FCorner[i] + P;
  end;

  //Calculate positions of handles
  Ptf.x := (FCorner[bcBOTTOM_RIGHT].X + FCorner[bcTOP_RIGHT].X) / 2;
  Ptf.y := (FCorner[bcBOTTOM_RIGHT].Y + FCorner[bcTOP_RIGHT].Y) / 2;
  FXHandlePt := ShrinkVect(Ptf, 0.8);

  Ptf.x := (FCorner[bcTOP_LEFT].X + FCorner[bcTOP_RIGHT].X) / 2;
  Ptf.y := (FCorner[bcTOP_LEFT].Y + FCorner[bcTOP_RIGHT].Y) / 2;
  FYHandlePt := ShrinkVect(Ptf, 0.8);

  CalcRegionPoints;
end;

procedure TEllipse.SetRotationDynamic(Value : Single);
begin
  while Value > TWO_PI do Value := Value - TWO_PI;
  FRotation := Value;
  SetGeometry;
end;

procedure TEllipse.SetRotation(Value : Single);
begin
  SetRotationDynamic(Value);
end;

function TEllipse.GetIntPoint : TPoint;
begin
  Result := FPos.IntPoint;
end;

procedure TEllipse.SetPosDynamic(Value : TPointf);
begin
  FPos := Value;
  SetGeometry;
end;

procedure TEllipse.SetPos(Value : TPointf);
begin
  SetPosDynamic(Value);
end;

procedure TEllipse.MovePos(DeltaPos : TPointf);
begin
  Pos := FPos + DeltaPos; //will trigger SetPos --> SetGeometry
end;

function TEllipse.CreateWinRegion : THandle;
begin
  Result := CreatePolygonRgn(RegionPt, RegionPointNum, ALTERNATE);
end;

procedure TEllipse.FreeWinRegion(Region: THandle);
begin
  DeleteObject(Region);
end;

procedure TEllipse.TraceOutline(Bitmap : TBitmap; Color : TColor; Thickness : byte);
var
  OnePoint : TPoint;
  i : integer;
begin
  Bitmap.Canvas.Pen.Color := Color;
  Bitmap.Canvas.Pen.Width := Thickness;
  for i := 0 to RegionPointNum -1 do begin
    OnePoint := RegionPt[i];
    if i = 0 then begin
      Bitmap.Canvas.MoveTo(OnePoint.X, OnePoint.Y);
    end else begin
      Bitmap.Canvas.LineTo(OnePoint.X, OnePoint.Y);
    end;
  end;
  if Thickness > 1 then begin
    Bitmap.Canvas.Pen.Color := ColorBlend (clBlack, clDkGray, 40);
    Bitmap.Canvas.Pen.Width := 1;
    for i := 0 to RegionPointNum -1 do begin
      OnePoint := RegionPt[i];
      if i = 0 then begin
        Bitmap.Canvas.MoveTo(OnePoint.X, OnePoint.Y);
      end else begin
        Bitmap.Canvas.LineTo(OnePoint.X, OnePoint.Y);
      end;
    end;
  end;


end;

function TEllipse.WhichHandleSelected(Pt : TPoint) : THandleSelected;
var SelPt, V : TPointf;
    PinV : TPointf;
    i : TResizeRectPts;
begin
  Result := hselNone;
  SelPt.IntPoint := Pt;

  //First check XHandle
  V := SelPt - FXHandlePt;
  if V.Length <= HANDLE_KNOB_RADIUS then begin
    Result := hselX;
    exit;
  end;

  if AllowEllipseShape then begin
    //Second check YHandle
    V := SelPt - FYHandlePt;
    if V.Length <= HANDLE_KNOB_RADIUS then begin
      Result := hselY;
      exit;
    end;
  end;

  if ShowBoundingRect then begin
   for i := rrpTopLeft to rrpMidTop do begin
     V := SelPt - FResizeRectPts[i];
     if V.Length <= RESIZE_SQR_SIZE * 2 then begin
       Result := THandleSelected(i);
       exit;
     end;
   end;
  end;

  if ShowLabel then begin
    //if InRect(Pt, LabelTextRect) then begin
    if LabelTextRect.ContainsPoint(Pt) then begin
      Result := hselLabel;
      exit;
    end;
  end;

  if LabelPinned then begin
    //if InRect(Pt, FPinRect) then begin
    if FPinRect.ContainsPoint(Pt) then begin
      Result := hselPinhead;
      exit;
    end;
    //PinV := SelPt - FPinHeadPos;
    //if (PinV.Length < 10) then begin
    //  Result := hselPinhead;
    //  exit;
    //end;
  end;

end;

function TEllipse.ContainsPoint(Pt : TPoint) : boolean;
var ARect : TRectf;
begin
  if ShowBoundingRect then begin
    ARect := FRect;
    ARect.Left := ARect.Left - RESIZE_SQR_SIZE - RESIZE_SPACE;
    ARect.Right := ARect.Right + RESIZE_SQR_SIZE + RESIZE_SPACE;
    ARect.Top := ARect.Top  - RESIZE_SQR_SIZE - RESIZE_SPACE;
    ARect.Bottom := ARect.Bottom +  RESIZE_SQR_SIZE + RESIZE_SPACE;
    //Result := InRect(Pt, ARect);
    Result := ARect.ContainsPoint(Pt);
  end else begin
    Result := PtInRegion(FWinRegion, Pt.X, Pt.Y);
  end;
  if (Result = false) and ShowLabel then begin
    Result := (WhichHandleSelected(Pt) <> hselNone);
    //Result := InRect(Pt, LabelTextRect);
  end;
end;

procedure TEllipse.DrawHandles(Bitmap : TBitmap);
  procedure Draw1Handle(Pt : TPointf);
  begin
    Bitmap.Canvas.Pen.Style := psSolid;
    Bitmap.Canvas.Pen.Color := clRed;
    Bitmap.Canvas.Pen.Width := 2;
    Bitmap.Canvas.PenPos := Pos.IntPoint;
    Bitmap.Canvas.LineTo(Pt.IntX, Pt.IntY);
    DrawBall(Bitmap, Pt, clRed, HANDLE_KNOB_RADIUS, true);
  end;
begin
  Draw1Handle(FXHandlePt);
  if AllowEllipseShape then begin
    Draw1Handle(FYHandlePt);
  end;
end;

procedure TEllipse.DrawBoundingRect(Bitmap : TBitmap);
Var i : TResizeRectPts;
begin
  for i := rrpTopLeft to rrpMidTop do begin
    DrawSquare(Bitmap, FResizeRectPts[i], RESIZE_SQR_COLOR, RESIZE_SQR_SIZE);
  end;
end;


procedure TEllipse.Render(Bitmap : TBitmap);

Var i : TBoundingCorner;
begin
  if (BorderThickness > 0) and ShowBorder then begin
    TraceOutline(Bitmap, BorderColor, BorderThickness);
  end;
  if FWinRegion <> HRGN(0) then FreeWinRegion(FWinRegion);
  FWinRegion := CreateWinRegion;
  SelectClipRgn(Bitmap.Canvas.Handle, FWinRegion);
  Bitmap.Canvas.Brush.Style := bsSolid;
  GradientFill(Bitmap, Self.Color, Darkercolor(Self.Color), FRect.IntRect);
  SelectClipRgn(Bitmap.Canvas.Handle, 0);
  //Leave region encircling object until next draw, or until destructor
  if ShowHandles then DrawHandles(Bitmap);
  if ShowBoundingRect then DrawBoundingRect(Bitmap);
  if ShowCorners then begin  //Bounding rectangle, rotated to match Rotation
    for i := bcTOP_LEFT to bcTOP_RIGHT do begin
      DrawBall(Bitmap, FCorner[i], clGreen);
    end;
  end;

end;

procedure TEllipse.RenderLabel(Bitmap : TBitmap);
//Separate from main Render, so that this can be done after all the
//other spheres have been drawn, so that labels will be on top.
const PIN_SCALE = 0.06;
var Size : TSize;
    LabelPos, StartPos : TPoint;
    LineVect : TPointf;
    DesiredLen : single;
begin
  Size := Bitmap.Canvas.TextExtent(Self.Name);
  LabelPos := Self.LabelPos.IntPoint;

  //Draw line from label to edge of circle.
  LineVect := Self.Pos - LabelPos;
  DesiredLen := LineVect.Length - Self.XRadius;  //assumes round object, as VinObjs will be.
  LineVect.ScaleToLen(DesiredLen);
  LineVect := LineVect + LabelPos;
  Bitmap.Canvas.Pen.Color := clBlack;
  Bitmap.Canvas.Pen.Width := 2;
  Bitmap.Canvas.PenPos := LabelPos;
  Bitmap.Canvas.LineTo(LineVect.IntX, LineVect.IntY);

  //Draw text at LabelPos, offset so that LabelPos is in the middle
  StartPos := LabelPos;
  StartPos.X := StartPos.X - (Size.cx div 2);
  StartPos.Y := StartPos.Y - Size.cy;
  if not ShowLabel then exit;
  Bitmap.Canvas.Brush.Color := clWhite;
  Bitmap.Canvas.Brush.Style := bsSolid;
  Bitmap.Canvas.Pen.Color := clRed;
  //Draw blank square to put text on, with red border
  LabelTextRect.Left := StartPos.X - TEXT_SPACE;
  LabelTextRect.Top  := StartPos.Y - TEXT_SPACE;
  LabelTextRect.Right := LabelTextRect.Left + Size.cx + TEXT_SPACE * 2;
  LabelTextRect.Bottom := LabelTextRect.Top + Size.cy + TEXT_SPACE * 2;
  Bitmap.Canvas.Pen.Width := 1;
  Bitmap.Canvas.Rectangle(LabelTextRect.IntRect);
  Bitmap.Canvas.Font.Color := clBlack;
  //Put out text in black, using current Font for Bitmap.
  Bitmap.Canvas.TextOut(StartPos.X, StartPos.Y, Self.Name);

  if LabelPinned then begin
    FPinRect.Left := LabelPos.X;
    FPinRect.Top := LabelTextRect.Top - Round(FPinBitmap.Height * PIN_SCALE) + 5;
    FPinRect.Right := FPinRect.Left + Round(FPinBitmap.Width * PIN_SCALE);
    FPinRect.Bottom := FPinRect.Top + Round(FPinBitmap.Height * PIN_SCALE);
    Bitmap.Canvas.StretchDraw(FPinRect.IntRect, FPinBitmap);
    FPinHeadPos := FPinRect.TopLeft;
    FPinHeadPos.X := FPinHeadPos.X + 10;
    FPinHeadPos.Y := FPinHeadPos.Y + 7;
    //DrawBall(Bitmap,FPinHeadPos,clBlue);
  end;

end;

procedure TEllipse.AnimateLabel(IntervalTimeMs : Extended);
const
   LABEL_K = 0.1;
   LABEL_M = 2;
   LABEL_ACCEL_DAMPEN = 0.005;
   LABEL_VEL_DAMPEN = 0.8;
   LABEL_VEL_MAX = 2;
   LABEL_OVERLAP_DAMPEN = 0.08;
   LABEL_LENGTH = 10;
   UP_VECT : TPointf = (x:0;y:-1);
var
  i : integer;
  LabelVect : Tpointf;
  TempForce : Tpointf;
  SpringStretch: single;
  OverlapV : TPointf;
  DeltaPos : TPointf;
  //OverlapLen : single;
begin
  if Self.LabelPinned then exit;
  LabelVect := Self.LabelPos - Self.Pos;
  Self.LabelSpringLength := Self.XRadius + LABEL_LENGTH;
  SpringStretch := LabelVect.length - Self.LabelSpringLength;

  TempForce := LabelVect * -1;
  TempForce.ScaleToLen(LABEL_K*SpringStretch);
  Self.LabelForce := TempForce + Self.LabelForce;
  Self.LabelForce := Self.LabelForce + UP_VECT;

  Self.LabelAccel := Self.LabelAccel + Self.LabelForce/LABEL_M;
  Self.LabelForce := ZERO_VECT;
  Self.LabelAccel := Self.LabelAccel * LABEL_ACCEL_DAMPEN;
  Self.LabelVel := Self.LabelVel + Self.LabelAccel * IntervalTimeMs;
  Self.LabelVel := Self.LabelVel * LABEL_VEL_DAMPEN;
  while Self.LabelVel.Length > LABEL_VEL_MAX do begin
    Self.LabelVel := Self.LabelVel * LABEL_VEL_DAMPEN;
  end;
  DeltaPos := Self.LabelVel * IntervalTimeMs;
  if DeltaPos.Length > 50 then begin
    DeltaPos.ScaleToLen(50);
  end;
  Self.LabelPos := Self.LabelPos + DeltaPos;
end;


procedure TEllipse.Animate(IntervalTimeMs : Extended);
begin
  AnimateLabel(IntervalTimeMS);
  //Add additional animate stuff here....
end;



//=============================================


end.

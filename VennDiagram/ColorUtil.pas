unit ColorUtil;

interface

  uses
    Windows, Classes, Graphics, Controls,
    ExtCtrls, math, Pointf, Rectf;

  const
    COLOR_BLEND_DEF_FACTOR = 60;  //0-100

  procedure ColorToRGB16(Color : TColor; var Red, Blue, Green : Color16); forward;
  function  RGB16ToColor (Red, Blue, Green : Color16) : TColor; forward;
  function  DarkerColor (Color : TColor; PctColor : byte= COLOR_BLEND_DEF_FACTOR) : TColor; forward;
  function  LighterColor (Color : TColor; PctColor : byte=COLOR_BLEND_DEF_FACTOR) : TColor; forward;
  function ColorBlend (ColorA, ColorB : TColor; PctA : byte) : TColor; forward;
  procedure GradientFill(Bitmap : TBitmap; Color1, Color2 : TColor; Rect : TRect); forward;


implementation

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

  function DarkerColor (Color : TColor; PctColor : byte=COLOR_BLEND_DEF_FACTOR) : TColor;
  begin
    Result := ColorBlend(Color, clBlack, Pctcolor);
  end;

  function  LighterColor (Color : TColor; PctColor : byte = COLOR_BLEND_DEF_FACTOR) : TColor;
  begin
    Result := ColorBlend(Color, clWhite, PctColor);
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


end.

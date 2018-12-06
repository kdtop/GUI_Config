unit TMGGraphUtil;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Dialogs, ExtCtrls, math, Pointf, Rectf, ColorUtil;

//==================================================
// From source below.
// http://www.delphigeist.com/2009/12/bitmap-flip-and-mirror.html
// (Not indicated to be copyrighted)
// 12/28/11
//==================================================
// bitmap max width = 32768 pixels
const CMAX_BITMAP_WIDTH = 1024 * 32;

// define a static array of TRGBTriple
type TArrayOfPixel = array[0..CMAX_BITMAP_WIDTH -1] of TRGBTriple;
     PArrayOfPixel = ^TArrayOfPixel;

  TTMGBitmap = class Helper for TBitmap
  //NOTe: This is a HELPER class.  So SELF will refer to the
  //      TBitmap object, not the Self of TTMGBitmap
  public
    procedure FlipHorizontal;
    procedure FlipVertical;
    procedure MirrorHorizontal;
    procedure MirrorVertical;
  end;
//==================================================
//End code from http://www.delphigeist.com/2009/12/bitmap-flip-and-mirror.html
// (more below, so marked)
//==================================================


procedure DrawBall(ABitmap : TBitmap; X, Y : integer; Color : TColor; Radius : word = 5; Filled : boolean = true); overload;
procedure DrawBall(ABitmap : TBitmap; P : TPointf; Color : TColor; Radius : word = 5;Filled : boolean = true); overload;
procedure DrawSquare(ABitmap : TBitmap; X, Y : integer; Color : TColor; Radius : word = 5; Filled : boolean = true); overload;
procedure DrawSquare(ABitmap : TBitmap; P : TPointf; Color : TColor; Radius : word = 5; Filled : boolean = true); overload;
procedure DrawSquare(ABitmap : TBitmap; Rect : TRect; Color : TColor; Filled : boolean = true); overload;
procedure DrawFilledRect(ABitmap : TBitmap; Rect : TRect; FillColor : TColor;
                         BorderColor : TColor = clBlack; BorderThickness : integer = 1;
                         FillStyle : TBrushStyle = bsSolid);
const
  clShadow = $575757;
  clYellow1 = $0CD6ED;
  clYellow2 = $0CE7ED;

implementation

procedure DrawSquare(ABitmap : TBitmap; Rect : TRect; Color : TColor; Filled : boolean = true);
begin
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
  DrawSquare(ABitmap, Rect, Color, Filled);
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

//==================================================
// From source below.
// http://www.delphigeist.com/2009/12/bitmap-flip-and-mirror.html
// (Not indicated to be copyrighted)
// 12/28/11
//==================================================

  { TTMGBitmap }
  procedure TTMGBitmap.FlipHorizontal;
  var y, x : Integer;
      Row : PArrayOfPixel;
      tmp : TRGBTriple;
  begin
    for y := 0 to Self.Height -1 do begin
      // scan each line starting from top
      Row := Self.ScanLine[y];
      // from left side of the bitmap to half it's size
      for x := 0 to Self.Width div 2 do begin
        // replace left side with right side of the bitmap
        // this is the magical flip
        tmp := Row[x];
        Row[x] := Row[Self.Width -x -1];
        Row[Self.Width -x -1] := tmp;
      end;// for x := 0 to Self.Width div 2 do begin
    end;// for y := 0 to Self.Height -1 do begin
  end;

  procedure TTMGBitmap.FlipVertical;
  var i, y : integer;
      RowSrc, RowDest : PArrayOfPixel;
      // temporary bitmap on which we draw the
      // flipped bitmap
      tmpBitmap : TBitmap;
  begin
    tmpBitmap := TBitmap.Create;   // create a temporary bitmap
    tmpBitmap.Assign(Self);  // assign self to it
    // scan each line starting from top
    for y := 0 to Self.Height -1 do begin
       RowSrc := Self.ScanLine[y];  // RowSrc is current line from self
       RowDest := tmpBitmap.ScanLine[Self.Height -1 -y]; // RowDest is current line from tmpBitmap
       for i := 0 to Self.Width -1 do begin  // copy each pixel from RowSrc to RowDest
         RowDest[i] := RowSrc[i];
       end;
    end;// for y := 0 to Self.Height -1 do begin
    // copy all data from tmpBitmap to self
    Self.Assign(tmpBitmap);
    FreeAndNil(tmpBitmap); // free allocated memory
  end;

  procedure TTMGBitmap.MirrorHorizontal;
  var tmpBmp : TBitmap;
      Left : integer;
  begin
    tmpBmp := TBitmap.Create;  // create a temporary bitmap
    tmpBmp.Assign(Self);  // assign data from self
    tmpBmp.FlipHorizontal; // flip it horizontally
    Left := Self.Width;
    // increase the width of bitmap
    // by two
    Self.Width := Self.Width * 2;
    // draw the temporary bitmap
    // with x = Left and y = 0
    Self.Canvas.Draw(Left, 0, tmpBmp);
    FreeAndNil(tmpBmp);  // free allocated memory
  end;

  procedure TTMGBitmap.MirrorVertical;
  var tmpBmp : TBitmap;
      Top : integer;
  begin
    tmpBmp := TBitmap.Create;  // create a temporary bitmap
    tmpBmp.Assign(Self);  // assign data from self
    tmpBmp.FlipVertical;  // flip it vertically
    Top := Self.Height;
    // increase the height of bitmap
    // by two
    Self.Height := Self.Height * 2;
    // draw the temporary bitmap
    // with x = 0 and y = Top
    Self.Canvas.Draw(0, Top, tmpBmp);
    FreeAndNil(tmpBmp);  // free allocated memory
  end;
//==================================================
//End code from http://www.delphigeist.com/2009/12/bitmap-flip-and-mirror.html
//==================================================


end.


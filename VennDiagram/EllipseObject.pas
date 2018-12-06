unit EllipseObject;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Dialogs, ExtCtrls, math, Pointf, Rectf, ColorUtil, TMGGraphUtil, StrUtils,
  OmniXML, OmniXML_Types,
{$IFDEF USE_MSXML}
  OmniXML_MSXML,
{$ENDIF}
  OmniXMLPersistent;

const
  TWO_PI = 3.14159 * 2;
  ELLIPSE_DRAW_FREQ_RAD = 0.1;  //Draw a point around ellipse every X radians
  ELLIPSE_NUM_SEGS = Round((TWO_PI / ELLIPSE_DRAW_FREQ_RAD))+1;
  TEXT_SPACE = 3;
  CRLF = #13#10;

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

  TSelHandle =      (hselNone          ,
                     hselX             ,
                     hselY             ,
                     hselTopLeft       ,
                     hselMidLeft       ,
                     hselBottomLeft    ,
                     hselMidBottom     ,
                     hselBottomRight   ,
                     hselMidRight      ,
                     hselTopRight      ,
                     hselMidTop        ,
                     hselLabel         ,
                     hselInfoOrZoom    ,
                     hselPinhead       ,
                     hselDelete        ,
                     hselEject         ,
                     hselNetRegion     ,
                     hselBody          );

    TDragMode =     (tdmNone,                  //not being dragged
                     tdmOverContainer,         //Dragged over a potiential container object
                     tdmNotIntoContainer);     //Not to be dropped into container upon mouseup.

const
   //LAST_HANDLE_SEL : TSelHandle = hselNetRegion;
   LAST_HANDLE_SEL = hselBody;

type
  THandleInfo = record
    Rect : TRectf;
    Hint : string;
    HintHoverStart : Int64;
    HintDelay : integer;  //milliseconds
    HintMaxDisplay : integer;  //milliseconds
    Visible : boolean;
    ShowPos : TPointf;
    Enabled : boolean;
  end;

  TBitmapPair = record
    LO, HI : TBitmap;
    procedure Free;
    function Select(HiMode : boolean) : TBitmap;
  end;

  TEllipse = class(TPersistent)
    Protected
      FRect : TRectf;  //this is the bounding rect for the object
      FCorner : array [bcTOP_LEFT..bcTOP_RIGHT] of TPointf;
      RegionPt : array [0 .. ELLIPSE_NUM_SEGS] of TPoint;
      RegionPointNum : word;
      FLastSysTime : Int64;
      FWinRegion : HRGN;
      FPos : TPointf;
      FRotation : single;  //Radians.  Angle between the X-axis and the major axis of the ellipse
      FSinRot, FCosRot : extended;
      FXRadius, FYRadius : single;
      FXHandlePt : TPointf;
      FYHandlePt : TPointf;
      FPinBMs : TBitmapPair;
      FPinHeadPos : TPointf;
      FVisible : Boolean;
      FLabelPinned : Boolean;
      HostBitmapRect : TRect;
      FHostBitmap : TBitmap; //doesn't own bitmap;

      FLabelPos : TPointf;
      //FLabelRect : TRectf;

      LabelVel : TPointf;
      LabelAccel : TPointf;
      LabelForce : TPointf;
      LabelAccelAvg : TPointfAvg;
      //FVel  : TPointf;

      FName : string;
      FNameSize : TSize;
      FColor : TColor;
      FHotColorMode : boolean;
      FZOrderNum : integer;
      FDataValue1 : single;     //misc storage for user use.
      FDataValue2 : single;     //misc storage for user use.
      FDataP1 : TPointf;        //misc storage for user use.
      FDataP2 : TPointf;        //misc storage for user use.
      FDataStr1 : string;       //misc storage for user use.
      FDataStr2 : string;       //misc storage for user use.
      FDataPtr1 : pointer;      //misc storage for user use.
      FDataPtr2 : pointer;      //misc storage for user use.
      FDataInt1 : integer;      //misc storage for user use.
      FDataInt2 : integer;      //misc storage for user use.
      FBorderThickness : byte;
      FBorderColor : TColor;
      FShowBorder : boolean;
      FShowHandles : boolean;
      FShowBoundingRect : boolean;
      FShowCorners : boolean;
      FAllowEllipseShape : boolean; //if false, object will always be round.
      FShowLabel : boolean;
      FID : string;

      function GetLabelRectProperty : TRectf;
      procedure SetName(Value: string);
      procedure SetNameDynamic(Value: string); dynamic;
      procedure GetLenAngle(Vect : TPointf; var Len : integer; var Angle : single);
      function GetBoundingCorner(Corner : TBoundingCorner) : TPoint;
      procedure SetXHandlePt (Value : TPointf);
      procedure SetYHandlePt (Value : TPointf);
      procedure SetXRadius(Value : single);
      procedure SetXRadiusDynamic(Value : single); dynamic;
      procedure SetYRadius(Value : single);
      procedure SetYRadiusDynamic(Value : single); dynamic;
      procedure SetHandlePtDynamic(SelHandle : TSelHandle; value : TPointf); dynamic;
      procedure SetVisibleDynamic(Value : Boolean); dynamic;
      procedure SetVisible(Value : Boolean);
      function GetPoint(Alpha : single) : TPointf; dynamic;
      procedure CalcRegionPoints;
      procedure SetGeometry; dynamic;
      procedure SetupHandleInfoRects; dynamic;
      function GetIntPoint : TPoint;

      function CreateWinRegion : THandle; //User SHOULD call FreeWinRegion when done with handle
      procedure SetPos(Value : TPointf);
      procedure SetPosDynamic(Value : TPointf); dynamic;
      procedure SetLabelPos(Value : TPointf);
      procedure SetLabelPosY(Value : single);
      procedure SetLabelPosX(Value : single);
      //procedure SetLabelPosDynamic(Value : TPointf); dynamic;
      procedure SetRotation(Value : Single);
      procedure SetRotationDynamic(Value : Single);dynamic;
      procedure AnimateLabel(IntervalTimeMs : Extended); dynamic;
      procedure CreateBitmapPair(var Pair : TBitmapPair; ResourceName : string);
      procedure SetHostBitmap(Value : TBitmap);
    public
      //FLabelRect : TRectf;
      HandleInfo : array[hselNone .. LAST_HANDLE_SEL] of THandleInfo;
      HideHint : boolean;  //A master switch for all hints.  Default is FALSE
      DragMode: TDragMode;
      //HostBitmap : TBitmap; //doesn't own bitmap;
      ObjectPtr : pointer; //allow object contain pointer to something else.
      function HostBitmapHeight : integer;
      function HostBitmapWidth : integer;
      function HostBitmapCenter : TPointf;
      function GetLabelRect(Bitmap : TBitmap; ALabelPos : TPointf) : TRectf;
      function IntervalSysTime : Extended; //returns in milliseconds;
      procedure SetHandlePt(SelHandle : TSelHandle; value : TPointf);
      procedure RenderHandles(Bitmap : TBitmap; MousePos : TPoint);
      procedure RenderBoundingRect(Bitmap : TBitmap; MousePos : TPoint); dynamic;
      function ContainsPointInRect(Pt : TPoint) : boolean; dynamic;
      function ContainsPointInBody(Pt : TPoint) : boolean; dynamic;
      function WhichHandleSelected(Pt : TPoint) : TSelHandle; dynamic;
      function HandleIsResizer(AHandle : TSelHandle) : boolean;
      function HandleIsActionBtn(AHandle : TSelHandle) : boolean;
      procedure MovePos(DeltaPos : TPointf);
      function GetObjColorForMouse(MousePos : TPoint) : TColor; dynamic;
      procedure RenderOutlineTrace(Bitmap : TBitmap; Color : TColor; Thickness : byte; MousePos : TPoint);
      procedure Render(Bitmap : TBitmap; MousePos : TPoint; var OrderNum : integer); Dynamic;
      procedure RenderPin(Bitmap : TBitmap; MousePos : TPoint);
      procedure RenderLabel(Bitmap : TBitmap; MousePos : TPoint); dynamic;
      procedure RenderLabelLine(Bitmap : TBitmap; MousePos : TPoint); dynamic;
      procedure CheckAndRenderHints(Bitmap : TBitmap; MousePos : TPoint); dynamic;
      procedure RenderHint(Bitmap: TBitmap; BottomLeftPt : TPoint; Text : String);
      procedure HideAllHints;
      function ColorForMouse(Color : TColor; MousePos : TPoint; Rect : TRectf) : TColor;
      procedure Animate(IntervalTimeMs : extended); dynamic;
      function SetAProperty(Name, Value : string): boolean; dynamic;
      //function ClippedLabelPos : TPointf; dynamic;
      constructor Create;
      destructor Destroy;
      //-------------------------
      property BoundingCorner[Corner : TBoundingCorner] : TPoint read GetBoundingCorner;
      property WinRegion : HRGN read FWinRegion;    //Owned by this object
      property Pos : TPointf read FPos write SetPos;
      property LabelPos : TPointf read FLabelPos write SetLabelPos;
      property LabelRect : TRectf read GetLabelRectProperty;
      property XHandlePt : TPointf read FXHandlePt write SetXHandlePt;
      property YHandlePt : TPointf read FYHandlePt write SetYHandlePt;
      property IntPos : TPoint read GetIntPoint;
      property BoundingRect : TRectf read FRect;
      property DataValue1 : single read FDataValue1 write FDataValue1;
      property DataValue2 : single read FDataValue2 write FDataValue2;
      property DataP1 : TPointf read FDataP1 write FDataP1;
      property DataP2 : TPointf read FDataP2 write FDataP2;
      property DataStr1 : string read FDataStr1 write FDataStr1;
      property DataStr2 : string read FDataStr2 write FDataStr2;
      property DataPtr1 : pointer read FDataPtr1 write FDataPtr1;
      property DataPtr2 : pointer read FDataPtr2 write FDataPtr2;
      property DataInt1 : integer read FDataInt1 write FDataInt1;
      property DataInt2 : integer read FDataInt2 write FDataInt2;
      property ZOrderNum : integer read FZOrderNum write FZOrderNum;
      property HotColorMode : boolean read FHotColorMode write FHotColorMode;
      property NameSize : TSize read FNameSize;
      property HostBitmap : TBitmap read FHostBitmap write SetHostBitmap;
    published
      property Name : string read FName write FName;
      property ID : string read FID write FID;
      property PosX : single read FPos.X write FPos.x;
      property PosY : single read FPos.Y write FPos.y;
      property Rotation : single read FRotation write SetRotation;
      property XRadius : single read FXRadius write SetXRadius;
      property YRadius : single read FYRadius write SetYRadius;
      property Visible : boolean read FVisible write SetVisible;
      property LabelPinned : Boolean read FLabelPinned write FLabelPinned;
      property LabelPosX : single read FLabelPos.X write SetLabelPosX;
      property LabelPosY : single read FLabelPos.Y write SetLabelPosY;
      property Color : TColor read FColor write FColor;
      property BorderThickness : byte read FBorderThickness write FBorderThickness;
      property BorderColor : TColor read FBorderColor write FBorderColor;
      property ShowBorder : boolean read FShowBorder write FShowBorder;
      property ShowHandles : boolean read FShowHandles write FShowHandles;
      property ShowBoundingRect : boolean read FShowBoundingRect write FShowBoundingRect;
      property ShowCorners : boolean read FShowCorners write FShowCorners;
      property AllowEllipseShape : boolean read FAllowEllipseShape write FAllowEllipseShape;
      property ShowLabel : boolean read FShowLabel write FShowLabel;
  end; {class}

function Between(A, N1, N2 : integer) : boolean;
procedure FreeWinRegion(Region: THandle);

Const
  HANDLE_KNOB_RADIUS = 5;
  HANDLE_SHRINK_FACTOR = 0.9;
  RESIZE_SQR_SIZE = 8; //4;
  RESIZE_SQR_COLOR = clBlack;
  RESIZE_SPACE = RESIZE_SQR_SIZE div 2;
  DEFAULT_HINT_DELAY = 1000; //milliseconds
  DEFAULT_HINT_MAX_DISPLAY = 5000; //milliseconds


implementation

{$R ELLIPSE.RES}

  function Between(A, N1, N2 : integer) : boolean;
  begin
    Result := (A >= N1) and (A <= N2);
  end;

  //=================================================

  procedure TBitmapPair.Free;
  begin
    FreeAndNil(LO);
    FreeAndNil(HI);
  end;

  function TBitmapPair.Select(HiMode : boolean) : TBitmap;
  begin
    if HiMode then Result := HI
    Else Result := LO;
  end;

  //=================================================
  constructor TEllipse.Create;
  var i : TSelHandle;
  begin
    Inherited Create;
    FWinRegion := HRGN(0);
    ShowBorder := false;
    ShowHandles := false;
    ShowBoundingRect := false;
    ShowCorners := false;
    AllowEllipseShape := true;
    LabelAccelAvg.InsertPt:= 0;
    ShowLabel := false;
    HideHint := false;
    FLastSysTime := 0;
    LabelPinned := False;
    CreateBitmapPair(FPinBMs, 'THUMB');
    DragMode := tdmNone;
    ObjectPtr := nil;
    HostBitmap := nil; //triggers change of HostBitmapRect
    FDataValue1 := 0;
    FDataValue2 := 0;
    FDataP1 := NULL_VECT;
    FDataP2 := NULL_VECT;
    FDataStr1 := '';
    FDataStr2 := '';
    FDataPtr1 := nil;
    FDataPtr2 := nil;
    FDataInt1 := 0;
    FDataInt2 := 0;

    //Init hint stuff.
    for i := hselNone to LAST_HANDLE_SEL do begin
      HandleInfo[i].Visible := false;
      HandleInfo[i].Enabled := true;
      HandleInfo[i].HintDelay := DEFAULT_HINT_DELAY;
      HandleInfo[i].HintMaxDisplay := DEFAULT_HINT_MAX_DISPLAY;
    end;
    for i := hselX to hselMidTop do begin
      HandleInfo[i].Hint := 'Click and drag to resize';
    end;
    HandleInfo[hselLabel].Hint := 'Double click to edit';
    HandleInfo[hselPinhead].Hint := 'Click to release label';
    HandleInfo[hselBody].Hint := 'Click and drag to move';
    HandleInfo[hselNetRegion].Hint := 'This is the Result Set';
  end;

  destructor TEllipse.Destroy;
  begin
    FreeWinRegion(FWinRegion);
    FPinBMs.Free;
    inherited Destroy;
  end;

  procedure TEllipse.SetNameDynamic(Value: string);
  begin
    FName := Value;
  end;

  procedure TEllipse.SetName(Value: string);
  begin
    SetNameDynamic(Value);
  end;


  function  TEllipse.SetAProperty(Name, Value : string): boolean;
  //Manually set specified property.  Only works for properties that
  //  have been coded for.
  //Returns TRUE if handled, otherwise false.
  begin
    Result := false;
    if Name = 'Name' then begin
      Name := Value;
      Result := true;
    end else if Name = 'ID' then begin
      ID := Value;
      Result := true;
    end;
  end;

  procedure TEllipse.SetHostBitmap(Value : TBitmap);
  begin
    FHostBitmap := Value;
    HostBitmapRect.TopLeft := ZERO_POINT;
    if assigned(Value) then begin
      HostBitmapRect.Right := Value.Width;
      HostBitmapRect.Bottom := Value.Height;
    end else begin
      HostBitmapRect.BottomRight := ZERO_POINT;
    end;
  end;

  procedure TEllipse.CreateBitmapPair(var Pair : TBitmapPair; ResourceName : string);
    Procedure CreateOne(var Bitmap : TBitmap; Name : string);
    begin
      Bitmap := TBitmap.Create;
      Bitmap.LoadFromResourceName(hInstance,Name);
      Bitmap.PixelFormat:= pf24bit;
      Bitmap.Transparent:= true;
      Bitmap.TransparentColor:= RGB(255, 0, 255);
    end;

  begin
    CreateOne(Pair.LO, ResourceName+'_LO');
    CreateOne(Pair.HI, ResourceName+'_HI');
  end;




  function TEllipse.GetPoint(Alpha : single) : TPointf;
  //Note: makes use of FCosRot and FSinRot (set in CalcRegionPoints
  var
    Sin, Cos : Extended;
  begin
    SinCos(Alpha, Sin, Cos);
    Result.X := (FXRadius * Cos * FCosRot) - (FYRadius * Sin * FSinRot);
    Result.Y := (FXRadius * Cos * FSinRot) + (FYRadius * Sin * FCosRot);
  end;


  procedure TEllipse.CalcRegionPoints;

  var
    Angle : single;
    OnePoint : TPointf;
  begin
    SinCos(FRotation, FSinRot, FCosRot);
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
    FXRadius := Abs(Value);
    SetGeometry;
  end;

  procedure TEllipse.SetXRadius(Value : single);
  begin
    SetXRadiusDynamic(Value);
    if not AllowEllipseShape then SetYRadiusDynamic(Value);
  end;

  procedure TEllipse.SetYRadiusDynamic(Value : single);
  begin
    FYRadius := Abs(Value);
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

  procedure TEllipse.SetHandlePtDynamic(SelHandle : TSelHandle; value : TPointf);
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

  procedure TEllipse.SetHandlePt(SelHandle : TSelHandle; Value : TPointf);
  begin
    SetHandlePtDynamic(SelHandle, Value);
  end;

  procedure TEllipse.SetVisibleDynamic(Value : Boolean);
  //Set up this way so decendant can override;
  begin
    FVisible := Value;
    if FVisible = false then begin
      Self.HideAllHints;
      Self.ZOrderNum := 0;
    end;
  end;

  procedure TEllipse.SetVisible(Value : Boolean);
  begin
    SetVisibleDynamic(Value);
  end;

  procedure TEllipse.SetupHandleInfoRects;

    function ShrinkVect(P : TPointf; Factor : single) : TPointf;
    var Vect : TPointf;
    begin
      Vect := P - Self.Pos;
      Vect := Vect * Factor;
      Vect := Self.Pos + Vect;
      Result := Vect;
    end;

    function HdlToSpot(Dir : TSelHandle) : TRectSpot;
    begin
      Result := TRectSpot(Ord(Dir) - Ord(hselTopLeft));
    end;

    procedure Setup1Rect(Dir : TSelHandle; Spot : TPointf);
    begin
      HandleInfo[Dir].Rect.Width := RESIZE_SQR_SIZE;
      HandleInfo[Dir].Rect.Height := RESIZE_SQR_SIZE;
      HandleInfo[Dir].Rect.Center := Spot;
      case Dir of
        hselX,
        hselY          : HandleInfo[Dir].Visible := AllowEllipseShape;
        hselTopLeft ..
        hselMidTop     : HandleInfo[Dir].Visible := ShowBoundingRect;
        else             HandleInfo[Dir].Visible := false;
      end;
    end;

  var Dir : TSelHandle;
      Spot : TPointf;
  begin
    for dir := hselNone to LAST_HANDLE_SEL do HandleInfo[Dir].Visible := true; //default
    HandleInfo[hselNone].Rect.IntRect := NULL_RECT;
    Setup1Rect(hselX, ShrinkVect(FRect.MidRight, 0.8));
    Setup1Rect(hselY, ShrinkVect(FRect.MidTop, 0.8));
    for dir := hselTopLeft to hselMidTop do begin
      Spot := FRect.Spot(HdlToSpot(Dir));
      Setup1Rect(Dir, Spot);
    end;
  end;


  procedure TEllipse.SetGeometry;

    procedure RotateCorners(Angle : single);
    var  X,Y  : single;
         i : TBoundingCorner;
    begin
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


  var P : TPoint;
      //X,Y  : single;
      i : TBoundingCorner;
  begin
    FRect.Top                 := -(FYRadius + BorderThickness);
    FRect.Left                := -(FXRadius + BorderThickness);
    FRect.Bottom              := +(FYRadius + BorderThickness);
    FRect.Right               := +(FXRadius + BorderThickness);
    FCorner[bcTOP_LEFT]       := FRect.TopLeft;
    FCorner[bcBOTTOM_LEFT]    := FRect.BottomLeft;
    FCorner[bcBOTTOM_RIGHT]   := FRect.BottomRight;
    FCorner[bcTOP_RIGHT]      := FRect.TopRight;
    if FRotation <> 0 then RotateCorners(FRotation);
    P := FPos.IntPoint;
    for i:= bcTOP_LEFT to bcTOP_RIGHT do FCorner[i] := FCorner[i] + P;
    FRect := FRect + P; //Translate Rect
    SetupHandleInfoRects;
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
  {
  procedure TEllipse.SetLabelPosDynamic(Value : TPointf);
  const
    LABEL_PIN_MARGIN : TRect = (Left:5; Top:15; Right:10; Bottom:5);
  begin
    //First Clip Value
    if value.x < LABEL_PIN_MARGIN.Left then value.x := LABEL_PIN_MARGIN.Left;
    if value.y < LABEL_PIN_MARGIN.Top  then value.y := LABEL_PIN_MARGIN.Top;
    if value.x > HostBitmapWidth-LABEL_PIN_MARGIN.Right then value.x := HostBitmapWidth-LABEL_PIN_MARGIN.Right;
    if value.y > HostBitmapHeight-LABEL_PIN_MARGIN.Bottom then value.y := HostBitmapHeight-LABEL_PIN_MARGIN.Bottom;

    FLabelPos := Value;
    FLabelRect := GetLabelRect(HostBitmap, FLabelPos); //kt 11/11/12
  end;}

  procedure TEllipse.SetLabelPos(Value : TPointf);
  const
    LABEL_PIN_MARGIN : TRect = (Left:5; Top:15; Right:10; Bottom:5);
  begin
    //First Clip Value
    if value.x < LABEL_PIN_MARGIN.Left then value.x := LABEL_PIN_MARGIN.Left;
    if value.y < LABEL_PIN_MARGIN.Top  then value.y := LABEL_PIN_MARGIN.Top;
    if value.x > HostBitmapWidth-LABEL_PIN_MARGIN.Right then value.x := HostBitmapWidth-LABEL_PIN_MARGIN.Right;
    if value.y > HostBitmapHeight-LABEL_PIN_MARGIN.Bottom then value.y := HostBitmapHeight-LABEL_PIN_MARGIN.Bottom;

    FLabelPos := Value;
    //FLabelRect := GetLabelRect(HostBitmap, FLabelPos); //kt 11/11/12
  end;



  procedure TEllipse.SetLabelPosY(Value : single);
  var P : TPointf;
  begin
    P := FLabelPos;
    P.y := Value;
    SetLabelPos(P);
  end;

  procedure TEllipse.SetLabelPosX(Value : single);
  var P : TPointf;
  begin
    P := FLabelPos;
    P.x := Value;
    SetLabelPos(P);
  end;
                 {

  function TEllipse.ClippedLabelPos : TPointf;
  begin
    //Will be overriden in descendant.
    Result := FLabelPos;
  end;            }



  procedure TEllipse.MovePos(DeltaPos : TPointf);
  begin
    Pos := FPos + DeltaPos; //will trigger SetPos --> SetGeometry
  end;

  function TEllipse.CreateWinRegion : THandle;
  begin
    Result := CreatePolygonRgn(RegionPt, RegionPointNum, ALTERNATE);
  end;


  procedure FreeWinRegion(Region: THandle);
  begin
    DeleteObject(Region);
  end;


  procedure TEllipse.RenderOutlineTrace(Bitmap : TBitmap;
                                        Color : TColor;
                                        Thickness : byte;
                                        MousePos : TPoint);
  var
    OnePoint : TPoint;
    i : integer;
    TempColor : TColor;
    MouseOver : boolean;

  begin
    //MouseOver := ContainsPointInBody(MousePos);
    MouseOver := HotColorMode;

    if Color = clBlack then begin
      if MouseOver then begin
        TempColor := ColorBlend(clBlack, clDkGray, 50);
      end else begin
        TempColor := Color;
      end;
    end else begin
      TempColor := ColorForMouse(Color, MousePos, FRect);
    end;

    Bitmap.Canvas.Pen.Color := TempColor;
    Bitmap.Canvas.Pen.Width := Thickness;
    for i := 0 to RegionPointNum -1 do begin
      OnePoint := RegionPt[i];
      if (i = 0) or (OnePoint.X < 0) then begin
        Bitmap.Canvas.MoveTo(OnePoint.X, OnePoint.Y);
      end else begin
        Bitmap.Canvas.LineTo(OnePoint.X, OnePoint.Y);
      end;
    end;

    if Thickness > 1 then begin
      if Color = clBlack then begin
        if MouseOver then begin
          TempColor := ColorBlend(clDkGray, clBlack, 90);
        end else begin
        TempColor := ColorBlend (clDkGray, clBlack, 60);
        end;
      end else begin
        TempColor := ColorBlend (clBlack, clDkGray, 40);
        TempColor := ColorForMouse(TempColor, MousePos, FRect);
      end;

      Bitmap.Canvas.Pen.Color := TempColor;
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

  function TEllipse.HandleIsResizer(AHandle : TSelHandle) : boolean;
  //Of the various handles, is the passed handle one of the resizer handles?
  begin
    Result := AHandle in [ hselTopLeft    ,
                           hselMidLeft    ,
                           hselBottomLeft ,
                           hselMidBottom  ,
                           hselBottomRight,
                           hselMidRight   ,
                           hselTopRight   ,
                           hselMidTop      ];

  end;

  function TEllipse.HandleIsActionBtn(AHandle : TSelHandle) : boolean;
  begin
    Result := AHandle in [ hselInfoOrZoom    ,
                           hselDelete        ,
                           hselEject       ];
  end;


  function TEllipse.WhichHandleSelected(Pt : TPoint) : TSelHandle;
  var j : TSelHandle;

  begin
    Result := hselNone;
    for j := hselX to LAST_HANDLE_SEL do begin
      if HandleInfo[j].Enabled
      and HandleInfo[j].Rect.ContainsPoint(Pt)
      and HandleInfo[j].Visible then begin
        Result := j;
        exit;
      end;
    end;
    if (Result = hselNone) and
      (ContainsPointInBody(Pt)) then begin
      Result := hselBody;
    end;
  end;

  function TEllipse.ContainsPointInRect(Pt : TPoint) : boolean;
  var ARect : TRectf;
      Handle : TSelHandle;
  begin
    if ShowBoundingRect then begin
      ARect := FRect;
      ARect.Grow(RESIZE_SPACE);
      Result := ARect.ContainsPoint(Pt);
    end else begin
      Result := PtInRegion(FWinRegion, Pt.X, Pt.Y);
    end;
    if (Result = false) and ShowLabel then begin
      Handle := WhichHandleSelected(Pt);
      Result := (Handle <> hselNone) and (Handle <> hselNetRegion);
    end;
  end;

  function TEllipse.ContainsPointInBody(Pt : TPoint) : boolean;
  //Does mouse overlie the Ellipse of the object
  //This function is much more computationally expensive than ContainsPointInRect
  //Best to first call that one first to exclude easy points if possible
  var V : TPointf;
      Angle : single;
      RadiusPt : TPointf;
      LMouse,LRadius : single;
  begin
    V := Pt - FPos;
    Angle := V.Angle;
    RadiusPt := GetPoint(Angle);
    LMouse := V.Length;  //Length from center to mouse
    LRadius := RadiusPt.Length; //Length from center to rim of ellipse
    Result := (LMouse < LRadius);
  end;


  procedure TEllipse.RenderHandles(Bitmap : TBitmap; MousePos : TPoint);
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
    if not HandleInfo[hselX].Enabled or not HandleInfo[hselY].Enabled then exit;
    HandleInfo[hselX].Visible := true;
    Draw1Handle(FXHandlePt);
    if AllowEllipseShape then begin
      HandleInfo[hselY].Visible := true;
      Draw1Handle(FYHandlePt);
    end;
  end;

  procedure TEllipse.RenderBoundingRect(Bitmap : TBitmap; MousePos : TPoint);
  Var j : TSelHandle;
      TempColor : TColor;
      var Rect : TRectf;
  begin
    for j :=hselTopLeft to hselMidTop do begin
      Rect := HandleInfo[j].Rect;
      if not HandleInfo[j].Enabled then continue;
      HandleInfo[j].Visible := true;
      TempColor := ColorForMouse(RESIZE_SQR_COLOR, MousePos, Rect);
      DrawSquare(Bitmap, Rect.IntRect, TempColor);
    end;
  end;


  procedure TEllipse.Render(Bitmap : TBitmap; MousePos : TPoint; var OrderNum : integer);

  Var i : TBoundingCorner;
      TempColor : TColor;
  begin
    Self.Visible := true;
    HandleInfo[hselBody].Visible := true;
    Inc(OrderNum);  ZOrderNum := OrderNum;
    HostBitmap := Bitmap;  //property.  Triggers save of HostBitmapRect
    //HostBitmapRect.TopLeft := ZERO_POINT;
    //HostBitmapRect.Right := Bitmap.Width;
    //HostBitmapRect.Bottom := Bitmap.Height;
    if (BorderThickness > 0) and ShowBorder then begin
      RenderOutlineTrace(Bitmap, BorderColor, BorderThickness, MousePos);
    end;
    if FWinRegion <> HRGN(0) then FreeWinRegion(FWinRegion);
    FWinRegion := CreateWinRegion;
    SelectClipRgn(Bitmap.Canvas.Handle, FWinRegion);
    Bitmap.Canvas.Brush.Style := bsSolid;
    TempColor := GetObjColorForMouse(MousePos);
    GradientFill(Bitmap, TempColor, Darkercolor(TempColor), FRect.IntRect);
    SelectClipRgn(Bitmap.Canvas.Handle, 0);
    //Leave region encircling object until next draw, or until destructor
    if ShowHandles then RenderHandles(Bitmap, MousePos);
    if ShowBoundingRect then RenderBoundingRect(Bitmap, MousePos);
    if ShowCorners then begin  //Bounding rectangle, rotated to match Rotation
      for i := bcTOP_LEFT to bcTOP_RIGHT do begin
        DrawBall(Bitmap, FCorner[i], clGreen);
      end;
    end;
  end;

  function TEllipse.GetObjColorForMouse(MousePos : TPoint) : TColor;
  begin
    if ContainsPointInBody(MousePos) then begin
      Result := LighterColor(Color);
    end else begin
      Result := Color;
    end;
  end;

  procedure TEllipse.RenderHint(Bitmap: TBitmap; BottomLeftPt : TPoint; Text : String);
  var Size : TSize;
      StartPos : TPoint;
      TempRect : TRect;
  const HINT_OFFSET = 5;
  begin
    if Text = '' then exit;
    Size := Bitmap.Canvas.TextExtent(Text);
    StartPos.X := BottomLeftPt.X + HINT_OFFSET;
    StartPos.Y := BottomLeftPt.Y - (Size.cy + HINT_OFFSET);

    //Draw blank square to put text on, with border
    TempRect.Left := StartPos.X - TEXT_SPACE;
    TempRect.Top  := StartPos.Y - TEXT_SPACE;
    TempRect.Right := TempRect.Left + Size.cx + TEXT_SPACE * 2;
    TempRect.Bottom := TempRect.Top + Size.cy + TEXT_SPACE * 2;

    Bitmap.Canvas.Brush.Style := bsSolid;
    Bitmap.Canvas.Pen.Color := clWhite;  //border color
    Bitmap.Canvas.Brush.Color := clYellow2; //background
    Bitmap.Canvas.Pen.Width := 1;
    //Bitmap.Canvas.Rectangle(TempRect);
    Bitmap.Canvas.RoundRect(TempRect.Left, TempRect.Top,
                            TempRect.Right, TempRect.Bottom,
                            10, 10);

    Bitmap.Canvas.Font.Color := clBlack;
    //Put out text in black, using current Font for Bitmap.
    Bitmap.Canvas.TextOut(StartPos.X, StartPos.Y, Text);

  end;


  procedure TEllipse.CheckAndRenderHints(Bitmap : TBitmap; MousePos : TPoint);


  var Dir : TSelHandle;
      CurSysTime, FreqPerSec: Int64;
      HintHoverTime : single;
      Offset : TPointf;
      NetRegionHintShown : boolean;
  begin
    NetRegionHintShown := false;
    if HideHint then exit;
    for Dir := hselNone to LAST_HANDLE_SEL do begin
      if HandleInfo[Dir].Visible
      and HandleInfo[Dir].Enabled
      and HandleInfo[Dir].Rect.ContainsPoint(MousePos) then begin
        if HandleInfo[Dir].HintHoverStart = 0 then begin
          QueryPerformanceCounter(HandleInfo[Dir].HintHoverStart);
        end else begin
          QueryPerformanceCounter(CurSysTime);
          QueryPerformanceFrequency(FreqPerSec);
          HintHoverTime := ((CurSysTime - HandleInfo[Dir].HintHoverStart) / FreqPerSec) * 1000;
          if (HintHoverTime > HandleInfo[Dir].HintDelay) and
             (HintHoverTime < HandleInfo[Dir].HintMaxDisplay) then begin
            if HandleInfo[Dir].ShowPos = NULL_VECT then begin
              Offset := NE_VECT;
              Offset.ScaleBy(5);
              HandleInfo[Dir].ShowPos := MousePos + Offset;
            end;
            if (Dir = hselNetRegion) then NetRegionHintShown := true;
            if (Dir = hselBody) and NetRegionHintShown then continue;
            RenderHint(Bitmap, HandleInfo[Dir].ShowPos.IntPoint, HandleInfo[Dir].Hint);
          end;
        end;
      end else begin
        HandleInfo[Dir].HintHoverStart := 0;
        HandleInfo[Dir].ShowPos := NULL_VECT;
      end;
    end;
  end;

  procedure TEllipse.HideAllHints;
  var Dir : TSelHandle;
  begin
    for Dir := hselNone to LAST_HANDLE_SEL do begin
      HandleInfo[Dir].Visible := false;
      //HandleInfo[Dir].HintHoverStart := 0;
      HandleInfo[Dir].ShowPos := NULL_VECT;
    end;
  end;

  function TEllipse.HostBitmapHeight : integer;
  begin
    Result := HostBitmapRect.Bottom - HostBitmapRect.Top;
  { if assigned(HostBitmap) then begin
      Result := HostBitmap.Height;
    end else Result := 0; }
  end;

  function TEllipse.HostBitmapWidth : integer;
  begin
    Result := HostBitmapRect.Right - HostBitmapRect.Left;
    {if assigned(HostBitmap) then begin
      Result := HostBitmap.Width;
    end else Result := 0; }
  end;

  function TEllipse.HostBitmapCenter : TPointf;
  begin
    Result.x := HostBitmapWidth / 2;
    Result.y := HostBitmapHeight / 2;
  end;


  procedure TEllipse.RenderLabelLine(Bitmap : TBitmap; MousePos : TPoint);
  var LineVect : TPointf;
      DesiredLen : single;
      Pt : TPointf;
  begin
    Pt := LabelPos;
    //LabelPos := ClippedLabelPos;
    //Draw line from label to edge of circle.
    LineVect := Self.Pos - Pt;
    DesiredLen := LineVect.Length - Self.XRadius;  //assumes round object, as VennObjs will be.
    LineVect.ScaleToLen(DesiredLen);
    LineVect := LineVect + Pt;
    Bitmap.Canvas.Pen.Color := clBlack;
    Bitmap.Canvas.Pen.Width := 2;
    Bitmap.Canvas.PenPos := Pt.IntPoint;
    Bitmap.Canvas.LineTo(LineVect.IntX, LineVect.IntY);
  end;

  procedure TEllipse.RenderPin(Bitmap : TBitmap; MousePos : TPoint);
  const PIN_SCALE = 0.06;
  var Size : TSize;
      Pt, StartPos : TPoint;
      TempRect : TRectf;
      IconBM : TBitmap;

  begin
    if not Self.LabelPinned then exit;
    Size := Bitmap.Canvas.TextExtent(Self.Name);
    Pt := LabelPos.IntPoint;
    //Pt := ClippedLabelPos.IntPoint;
    StartPos := Pt;
    StartPos.Y := StartPos.Y - Size.cy;
    TempRect.Top  := StartPos.Y - TEXT_SPACE;
    TempRect.Left := Pt.X;
    TempRect.Top := TempRect.Top - Round(FPinBMs.LO.Height * PIN_SCALE) + 5;
    TempRect.Right := TempRect.Left + Round(FPinBMs.LO.Width * PIN_SCALE);
    TempRect.Bottom := TempRect.Top + Round(FPinBMs.LO.Height * PIN_SCALE);

    IconBM := FPinBMs.Select(TempRect.ContainsPoint(MousePos));
    Bitmap.Canvas.StretchDraw(TempRect.IntRect, IconBM);
    FPinHeadPos := TempRect.Center;
    HandleInfo[hselPinhead].Rect := TempRect;
    HandleInfo[hselPinhead].Visible := true;

  end;

  function TEllipse.GetLabelRectProperty : TRectf;
  begin
    try
      Result := GetLabelRect(HostBitmap,FLabelPos);
    finally
      //nothing
    end;
  end;

  function TEllipse.GetLabelRect(Bitmap : TBitmap; ALabelPos : TPointf) : TRectf;
  var Size : TSize;
      LabelPt, StartPos : TPointf;
      MaxWidth, MaxHeight : integer;
  begin
    if assigned(Bitmap) then begin
      Size := Bitmap.Canvas.TextExtent(Self.Name);
    end else begin
      Size.cx := 10;  //arbitrary small number
      Size.cy := 10;  //arbitrary small number
    end;
    LabelPt := ALabelPos;
    MaxWidth := HostBitmapWidth;
    MaxHeight := HostBitmapHeight;

    //Draw text at LabelPos, offset so that LabelPos is in the middle
    StartPos.X := LabelPt.X - (Size.cx div 2);
    StartPos.Y := LabelPt.Y - Size.cy;

    //if StartPos.X < TEXT_SPACE then StartPos.X := TEXT_SPACE;
    //if StartPos.Y < TEXT_SPACE then StartPos.Y := TEXT_SPACE;
    //---------------

    Result.Left := StartPos.IntX - TEXT_SPACE;
    Result.Top  := StartPos.IntY - TEXT_SPACE;
    Result.Right := Result.Left + Size.cx + TEXT_SPACE * 2;
    Result.Bottom := Result.Top + Size.cy + TEXT_SPACE * 2;

    //---------------
    {
    if Result.Right > MaxWidth then begin
      Result.Left := Result.Left - (Result.Right - MaxWidth);
      Result.Right := MaxWidth;
    end;

    if Result.Bottom > MaxHeight then begin
      Result.Top := Result.Top - (Result.Bottom - MaxHeight);
      Result.Bottom := MaxHeight;
    end; }
    //---------------
  end;


  procedure TEllipse.RenderLabel(Bitmap : TBitmap; MousePos : TPoint);
  //Separate from main Render, so that this can be done after all the
  //other spheres have been drawn, so that labels will be on top.
  var Size : TSize;
      Pt, StartPos : TPointf;
      TempRect : TRectf;
  begin
    if not HandleInfo[hselLabel].Enabled then exit;
    Size := Bitmap.Canvas.TextExtent(Self.Name);
    //Pt := ClippedLabelPos;
    Pt := LabelPos;

    //Draw text at LabelPos, offset so that LabelPos is in the middle
    //StartPos := Pt;
    //StartPos.X := StartPos.X - (Size.cx div 2);
    //StartPos.Y := StartPos.Y - Size.cy;
    TempRect := GetLabelRect(Bitmap, Pt);
    StartPos.x := TempRect.Left+TEXT_SPACE;
    StartPos.y := TempRect.Top+TEXT_SPACE;
    if not ShowLabel then exit;

    //Draw blank square to put text on, with red border
    //FLabelRect := GetLabelRect(Bitmap, Pt);
    HandleInfo[hselLabel].Rect := TempRect; //FLabelRect;
    HandleInfo[hselLabel].Visible := ShowLabel;

    Bitmap.Canvas.Brush.Style := bsSolid;
    Bitmap.Canvas.Pen.Color := clRed;
    Bitmap.Canvas.Brush.Color := ColorForMouse(clLtGray, MousePos, TempRect);
    Bitmap.Canvas.Pen.Width := 1;
    Bitmap.Canvas.Rectangle(TempRect.IntRect);
    Bitmap.Canvas.Font.Color := clBlack;
    //Put out text in black, using current Font for Bitmap.
    Bitmap.Canvas.TextOut(StartPos.IntX, StartPos.IntY, Self.Name);
  end;


  function TEllipse.ColorForMouse(Color : TColor; MousePos : TPoint; Rect : TRectf) : TColor;
  begin
    Result := Color;
    if Rect.ContainsPoint(MousePos) then begin
      Result := LighterColor(Color);
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
    LabelVect : Tpointf;
    TempVel : TPointf;
    TempForce : Tpointf;
    SpringStretch: single;
    DeltaPos : TPointf;
    TempAccel : TPointf;
    LabelSpringLength : single;
  begin
    if LabelPinned then exit;
    LabelVect := LabelPos - Pos;
    LabelSpringLength := XRadius + LABEL_LENGTH;
    SpringStretch := LabelVect.length - LabelSpringLength;

    TempForce := LabelVect * -1;
    TempForce.ScaleToLen(LABEL_K*SpringStretch);
    LabelForce := TempForce + Self.LabelForce;
    LabelForce := LabelForce + UP_VECT;

    LabelAccelAvg.Add(LabelAccel);
    TempAccel := LabelAccelAvg.Avg + LabelForce/LABEL_M;

    LabelForce := ZERO_VECT;
    TempAccel := TempAccel * LABEL_ACCEL_DAMPEN; //original line above

    TempVel := (LabelVel + TempAccel * IntervalTimeMs) * LABEL_VEL_DAMPEN;
    LabelVel := TempVel;
    while LabelVel.Length > LABEL_VEL_MAX do begin
      LabelVel := LabelVel * LABEL_VEL_DAMPEN;
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


  function TEllipse.IntervalSysTime : Extended; //returns in milliseconds;
  var
    CurSysTime, FreqPerSec: Int64;
  begin
    QueryPerformanceFrequency(FreqPerSec);
    QueryPerformanceCounter(CurSysTime);
    Result := ((CurSysTime - FLastSysTime) / FreqPerSec) * 1000;
    FLastSysTime := CurSysTime;
    if Result > 100 then Result := 1; //prevent problems after big delay
  end;


//=============================================


end.

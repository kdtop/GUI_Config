unit VennObject;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Dialogs, ExtCtrls, Math, EllipseObject, StrUtils, TMGStrUtils,
  TMGGraphUtil, ColorUtil, Pointf, Rectf, TypesU,
  OmniXML, OmniXML_Types,
{$IFDEF USE_MSXML}
  OmniXML_MSXML,
{$ENDIF}
  OmniXMLPersistent;

type
  TCombinationStyle = (tcsNone                = -1,
                       tcsIncludeOptional     =  0,  // --> A or B
                       tcsIncludeRequired     =  1,  // --> A and B
                       tcsExclude             =  2,  // --> A not B
                       tcsObject              =  3,  // --> (not a logic term)
                       tcsEquals              =  4,  // --> =
                       tscNotEquals           =  5,  // --> <>
                       tscNotEqualsALT        =  6,  // --> '=
                       tcsLessThan            =  7,  // --> <
                       tcsGreaterThan         =  8,  // --> >
                       tcsGreaterOrEquals     =  9,  // --> >=
                       tcsGreaterOrEqualsALT  = 10,  // --> '<
                       tcsLessThanOrEquals    = 11,  // --> <=
                       tcsLessThanOrEqualsALT = 12,  // --> '>
                       tcsPlus                = 13,  // --> +
                       tcsMinus               = 14,  // --> -
                       tcsAnd                 = 15,  // --> &
                       tcsNotAnd              = 16,  // --> '&
                       tcsOr                  = 17,  // --> !
                       tcsNotOr               = 18,  // --> '!
                       tcsContains            = 19,  // --> [
                       tcsNotContains         = 20,  // --> '[
                       tcsNotFollows          = 21,  // --> ']
                       tcsFollows             = 22,  // --> ]
                       tcsComma               = 23); // --> ,

const
  MAX_LOGIC_WORD : TCombinationStyle = tcsComma;
  FIRST_COMPARATOR : TCombinationStyle = tcsEquals;
  LAST_COMPARATOR : TCombinationStyle = tcsComma;

  FIRST_NUMERIC_COMPARATOR : TCombinationStyle = tcsEquals;
  LAST_NUMERIC_COMPARATOR : TCombinationStyle = tcsLessThanOrEqualsALT;

  SELECTED_DRAW_COLOR : TColor = clWhite;
  UNSELECTED_DRAW_COLOR : TColor = clBlack;
  //SELECTED_LABEL_BORDER_COLOR : TColor = clBlack;

  LOGIC_WORDS : Array[tcsNone..tcsComma] of string = (
                  'NONE',  //-1
                  'OR',    //0
                  'AND',   //1
                  'NOT',   //2
                  'OBJ',   //3
                  '=',     //4
                  '<>',    //5
                  '''=',   //6
                  '<',     //7
                  '>',     //8
                  '>=',    //9
                  '''<',   //10
                  '<=',    //11
                  '''>',   //12
                  '+',     //13
                  '-',     //14
                  '&',     //15
                  '''&',   //16
                  '!',     //17
                  '''!',   //18
                  '[',     //19
                  '''[',   //20
                  ''']',   //21
                  ']',     //22
                  ','      //23
                );

type
  TRgnIntersection = (rgniNone, rgniPartialOverlap, rgniAcontainsB, rgniBcontainsA);
  TZoomMode = (zmNormal,zmZoomingIn, zmZoomingOut,zmAtMax,zmDisappear);

  TFloatingText = class(TObject)
  public
    Font : TFont;
    Text : string;  //Text to display
    Pos  : TPoint;  //(X,Y) of text to put on screen.
    constructor Create;
    destructor Destroy;
  end;

  TVennObj = class;

  TNotifyVennObjActionRequestEvent = procedure (VennObj : TVennObj; var Allowed : boolean);
  //TVennObjNotifyEvent = procedure (VennObj : TVennObj);
  TNotifyForVennObjectEvent = procedure(Obj: TVennObj) of object;

  TVennObjList = class;

  TVennObj = class(TEllipse)
    Protected
      DebugBitmap : TBitmap;  //temp
      FComboMode : TCombinationStyle;
      FChildren : TVennObjList;
      FParent : TVennObj;
      FSelected : boolean;
      FUnselectedColor : TColor;  //will save original color when in selected mode
      ShadowBM : TBitmap;
      ZoomBMs : TBitmapPair;
      EjectBMs : TBitmapPair;
      TrashBMs : TBitmapPair;
      FXPctOfParent : single;
      FYPctOfParent : single;
      FRadiusPctOfParent : single;
      UnZoomedRadius : single;
      UnZoomedPos : TPointf;
      FZoomMode : TZoomMode;
      FZoomPct : Single; //0-100
      FZoomedLabelStart : TPointf;
      FDrawAsSquircle : boolean;

      SkipRender : boolean;
      ShadowOffsetV : TPoint;
      ShowShadow : boolean;
      ShadowColor : TColor;
      SelectedBorderColor : TColor;
      FOnFinishedZoomOut : TNotifyEvent;
      FRgnManager : TVennObj;
      FLogicDescr : TStringList;
      FLogicDescrERR : TStringList;
      FCanDrag : boolean;
      FFunctionType : TfnnName;

      FFloatingTextList : TList; //will be filled with pointers to TFloatingText objects
      FOnDeleteRequest : TNotifyVennObjActionRequestEvent;

      procedure SetSelected(Value : boolean);
      procedure SetComboMode (Value : TCombinationStyle);
      procedure SetPosDynamic(Value : TPointf); override;
      procedure SetNameDynamic(Value: string); override;
      //function ClippedLabelPos : TPointf; override;
      procedure SetParent(Value : TVennObj);
      function HasParent: boolean;
      procedure SetHandlePtDynamic(SelHandle : TSelHandle; value : TPointf); override;
      procedure SetupInfoOrZoomRect;
      procedure SetupEjectRect;
      procedure SetupDeleteRect;
      procedure SetupBodyRect;
      function GetPoint(Alpha : single) : TPointf; override;
      procedure SetXRadiusDynamic(Value : single); override;
      procedure SetYRadiusDynamic(Value : single); override;
      procedure SetZoomMode(Value : TZoomMode);
      procedure SetZoomPct(Value : Single);
      procedure SetVisibleDynamic(Value : Boolean); override;
      procedure SetParentObj(Obj, ParentObj : TVennObj);
      procedure AnimateZoom(IntervalTimeMs : extended; ZoomIn : boolean);
      procedure RenderLabel(Bitmap : TBitmap; MousePos : TPoint); dynamic;
      procedure RenderASet(Bitmap : TBitmap; Region : HRGN; MousePos : TPoint);
      procedure CheckLabelCollision(VennObject : TVennObj; AList: TVennObjList; IntervalTimeMs : Extended);
      function GetGrandparent : TVennObj;
      procedure SetupHandleInfoRects; override;
      procedure StripXMLHeaderFooter(var XML : XmlString);
      function AddXMLHeaderFooter(XML : XmlString) : XMLString;
      procedure StripXMLObjOpenClose(var XML : XmlString);
      procedure DeleteBlankXMLLines(SL : TStringList); overload;
      procedure DeleteBlankXMLLines(Var Text : XMLString); overload;
      procedure IndentXML(SL : TStringList; Prefix : string = '  '); overload;
      function IndentXML(Text : XMLString; Prefix : string = '  ') : XMLString; overload;
      function ExtractChildXML(SL : TStringList) : XMLString;
      procedure SetDrawAsSquircle(Value : boolean);
      function GetCanResize : boolean;
      procedure SetCanResize(Value : boolean);
      function GetCanDelete  : boolean;
      procedure SetCanDelete(Value : boolean);
      function GetCanEject  : boolean;
      procedure SetCanEject(Value : boolean);

    public
      NetRegion : HRGN; //Owned here.  Region is defined by combination of children
      PotentialParent : TVennObj;  //elh
      AlwaysEnableZoomIcon : boolean; //if false, then only show zoom icon if has children.
      //HostBitmap : TBitmap; //doesn't own bitmap;  <-- moved to TEllipseObj
      function LogicWords(mode:TCombinationStyle):string;
      procedure AddFloatingText(Pos : TPoint; Text : String; Font : TFont = nil);
      procedure AutoArrangeChildrenForFormulaDisplay;
      procedure ClearFloatingTextList;
      procedure RenderFloatingText(ABitmap : TBitmap);
      function RadiusToBoundingBox : integer;
      procedure RenderActiveSet(Bitmap : TBitmap; MousePos : TPoint);
      procedure CheckForOverlappingLabels;
      procedure AutoArrangeChildren;
      procedure AutoArrangeChildrenAndGrandchildren;
      procedure SetPosPctOfParent;
      procedure SetRadiusPctOfParent;
      function GetObjColorForMouse(MousePos : TPoint) : TColor; override;
      procedure RenderBoundingRect(Bitmap : TBitmap; MousePos : TPoint); override;
      procedure Render(Bitmap : TBitmap; MousePos : TPoint; var OrderNum : integer); override;
      procedure RenderAndChild(Bitmap : TBitmap; MousePos : TPoint; var OrderNum : integer);
      procedure RenderChildren(Bitmap : TBitmap; MousePos : TPoint; var OrderNum : integer);
      procedure CheckAndRenderChildNum(Bitmap : TBitmap; MousePos : TPoint);
      procedure RenderChildNum(Bitmap : TBitmap; Num : integer; MousePos : TPoint);
      procedure RenderZoomIcon(Bitmap : TBitmap; MousePos : TPoint);
      procedure RenderEjectIcon(Bitmap : TBitmap; MousePos : TPoint);
      procedure RenderDeleteIcon(Bitmap : TBitmap; MousePos : TPoint);
      procedure RenderShadow(Bitmap : TBitmap; MousePos : TPoint);
      function ContainerObj(Obj : TVennObj) : TVennObj;
      function ContainsPointOrChild(Pt : TPoint) : TVennObj;
      function ObjInRegion(VennObject : TVennObj) : TVennObj;
      function ZoomingOrChild : boolean;
      function ZoomingChild : boolean;
      function HasZoomSibling : boolean;
      function HasSibling : boolean;
      function HasChild : boolean;
      procedure GetNetRegion(var NetRegion : HRGN;  ObjList: TVennObjList; var SetIsNull : boolean);
      procedure RenderOutlineTraceAndChildrens(Bitmap : TBitmap; Color : TColor; Thickness : byte; MousePos : TPoint);
      procedure RenderBoundingOrChildIfSel(Bitmap : TBitmap; MousePos : TPoint);
      procedure RenderLabelAndChild(Bitmap : TBitmap; MousePos : TPoint);
      procedure RenderPinAndChild(Bitmap : TBitmap; MousePos : TPoint);
      procedure CheckAndRenderHints(Bitmap : TBitmap; MousePos : TPoint); override;
      function WhichHandleSelected(Pt : TPoint) : TSelHandle; override;
      function ContainsPointInRect(Pt : TPoint) : boolean; override;
      function ContainsPointInBody(Pt : TPoint) : boolean; override;
      procedure AnimateAndChild(IntervalTimeMs : Extended);
      procedure AnimateChildren(IntervalTimeMs : Extended);
      procedure ResizeFromParent;
      function ItemAtPoint(Pt : TPoint; CurSelObj :TVennObj = nil; ListOfAll : TVennObjList=nil) : TVennObj; dynamic;
      procedure HideAllHintsAndChildren;
      function TouchingSiblings : boolean;
      function GetXMLRepresentation : XmlString;
      function AddLF2XML(XML : XMLString) : XMLString;
      function GetStrippedXMLRepresentation : XmlString;
      function GetCoreXMLRepresentation(ErrList : TStringList) : XmlString;
      procedure SetPropertiesFromCoreXML (XML : XMLString);
      procedure LoadFromXML(XML : XmlString);
      function GetLogicString(ErrList : TStringList) : string;
      procedure LoadFromLogicString(Logic : String); dynamic;
      function LocationPath : string;
      function SetAProperty(Name, Value : string): boolean; dynamic;
      constructor Create(Parent : TVennObj);
      destructor Destroy;  dynamic;
      //------------------------
      property Parent : TVennObj read FParent write SetParent;
      property Grandparent : TVennObj read GetGrandparent;
      property RgnManager : TVennObj read FRgnManager write FRgnManager;
      Property ZoomedLabelStart : TPointf read FZoomedLabelStart write FZoomedLabelStart;
      property ZoomMode : TZoomMode read FZoomMode write SetZoomMode;
      property ZoomPct : single read FZoomPct write SetZoomPct;
      property Children : TVennObjList read FChildren;
      property CanResize : boolean read GetCanResize write SetCanResize;
      property CanDelete : Boolean read GetCanDelete write SetCanDelete;
      property CanDrag : boolean read FCanDrag write FCanDrag;
      property CanEject : boolean read GetCanEject write SetCanEject;
      Property FunctionType : TfnnName read FFunctionType write FFunctionType; //only used if Object represents a function
      property OnDeleteRequest : TNotifyVennObjActionRequestEvent read FOnDeleteRequest write FOnDeleteRequest;
    published
      property Selected : boolean read FSelected write SetSelected;
      property CombinationMode : TCombinationStyle read FComboMode write SetComboMode;
      Property OnFinishedZoomOut : TNotifyEvent read FOnFinishedZoomOut write FOnFinishedZoomOut;
      property XPctOfParent : single read FXPctOfParent write FXPctOfParent;
      property YPctOfParent : single read FYPctOfParent write FYPctOfParent;
      property RadiusPctOfParent : single read FRadiusPctOfParent write FRadiusPctOfParent;
      property DrawAsSquircle : boolean read FDrawAsSquircle write SetDrawAsSquircle;
  end;

  //NOTE: this class is not responsible for objects that
  //      it contains.  Users must free them manually.
  TVennObjList = class (TObject)
    private
      //FList : TStringList;
      FList : TList;
      function GetItem(Index : Integer) : TVennObj;
      procedure SetItem(Index : Integer; Value : TVennObj);
      function GetItemCount : integer;
      //procedure SetName(Index : Integer; Value : string);
      function GetName(Index : integer) : string;
    public
      function Add(Item : TVennObj) : integer; overload;
      //function Add(Name : string; Item : TVennObj) : integer; overload;
      function IndexOf(Item : TVennObj) : integer; overload;
      function IndexOf(Name : string) : integer; overload;
      function IndexOfID(ID : string) : integer;
      procedure Delete(Index : Integer); overload;
      procedure Delete(Item : TVennObj); overload;
      procedure Delete(Name : string); overload;
      procedure DeleteID(ID : string);
      procedure DestroyAll;
      procedure Clear;
      function GetByName(Name : string) : TVennObj;
      function GetByID(ID : string) : TVennObj;
      function MoveToFront(Item : TVennObj) : integer;
      property Count : Integer read GetItemCount;
      //property Name[Index : Integer] : string read GetName write SetName;
      property Item[Index : Integer] : TVennObj read GetItem write SetItem; default;
      constructor Create;
      destructor Destroy;
  end;

  function  CompareRgnsA(A, B : HRGN) : TRgnIntersection; forward;
  function  RgnsAreEqual(A, B : HRGN) : boolean; forward;
  function  RgnIsNULL(Rgn: HRGN) : boolean;  forward;
  procedure RgnAandB(var Result: HRGN; A, B : HRGN; var ResultIsNull : boolean); forward;
  procedure RgnAorB (var Result: HRGN; A, B : HRGN; var ResultIsNull : boolean); forward;
  procedure RgnAnotB(var Result: HRGN; A, B : HRGN; var ResultIsNull : boolean); forward;
  function  RgnContainsPt(Rgn : HRGN; Pt : TPoint) : boolean; forward;
  function  NewRgnCopy(A : HRGN; MaxSize : TPoint) : HRGN; forward;
  function  IsComparator(Mode : TCombinationStyle) : boolean;
  function  IsAndOrNot(Mode : TCombinationStyle) : boolean;

const
  ZOOM_ENLARGEMENT_FACTOR = 1.1;

  XML_HEADER = '<data PropFormat="node">';
  XML_FOOTER = '</data>';
  XML_VIN_OPEN = '<TVennObj>';
  XML_VIN_CLOSE = '</TVennObj>';
  XML_RGN_MGR_OPEN = '<TRgnManager>';
  XML_RGN_MGR_CLOSE = '</TRgnManager>';


implementation

{$R VIN_PICS.RES}

  uses RegionManager,
       frmVennU; //temp for debugging

  var SHOW_DEBUG_SET : byte;


  function RgnMgr(Obj : TVennObj) : TRgnManager;
  begin
    Result := TRgnManager(Obj.RgnManager);
  end;

//========================================================
//========================================================

  function NewRgnCopy(A : HRGN; MaxSize : TPoint) : HRGN;
  //NOTE: this function creates a NEW region.  Caller will own object
  var isNull : boolean;
  begin
    Result := CreateRectRgn(0, 0, MaxSize.X, MaxSize.Y);
    RgnAandB(Result, A, Result, isNull);
  end;

  function RgnIsNULL(Rgn: HRGN) : boolean;  //returns TRUE if Region has no area
  var tempRgnRECT : TRect;
      RgnBoxRslt : integer;
  begin
    RgnBoxRslt := GetRgnBox(Rgn, tempRgnRECT);
    Result := (RgnBoxRslt = NULLREGION);
  end;

  function  RgnsAreEqual(A, B : HRGN) : boolean;
  begin
    Result := EqualRgn(A, B);
  end;

  function CompareRgnsA(A, B : HRGN) : TRgnIntersection;
  var   tempRgn : HRGN;
        CombineRslt : integer;
  label CompDONE;
  begin
    tempRgn := CreateRectRgn(0, 0, 10, 10);  //initial region that will be discarded.
    //Test for overlap
    CombineRslt := CombineRgn(tempRgn, A, B, RGN_AND);  // A AND B
    if CombineRslt = NULLREGION then begin
      Result := rgniNone;
      goto CompDone;
    end;
    //Ranges are overlapped.  Now, is one contained in the other?
    //Possibilities: A contains all of B
    //               B contains all of A
    //               A extends outside of B
    //               B extends outside of A
    //               A and B both extend ouside each other
    CombineRslt := CombineRgn(tempRgn, A, B, RGN_DIFF);  // A NOT IN B
    if CombineRslt = NULLREGION then begin
      Result := rgniBcontainsA;
      goto CompDONE;
    end;
    CombineRslt := CombineRgn(tempRgn, B, A, RGN_DIFF);  // B NOT IN A
    if CombineRslt = NULLREGION then begin
      Result := rgniAcontainsB;
      goto CompDONE;
    end;
    Result := rgniPartialOverlap;
  CompDONE:
    FreeWinRegion(tempRgn)
  end;

  procedure RgnAandB(var Result: HRGN; A, B : HRGN; var ResultIsNull : boolean);
  //Return set that contained in by A and B
  var CombineResult : integer;
  begin
    CombineResult := CombineRgn(Result, A, B, RGN_AND);
    if CombineResult = ERROR then begin
      Raise Exception.Create('Error combining windows regions.');
    end;
    ResultIsNull :=  (CombineResult = NULLREGION);
  end;

  procedure RgnAnotB(var Result: HRGN; A, B : HRGN; var ResultIsNull : boolean);
  //Return set defined by A NOT B
  var CombineResult : integer;
  begin
    CombineResult := CombineRgn(Result, A, B, RGN_diff);
    if CombineResult = ERROR then begin
      Raise Exception.Create('Error combining windows regions.');
    end;
    ResultIsNull :=  (CombineResult = NULLREGION);
  end;

  procedure RgnAorB (var Result: HRGN; A, B : HRGN; var ResultIsNull : boolean);
  //Return set that defined by A OR B
  var CombineResult : integer;
  begin
    if RgnIsNULl(B) then begin  //this block is debug only.
      //debug := true;
    end;
    CombineResult := CombineRgn(Result, A, B, RGN_OR);
    if CombineResult = ERROR then begin
      Raise Exception.Create('Error combining windows regions.');
    end;
    ResultIsNull :=  (CombineResult = NULLREGION);
  end;

  function RgnContainsPt(Rgn : HRGN; Pt : TPoint) : boolean;
  begin
    Result := PtInRegion(Rgn, Pt.X, Pt.Y);
  end;

//============================================================
//============================================================
  function IsComparator(Mode : TCombinationStyle) : boolean;
  begin
    Result := ((Ord(Mode) >= Ord(FIRST_COMPARATOR)) and (ord(mode) <= ord(LAST_COMPARATOR)));
  end;

  function  IsAndOrNot(Mode : TCombinationStyle) : boolean;
  begin
    Result := (Mode = tcsIncludeOptional) or
              (Mode = tcsIncludeRequired) or
              (Mode =tcsExclude);
  end;


//============================================================
//============================================================
  constructor TFloatingText.Create;
  begin
    Inherited Create;
    Font := TFont.Create;
    Font.Name := 'Times New Roman';
    Font.Size := 12;
  end;

  destructor TFloatingText.Destroy;
  begin
    Font.Free;
    Inherited Destroy;
  end;

//============================================================
//============================================================

  constructor TVennObjList.Create;
  begin
    Inherited Create;
    FList := TList.Create;
  end;

  destructor TVennObjList.Destroy;
  begin
    FList.Free;  //User is responsible for contained objects.
    Inherited Destroy;
  end;

  function TVennObjList.GetItem(Index : Integer) : TVennObj;
  begin
    if (Index < 0) or (Index >= FList.Count) then begin
      Result := nil;
      exit;
    end;
    Result := TVennObj(FList.Items[Index]);
  end;

  procedure TVennObjList.SetItem(Index : Integer; Value : TVennObj);
  begin
    if (Index > 0) and (Index < FList.Count) then begin
    end;
    FList.Items[Index] := Value;
  end;


  function TVennObjList.IndexOf(Item : TVennObj) : integer;
  var i : integer;
  begin
    Result := -1;
    for i := 0 to FList.Count - 1 do begin
      if FList.Items[i] = Item then begin
        Result := i;
        break;
      end;
    end;
  end;

  function TVennObjList.IndexOf(Name : string) : integer;
  var i : integer;
  begin
    Result := -1;
    for i := 0 to FList.Count - 1 do begin
      if not assigned(FList.Items[i]) then continue;
      if TVennObj(FList.Items[i]).Name = Name then begin
        Result := i;
        break;
      end;
    end;
  end;

  function TVennObjList.IndexOfID(ID : string) : integer;
  //kt Removing case sensitivity in match of ID's.    10/6/13
  var i : integer;
  begin
    Result := -1;
    for i := 0 to FList.Count - 1 do begin
      if not assigned(FList.Items[i]) then continue;
      if UpperCase(TVennObj(FList.Items[i]).ID) = UpperCase(ID) then begin
        Result := i;
        break;
      end;
    end;
  end;


  function TVennObjList.GetByName(Name : string) : TVennObj;
  var i : integer;
  begin
    Result := nil;
    i := IndexOf(Name);
    if (i > -1) then Result := GetItem(i);
  end;

  function TVennObjList.GetByID(ID : string) : TVennObj;
  var i : integer;
  begin
    Result := nil;
    i := IndexOfID(ID);
    if (i > -1) then Result := GetItem(i);
  end;


  function TVennObjList.GetItemCount : integer;
  begin Result := FList.Count; End;

  {
  procedure TVennObjList.SetName(Index : Integer; Value : string);
  begin FList.Strings[Index] := Value; end;
  }

  function TVennObjList.GetName(Index : integer) : string;
  var Obj : TVennObj;
  begin
    Obj := GetItem(Index);
    if not Assigned(Obj) then exit;
    Result := Obj.Name;
    //Result := FList.Strings[Index];
  end;

  function  TVennObjList.Add(Item : TVennObj) : integer;
  begin Result := FList.Add(Item); end;


  {
  function TVennObjList.Add(Name : string; Item : TVennObj) : integer;
  begin Result := FList.AddObject(Name,Item); end;
  }

  procedure TVennObjList.Delete(Name : string);
  var i : integer;
  begin
    i := Self.IndexOf(Name);
    if (i > -1) then begin
      Self.Delete(i);
    end;
  end;

  procedure TVennObjList.DeleteID(ID : string);
  var i : integer;
  begin
    i := Self.IndexOfID(ID);
    if (i > -1) then begin
      Self.Delete(i);
    end;
  end;


  procedure TVennObjList.Delete(Item : TVennObj);
  var i : integer;
  begin
    i := Self.IndexOf(Item);
    if (i > -1) then begin
      Self.Delete(i);
    end;
  end;

  procedure TVennObjList.Delete(Index : Integer);
  begin
    FList.Delete(Index);  //if Index is out of bounds, then let it raise exception
  end;

  procedure TVennObjList.DestroyAll;
  begin
    while Count > 0 do begin
      Self.Item[Count-1].Destroy;  //Destroy --> Deletes itself from this list
      //Delete(Count-1);
    end;
  end;

  procedure TVennObjList.Clear;
  begin FList.Clear;  end;

  function TVennObjList.MoveToFront(Item : TVennObj) : integer;
  begin
    Result := -1;
    if not assigned(Item) then exit;
    Result := IndexOf(Item);
    if Result = -1 then exit;
    if Result = FList.Count - 1 then exit;
    FList.Delete(Result);
    Result := Add(Item);
  end;

//========================================================
//========================================================


  constructor TVennObj.Create(Parent : TVennObj);
  begin
    Inherited Create;
    FChildren := TVennObjList.Create;
    FParent := Parent;
    if assigned(Parent) then begin
      Parent.Children.Add(Self);
    end;
    NetRegion := HRGN(0);
    AllowEllipseShape := false;
    FDrawAsSquircle := false;
    SelectedBorderColor := SELECTED_DRAW_COLOR;
    ShowLabel := true;
    BorderColor := UNSELECTED_DRAW_COLOR;
    FComboMode := tcsIncludeRequired;
    ShowShadow := true;
    ShadowOffsetV.X := 10;
    ShadowOffsetV.Y := 5;
    ShadowColor := clShadow;

    ShadowBM := TBitmap.Create;
    ShadowBM.LoadFromResourceName(hInstance,'SHADOW');
    ShadowBM.PixelFormat:= pf24bit;
    ShadowBM.Transparent:= true;
    ShadowBM.TransparentColor:= clFuchsia; //RGB(255, 0, 255);

    CreateBitmapPair(ZoomBMs, 'ZOOM');
    CreateBitmapPair(EjectBMs, 'EJECT');
    CreateBitmapPair(TrashBMs, 'TRASH');

    ZoomMode := zmNormal;
    ZoomPct := 0;
    OnFinishedZoomOut := nil;

    HandleInfo[hselEject].Hint := 'Click to move object up one level';
    HandleInfo[hselInfoOrZoom].Hint := 'Click to zoom into object';
    HandleInfo[hselDelete].Hint := 'Click to delete object (and any children)';

    FLogicDescr := TStringList.Create;
    FLogicDescrERR := TStringList.Create;

    AlwaysEnableZoomIcon := false;
    CanResize := true;
    CanDelete := true;
    CanEject := true;
    FCanDrag := true;
    FFunctionType := fnnNone;

    FFloatingTextList := TList.Create;
    FOnDeleteRequest := nil;
  end;


  destructor TVennObj.Destroy;
  begin
    if assigned(FParent) then begin
      FParent.Children.Delete(Self);
    end;
    //Each VennObject owns it's children
    while FChildren.Count > 0 do begin
      FChildren[FChildren.Count-1].Destroy;
      //FChildren[i].Free;  //for some reason wasn't calling destroy
    end;
    ShadowBM.Free;
    ZoomBMs.Free;
    TrashBMs.Free;
    EjectBMs.Free;
    FChildren.Free;
    FreeWinRegion(NetRegion);
    FLogicDescr.Free;
    FLogicDescrERR.Free;

    ClearFloatingTextList;
    FFloatingTextList.Free;  //DOES own objects, cleared by ClearFloatingTextList;

    inherited Destroy;
  end;

  function TVennObj.GetCanResize : boolean;
  var i : TSelHandle;
  begin
    Result := false;
    for i := hselX to hselMidTop do begin
      if not HandleInfo[i].Enabled or not HandleInfo[i].Visible then continue;
      Result := true;
      break;
    end;
  end;

  procedure TVennObj.SetCanResize(Value : boolean);
  var i : TSelHandle;
  begin
    for i := hselX to hselMidTop do begin
      HandleInfo[i].Enabled := Value;
    end;
  end;

  function TVennObj.GetCanDelete  : boolean;
  begin
    Result := (HandleInfo[hselDelete].Enabled and HandleInfo[hselDelete].Visible);
  end;

  procedure TVennObj.SetCanDelete(Value : boolean);
  begin
    HandleInfo[hselDelete].Enabled := Value;
  end;

  function TVennObj.GetCanEject  : boolean;
  begin
    Result := (HandleInfo[hselEject].Enabled and HandleInfo[hselEject].Visible);
  end;

  procedure TVennObj.SetCanEject(Value : boolean);
  begin
    HandleInfo[hselEject].Enabled := Value
  end;

  function TVennObj.GetPoint(Alpha : single) : TPointf;
  //Alpha is in radians

  var
    Sin, Cos : Extended;
    Radius : single;
    Sin2, Cos2 : Extended;
    A2,Radius2 : single;
    Quadrant : byte;
    Pct : single;
  type
    TAngleRange = record
      AngleStart,AngleEnd, MapAngleStart: single;
    end;
    TQuadSign = record
      X,Y : shortint;
    end;
  const
    PI = 3.1415926536;
    HALF_PI = PI / 2;
    ARC_SIN_HALF = 0.523598786;  //ArcSin(0.5)
    ARC_COS_HALF = 1.04719755;   //ArcCos(0.5)
    ANGLE_RANGE = (ARC_COS_HALF - ARC_SIN_HALF);

    ANGLE_RANGES : ARRAY[1..4] of TAngleRange = (
      (AngleStart : ARC_SIN_HALF;        AngleEnd : ARC_COS_HALF;        MapAngleStart : 0      ),
      (AngleStart : PI - ARC_COS_HALF;   AngleEnd : PI - ARC_SIN_HALF;   MapAngleStart : 1/2*PI ),
      (AngleStart : PI + ARC_SIN_HALF;   AngleEnd : PI + ARC_COS_HALF;   MapAngleStart : PI     ),
      (AngleStart : 2*PI - ARC_COS_HALF; AngleEnd : 2*PI - ARC_SIN_HALF; MapAngleStart : 3/2*PI )
    );
    QUAD_SIGN : ARRAY[1..4] of TQuadSign = (
     (X :  1; Y : 1 ),
     (X : -1; Y : 1 ),
     (X : -1; Y : -1),
     (X :  1; Y : -1)
    );

    function GetQuadrant(Sin, Cos : Extended) : byte;
    begin
      if (Sin >= 0) then begin
        if (Cos >= 0) then Result := 1 else Result := 2;
      end else begin
        if (Cos < 0) then Result := 3 else Result := 4;
      end;
    end;

  begin
    if FDrawAsSquircle then begin
      while Alpha > (2*PI) do Alpha := Alpha - (2*PI);
      SinCos(Alpha, Sin, Cos);
      Radius := FXRadius; //Note: only XRadius used here.  YRadius for VennObj is the same.
      Quadrant := GetQuadrant(Sin, Cos);
      if (Sin < 0.5) and (Sin > -0.5) then begin  //Left and right sides
        Result.X := Radius * QUAD_SIGN[Quadrant].X;
        Result.Y := Radius * Sin;
      end else if (Cos < 0.5) and (Cos > -0.5) then begin //Top and Bottom
        Result.X := Radius * Cos;
        Result.Y := Radius * QUAD_SIGN[Quadrant].Y;
      end else begin  //The curved corners
        Pct := (Alpha - ANGLE_RANGES[Quadrant].AngleStart) / ANGLE_RANGE;
        A2 := ANGLE_RANGES[Quadrant].MapAngleStart + Pct*PI/2;
        SinCos(A2, Sin2, Cos2);
        Radius2 := Radius * 0.5;
        Result.X := Radius2 * Cos2;
        Result.Y := Radius2 * Sin2;
        Result.X := Result.X + Radius2 * QUAD_SIGN[Quadrant].X;
        Result.Y := Result.Y + Radius2 * QUAD_SIGN[Quadrant].Y;
      end;
    end else begin
      Result := inherited GetPoint(Alpha);
    end;
  end;

  procedure TVennObj.SetDrawAsSquircle(Value : boolean);
  begin
    FDrawAsSquircle := Value;
    CalcRegionPoints;
  end;

  procedure TVennObj.SetNameDynamic(Value: string);
  begin
    FName := Value;
    //FNameSize := Bitmap.Canvas.TextExtent(Text);
  end;


  function  TVennObj.SetAProperty(Name, Value : string): boolean;
  //Manually set specified property.  Only works for properties that
  //  have been coded for.
  //Returns TRUE if handled, otherwise false.
  begin
    Result := inherited SetAProperty(Name, Value);
    if Result = true then exit;
    { //More later.. E.g.
    if Name = 'Name' then begin
      Name := Value;
      Result := true;
    end;
    }
  end;

  procedure TVennObj.SetPropertiesFromCoreXML (XML : XMLString);
  //Example input:
  {   <TVennObj>
        <Name>Object 2</Name>
        <ID>2</ID>
      </TVennObj>  }

    procedure SetupAProperty(Line: String; var Tag, Value : string);
    begin
      Line := Trim(Line);
      Tag := Piece(Piece(Line,'>',1),'<',2);
      Line := Piece(Line,'>',2);
      if Tag = '' then exit;
      Value := Piece(Line,'<',1);
    end;

  var SL : TStringList;
      i  : integer;
      Tag, Value : string;
  begin
    XML := Trim(XML);
    StripXMLObjOpenClose(XML);
    SL := TStringList.Create;
    SL.Text := XML;
    DeleteBlankXMLLines(SL);
    for i := 0 to SL.Count - 1 do begin
      SetupAProperty(SL.Strings[i], Tag, Value);
      SetAProperty(Tag, Value);
    end;
    SL.Free;
  end;


  procedure TVennObj.CheckLabelCollision(VennObject : TVennObj;
                                        AList: TVennObjList;
                                        IntervalTimeMs : Extended);
  const
       LABEL_OVERLAP_DAMPEN = 0.08;

  var
    Obj : TVennObj;
    i : integer;
    OverlapV : TPointf;
    OverlapLen : single;
  begin
    for i := 0 to AList.Count - 1 do begin
      Obj := AList[i];
      if not Assigned(Obj) then continue;
      if Obj = VennObject then continue;
      if not Obj.HandleInfo[hselLabel].Enabled then continue;
      OverlapV := RectOverlapV(Obj.HandleInfo[hselLabel].Rect, VennObject.HandleInfo[hselLabel].Rect);
      OverlapV := OverlapV * LABEL_OVERLAP_DAMPEN;
      OverlapLen := OverlapV.Length;
      if OverlapLen  < 3 then begin
        OverlapV.ScaleBy(OverlapLen / 5);
      end;
      OverlapLen := OverlapV.Length;
      if OverlapLen  < 1 then OverlapV := ZERO_VECT;

      VennObject.LabelForce := VennObject.LabelForce + OverlapV;
    end;
  end;

  function TVennObj.LogicWords(mode:TCombinationStyle):string;
  begin
    result := LOGIC_WORDS[mode];
    result := stringreplace(result,'''<','>= ',[rfIgnoreCase]);
    result := stringreplace(result,'''>','<= ',[rfIgnoreCase]);
    result := stringreplace(result,'<>','NOT =',[rfIgnoreCase]);
    result := stringreplace(result,'''','NOT ',[rfIgnoreCase]);
    result := stringreplace(result,'[','CONTAINS ',[rfIgnoreCase]);
    result := stringreplace(result,']','FOLLOWS ',[rfIgnoreCase]);
    result := stringreplace(result,'&','AND ',[rfIgnoreCase]);
    result := stringreplace(result,'!','OR ',[rfIgnoreCase]);
    result := stringreplace(result,',',' , ',[rfIgnoreCase]);
  end;
  
  procedure TVennObj.GetNetRegion(var NetRegion : HRGN;
                                 ObjList: TVennObjList;
                                 var SetIsNull : boolean);
  //NetRegion should exist prior to calling this.
  //However, if passed as 0, then will be created...
  var OrigRgn : HRGN;
      tempRect : TRect;

    function Combine1(Mode : TCombinationStyle; ForceFirstAsAND : boolean = false) : integer;
    //Result is the number of objects that matched combination mode
    var i : integer;
        Obj : TVennObj;
        ObjRegion : HRGN;
        s : string;
        OrigMode : TCombinationStyle;
    begin
      OrigMode := tcsNone;
      Result := 0;
      if not assigned(ObjList) then exit;
      for i := 0 to ObjList.Count - 1 do begin
        Obj := ObjList[i];
        if Obj.CombinationMode <> Mode then continue;
        if ForceFirstAsAND then begin
          //This is done because if there are only OR mode objects
          //  then the entire screen is shown as selected.
          OrigMode := Mode;
          Mode := tcsIncludeRequired; //Force mode to AND.  Restored at end of loop
        end;
        Inc (Result);
        OrigRgn := NewRgnCopy(NetRegion, HostBitmapRect.BottomRight);
        ObjRegion := Obj.WinRegion;
        if (ObjRegion <> HRGN(0)) then begin
          case Mode of
            tcsIncludeOptional : RgnAorB (NetRegion, NetRegion, ObjRegion, SetIsNull);
            tcsIncludeRequired : RgnAandB(NetRegion, NetRegion, ObjRegion, SetIsNull);
            tcsExclude         : RgnAnotB(NetRegion, NetRegion, ObjRegion, SetIsNull);
            tcsObject          : begin end;  //do nothing.
          end; //case

          if SHOW_DEBUG_SET=2 then begin
            DrawFilledRect(debugBitmap, tempRect, clwhite);
            VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, DebugBitmap); //debugging only.  Remove later.
            RenderASet(DebugBitmap, NetRegion, ZERO_POINT); //debugging only.  Remove later.
            VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, DebugBitmap); //debugging only.  Remove later.
          end;
        end;
        if not SetIsNull and not RgnsAreEqual(OrigRgn, NetRegion) then begin
          s := LogicWords(mode) + ' ';
          FLogicDescr.AddObject(s + Obj.GetLogicString(FLogicDescrERR), Obj);
        end else begin
          FLogicDescrERR.AddObject('Object doesn''t affect set calculations: '+
                                   'Name='+Obj.Name+', Parent path='+Obj.LocationPath,
                                   Obj);
        end;
        FreeWinRegion(OrigRgn);
        if ForceFirstAsAND then begin
          Mode := OrigMode;
          ForceFirstAsAND := false;
        end;
      end;
    end;

  var NumUsed : integer;

  begin
    SetIsNull := true;
    OrigRgn := HRGN(0);
    FLogicDescr.Clear;
    FLogicDescrERR.Clear;
    if NetRegion = HRGN(0) then begin
      NetRegion := CreateRectRgn(0, 0, HostBitmapRect.Right, HostBitmapRect.Bottom);
    end;

    //begin debug code ----------
    if SHOW_DEBUG_SET=2 then begin
      tempRect.Left := 0;
      tempRect.Top := 0;
      tempRect.Right := debugbitmap.Width;
      tempRect.Bottom := debugbitmap.Height;
      DrawFilledRect(debugBitmap, tempRect, clwhite);
      RenderASet(DebugBitmap, NetRegion, ZERO_POINT); //debugging only.  Remove later.
      VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, DebugBitmap); //debugging only.  Remove later.
    end;
    //end debug code

    NumUsed := Combine1(tcsIncludeRequired); //First combine all required sets (AND)
    Combine1(tcsIncludeOptional, (NumUsed=0)); //Next add optional sets (OR)
    Combine1(tcsExclude);         //Finally exclude exclusionary sets (NOT)
    //tcsObject --> figure out if anything should be done here....

  end;

  function TVennObj.LocationPath : string;
  begin
    Result := Self.Name;
    if assigned(Self.Parent) then begin
      Result := Result + ' <- ' + Parent.LocationPath;
    end;
  end;


  procedure TVennObj.SetSelected(Value : boolean);
  begin
    if FSelected = Value then exit;
    FSelected := Value;
    ShowBorder := true;;
    ShowBoundingRect := FSelected;
    if FSelected then begin
      FUnselectedColor := BorderColor;
      BorderThickness := 5;
      BorderColor := SelectedBorderColor;
    end else begin
      BorderThickness := 3;
      BorderColor := FUnselectedColor;
    end;
  end;


  procedure TVennObj.RenderShadow(Bitmap : TBitmap; MousePos : TPoint);
  //This only works with circlular Vin objects.
  var Rect : TRectf;
      SavMode : integer;
      ShadowPos : TPointf;
  begin
    exit; //cut out shadow for now.
    if not ShowShadow then exit;
    Rect := Self.FRect;

    ShadowPos := Pos + ShadowOffsetV;
    Bitmap.Canvas.Brush.Style := bsDiagCross;
    DrawBall(Bitmap, ShadowPos, ShadowColor, Round(XRadius), false);

    Self.Visible := true;
    Rect := Rect + ShadowOffsetV;

    SavMode := Bitmap.Canvas.CopyMode;
    Bitmap.Canvas.CopyMode := cmSrcPaint;
    Bitmap.Canvas.StretchDraw(Rect.IntRect,ShadowBM);
    Bitmap.Canvas.CopyMode := SavMode;
  end;

  procedure TVennObj.CheckAndRenderChildNum(Bitmap : TBitmap; MousePos : TPoint);
  begin
    if (FChildren.Count > 0) and not Self.ShowBoundingRect then begin
      RenderChildNum(Bitmap,FChildren.Count, MousePos);
    end;
  end;


  procedure TVennObj.RenderChildNum(Bitmap : TBitmap; Num : integer; MousePos : TPoint);
  var S : string;
      Size : TSize;
      cx, cy : single;
      x, y : single;
      Rect, TempRect : TRectf;
  begin
    //SetupInfoOrZoomRect;
    if not HandleInfo[hselInfoOrZoom].Enabled then exit;
    s := ' '+IntToStr(Num)+' ';
    Bitmap.Canvas.Font.Size := 10;  //Size of child number text.
    Size := Bitmap.Canvas.TextExtent(s);

    TempRect := HandleInfo[hselInfoOrZoom].Rect;
    cx := ((TempRect.Right - TempRect.Left) / 2 ) + TempRect.Left;
    cy := ((TempRect.Bottom - TempRect.Top) / 2 ) + TempRect.Top;
    x := cx - Size.cx / 2;
    y := cy - Size.cy / 2;
    Bitmap.Canvas.Pen.Color := clWhite;
    Bitmap.Canvas.Pen.Width := 1;
    Rect.Top    := cy - Size.cy/1;
    Rect.Left   := cx - Size.cx/1;
    Rect.Right  := cx + Size.cx/1;
    Rect.Bottom := cy + Size.cy/1;

    Bitmap.Canvas.Brush.Color := ColorForMouse(clRed, MousePos, Rect); //clRed;
    Bitmap.Canvas.Font.Color := clWhite;

    Bitmap.Canvas.Brush.Style := bsSolid;
    Bitmap.Canvas.Ellipse(Rect.IntRect);
    Bitmap.Canvas.TextOut(round(x), Round(y-2), s);
    HandleInfo[hselInfoOrZoom].Visible := true;
  end;



  procedure TVennObj.RenderEjectIcon(Bitmap : TBitmap; MousePos : TPoint);
  var SavMode : integer;
      TempRect : TRectf;
      IconBM : TBitmap;
  begin
    if not HandleInfo[hselEject].Enabled then exit;
    SavMode := Bitmap.Canvas.CopyMode;
    Bitmap.Canvas.CopyMode := cmSrcPaint;
    TempRect := HandleInfo[hselEject].Rect;

    IconBM := EjectBMs.Select(TempRect.ContainsPoint(MousePos));
    Bitmap.Canvas.StretchDraw(TempRect.IntRect, IconBM);
    Bitmap.Canvas.CopyMode := SavMode;
    HandleInfo[hselEject].Visible := true;
  end;


  procedure TVennObj.RenderZoomIcon(Bitmap : TBitmap; MousePos : TPoint);
  var SavMode : integer;
      TempRect : TRectf;
      IconBM : TBitmap;

  begin
    if not HandleInfo[hselInfoOrZoom].Enabled then exit;
    SavMode := Bitmap.Canvas.CopyMode;
    Bitmap.Canvas.CopyMode := cmSrcPaint;
    TempRect := HandleInfo[hselInfoOrZoom].Rect;

    IconBM := ZoomBMs.Select(TempRect.ContainsPoint(MousePos));
    Bitmap.Canvas.StretchDraw(TempRect.IntRect, IconBM);
    Bitmap.Canvas.CopyMode := SavMode;
    HandleInfo[hselInfoOrZoom].Visible := true;
  end;

  procedure TVennObj.RenderDeleteIcon(Bitmap : TBitmap; MousePos : TPoint);
  var SavMode : integer;
      TempRect : TRectf;
      IconBM : TBitmap;

  begin
    if not HandleInfo[hselDelete].Enabled then exit;
    SavMode := Bitmap.Canvas.CopyMode;
    Bitmap.Canvas.CopyMode := cmSrcPaint;
    TempRect := HandleInfo[hselDelete].Rect;

    IconBM := TrashBMs.Select(TempRect.ContainsPoint(MousePos));
    Bitmap.Canvas.StretchDraw(TempRect.IntRect, IconBM);
    Bitmap.Canvas.CopyMode := SavMode;
    HandleInfo[hselDelete].Visible := true;
  end;


  procedure TVennObj.Render(Bitmap : TBitmap; MousePos : TPoint; var OrderNum : integer);
  begin
    //HostBitmap := Bitmap;  done in inherited code
    //------------------------------
    inherited Render(Bitmap, MousePos, OrderNum);
    //------------------------------
    if Self.CombinationMode = tcsExclude then begin
      SelectClipRgn(Bitmap.Canvas.Handle, WinRegion);
      Bitmap.Canvas.Brush.Style := bsDiagCross;
      Bitmap.Canvas.Brush.Color := clRed;
      Bitmap.Canvas.Rectangle(FRect.IntRect);
      SelectClipRgn(Bitmap.Canvas.Handle, 0);
    end;
    CheckAndRenderChildNum(Bitmap, MousePos);
    {
    if (FChildren.Count > 0) and not Self.ShowBoundingRect then begin
      RenderChildNum(Bitmap,FChildren.Count, MousePos);
    end;
    }
  end;

  procedure TVennObj.RenderChildren(Bitmap : TBitmap; MousePos : TPoint; var OrderNum : integer);
  const
    NULL_PT  : TPoint = (x: -1; y:-1);

  var i : integer;
      MouseOverObj,
      HoverOverObj, Obj : TVennObj;
      RgnMgr : TRgnManager;
      BorderColor : TColor;
      BorderThickness : integer;
      DrawColor : TColor;

    function MousePosForObj(Obj : TVennObj) : TPoint;
    begin
      if Obj = MouseOverObj then begin
        Result := MousePos;
      end else begin
        Result := NULL_PT;
      end;
    end;

  begin
    if not assigned(RgnManager) then exit;
    RgnMgr := TRgnManager(RgnManager);
    if RgnMgr.VennObjectShouldShowChildren(Self) = false then begin
      exit;
    end;

    //-------------------------------------------------------------
    //Discussion of visiblity:
    // 1. If we are zoomed in to a grandchild, then we don't want to
    //    show the grandparent.  Thus the grandparent shouldn't be "visible."
    //    But that means that we should attempt to render an object, even
    //    if it is not visible, because a child or grandchild might be
    //    visible.  It is like we need to have two different signals,
    //    one for those that should be processed, and another for those
    //    that are visible...
    //    I will make two signals to be:
    //       Visible  & SkipProcessing
    //-------------------------------------------------------------

    //-------------------------------------------------------------
    //Discussion of Mouse over highlighting:
    //My initial plan was for each object to determine if the mouse was
    //  over it, and highlight itself accordingly.  This works in simple
    //  scenes.  However, with multiple overlapping objects, it leads
    //  to inaccuracy and confusion.
    //To try to remedy this, I will have each object determine which of
    //  it's children should be considered to be under the mouse.  That
    //  child will get the true mouse position.  All others will get
    //  a NULL_PT mouse position.
    //-------------------------------------------------------------

    MouseOverObj := ItemAtPoint(MousePos);
    BorderColor := clBlack;

    //Set default for all children, and grandchildren etc to be invisible.
    for i := 0 to Children.Count - 1 do begin
      Obj := Children[i];  if not Assigned(Obj) then continue;
      Obj.Visible := false; //triggers setter --> hides grandchildren also
      Obj.SkipRender := true;
    end;
    //Restore visiblity for immediate children.
    for i := 0 to Children.Count - 1 do begin
      Obj := Children[i];  if not Assigned(Obj) then continue;
      if Obj.HasZoomSibling then continue;
      Obj.SkipRender := false;
      if Obj.ZoomingChild then continue;
      if RgnMgr.InUpperZoomStack(Obj) then continue;
      Obj.Visible := True;
    end;

    //Render all shadows
    for i := 0 to Children.Count - 1 do begin
      Obj := Children[i];  if not Assigned(Obj) then continue;
      if Obj.SkipRender then continue;
      Obj.RenderShadow(Bitmap, MousePosForObj(Obj));
      if SHOW_DEBUG_SET>0 then VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, Bitmap); //debugging only.  Remove later.
    end;

    //Render all inclusion objects
    for i := 0 to Children.Count - 1 do begin
      Obj := Children[i];  if not Assigned(Obj) then continue;
      if Obj.SkipRender then continue;
      if Obj.CombinationMode = tcsExclude then continue;
      Obj.RenderAndChild(Bitmap, MousePosForObj(Obj), OrderNum);
      if SHOW_DEBUG_SET>0 then VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, Bitmap); //debugging only.  Remove later.
    end;

    //Draw exclusionary objects last
    for i := 0 to Children.Count - 1 do begin
      Obj := Children[i];  if not Assigned(Obj) then continue;
      if Obj.SkipRender then continue;
      if Obj.CombinationMode <> tcsExclude then continue;
      Obj.RenderAndChild(Bitmap, MousePosForObj(Obj), OrderNum);
      if SHOW_DEBUG_SET>0 then VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, Bitmap); //debugging only.  Remove later.
    end;

    //tcsObject --> figure what needs to be done in this case....

    HoverOverObj := nil;
    for i := 0 to Children.Count - 1 do begin
      Obj := Children[i];  if not Assigned(Obj) then continue;
      if Obj.SkipRender then continue;
      if not Obj.HotColorMode then continue;
      HoverOverObj := Obj;
      break;
    end;
    if assigned(HoverOverObj) then begin
      //Obj.RenderAndChild(Bitmap, MousePosForObj(Obj), OrderNum);
      HoverOverObj.RenderAndChild(Bitmap, MousePosForObj(HoverOverObj), OrderNum);
      if SHOW_DEBUG_SET>0 then VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, Bitmap); //debugging only.  Remove later.
    end;

    //FIX: Obj in block below may not be initialized....
    if not Self.ZoomingChild then begin
      //kt, attempt at fix: original -->  RenderActiveSet(Bitmap, MousePosForObj(Obj));
      RenderActiveSet(Bitmap, MousePosForObj(self));
      if SHOW_DEBUG_SET>0 then VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, Bitmap); //debugging only.  Remove later.
    end;

    //Next, redraw outlines, so have overlapping lines
    //Skip selected object here. That will be handled further below.
    Bitmap.Canvas.Pen.Style := psSolid;
    for i := 0 to Children.Count - 1 do begin
      Obj := Children[i]; if not Assigned(Obj) then continue;
      if Obj.SkipRender then continue;
      if Obj.Selected then continue;
      if Obj.ZoomMode <> zmNormal then continue;

      DrawColor := BorderColor;
      BorderThickness := 4;
      if assigned(HoverOverObj) and (Obj <> HoverOverObj) then BorderThickness := 1;
      //if Obj.Selected then begin
      //  DrawColor := SelectedBorderColor; // SELECTED_DRAW_COLOR;
      //  BorderThickness := 3;
      //end;
      Obj.RenderOutlineTraceAndChildrens(Bitmap, DrawColor, BorderThickness, MousePosForObj(Obj));
      if SHOW_DEBUG_SET>0 then VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, Bitmap); //debugging only.  Remove later.
    end;

    //Next, if any object is being dragged, then draw with special border
    for i := 0 to Children.Count - 1 do begin
      Obj := Children[i]; if not Assigned(Obj) then continue;
      if Obj.SkipRender then continue;
      Case Obj.DragMode of
        tdmNone             : continue;
        tdmOverContainer    : BorderColor := clRed;
        tdmNotIntoContainer : BorderColor := clGreen;
      end;
      Obj.RenderOutlineTraceAndChildrens(Bitmap, BorderColor, 5, MousePosForObj(Obj));
      if SHOW_DEBUG_SET>0 then VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, Bitmap); //debugging only.  Remove later.
    end;

    //re-render ChildNum, so it is not overlapped
    for i := 0 to Children.Count - 1 do begin
      Obj := Children[i]; if not Assigned(Obj) then continue;
      if Obj.SkipRender then continue;
      Obj.CheckAndRenderChildNum(Bitmap, MousePosForObj(Obj));
      if SHOW_DEBUG_SET>0 then VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, Bitmap); //debugging only.  Remove later.
    end;

    //Render Bounding rects.
    for i := 0 to Children.Count - 1 do begin
      Obj := Children[i]; if not Assigned(Obj) then continue;
      if Obj.SkipRender then continue;
      Obj.RenderBoundingOrChildIfSel(Bitmap, MousePosForObj(Obj));
      if SHOW_DEBUG_SET>0 then VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, Bitmap); //debugging only.  Remove later.
    end;

    //Render label Lines
    for i := 0 to Children.Count - 1 do begin
      Obj := Children[i]; if not Assigned(Obj) then continue;
      if Obj.SkipRender then continue;
      //kt if Obj.ZoomMode = zmDisappear then continue;  //elh
      if Obj.ZoomMode <> zmNormal then continue;  //kt
      Obj.RenderLabelLine(Bitmap, MousePosForObj(Obj));
      if SHOW_DEBUG_SET>0 then VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, Bitmap); //debugging only.  Remove later.
    end;

    //Render labels
    for i := 0 to Children.Count - 1 do begin
      Obj := Children[i]; if not Assigned(Obj) then continue;
      if Obj.SkipRender then continue;
      Obj.RenderLabelAndChild(Bitmap, MousePosForObj(Obj));
      if SHOW_DEBUG_SET>0 then VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, Bitmap); //debugging only.  Remove later.
    end;

    //Render label pins
    for i := 0 to Children.Count - 1 do begin
      Obj := Children[i]; if not Assigned(Obj) then continue;
      if Obj.SkipRender then continue;
      if Obj.ZoomMode <> zmNormal then continue;  //kt
      Obj.RenderPinAndChild(Bitmap, MousePosForObj(Obj));
      if SHOW_DEBUG_SET>0 then VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, Bitmap); //debugging only.  Remove later.
    end;

    //Next, redraw Selected object outline so that it is on top of other's labels.
    Bitmap.Canvas.Pen.Style := psSolid;
    for i := 0 to Children.Count - 1 do begin
      Obj := Children[i]; if not Assigned(Obj) then continue;
      if Obj.SkipRender then continue;
      if not Obj.Selected then continue;
      DrawColor := SelectedBorderColor; //SELECTED_DRAW_COLOR
      BorderThickness := 3;
      Obj.RenderOutlineTraceAndChildrens(Bitmap, DrawColor, BorderThickness, MousePosForObj(Obj));
      Obj.RenderLabelLine(Bitmap, MousePosForObj(Obj));
      Obj.RenderLabelAndChild(Bitmap, MousePosForObj(Obj));
      if SHOW_DEBUG_SET>0 then VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, Bitmap); //debugging only.  Remove later.
    end;

    RenderFloatingText(Bitmap);

    //Render Hints
    for i := 0 to Children.Count - 1 do begin
      Obj := Children[i]; if not Assigned(Obj) then continue;
      if (Obj.SkipRender) or (Obj.HideHint) then continue;
      Obj.CheckAndRenderHints(Bitmap, MousePosForObj(Obj));
      if SHOW_DEBUG_SET>0 then VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, Bitmap); //debugging only.  Remove later.
    end;
    //------------------------------
  end;

  function TVennObj.GetObjColorForMouse(MousePos : TPoint) : TColor;
  //overrides ElipseObject.GetObjColorForMouse
  var
      RgnMgr : TRgnManager;
      HandleSel : TSelHandle;
      TestObj, Obj : TVennObj;
      ObjList : TVennObjList;
      BodyEncountered : boolean;
      i, j : integer;
  begin
    Result := Color;

    if IsAndOrNot(Self.CombinationMode) and (not TouchingSiblings) then begin
      Result := clLtGray;
    end;
    HotColorMode := false;
    if not FRect.ContainsPoint(MousePos) then exit;
    if not assigned(RgnManager) then exit;
    RgnMgr := TRgnManager(RgnManager);
    ObjList := TVennObjList.Create;

    RgnMgr.ItemAtPoint(MousePos, RgnMgr.SelVennObject, ObjList);
    Obj := nil;

    //Ensure only one entry with hselBody (the last one rendered)
    BodyEncountered := false;
    for i := 0 to ObjList.Count - 1 do begin
      TestObj := ObjList.Item[i];
      if TestObj = nil then continue;

      HandleSel := TestObj.WhichHandleSelected(MousePos);
      if HandleSel <> hselBody then continue;
      if TestObj = RgnMgr.SelVennObject then begin  //Selected object trumps other objects
        BodyEncountered := true;
        for j := 0 to ObjList.Count - 1 do begin
          if j = i then continue;
          TestObj := ObjList.Item[j];
          HandleSel := TestObj.WhichHandleSelected(MousePos);
          if HandleSel <> hselBody then continue;
          ObjList.Item[j] := nil;
        end;
      end;
      if not BodyEncountered then begin
        BodyEncountered := true;
        continue;
      end else begin
        ObjList.Item[i] := nil;
      end;
    end;

    for i := 0 to ObjList.Count - 1 do begin
      TestObj := ObjList.Item[i];
      if TestObj = nil then continue;
      HandleSel := TestObj.WhichHandleSelected(MousePos);
      if HandleSel = hselBody then begin
        Obj := TestObj;
        break;
      end;
    end;
    if Obj = Self then begin
      Result := LighterColor(Result);  //Color
      HotColorMode := true;
    end;
    ObjList.Free;
  end;

  procedure TVennObj.RenderAndChild(Bitmap : TBitmap; MousePos : TPoint; var OrderNum : integer);
  begin
    if Self.Visible then begin
      Render(Bitmap, MousePos, OrderNum);
    end;
    //If a grandparent is zoomed, then it may will not be visible, but
    //it's child or grandchild may be, so still try to process them.
    RenderChildren(Bitmap, MousePos, OrderNum);
  end;


  procedure TVennObj.RenderBoundingRect(Bitmap : TBitmap; MousePos : TPoint);
  begin
    inherited RenderBoundingRect(Bitmap, MousePos);
    if (FChildren.Count > 0) or AlwaysEnableZoomIcon then begin
      RenderZoomIcon(Bitmap, MousePos);
    end;
    if HasParent then RenderEjectIcon(Bitmap, MousePos);
    RenderDeleteIcon(Bitmap, MousePos);
  end;


  procedure TVennObj.RenderBoundingOrChildIfSel(Bitmap : TBitmap; MousePos : TPoint);
  var i : integer;
  begin
    if Self.Selected then begin
      Self.RenderBoundingRect(Bitmap, MousePos);
    end else begin
      for i := 0 to FChildren.Count - 1 do begin
        FChildren[i].RenderBoundingOrChildIfSel(Bitmap, MousePos);
      end;
    end;
  end;

  procedure TVennObj.RenderLabelAndChild(Bitmap : TBitmap; MousePos : TPoint);
  var i : integer;
      Obj : TVennObj;
  begin
    RenderLabel(Bitmap, MousePos);
    //Now render label of children, if they are visible.
    for i := 0 to FChildren.Count - 1 do begin
      Obj := FChildren[i];
      if not Obj.Visible then continue;
      Obj.RenderLabel(Bitmap, MousePos);
    end;
  end;

  procedure TVennObj.RenderPinAndChild(Bitmap : TBitmap; MousePos : TPoint);
  var i : integer;
      Obj : TVennObj;
  begin
    RenderPin(Bitmap, MousePos);
    //Now render Pin of children, if they are visible.
    for i := 0 to FChildren.Count - 1 do begin
      Obj := FChildren[i];
      if not Obj.Visible then continue;
      Obj.RenderPin(Bitmap, MousePos);
    end;
  end;

  procedure TVennObj.RenderOutlineTraceAndChildrens(Bitmap : TBitmap;
                                                   Color : TColor;
                                                   Thickness : byte;
                                                   MousePos : TPoint);
  var
    i : integer;
    VennObject : TVennObj;
  begin
    if Self.Visible then RenderOutlineTrace(Bitmap, Color, Thickness, MousePos);
    for i := 0 to FChildren.Count - 1 do begin
      VennObject := FChildren[i];
      if VennObject.HasZoomSibling then continue;
      if not VennObject.visible then continue;
      FChildren[i].RenderOutlineTraceAndChildrens(Bitmap,Color,Thickness, MousePos);
    end;
  end;

  procedure TVennObj.SetComboMode (Value : TCombinationStyle);
  begin
    FComboMode := Value;
    //Later.... change border style etc.
  end;

  procedure TVennObj.SetPosPctOfParent;
  var SelfRelPos : TPointf;
  begin
    if not assigned(FParent) then exit;
    SelfRelPos := Self.Pos - FParent.Pos;
    if FParent.XRadius > 0 then begin
      FXPctOfParent := SelfRelPos.x / FParent.XRadius;
    end else FXPctOfParent := 0.25;  //arbitrary pct
    if FParent.YRadius > 0 then begin
      FYPctOfParent := SelfRelPos.y / FParent.YRadius;
    end else FYPctOfParent := 0.25;  //arbitrary pct
  end;

  (*
  function TVennObj.HostBitmapHeight : integer;
  begin
    Result := HostBitmapRect.Bottom - HostBitmapRect.Top;
  { if assigned(HostBitmap) then begin
      Result := HostBitmap.Height;
    end else Result := 0; }
  end;

  function TVennObj.HostBitmapWidth : integer;
  begin
    Result := HostBitmapRect.Right - HostBitmapRect.Left;
    {if assigned(HostBitmap) then begin
      Result := HostBitmap.Width;
    end else Result := 0; }
  end;

  function TVennObj.HostBitmapCenter : TPointf;
  begin
    Result.x := HostBitmapWidth / 2;
    Result.y := HostBitmapHeight / 2;
  end;      *)

  function TVennObj.RadiusToBoundingBox : integer;
  begin
    Result := Round(Self.XRadius) + RESIZE_SQR_SIZE;
  end;
  {
  function TVennObj.ClippedLabelPos : TPointf;
  var Pt, Delta : TPointf;
      UnClippedRect : TRectf;
  begin
    Result := LabelPos;
    //First clip label position
    if (HostBitmapWidth > 0) and (HostBitmapHeight > 0) and
    (Self.ZoomMode = zmNormal) then begin
      UnClippedRect := GetLabelRect(HostBitmap, LabelPos);
      Pt := UnClippedRect.TopLeft;
      Delta := LabelPos - Pt;
      if Pt.x < (-DISPLAY_OFFSET.X) then begin
        Pt.x := (-DISPLAY_OFFSET.X);
      end;
      if Pt.Y < (-DISPLAY_OFFSET.Y) then begin
        Pt.Y := (-DISPLAY_OFFSET.Y);
      end;

      if (Pt.x + LabelRect.Width)> HostBitmapWidth then begin
        Pt.x := HostBitmapWidth - LabelRect.Width;
      end;

      if (Pt.y + LabelRect.Height) > HostBitmapHeight then begin
        Pt.Y := HostBitmapHeight - LabelRect.Height;
      end;
      Result := Pt + Delta;
    end;
  end; }


  procedure TVennObj.SetPosDynamic(Value : TPointf);
  var i : integer;
  begin
    //Keep Object from being positioned off the screen unless zoomed.
    if (HostBitmapWidth > 0) and ( HostBitmapHeight > 0) and
    (Self.ZoomMode = zmNormal) then begin
      if (Value.x + Self.RadiusToBoundingBox) > HostBitmapWidth then begin
        Value.x := HostBitmapWidth - Self.RadiusToBoundingBox;
      end;
      if (Value.x - Self.RadiusToBoundingBox) < (-DISPLAY_OFFSET.X) then begin
        Value.x := Self.RadiusToBoundingBox + (-DISPLAY_OFFSET.X);
      end;
      if (Value.y + Self.RadiusToBoundingBox) > HostBitmapHeight then begin
        Value.Y := HostBitmapHeight - Self.RadiusToBoundingBox;
      end;
      if (Value.Y - Self.RadiusToBoundingBox) < (-DISPLAY_OFFSET.Y) then begin
        Value.Y := Self.RadiusToBoundingBox + (-DISPLAY_OFFSET.Y);
      end;
    end;
    Inherited SetPosDynamic(Value);
    SetPosPctOfParent;
    //Move any children also.
    for i := 0 to FChildren.Count - 1 do begin
      FChildren[i].ResizeFromParent;
    end;
  end;


  procedure TVennObj.SetParent(Value : TVennObj);
  begin
    if Value = FParent then exit;
    if assigned(FParent) then FParent.Children.Delete(Self);
    FParent := Value;
    if assigned(FParent) then FParent.Children.Add(Self);
    SetPosPctOfParent;
    //SetRadiusPctOfParent;
  end;

  function TVennObj.HasParent: boolean;
  begin
    Result := (Self.Parent <> nil) and
              (Self.Parent <> Self.RgnManager);
  end;


  function TVennObj.ContainsPointOrChild(Pt : TPoint) : TVennObj;
  //Returns object that actually contains the point.
  var i : integer;
  begin
    Result := nil;
    //The resizing box for a child may be outside parent
    for i := 0 to FChildren.Count - 1 do begin
      Result := FChildren[i].ContainsPointOrChild(Pt);
      if Assigned(Result) then exit;
    end;
    //Lastly, check self
    if ContainsPointInRect(Pt) then Result := Self;
  end;


  function TVennObj.ObjInRegion(VennObject : TVennObj) : TVennObj;
  //Returns if shape of VennObject will lie completely inside the region
  // for this object.  And if so, does it also lie in a child object?
  //Returns object that VennObject lies with on the screen (based on
  //        coordinates and shape etc, not ownership.
  var Relationship : TRgnIntersection;
      i : integer;
  begin
    Result := nil;
    Relationship := CompareRgnsA(Self.WinRegion, VennObject.WinRegion);
    if Relationship <> rgniAcontainsB then exit;
    for i := 0 to FChildren.Count - 1 do begin
      Result := FChildren[i].ObjInRegion(VennObject);
      if assigned(Result) then break;
    end;
    if not assigned(Result) then Result := self;
  end;


  procedure TVennObj.SetHandlePtDynamic(SelHandle : TSelHandle; Value : TPointf);
  var i : integer;
      Obj : TVennObj;
  begin
    Inherited SetHandlePtDynamic(SelHandle, Value);
    for i := 0 to FChildren.Count -1 do begin
      Obj := FChildren[i];
      Obj.ResizeFromParent;
    end;
  end;


  function TVennObj.WhichHandleSelected(Pt : TPoint) : TSelHandle;
  begin
    Result := inherited WhichHandleSelected(Pt);
  end;

  function TVennObj.ContainsPointInRect(Pt : TPoint) : boolean;
  begin
    Result := inherited ContainsPointInRect(Pt);
    if Result = true then exit;
    if (FChildren.Count > 0)
    and HandleInfo[hselInfoOrZoom].Enabled
    and HandleInfo[hselInfoOrZoom].Rect.ContainsPoint(Pt) then begin
      Result := TRUE;
    end;
  end;


  function TVennObj.ContainsPointInBody(Pt : TPoint) : boolean;
  //The test will be easier for circles than ellipse (parent)
  var V : TPointf;
  begin
    V := Pt - Self.Pos;
    Result := (V.Length < XRadius);
  end;


  procedure TVennObj.SetVisibleDynamic(Value : Boolean);
  var i : integer;
      Obj : TVennObj;
  begin
    Inherited SetVisibleDynamic(Value);
    //If invisible, then all children invisible.
    //But if setting to visible, then children might not be visibile
    if FVisible = false then begin
      for i := 0 to FChildren.Count - 1 do begin
        Obj := FChildren.Item[i];
        Obj.Visible := false;
        Obj.ZOrderNum := 0;
        Obj.HideAllHints;
      end;
    end;
  end;


  procedure TVennObj.SetRadiusPctOfParent;
  begin
    if not assigned(FParent) then exit;
    if FParent.XRadius <> 0 then begin
      FRadiusPctOfParent := Self.XRadius / FParent.XRadius;
    end else FRadiusPctOfParent := 0.25; //arbitrary pct
  end;


  procedure TVennObj.SetXRadiusDynamic(Value : single);
  begin
    inherited SetXRadiusDynamic(Value);
    SetRadiusPctOfParent;
  end;


  procedure TVennObj.SetYRadiusDynamic(Value : single);
  begin
    inherited SetYRadiusDynamic(Value);
    SetRadiusPctOfParent;
  end;


  procedure TVennObj.ResizeFromParent;
  var SelfRelPos : TPointf;
  begin
    if not assigned(FParent) then exit;
    if FRadiusPctOfParent = 0 then SetRadiusPctOfParent;    //elh

    Self.XRadius := Round(FRadiusPctOfParent * FParent.XRadius);
    Self.YRadius := Round(FRadiusPctOfParent * FParent.YRadius);

    SelfRelPos.x := FXPctOfParent * FParent.XRadius;
    SelfRelPos.y := FYPctOfParent * FParent.YRadius;

    Self.Pos := SelfRelPos + FParent.Pos;
  end;


  procedure TVennObj.SetZoomMode(Value : TZoomMode);
  var OldMode : TZoomMode;
  begin
    if Value = FZoomMode then exit;
    OldMode := FZoomMode;
    FZoomMode := Value;
    if FZoomMode = zmNormal then begin
      //Back to normal, so restore saved values
      Self.XRadius := UnZoomedRadius;
      Self.Pos := UnZoomedPos;
    end else if OldMode = zmNormal then begin
      //Leaving normal state, so save values
      UnZoomedRadius := Self.XRadius;
      UnZoomedPos := Self.Pos;
    end;
  end;


  procedure TVennObj.SetZoomPct(Value : Single);
  var OldZoom : single;
      NewXRadius : single;
      TargetRadiusLen, RadiusDiff : single;
  begin
    if Value > 100 then Value := 100;
    //if Value < 0 then Value := 0;
    OldZoom := FZoomPct;
    FZoomPct := Value;
    TargetRadiusLen := HostBitmapCenter.x * ZOOM_ENLARGEMENT_FACTOR;
    RadiusDiff := TargetRadiusLen - UnZoomedRadius;
    NewXRadius := UnZoomedRadius + (RadiusDiff * FZoomPct/100);

    //if Value = 0 then begin
    if Value <= 0 then begin
      if ZoomMode = zmZoomingOut then begin
        ZoomMode := zmNormal;
        if assigned(OnFinishedZoomOut) then begin
          OnFinishedZoomOut(Self);
        end;
        exit;
      end else if ZoomMode = zmDisappear then begin
        if (Self.XRadius < 5) or (NewXRadius<4) then begin
          ZoomMode := zmNormal;
          exit;
        end;
      end;

    end else if Value = 100 then begin
      ZoomMode := zmAtMax;
    end else if Value > OldZoom then begin
      ZoomMode := zmZoomingIn;
    end else if Value < OldZoom  then begin
      ZoomMode := zmZoomingOut;
    end;

    Self.XRadius := NewXRadius; //UnZoomedRadius + (RadiusDiff * FZoomPct/100);
  end;

  procedure TVennObj.AnimateZoom(IntervalTimeMs : extended; ZoomIn : boolean);
  const MS_FOR_FULL_ZOOM = 500;
        MS_FOR_DISAPPEAR = 1000;
        TIME_FOR_ZOOM: array[FALSE..TRUE] of integer=(MS_FOR_FULL_ZOOM,MS_FOR_DISAPPEAR);
  var DeltaPct : single;
      PosTravelV : TPointf;
      TravelScale : single;
      TimeForZoom : integer;
  begin
    TimeForZoom := TIME_FOR_ZOOM[self.ZoomMode = zmDisappear];
    DeltaPct := IntervalTimeMs / TimeForZoom;  // calculates 0-1, not 0-100
    if not ZoomIn then DeltaPct := -DeltaPct;
    ZoomPct := ZoomPct + (DeltaPct * 100);

    PosTravelV :=  HostBitmapCenter - UnZoomedPos;
    TravelScale := ZoomPct /100;
    if TravelScale > 1.0 then TravelScale := 1;
    PosTravelV.ScaleBy(TravelScale);
    Self.Pos := UnZoomedPos + PosTravelV;
  end;

  procedure TVennObj.AnimateAndChild(IntervalTimeMs : Extended);
  begin
    Animate(IntervalTimeMS);
    AnimateChildren(IntervalTimeMS);
  end;

  procedure TVennObj.AnimateChildren(IntervalTimeMs : Extended);
  var i : integer;
      Obj : TVennObj;
  begin
    //Check for label collisions in children.
    for i := 0 to FChildren.Count - 1 do begin
      Obj := FChildren[i];
      CheckLabelCollision(Obj, FChildren, IntervalTimeMs);
    end;

    case Self.ZoomMode of
      zmZoomingIn:  AnimateZoom(IntervalTimeMS, true);
      zmZoomingOut: AnimateZoom(IntervalTimeMS, false);
      zmDisappear:  AnimateZoom(IntervalTimeMS, false);
      zmAtMax:      AnimateZoom(IntervalTimeMS, true);  //elh  Even if at max, check to see if form size has changed since last set to max
    end;
    for i := 0 to FChildren.Count - 1 do begin
      Obj := FChildren[i];
      //Obj.Animate(IntervalTimeMS);
      Obj.AnimateAndChild(IntervalTimeMS);
    end;
    for i := 0 to FChildren.Count - 1 do begin
      Obj := FChildren[i];
      if (assigned(Obj.PotentialParent)) and
      (Obj.PotentialParent <> Obj.Parent) and
      (Obj.ZoomMode <> zmDisappear) then begin
        SetParentObj(Obj,Obj.PotentialParent);
        PotentialParent := nil;
        break;
      end;
    end;
  end;

  procedure TVennObj.RenderLabel(Bitmap : TBitmap; MousePos : TPoint);
  //Separate from main Render, so that this can be done after all the
  //other spheres have been drawn, so that labels will be on top.
  var SavedLabelPos, Pt : TPointf;
      Size : TSize;
      RgnMgr : TRgnManager;
      TempRect : TRectf;
  begin
    RgnMgr := TRgnManager(RgnManager);
    if Assigned(RgnMgr) and
    RgnMgr.EditLabelModeEnabled and
    (RgnMgr.SelVennObject = Self) and
    (self.ZoomMode <> zmDisappear) then begin
      RenderLabelLine(Bitmap, MousePos);
      exit;
    end;

    SavedLabelPos := Self.LabelPos;
    if (ZoomMode <> zmNormal) then begin
      Size := Bitmap.Canvas.TextExtent(Self.Name);
      Pt := ZoomedLabelStart;
      Pt.y := Pt.y + Size.cy;
      Pt.x := Pt.x + Size.cx/2 + TEXT_SPACE;
      Self.LabelPos := Pt;
    end;

    inherited RenderLabel(Bitmap, MousePos);
    //VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, Bitmap); //debugging only.  Remove later.
    TempRect := LabelRect;
    Self.LabelPos := SavedLabelPos;
    //FLabelRect := TempRect;

    if Self.Selected then begin
      Bitmap.Canvas.Pen.Color := Self.SelectedBorderColor;  //  SELECTED_LABEL_BORDER_COLOR;
      Bitmap.Canvas.Pen.Width := 2;  //not used with FrameRect -- it just does 1 pixel
      Bitmap.Canvas.Brush.Style := bsClear;
      if SHOW_DEBUG_SET>0 then VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, Bitmap); //debugging only.  Remove later.
      Bitmap.Canvas.Rectangle(TempRect.IntRect);
      //Bitmap.Canvas.FrameRect(FLabelRect.IntRect);
      if SHOW_DEBUG_SET>0 then VennForm.Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, Bitmap); //debugging only.  Remove later.
    end;

  end;

  procedure TVennObj.CheckAndRenderHints(Bitmap : TBitmap; MousePos : TPoint);
  var
    RgnMgr : TRgnManager;
    TempRect : TRectf;
  begin
    RgnMgr := TRgnManager(RgnManager);
    if Assigned(RgnMgr) and
      RgnMgr.EditLabelModeEnabled then begin
      exit;
    end;
    if RgnContainsPt(Parent.NetRegion, MousePos) then begin
      TempRect.Top := MousePos.Y;
      TempRect.Left := MousePos.X;
      TempRect.Width := 1; TempRect.Height := 1;
      HandleInfo[hselNetRegion].Rect := TempRect;
      HandleInfo[hselNetRegion].Visible := true;
      //RenderHint(Bitmap, MousePos, 'This is the net region...');
      //exit;
    end else begin
      HandleInfo[hselNetRegion].Visible := false;
      HandleInfo[hselNetRegion].HintHoverStart := 0;
    end;
    inherited CheckAndRenderHints(Bitmap, MousePos);
  end;


  function TVennObj.ZoomingOrChild : boolean;
  begin
    Result := (Self.ZoomMode <> zmNormal);
    if Result = true then exit;
    Result := ZoomingChild;
  end;

  function TVennObj.ZoomingChild : boolean;
  var i : integer;
  begin
    Result := false;
    for i := 0 to FChildren.Count - 1 do begin
      Result := FChildren.Item[i].ZoomingOrChild;  //.ZoomingChild;
      if Result = true then break;
    end;
  end;

  function TVennObj.HasZoomSibling : boolean;
  var i : integer;
      Obj : TVennObj;
  begin
    Result := False;
    if not assigned(Parent) then exit;
    for i := 0 to Parent.Children.Count - 1 do begin
      Obj := FParent.Children[i];
      if Obj = Self then continue;
      if Obj.ZoomMode = zmDisappear then continue;    //elh
      if Obj.ZoomMode <> zmNormal then begin
        Result := True;
        break;
      end;
    end;
  end;

  function TVennObj.HasChild : boolean;
  begin
    Result := (FChildren.Count > 0);
  end;

  function TVennObj.HasSibling : boolean;
  begin
    Result := False;
    if not assigned(Parent) then exit;
    if Parent.Children.Count > 1 then result := true;
  end;

  //---------

  procedure TVennObj.RenderActiveSet(Bitmap : TBitmap; MousePos : TPoint);
  var SetIsNull : boolean;
      ParentObj : TVennObj;
      RgnMgr : TRgnManager;
  begin
    //DebugBitmap := Bitmap; //debug only. remove later
    if not assigned(RgnManager) then exit;
    RgnMgr := TRgnManager(RgnManager);
    //Setup a Windows region for entire screen (full set of everything, to be narrowed down later)
    If NetRegion <> HRGN(0) then FreeWinRegion(NetRegion);
    NetRegion := CreateRectRgn(0, 0, Bitmap.Width, Bitmap.Height);
    if  RgnMgr.ZoomStack.Count = 0 then begin
      GetNetRegion(NetRegion, Children, SetIsNull);
    end else begin
      ParentObj := nil;
      if RgnMgr.ZoomStack.Count > 0 then begin
        ParentObj := RgnMgr.ZoomStack.Item[RgnMgr.ZoomStack.count-1];
      end;
      if Assigned(ParentObj) then begin
        GetNetRegion(NetRegion, ParentObj.Children, SetIsNull);
      end else begin
        SetIsNull := true;
      end;
    end;
    if not SetIsNull then RenderASet(Bitmap, NetRegion, MousePos); //Draw Active Set
    //Leave NetRegion intact until next render, or Self.destructor called
    //FreeWinRegion(NetRegion);
  end;

  procedure TVennObj.RenderASet(Bitmap : TBitmap; Region : HRGN; MousePos : TPoint);
  var SetRect : TRect;
      RgnMgr : TRgnManager;
  begin
    GetRgnBox(Region, SetRect); //gets rect that contains set.
    //Draw Set
    SelectClipRgn(Bitmap.Canvas.Handle, Region);
    //Draw background
    //DrawFilledRect(Bitmap, SetRect,CurrentActiveSetColor, clBlack, 0);
    if not assigned(RgnManager) then exit;
    RgnMgr := TRgnManager(RgnManager);
    Bitmap.Canvas.Brush.Color := RgnMgr.CurrentActiveSetColor;
    Bitmap.Canvas.Brush.Style := bsSolid;
    Bitmap.Canvas.Rectangle(SetRect);

    //Draw pattern overlay
    //DrawFilledRect(Bitmap, SetRect,clBlack, clBlack, 0, bsVertical);
    Bitmap.Canvas.Brush.Color := clBlack;
    Bitmap.Canvas.Brush.Style := bsVertical;
    Bitmap.Canvas.Rectangle(SetRect);

    SelectClipRgn(Bitmap.Canvas.Handle, 0);
  end;

  procedure TVennObj.SetParentObj(Obj, ParentObj : TVennObj);
  begin
    if not assigned(Obj) then exit;
    Obj.Parent := ParentObj; //--> stiggers SetParent()
  End;

  function TVennObj.ContainerObj(Obj : TVennObj) : TVennObj;
  //Returns lowest (lowest great grandchild etc) object that completely
  //  contains VennObject;
  //If return result is nil, then VennObject is not inside any other object;
  var i : integer;
      AObj  : TVennObj;

  begin
    //KT note to Eddie.  I fixed this...
    Result := Nil;
    if not assigned(Obj) then exit;
    if not assigned(Obj.Parent) then exit;
    for i := 0 to Obj.Parent.Children.count -1 do begin
      AObj := Obj.Parent.Children[i];
      if (AObj = Obj) then continue;
      Result := AObj.ObjInRegion(Obj);
      if assigned(Result) then break;
    end;
    {
    for i := 0 to Children.count -1 do begin
      if (Children[i] = VennObject) then continue;
      Result := Children[i].ObjInRegion(VennObject);
      if assigned(Result) then break;
    end;
    }
    if Result = nil then begin
      //Result := Self.RgnManager;
      Result := Obj.Parent;
    end;
  end;

  function TVennObj.ItemAtPoint(Pt : TPoint; CurSelObj :TVennObj = nil; ListOfAll : TVennObjList=nil) : TVennObj;
  var RgnMgr : TRgnManager;

    function AddToList(Obj : TVennObj) : boolean; //returns true if added
    begin
      Result := false;
      if Assigned(Obj) and Assigned(ListOfAll) then begin
        Result := true;
        if (ListOfAll.IndexOf(Obj)<0) then begin
          ListOfAll.Add(Obj);
        end;
      end;
    end;

    function Check1HandelItemAtPoint(Obj : TVennObj; Handle: TSelHandle) : TVennObj;
    begin
      Result := nil;
      if not Assigned(Obj) then exit;
      if not Obj.Visible then exit;
      if Obj.HandleInfo[Handle].Enabled
      and Obj.HandleInfo[Handle].Rect.ContainsPoint(Pt) then begin
        Result := Obj;
      end;
    end;

    {function Check1PinItemAtPoint(Obj : TVennObj) : TVennObj;
    begin
      Result := Check1HandelItemAtPoint(Obj, hselPinhead);
    end;}

    {function Check1LabelItemAtPoint(Obj : TVennObj) : TVennObj;
    begin
      Result := Check1HandelItemAtPoint(Obj, hselLabel);
    end;}

    {function Check1InfoOrZoomItemAtPoint(Obj : TVennObj) : TVennObj;
    begin
      Result := Check1HandelItemAtPoint(Obj, hselInfoOrZoom);
    end;}

    procedure LoopCheckAddHandle(Parent : TVennObj; Handle: TSelHandle);
    var i : integer;
        Obj : TVennObj;
    begin
      for i := Parent.Children.Count - 1 downto 0 do begin
        Obj := Parent.Children[i];
        Result := Check1HandelItemAtPoint(Obj, Handle);
        if not Assigned(Result) then continue;
        if not AddToList(Result) then exit;
      end;
    end;

    function Check1ItemAtPoint(Obj : TVennObj) : TVennObj;
    begin
      Result := nil;
      if not Assigned(Obj) then exit;
      if not Obj.Visible then exit;
      if RgnMgr.ZoomStack.Count> 0 then begin
        //Result := Obj.ContainsPointOrChild(Pt);  //May be child or grandchild of Obj
        if Obj.ContainsPointInRect(Pt) then Result := Obj;
        if Result = RgnMgr.ZoomStack.Item[0] then begin
          Result := nil;  //Don't allow RgnManager to be selected.
        end;
        if Assigned(Result) and Result.HasZoomSibling then begin
          Result := nil;
        end;
      end else begin
        if Obj.ContainsPointInRect(Pt) then Result := Obj;
      end;
    end;

    function BestFromList(ListOfAll : TVennObjList): TVennObj;
    //Note: CurSelObj is available in scope from parent function
    var i : integer;
        HandleSel : TSelHandle;
        OneSize, MaxSize : single;
        LargestIndex : integer;

    begin
      Result := Nil;
      if ListOfAll.Count = 0 then exit;
      Result := ListOfAll.Item[0];
      if ListOfAll.Count = 1 then exit;
      for i := ListOfAll.Count - 1 downto 0 do begin
        HandleSel := ListOfAll.Item[i].WhichHandleSelected(Pt);
        if HandleIsResizer(HandleSel) then begin
          //If one of the tiny resizer boxes has been clicked on, then don't consider any others.
          Result := ListOfAll.Item[i];
          exit;
        end;
        if (HandleSel = hselNone) and (ListOfAll.Count > 1) then ListOfAll.Delete(i);
      end;
      for i := ListOfAll.Count - 1 downto 0 do begin
        HandleSel := ListOfAll.Item[i].WhichHandleSelected(Pt);
        if HandleIsActionBtn(HandleSel) then begin
          Result := ListOfAll.Item[i];
          exit;
        end;
      end;
      //next check if one is smaller.  Pick smaller one.
      while ListOfAll.Count > 1 do begin
        MaxSize := 0;
        LargestIndex := 0;
        for i := ListOfAll.Count - 1 downto 0 do begin
          OneSize := ListOfAll.Item[i].BoundingRect.DiagonalLen;
          if  OneSize > MaxSize then begin
            MaxSize := OneSize;
            LargestIndex := i;
          end;
        end;
        ListOfAll.Delete(LargestIndex);  //delete largest of set
      end;
      Result := ListOfAll.Item[0];
    end;

  var i : integer;
      Obj : TVennObj;
      VisibleParent : TVennObj;
      LocalListOfAll : boolean;

  begin
    Result := nil;
    if not assigned(ListOfAll) then begin
      ListOfAll := TVennObjList.Create;
      LocalListOfAll := true; //kt
    end else LocalListOfAll := false;
    if not assigned(RgnManager) then exit;
    RgnMgr := TRgnManager(RgnManager);

    if RgnMgr.ZoomStack.Count> 0 then begin
      VisibleParent := RgnMgr.ZoomStack.Item[RgnMgr.ZoomStack.Count-1];
    end else begin
      VisibleParent := RgnManager;
    end;

    if assigned(VisibleParent) and assigned(VisibleParent.Children) then begin
      //First check Pins.  They are on top of labels
      LoopCheckAddHandle(VisibleParent, hselPinhead);
      {for i := VisibleParent.Children.Count - 1 downto 0 do begin
        Obj := VisibleParent.Children[i];
        Result := Check1PinItemAtPoint(Obj);
        if not Assigned(Result) then continue;
        if not AddToList(Result) then exit;
      end;}

      //next check labels.  They should be on top of all objects.
      LoopCheckAddHandle(VisibleParent, hselLabel);
      {for i := VisibleParent.Children.Count - 1 downto 0 do begin
        Obj := VisibleParent.Children[i];
        Result := Check1LabelItemAtPoint(Obj);
        if not Assigned(Result) then continue;
        if not AddToList(Result) then exit;
      end;}

      //next Info/Zoom areas.  They should be on top of all objects.
      LoopCheckAddHandle(VisibleParent, hselInfoOrZoom);
      {for i := VisibleParent.Children.Count - 1 downto 0 do begin
        Obj := VisibleParent.Children[i];
        Result := Check1InfoOrZoomItemAtPoint(Obj);
        if not Assigned(Result) then continue;
        if not AddToList(Result) then exit;
      end;}

      //next Delete areas.  They should be on top of all objects.
      LoopCheckAddHandle(VisibleParent, hselDelete);
    end;

    if assigned(CurSelObj) then begin
      Result := Check1ItemAtPoint(CurSelObj);
      if Assigned(Result) then begin
        if not AddToList(Result) then exit;
      end;
    end else begin
      Result := Check1ItemAtPoint(Self);
      if Assigned(Result) then begin
        if not AddToList(Result) then exit;
      end;
    end;

    if Assigned(VisibleParent) then begin
      //Check objects rendered last (should be "foremost" on screen)
      for i := VisibleParent.Children.Count - 1 downto 0 do begin
        Obj := VisibleParent.Children[i];
        Result := Check1ItemAtPoint(Obj);
        if not Assigned(Result) then continue;
        if not AddToList(Result) then exit;
      end;
    end;
    if Assigned(ListOfAll) and (ListOfAll.Count > 0) then begin
      Result := BestFromList(ListOfAll);
    end;
    if LocalListOfAll then FreeAndNil(ListOfAll);
  end;

  function TVennObj.GetGrandparent : TVennObj;
  begin
    Result := Self.Parent;
    if assigned(Result) then begin
      Result := Result.Parent;
    end;
  end;


  procedure TVennObj.SetupInfoOrZoomRect;
  var Size : single;
      TempRect : TRectf;
  begin
    Size := (FRect.Right - FRect.Left) / 6;
    TempRect.Top := FRect.Top;
    TempRect.Left := FRect.Right - Size;
    TempRect.Right := TempRect.Left + Size;
    TempRect.Bottom := TempRect.Top + Size;
    HandleInfo[hselInfoOrZoom].Rect := TempRect;
    HandleInfo[hselInfoOrZoom].Visible := (FChildren.Count > 0)
  end;

  procedure TVennObj.SetupEjectRect;
  var Size : single;
      TempRect : TRectf;
  begin
    Size := (FRect.Right - FRect.Left) / 6;
    TempRect.Top := FRect.Top; // - RESIZE_SQR_SIZE * 2;
    TempRect.Left := FRect.Left;
    TempRect.Right := TempRect.Left + Size;
    TempRect.Bottom := TempRect.Top + Size;
    HandleInfo[hselEject].Rect := TempRect;
    HandleInfo[hselEject].Visible := HasParent;
  end;

  procedure TVennObj.SetupDeleteRect;
  var Size : single;
      TempRect : TRectf;
  begin
    Size := (FRect.Right - FRect.Left) / 6;
    TempRect.Top := FRect.Bottom - Size;
    TempRect.Left := FRect.Left;
    TempRect.Right := TempRect.Left + Size;
    TempRect.Bottom := FRect.Bottom;
    HandleInfo[hselDelete].Rect := TempRect;
    HandleInfo[hselDelete].Visible := true;
  end;

  procedure TVennObj.SetupBodyRect;
  var Radius : single;
      TempRect : TRectf;
  begin
    Radius := Self.XRadius * 0.75;
    TempRect.Top    := Self.Pos.Y - Radius;
    TempRect.Left   := Self.Pos.X - Radius;
    TempRect.Right  := Self.Pos.X + Radius;
    TempRect.Bottom := Self.Pos.Y + Radius;
    HandleInfo[hselBody].Rect := TempRect;
    HandleInfo[hselBody].Visible := true;
  end;


  procedure TVennObj.SetupHandleInfoRects;

  begin
    inherited SetupHandleInfoRects;
    SetupInfoOrZoomRect;
    SetupEjectRect;
    SetupDeleteRect;
    SetupBodyRect;
  end;


  procedure TVennObj.HideAllHintsAndChildren;
  var i : integer;
  begin
    HideAllHints;
    for i := 0 to Children.Count-1 do begin
      Children[i].HideAllHintsAndChildren;
    end;
  end;


  function TVennObj.TouchingSiblings : boolean;
  //Returns true if overlaps with all siblinggs.
  //Returns true if no other siblings, or no parent
  //Returns false if not in contact with a sibling.
    function ObjsOverlap(A, B : TVennObj) : boolean;
    var Dist : single;
        Delta : TPointf;
        Radii : single;
    begin
      Delta := A.Pos - B.Pos;
      Dist := Delta.Length;
      Radii := A.XRadius + B.XRadius;
      Result := (Dist < Radii);
    end;

  var i : integer;
      Obj : TVennObj;

  begin
    Result := true;
    if not assigned(Self.Parent) then exit;
    for i := 0 to Self.Parent.Children.Count-1 do begin
      Obj := Self.Parent.Children.Item[i];
      if Obj = self then continue;
      if not ObjsOverlap(Self, Obj) then begin
        Result := false;
        break;
      end;
    end;
  end;


  function TVennObj.AddXMLHeaderFooter(XML : XmlString) : XMLString;
  begin
    Result := XML_HEADER + CRLF +
              XML +
              XML_FOOTER;
  end;


  procedure TVennObj.StripXMLHeaderFooter(var XML : XmlString);
  var s : XMLString;
  begin
    XML := Trim(XML);
    if MidStr(XML, 1, Length(XML_HEADER)) = XML_HEADER then begin
      XML := MidStr(XML, Length(XML_HEADER)+1, Length(XML));
    end;
    S := MidStr(XML, Length(XML)-Length(XML_FOOTER)+1, Length(XML));
    if s = XML_FOOTER then begin
      XML := MidStr(XML, 1, Length(XML) - Length(XML_FOOTER));
    end;
  end;

  procedure TVennObj.StripXMLObjOpenClose(var XML : XmlString);
  var s : XMLString;
  begin
    if MidStr(XML, 1, Length(XML_VIN_OPEN)) = XML_VIN_OPEN then begin
      XML := MidStr(XML, Length(XML_VIN_OPEN)+1, Length(XML));
    end else if MidStr(XML, 1, Length(XML_RGN_MGR_OPEN)) = XML_RGN_MGR_OPEN then begin
      XML := MidStr(XML, Length(XML_RGN_MGR_OPEN)+1, Length(XML));
    end;
    S := MidStr(XML, Length(XML)-Length(XML_VIN_CLOSE)+1, Length(XML));
    if s = XML_VIN_CLOSE then begin
      XML := MidStr(XML, 1, Length(XML) - Length(XML_VIN_CLOSE));
    end else begin
      S := MidStr(XML, Length(XML)-Length(XML_RGN_MGR_CLOSE)+1, Length(XML));
      if s = XML_RGN_MGR_CLOSE then begin
        XML := MidStr(XML, 1, Length(XML) - Length(XML_RGN_MGR_CLOSE));
      end;
    end;
  end;

  procedure TVennObj.DeleteBlankXMLLines(SL : TStringList);
  var j : integer;
  begin
    for j := SL.Count-1 downto 0 do begin
      if Trim(SL.Strings[j])='' then SL.Delete(j);  //Delete blank lines
    end;
  end;

  procedure TVennObj.DeleteBlankXMLLines(var Text : XMLString);
  var SL : TStringList;
  begin
    SL := TStringList.Create;
    SL.Text := Text;
    DeleteBlankXMLLines(SL);
    Text := SL.Text;
  end;

  procedure TVennObj.IndentXML(SL : TStringList; Prefix : string = '  ');
  var i : integer;
  begin
    for i := 0 to SL.Count-1 do begin
      SL.Strings[i] := Prefix + SL.Strings[i];
    end;
  end;

  function TVennObj.IndentXML(Text : XMLString; Prefix : string = '  ') : XMLString;
  var SL : TStringList;
  begin
    SL := TStringList.Create;
    SL.Text := Text;
    IndentXML(SL, Prefix);
    Text := SL.Text;
    Result := Text;
  end;


  function TVennObj.GetStrippedXMLRepresentation : XmlString;
  var i,j : integer;
      Obj : TVennObj;
      XML : XMLString;
      SL : TStringList;
  begin
    TOmniXMLWriter.SaveXML(Self, XML, pfNodes, ofIndent);
    StripXMLHeaderFooter(XML);
    StripXMLObjOpenClose(XML);
    XML := AddLF2XML(XML);
    XML := XML_VIN_OPEN + CRLF + XML;
    SL := TStringList.Create;
    SL.Text := XML;
    for j := 1 to SL.Count-1 do begin  //don't indent first line
      SL.Strings[j] := '  ' + SL.Strings[j];
    end;
    Result := SL.Text;
    if Children.Count>0 then begin
      for i := 0 to Children.Count - 1 do begin
        Obj := Children.Item[i];
        XML := Obj.GetStrippedXMLRepresentation;
        Result := Result + IndentXML(XML);
      end;
    end;
    Result := Result + CRLF + XML_VIN_CLOSE;
    SL.Text := Result;
    DeleteBlankXMLLines(SL);
    Result := SL.Text;
    SL.Free;
  end;

  function TVennObj.GetCoreXMLRepresentation(ErrList : TStringList) : XmlString;
  //Purpose: to manually export selected properties, in XML format.
    procedure WriteVal(Var XML : XMLString; Tag : string; Value : string); overload;
    begin
      if XML <> '' then XML := XML + #10#13;
      XML := XML + '<'+Tag+'>'+Value+'</'+Tag+'>';
    end;

  var j : integer;
      XML : XMLString;
      SL : TStringList;
  begin
    XML := '';
    WriteVal(XML,'Name',Self.Name);
    WriteVal(XML,'ID',Self.ID);
    //Put more properties above if wanted....
    XML := AddLF2XML(XML);
    XML := XML_VIN_OPEN + CRLF + XML;
    SL := TStringList.Create;
    SL.Text := XML;
    for j := 1 to SL.Count-1 do begin  //don't indent first line
      SL.Strings[j] := '  ' + SL.Strings[j];
    end;
    SL.Add(XML_VIN_CLOSE);
    DeleteBlankXMLLines(SL);
    Result := SL.Text;
    SL.Free;
  end;

  function TVennObj.GetXMLRepresentation : XmlString;
  begin
    Result := GetStrippedXMLRepresentation;
    Result := AddXMLHeaderFooter(Result);
  end;

  function TVennObj.AddLF2XML(XML : XMLString) : XMLString;
  begin
    Result := AnsiReplaceText(XML, '><', '>'+CRLF+'<');
  end;

  function TVennObj.ExtractChildXML(SL : TStringList) : XMLString;
  //Assumes that first line in SL is the beginning of the child object
  var Level : integer;
      ResultSL : TStringList;
      s : string;
  begin
    ResultSL := TStringList.Create;
    Level := 0;
    While SL.Count > 0 do begin
      s := SL[0]; SL.Delete(0);
      if PosEx(XML_VIN_OPEN, s)>0 then begin
        inc(Level);
      end;
      if PosEx(XML_VIN_CLOSE, s)>0 then begin
        Dec(Level);
        if Level=0 then begin
          ResultSL.Add(s);
          break;
        end;
      end;
      if Level > 0 then ResultSL.Add(s);
    end;
    Result := ResultSL.Text;
    ResultSL.Free;
  end;

  procedure TVennObj.LoadFromXML(XML : XmlString);
  var SL : TStringList;
      i  : integer;
      Obj : TVennObj;
      RgnMgr : TRgnManager;

  begin
    Children.DestroyAll;
    TOmniXMLReader.LoadXML(Self, XML);
    XML := AddLF2XML(XML);
    //NOTE: Rather than do a proper parsing of the XML document, I
    //      am going to assume that it is formatted as per the saving
    //      process from GetXMLRepresentation.
    //      Namely one node per line, and a few other things too.
    //      I could later do it properly...
    SL := TStringList.Create;
    StripXMLHeaderFooter(XML);
    SL.Text := XML;
    DeleteBlankXMLLines(SL);
    if SL.Count>0 then SL.Delete(0);  //should be <TVennObj>
    if SL.Count>0 then SL.Delete(SL.Count-1);  //should be </TVennObj>
    //Remove all properties above 1st child (children are at end)
    //FIX: variable 'i' below doesn't seem to be initialized...
    While SL.Count > 0 do begin
      //kt original --> if PosEx(XML_VIN_OPEN, SL[i])=0 then begin
      if PosEx(XML_VIN_OPEN, SL[0])=0 then begin  //kt <--- is [0] correct??
        SL.Delete(0);
      end else begin
        break;
      end;
    end;
    Repeat
      XML := ExtractChildXML(SL);
      if XML <> '' then begin
        RgnMgr := TRgnManager(Self.RgnManager);
        XML := AddXMLHeaderFooter(XML);

        Obj := RgnMgr.NewChild(Self);  //will insert itself into Self.Children
        Obj.LoadFromXML(XML);
      end;
    until XML = '';

    SL.Free;
  end;


  function TVennObj.GetLogicString(ErrList : TStringList) : string;
  var SetIsNull : boolean;
      i : integer;
  begin
    if Self.Name <> RGN_MGR_NAME then Result := '[#' + Self.ID + ']'
    else Result := ' ';
    if Children.Count > 0 then begin
      SetIsNull := False;
      if FLogicDescr.Count = 0 then begin
        GetNetRegion(NetRegion, Children, SetIsNull);
      end else begin
        if Self.Name <> RGN_MGR_NAME then Result := Result + ':(';
        for i := 0 to FLogicDescr.Count - 1 do begin
          if Result[Length(Result)] <> '(' then Result := Result + ' ';
          Result := Result + FLogicDescr.Strings[i];

        end;
        if Self.Name <> RGN_MGR_NAME then Result := Result + ')';
      end;
      if FLogicDescrERR.Count > 0 then begin
        ErrList.Text := ErrList.Text + FLogicDescrERR.Text;
        {
        ErrS := '';
        for i := 0 to FLogicDescrERR.Count-1 do begin
          if ErrS <> '' then ErrS := ErrS + '; ';
          ErrS := ErrS + FLogicDescrERR.Strings[i];
        end;
        Result := Result + ' (NOTE: ' + ErrS + ')';' +
        }
      end;
    end;
    Result := Trim(Result);
  end;



  procedure TVennObj.LoadFromLogicString(Logic : String);
  //Purpose: Set up children and logical arrangement based on logic string.
  //         Children objects must already be set up in RgnMgr
  // Example of input:
  //         AND [#2] AND [#3] AND [#5]:(AND [#1] AND [#4])
  //     or  OBJ [#A]:(OBJ [#1] OBJ [#2]) >= OBJ [#B]:(OBJ [#3] OBJ [#4])

    function GetComboStyle(Name : string) : TCombinationStyle;
    var i  : TCombinationStyle;
    begin
      result :=tcsNone;
      for i := tcsIncludeOptional to LAST_COMPARATOR do begin
        if LOGIC_WORDS[i] = Name then begin
          Result := i;
          break;
        end;
      end;
    end;

    function HandleNextGrp(var Logic, SubStr : string) : TVennObj;
    var
      tempS  : string;
      ComboTerm, ID : string;
      ComboMode : TCombinationStyle;
      p : integer;
    begin
      Logic := UpperCase(Trim(Logic));
      ComboTerm := Piece(Logic,' ',1);
      ComboMode := GetComboStyle(ComboTerm);
      if ComboMode = tcsNone then begin
        Raise Exception.Create('Unexpected combination term. Got: '+ComboTerm);
      end;
      Logic := LTrim(Logic, Length(ComboTerm)+1); //cleave off Bool/combinator
      if IsComparator(ComboMode) then begin
        tempS := Piece(Logic, ' ' , 1);
        if tempS <> 'OBJ' then begin
          Raise Exception.Create('Missing "OBJ" after comparator. Got: '+Logic);
        end;
        Logic := LTrim(Logic, 4); //trim off  'OBJ ' = 4 chars
      end;
      tempS := Piece(Logic,']',1); //e.g. [#2
      ID := piece(tempS,'[#',2);
      Logic := Trim(LTrim(Logic, Length(ID)+3));
      if ID='' then Raise Exception.Create('Can''t find object ID.  Got: ' + Logic);
      Result := RgnMgr(Self).Children.GetByID(ID);
      if not Assigned(Result) then Raise Exception.Create('Can''t find object with ID "' + ID + '"');
      Result.CombinationMode := ComboMode;

      if (Length(Logic) > 0) and (Logic[1] = ':') then begin
        p := 1;
        SubStr :=  MatchedExtract(Logic, '(', P);
        Logic := LTrim(Logic, Length(SubStr)+3);
      end else begin
        SubStr := '';
      end;
    end;

  var SubStr : string;
      LastObj, Obj : TVennObj;
  begin   //eddie -- check here. 
    LastObj := nil;
    Logic := Trim(Logic);
    repeat
      Obj := HandleNextGrp(Logic, SubStr);
      if assigned(Obj) then begin
        Obj.Parent := self; //automatically removes itself from prior parent's list.
        if SubStr <> '' then begin
          Obj.LoadFromLogicString(SubStr);
        end;
        if IsComparator(Obj.CombinationMode) then begin
          Obj.DataPtr1 := LastObj;  // e.g. A >= B     B.DataPtr1 points to A
        end;
      end;
      LastObj := Obj;
       if Logic=',' then Logic := '';
       
    until (Logic = '');
    //AutoArrangeChildren;  //will have to be done after parent autoarranged
  end;

  procedure TVennObj.CheckForOverlappingLabels;
  var
    i, j,Cycles : integer;
    LabelsOK : boolean;
    debug : boolean;
    Obj, Obj2 : TVennObj;
    TempRect: TRectf;
  begin
    //Now check for overlapping labels.
    LabelsOK := true;
    Cycles := 1;
    debug := false; //change at runtime for debugging.
    repeat
      if debug then continue;
      for i := 0 to Children.Count - 1 do begin
        Obj := Children.Item[i];
        TempRect := Obj.LabelRect;
        for j := i+1 to Children.Count - 1 do begin
          Obj2 := Children.Item[j];
          if TempRect.Overlaps(Obj2.LabelRect) then begin
            LabelsOK := false;
            Obj.LabelPosY := Obj.LabelPosY + 10; //move
            Obj2.LabelPosY := Obj2.LabelPosY - 10; //move
          end;
        end;
      end;
      inc (Cycles);
    until (Cycles > 25) or LabelsOK;
  end;

  procedure TVennObj.AutoArrangeChildren;
  var ClusterCenter : TPointf;
      ClusterR : single;
      Obj  : TVennObj;
      MaxRadius, ObjRadius : single;
      CentralRadius : single;
      TempRadius, MaxRoom : Single;

      ZoomedClusterCenter : TPointf;
      //ZoomedClusterR : single;
      ZoomedMaxRadius : single;
      //ZoomedObjRadius : single;
      //ZoomedCentralRadius : single;
      //ZoomedMaxRoom : Single;

      Angle : single;
      AngleInc : single;
      i  : integer;
      Pt : TPointf;
      AndOrList, NotList, OtherList : TVennObjList;


  begin
    //-----------------------------------------------------------------
    //Discussion of zoomed objects
    //When positioning children, if the parent is not the RGN_MGR, then
    //   the children are positioned inside the size of the parent.  This
    //   requires that it all be put inside the width of just one object, and
    //   is thus a small arrangement.  However, when the parent is zoomed
    //   into, the arrangement will be enlarged, and it will all look OK.
    //The problem is that labels positions are not changed during zoom /unzoom.
    //   Thus I will need to calculate the label position as if the zoom process
    //   has already taken place.
    //-----------------------------------------------------------------
    if Children.Count = 0 then exit;

    MaxRoom := Min(HostBitmapHeight, HostBitmapWidth);
    MaxRoom := MaxRoom * 0.90;
    MaxRadius := MaxRoom / 2;
    ClusterCenter := HostBitmapCenter;
    //not used --> ZoomedMaxRoom := MaxRoom;
    ZoomedMaxRadius := MaxRadius;
    ZoomedClusterCenter := ClusterCenter;
    if Self.Name <> RGN_MGR_NAME then begin
      MaxRoom := Self.XRadius;
      MaxRoom := MaxRoom * 0.75;  //0.90
      MaxRadius := MaxRoom / 2;
      ClusterCenter := Self.Pos;
    end;
    ClusterR        := MaxRadius * 0.40;  //distance from center of cluster to center of varius AND objects
    //not used --> ZoomedClusterR  := ZoomedMaxRadius * 0.40;

    ObjRadius       := MaxRadius * 0.6;
    //not used --> ZoomedObjRadius := ZoomedMaxRadius * 0.6;

    CentralRadius := ObjRadius - ClusterR;  // radius of central overalapped area
    //not used --> ZoomedCentralRadius := ZoomedObjRadius - ZoomedClusterR;

    AndOrList := TVennObjList.Create;
    NotList   := TVennObjList.Create;
    OtherList := TVennObjList.Create;

    for i := 0 to Children.Count - 1 do begin
      case Children[i].CombinationMode of
        tcsIncludeOptional : AndOrList.Add(Children[i]);
        tcsIncludeRequired : AndOrList.Add(Children[i]);
        tcsExclude         : NotList.Add(Children[i]);
        else                 OtherList.Add(Children[i]);
      end; {case}
    end;

    //first handle the AND list.
    if AndOrList.Count = 1 then begin
      AndOrList[0].Pos := ClusterCenter;
      AndOrList[0].XRadius := ObjRadius;
    end else if AndOrList.Count > 1 then begin
      AngleInc := 2 * PI / AndOrList.Count;
      for i := 0 to AndOrList.Count - 1 do begin
        Angle := AngleInc * i;
        Obj := AndOrList.Item[i];
        Obj.XRadius := ObjRadius;
        Pt.x := Cos(Angle) * ClusterR;
        Pt.Y := Sin(Angle) * ClusterR;
        Obj.Pos := Pt + ClusterCenter;
        Obj.LabelPinned := true;
        //Pt.x := Cos(Angle) * MaxRadius * 1.25;
        //Pt.y := Sin(Angle) * MaxRadius * 1.25;
        Pt.x := Cos(Angle) * ZoomedMaxRadius * 1.25;
        Pt.y := Sin(Angle) * ZoomedMaxRadius * 1.25;
        //Obj.LabelPos := Pt + ClusterCenter;
        Obj.LabelPos := Pt + ZoomedClusterCenter;
      end;
    end;
    //Next handle the NOT list.
    if NotList.Count > 0 then begin
      AngleInc := 2 * PI / NotList.Count;
      for i := 0 to NotList.Count - 1 do begin
        Angle := PI/2 + (AngleInc * i);  //start 90 degrees offset from AND objects. //kt 5/29/13 
        Obj := NotList.Item[i];
        Obj.XRadius := ObjRadius  * 0.50;
        TempRadius := CentralRadius * 0.66 + Obj.XRadius;
        Pt.x := Cos(Angle) * TempRadius;
        Pt.Y := Sin(Angle) * TempRadius;
        Obj.Pos := Pt + ClusterCenter;
        Obj.LabelPinned := true;
        //Pt.x := Cos(Angle) * MaxRadius * 0.90;
        //Pt.y := Sin(Angle) * MaxRadius * 0.90;
        Pt.x := Cos(Angle) * ZoomedMaxRadius * 0.90;
        Pt.y := Sin(Angle) * ZoomedMaxRadius * 0.90;
        //Obj.LabelPos := Pt + ClusterCenter;
        Obj.LabelPos := Pt + ZoomedClusterCenter;
      end;
    end;

    //Next handle the OTHER list.
    if OtherList.Count > 0 then begin
      AngleInc := 2 * PI / OtherList.Count;
      for i := 0 to OtherList.Count - 1 do begin
        Angle := AngleInc * i;
        Obj := OtherList.Item[i];
        Obj.XRadius := ObjRadius  * 0.50;
        TempRadius := CentralRadius * 0.66 + Obj.XRadius;
        Pt.x := Cos(Angle) * TempRadius;
        Pt.Y := Sin(Angle) * TempRadius;
        Obj.Pos := Pt + ClusterCenter;
        Obj.LabelPinned := (OtherList.Count > 1);
        //Pt.x := Cos(Angle) * MaxRadius * 0.90;
        //Pt.y := Sin(Angle) * MaxRadius * 0.90;
        Pt.x := Cos(Angle) * ZoomedMaxRadius * 0.90;
        Pt.y := Sin(Angle) * ZoomedMaxRadius * 0.90;
        //Obj.LabelPos := Pt + ClusterCenter;
        Obj.LabelPos := Pt + ZoomedClusterCenter;
      end;
    end;

    CheckForOverlappingLabels;

    AndOrList.Free;
    NotList.Free;
    OtherList.Free;
  end;

  procedure TVennObj.AutoArrangeChildrenAndGrandchildren;
  var i : integer;
  begin
    AutoArrangeChildren;
    for i := 0 to Children.count - 1 do begin
      Children[i].AutoArrangeChildrenAndGrandchildren;
    end;
  end;


  procedure TVennObj.ClearFloatingTextList;
  var i : integer;
  begin
    for i := 0 to FFloatingTextList.Count - 1 do begin
      TFloatingText(FFloatingTextList[i]).Free;
    end;
    FFloatingTextList.Clear;
  end;

  procedure TVennObj.AddFloatingText(Pos : TPoint; Text : String; Font : TFont = nil);
  var  OneFloatingText : TFloatingText;
  begin
    OneFloatingText := TFloatingText.Create;
    if Assigned(Font) then OneFloatingText.Font.Assign(Font);
    OneFloatingText.Pos := Pos;
    OneFloatingText.Text := Text;
    FFloatingTextList.Add(OneFloatingText);
  end;

  procedure TVennObj.RenderFloatingText(ABitmap : TBitmap);
  var i,j : integer;
      FlText : TFloatingText;
  begin
    if Self.Name = RGN_MGR_NAME then begin
      if RgnMgr(FRgnManager).UnzoomBMToBeShown then exit
    end; 
    for j := 0 to self.Children.count - 1 do begin
      if self.Children.Item[j].ZoomMode = zmZoomingOut then exit;
    end;
    for i := 0 to FFloatingTextList.Count - 1 do begin
      FlText := TFloatingText(FFloatingTextList[i]);
      if Assigned(FlText.Font) then ABitmap.Canvas.Font.Assign(FlText.Font);
      ABitmap.Canvas.Brush.Color := clRed;
      ABitmap.Canvas.TextOut(FlText.Pos.X, FlText.Pos.Y, FlText.Text);
    end;
  end;


  procedure TVennObj.AutoArrangeChildrenForFormulaDisplay;
  //Note: this will also get auto arrange grandchildren etc

  var Obj : TVennObj;
      MaxRoom, SlotWidth, ObjDiameter : single;
      EnlargedSlotWidth, EnlargedObjDiameter : single;
      i  : integer;
      WordWidth, GapSize : integer;

      EnlargedRadius : single;
      LabelPt,
      EnlargedPt, Pt : TPointf;
      DisplayY : single;
      NumSlots : integer;
      CompName : string;
      Font : TFont;

  const
      LMARGIN = 100;
      COMP_TEXT_WIDTH = 50;

      function SlotPt(SlotWidth : Single; num : integer) : TPointf;
      begin
        Result.y := DisplayY;
        Result.x := LMARGIN + (SlotWidth * Num) + COMP_TEXT_WIDTH;
      end;

      function HalfTextWidth(s:string): integer;
      var
         size : TSize;
      begin
         HostBitmap.Canvas.Font.Assign(Font);
         Size := HostBitmap.Canvas.TextExtent(s);
         result := size.cx div 2;
      end;

  begin
    if not assigned(Children) then exit;
    if Children.Count = 0 then exit;
    Font := TFont.Create;
    Font.Color := clWhite;
    Font.Name := 'Arial';
    Font.Size := 16;
    NumSlots := Children.Count;

    GapSize := 0;
    for i := 1 to Children.Count - 1 do begin
      Obj := Children[i];
      CompName := LogicWords(Obj.CombinationMode);
      WordWidth := HalfTextWidth(CompName) * 2;
      if WordWidth > GapSize then GapSize := WordWidth;
    end;
    if GapSize < COMP_TEXT_WIDTH then GapSize := COMP_TEXT_WIDTH;

    MaxRoom := HostBitmapWidth - LMARGIN;
    SlotWidth := MaxRoom / NumSlots;
    SlotWidth := Min(SlotWidth, HostBitmapHeight * 0.8);
    ObjDiameter := SlotWidth - GapSize;

    //not used --> EnlargedMaxRoom := MaxRoom;
    EnlargedSlotWidth := SlotWidth;
    EnlargedObjDiameter := ObjDiameter;

    if assigned(FParent) then begin
      MaxRoom := Self.XRadius;
      SlotWidth := MaxRoom / NumSlots;
      ObjDiameter := SlotWidth;
    end;

    DisplayY := HostBitmapCenter.y;
    ClearFloatingTextList;
    for i := 0 to Children.Count - 1 do begin
      Pt := SlotPt(SlotWidth, i);
      EnlargedPt := SlotPt(EnlargedSlotWidth, i);
      Obj := Children[i];
      Obj.XRadius := ObjDiameter / 2;
      EnlargedRadius := EnlargedObjDiameter / 2;
      if assigned(FParent) then begin
        Pt.x := (self.pos.x - (self.xradius/2)) + (SlotWidth * i);
        if i > 0 then Pt.x := Pt.X + (GapSize/3);
        Obj.Pos := pt;
      end else begin
        Obj.Pos := EnlargedPt;
      end;
      Obj.LabelPinned := True;
      LabelPt  := EnlargedPt;
      LabelPt.y := LabelPt.y - EnlargedRadius / 2; //move labels 1/4 above center, so they don't potentially overwrite floating text.
      Obj.LabelPos := LabelPt;
      if i = 0 then continue;
      if Obj.CombinationMode = tcsObject then continue;
      CompName := LogicWords(Obj.CombinationMode);
      if not assigned(FParent) then begin
        Pt.x := Pt.x - Obj.XRadius - (GapSize div 2) - HalfTextWidth(CompName);  // Get position for floating text label.
        AddFloatingText(Pt.IntPoint, CompName, Font);
      end else begin
        EnlargedPt.x := EnlargedPt.x - EnlargedRadius - (GapSize div 2) - HalfTextWidth(CompName);
        AddFloatingText(EnlargedPt.IntPoint, CompName, Font);
      end;
    end;
    CheckForOverlappingLabels;
    Font.Free;

    for i := 0 to Children.Count - 1 do begin
      Obj := Children[i];
      //Now also arrange next level deeper.  If Obj doesn't have children, function will just exit.
      Obj.AutoArrangeChildrenForFormulaDisplay;
    end;
  end;

initialization
  SHOW_DEBUG_SET := 0;


end.

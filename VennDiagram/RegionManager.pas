unit RegionManager;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Math,
  Dialogs, ExtCtrls, EllipseObject, TMGGraphUtil, Forms, StrUtils,
  VennObject, StdCtrls, ComCtrls,  Pointf, Rectf, ColorUtil,
  OmniXML, OmniXML_Types,
{$IFDEF USE_MSXML}
  OmniXML_MSXML,
{$ENDIF}
  OmniXMLPersistent;

const
  MAX_STORED_COLOR = 100;

type

  TRgnManager = class (TVennObj)
  private
    FSelected : TVennObjList; //doesn't own objects
    FEditObj : TVennObj; //doesn't own object
    FEdit : TEdit;  //is owned here
    FEditFirstSelectDone : boolean;
    FBitmap : TBitmap;  //is owned here
    Dragging : boolean;
    DraggingOffset : TPointf;
    LabelDraggingOffset : TPointf;
    ActiveSetColorPct : byte;
    ActiveSetColorAnimateUp : boolean;
    HandleSel : TSelHandle;
    FUnZoomBM : TBitmap;
    FUnZoomHiBM : TBitmap;
    FUnZoomRect : TRectf;
    FZoomStack : TVennObjList; //doesn't own objects;
    FAllObjects : TVennObjList; //doesn't own objects;
    BitmapHeight : integer;
    BitmapWidth : integer;
    RenderOrder : integer;

    FEditLabelModeEnabled : boolean;
    FActiveSetColor : TColor;
    FCurrentActiveSetColor : TColor;
    FNextColorIndex : integer;
    FColorStore : Array[1..MAX_STORED_COLOR] of TColor;
    FUseColorArray : boolean; //If false, colors assigned randomly.
    FCanvas : TCanvas; //doesn't own this.  Paints to this.
    fWallpaperSourceBM : TBitmap;
    FWallpaperBM : TBitmap;
    FObjIDCounter : integer;
    FIgnoreOneMouseDown : boolean;
    FOnRefreshNeeded : TNotifyEvent;
    // moved to VennObject FFloatingTextList : TList; //will be filled with pointers to TFloatingText objects

  protected
    FSelVennObject : TVennObj;  //doesn't own object
    FOnSelChange : TNotifyForVennObjectEvent;
    FOnRtClickVennObject : TNotifyForVennObjectEvent;
    FOnDblClickVennObject : TNotifyForVennObjectEvent;
    procedure HandleOnExit(Sender: TObject);
    procedure HandleOnEditChange(Sender: TObject);
    procedure HandleEditKeyPress(Sender: TObject; var Key: Char);
    procedure HandleOnEditMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SetLabelEditModeEnabled(Enabled : boolean);
    procedure AnimateSetColor(IntervalTimeMs : Extended);
    procedure ZoomIntoObj(Obj : TVennObj);
    procedure SetSelVennObject(Value : TVennObj);
    procedure Animate(IntervalTimeMs : Extended); overload;
    procedure HandleDoneZoomOut(Sender : TObject);
    procedure RenderUnzoomIcon(Bitmap : TBitmap; MousePos : TPoint);
    procedure AdjustMousePos(var MousePos : TPoint); overload;
    procedure AdjustMousePos(var MousePos : TPointf); overload;
    function SetupAdjustedMouse(X, Y : integer) : TPoint;
    procedure SetWallpaperBMForSize(NewHeight, NewWidth : integer);
    function GetNextColor : TColor;
    procedure InitNewChild(VennObject : TVennObj);
  public
    MasterMousePos : TPoint;
    function UnzoomBMToBeShown : boolean;
    procedure SetSelection(Obj : TVennObj);
    procedure ZoomOut1Level;
    procedure ZoomIntoSelected;
    function VennObjectShouldShowChildren(Obj : TVennObj) : boolean;
    procedure AddObj(Obj : TVennObj);
    function NewChild (Parent : TVennObj = nil) : TVennObj;
    procedure ClearChildren;
    function DeleteObj(Obj : TVennObj) : integer;
    function InUpperZoomStack(Obj : TVennObj) : boolean;
    procedure HandleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure HandleMouseMove(Sender: TObject; Shift: TShiftState; X,  Y: Integer);
    procedure HandleMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure HandleDblClick(MousePos : TPoint);
    procedure Resize(NewHeight, NewWidth : integer);
    procedure Animate(); overload;
    procedure ClearBitmap(Bitmap : TBitmap; WallpaperBM : TBitmap = nil);
    procedure Render(MousePos : TPoint; var OrderNum : integer);
    procedure AnimateAndRender;
    //procedure AnimateAndRender(MousePos : TPoint);
    function ItemAtPoint(Pt : TPoint; CurSelObj :TVennObj; ListOfAll : TVennObjList=nil) : TVennObj; override;
    procedure SaveToFile(FilePathName : string);
    procedure LoadFromFile(FilePathName : string);
    function  GetCoreXMLRepresentation(ErrList : TStringList) : XmlString;
    procedure LoadFromCoreXML(XML : XmlString);
    constructor Create(AParent : TWinControl);
    destructor Destroy; dynamic;
    //-------------------
    property SelVennObject : TVennObj read FSelVennObject write SetSelVennObject;
    property Canvas : TCanvas read FCanvas write FCanvas;
    property ZoomStack : TVennObjList read FZoomStack; //doesn't own objects;
    property WallpaperBM : TBitmap read FWallpaperBM write FWallpaperBM;
    property OnSelChange : TNotifyForVennObjectEvent read FOnSelChange write FOnSelChange;    //If nothing is selected, then event will fire with Obj=nil
    property OnRtClickVennObject : TNotifyForVennObjectEvent read FOnRtClickVennObject write FOnRtClickVennObject;
    property OnDblClickVennObject : TNotifyForVennObjectEvent read FOnDblClickVennObject write FOnDblClickVennObject;
    property OnRefreshNeeded : TNotifyEvent read FOnRefreshNeeded write FOnRefreshNeeded;
  published
    property UseArrayColors : boolean read FUseColorArray write FUseColorArray;
    property WallpaperSourceBM : TBitmap read FWallpaperSourceBM write FWallpaperSourceBM;
    property EditLabelModeEnabled : boolean read FEditLabelModeEnabled write FEditLabelModeEnabled;
    property ActiveSetColor : TColor read FActiveSetColor write FActiveSetColor;
    property CurrentActiveSetColor : TColor read FCurrentActiveSetColor write FCurrentActiveSetColor;
  end;

CONST
     DISPLAY_OFFSET : TPoint  = (X:-5; Y: -5);
     RGN_MGR_NAME = '(RGN_MANAGER)';

implementation

  {$R RGN_MGR.RES}

  uses MainU, frmVennU; //temp for debugging
  const SHOW_DEBUG_SET = 0;
        MIN_EDIT_WIDTH = 100;
        ALL_OBJS = 'AllObjects';
        ALL_OBJS_OPEN  = '<'+ALL_OBJS+'>';
        ALL_OBJS_CLOSE = '</'+ALL_OBJS+'>';
        LOGIC_STR = 'LogicDescription';
        LOGIC_STR_OPEN  = '<'+LOGIC_STR+'>';
        LOGIC_STR_CLOSE = '</'+LOGIC_STR+'>';

//============================================================
//============================================================

  constructor TRgnManager.Create(AParent : TWinControl);
  var i : integer;
  begin
    Inherited Create(Nil);
    Self.RgnManager := Self;
    Self.Name := RGN_MGR_NAME;
    Self.ID := '0';
    FOnRefreshNeeded := nil;
    FSelVennObject := nil;
    FSelected := TVennObjList.Create; //doesn't own objects
    Dragging := false;
    ActiveSetColor := clYellow;
    Self.XRadius := 10000;
    Self.YRadius := 10000;
    BitmapHeight := 0;
    BitmapWidth := 0;
    FUnZoomBM := TBitmap.Create;
    FUnZoomBM.LoadFromResourceName(hInstance,'BACK_ZOOML');
    FUnZoomBM.PixelFormat:= pf24bit;
    FUnZoomBM.Transparent:= true;
    FUnZoomBM.TransparentColor:= clFuchsia; //RGB(255, 0, 255);

    FUnZoomHiBM := TBitmap.Create;
    FUnZoomHiBM.LoadFromResourceName(hInstance,'BACK_ZOOMH');
    FUnZoomHiBM.PixelFormat:= pf24bit;
    FUnZoomHiBM.Transparent:= true;
    FUnZoomHiBM.TransparentColor:= clFuchsia; //RGB(255, 0, 255);

    FUnZoomRect.TopLeft:= ZERO_VECT;
    FUnZoomRect.Right:= FUnZoomBM.Width;
    FUnZoomRect.Bottom := FUnZoomBM.Height;
    FZoomStack := TVennObjList.Create;
    FAllObjects := TVennObjList.Create;

    WallpaperSourceBM := TBitmap.Create;
    WallpaperSourceBM.LoadFromResourceName(hInstance,'LEATHER');
    WallpaperBM := TBitmap.Create;
    SetWallpaperBMForSize(AParent.Height, AParent.Width);

    FBitmap := TBitmap.Create;
    FBitmap.Width := VennForm.Width;
    FBitmap.Height := VennForm.Height-BOTTOM_SPACING;

    FEdit := TEdit.Create(AParent);
    FEdit.Parent := AParent;
    FEdit.OnKeyPress := HandleEditKeyPress;
    FEdit.OnExit :=   HandleOnExit;
    FEdit.OnMouseUp := HandleOnEditMouseUp;
    FEdit.OnChange := HandleOnEditChange;
    //FEdit.OnEnter := HandleOnEditChange;
    FEdit.AutoSelect := true;
    SetLabelEditModeEnabled(false);

    FOnSelChange := nil;
    FOnRtClickVennObject := nil;
    FObjIDCounter := 0;
    Randomize;
    for i := 1 to MAX_STORED_COLOR do FColorStore[i] := TColor(Random($FFFFFF));
    FNextColorIndex := 1;
    FUseColorArray := true;
    FIgnoreOneMouseDown := false;

    //moved to VennObject  FFloatingTextList := TList.Create;
  end;

  destructor TRgnManager.Destroy;
  begin
    FUnZoomBM.Free;
    FUnZoomHiBM.Free;
    WallpaperSourceBM.Free;
    WallpaperBM.Free;
    FBitmap.Free;
    FZoomStack.Free;  //doesn't own objects
    FAllObjects.Free; //doesn't own objects
    FSelected.Free;   //doesn't own objects
    //moved to VennObject  ClearFloatingTextList;
    //moved to VennObject  FFloatingTextList.Free;  //DOES own objects, cleared by ClearFloatingTextList;
    Inherited Destroy;
  end;

  function TRgnManager.GetCoreXMLRepresentation(ErrList : TStringList) : XmlString;
  //Purpose: return a core XML representation.  E.G.
  {
    <data PropFormat="node">
     <AllObjects>
      <TVennObj>
        <Name>Object 1</Name>
        <ID>1</ID>
      </TVennObj>
      <TVennObj>
        <Name>Object 2</Name>
        <ID>2</ID>
      </TVennObj>
      <TVennObj>
        <Name>Object 3</Name>
        <ID>3</ID>
      </TVennObj>
      <TVennObj>
        <Name>Object 4</Name>
        <ID>4</ID>
      </TVennObj>
      <TVennObj>
        <Name>Object 5</Name>
        <ID>5</ID>
      </TVennObj>
     </AllObjects>
     <LogicDescription>AND [#2] AND [#3] AND [#5]:(AND [#1] AND [#4])</LogicDescription>
    </data>
  }
  var XML : XMLString;
      i : integer;
      Obj : TVennObj;
  begin
    XML := ALL_OBJS_OPEN+CRLF;
    for i := 0 to FAllObjects.Count - 1 do begin
      Obj := FAllObjects.Item[i];
      XML := XML + IndentXML(Obj.GetCoreXMLRepresentation(ErrList));
    end;
    XML := XML + ALL_OBJS_CLOSE + CRLF;
    XML := XML + LOGIC_STR_OPEN + GetLogicString(ErrList) + LOGIC_STR_CLOSE +CRLF;
    DeleteBlankXMLLines(XML);
    XML := IndentXML(XML);
    Result := AddXMLHeaderFooter(XML);
  end;

  procedure TRgnManager.LoadFromCoreXML(XML : XmlString);
  //note: see example of XML format in GetCoreXMLRepresentation();
  var SL : TStringList;
      i  : integer;
      Obj : TVennObj;
      LogicStr : String;

  begin
    ClearFloatingTextList;
    ClearChildren;
    XML := AddLF2XML(XML);
    StripXMLHeaderFooter(XML);
    //NOTE: Rather than do a proper parsing of the XML document, I
    //      am going to assume that it is formatted as per the saving
    //      process from GetXMLRepresentation.
    //      Namely one node per line, and a few other things too.
    //      I could later do it properly...
    SL := TStringList.Create;
    SL.Text := XML;
    DeleteBlankXMLLines(SL);
    if SL.Count>0 then SL.Delete(0);  //should be ALL_OBJS_OPEN
    //Create all children (to be positioned by logic string below)
    Repeat
      XML := ExtractChildXML(SL);
      if XML <> '' then begin
        //XML := AddXMLHeaderFooter(XML);
        Obj := NewChild(Self);  //will insert itself into Self.Children
        Obj.HostBitmap := FBitmap;
        Obj.HostBitmap.Height := FBitmap.Height;
        Obj.HostBitmap.Width := FBitmap.Width;
        Obj.SetPropertiesFromCoreXML(XML);
      end;
    until (SL.Count=0) or
          (Trim(SL.Strings[0])= ALL_OBJS_CLOSE) or
          (XML='');
    //get Logic String
    LogicStr := '';
    i := 0;
    while i <= (SL.Count-1) do begin
      if PosEx(LOGIC_STR_OPEN, SL.Strings[i])>0 then begin
        LogicStr := Trim(SL.Strings[i]);
        LogicStr := ReplaceText(LogicStr,LOGIC_STR_OPEN,'');
        LogicStr := ReplaceText(LogicStr,LOGIC_STR_CLOSE,'');
      end;
      inc (i);
    end;
    if LogicStr<>'' then begin
      Self.LoadFromLogicString(LogicStr);
    end;
    AutoArrangeChildrenAndGrandchildren;
    SetSelection(nil);
    SL.Free;
  end;



  procedure TRgnManager.AnimateSetColor(IntervalTimeMs : Extended);
  begin
    if ActiveSetColorAnimateUp then begin
      Inc(ActiveSetColorPct,2);
      if ActiveSetColorPct > 100 then begin
        ActiveSetColorAnimateUp := false;
        ActiveSetColorPct := 98;
      end;
    end else begin
      Dec(ActiveSetColorPct,2);
      if ActiveSetColorPct > 250 then begin  //wrapped value
        ActiveSetColorAnimateUp := true;
        ActiveSetColorPct := 2;
      end;
    end;
    CurrentActiveSetColor := ColorBlend(ActiveSetColor, clRed, ActiveSetColorPct);
  end;

  procedure TRgnManager.Animate(IntervalTimeMs : Extended);
  begin
    AnimateSetColor(IntervalTimeMS);
    //inherited Animate(IntervalTimeMs);
    //Don't animate self, since Region Manager doesn't have visible parts.
    AnimateChildren(IntervalTimeMs);
  end;

  procedure TRgnManager.Animate();
  var IntervalTimeMs : Extended;
  begin
    IntervalTimeMs := IntervalSysTime;
    Animate(IntervalTimeMs);
  end;


  function TRgnManager.UnzoomBMToBeShown : boolean;
  begin
    Result := (FZoomStack.Count > 0) and
              (FZoomStack.Item[0].ZoomMode in [zmAtMax, zmZoomingIn]);
  end;

  procedure TRgnManager.RenderUnzoomIcon(Bitmap : TBitmap; MousePos : TPoint);
  var Rect : TRectf;
      BM : TBitmap;

  begin
    Rect.Left   := -DISPLAY_OFFSET.X;
    Rect.Top    := -DISPLAY_OFFSET.Y;
    Rect.Right  := -DISPLAY_OFFSET.X + FUnZoomBM.Width;
    Rect.Bottom := -DISPLAY_OFFSET.Y + FUnZoomBM.Height;
    if Rect.ContainsPoint(MousePos) then begin
      BM := FUnZoomHiBM;
    end else begin
      BM := FUnZoomBM;
    end;
    Bitmap.Canvas.Draw(-DISPLAY_OFFSET.X, -DISPLAY_OFFSET.Y, BM);
  end;

  procedure TRgnManager.AdjustMousePos(var MousePos : TPoint);
  begin
    MousePos := SubtractPoint(MousePos, DISPLAY_OFFSET);
  end;

  procedure TRgnManager.AdjustMousePos(var MousePos : TPointf);
  var TempPt : TPoint;
  begin
    TempPt := MousePos.IntPoint;
    AdjustMousePos(TempPt);
    MousePos.IntPoint := TempPt;
  end;

  function TRgnManager.SetupAdjustedMouse(X, Y : integer) : TPoint;
  begin
    Result.x := X;
    Result.y := Y;
    AdjustMousePos(Result);
  end;


  function TRgnManager.ItemAtPoint(Pt : TPoint; CurSelObj :TVennObj; ListOfAll : TVennObjList=nil) : TVennObj;
  begin
    if UnzoomBMToBeShown and FUnZoomRect.ContainsPoint(Pt) then begin
      Result := nil;
      exit;
    end;
    Result := Inherited ItemAtPoint(Pt, CurSelObj, ListOfAll);
  end;

  //--- Selection stuff -------------------------------------------

  //Will change such that Selection is a list instead of a single pointer
  //Will need AddToSelList, DelFromSelList, ClearSelList

  procedure TRgnManager.SetSelection(Obj : TVennObj);

    procedure SetSelectOfObj(Obj : TVennObj; Selected : boolean);
    var Mode : integer;
    begin
      if not assigned(Obj) then exit;
      Obj.Selected := Selected;
      if Selected then begin
       Mode := Integer(Obj.CombinationMode);
       VennForm.cboMode.ItemIndex := Mode;
       VennForm.cboMode.Text := VennForm.cboMode.Items[VennForm.cboMode.ItemIndex];
      end else begin
        VennForm.cboMode.Text := '';
      end;
    end;

  begin
    if Assigned(SelVennObject) and (SelVennObject <> Obj) then begin
      SetSelectOfObj(SelVennObject, false);
    end;
    SelVennObject := Obj;
    SetSelectOfObj(SelVennObject, true);
    if assigned(FOnSelChange) then FOnSelChange(SelVennObject);
  end;

  //----------------------------------------------


  procedure TRgnManager.AddObj(Obj : TVennObj);
  //Inserts existing object into hierarchy
  var i : integer;     //elh
      Child : TVennObj; //elh
      Pt : TPointf;
  begin
    Obj.OnFinishedZoomOut := HandleDoneZoomOut;
    Pt.x := FUnZoomRect.Right + 10;
    Pt.y := -DISPLAY_OFFSET.Y + 5;
    //Obj.ZoomedLabelStart := FUnZoomRect.TopRight;
    Obj.ZoomedLabelStart := Pt;
    Obj.RgnManager := Self;
    //elh addition
    for i := 0 to Self.ZoomStack.Count - 1 do begin
      Child := Self.ZoomStack[i];
      if Child.ZoomMode <> zmNormal then Obj.Parent := Child;
    end;
    if Obj.Parent = nil then Obj.Parent := self;  //Will effect additon to Self.Children List
    Obj.SetRadiusPctOfParent;
    //end elh addition
    //original line  ->  Obj.Parent := self;  //Will effect additon to Self.Children List
    SetSelection(Obj);
  end;

  function TRgnManager.GetNextColor : TColor;
  //Colors are randomized only at the initialization of the TRgnManager.
  //Otherwise colors will be consistent between different sets.
  begin
    if (FNextColorIndex <= MAX_STORED_COLOR) and (FUseColorArray) then begin
      Result := FColorStore[FNextColorIndex];
      inc (FNextColorIndex);
      exit;
    end;
    Result :=TColor(Random($FFFFFF));
  end;

  procedure TRgnManager.InitNewChild(VennObject : TVennObj);
  var InitPos : TPointf;
  begin
    VennObject.RgnManager := Self;
    VennObject.AllowEllipseShape := false;
    VennObject.XRadius := 40;
    VennObject.Rotation := 0;
    VennObject.DataValue1 := 0;
    VennObject.HostBitmap := FBitmap;
    Randomize;
    VennObject.Color := GetNextColor;
    InitPos.X := Random(200)+100;
    InitPos.Y := Random(200)+100;
    InitPos := InitPos - VennObject.XRadius;
    VennObject.LabelPos := InitPos;
    VennObject.Pos := InitPos;
    Inc(FObjIDCounter);
    VennObject.Name := 'Object ' + IntToStr(FObjIDCounter);
    VennObject.ID := IntToStr(FObjIDCounter);
    FAllObjects.Add(VennObject);
    InitPos.X := Random(200)+100;
    InitPos.Y := Random(200)+100;
    VennObject.LabelPos := InitPos;
  end;


  function TRgnManager.NewChild(Parent : TVennObj = nil) : TVennObj;
  //Note: all creation of children should be done HERE.
  var VennObject : TVennObj;
  begin
    VennObject := TVennObj.Create(Parent);
    Result := VennObject;
    InitNewChild(VennObject);
    AddObj(VennObject); //This will own objects.
  end;

  procedure TRgnManager.ClearChildren;
  begin
    Children.DestroyAll;
    FAllObjects.Clear; //kt
    FObjIDCounter := 0;
    FNextColorIndex := 1;
  end;


  function TRgnManager.DeleteObj(Obj : TVennObj) : integer;
  var DelOK: boolean;
      ID : string;
  begin
    Result := mrCancel;
    if not assigned(Obj) then exit;
    if assigned(Obj.OnDeleteRequest) then begin
      Obj.OnDeleteRequest(Obj, DelOK);
      if DelOK then Result := mrOK;
    end else begin
      Result := MessageDlg('Are you sure you want to delete this object'+CRLF+
                 'and any children that it may contain?'+CRLF+
                 'NOTE: Can not be undone.',mtWarning, mbOKCancel, 0);
    end;
    if Result <> mrOK then exit;
    ID := Obj.ID;
    FAllObjects.DeleteID(ID);
    Obj.Destroy;
    Obj := nil;   
  end;

  function TRgnManager.InUpperZoomStack(Obj : TVennObj) : boolean;
  //Returns true if object is in zoom stack, but isn't at the end of the stack
  //This is because all members in the zoom stack should be hidden except for
  //the last entry.
  //Returns false if object is not in stack, or if it is at last entry.
  var i : integer;
  begin
    Result := false;
    i := ZoomStack.IndexOf(Obj);
    if i = -1 then exit;
    if i = (ZoomStack.Count-1) then exit;
    Result := true;
  end;


  procedure TRgnManager.HandleMouseDown(Sender: TObject; Button: TMouseButton;
                                 Shift: TShiftState; X, Y: Integer);
  var MousePos : TPoint;
      Obj : TVennObj;
      //ListOfAll : TVennObjList;

  begin
    MasterMousePos.X := X;
    MasterMousePos.Y := Y;
    if FIgnoreOneMouseDown then begin
      //For some reason, I get a spurious mousedown after a successful double-click
      FIgnoreOneMouseDown := false;
      exit;
    end;
    if EditLabelModeEnabled and FEditFirstSelectDone then begin
      SetLabelEditModeEnabled(false); //will save changes.
    end;
    MousePos := SetupAdjustedMouse(X, Y);
    //ListOfAll := TVennObjList.Create;
    //Obj := ItemAtPoint(MousePos, SelVennObject, ListOfAll);
    Obj := ItemAtPoint(MousePos, SelVennObject);
    //ListOfAll.Free;
    SetSelection(Obj);
    if not Assigned(SelVennObject) then begin
      Dragging := false;
      exit;
    end;
    HandleSel := SelVennObject.WhichHandleSelected(MousePos);
    DraggingOffset := SelVennObject.Pos - MousePos;
    LabelDraggingOffset := SelVennObject.LabelPos - MousePos;
    Children.MoveToFront(SelVennObject);
    Dragging := true;
    SelVennObject.DragMode := tdmNotIntoContainer;
    //if FFloatingTextList.Count > 0 then begin
    //  Dragging := false; //don't allow dragging if Floating Text Labels are on the screen.
    //end;
  end;

  procedure TRgnManager.HandleMouseMove(Sender: TObject; Shift: TShiftState;
                                        X,  Y: Integer);
  var MousePos : TPointf;
      AContainerObj : TVennObj;

  begin
    MasterMousePos.X := X;
    MasterMousePos.Y := Y;
    if not Dragging then exit;
    if not Assigned(SelVennObject) then exit;

    if Y > BitmapHeight then Y := BitmapHeight;
    if X > BitmapWidth then X := BitmapWidth;
    MousePos.IntPoint := SetupAdjustedMouse(X, Y);
    if HandleSel in [hselBody, hselNetRegion] then begin
      if SelVennObject.CanDrag = false then exit;
      SelVennObject.Pos := MousePos + DraggingOffset;
      AContainerObj := nil;
      if (ssCtrl in Shift) then begin
        AContainerObj := ContainerObj(SelVennObject);
        if AContainerObj = SelVennObject.Parent then begin
          AContainerObj := nil;
        end;
      end;
      if Assigned(AContainerObj) then begin
        SelVennObject.DragMode := tdmOverContainer;
      end else begin
        SelVennObject.DragMode := tdmNotIntoContainer;
      end;
      if SelVennObject.LabelPinned then begin
        SelVennObject.LabelPos := MousePos + LabelDraggingOffset;
      end;
    end else begin
      SelVennObject.SetHandlePt(HandleSel, MousePos);
    end;
  end;

  procedure TRgnManager.HandleMouseUp(Sender: TObject; Button: TMouseButton;
                               Shift: TShiftState; X, Y: Integer);
  var MousePos : TPointf;
      AContainerObj : TVennObj;
      NewHandle : TSelHandle;
      HasSibling : boolean;
      ClickedSel : TSelHandle;

  begin
    MasterMousePos.X := X;
    MasterMousePos.Y := Y;
    Dragging := false;
    MousePos.IntPoint := SetupAdjustedMouse(X, Y);
    if UnzoomBMToBeShown and FUnZoomRect.ContainsPoint(MousePos) then begin
      ZoomOut1Level;
      exit;
    end;
    if not Assigned(SelVennObject) then exit;
    HasSibling := SelVennObject.HasSibling;
    NewHandle := SelVennObject.WhichHandleSelected(MousePos.IntPoint);
    AContainerObj := nil;
    if (NewHandle = HandleSel) then ClickedSel := NewHandle else ClickedSel := hselNone;
    case ClickedSel of
      hselPinhead       : begin
                            SelVennObject.LabelPinned := false;
                            SelVennObject.DragMode := tdmNone;
                            exit;
                          end;
      hselInfoOrZoom    : begin
                            ZoomIntoSelected;
                            exit;
                          end;
      hselDelete        : if DeleteObj(SelVennObject) <> mrCancel then begin
                            if assigned(SelVennObject) then SelVennObject.DragMode := tdmNone;
                            SelVennObject := nil;
                            if not HasSibling then ZoomOut1Level;
                            if assigned(FOnRefreshNeeded) then begin
                              FOnRefreshNeeded(Self);  //should trigger a refresh.
                            end;
                            exit;
                          end;
      hselEject         : AContainerObj := SelVennObject.Grandparent;
      else                begin
                            if SelVennObject.DragMode = tdmOverContainer then begin
                              AContainerObj := ContainerObj(SelVennObject);
                            end;
                          end;
    end; {case}
    SelVennObject.DragMode := tdmNone;
    if Assigned(SelVennObject)
      and Assigned(AContainerObj)
      and (SelVennObject.Parent <> AContainerObj) then begin
      SelVennObject.ZoomMode := zmDisappear;  //elh
      SelVennObject.PotentialParent := AContainerObj;  //elh
      SetSelection(nil);
    end;
    if Assigned(SelVennObject) and (Button = mbRight) and assigned(FOnRtClickVennObject) then begin
      FOnRtClickVennObject(SelVennObject);
    end;
  end;

  procedure TRgnManager.HandleDblClick(MousePos : TPoint);
  var TempHandleSel : TSelHandle;
      EditRect : TRectf;
  begin
    AdjustMousePos(MousePos);
    FEditObj := ItemAtPoint(MousePos, SelVennObject);
    if not Assigned(FEditObj) then exit;
    FEditObj.DragMode := tdmNone;
    Dragging := false;
    TempHandleSel := FEditObj.WhichHandleSelected(MousePos);
    if TempHandleSel in [hselNetRegion, hselBody] then begin
      if Assigned(FEditObj) and assigned(FOnDblClickVennObject) then begin
        FOnDblClickVennObject(FEditObj);
        FIgnoreOneMouseDown := true; //Stop spurious mousedown that was occuring after this.
      end;
      exit;
    end;
    if TempHandleSel <> hselLabel then exit;
    EditRect := FEditObj.LabelRect;
    FEdit.Top :=  EditRect.IntTop - 5;
    FEdit.Left := EditRect.IntLeft - 5;
    FEdit.Text := FEditObj.Name;
    FEdit.Width := EditRect.IntWidth;
    If FEdit.Width < MIN_EDIT_WIDTH then FEdit.Width := MIN_EDIT_WIDTH;
    HideAllHintsAndChildren;
    RenderOrder := 0;
    Render(MousePos, RenderOrder);
    SetLabelEditModeEnabled(true);
    FEdit.SelectAll;
  end;

  procedure TRgnManager.SetLabelEditModeEnabled(Enabled : boolean);
  begin
    FEdit.Visible := Enabled;
    EditLabelModeEnabled := Enabled;
    if (Enabled = false) then begin
      FEditFirstSelectDone := false;
      if assigned(FEditObj) then begin
        FEditObj.Name := FEdit.Text;
        FEditObj.LabelPinned := False
      end;
    end;
  end;


  procedure TRgnManager.HandleOnExit(Sender: TObject);
  begin
    if assigned(FEditObj) then FEditObj.LabelPinned := False
  end;

  procedure TRgnManager.HandleOnEditChange(Sender: TObject);
  begin
    FEditFirstSelectDone := true;
  end;

  procedure TRgnManager.HandleEditKeyPress(Sender: TObject; var Key: Char);
  begin
    if Key in [#13, #27] then begin
      if Key = #27 then begin
        FEdit.Text := FEditObj.Name;
      end;
      SetLabelEditModeEnabled(false);
      Key := #0;
    end;
  end;

  procedure TRgnManager.HandleOnEditMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
    if (Button <> mbLeft) then exit;
    if not (Sender = FEdit) then exit;
    if FEditFirstSelectDone then exit;
    FEdit.SelectAll;
    FEditFirstSelectDone := true;
  end;


  procedure TRgnManager.HandleDoneZoomOut(Sender : TObject);
  begin
    //ZoomOut1Level;
  end;

  procedure TRgnManager.SetWallpaperBMForSize(NewHeight, NewWidth : integer);
  //Paints WallpaperSourceBM onto WallpaperBM in alternating methods, so
  // there are no obvious division lines between bitmaps
    { +---------------+------------------+
      |  Original     |  Flipped Horiz   |
      |  Source BM    |                  |
      |    [0,0]      |   [1,0]          |
      +---------------+------------------+
      |  Flipped Vert |  Flipped both    |
      |               |  Horiz & Vert    |
      |    [0,1]      |   [1,1]          |
      +---------------+------------------+  }

  var TileX,TileY : integer;
      MaxX,MaxY : integer;
      BMIndexX, BMIndexY : Byte;
      BMArray : Array[0..1,0..1] of TBitmap;

  begin
    BMArray[0,0] := WallpaperSourceBM; //owned elsewhere
    BMArray[1,0] := TBitmap.Create;
    BMArray[0,1] := TBitmap.Create;
    BMArray[1,1] := TBitmap.Create;

    BMArray[1,0].Assign(WallpapersourceBM);
    BMArray[0,1].Assign(WallpapersourceBM);
    BMArray[1,1].Assign(WallpapersourceBM);

    BMArray[1,0].FlipHorizontal;
    BMArray[0,1].FlipVertical;
    BMArray[1,1].FlipHorizontal;
    BMArray[1,1].FlipVertical;

    MaxY := 0;
    TileX := -1;
    TileY := -1;
    repeat
      inc (TileY);
      MaxX := 0;
      repeat
        Inc(TileX);
        BMIndexX := TileX mod 2;  BMIndexY := TileY mod 2;
        WallpaperBM.Canvas.Draw(MaxX, MaxY, BMArray[BMIndexX, BMIndexY]);
        MaxX := MaxX + WallpaperSourceBM.Width - 1;
      until MaxX >= WallpaperBM.Width;
      MaxY := MaxY + WallpaperSourceBM.Height - 1;
      TileX := -1;
    until MaxY > WallpaperBM.Height;
    BMArray[1,0].Free;
    BMArray[0,1].Free;
    BMArray[1,1].Free;
    //NOTE: don't free BMArray[0,0] !
  end;

  procedure TRgnManager.Resize(NewHeight, NewWidth : integer);
  var i : integer;
  begin
    FBitmap.Width := NewWidth;
    FBitmap.Height := NewHeight;
    BitmapHeight := NewHeight;
    BitmapWidth := NewWidth;
    //(Note: Region manager is never rendered, so have to set these here...}
    HostBitmap := FBitmap;

    if Assigned(WallpaperSourceBM) and Assigned(WallpaperBM) then begin
      WallpaperBM.Width := NewWidth;
      WallpaperBM.Height := NewHeight;
      SetWallpaperBMForSize(NewHeight, NewWidth);
    end;
    Self.FXRadius := (BitmapWidth / 2) * ZOOM_ENLARGEMENT_FACTOR;
    Self.FYRadius := (BitmapHeight / 2) * ZOOM_ENLARGEMENT_FACTOR;
    for i := 0 to FChildren.Count - 1 do begin
      FChildren[i].SetPosPctOfParent;
      FChildren[i].SetRadiusPctOfParent;
    end;
    if FZoomStack.Count > 0 then begin
      FZoomStack.Item[0].ZoomMode := zmZoomingIn;
    end;
  end;

  procedure TRgnManager.SetSelVennObject(Value : TVennObj);
  begin
    FSelVennObject := Value;
  end;

  procedure TRgnManager.ZoomOut1Level;
  var Obj : TVennObj;
  begin
    if FZoomStack.Count > 0 then begin
      Obj := FZoomStack[FZoomStack.Count-1];
      Obj.ZoomMode := zmZoomingOut;
      FZoomStack.Delete(Obj);
    end;
    if FZoomStack.Count > 0 then begin
      Obj := FZoomStack[FZoomStack.Count-1];
    end else Obj := nil;
    SetSelection(Obj);
  end;

  procedure TRgnManager.ZoomIntoSelected;
  begin
    SelVennObject.DragMode := tdmNone;
    ZoomIntoObj(SelVennObject);
  end;

  procedure TRgnManager.ZoomIntoObj(Obj : TVennObj);
  begin
    if not assigned(Obj) then exit;
    FZoomStack.Add(Obj);
    Obj.ZoomMode := zmZoomingIn;
    if Obj.HasChild then begin
      SetSelection(Obj.Children.Item[0]);
    end else begin
      SetSelection(Nil);
    end;
  end;

  procedure TRgnManager.ClearBitmap(Bitmap : TBitmap; WallpaperBM : TBitmap = nil);
  begin
    if assigned(WallpaperBM) then begin
      Bitmap.Canvas.Draw(0, 0, WallpaperBM);
    end else begin
      Bitmap.Canvas.Brush.Color := clWhite;
      Bitmap.Canvas.Brush.Style := bsSolid;
      Bitmap.Canvas.Pen.Style := psSolid;
      Bitmap.Canvas.Pen.Color := clWhite;
      Bitmap.Canvas.Rectangle(0, 0, Bitmap.Width, Bitmap.Height);
    end;

    if SHOW_DEBUG_SET>0 then VennForm.Canvas.Draw(1, 1, Bitmap); //debugging only.  Remove later.
  end;

  function TRgnManager.VennObjectShouldShowChildren(Obj : TVennObj) : boolean;
  begin
    //Should show children if object is top level object (parent=nil)
    // or if object is the most recent addition to ZoomStack.
    Result := false;
    if Obj.Parent = nil then begin
      Result := true;
      exit;
    end;
    if (FZoomStack.Count = 0) then exit;
    //if fZoomStack.IndexOf(Obj) = (FZoomStack.Count -1) then begin
    if fZoomStack.IndexOf(Obj) > -1 then begin
      Result := true;
      exit;
    end;
  end;

  procedure TRgnManager.SaveToFile(FilePathName : string);
  var XML : XMLString;
      SL : TStringList;
  begin
    if ZoomStack.Count > 0 then begin
      MessageDlg('Unable to save while zoomed-in.'+CRLF+
                 'Please back up to top level',mtError, [mbOK],0);
      exit;
    end;
    XML := GetXMLRepresentation;
    XML := AddLF2XML(XML);
    SL := TStringList.Create;
    SL.Text := XML;
    SL.SaveToFile(FilePathName);
    SL.Free;
  end;

  procedure TRgnManager.LoadFromFile(FilePathName : string);
  var XML : XMLString;
      SL : TStringList;
  begin
    ClearFloatingTextList;
    SL := TStringList.Create;
    SL.LoadFromFile(FilePathName);
    XML := SL.Text;
    ZoomStack.Clear; //doesn't own objects
    Self.LoadFromXML(XML);
    SL.Free;
  end;

  procedure TRgnManager.Render(MousePos : TPoint; var OrderNum : integer);
  begin
    AdjustMousePos(MousePos);
    ClearBitmap(FBitmap, WallpaperBM);
    if (BitmapWidth = 0) or (BitmapHeight = 0) then begin
      Resize(FBitmap.Height, FBitmap.Width);
    end;
    //NOTE: don't render self, because self is Region Manager (invisible)
    RenderChildren(FBitmap, MousePos, OrderNum);
    if UnzoomBMToBeShown then RenderUnzoomIcon(FBitmap, MousePos);
    //RenderFloatingText(FBitmap);
    Canvas.Draw(DISPLAY_OFFSET.X, DISPLAY_OFFSET.Y, FBitmap); //compensates for lack of clipping at edges during circle drawing.
  end;

  //procedure TRgnManager.AnimateAndRender(MousePos : TPoint);
  procedure TRgnManager.AnimateAndRender;
  begin
    Animate;
    RenderOrder := 0;
    //Render(MousePos, RenderOrder);
    Render(MasterMousePos, RenderOrder);
  end;




end.


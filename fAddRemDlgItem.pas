unit fAddRemDlgItem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Buttons,
  fOneRecEditU, TypesU,
  FMU, TMGStrUtils, ORCtrls;

type
  TfrmAddRemDlgItem = class(TForm)
    pnlTop: TPanel;
    Image1: TImage;
    lblAddItem: TLabel;
    btnStoreEdit: TBitBtn;
    pnlbottom: TPanel;
    btnCancel: TBitBtn;
    btnDone: TBitBtn;
    btnPrev: TBitBtn;
    btnNext: TBitBtn;
    pcWizardPageControl: TPageControl;
    tsElementPos: TTabSheet;
    tsNewOrReuse: TTabSheet;
    rgNewOrReuse: TRadioGroup;
    tsNewElement: TTabSheet;
    Label2: TLabel;
    edtValue: TEdit;
    btnCreateItem: TBitBtn;
    tsPickElement: TTabSheet;
    btnMoveDown: TBitBtn;
    btnMoveUp: TBitBtn;
    Label1: TLabel;
    Label4: TLabel;
    cboItemType: TComboBox;
    Label3: TLabel;
    cboElements: TORComboBox;
    cboClass: TComboBox;
    Label5: TLabel;
    reSiblingPosDisplay: TRichEdit;
    btnCopyItem: TBitBtn;
    Label6: TLabel;
    cboSponsor: TORComboBox;
    btnNextPicStore: TBitBtn;
    procedure tsPickElementHide(Sender: TObject);
    procedure cboSponsorDropDown(Sender: TObject);
    procedure cboSponsorNeedData(Sender: TObject; const StartFrom: string;
      Direction, InsertAt: Integer);
    procedure cboSponsorDblClick(Sender: TObject);
    procedure cboSponsorClick(Sender: TObject);
    procedure cboSponsorChange(Sender: TObject);
    procedure btnMoveDownClick(Sender: TObject);
    procedure btnMoveUpClick(Sender: TObject);
    procedure tsNewOrReuseShow(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tsElementPosShow(Sender: TObject);
    procedure cboElementsClick(Sender: TObject);
    procedure cboElementsChange(Sender: TObject);
    procedure edtValueChange(Sender: TObject);
    procedure cboElementsDblClick(Sender: TObject);
    procedure cboElementsNeedData(Sender: TObject; const StartFrom: string;
                                  Direction, InsertAt: Integer);
    procedure btnPrevClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure tsPickElementShow(Sender: TObject);
    procedure tsNewElementShow(Sender: TObject);
    procedure btnDoneClick(Sender: TObject);
    procedure rgNewOrReuseClick(Sender: TObject);
    procedure btnCreateItemClick(Sender: TObject);
  private
    { Private declarations }
    FRefreshIndicated : boolean;
    FElementIENToUse : string;
    FElementNameToUse : string;
    FSponsorIENToUse : string;
    FElementLinesIndex : integer;
    FAddedComponentIEN : string;
    FPageStack : TList;  //Will hold integers (page indexes)
    FFileMan : TFileman;  //owned here
    FFMFile : TFMFile;    //not owned here
    FFMRecord : TFMFile;    //not owned here
    FDlgComponentsSubfile : TFMFile;    //not owned here
    FParentFMRecord : TFMRecord; //not owned here
    FNextPage : TTabSheet;  //doesn't own object
    FSiblingList : TStringList;
    FCopyElementMode : boolean;
    ElementTypesSet : TStringList;  //not owned here
    FChangingTabVisibility : boolean;
    ElementSiblingPosition : single;
    AddingRootDialog : boolean;
    procedure ShowOnlyPage(Page : TTabSheet);
    procedure SetVisiblePage(Page : TTabSheet);
    procedure SetButtonVisibility;
    procedure SetUpDownButtonVisibility;
    function LastStackEntry : TTabSheet;
    procedure PopStackUntilPage(Page : TTabSheet);
    function Pop1StackPage : TTabSheet;
    procedure AddCurrentPageToPageStack;
    procedure AddToPageStack(Page : TTabSheet);
    procedure DisplayCurrentElementPos;
    procedure DisplayElementPosition(ElementName : string; ElementPos : single; ElementIEN : string);
    function MaxSiblingSeqNum : single;
    function SiblingSeqNum(Index : integer) : single;
    function FormatSeqPos(Num : Single) : string;
    function CheckItemUseInOtherTrees : boolean;
    procedure PrepAllowedItemTypes;
    function DoCopyItem : Integer;
    procedure ReLabelForAddingRootDialog;
  public
    { Public declarations }
    procedure Initialize(ParentIEN : string);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property RefreshIndicated : boolean read FRefreshIndicated;
  end;

implementation

{$R *.dfm}

uses
 rRPCsU, MainU, Math, RichEdit, LogUnit, fCopyRemDlgItem;

const
   REM_DLG_FILE = '801.41';
   //MOVE_UP_DN_MESSAGE = '  <---- Move UP/DN if desired';
   MOVE_UP_DN_MESSAGE = '';
   DEFAULT_SEQ_SPACING = 10;

constructor TfrmAddRemDlgItem.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);

  FFileMan := TFileman.Create;
  FFMFile := nil;
  FFMRecord := nil;
  FChangingTabVisibility := false;

  //pcWizardPageControl.ActivePageIndex := 0;
  ShowOnlyPage(tsNewOrReuse);
  rgNewOrReuse.ItemIndex := 1;  //Default to Reuse prior element.
  FNextPage := tsPickElement;
  FPageStack := TList.Create; //doesn't own anything
  FRefreshIndicated := false;
  FSiblingList := TStringList.Create;
  SetButtonVisibility;  //must be after creation of FSiblingList
  AddCurrentPageToPageStack;
  ElementSiblingPosition := -1;
  FElementLinesIndex := -1;

end;

destructor TfrmAddRemDlgItem.Destroy;
begin
  FPageStack.Free;
  FFileMan.Free;
  FSiblingList.Free;
  Inherited Destroy;
end;

procedure TfrmAddRemDlgItem.edtValueChange(Sender: TObject);
var IsOK : boolean;
begin
  //later could add code to ensure namespaced appropriately.
  IsOK := (Length(edtValue.Text)>2);
  btnCreateItem.Enabled := IsOK;
  if IsOK then begin
    edtValue.Color := clWindow;
  end else begin
    edtValue.Color := clYellow;
  end;
end;

procedure TfrmAddRemDlgItem.FormShow(Sender: TObject);
begin
  MainU.MainForm.InitORComboBox(cboElements,'A');
end;

procedure TfrmAddRemDlgItem.Initialize(ParentIEN : string);
var i : integer;
    IEN, s,SeqNum, Name : string;
begin
  AddingRootDialog := (Pos('+', ParentIEN)>0);
  FFMFile := FFileMan.FMFile[REM_DLG_FILE];
  if not AddingRootDialog then begin
    FParentFMRecord := FFMFile.FMRecord[ParentIEN];
    FDlgComponentsSubfile := FParentFMRecord.FMField['10'].Subfile;
    FDlgComponentsSubfile.GetRecordsList(FSiblingList);
    for i := 0 to FSiblingList.Count - 1 do begin
      s := FSiblingList.Strings[i];
      IEN := piece(s, '=', 1);
      SeqNum := Trim(piece(s, '=', 2));
      while Length(piece(SeqNum,'.',1)) < 4 do SeqNum := '0' + SeqNum;
      Name := FDlgComponentsSubfile.FMRecord[IEN].FMField['2'].Value;
      FSiblingList.Strings[i] := SeqNum + '^' + Name + '^' + IEN;
    end;

    ElementTypesSet := FParentFMRecord.FMField['4'].OptionsOfSet;  //format--> Symbol:Meaning
    cboItemType.Items.Clear;
    cboItemType.ItemIndex := -1;
    cboItemType.Text := '';
    for i := 0 to ElementTypesSet.Count - 1 do begin
      s := ElementTypesSet.Strings[i];
      Name := Uppercase(Piece(s, ':', 2));
      cboItemType.Items.Add(Name);
    end;
  end else begin
    ReLabelForAddingRootDialog;
    cboItemType.Items.Clear;
    cboItemType.Items.Add('reminder dialog');
  end;
  if cboItemType.Items.Count > 0 then cboItemType.ItemIndex := 0;
end;

function TfrmAddRemDlgItem.DoCopyItem : Integer;
var
  frmCopyRemDlgItem: TfrmCopyRemDlgItem;
begin
  Result := mrCancel;
  frmCopyRemDlgItem := TfrmCopyRemDlgItem.Create(Self);
  if frmCopyRemDlgItem.Initialize(FElementIENToUse, FElementNameToUse) then begin
    Result := frmCopyRemDlgItem.ShowModal;
    if Result = mrOK then begin
      FElementIENToUse := frmCopyRemDlgItem.NewlyCopiedItemIEN;
      FElementNameToUse := frmCopyRemDlgItem.NewlyCopiedItemName;
      //btnNextClick(Self);
    end;
  end;
  frmCopyRemDlgItem.Free;
end;

procedure TfrmAddRemDlgItem.ReLabelForAddingRootDialog;
begin
  lblAddItem.Caption := 'Add Reminder Dialog';
end;

procedure TfrmAddRemDlgItem.btnCreateItemClick(Sender: TObject);
var NewRec : TFMRecord; //not owned here.
    Sponsor, ItemType : string;

begin
  if FElementIENToUse = '' then begin
    NewRec := FFMFile.GetScratchRecord;
    NewRec.FMField['.01'].Value := edtValue.text;
    ItemType := Trim(ConvertRemDlgItemTypeName(cboItemType.Text));
    if ItemType <> '' then NewRec.FMField['4'].Value := ItemType;
    Sponsor := cboSponsor.Text;
    if Sponsor <> '' then NewRec.FMField['101'].Value := Sponsor;
    NewRec.FMField['100'].Value := cboClass.Text;
    if NewRec.PostChanges = false then begin
      exit;  //The post shows FM errors itself.
    end;
    FElementIENToUse := piece(NewRec.IENS,',',1);
    FElementNameToUse := edtValue.text;
    btnCreateItem.Caption := '&Edit Details';
    btnCreateItem.Glyph.Assign(btnStoreEdit.Glyph);
    edtValue.Enabled := false;
    //Disable backup up and Cancel button.
    cboItemType.Enabled := false;
    cboClass.Enabled := false;
    btnCancel.Enabled := false;
    FNextPage := tsElementPos;
    FPageStack.Clear;  //prevent backup.
    SetButtonVisibility;
  end else begin
    NewRec := FFMFile.FMRecord[FElementIENToUse];
  end;

  EditOneRecordModal(REM_DLG_FILE, FElementIENToUse+',', true);
  FRefreshIndicated := true;
  NewRec.RefreshFromServer;
  edtValue.Text := NewRec.FMField['.01'].Value;
  FElementNameToUse := edtValue.text;
  cboItemType.Text := NewRec.FMField['4'].Value;
  cboClass.Text := NewRec.FMField['100'].Value
end;


procedure TfrmAddRemDlgItem.btnDoneClick(Sender: TObject);
var NewSubRec : TFMRecord; //not owned here.
    SeqNum : string;
begin
  if AddingRootDialog then begin
    Self.ModalResult := mrOK; //will cause form to close.
    exit;
  end;
  if FElementIENToUse <> '' then begin
    NewSubRec := FDlgComponentsSubfile.GetScratchRecord;
    SeqNum := FormatSeqPos(ElementSiblingPosition);
    NewSubRec.FMField['.01'].Value := SeqNum;
    NewSubRec.FMField['2'].Value := '`'+FElementIENToUse;
    if NewSubRec.PostChanges = false then begin
      exit;  //The post shows FM errors itself.
    end;
    FAddedComponentIEN := NewSubRec.IENS;
    FRefreshIndicated := true;
    Self.ModalResult := mrOK; //will cause form to close.
  end else begin
    MessageDlg('Can''t find item to add!', mtError, [mbOK],0);
  end;
end;

procedure TfrmAddRemDlgItem.btnPrevClick(Sender: TObject);
var Page : TTabSheet;
begin
  if LastStackEntry = nil then exit;
  Page := Pop1StackPage;
  SetVisiblePage(Page);
  SetButtonVisibility;
end;

procedure TfrmAddRemDlgItem.btnNextClick(Sender: TObject);
//var SL : TStringList;
begin
  If FNextPage = nil then exit;
  if (pcWizardPageControl.ActivePage = tsPickElement) then begin
    if FCopyElementMode then begin
      if DoCopyItem <> mrOK then exit;
    end else if CheckItemUseInOtherTrees = false then exit;
  end;
  SetVisiblePage(FNextPage);
  AddCurrentPageToPageStack;
  FNextPage := nil;
  SetButtonVisibility;
end;

function TfrmAddRemDlgItem.CheckItemUseInOtherTrees : boolean;
//Return false if user doesn't want to continue.
var ALogForm: TLogForm;
    SL : TStringList;
    name : string;
    i : integer;
begin
  Result := true;
  SL := TStringList.Create;
  ALogForm := nil;
  try
    rRPCSU.GetRemDialogItemTreeRoots(FElementIENToUse, SL);
    if SL.Count = 0 then exit; //goes to Finally.
    ALogForm := TLogForm.Create(Self);
    ALogForm.Caption := 'Proceed?';
    ALogForm.CancelBtn.Visible := true;
    ALogForm.Memo.ReadOnly := true;
    ALogForm.Memo.Font.Size := 10;
    ALogForm.Memo.Font.Name := 'Arial';
    ALogForm.Memo.Lines.Clear;
    ALogForm.Memo.Color := clBtnFace;
    ALogForm.Memo.ScrollBars := ssVertical;
    With ALogForm.Memo.Lines do begin
      Add('Are you sure you want to use ' + FElementNameToUse + '?');
      Add('');
      Add('Click');
      Add('   [OK] button to continue, or ');
      Add('   [CANCEL] to repick or copy.');
      Add('');
      Add('WARNING: This item is also used in ANOTHER reminder dialog,');
      Add('   and any changes to it will affect *ALL* below!');
      Add('---------------------------------------------------------');
      for i := 0 to SL.Count - 1 do begin
        name := Piece(SL.Strings[i],'^',2);
        if name = '' then continue;
        Add('  Used in: ' + name);
      end;
    end;
    Result := (ALogForm.ShowModal = mrOK);
  finally
    ALogForm.Free;
    SL.Free;
  end;
end;


procedure TfrmAddRemDlgItem.cboElementsChange(Sender: TObject);
begin
  if Length(cboElements.ItemID)>0 then begin
    FElementIENToUse := IntToStr(cboElements.ItemID);
    FElementNameToUse := cboElements.Text;
  end else begin
    FElementIENToUse := '';
    FElementNameToUse := '';
  end;
  btnNext.enabled := FElementIENToUse <> '';
  FNextPage := tsElementPos;
end;

procedure TfrmAddRemDlgItem.cboElementsClick(Sender: TObject);
begin
  cboElementsChange(self);
end;

procedure TfrmAddRemDlgItem.cboSponsorClick(Sender: TObject);
begin
  cboSponsorChange(Self);
end;


procedure TfrmAddRemDlgItem.cboSponsorDblClick(Sender: TObject);
begin
  cboSponsorChange(Self);
end;

procedure TfrmAddRemDlgItem.cboSponsorDropDown(Sender: TObject);
begin
  if cboSponsor.Text = '' then begin
    cboSponsor.InitLongList('A');
  end;
end;

procedure TfrmAddRemDlgItem.cboSponsorNeedData(Sender: TObject;
  const StartFrom: string; Direction, InsertAt: Integer);
var  Result : TStrings;
     FileNum : string;
begin
  FileNum := '811.6';  //REMINDER SPONSOR
  Result := SubsetofFile(FileNum, StartFrom, Direction);
  TORComboBox(Sender).ForDataUse(Result);
end;

procedure TfrmAddRemDlgItem.cboElementsDblClick(Sender: TObject);
begin
  if Length(cboElements.ItemID) > 0 then begin
    cboElementsChange(Self);
    btnNextClick(Self);
  end;
end;

procedure TfrmAddRemDlgItem.cboElementsNeedData(Sender: TObject;
  const StartFrom: string; Direction, InsertAt: Integer);
var  Result : TStrings;
     FileNum : string;
     Scrn    : string;
begin
  if AddingRootDialog then exit;
  FileNum := '801.41';  //REMINDER DIALOG file
  Scrn := '[REMDLG ITEM PARENT:'+FParentFMRecord.IEN+']';
  Result := SubsetofFile(FileNum, StartFrom, Direction,Scrn);
  //ScreenRemDlgData(Result, RemDlgScreenMode);
  TORComboBox(Sender).ForDataUse(Result);
end;

procedure TfrmAddRemDlgItem.cboSponsorChange(Sender: TObject);
begin
  if Length(cboSponsor.ItemID)>0 then begin
    FSponsorIENToUse := IntToStr(cboSponsor.ItemID);
  end else begin
    FSponsorIENToUse := '';
  end;
end;

procedure TfrmAddRemDlgItem.ShowOnlyPage(Page : TTabSheet);
var i : integer;
    OnePage : TTabSheet;
begin
  pcWizardPageControl.ActivePage := Page;
  for i := 0 to pcWizardPageControl.PageCount - 1 do begin
    OnePage := pcWizardPageControl.Pages[i];
    FChangingTabVisibility := true;
    OnePage.TabVisible := (OnePage = Page);
    FChangingTabVisibility := false;
  end;
end;

function TfrmAddRemDlgItem.SiblingSeqNum(Index : integer) : single;
var numStr : string;
    s : string;
begin
  if (Index >= reSiblingPosDisplay.Lines.Count) or (Index < 0) then begin
    Result := 0;
  end else begin
    s  := reSiblingPosDisplay.Lines.Strings[Index];
    NumStr := piece(s,':',1);
    Result := StrToFloatDef(NumStr, 0);
  end;
end;

function TfrmAddRemDlgItem.MaxSiblingSeqNum : single;
var s : string;
begin
  FSiblingList.Sort;
  //Result := SiblingSeqNum(FSiblingList.count-1);
  if FSiblingList.Count = 0 then begin
    Result := DEFAULT_SEQ_SPACING;
  end else begin
    s := FSiblingList.Strings[FSiblingList.count-1];
    Result := StrToFloatDef(Piece(s, '^',1),0);
  end;
end;


function TfrmAddRemDlgItem.FormatSeqPos(Num : Single) : string;
begin
  Result := FormatFloat('0.#', Num);
end;


procedure TfrmAddRemDlgItem.DisplayElementPosition(ElementName : string;
                                                   ElementPos : single; ElementIEN : string);
var PadLen : integer;

  function PadLength(Num : single) : integer;
  var str : string;
  begin
    str := FormatSeqPos(Num);
    Result := length(piece(str, '.',1));
  end;

  function PadToLen(Num : single; PadLen : integer) : string;
  var str : string;
      NumToAdd : integer;
  begin
    Str := FormatSeqPos(Num);
    NumToAdd := PadLen-Length(piece(Str,'.',1));
    while NumToAdd>0 do begin
      Str := '0' + Str;
      Dec(NumToAdd);
    end;
    Result := str;
  end;

  function DisplayLine(ASeqNum : single; Name : string) : string;
  begin
    Result := PadToLen(ASeqNum, PadLen) + ':  ' + Name;
  end;


  procedure InsertAtSeqPos(SeqPos : single; S,IEN : string);

  var i : integer;
      //OneS : string;
      OneSeq : single;
      IntIEN : integer;
      InsertBetween : boolean;
      Format: CHARFORMAT2;
  begin
    InsertBetween := false;
    for i := 0 to reSiblingPosDisplay.Lines.Count - 1 do begin
      //OneS := reSiblingPosDisplay.Lines.Strings[i];
      OneSeq := SiblingSeqNum(i);
      if OneSeq > SeqPos then begin
        InsertBetween := true;
        break;
      end;
    end;
    IntIEN := StrToIntDef(IEN, 0);
    if InsertBetween then begin
      reSiblingPosDisplay.Lines.InsertObject(i, DisplayLine(SeqPos, S), Pointer(IntIEN));
      FElementLinesIndex := i;
    end else begin
      FElementLinesIndex := reSiblingPosDisplay.Lines.AddObject(DisplayLine(SeqPos, S), Pointer(IntIEN));
    end;
    reSiblingPosDisplay.SelStart := reSiblingPosDisplay.Perform(EM_LINEINDEX, FElementLinesIndex, 0);
    reSiblingPosDisplay.SelLength := reSiblingPosDisplay.Perform(EM_LINELENGTH, reSiblingPosDisplay.SelStart, 0);
    reSiblingPosDisplay.SelAttributes.Style := [fsBold];
    reSiblingPosDisplay.SelAttributes.Size := 9;
    //lines below From: http://www.delphipages.com/forum/showthread.php?t=203456
    FillChar(Format, SizeOf(Format), 0);
    Format.cbSize := SizeOf(Format);
    Format.dwMask := CFM_BACKCOLOR;
    Format.crBackColor := clYellow;
    reSiblingPosDisplay.Perform(EM_SETCHARFORMAT, SCF_SELECTION, Longint(@Format));
  end;

  var i : integer;
      IEN : longword;
      Name, s : string;
      ASeqNum, MaxSeqNum : single;

begin {DisplayElementPosition}
  //NOTE: position is allowed, by database, to only have 1 digit after the decimal.
  reSiblingPosDisplay.Lines.Clear;
  MaxSeqNum := MaxSiblingSeqNum;  //will sort FSiblingList;
  PadLen := PadLength(MaxSeqNum);
  for i := 0 to FSiblingList.Count - 1 do begin  //format: SeqNum + '^' + Name + '^' + IEN;
    s := FSiblingList.Strings[i];
    ASeqNum := StrToFloatDef(Piece(s, '^',1),-99);
    IEN := StrToIntDef(Piece(s, '^',3), 0);
    Name := Piece(s, '^',2);
    reSiblingPosDisplay.Lines.AddObject(DisplayLine(ASeqNum, Name), Pointer(IEN));
  end;
  InsertAtSeqPos(ElementPos, ElementName + MOVE_UP_DN_MESSAGE,  ElementIEN);
  SetUpDownButtonVisibility;
end;

procedure TfrmAddRemDlgItem.DisplayCurrentElementPos;
begin
  DisplayElementPosition(FElementNameToUse, ElementSiblingPosition, FElementIENToUse);
end;

procedure TfrmAddRemDlgItem.tsElementPosShow(Sender: TObject);
begin
  ElementSiblingPosition := MaxSiblingSeqNum + DEFAULT_SEQ_SPACING;
  DisplayCurrentElementPos;
  //btnDone.Visible := true;
  //btnDone.Enabled := true;
end;

procedure TfrmAddRemDlgItem.btnMoveUpClick(Sender: TObject);
var BeforeSeq, AfterSeq, Diff, NewSeq : single;
begin
  //Move position up
  if reSiblingPosDisplay.Lines.Count < 2 then exit;
  if FElementLinesIndex = 0 then exit;
  BeforeSeq := SiblingSeqNum(FElementLinesIndex -2);
  AfterSeq  := SiblingSeqNum(FElementLinesIndex -1);
  if AfterSeq = 0 then AfterSeq := MaxSiblingSeqNum;
  Diff := AfterSeq - BeforeSeq;
  if Diff <= 0.1 then begin
    raise Exception.Create('Unable to fit element between '+FormatSeqPos(BeforeSeq) +
                           ' and ' + formatSeqPos(AfterSeq) + '.');
  end;
  NewSeq := BeforeSeq + Diff/2;
  if FormatSeqPos(NewSeq) = FormatSeqPos(BeforeSeq) then NewSeq := NewSeq + 0.1;
  ElementSiblingPosition := NewSeq;
  DisplayCurrentElementPos;
end;

procedure TfrmAddRemDlgItem.btnMoveDownClick(Sender: TObject);
var BeforeSeq, AfterSeq, Diff, NewSeq : single;
begin
  //Move position down.
//  function TfrmAddRemDlgItem.SiblingSeqNum(Index : integer) : single;
  if reSiblingPosDisplay.Lines.Count < 2 then exit;
  if FElementLinesIndex = reSiblingPosDisplay.Lines.Count - 1 then exit;
  BeforeSeq := SiblingSeqNum(FElementLinesIndex +1);
  AfterSeq  := SiblingSeqNum(FElementLinesIndex +2);
  if AfterSeq = 0 then begin
    AfterSeq := MaxSiblingSeqNum;
    if FormatSeqPos(AfterSeq) = FormatSeqPos(BeforeSeq) then AfterSeq := AfterSeq + DEFAULT_SEQ_SPACING*2;
  end;
  Diff := AfterSeq - BeforeSeq;
  if Diff <= 0.1 then begin
    raise Exception.Create('Unable to fit element between '+FormatSeqPos(BeforeSeq) +
                           ' and ' + formatSeqPos(AfterSeq) + '.');
  end;
  NewSeq := BeforeSeq + Diff/2;
  if FormatSeqPos(NewSeq) = FormatSeqPos(BeforeSeq) then NewSeq := NewSeq + 0.1;
  ElementSiblingPosition := NewSeq;
  DisplayCurrentElementPos;
end;

procedure TfrmAddRemDlgItem.PrepAllowedItemTypes;
var ParentType : TRemDlgElementType;
    Name, AllowedTypes : string;
    i : integer;

begin
  if AddingRootDialog then exit;
  //Set possible types that can be added, based on parent.
  ParentType := ConvertRemDlgItemTypeTag(FParentFMRecord.FMField['4'].Value);
  case ParentType of  //All possibilities: 'PERFGST'
    detPrompt {P}         : AllowedTypes := 'PEFG';
    detDialogElement {E}  : AllowedTypes := 'PF';
    detReminderdialog {R} : AllowedTypes := 'EG';
    detForcedValue {F}    : AllowedTypes := 'PEFG';
    detDialogGroup {G}    : AllowedTypes := 'PERFGST';
    detResultGroup {S}    : AllowedTypes := 'T';
    detResultElement {T}  : AllowedTypes := 'PEFG';
  end;
  cboItemType.Items.Clear;
  for i := 1 to length(AllowedTypes) do begin
    Name := GetRemDelItemTypeName(AllowedTypes[i]);
    if Name = '' then continue;
    cboItemType.Items.Add(Name);
  end;
  if cboItemType.Items.Count > 0 then begin
    cboItemType.ItemIndex := 0;
    cboItemType.Text := cboItemType.Items.Strings[0];
  end;
end;


procedure TfrmAddRemDlgItem.tsNewElementShow(Sender: TObject);
begin
  FNextPage := tsElementPos;
  FElementIENToUse := '';
  SetButtonVisibility;
  btnDone.Enabled := false;
  PrepAllowedItemTypes;
end;

procedure TfrmAddRemDlgItem.tsNewOrReuseShow(Sender: TObject);
begin
  case rgNewOrReuse.ItemIndex of
    0 : FNextPage := tsNewElement;
    1 : FNextPage := tsPickElement;
  end;
end;

procedure TfrmAddRemDlgItem.tsPickElementHide(Sender: TObject);
begin
  btnNext.Glyph.Assign(btnNextPicStore.Glyph);
  btnNext.Caption := '&Next';
end;

procedure TfrmAddRemDlgItem.tsPickElementShow(Sender: TObject);
begin
  FNextPage := tsElementPos;
  SetButtonVisibility;
  btnDone.Enabled := false;
  if FCopyElementMode then begin
    btnNext.Glyph.Assign(btnCopyItem.Glyph);
    btnNext.Caption := 'Co&py';
  end else begin
    btnNext.Glyph.Assign(btnNextPicStore.Glyph);
    btnNext.Caption := '&Next';
  end;
  cboElements.SetFocus;
end;

procedure TfrmAddRemDlgItem.SetVisiblePage(Page : TTabSheet);
begin
  ShowOnlyPage(Page);
end;


procedure TfrmAddRemDlgItem.SetButtonVisibility;
begin
  if (AddingRootDialog) and (pcWizardPageControl.ActivePage <> tsNewOrReuse) then begin
    btnPrev.enabled := true;
    btnNext.enabled := false;
    btnDone.visible := true;
    //btnDone.enabled := (btnCreateItem.enabled = false);
    btnDone.enabled := (FNextPage <> nil);
  end else begin
    btnPrev.Enabled := (FPageStack.Count > 1);
    btnNext.Enabled := (FNextPage <> nil);
    btnDone.Visible := (pcWizardPageControl.ActivePage = tsElementPos);
    btnDone.Enabled := btnDone.Visible;
  end;
end;

procedure TfrmAddRemDlgItem.SetUpDownButtonVisibility;
begin
  btnMoveUp.Enabled := (FElementLinesIndex > 0);
  btnMoveDown.Enabled := (FElementLinesIndex  < reSiblingPosDisplay.Lines.Count - 1);
end;


function TfrmAddRemDlgItem.LastStackEntry : TTabSheet;
begin
  Result := nil;
  if FPageStack.Count = 0 then exit;
  Result := TTabSheet(FPageStack[FPageStack.Count-1]);
end;


procedure TfrmAddRemDlgItem.PopStackUntilPage(Page : TTabSheet);
begin
  while (FPageStack.Count>0) do begin
    if LastStackEntry = Page then break;
    FPageStack.Delete(FPageStack.Count-1);
  end;
end;

procedure TfrmAddRemDlgItem.rgNewOrReuseClick(Sender: TObject);
begin
  case rgNewOrReuse.ItemIndex of
    0   : FNextPage := tsNewElement;
    1,2 : FNextPage := tsPickElement;
  end;
  FCopyElementMode := (rgNewOrReuse.ItemIndex=1);
end;

function TfrmAddRemDlgItem.Pop1StackPage : TTabSheet;
//Pop last entry off, and return result.
begin
  Result := nil;
  if FPageStack.Count=0 then exit;
  FPageStack.Delete(FPageStack.Count-1);
  Result := LastStackEntry;
  //moved the delete up a line, so the last entry points to the 'next to last' 
end;

procedure TfrmAddRemDlgItem.AddToPageStack(Page : TTabSheet);
begin
  FPageStack.Add(Page);
end;

procedure TfrmAddRemDlgItem.AddCurrentPageToPageStack;
var Page : TTabSheet;
begin
  Page := pcWizardPageControl.ActivePage;
  if LastStackEntry = Page then exit;
  AddToPageStack(Page);
end;



end.

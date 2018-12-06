unit fAddRemFinding;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, ComCtrls, OrFn,
  GlobalsU, fMultiRecEditU, TypesU, FMU;

type
  TAddFindingType = (aftNone, aftFinding, aftFuncFinding, aftAge, aftSubGroup);

  TfrmAddRemFinding = class(TForm)
    pnlbottom: TPanel;
    pnlTop: TPanel;
    Image1: TImage;
    lblAddItem: TLabel;
    pcWizardPageControl: TPageControl;
    tsStep1: TTabSheet;
    tsNewOrReuse: TTabSheet;
    btnCancel: TBitBtn;
    btnDone: TBitBtn;
    btnPrev: TBitBtn;
    btnNext: TBitBtn;
    rgTypeToAdd: TRadioGroup;
    rgNewOrReuse: TRadioGroup;
    tsNewFinding: TTabSheet;
    tsPickFinding: TTabSheet;
    edtValue: TEdit;
    Label2: TLabel;
    btnCreateItem: TBitBtn;
    cboMode: TComboBox;
    Label6: TLabel;
    tsNewFuncFinding: TTabSheet;
    edtFindingNumber: TEdit;
    Label1: TLabel;
    Label3: TLabel;
    cboFuncMode: TComboBox;
    btnCreateFuncItem: TBitBtn;
    btnStoreEdit: TBitBtn;
    Label4: TLabel;
    tsAddAge: TTabSheet;
    btnCreateAgeItem: TBitBtn;
    Label5: TLabel;
    procedure btnCreateAgeItemClick(Sender: TObject);
    procedure tsStep1Show(Sender: TObject);
    procedure tsNewFuncFindingShow(Sender: TObject);
    procedure btnCreateFuncItemClick(Sender: TObject);
    procedure edtFindingNumberChange(Sender: TObject);
    procedure tsNewOrReuseShow(Sender: TObject);
    procedure btnCreateItemClick(Sender: TObject);
    procedure edtValueChange(Sender: TObject);
    procedure tsNewFindingShow(Sender: TObject);
    procedure edtValueClick(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure rgNewOrReuseClick(Sender: TObject);
    procedure rgTypeToAddClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FPageStack : TList;  //Will hold integers (page indexes)
    FReminderGridInfo : TGridInfo;  //Won't own object.
    FMode : TAddFindingType;
    FNextPage : TTabSheet;  //doesn't own object
    ReusePrior : boolean;
    FVennDisplayMode : TDisplayVMode;
    FFileMan : TFileman;  //owned here
    FFMFile : TFMFile;    //not owned here
    FFindingsSubfile: TFMFile;      //not owned here
    FFuncFindingsSubfile : TFMFile; //not owned here
    FFMRecord : TFMRecord; //not owned here
    FRefreshIndicated : boolean;
    FChangingTabVisibility : boolean;
    FAddedFindingFileNumber : string;
    FAddedFuncFindingFileNumber : string;
    FAddedFindingIENS : string;
    FAddedFuncFindingIENS : string;
    FAddedFindingItem : string;
    FAddedFuncFindingItem : string;
    FExistingFindings : TStringList;
    FExistingFuncFindings : TStringList;
    FAgeFindingAdded : boolean;
    procedure SetButtonVisibility;
    procedure PopStackUntilPage(Page : TTabSheet);
    function Pop1StackPage : TTabSheet;
    procedure AddToPageStack(Page : TTabSheet);
    procedure AddCurrentPageToPageStack;
    procedure ClearFuturePageStackEntries;
    function LastStackEntry : TTabSheet;
    procedure SetMode(Mode : TAddFindingType);
    procedure ShowOnlyPage(Page : TTabSheet);
    procedure SetVisiblePage(Page : TTabSheet);
  public
    { Public declarations }
    procedure Initialize(FileNum, IENS : string; VennDisplayMode : TDisplayVMode);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property RefreshIndicated : boolean read FRefreshIndicated;
  end;

//var
//  frmAddRemFinding: TfrmAddRemFinding;

implementation

{$R *.dfm}

uses
  fOneRecEditU, LookupU, MainU, Rem2VennU;

const
  NUM_WIZARD_PAGES = 2;
  LOGIC_CONVERSION : array[-1..3] of string[4] = ('', '!', '&', '&''','');

constructor TfrmAddRemFinding.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);

  FFileMan := TFileman.Create;
  FFMFile := nil;
  FFMRecord := nil;

  pcWizardPageControl.ActivePageIndex := 0;
  FNextPage := nil;
  FPageStack := TList.Create; //doesn't own anything

  FAddedFindingFileNumber := '';
  FAddedFindingIENS := '';
  FAddedFuncFindingFileNumber := '';
  FAddedFuncFindingIENS := '';
  FAgeFindingAdded := false;

  FRefreshIndicated := false;
  FChangingTabVisibility := false;
  FExistingFuncFindings := TStringList.Create;

  AddCurrentPageToPageStack;
end;

procedure TfrmAddRemFinding.Initialize(FileNum, IENS : string;
                                       VennDisplayMode : TDisplayVMode);
var Title : string;
    FindingListStr : string;
begin
  FVennDisplayMode := VennDisplayMode;

  FFMFile := FFileMan.FMFile[FileNum];
  FFMRecord := FFMFile.FMRecord[IENS];
  FFindingsSubfile := FFMRecord.FMField['20'].Subfile;
  FFuncFindingsSubfile := FFMRecord.FMField['25'].Subfile;

  Title := 'Add ';
  case FVennDisplayMode of
    dvmResolution : begin
      Title := Title + 'Resolution ';
      cboMode.ItemIndex := 0;  //OR
      cboFuncMode.ItemIndex := 0;  //OR
    end;
    dvmCohort     : begin
      Title := Title + 'Cohort ';
      FindingListStr := FFMRecord.FMField['33'].Value; //33=PATIENT COHORT FINDING LIST
      if Pos('AGE',FindingListStr)=0 then begin
        rgTypeToAdd.Items.Add('Age Specification Finding');
      end;
      cboMode.ItemIndex := 1;  //AND
      cboFuncMode.ItemIndex := 1;  //AND
    end;
    dvmUtility     : begin
      Title := Title + 'Utility ';
      cboMode.ItemIndex := -1;  //null
      cboFuncMode.ItemIndex := -1;  //null
      cboMode.Visible := false;
      cboFuncMode.Visible := false;
    end;
  end; {case}
  Title := Title + 'Finding or Item';
  lblAddItem.Caption := Title;

  FFindingsSubfile.GetRecordsList(FExistingFindings);
  FFuncFindingsSubfile.GetRecordsList(FExistingFuncFindings);
end;


destructor TfrmAddRemFinding.Destroy;
begin
  FPageStack.Free;
  FFileMan.Free;
  FExistingFuncFindings.Free;
  Inherited Destroy;
end;

procedure TfrmAddRemFinding.FormShow(Sender: TObject);
begin
  SetVisiblePage(tsStep1);
  FPageStack.Clear;
  AddCurrentPageToPageStack;
  rgTypeToAddClick(Self);
end;

procedure TfrmAddRemFinding.edtFindingNumberChange(Sender: TObject);
var IsOK : boolean;
    CurValue : string;
begin
  IsOK := true;
  CurValue := edtFindingNumber.Text;
  if (StrToIntDef(CurValue, -99) = -99)
  or (FExistingFuncFindings.Values[CurValue] <>'') then begin
    IsOK := False;
  end;
  btnCreateFuncItem.Enabled := IsOK;
  if IsOK then begin
    edtFindingNumber.Color := clWindow;
  end else begin
    edtFindingNumber.Color := clYellow;
  end;

end;

procedure TfrmAddRemFinding.edtValueChange(Sender: TObject);
begin
  btnCreateItem.Enabled := (edtValue.Text <> '');
end;



procedure TfrmAddRemFinding.edtValueClick(Sender: TObject);
var
  VarPtrInfo : TStringList;
  tempVarPtrInfo : TStringList;
  FieldLookupForm : TFieldLookupForm;
  GridInfo : TGridInfo;
  Pt : TPoint;
  FMField : TFMField;
  FMRecord : TFMRecord;
  ContainingFileNum, ContainingFieldNum : string;

begin
  FMRecord := FFindingsSubfile.GetScratchRecord;
  FMField := FMRecord.FMField['.01'];
  VarPtrInfo := FMField.OptionsOfVarPtr;
  ContainingFileNum := FFindingsSubfile.FileNumber;
  ContainingFieldNum := '.01';

  FieldLookupForm:= TFieldLookupForm.Create(Nil);
  FieldLookupForm.PrepFormAsMultFile(VarPtrInfo, edtValue.Text, ContainingFileNum, ContainingFieldNum);
  FieldLookupForm.Auto_Press_Edit_Button := False;
  FieldLookupForm.Suppress_Positioning_Form_To_Mouse := true;
  Pt.X := edtValue.Left;
  Pt.Y := edtValue.Top + edtValue.Height + 5;
  Pt := tsNewFinding.ClientToScreen(Pt);
  FieldLookupForm.Left := Pt.X;
  FieldLookupForm.Top  := Pt.Y;

  //VarPtrInfo.Free;

  if FieldLookupForm.ShowModal = mrOK then begin
    edtValue.Text := FieldLookupForm.SelectedValue;
  end;
  FreeAndNil(FieldLookupForm);
end;

procedure TfrmAddRemFinding.SetMode(Mode : TAddFindingType);
var SubfileNum : string;
    IENS : string;
begin
  if Mode = FMode then exit;
  FMode := Mode;
end;

procedure TfrmAddRemFinding.SetButtonVisibility;
begin
  btnPrev.Enabled := (FPageStack.Count > 0);
  btnNext.Enabled := (FNextPage <> nil);
end;

function TfrmAddRemFinding.LastStackEntry : TTabSheet;
begin
  Result := nil;
  if FPageStack.Count = 0 then exit;
  Result :=TTabSheet(FPageStack[FPageStack.Count-1]);
end;


procedure TfrmAddRemFinding.PopStackUntilPage(Page : TTabSheet);
begin
  while (FPageStack.Count>0) do begin
    if LastStackEntry = Page then break;
    FPageStack.Delete(FPageStack.Count-1);
  end;
end;

function TfrmAddRemFinding.Pop1StackPage : TTabSheet;
//Pop last entry off, and return result.
begin
  Result := nil;
  if FPageStack.Count=0 then exit;
  FPageStack.Delete(FPageStack.Count-1);
  Result := LastStackEntry;
end;


procedure TfrmAddRemFinding.ShowOnlyPage(Page : TTabSheet);
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

procedure TfrmAddRemFinding.tsNewFindingShow(Sender: TObject);
begin
  if FChangingTabVisibility then exit;
  edtValueClick(Self);
end;

procedure TfrmAddRemFinding.tsNewFuncFindingShow(Sender: TObject);
var i : integer;
begin
  //suggest next available number for function.
  if edtFindingNumber.Text <> '' then exit;
  i := 1;
  while FExistingFuncFindings.Values[IntToStr(i)] <> '' do inc (i);
  edtFindingNumber.Text := IntToStr(i);
end;

procedure TfrmAddRemFinding.tsNewOrReuseShow(Sender: TObject);
begin
  rgNewOrReuseClick(Sender);
end;

procedure TfrmAddRemFinding.tsStep1Show(Sender: TObject);
begin
  rgTypeToAddClick(sender);
end;

procedure TfrmAddRemFinding.SetVisiblePage(Page : TTabSheet);
begin
  ShowOnlyPage(Page);
end;


procedure TfrmAddRemFinding.btnCreateAgeItemClick(Sender: TObject);
var  InternalCohortLogic, FindingsListStr, FindingCount : string;
     Count : integer;
begin
  if FAgeFindingAdded = false then begin
    //31=INTERNAL PATIENT COHORT LOGIC
    InternalCohortLogic := FFMRecord.FMField['31'].Value;
    if Pos('(AGE)', InternalCohortLogic) = 0 then begin
      InternalCohortLogic := '(AGE)&' + InternalCohortLogic;
      FFMRecord.FMField['31'].Value := InternalCohortLogic;
    end;
    //33=PATIENT COHORT FINDING LIST
    FindingsListStr := FFMRecord.FMField['33'].Value;
    if Pos('AGE;', FindingsListStr)=0 then begin
      FindingsListStr := 'AGE;' + FindingsListStr;
      FFMRecord.FMField['33'].Value := FindingsListStr;
      //32=PATIENT COHORT FINDING COUNT
      FindingCount := FFMRecord.FMField['32'].Value;
      Count := StrToIntDef(FindingCount,0) + 1;
      FFMRecord.FMField['32'].Value := IntToStr(Count);
    end;
    if not FFMRecord.PostChanges then exit;
    FAgeFindingAdded := true;
    btnCreateAgeItem.Caption := '&Edit Details';
    btnCreateAgeItem.Glyph.Assign(btnStoreEdit.Glyph);
    //Disable backup up and Cancel button.
    btnPrev.Enabled := false;
    btnDone.Visible := true;
    btnCancel.Enabled := false;
  end;
  HandleAgeDetailClick;  //launch edit of age items.....
  FRefreshIndicated := true;
end;

procedure TfrmAddRemFinding.btnCreateFuncItemClick(Sender: TObject);
  //Here I create and then edit function item.
var NewSubRec : TFMRecord; //not owned here.
    IEN, IENS : string;
    LogicFld, Logic : string;
    FMField : TFMField;   //not owned here.
    SubRecord : TFMRecord; //not owned here.
    tempGridInfo : TGridInfo;

begin
  case FVennDisplayMode of
    dvmCohort     : LogicFld := '12';
    dvmResolution : LogicFld := '11';
    dvmUtility    : LogicFld := '';
  end; {case}
  if FAddedFuncFindingIENS = '' then begin
    NewSubRec := FFuncFindingsSubfile.GetScratchRecord;
    NewSubRec.FMField['.01'].Value := edtFindingNumber.text;
    Logic := LOGIC_CONVERSION[cboFuncMode.ItemIndex];
    if (LogicFld <> '') and (Logic <> '') then NewSubRec.FMField[LogicFld].Value := Logic;
    if NewSubRec.PostChanges = false then begin
      exit;  //The post shows FM errors itself.
    end;
    FAddedFuncFindingFileNumber := FFuncFindingsSubfile.FileNumber;
    FAddedFuncFindingIENS := NewSubRec.IENS;
    btnCreateFuncItem.Caption := '&Edit Details';
    btnCreateFuncItem.Glyph.Assign(btnStoreEdit.Glyph);
    edtFindingNumber.Enabled := false;
    //Disable backup up and Cancel button.
    cboFuncMode.Enabled := false;
    btnPrev.Enabled := false;
    btnDone.Visible := true;
    btnCancel.Enabled := false;
  end else begin
    NewSubRec := FFuncFindingsSubfile.FMRecord[FAddedFuncFindingIENS];
  end;

  tempGridInfo := TGridInfo.Create;
  tempGridInfo.FileNum := FAddedFuncFindingFileNumber;
  tempGridInfo.IENS := FAddedFuncFindingIENS;
  tempGridInfo.FreeTextFieldEditor := Rem2VennU.HandleTextEdit;

  EditOneRecordModal(tempGridInfo, true);
  //EditOneRecordModal(FAddedFuncFindingFileNumber, FAddedFuncFindingIENS, true);
  tempGridInfo.Free;

  FRefreshIndicated := true;
  IEN := Piece(NewSubRec.IENS, ',',1);
  SubRecord := FFuncFindingsSubfile.FMRecord[IEN];
  SubRecord.RefreshFromServer;
  edtFindingNumber.Text := SubRecord.FMField['.01'].Value;
  cboFuncMode.Text := SubRecord.FMField[LogicFld].Value;
end;

procedure TfrmAddRemFinding.btnCreateItemClick(Sender: TObject);
var NewSubRec : TFMRecord; //not owned here.
    IEN, IENS : string;
    LogicFld, Logic : string;
    FMField : TFMField;   //not owned here.
    SubRecord : TFMRecord; //not owned here.
    AGridInfo : TGridInfo; //owned here
    Prefix : string;
    i : integer;

begin
  case FVennDisplayMode of
    dvmCohort     : LogicFld := '8';  //'12'
    dvmResolution : LogicFld := '7';  //'11'
    dvmUtility    : LogicFld := '';
  end; {case}
  if FAddedFindingIENS = '' then begin
    NewSubRec := FFindingsSubfile.GetScratchRecord;
    NewSubRec.FMField['.01'].Value := edtValue.text;
    FAddedFindingItem := edtValue.text;
    Logic := LOGIC_CONVERSION[cboMode.ItemIndex];
    if (LogicFld <> '') and (Logic <> '') then NewSubRec.FMField[LogicFld].Value := Logic;
    if NewSubRec.PostChanges = false then begin
      exit;  //The post shows FM errors itself.
    end;
    FAddedFindingFileNumber := FFindingsSubfile.FileNumber;
    FAddedFindingIENS := NewSubRec.IENS;
    btnCreateItem.Caption := '&Edit Details';
    btnCreateItem.Glyph.Assign(btnStoreEdit.Glyph);
    edtValue.Enabled := false;
    //Disable backup up and Cancel button.
    cboMode.Enabled := false;
    btnPrev.Enabled := false;
    btnDone.Visible := true;
    btnCancel.Enabled := false;
  end else begin
    NewSubRec := FFindingsSubfile.FMRecord[FAddedFindingIENS];
  end;

  AGridInfo := TGridInfo.Create;  //won't own anything.
  AGridInfo.FileNum := FAddedFindingFileNumber;
  AGridInfo.IENS := FAddedFindingIENS;
  Prefix := piece (FAddedFindingItem, '.', 1);
  if Prefix <> '' then begin
    i := MainForm.RemFindingsTemplatesList.IndexOf(Prefix);
    if i > -1 then AGridInfo.BasicTemplate := TStringList(MainForm.RemFindingsTemplatesList.Objects[i]);
  end;
  //EditOneRecordModal(FAddedFindingFileNumber, FAddedFindingIENS, true);
  EditOneRecordModal(AGridInfo, true);
  AGridInfo.Free;
  FRefreshIndicated := true;
  IEN := Piece(NewSubRec.IENS, ',',1);
  SubRecord := FFindingsSubfile.FMRecord[IEN];
  SubRecord.RefreshFromServer;
  edtValue.Text := SubRecord.FMField['.01'].Value;
  FAddedFindingItem := edtValue.Text;
  cboMode.Text := SubRecord.FMField[LogicFld].Value;
end;

procedure TfrmAddRemFinding.btnNextClick(Sender: TObject);
var
   SavedNextPage : TTabsheet;
begin
  If FNextPage = nil then exit;
  SavedNextPage := FNextPage;
  SetVisiblePage(FNextPage);
  AddCurrentPageToPageStack;
  if SavedNextPage = FNextPage then FNextPage := nil;
  SetButtonVisibility;
end;

procedure TfrmAddRemFinding.btnPrevClick(Sender: TObject);
var Page : TTabSheet;
begin
  if LastStackEntry = nil then exit;
  Page := Pop1StackPage;
  SetVisiblePage(Page);
  SetButtonVisibility;
end;

procedure TfrmAddRemFinding.ClearFuturePageStackEntries;
begin
  PopStackUntilPage(pcWizardPageControl.ActivePage);
end;


procedure TfrmAddRemFinding.AddToPageStack(Page : TTabSheet);
begin
  FPageStack.Add(Page);
end;

procedure TfrmAddRemFinding.AddCurrentPageToPageStack;
var Page : TTabSheet;
begin
  Page := pcWizardPageControl.ActivePage;
  if LastStackEntry = Page then exit;
  AddToPageStack(Page);
end;


procedure TfrmAddRemFinding.rgNewOrReuseClick(Sender: TObject);
begin
  ReusePrior := (rgNewOrReuse.ItemIndex = 1);
  FNextPage := nil;
  Case FMode of
    aftFinding :     begin
                       if ReusePrior then begin
                         //Here I need to compare the list of all findings with list of findings used
                         //and determine if any are avail for picking.  If not, then show message
                         FNextPage := tsPickFinding
                       end else FNextPage := tsNewFinding;
                     end;
    aftFuncFinding : begin
                       if ReusePrior then begin
                         FNextPage := nil    //FINISH
                       end else FNextPage := tsNewFuncFinding;
                     end;
  end; //case
  SetButtonVisibility;
end;

procedure TfrmAddRemFinding.rgTypeToAddClick(Sender: TObject);
const
  RG_MAP : array [-1..3] of TAddFindingType = (aftNone,
                                               aftFinding,
                                               aftFuncFinding,
                                               aftAge,
                                               aftSubGroup);
begin
  ClearFuturePageStackEntries;
  SetMode(RG_MAP[rgTypeToAdd.ItemIndex]);
  Case FMode of
    aftNone :        FNextPage := nil;
    aftFinding :     FNextPage := tsNewOrReuse;
    aftFuncFinding : FNextPage := tsNewOrReuse;
    aftAge:          FNextPage := tsAddAge;  
    aftSubGroup:     FNextPage := nil;  //FINISH
  end; //case
  SetButtonVisibility;

end;




end.

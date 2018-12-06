unit fFindingDetail;
//NOTE: Handles Function Findings, and plain Findings, and other reminder stuff

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  frmVennU, VennObject, TypesU, UtilU, ReminderObjU,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TFindingDetailForm = class(TForm)
    pnlBottom: TPanel;
    RevertBtn: TBitBtn;
    ApplyBtn: TBitBtn;
    DoneBtn: TBitBtn;
    pnlVennDisplay: TPanel;
    btnDetails: TBitBtn;
    procedure btnDetailsClick(Sender: TObject);
    procedure pnlVennDisplayResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure HandleSelectionChange(RemObject : TRemObj);
    procedure HandleRemDefRemObjectRtClick(RemObject : TRemObj);
    procedure HandleRemObjectDblClick(RemObject : TRemObj);
    function HandleFindings(GridInfo : TGridInfo) : boolean;
    function HandleFunctionFindings(GridInfo : TGridInfo) : boolean;
    function HandleTerms(GridInfo : TGridInfo) : boolean;
    function AutoEditClickField(GridInfo : TGridInfo;  FieldNum : string) : boolean;
  public
    { Public declarations }
    VennForm : TVennForm;
    function Initialize(GridInfo : TGridInfo) : boolean;
  end;

implementation

{$R *.dfm}

  uses ORFn, Rem2VennU, MainU, LookupU, FMU, rRPCsU;

  procedure TFindingDetailForm.btnDetailsClick(Sender: TObject);
  begin
    VennForm.btnDetailsClick(Sender);
  end;

  procedure TFindingDetailForm.FormCreate(Sender: TObject);
  begin
    VennForm := TVennForm.Create(Self);
    VennForm.cboMode.Visible := false;
    VennForm.btnDetails.Visible := false;
    VennForm.Running := true;
    VennForm.ParentWindow := pnlVennDisplay.Handle;
    VennForm.Top := 0;
    VennForm.Left := 100;
    VennForm.Show;
    VennForm.Visible := true;
    pnlVennDisplayResize(Sender);
    VennForm.RgnMgr.OnSelChange := HandleSelectionChange;
    VennForm.RgnMgr.OnRtClickRemObject := HandleRemDefRemObjectRtClick;
    VennForm.RgnMgr.OnDblClickRemObject := HandleRemObjectDblClick;
    VennForm.btnTestReminder.Visible := false;
    VennForm.btnAddVennObj.Visible := false;
    VennForm.btnDelItem.Visible := false;
  end;

  procedure TFindingDetailForm.FormDestroy(Sender: TObject);
  begin
    VennForm.Free;
  end;

  procedure TFindingDetailForm.HandleSelectionChange(RemObject : TRemObj);
  var Enabled : boolean;
  begin
    Enabled := Assigned(RemObject) and
    ((RemObject.Children.Count > 0) or (Assigned(RemObject.GridInfo)));
    btnDetails.Enabled := Enabled;
  end;

  procedure TFindingDetailForm.HandleRemDefRemObjectRtClick(RemObject : TRemObj);
  begin
   if (RemObject.Children.Count > 0) then begin
      VennForm.RgnMgr.ZoomIntoSelected;
      exit;
    end;
  end;

  procedure TFindingDetailForm.HandleRemObjectDblClick(RemObject : TRemObj);
  begin
    if btnDetails.Enabled then btnDetailsClick(RemObject);
  end;


  procedure TFindingDetailForm.pnlVennDisplayResize(Sender: TObject);
  begin
    VennForm.Width := pnlVennDisplay.Width + 5;
    VennForm.Height := pnlVennDisplay.Height;
    //VennForm.RgnMgr.Resize(VennForm.Height-BOTTOM_SPACING, VennForm.Width);
    VennForm.RgnMgr.Resize(VennForm.Height, VennForm.Width);
    VennForm.RgnMgr.AutoArrangeChildrenForFormulaDisplay;
  end;



  function TFindingDetailForm.AutoEditClickField(GridInfo : TGridInfo;  FieldNum : string) : boolean;
  //Returns TRUE if should show form, or FALSE if show form.
  var
    VarPtrInfo : TStringList;
    FieldLookupForm : TFieldLookupForm;
    idx : integer;
    Value : string;

  begin
    VarPtrInfo := TStringList.Create;
    ExtractVarPtrInfo(VarPtrInfo, GridInfo.Data, GridInfo.FileNum, FieldNum);
    idx := FindInStrings(FieldNum, GridInfo.Data, GridInfo.FileNum);
    if idx >=0 then begin
      Value := GridInfo.Data.Strings[idx];
      Value := Piece(Value, '^',4);
      FieldLookupForm:= TFieldLookupForm.Create(Self);
      FieldLookupForm.PrepFormAsMultFile(VarPtrInfo, Value, GridInfo.FileNum, FieldNum);
      FieldLookupForm.EditBtnClick(Self);
      FieldLookupForm.Free;
    end;
    VarPtrInfo.Free;
    Result := false;
  end;

  function TFindingDetailForm.HandleFindings(GridInfo : TGridInfo) : boolean;
  //File = REMINDER DEFINITION:FINDINGS (811.902)
  begin
    Result := AutoEditClickField(GridInfo, '.01');
  end;

  function TFindingDetailForm.HandleTerms(GridInfo : TGridInfo) : boolean;
  //File = REMINDER TERM:FINDINGS (811.52)
  //Parentfile = 811.5 REMINDER TERM
  var
    LogicStr : string;
    SubRecsSL : TStringList;
    s, FindingsUsed : string;
    ParentIEN, IEN : string;
    i : integer;
    FileMan : TFileMan;
    OneReminderTerm : TFMRecord;  //not owned here
    FMReminderTerm, FMSubFindings : TFMFile;    //not owned here

  begin
    //Result := AutoEditClickField(GridInfo, '20');
    //NOTE: GridInfo.IENS is for current subrecord being displayed.
    ParentIEN := piece(GridInfo.IENS,',',2);
    //So I need to use this to query the parent record for other subrecords
    FileMan := TFileMan.Create;
    FMReminderTerm := FileMan.FMFile['811.5'];
    OneReminderTerm := FMReminderTerm.FMRecord[ParentIEN];
    FMSubFindings := OneReminderTerm.FMField['20'].Subfile;
    SubRecsSL := TStringList.Create;
    FMSubFindings.GetRecordsList(SubRecsSL);  //format: Strings[i]='IEN=.01Value'
    LogicStr := '';
    FindingsUsed := '';
    for i := 0 to SubRecsSL.Count - 1 do begin
      s := SubRecsSL.Strings[i];   if s='' then continue;
      IEN := piece(s,'=',1);       if IEN='' then continue;
      if LogicStr <> '' then LogicStr := LogicStr + '!';
      LogicStr := LogicStr + 'FI('+IEN+')';
      if FindingsUsed <> '' then FindingsUsed := FindingsUsed + ';';
      FindingsUsed := FindingsUsed + 'FI('+IEN+')';
    end;
    SubRecsSL.Free;
    Rem2VennU.PrepFindingSubVennForm(VennForm, LogicStr, FindingsUsed, '811.52', ParentIEN+',');
    Result := true;
  end;

  function TFindingDetailForm.HandleFunctionFindings(GridInfo : TGridInfo) : boolean;
  //Returns TRUE if should show form, or FALSE if show form.
  var
    FuncStr : string;
    FuncList, FindingsList : TStringList;
    FunctionName : string;
    ArgSig, IENS, OneIENS : string;
    ArgPos : integer;
    Code, Value : string;
    FindingsUsed : string;
    LineStr,FindingLineStr : string;
    i,j : integer;

  begin
    FindingsList := TStringList.Create;
    FuncList := TStringList.Create;
    FuncStr := Rem2VennU.FieldValue(GridInfo.Data, '811.925',GridInfo.IENS,'3');
    FindingsUsed := '';
    Rem2VennU.GetFieldMatchesFullLine(GridInfo.Data, '811.9255','.02', FuncList);  //811.9255 = Field 5 (FUNCTION LIST)
    for i := 0 to FuncList.Count - 1 do begin
      LineStr := FuncList.Strings[i];
      FunctionName := OrFn.Piece(LineStr, '^', 4);
      IENS := OrFn.Piece(LineStr, '^', 2);
      ArgSig := rRPCsU.GetFunctionFindingArgumentSignature(FunctionName);
      FindingsList.Clear;
      Rem2VennU.GetFieldMatchesFullLine(GridInfo.Data, '811.9256','.01', FindingsList);  //811.9256 = Field 20 (FUNCTION ARGUMENT LIST)
      for j := 0 to FindingsList.Count - 1 do begin
        FindingLineStr := FindingsList.Strings[j];
        OneIENS := OrFN.Piece(FindingLineStr, '^', 2);
        if OrFn.Pieces(OneIENS,',',2,5)<> IENS then continue;
        ArgPos := StrToIntDef(OrFN.Piece(OneIENS, ',', 1),0);
        if ArgPos = 0 then continue;
        Value := OrFn.Piece(FindingLineStr,'^',4);
        Code := OrFn.Piece(ArgSig,'^',ArgPos);
        if Code = 'F' then FindingsUsed := FindingsUsed + 'FI(' + Value + ');';
        if Code = 'S' then FindingsUsed := FindingsUsed + 'STRING("' + Value + '");';
        if Code = 'N' then FindingsUsed := FindingsUsed + 'NUMBER(' + Value + ');';
      end;
    end;

    {
    Rem2VennU.GetFieldMatches(GridInfo.Data, '811.9256','.01', FindingsList);  //811.9256 = Field 20 (FUNCTION ARGUMENT LIST)
    FindingsUsed := '';
    for i := 0 to FindingsList.Count - 1 do begin
      FindingsUsed := FindingsUsed + 'FI(' + FindingsList.Strings[i] + ');';
    end;

    }

    FindingsList.free;
    FuncList.Free;
    Rem2VennU.PrepFuncFindingSubVennForm(VennForm, FuncStr, FindingsUsed);
    Result := true;
  end;

  function TFindingDetailForm.Initialize(GridInfo : TGridInfo) : boolean;
  //Returns TRUE if should show form, or FALSE if show form.
  begin
    Result := false;
    if (GridInfo.FileNum = '811.925') then begin  //Reminder Definition:FUNCTION FINDINGS
      Result := HandleFunctionFindings(GridInfo);
    end else if (GridInfo.FileNum = '811.902') then begin  //Reminder Definition:FINDINGS
      Result := HandleFindings(GridInfo);
    end else if (GridInfo.FileNum = '811.52') then begin  //REMINDER TERM:FINDINGS
      Result := HandleTerms(GridInfo);
    end;
  end;

end.

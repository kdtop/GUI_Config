unit frmFuncFinding;
//NOTE: Handles Function Findings, and plain Findings, and other reminder stuff

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  frmVennU, VennObject, TypesU, UtilU, ReminderObjU,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TFuncFindingForm = class(TForm)
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
    //procedure HandleSelectionChange(VennObject : TVennObj);
    procedure HandleSelectionChange(RemObject : TRemObj);
    //procedure HandleRemDefVennObjectRtClick(VennObject : TVennObj);
    procedure HandleRemDefRemObjectRtClick(RemObject : TRemObj);
    //procedure HandleVennObjectDblClick(VennObject : TVennObj);
    procedure HandleRemObjectDblClick(RemObject : TRemObj);
    function HandleFindings(GridInfo : TGridInfo) : boolean;
    function HandleFunctionFindings(GridInfo : TGridInfo) : boolean;
    //function HandleTerms(GridInfo : TGridInfo) : boolean;
    function AutoEditClickField(GridInfo : TGridInfo;  FieldNum : string) : boolean;
  public
    { Public declarations }
    VennForm : TVennForm;     //elh  moved from private
    function Initialize(GridInfo : TGridInfo) : boolean;
  end;

//var
//  FuncFindingForm: TFuncFindingForm;

implementation

{$R *.dfm}

  uses ORFn, Rem2VennU, MainU, LookupU;

  procedure TFuncFindingForm.btnDetailsClick(Sender: TObject);
  begin
    VennForm.btnDetailsClick(Sender);
  end;

  procedure TFuncFindingForm.FormCreate(Sender: TObject);
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
  end;

  procedure TFuncFindingForm.FormDestroy(Sender: TObject);
  begin
    VennForm.Free;
  end;

  procedure TFuncFindingForm.HandleSelectionChange(RemObject : TRemObj);
  var Enabled : boolean;
  begin
    Enabled := Assigned(RemObject) and (RemObject.Children.Count > 0);
    btnDetails.Enabled := Enabled;
  end;

  procedure TFuncFindingForm.HandleRemDefRemObjectRtClick(RemObject : TRemObj);
  begin
   if (RemObject.Children.Count > 0) then begin
      VennForm.RgnMgr.ZoomIntoSelected;
      exit;
    end;
  end;

  procedure TFuncFindingForm.HandleRemObjectDblClick(RemObject : TRemObj);
  begin
    if btnDetails.Enabled then btnDetailsClick(RemObject);
  end;


  procedure TFuncFindingForm.pnlVennDisplayResize(Sender: TObject);
  begin
    VennForm.Width := pnlVennDisplay.Width + 5;
    VennForm.Height := pnlVennDisplay.Height;
    //VennForm.RgnMgr.Resize(VennForm.Height-BOTTOM_SPACING, VennForm.Width);
    VennForm.RgnMgr.Resize(VennForm.Height, VennForm.Width);
    VennForm.RgnMgr.AutoArrangeChildrenForFormulaDisplay;
  end;



  function TFuncFindingForm.AutoEditClickField(GridInfo : TGridInfo;  FieldNum : string) : boolean;
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
      FieldLookupForm.PrepFormAsMultFile(VarPtrInfo, Value);
      FieldLookupForm.EditBtnClick(Self);
      FieldLookupForm.Free;
    end;
    VarPtrInfo.Free;
    Result := false;
  end;

  function TFuncFindingForm.HandleFindings(GridInfo : TGridInfo) : boolean;
  //File = REMINDER DEFINITION:FINDINGS (811.902)
  var
    FuncStr : string;
    FindingsList : TStringList;
    FindingsUsed : string;
    i : integer;
  begin
    Result := AutoEditClickField(GridInfo, '.01');
    FindingsList := TStringList.Create;
    FuncStr := Rem2VennU.FieldValue(GridInfo.Data, '811.902',GridInfo.IENS,'.01');
    {
    Rem2VennU.GetFieldMatches(GridInfo.Data, '811.9256','.01', FindingsList);
    FindingsUsed := '';
    for i := 0 to FindingsList.Count - 1 do begin
      FindingsUsed := FindingsUsed + 'FI(' + FindingsList.Strings[i] + ');';
    end;
    }
    FindingsList.free;
    //Rem2VennU.PrepFuncFindingSubVennForm(VennForm, FuncStr, FindingsUsed);
    //Result := true;
  end;

  {
  function TFuncFindingForm.HandleTerms(GridInfo : TGridInfo) : boolean;
  begin
    Result := AutoEditClickField(GridInfo, '20');
  end;
  }

  function TFuncFindingForm.HandleFunctionFindings(GridInfo : TGridInfo) : boolean;
  //Returns TRUE if should show form, or FALSE if show form.
  var
    FuncStr : string;
    FindingsList : TStringList;
    FindingsUsed : string;
    i : integer;

  begin
    FindingsList := TStringList.Create;
    FuncStr := Rem2VennU.FieldValue(GridInfo.Data, '811.925',GridInfo.IENS,'3');
    Rem2VennU.GetFieldMatches(GridInfo.Data, '811.9256','.01', FindingsList);
    FindingsUsed := '';
    for i := 0 to FindingsList.Count - 1 do begin
      FindingsUsed := FindingsUsed + 'FI(' + FindingsList.Strings[i] + ');';
    end;
    FindingsList.free;
    Rem2VennU.PrepFuncFindingSubVennForm(VennForm, FuncStr, FindingsUsed);
    Result := true;
  end;

  function TFuncFindingForm.Initialize(GridInfo : TGridInfo) : boolean;
  //Returns TRUE if should show form, or FALSE if show form.
  begin
    Result := false;
    if (GridInfo.FileNum = '811.925') then begin  //Reminder Definition:FUNCTION FINDINGS
      Result := HandleFunctionFindings(GridInfo);
    end else if (GridInfo.FileNum = '811.902') then begin  //Reminder Definition:FINDINGS
      Result := HandleFindings(GridInfo);
    {end else if (GridInfo.FileNum = '811.5') then begin  //REMINDER TERM
      Result := HandleTerms(GridInfo);  }
    end;
  end;

end.

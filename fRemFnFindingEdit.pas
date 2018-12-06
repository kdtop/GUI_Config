unit fRemFnFindingEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, StrUtils,
  LookupU,
  ORFN, FMU;

type
  TfrmFnFindingEdit = class(TForm)
    btnAddFunction: TBitBtn;
    btnAddArg: TBitBtn;
    lblFunString: TLabel;
    edtFuncString: TEdit;
    btnCancel: TBitBtn;
    btnDone: TBitBtn;
    btnClearString: TBitBtn;
    lblLegend: TLabel;
    lbArgs: TListBox;
    procedure btnClearStringClick(Sender: TObject);
    procedure btnAddFunctionClick(Sender: TObject);
    procedure btnAddArgClick(Sender: TObject);
  private
    { Private declarations }
    FFuncIENS : string;
    FFileMan : TFileman;              //owned here
    FRemDefFile : TFMFile;              //not owned here   //811.9
    FNormalFindingsSubfile: TFMFile;    //not owned here   //811.902
    FRemDefRecord : TFMRecord;          //not owned here

    FNormalFindings : TStringList;

    function SelectFunctionName(InitValue : string; var Changed : boolean) : string;
    function GetResult : string;
  public
    { Public declarations }
    procedure Initialize(InitValue, FuncFindingIENS : string);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Result : string read GetResult;
  end;

//var
//  frmFnFindingEdit: TfrmFnFindingEdit;

implementation

{$R *.dfm}

//-------------------------------------------------------------------
//-------------------------------------------------------------------

constructor TfrmFnFindingEdit.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);

  FFileMan := TFileman.Create;
  FRemDefFile := FFileMan.FMFile['811.9'];  //REMINDER DEFINITION
  FNormalFindings := TStringList.Create;
  FRemDefRecord := nil;
  FNormalFindingsSubfile := nil;
end;

destructor TfrmFnFindingEdit.Destroy;
begin
  FFileMan.Free;
  FNormalFindings.Free;
  inherited Destroy;
end;

procedure TfrmFnFindingEdit.Initialize(InitValue, FuncFindingIENS : string);
var RecordIENS : string;
begin
  FFuncIENS := FuncFindingIENS;
  RecordIENS := piece(FFuncIENS, ',', 2) + ',';
  FRemDefRecord := FRemDefFile.FMRecord[RecordIENS];
  FNormalFindingsSubfile := FRemDefRecord.FMField['20'].Subfile;   //20 = FINDINGS field

  FNormalFindingsSubfile.GetRecordsList(FNormalFindings);
  lbArgs.Items.Assign(FNormalFindings); //IEN=Name
  edtFuncString.Text := InitValue;
end;


procedure TfrmFnFindingEdit.btnAddArgClick(Sender: TObject);
var SelectedI : integer;
    i : integer;
    s, ArgNum : string;
begin
  SelectedI := -1;
  for i := 0 to lbArgs.Items.Count - 1 do begin
    if LbArgs.Selected[i] then begin
      SelectedI := i;
      break;
    end;
  end;
  if SelectedI = -1 then begin
    MessageDlg('Please select argument from list below first', mtError, [mbOK], 0);
    exit;
  end;
  s := lbArgs.Items.Strings[SelectedI];
  ArgNum := piece(s, ' ', 1);
  if ArgNum='' then exit;
  ArgNum := Piece(ArgNum,'=',1);
  s := Trim(edtFuncString.Text);
  if not (RightStr(s, 1)[1] in ['(',',']) then ArgNum := ',' + ArgNum;
  edtFuncString.Text := s + ArgNum;
end;

procedure TfrmFnFindingEdit.btnAddFunctionClick(Sender: TObject);
var s : string;
    Changed : boolean;
begin
  s := SelectFunctionName('', Changed);
  if s <> '' then s := s + '(';
  edtFuncString.Text := edtFuncString.Text + s;
end;

procedure TfrmFnFindingEdit.btnClearStringClick(Sender: TObject);
begin
  edtFuncString.Text := '';
end;

function TfrmFnFindingEdit.GetResult : string;
begin
  Result := edtFuncString.Text;
end;


function TfrmFnFindingEdit.SelectFunctionName(InitValue : string; var Changed : boolean) : string;
var FieldLookupForm: TFieldLookupForm;
begin
  Result := InitValue;
  FieldLookupForm:= TFieldLookupForm.Create(Nil);
  FieldLookupForm.PrepForm('802.4', InitValue, '811.9255', '.02');
  if FieldLookupForm.ShowModal = mrOK then begin
    Result := FieldLookupForm.SelectedValue;
  end;
  Changed := FieldLookupForm.ChangesMade;
  FreeAndNil(FieldLookupForm);
end;



end.

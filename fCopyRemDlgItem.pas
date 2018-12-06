unit fCopyRemDlgItem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, Buttons, ORCtrls;

type
  TfrmCopyRemDlgItem = class(TForm)
    Label1: TLabel;
    edtSource: TEdit;
    Label2: TLabel;
    edtNamespace: TEdit;
    Label3: TLabel;
    btnCancel: TBitBtn;
    btnCopy: TBitBtn;
    clbChildren: TCheckListBox;
    lblCopyChildDescription: TLabel;
    lblCopyChild: TLabel;
    Label6: TLabel;
    edtDemoName: TEdit;
    lblWorking: TLabel;
    Label4: TLabel;
    cboSponsor: TORComboBox;
    procedure cboSponsorDropDown(Sender: TObject);
    procedure cboSponsorNeedData(Sender: TObject; const StartFrom: string;
      Direction, InsertAt: Integer);
    procedure cboSponsorDblClick(Sender: TObject);
    procedure cboSponsorClick(Sender: TObject);
    procedure cboSponsorChange(Sender: TObject);
    procedure edtNamespaceClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtNamespaceChange(Sender: TObject);
  private
    { Private declarations }
    FSourceIEN : string;
    ManuallyChangingNamespace : boolean;
    NamespaceOK : boolean;
    FChildList : TStringList;
    FSponsorIENToUse : string;
    procedure SetNamespaceState(IsOK : boolean);
    procedure SetDemoName;
    procedure FillAcceptList(AcceptList : TStringList);
    procedure SetupChildItemsList;
    function NewName(s : string) : string;
  public
    { Public declarations }
    NewlyCopiedItemIEN : string; //will be '' if problem occurred with copy
    NewlyCopiedItemName : string; //will be '' if problem occurred with copy
    function Initialize(SourceIEN, SourceName : string) : boolean;

  end;

//var
//  frmCopyRemDlgItem: TfrmCopyRemDlgItem;

implementation

{$R *.dfm}

uses
  rRPCsU, ORFn;

procedure TfrmCopyRemDlgItem.btnCopyClick(Sender: TObject);
var
  CopyResult : string;
  AcceptList : TStringList;
  PriorCursor : TCursor;

begin
  AcceptList := TStringList.Create;
  FillAcceptList(AcceptList);
  lblWorking.Visible := true;
  PriorCursor := Self.Cursor;
  Self.Cursor := crHourGlass;
  Application.ProcessMessages;
  CopyResult := rRPCsU.ReminderDlgCopyTree(FSourceIEN, edtNamespace.Text, FSponsorIENToUse, AcceptList);
  NewlyCopiedItemIEN := piece(CopyResult, '^',1);
  NewlyCopiedItemName := piece(CopyResult, '^',2);
  AcceptList.Free;
  lblWorking.Visible := false;
  Self.Cursor := PriorCursor;
  Application.ProcessMessages;
  if NewlyCopiedItemIEN <> '' then begin
    Self.ModalResult := mrOK;
  end else begin
    Self.ModalResult := mrNo;  //signal of problem.
  end;
  //Form should close here.
end;

function TfrmCopyRemDlgItem.NewName(s : string) : string;
begin
  Result := edtNamespace.Text + '-' + s;
end;


procedure TfrmCopyRemDlgItem.FillAcceptList(AcceptList : TStringList);
//Later this form could be modified to allow namespace designation
//e.g. 'DG' to let ALL 'DG' namespaced entries to be allowed at one.
var i : integer;
begin
  for i := 0 to clbChildren.Items.Count-1 do begin
    if clbChildren.Checked[i] = true then continue;
    AcceptList.Add(FChildList.Strings[i]);
  end;
end;

procedure TfrmCopyRemDlgItem.cboSponsorChange(Sender: TObject);
begin
  if Length(cboSponsor.ItemID)>0 then begin
    FSponsorIENToUse := IntToStr(cboSponsor.ItemID);
  end else begin
    FSponsorIENToUse := '';
  end;
end;

procedure TfrmCopyRemDlgItem.cboSponsorClick(Sender: TObject);
begin
  cboSponsorChange(Self);
end;

procedure TfrmCopyRemDlgItem.cboSponsorDblClick(Sender: TObject);
begin
  cboSponsorChange(Self);
end;

procedure TfrmCopyRemDlgItem.cboSponsorDropDown(Sender: TObject);
begin
  if cboSponsor.Text = '' then begin
    cboSponsor.InitLongList('A');
  end;
end;

procedure TfrmCopyRemDlgItem.cboSponsorNeedData(Sender: TObject;
  const StartFrom: string; Direction, InsertAt: Integer);
var  Result : TStrings;
     FileNum : string;
begin
  FileNum := '811.6';  //REMINDER SPONSOR
  Result := SubsetofFile(FileNum, StartFrom, Direction);
  TORComboBox(Sender).ForDataUse(Result);
end;

procedure TfrmCopyRemDlgItem.edtNamespaceChange(Sender: TObject);
  function AlphaOnly(s : string) : boolean;
  var i : integer;
  begin
    Result := true;
    for i := 1 to Length(s) do begin
      if not (s[i] in ['A'..'Z']) then begin
        Result := false;
        break;
      end;
    end;
  end;

var s : string;
begin
  if ManuallyChangingNamespace then exit;
  s := Uppercase(edtNamespace.Text);
  NamespaceOK := false;
  ManuallyChangingNamespace := True;
  if s <> edtNamespace.Text then begin
    edtNamespace.Text := s;
    edtNamespace.SetFocus;
    edtNamespace.SelStart := Length(edtNamespace.Text);
  end;
  NamespaceOK := ((Length(s) >= 2) and (Length(s) <= 4) and AlphaOnly(s));
  SetDemoName;
  ManuallyChangingNamespace := false;
  SetNamespaceState(NamespaceOK);
  if NamespaceOK then SetupChildItemsList;
end;

procedure TfrmCopyRemDlgItem.edtNamespaceClick(Sender: TObject);
begin
  edtNamespaceChange(Self);
end;

procedure TfrmCopyRemDlgItem.SetDemoName;
begin
  edtDemoName.Text := NewName(edtSource.Text)
end;

procedure TfrmCopyRemDlgItem.SetNamespaceState(IsOK : boolean);
begin
  if IsOK then begin
    edtNamespace.Color := clWindow;
  end else begin
    edtNamespace.Color := clYellow;
    edtDemoName.Text := '';
  end;
  btnCopy.Enabled := IsOK;
end;

procedure TfrmCopyRemDlgItem.FormCreate(Sender: TObject);
begin
 FChildList := TStringList.Create;
 ManuallyChangingNamespace := false;
 NamespaceOK := false;
 NewlyCopiedItemIEN := '';
end;

function TfrmCopyRemDlgItem.Initialize(SourceIEN, SourceName : string) : boolean;
//Returns TRUE if OK, or FALSE if error occured
var i : integer;
begin
  edtSource.Text := SourceName;
  SetDemoName;
  FSourceIEN := SourceIEN;
  FSponsorIENToUse := '';
  Result := rRPCsU.GetReminderDlgChildList(FSourceIEN, FChildList);
  SetupChildItemsList;
end;

procedure TfrmCopyRemDlgItem.SetupChildItemsList;
var i : integer;
    s : string;
    Empty : boolean;
const ARROW = ' --> ';
begin
  if clbChildren.Items.Count <> FChildList.Count then begin
    clbChildren.Items.Assign(FChildList);
    for i := 0 to clbChildren.Items.Count-1 do begin
      clbChildren.Checked[i] := true;
      clbChildren.ItemEnabled[i] := true;
    end;
  end;
  for i := 0 to clbChildren.Items.Count-1 do begin
     s := FChildList.Strings[i];
    clbChildren.Items.Strings[i] := s + ARROW + NewName(s);
  end;
  Empty := (clbChildren.Items.Count=0);
  lblCopyChildDescription.Enabled := not Empty;
  lblCopyChild.Enabled := not Empty;
  clbChildren.Enabled := not Empty;

end;


end.

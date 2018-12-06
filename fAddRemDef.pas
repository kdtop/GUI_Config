unit fAddRemDef;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Buttons,
  FMU, fOneRecEditU, ORFN, ORCtrls, rRPCsU;

type
  TfrmAddRemDef = class(TForm)
    pnlbottom: TPanel;
    btnCancel: TBitBtn;
    btnDone: TBitBtn;
    btnPrev: TBitBtn;
    btnNext: TBitBtn;
    pnlTop: TPanel;
    Image1: TImage;
    lblAddRemDef: TLabel;
    btnStoreEdit: TBitBtn;
    pcWizardPageControl: TPageControl;
    tsNewFinding: TTabSheet;
    Label2: TLabel;
    Label6: TLabel;
    edtName: TEdit;
    btnCreateItem: TBitBtn;
    cboGender: TComboBox;
    cboClass: TComboBox;
    Label5: TLabel;
    cboSponsor: TORComboBox;
    Label1: TLabel;
    edtUsage: TEdit;
    Label3: TLabel;
    edtDisplayName: TEdit;
    Label4: TLabel;
    procedure FormShow(Sender: TObject);
    procedure edtUsageClick(Sender: TObject);
    procedure cboSponsorDropDown(Sender: TObject);
    procedure cboSponsorDblClick(Sender: TObject);
    procedure cboSponsorChange(Sender: TObject);
    procedure cboSponsorClick(Sender: TObject);
    procedure cboSponsorNeedData(Sender: TObject; const StartFrom: string;
      Direction, InsertAt: Integer);
    procedure btnCreateItemClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtInputChange(Sender: TObject);
  private
    { Private declarations }
    FFileman : TFileman; //owned here
    FRemDefFMFile : TFMFile;  //owned by FFileman;
    FAddedRemDefIEN : string;
    FRefreshIndicated : boolean;
    FSponsorIENToUse : string;
    function GetReminderName : string;
  public
    { Public declarations }
    property RefreshIndicated : boolean read FRefreshIndicated;
    property ReminderName : string read GetReminderName;
  end;

//var
//  frmAddRemDef: TfrmAddRemDef;

implementation

{$R *.dfm}
uses
  fReminderDefFilter;

const
   REM_DEF_FILE = '811.9';


procedure TfrmAddRemDef.FormCreate(Sender: TObject);
begin
  FFileman := TFileman.Create;
  FRemDefFMFile := FFileman.FMFile['811.9'];
end;

procedure TfrmAddRemDef.FormDestroy(Sender: TObject);
begin
  FFileman.Free;  //owns all other FM objects
end;



procedure TfrmAddRemDef.FormShow(Sender: TObject);
begin
  edtName.SetFocus;
end;

procedure TfrmAddRemDef.btnCreateItemClick(Sender: TObject);
  //Here I create and then edit function item.
var EditRec,NewRec : TFMRecord; //not owned here.
    IEN, IENS : string;
    FMField : TFMField;   //not owned here.
    Gender : string;

begin
  if FAddedRemDefIEN = '' then begin
    NewRec := FRemDefFMFile.GetScratchRecord;
    NewRec.FMField['.01'].Value := edtName.text;
    NewRec.FMField['100'].Value := cboClass.Text;
    if NewRec.PostChanges = false then begin
      exit;  //The post shows FM errors itself.
    end;
    FAddedRemDefIEN := piece(NewRec.IENS,',',1);
    EditRec := FRemDefFMFile.FMRecord[FAddedRemDefIEN];
    EditRec.FMField['1.2'].Value := edtDisplayName.Text;
    EditRec.FMField['101'].Value := cboSponsor.Text;
    EditRec.FMField['103'].Value := edtUsage.Text;
    Gender := cboGender.Text;
    if Gender<>'' then begin
      if Pos(' or ', Gender)>0 then Gender := '';
      if Pos('Male', Gender)>0 then Gender := 'M'
      else if Pos('Female', Gender)>0 then Gender := 'F'
      else Gender := '';
      if Gender <>'' then EditRec.FMField['1.9'].Value := Gender;
    end;
    EditRec.FMField['31'].Value := '(SEX)&(AGE)';     //kt added &(AGE) 9/18/13
    EditRec.FMField['32'].Value := '1';
    EditRec.FMField['33'].Value := 'SEX;AGE';         //kt added ;AGE 9/18/13
    if EditRec.PostChanges = false then exit;
    btnCreateItem.Caption := '&Edit Details';
    btnCreateItem.Glyph.Assign(btnStoreEdit.Glyph);
    //Disable backup up and Cancel button.
    //btnPrev.Enabled := false;
    //btnDone.Visible := true;
    btnDone.Enabled := true;
    btnCancel.Enabled := false;
  end else begin
    EditRec := FRemDefFMFile.FMRecord[FAddedRemDefIEN];
  end;

  EditOneRecordModal(REM_DEF_FILE, FAddedRemDefIEN, true);
  FRefreshIndicated := true;
  IEN := Piece(EditRec.IENS, ',',1);
  EditRec := FRemDefFMFile.FMRecord[IEN];
  EditRec.RefreshFromServer;
  edtName.Text := EditRec.FMField['.01'].Value;
  edtDisplayName.Text := EditRec.FMField['1.2'].Value;
  cboClass.Text := EditRec.FMField['100'].Value;
  cboSponsor.Text := EditRec.FMField['101'].Value;
  edtUsage.Text := EditRec.FMField['103'].Value;
  if EditRec.FMField['1.9'].Value = 'MALE' then begin
    cboGender.ItemIndex := 1;
  end else if EditRec.FMField['1.9'].Value = 'FEMALE' then begin
    cboGender.ItemIndex := 2;
  end else begin
    cboGender.ItemIndex := 0;
  end;
  edtName.Enabled := false;
  cboClass.Enabled := false;
  cboSponsor.Enabled := false;
  edtUsage.Enabled := false;
  cboGender.Enabled := false;
  edtDisplayName.Enabled := false;
end;

procedure TfrmAddRemDef.cboSponsorChange(Sender: TObject);
begin
  if Length(cboSponsor.ItemID)>0 then begin
    FSponsorIENToUse := IntToStr(cboSponsor.ItemID);
  end else begin
    FSponsorIENToUse := '';
  end;
  edtInputChange(Sender);
end;

procedure TfrmAddRemDef.cboSponsorClick(Sender: TObject);
begin
  cboSponsorChange(Self);
end;

procedure TfrmAddRemDef.cboSponsorDblClick(Sender: TObject);
begin
  cboSponsorChange(Self);
end;

procedure TfrmAddRemDef.cboSponsorDropDown(Sender: TObject);
begin
  if cboSponsor.Text = '' then begin
    cboSponsor.InitLongList('A');
  end;
end;

procedure TfrmAddRemDef.cboSponsorNeedData(Sender: TObject;
  const StartFrom: string; Direction, InsertAt: Integer);
var  Result : TStrings;
     FileNum : string;
begin
  FileNum := '811.6';  //REMINDER SPONSOR
  Result := SubsetofFile(FileNum, StartFrom, Direction);
  TORComboBox(Sender).ForDataUse(Result);
end;

procedure TfrmAddRemDef.edtUsageClick(Sender: TObject);
var
  frmRemDefFilters: TfrmRemDefFilters;
begin
  frmRemDefFilters := TfrmRemDefFilters.Create(Self);
  frmRemDefFilters.Initialize(edtUsage.Text);
  if frmRemDefFilters.ShowModal = mrOK then begin
    edtUsage.Text := frmRemDefFilters.UserChosenFlags;
  end;
  frmRemDefFilters.Free;
end;

procedure TfrmAddRemDef.edtInputChange(Sender: TObject);
begin
  btnCreateItem.Enabled :=  (edtName.Text <> '')
                        and (edtDisplayName.Text <> '')
                        //and (cboSponsor.Text <> '')
                        and (edtUsage.Text <> '');
  if Sender is TEdit then with TEdit(Sender) do begin
    if Text = '' then Color := clYellow else Color := clWhite;
  end else if Sender is TComboBox then with TComboBox(Sender) do begin
    if Text = '' then Color := clYellow else Color := clWhite;
  end else if Sender is TORComboBox then with TORComboBox(Sender) do begin
    if Text = '' then Color := clYellow else Color := clWhite;
  end;

end;

function TfrmAddRemDef.GetReminderName : string;
begin
  Result := edtName.Text;
end;


end.

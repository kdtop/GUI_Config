unit fTestReminder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  TestRemResultsU,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, ORCtrls,OrFn,rCore;

type
  TfrmTestReminder = class(TForm)
    Panel1: TPanel;
    btnDone: TBitBtn;
    Panel2: TPanel;
    Memo: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    cbAllTerms: TCheckBox;
    btnGetTestInfo: TBitBtn;
    DateTimePicker1: TDateTimePicker;
    TestPatientORComboBox: TORComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TestPatientORComboBoxNeedData(Sender: TObject;
      const StartFrom: string; Direction, InsertAt: Integer);
    procedure btnGetTestInfoClick(Sender: TObject);
  private
    { Private declarations }
    FReminderIEN : string;
    FResultsMgr : TRemTestResultMgr;
    FOwnershipOfResultsMgrTransferred : boolean;
  public
    function GetAndTransferOwnershipOfResultsMgr : TRemTestResultMgr;
    procedure Initialize(ReminderIEN : string);
  end;

var
  frmTestReminder: TfrmTestReminder;

implementation

{$R *.dfm}

  uses rRPCsU, MainU, LookUpU;

  procedure TfrmTestReminder.btnGetTestInfoClick(Sender: TObject);
  var
    DFN, AsOfDate : string;
  begin
    DFN := IntToStr(TestPatientORComboBox.ItemIEN);
    AsOfDate := DateToStr(DateTimePicker1.DateTime);
    rRPCsU.ReminderTest(FReminderIEN, DFN, AsOfDate,cbAllTerms.Checked, Memo.Lines);
    FResultsMgr.Load(Memo.Lines);
  end;

  procedure TfrmTestReminder.FormCreate(Sender: TObject);
  begin
  FOwnershipOfResultsMgrTransferred := false;
  end;

  procedure TfrmTestReminder.FormDestroy(Sender: TObject);
  begin
    if not FOwnershipOfResultsMgrTransferred then FreeAndNil(FResultsMgr);
  end;

  function TfrmTestReminder.GetAndTransferOwnershipOfResultsMgr : TRemTestResultMgr;
  begin
    Result := FResultsMgr;
    FOwnershipOfResultsMgrTransferred := true;
  end;


  procedure TfrmTestReminder.Initialize(ReminderIEN : string);
  begin
    MainForm.InitORCombobox(TestPatientORComboBox,'A');
    FReminderIEN := ReminderIEN;
    if Assigned(FResultsMgr) then FreeAndNil(FResultsMgr);
    FResultsMgr := TRemTestResultMgr.Create(FReminderIEN);
  end;


procedure TfrmTestReminder.TestPatientORComboBoxNeedData(Sender: TObject;
  const StartFrom: string; Direction, InsertAt: Integer);
var
  i: Integer;
  NoAlias, Patient: String;
  PatientList: TStringList;
const
  AliasString = ' -- ALIAS';

begin
  //NOTICE: for now I am taking out restrictions regarding restricted
  //        patient lists.  User will be able to test a reminder for
  //        any patient (but not open their chart)
  NoAlias := StartFrom;
  with Sender as TORComboBox do begin
    if Items.Count > ShortCount then begin
      NoAlias := Piece(Items[Items.Count-1], '^', 1) + '^' + NoAlias;
    end;
  end;
  if pos(AliasString, NoAlias)> 0 then begin
    NoAlias := Copy(NoAlias, 1, pos(AliasString, NoAlias)-1);
  end;
  PatientList := TStringList.Create;
  try
    begin
      PatientList.Assign(SubSetOfPatients(NoAlias, Direction));
      for i := 0 to PatientList.Count-1 do begin  // Add " - Alias" to alias names:
        Patient := PatientList[i];
        // Piece 6 avoids display problems when mixed with "RPL" lists:
        if (Uppercase(Piece(Patient, U, 2)) <> Uppercase(Piece(Patient, U, 6))) then begin
          SetPiece(Patient, U, 2, Piece(Patient, U, 2) + AliasString);
          PatientList[i] := Patient;
        end;
      end;
      TestPatientORComboBox.ForDataUse(PatientList);
    end;
  finally
    PatientList.Free;
  end;  
end;

end.

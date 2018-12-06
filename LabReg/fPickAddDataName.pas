unit fPickAddDataName;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ORCtrls,
  uSrchHelper;

type
  TDataNameMode = (tPick=0, tAdd=1);

  TfrmPickAddDataName = class(TForm)
    pnlMain: TPanel;
    pnlBottom: TPanel;
    btnCancel: TButton;
    btnOK: TButton;
    Label1: TLabel;
    Label2: TLabel;
    lblLabName: TLabel;
    rgDataName: TRadioGroup;
    pnlPickDN: TPanel;
    edtDNSrch: TEdit;
    lbDNSrch: TListBox;
    Label3: TLabel;
    pnlAddDN: TPanel;
    Label5: TLabel;
    edtNewDNName: TEdit;
    Image1: TImage;
    procedure edtAbrvDNNameChange(Sender: TObject);
    procedure edtNewLabTestNameChange(Sender: TObject);
    procedure edtNewDNNameChange(Sender: TObject);
    procedure rgDataNameClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    AlertHandle : string;
    TestName : string;
    DataNameMode : TDataNameMode;
    DNSrchHelper : TSrchHelper;
    procedure HandleDNSrchSelected(Sender : TObject);
    procedure SetDataNamePickVisibility(Mode : TDataNameMode);
    procedure SetOKButtonEnable;
    function ReadyForOKButton : boolean;
  public
    { Public declarations }
    StorageLoc63d04 : string;
    procedure Initialize(AlertHandle, TestName : string);
  end;

//var frmPickAddDataName: TfrmPickAddDataName;

implementation

{$R *.dfm}

  uses
    rHL7RPCsU, ORFn;

  procedure TfrmPickAddDataName.edtAbrvDNNameChange(Sender: TObject);
  begin
    SetOKButtonEnable;
  end;

  procedure TfrmPickAddDataName.edtNewDNNameChange(Sender: TObject);
  begin
    SetOKButtonEnable;
  end;

  procedure TfrmPickAddDataName.edtNewLabTestNameChange(Sender: TObject);
  begin
    SetOKButtonEnable;
  end;

  procedure TfrmPickAddDataName.FormCreate(Sender: TObject);
  begin
    DNSrchHelper := TSrchHelper.Create(Self);
    DNSrchHelper.Initialize(edtDNSrch, lbDNSrch, '63.04');  //this will set up TComboBox to work like a search box.
    DNSrchHelper.ServerCustomizerFn := '$$CUSTDN^TMGHL7R2';
    DNSrchHelper.OnSelectedChange := HandleDNSrchSelected;
  end;

  procedure TfrmPickAddDataName.FormDestroy(Sender: TObject);
  begin
    DNSrchHelper.Free;
  end;

  procedure TfrmPickAddDataName.Initialize(AlertHandle, TestName : string);
  //TestName -- name of the test from the HL7 message (perhaps shortened by user to 30 chars)
  begin
    StorageLoc63d04 := '';
    Self.AlertHandle := AlertHandle;
    Self.TestName := TestName;
    edtNewDNName.Text := TestName;
    lblLabName.Caption := TestName;
    StorageLoc63d04 := '';
    btnOK.Enabled := false;
    rgDataName.ItemIndex := Ord(tPick);
    rgDataNameClick(nil);
  end;

  procedure TfrmPickAddDataName.HandleDNSrchSelected(Sender : TObject);
  //Called by search helper when DN search has selected term.
  begin
    StorageLoc63d04 := DNSrchHelper.SelectedIEN;
    SetOKButtonEnable;
  end;

  procedure TfrmPickAddDataName.SetDataNamePickVisibility(Mode : TDataNameMode);
  begin
    case Mode of
      tPick: begin
                pnlAddDN.Visible := false;
                pnlPickDN.Visible := true;
                pnlPickDN.Align := alTop;
                Self.Height := pnlMain.Top + pnlPickDN.Height + 45 + pnlBottom.Height;
             end;
      tAdd:  begin
                pnlPickDN.Visible := false;
                pnlAddDN.Visible := true;
                pnlAddDN.Top := 0;
                pnlAddDN.Align := alTop;
                Self.Height := pnlMain.Top + pnlAddDN.Height + 45 + pnlBottom.Height;
             end;
    end;
  end;

  procedure TfrmPickAddDataName.rgDataNameClick(Sender: TObject);
  begin
    DataNameMode := TDataNameMode(rgDataName.ItemIndex);
    SetDataNamePickVisibility(DataNameMode);
    SetOKButtonEnable;
  end;

  procedure TfrmPickAddDataName.SetOKButtonEnable;
  begin
    btnOK.Enabled := ReadyForOKButton;
  end;

  function TfrmPickAddDataName.ReadyForOKButton : boolean;
  begin
    Result := (StorageLoc63d04 <> '');
  end;

  procedure TfrmPickAddDataName.btnOKClick(Sender: TObject);
  //NOTE: before this could be called, ReadyForOKButton must have returned TRUE
  begin
    if DataNameMode = tAdd then begin
      if MessageDlg('Add a new lab storage location named:' + #13#10 +
                 edtNewDNName.Text + '?' + #13#10 +
                 'NOTE: this can not be undone', mtConfirmation, [mbOK, mbCancel], 0) <> mrOK then begin
        //user aborting
        exit;
      end;
      StorageLoc63d04 := AutoAddDataName(edtNewDNName.Text);
      if StorageLoc63d04 = '' then exit;
    end;
    Self.ModalResult := mrOK;
  end;
end.


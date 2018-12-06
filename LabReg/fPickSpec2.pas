unit fPickSpec2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uSrchHelper;

type
  //NOTE: the enum below must match order of items in rgSpecimen
  TSpec2 = (tNone=-1, tSerum=0, tBlood=1, tUrine=2, tCSF=3, tSkin=4, tOther=5, tSearch=6);

  TfrmPickSpec2 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    lblLabName: TLabel;
    rgSpecimen: TRadioGroup;
    pnlBottom: TPanel;
    btnCancel: TButton;
    btnOK: TButton;
    pnlMain: TPanel;
    lblInstructions: TLabel;
    pnlPick: TPanel;
    edtSrch: TEdit;
    lbSrch: TListBox;
    Image1: TImage;
    procedure btnOKClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rgSpecimenClick(Sender: TObject);
  private
    { Private declarations }
    SpecSrchHelper : TSrchHelper;
    AlertHandle : string;
    TestName : string;
    SelectedSpec : TSpec2;
    SelectedSpecName : string;
    NeedManualSelection : boolean;
    procedure HandleSrchSelected(Sender : TObject);
    procedure AdjustLayout;
    procedure SetOKButtonEnable;
    function  ReadyForOKButton : boolean;
  public
    { Public declarations }
    ResultIEN : string;
    function Initialize(AlertHandle, TestName, PriorSpecimen : string) : boolean;

  end;

const
  //Note: if this is changed, match changes in fPickSpecimen.  They corelate and match up by index.
  SPEC2_NAME : array[tNone..tSearch] of string[24] = (
    'NONE',
    'SERUM',
    'BLOOD VENOUS',
    'URINE',
    'CSF',
    'SKIN',
    'OTHER',
    'SEARCH'
  );

//var
//  frmPickSpec2: TfrmPickSpec2;  //not auto-created

implementation

{$R *.dfm}
  uses
    rHL7RPCsU, fPickSpecimen;


  procedure TfrmPickSpec2.FormCreate(Sender: TObject);
  begin
    SpecSrchHelper := TSrchHelper.Create(Self);
    SpecSrchHelper.Initialize(edtSrch, lbSrch, '64.061');  //this will set up TComboBox to work like a search box.
    SpecSrchHelper.OnSelectedChange := HandleSrchSelected;
    SelectedSpec := tNone;
    SelectedSpecName := '';
    //rgSpecimenClick(nil);
  end;

  procedure TfrmPickSpec2.FormDestroy(Sender: TObject);
  begin
    SpecSrchHelper.Free;

  end;

  function TfrmPickSpec2.Initialize(AlertHandle, TestName, PriorSpecimen : string) : boolean;
  //Input: PriorSpecimen should be name from fPickSpecimen
  //Returns TRUE if showmodal is NOT needed.  Was able to pick based on PriorSpecimen.
  var i : TSpec2;
  begin
    Result := false;
    ResultIEN := '';
    NeedManualSelection := false;
    Self.AlertHandle := AlertHandle;
    Self.TestName := TestName;
    lblLabName.Caption := TestName;
    if PriorSpecimen <> '' then begin
      for i := tSerum to tOther do begin
        if SPEC2_NAME[i] <> PriorSpecimen then continue;
        rgSpecimen.ItemIndex := ord(i);
        rgSpecimenClick(nil);
        break;
      end;
      if ReadyForOKButton then Result := true
      else begin
        rgSpecimen.ItemIndex := ord(tSearch);
        edtSrch.Text := PriorSpecimen;  //should fire change events.
      end;
    end else begin
      rgSpecimenClick(nil);
    end;
  end;

  procedure TfrmPickSpec2.rgSpecimenClick(Sender: TObject);
  begin
    SelectedSpec := TSpec2(rgSpecimen.ItemIndex);
    SelectedSpecName := SPEC2_NAME[SelectedSpec];
    if SelectedSpec = tSearch then begin
      NeedManualSelection := true;
      SpecSrchHelper.InitEditBox;
    end else begin
      NeedManualSelection := false;
      SpecSrchHelper.OnSelectedChange := nil;  //temp turn off change handler
      edtSrch.Text := SelectedSpecName;
      SpecSrchHelper.RefreshSearch;  //force search now.
      Sleep(50); Application.ProcessMessages;
      SpecSrchHelper.OnSelectedChange := HandleSrchSelected;  //restore change handler
      if SpecSrchHelper.SelectedIEN = '' then begin
        if not SpecSrchHelper.SelectIfExactMatch(SelectedSpecName) then begin
          HandleSrchSelected(nil);
        end;
      end else begin
        HandleSrchSelected(nil);
      end;
    end;
    AdjustLayout;
  end;

  procedure TfrmPickSpec2.AdjustLayout;
  var MidX : integer;
  begin
    //Adjust layout depending on visibility status....
    if NeedManualSelection then begin
      pnlMain.Visible := true;
      Self.Height := rgSpecimen.Top + rgSpecimen.Height + 45 + pnlMain.Height + pnlBottom.Height;
    end else begin
      pnlMain.Visible := false;
      Self.Height := rgSpecimen.Top + rgSpecimen.Height + 45 + pnlBottom.Height;
    end;
    SetOKButtonEnable;
  end;


  procedure TfrmPickSpec2.HandleSrchSelected(Sender : TObject);
  begin
    ResultIEN := SpecSrchHelper.SelectedIEN;
    NeedManualSelection := ((ResultIEN='') and (lbSrch.Items.Count > 0)) or (SelectedSpec = tSearch);
    AdjustLayout;
  end;

  procedure TfrmPickSpec2.SetOKButtonEnable;
  begin
    btnOK.Enabled := ReadyForOKButton;
  end;

  function TfrmPickSpec2.ReadyForOKButton : boolean;
  begin
    Result := (ResultIEN <> '');
  end;

  procedure TfrmPickSpec2.btnOKClick(Sender: TObject);
  begin
    Self.ModalResult := mrOK;
  end;


end.


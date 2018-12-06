unit fPickAddWorkLoad;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uSrchHelper, StrUtils;

type
  TWkLdPickMode = (tNone, tNewWkLd, tExistingWkLd);

  TfrmPickAddWorkLoad = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    lblLabName: TLabel;
    rgSelectMode: TRadioGroup;
    pnlBottom: TPanel;
    btnCancel: TButton;
    btnOK: TButton;
    pnlMain: TPanel;
    pnlPick: TPanel;
    edtWkLdSrch: TEdit;
    lbWkLdSrch: TListBox;
    lblInstructions: TLabel;
    pnlAddWkLd: TPanel;
    Label3: TLabel;
    edtNewWkLdCodeName: TEdit;
    edtNewWkLdNum: TEdit;
    Label4: TLabel;
    Image1: TImage;
    procedure edtNewWkLdCodeNameChange(Sender: TObject);
    procedure edtNewWkLdNumChange(Sender: TObject);
    procedure rgSelectModeClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    AlertHandle : string;
    TestName : string;
    SelectMode : TWkLdPickMode;
    ExcludeList : TStringList;
    WkLdSrchHelper : TSrchHelper;
    function GetSelectedWorkLoadCode() : string;
    function IsWkLdCodeValid(Code : string) : boolean;
    function IsWkLdNameValid(Code : string) : boolean;
    procedure HandleWkLdSrchSelected(Sender : TObject);
    procedure HandleWkLdSearchScreen(SrchResults : TStringList);
    procedure SetOKButtonEnable;
    function ReadyForOKButton : boolean;
  public
    { Public declarations }
    ResultWorkLoadIEN : string;
    ResultWorkLoadName : string;
    ResultWorkLoadCode : string;
    procedure Initialize(AlertHandle, TestName : string; ExcludeList : TStringList);
  end;

//var
//  frmPickAddWorkLoad: TfrmPickWorkLoad;

implementation

{$R *.dfm}

  uses
    ORFn, rHL7RPCsU;

  const
    PICK_EXISTING_WKLD = 'Search and select existing lab test code below.';
    ADD_NEW_WKLD = 'Search and select for SIMILAR lab test code, to model NEW code after.';


  procedure TfrmPickAddWorkLoad.FormCreate(Sender: TObject);
  begin
    ExcludeList := TStringList.Create;
    WkLdSrchHelper := TSrchHelper.Create(Self);
    WkLdSrchHelper.Initialize(edtWkLdSrch, lbWkLdSrch, '64');  //this will set up TComboBox to work like a search box.
    WkLdSrchHelper.OnSelectedChange := HandleWkLdSrchSelected;
    WkLdSrchHelper.OnScreenResults := HandleWkLdSearchScreen;
    WkLdSrchHelper.ServerCustomizerFn := '$$CUSTWKLD^TMGHL7R2';
    SelectMode := tNone;
    rgSelectModeClick(nil);
  end;

  procedure TfrmPickAddWorkLoad.FormDestroy(Sender: TObject);
  begin
    ExcludeList.Free;

  end;

  procedure TfrmPickAddWorkLoad.Initialize(AlertHandle, TestName : string; ExcludeList : TStringList);
  begin
    ResultWorkLoadIEN := '';
    ResultWorkLoadCode := '';
    ResultWorkLoadName := '';
    Self.AlertHandle := AlertHandle;
    Self.TestName := TestName;
    lblLabName.Caption := TestName;
    edtNewWkLdCodeName.Text := TestName;
    Self.ExcludeList.Assign(ExcludeList);
  end;

  function TfrmPickAddWorkLoad.GetSelectedWorkLoadCode() : string;
  begin
    Result := piece(WkLdSrchHelper.SelectedRawData, '^', 4);
  end;

  procedure TfrmPickAddWorkLoad.HandleWkLdSrchSelected(Sender : TObject);
  var Code, Name : string;
  begin
    Code := GetSelectedWorkLoadCode;;
    Name := edtNewWkLdCodeName.Text;
    if SelectMode = tExistingWkLd then begin
      ResultWorkLoadIEN := WkLdSrchHelper.SelectedIEN;
      ResultWorkLoadCode := Code;
      ResultWorkLoadName := Name;
      SetOKButtonEnable();
    end else begin //new workload code
      ResultWorkLoadIEN := '';
      ResultWorkLoadCode := '';
      ResultWorkLoadName := '';
      if Code <> '' then Code := NextAvailWorkLoadCode(Code);
      edtNewWkLdNum.Text := Code;
      edtNewWkLdNumChange(nil);  //will trigger call to SetOKButtonEnable();
    end;
  end;

  function TfrmPickAddWorkLoad.IsWkLdCodeValid(Code : string) : boolean;
  var IntPart,DecPart : string;
  begin
    IntPart := piece(Code,'.',1);
    DecPart := piece(Code,'.',2);
    Result := (Length(IntPart)=5) and (Length(DecPart)=4);
  end;


  function TfrmPickAddWorkLoad.IsWkLdNameValid(Code : string) : boolean;
  var Value : string;
  begin
    Value := edtNewWkLdCodeName.Text;
    Result := false;
    if MidStr(Value, 1, 1) = '-' then exit;
    if Length(Value) < 2 then exit;
    if Length(Value) > 60 then exit;
    Result := true;
  end;

  procedure TfrmPickAddWorkLoad.edtNewWkLdCodeNameChange(Sender: TObject);
  var Valid : boolean;
  begin
    Valid := IsWkLdNameValid(edtNewWkLdCodeName.Text);
    if Valid then begin
      edtNewWkLdCodeName.Color := clWindow;
    end else begin
      edtNewWkLdCodeName.Color := clRed;
    end;
    SetOKButtonEnable();
  end;

  procedure TfrmPickAddWorkLoad.edtNewWkLdNumChange(Sender: TObject);
  var Valid : boolean;
  begin
    Valid := IsWkLdCodeValid(edtNewWkLdNum.Text);
    if Valid then begin
      edtNewWkLdNum.Color := clWindow;
    end else begin
      edtNewWkLdNum.Color := clRed;
    end;
    SetOKButtonEnable();
  end;


  procedure TfrmPickAddWorkLoad.HandleWkLdSearchScreen(SrchResults : TStringList);
  //Remove items from exclude list here...
  var i : integer;
      WkLd, s : string;
  begin
    //finish.
    if SelectMode = tNewWkLd then exit; //no screen needed.
    for i:= SrchResults.Count - 1 downto 0 do begin
      s := SrchResults.Strings[i];
      WkLd := piece(s, '^', 4);
      if ExcludeList.IndexOf(WkLd) = -1 then continue;
      SrchResults.Delete(i);
    end;
  end;

  procedure TfrmPickAddWorkLoad.SetOKButtonEnable;
  begin
    btnOK.Enabled := ReadyForOKButton;
  end;

  function TfrmPickAddWorkLoad.ReadyForOKButton : boolean;
  begin
    if SelectMode = tExistingWkLd then begin
      Result := (ResultWorkLoadCode <> '');
    end else begin
      Result := IsWkLdCodeValid(edtNewWkLdNum.Text) and
                IsWkLdNameValid(edtNewWkLdCodeName.Text);
    end;
  end;

  procedure TfrmPickAddWorkLoad.rgSelectModeClick(Sender: TObject);
  var s : string;
  begin
    s := '';
    if rgSelectMode.ItemIndex = 0 then begin  //Select Existing WorkLoad code
      lblInstructions.Caption := PICK_EXISTING_WKLD;
      SelectMode := tExistingWkLd;
      pnlAddWkLd.Visible := false;
    end else begin  //Add NEW WorkLoad code
      lblInstructions.Caption := ADD_NEW_WKLD;
      SelectMode := tNewWkLd;
      pnlAddWkLd.Visible := true;
    end;
    WkLdSrchHelper.RefreshSearch;  //filter is different depending on selection here...
  end;

  procedure TfrmPickAddWorkLoad.btnOKClick(Sender: TObject);
  //Can't get here without ReadFoOKButton resulting TRUE;
  var Name,Num : string;
      RPCResult : string;
  begin
    if SelectMode = tExistingWkLd then begin
      Self.ModalResult := mrOK;  //will close form.
    end else begin
      Name := edtNewWkLdCodeName.Text;
      Num := edtNewWkLdNum.Text;
      if MessageDlg('Add new VistA laboratory test code (workload code)' + #13#10 +
                    Name + ' (' + Num + ')' + #13#10 +
                    'NOTE: This can not be undone.', mtConfirmation, [mbOK, mbCancel], 0) <> mrOK then exit;
      RPCResult := AddWorkLoadCode(Name, Num);
      if RPCResult = '' then exit;  //error should already have been shown.
      ResultWorkLoadIEN := piece(RPCResult, '^', 1);
      ResultWorkLoadName := piece(RPCResult, '^', 2);
      ResultWorkLoadCode := piece(RPCResult, '^', 3);
      Self.ModalResult := mrOK;  //will close form.
    end;
  end;

end.


unit fXWBOnFail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Trpcb, Rpcconf1, ExtCtrls, frmVistAAbout, Menus;

type
  TfrmXWBOnFail = class(TForm)
    btnConnect: TButton;
    RPCB: TRPCBroker;
    rgrSelectAction: TRadioGroup;
    btnExit: TButton;
    Memo1: TMemo;
    edtErrorText: TEdit;
    edtLoginError: TEdit;
    lblLogin_ErrorText: TLabel;
    cbxBadAccess: TCheckBox;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    procedure btnConnectClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure MyErrorHandler(RPCBroker: TRPCBroker);
  end;

var
  frmXWBOnFail: TfrmXWBOnFail;

implementation

{$R *.DFM}

procedure TfrmXWBOnFail.MyErrorHandler(RPCBroker: TRPCBroker);
var
  ErrorText: String;
  Path: String;
  StrLoc: TStringList;
  NowVal: TDateTime;
begin
  NowVal := Now;
  ErrorText := RPCB.RPCBError;
  StrLoc := TStringList.Create;
  Path := ExtractFilePath(Application.ExeName);
  Path := Path + 'Error.Log';
  if FileExists(Path) then
    StrLoc.LoadFromFile(Path);
  StrLoc.Add(FormatDateTime('mm/dd/yyyy hh:mm:ss  ',NowVal) + ErrorText);
  StrLoc.SaveToFile(Path);
end;

procedure TfrmXWBOnFail.btnConnectClick(Sender: TObject);
begin
  if btnConnect.Caption = 'Connect' then
  begin
    edtErrorText.Text := '';   // Clear out old values
    edtLoginError.Text := '';
    RPCB.AccessVerifyCodes := '';
    RPCB.KernelLogIn := True;
    if cbxBadAccess.Checked then
      RPCB.AccessVerifyCodes := 'monkeysee;monkeydo';
    RPCB.OnRPCBFailure := nil;
    RPCB.ShowErrorMsgs := semRaise;
    case rgrSelectAction.ItemIndex of    //
      0: RPCB.OnRPCBFailure := MyErrorHandler;
      1: RPCB.ShowErrorMsgs := semRaise;
      2: RPCB.ShowErrorMsgs := semQuiet;
    end;    // case
    try
      RPCB.Connected := True;
      if RPCB.Connected then
        btnConnect.Caption := 'Disconnect';
    finally
      edtErrorText.Text := RPCB.RPCBError;
      edtLoginError.Text := RPCB.LogIn.ErrorText;
    end;
  end
  else
  begin
    RPCB.Connected := False;
    btnConnect.Caption := 'Connect';
  end;
end;

procedure TfrmXWBOnFail.btnExitClick(Sender: TObject);
begin
  halt;
end;

procedure TfrmXWBOnFail.FormCreate(Sender: TObject);
var
  Server: String;
  Port: String;
begin
  GetServerInfo(Server, Port);
  RPCB.Server := Server;
  RPCB.ListenerPort := StrToInt(Port);
end;

procedure TfrmXWBOnFail.Exit1Click(Sender: TObject);
begin
  Halt;
end;

procedure TfrmXWBOnFail.About1Click(Sender: TObject);
begin
  ShowAboutBox;
end;

end.

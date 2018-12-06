unit fXWBAVCodes;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Trpcb, RpcSLogin, Menus, frmVistAAbout, SharedRPCBroker;

type
  TForm1 = class(TForm)
    edtDUZ: TEdit;
    edtName: TEdit;
    edtDTime: TEdit;
    edtUserName: TEdit;
    btnConnect: TButton;
    edtAccessCode: TEdit;
    edtVerifyCode: TEdit;
    lblAccessCode: TLabel;
    lblVerifyCode: TLabel;
    btnExit: TButton;
    lblDUZ: TLabel;
    lblName: TLabel;
    lblDTime: TLabel;
    lblUserName: TLabel;
    edtServer: TEdit;
    edtListenerPort: TEdit;
    lblServer: TLabel;
    lblListenerPort: TLabel;
    Memo1: TMemo;
    MainMenu1: TMainMenu;
    mnuFile: TMenuItem;
    mnuFileExit: TMenuItem;
    mnuHelp: TMenuItem;
    mnuHelpAbout: TMenuItem;
    brkrRPCB: TSharedRPCBroker;
    procedure btnConnectClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure mnuFileExitClick(Sender: TObject);
    procedure mnuHelpAboutClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Login: TVistaLogin;

implementation

{$R *.DFM}

procedure TForm1.btnConnectClick(Sender: TObject);
var
  NChars: Cardinal;
  NameBuffer: PChar;
begin
  if btnConnect.Caption = 'Connect' then
  begin
    { check data there for silent login }
    if (edtAccessCode.Text = '') or
       (edtVerifyCode.Text = '') or
       (edtServer.Text = '') or
       (edtListenerPort.Text = '') then
         ShowMessage('The four Bold edit boxes must be filled in before the connection can be made.')
    else
    begin
      { set up for silent login }
      with BrkrRPCB do
      begin
        Login.AccessCode := edtAccessCode.Text;
        Login.VerifyCode := edtVerifyCode.Text;
        Server := edtServer.Text;
        ListenerPort := StrToInt(edtListenerPort.Text);
        KernelLogin := False;
        Login.Mode := lmAVCodes;
        Login.PromptDivision := True;
        Connected := True;

        if Connected = True then
        begin
          GetUserInfo(brkrRPCB);
          edtDUZ.Text := User.DUZ;
          edtName.Text := User.Name;
          edtDTime.Text := User.DTime;

          { Get local username as well }
          NChars := 0;
          GetUserName(nil,NChars);
          NameBuffer := StrAlloc(NChars);
          if GetUserName(NameBuffer, NChars) then
            edtUserName.Text := StrPas(NameBuffer)
          else
            edtUserName.Text := 'Can''t get name';
          btnConnect.Caption := 'Disconnect';
          btnExit.Default := True;
          btnConnect.Default := False;
        end;  // if Connected = True
      end;  // with brkrRPCB do
    end;  // else
  end  // if btnConnect.Caption
  else
  begin
    brkrRPCB.Connected := False;
    btnConnect.Caption := 'Connect';
  end;
  edtAccessCode.Text := '';
  edtVerifyCode.Text := '';
  Application.ProcessMessages;
end;

procedure TForm1.btnExitClick(Sender: TObject);
begin
  halt;
end;

procedure TForm1.mnuFileExitClick(Sender: TObject);
begin
  halt;
end;

procedure TForm1.mnuHelpAboutClick(Sender: TObject);
begin
  ShowAboutBox;
end;

end.
 
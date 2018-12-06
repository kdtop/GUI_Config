unit fXWBAppHandle2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Trpcb, RpcSLogin, RpcConf1, frmVistAAbout, Menus,
  SharedRPCBroker;

type
  TForm1 = class(TForm)
    edtDuz: TEdit;
    edtName: TEdit;
    edtDTime: TEdit;
    edtUserName: TEdit;
    btnClose: TButton;
    edtDivision: TEdit;
    lblDUZ: TLabel;
    lblName: TLabel;
    lblDTime: TLabel;
    lblDivision: TLabel;
    lblUserName: TLabel;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    About1: TMenuItem;
    About2: TMenuItem;
    brkrRPCB: TSharedRPCBroker;
    procedure FormCreate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure About2Click(Sender: TObject);
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



procedure TForm1.FormCreate(Sender: TObject);
var
  NChars: Cardinal;
  NameBuffer: PChar;
  Server, Port: String;
begin
  { check for silent login data on command line }
  if not CheckCmdLine(brkrRPCB) then
  begin        // Couldn't log on via command line give choice
    if Application.MessageBox('Can''t connect by command line arguments, do you want to connect anyway?','Silent Connection Error', MB_OKCANCEL + MB_DEFBUTTON1) = IDOK then
    begin
      GetServerInfo(Server, Port);
      brkrRPCB.Server := Server;
      brkrRPCB.ListenerPort := StrToInt(Port);
      Caption := 'XWBAppHandle2 - Started by normal sign-on'
    end
    else
      halt;
  end;

  { Get and display information on logged in user }
  GetUserInfo(brkrRPCB);
  edtDUZ.Text := brkrRPCB.User.DUZ;
  edtName.Text := brkrRPCB.User.Name;
  edtDTime.Text := brkrRPCB.User.DTime;
  edtDivision.Text := brkrRPCB.User.Division;

  {also show local username }
  NChars := 0;
  GetUserName(nil,NChars);
  NameBuffer := StrAlloc(NChars);
  if GetUserName(NameBuffer, NChars) then
    edtUserName.Text := NameBuffer
  else
    edtUserName.Text := 'Can''t get name';
end;


procedure TForm1.btnCloseClick(Sender: TObject);
begin
  halt;
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  Halt;
end;

procedure TForm1.About2Click(Sender: TObject);
begin
  ShowAboutBox;
end;

end.

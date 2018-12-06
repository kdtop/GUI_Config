unit fXWBAppHandle1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RpcSlogin, Trpcb, RpcConf1, frmVistAAbout, Menus,
  SharedRPCBroker;

type
  TForm1 = class(TForm)
    btnConnect: TButton;
    btnStartApp2: TButton;
    edtOtherProgram: TEdit;
    lblOtherProgram: TLabel;
    lblOptional: TLabel;
    lblWithFull: TLabel;
    Memo1: TMemo;
    btnExit: TButton;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    brkrRPCB: TSharedRPCBroker;
    procedure btnConnectClick(Sender: TObject);
    procedure btnStartApp2Click(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.btnConnectClick(Sender: TObject);
var
  Server, Port: String;
begin
  if btnConnect.Caption = '&Connect' then
  begin
    GetServerInfo(Server, Port);
    brkrRPCB.Server := Server;
    brkrRPCB.ListenerPort := StrToInt(Port);
    brkrRPCB.Connected := True;
    if brkrRPCB.Connected then
      btnConnect.Caption := '&Disconnect';
  end
  else
  begin
    brkrRPCB.Connected := False;
    btnConnect.Caption := '&Connect';
  end;
end;

procedure TForm1.btnStartApp2Click(Sender: TObject);
var
  CurDir: String;
begin
  if edtOtherProgram.Text <> '' then
  begin
    CurDir := edtOtherProgram.Text;
    StartProgSLogin(CurDir,nil);
  end
  else
  begin
    { Use Test2.exe and expecting it to be in the startup directory for the current application}
    CurDir := ExtractFilePath(ParamStr(0)) + 'XWBAppHandle2.exe';

    { Now start application with silent login }
    StartProgSLogin(CurDir, brkrRPCB);
  end;
end;

procedure TForm1.btnExitClick(Sender: TObject);
begin
  halt;
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  Halt;
end;

procedure TForm1.About1Click(Sender: TObject);
begin
  ShowAboutBox;
end;

end.

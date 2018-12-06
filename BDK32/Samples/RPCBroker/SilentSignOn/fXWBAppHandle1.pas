unit fXWBAppHandle1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RpcSlogin, Trpcb, RpcConf1, frmVistAAbout, Menus, ActnList;

type
  TForm1 = class(TForm)
    brkrRPCB: TRPCBroker;
    btnConnect: TButton;
    btnStartApp2: TButton;
    edtOtherProgram: TEdit;
    lblOtherProgram: TLabel;
    lblOptional: TLabel;
    lblWithFull: TLabel;
    Memo1: TMemo;
    btnExit: TButton;
    mnuMainMenu: TMainMenu;
    mnuFile: TMenuItem;
    mnuFileExit: TMenuItem;
    Help1: TMenuItem;
    mnuAbout: TMenuItem;
    mnuOptions: TMenuItem;
    OnlyOldConnection1: TMenuItem;
    ActionList1: TActionList;
    actOldConnectionOnly: TAction;
    actBackwardsCompatible: TAction;
    actDebugMode: TAction;
    BackwardsCompatible1: TMenuItem;
    DebugMode1: TMenuItem;
    procedure btnConnectClick(Sender: TObject);
    procedure btnStartApp2Click(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure mnuFileExitClick(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure actOldConnectionOnlyExecute(Sender: TObject);
    procedure actBackwardsCompatibleExecute(Sender: TObject);
    procedure actDebugModeExecute(Sender: TObject);
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
    begin
      btnConnect.Caption := '&Disconnect';
      mnuOptions.Enabled := False;
    end;
  end
  else
  begin
    brkrRPCB.Connected := False;
    btnConnect.Caption := '&Connect';
    mnuOptions.Enabled := True;
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

procedure TForm1.mnuFileExitClick(Sender: TObject);
begin
  Halt;
end;

procedure TForm1.mnuAboutClick(Sender: TObject);
begin
  ShowAboutBox;
end;

procedure TForm1.actOldConnectionOnlyExecute(Sender: TObject);
begin
  if actOldConnectionOnly.Checked then
  begin
    actOldConnectionOnly.Checked := False;
    brkrRPCB.OldConnectionOnly := False;
  end
  else
  begin
    actOldConnectionOnly.Checked := True;
    brkrRPCB.OldConnectionOnly := True;
  end;
end;

procedure TForm1.actBackwardsCompatibleExecute(Sender: TObject);
begin
  if actBackwardsCompatible.Checked then
  begin
    actBackwardsCompatible.Checked := False;
    brkrRPCB.IsBackwardCompatibleConnection := False;
  end
  else
  begin
    brkrRPCB.IsBackwardCompatibleConnection := True;
    actBackwardsCompatible.Checked := True;
  end;
end;

procedure TForm1.actDebugModeExecute(Sender: TObject);
begin
  if actDebugMode.Checked then
  begin
    actDebugMode.Checked := False;
    brkrRPCB.DebugMode := False;
  end
  else
  begin
    brkrRPCB.DebugMode := True;
    actDebugMode.Checked := True;
  end;
end;

end.

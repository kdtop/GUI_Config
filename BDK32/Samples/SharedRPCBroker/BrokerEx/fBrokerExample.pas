{**************************************************
RPC Broker Example form      ver. 1.1  9/3/97
   Broker Development Team
   San Francisco IRM Field Office, Dept. of Veterans Affairs

Disclaimer:
   This example does not attempt to teach general Delphi and M programming.
   We intentionally removed any safeguards from the code that prevents
   passing values that are too small or too large.  Therefore, the important
   code remains uncluttered and the programmer is free to experiment and
   push the program beyond its limits.

Purpose:
   This sample application is an example of how to program client/server
   applications in Delphi and M using the RPC Broker. The demonstrated features
   include:
     - Connecting to an M server
     - Creating an application context
     - Using the GetServerInfo function
     - Displaying the VistA splash screen
     - Setting the TRPCBroker Param property for each Param PType (literal,
       reference, list)
     - Calling RPCs with the Call method
     - Calling RPCs with the lstCall and strCall methods

   We encourage you to study the Delphi and M source code to see how the
   Broker is used to accomplish these tasks.  Try changing some of the
   RPCBroker1 component properties to see what happens.  Also, try other
   values in the fields of the remote procedure records in the
   REMOTE PROCEDURE file.

Warning: "Get list" and "Sort numbers" tabs can potentially take excessively
large data samples which can either crash server process or cause the
connection timeout.  Final note, memory allocation errors are not recorded
in the Kernel error trap.  They are recorded in the operating system error
trap.

Context option for this application:
   XWB BROKER EXAMPLE

Remote procedures used:
   XWB EXAMPLE ECHO STRING
   XWB EXAMPLE GET LIST
   XWB EXAMPLE SORT NUMBERS
   XWB EXAMPLE WPTEXT
   XWB GET VARIABLE VALUE

Server M routine:
   XWBEXMPL
**************************************************}
unit fBrokerExample;

interface

uses
  SysUtils,Forms, StdCtrls,Graphics, Dialogs, WinTypes,
  Controls, Classes, ExtCtrls, TRPCB, XWBut1, MFunStr, Menus, WinProcs,
  RpcConf1, Spin, ComCtrls, BrokerExampleAboutFrm, Buttons,
  ActiveX, SharedRPCBroker;

type
  TfrmBrokerExample = class(TForm)
    GroupBox2: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    MainMenu1: TMainMenu;
    Help1: TMenuItem;
    AboutExample: TMenuItem;
    btnConnect: TButton;
    edtPort: TEdit;
    edtServer: TEdit;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    lblSend: TLabel;
    edtStrOrig: TEdit;
    lblReturn: TLabel;
    edtStrRtrn: TEdit;
    btnEchoString: TButton;
    lblList: TLabel;
    Label1: TLabel;
    edtReference: TEdit;
    Label4: TLabel;
    edtValue: TEdit;
    btnPassByRef: TButton;
    lstData: TListBox;
    Label5: TLabel;
    btnGetList: TButton;
    btnWPText: TButton;
    Label6: TLabel;
    lstSorted: TListBox;
    btnSortNum: TButton;
    spnNumbers: TSpinEdit;
    Label7: TLabel;
    rgrDirection: TRadioGroup;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    spnLines: TSpinEdit;
    spnKbytes: TSpinEdit;
    Timer1: TTimer;
    mmoText: TMemo;
    lblStatus: TLabel;
    BitBtn1: TBitBtn;
    btnGetServerInfo: TBitBtn;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    Memo5: TMemo;
    RPCBroker1: TSharedRPCBroker;
    procedure AboutExampleClick(Sender: TObject);
    procedure btnEchoStringClick(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure btnPassByRefClick(Sender: TObject);
    procedure btnGetListClick(Sender: TObject);
    procedure btnSortNumClick(Sender: TObject);
    procedure btnWPTextClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnGetServerInfoClick(Sender: TObject);
    procedure edtServerChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
end;



var
  frmBrokerExample: TfrmBrokerExample;


implementation

{$R *.DFM}

procedure TfrmBrokerExample.btnEchoStringClick(Sender: TObject);
begin
  RPCBroker1.RemoteProcedure := 'XWB EXAMPLE ECHO STRING';
  RPCBroker1.Param[0].Value := edtStrOrig.Text;
  RPCBroker1.Param[0].PType := literal;
  RPCBroker1.Call;                           //execute RPC
  edtStrRtrn.Text := RPCBroker1.Results[0];  //for single value use Results[0]
end;



procedure TfrmBrokerExample.btnPassByRefClick(Sender: TObject);
begin
  RPCBroker1.RemoteProcedure := 'XWB GET VARIABLE VALUE';
  RPCBroker1.Param[0].Value := edtReference.Text;
  RPCBroker1.Param[0].PType := reference;
  edtValue.Text := RPCBroker1.strCall;   //execute RPC and show result in one call
end;



procedure TfrmBrokerExample.btnGetListClick(Sender: TObject);
begin
  RPCBroker1.RemoteProcedure := 'XWB EXAMPLE GET LIST';
  if RadioButton1.Checked then begin
    RPCBroker1.Param[0].Value := 'LINES';
    RPCBroker1.Param[0].PType := literal;
    RPCBroker1.Param[1].Value := IntToStr(spnLines.Value);
    RPCBroker1.Param[1].PType := literal;
  end
  else begin
    RPCBroker1.Param[0].Value := 'KILOBYTES';
    RPCBroker1.Param[0].PType := literal;
    RPCBroker1.Param[1].Value := IntToStr(spnKbytes.Value);
    RPCBroker1.Param[1].PType := literal
  end;
  RPCBroker1.Call;                           //execute RPC
  lstData.Items := RPCBroker1.Results;       //show results of the call
end;



procedure TfrmBrokerExample.btnWPTextClick(Sender: TObject);
begin
  RPCBroker1.RemoteProcedure := 'XWB EXAMPLE WPTEXT';
  RPCBroker1.lstCall(mmoText.Lines);         //execute RPC and show results in one call
end;



procedure TfrmBrokerExample.btnSortNumClick(Sender: TObject);
var
  I, SaveRPCTimeLimit: integer;
begin
  lblStatus.Visible := True;                 //turn on status label
  lblStatus.Caption := 'building';           //tell user what's happenning
  Application.ProcessMessages;               //give Windows chance to paint
  with RPCBroker1 do begin
    RemoteProcedure := 'XWB EXAMPLE SORT NUMBERS';
    if rgrDirection.ItemIndex = 0 then Param[0].Value := 'LO'
    else Param[0].Value := 'HI';
    Param[0].PType := literal;
    with Param[1] do begin
      PType := list;                                //tells Broker to pass Mult
        for I := 0 to spnNumbers.Value - 1 do       //build Mult one by one
          Mult[IntToStr(Random(10000)+1)] := IntToStr(I); //subscript and value are strings!
    end;
    lblStatus.Caption := 'RPC running';
    Application.ProcessMessages;             //give Windows chance to paint
    SaveRPCTimeLimit := RPCTimeLimit;
    RPCTimeLimit := spnNumbers.Value div 10; //adjust in case a lot of numbers
    Call;                                    //execute RPC
    lstSorted.Items := Results;              //show results of the call
    RPCTimeLimit := SaveRPCTimeLimit;        //restore original value
  end;
  lblStatus.Visible := False;                //turn off status label
end;



procedure TfrmBrokerExample.btnConnectClick(Sender: TObject);
begin
  if btnConnect.Caption = '&Connect' then
  begin   //connect
    RPCBroker1.ClearParameters := True;           //try False, see what happens
    try
      RPCBroker1.Connected := True;
                     //establish connection
      if not RPCBroker1.CreateContext('XWB BROKER EXAMPLE') then
          ShowMessage('Context could not be created!');
    except
      on e: Exception do
        ShowMessage('Error: ' + e.Message);
    end;
  end
  else                                            //disconnect
    RPCBroker1.Connected := False;
end;



procedure TfrmBrokerExample.btnGetServerInfoClick(Sender: TObject);
var
  strServer, strPort: string;
begin
  if GetServerInfo(strServer, strPort)<> mrCancel then
  begin {getsvrinfo}
    edtServer.Text := strServer;                  //use chosen server
    edtPort.Text := strPort;                      //use chosen port
  end;
end;



procedure TfrmBrokerExample.edtServerChange(Sender: TObject);
begin
  RPCBroker1.Server := edtServer.Text;          //use specified server name/addr
  RPCBroker1.ListenerPort := StrToInt(edtPort.Text);  //use specified port
end;



procedure TfrmBrokerExample.Timer1Timer(Sender: TObject);
begin
  if RPCBroker1.Connected then begin
    btnConnect.Caption := '&Disconnect';
    btnConnect.Default := False;
    Label3.Caption := 'Connected';
    Label3.Font.Color := clLime;  // clGreen;  // went to lime for higher contrast at some of the High contrast desktops
  end
  else begin
    btnConnect.Caption := '&Connect';
    btnConnect.Default := True;
    Label3.Caption := 'Disconnected';
    Label3.Font.Color := clRed;   //  Stayed with Red, generated a high contrast across all of the various combinations
                                  //  Attempted to use clHighlight, but it did not show up like a highlight.
  end;
end;



procedure TfrmBrokerExample.AboutExampleClick(Sender: TObject);
begin
  AboutBox.Show;
end;


procedure TfrmBrokerExample.FormCreate(Sender: TObject);
begin
  CoInitialize(nil);
end;

end.



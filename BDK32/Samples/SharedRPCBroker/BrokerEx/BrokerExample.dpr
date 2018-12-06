program BrokerExample;

uses
  Forms,
  fBrokerExample in 'fBrokerExample.pas' {frmBrokerExample},
  SplVista,
  fSgnonDlg in '..\..\Source\fSgnonDlg.pas' {frmSignonDialog};

// include to display Vista splash

{$R *.RES}

begin
  Application.CreateForm(TfrmBrokerExample, frmBrokerExample);
  Application.CreateForm(TfrmSignonDialog, frmSignonDialog);
  SplashOpen;                                    // display splash screen
  SplashClose(3000);                             // min splash time 3 seconds, then close
  Application.Run;
end.

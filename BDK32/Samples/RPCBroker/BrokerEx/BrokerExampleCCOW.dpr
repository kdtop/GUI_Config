program BrokerExampleCCOW;

uses
  Forms,
  fBrokerExampleCCOW in 'fBrokerExampleCCOW.pas' {frmBrokerExampleCCOW},
  SplVista,
  fOkToTerminate in 'fOkToTerminate.pas' {frmOKToTerminate};

// include to display Vista splash

{$R *.RES}

begin
  Application.CreateForm(TfrmBrokerExampleCCOW, frmBrokerExampleCCOW);
  Application.CreateForm(TfrmOKToTerminate, frmOKToTerminate);
  SplashOpen;                                    // display splash screen
  SplashClose(3000);                             // min splash time 3 seconds, then close
  Application.Run;
end.

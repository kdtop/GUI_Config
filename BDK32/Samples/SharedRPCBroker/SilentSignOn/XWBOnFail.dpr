program XWBOnFail;

uses
  Forms,
  fXWBOnFail in 'fXWBOnFail.pas' {frmXWBOnFail};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmXWBOnFail, frmXWBOnFail);
  Application.Run;
end.

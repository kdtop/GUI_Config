program XWBAVCodes;

uses
  Forms,
  fXWBAVCodes in 'fXWBAVCodes.pas' {Form1},
  frmVistAAbout in 'frmVistAAbout.pas' {frmVistAAbout};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Test4Silent';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

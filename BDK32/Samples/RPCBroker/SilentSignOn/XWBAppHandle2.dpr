program XWBAppHandle2;

uses
  Forms,
  fXWBAppHandle2 in 'fXWBAppHandle2.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

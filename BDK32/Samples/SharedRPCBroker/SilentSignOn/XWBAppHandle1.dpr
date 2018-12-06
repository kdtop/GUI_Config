program XWBAppHandle1;

uses
  Forms,
  fXWBAppHandle1 in 'fXWBAppHandle1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

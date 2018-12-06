program DlgTemp;

uses
  Forms,
  Unit1 in 'C:\Program Files\Borland\Delphi7\Projects\Killthis\Unit1.pas' {Form1},
  RemDlgCreator in 'RemDlgCreator.pas',
  XML2Dlg in 'XML2Dlg.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.


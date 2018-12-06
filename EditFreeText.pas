unit EditFreeText;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TEditFreeTextForm = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    TextToEdit: TEdit;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//var
  //EditFreeTextForm: TEditFreeTextForm;

implementation

uses SelDateTimeU;

{$R *.dfm}

procedure TEditFreeTextForm.FormShow(Sender: TObject);
var mousePos : TPoint;
  begin
    GetCursorPos(mousePos);
    Top := mousePos.Y - 39;
    Left := mousePos.X - TextToEdit.Left - TextToEdit.Width;
    if Left + Width > Screen.DesktopWidth then begin
      Left := Screen.DesktopWidth - Width;
    end;
    TextToEdit.SetFocus;
  end;


end.


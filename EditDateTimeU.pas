unit EditDateTimeU;
(* WorldVistA Configuration Utility
   (c) 8/2008.  Released under LGPL
   Programmed by Kevin Toppenberg, Eddie Hagood  *)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls;

type
  TEditDateTimeForm = class(TForm)
    DateTimePicker: TDateTimePicker;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    btnNone: TButton;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//var
  //EditDateTimeForm: TEditDateTimeForm;

implementation


{$R *.dfm}

  procedure TEditDateTimeForm.FormShow(Sender: TObject);
    var mousePos : TPoint;
  begin
    GetCursorPos(mousePos);
    Top := mousePos.Y - 39;
    Left := mousePos.X - 15;
    if Left + Width > Screen.DesktopWidth then begin
      Left := Screen.DesktopWidth - Width;
    end;
    DateTimePicker.SetFocus;
  end;

end.


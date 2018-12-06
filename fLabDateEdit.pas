unit fLabDateEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls;

type
  TfrmLabDateEdit = class(TForm)
    lblDTCompleted: TLabel;
    dtpDate: TDateTimePicker;
    btnCancel: TBitBtn;
    btnApply: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure dtpDTPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure InitDate(DateStr : string);
  end;

//var
//  frmLabDateEdit: TfrmLabDateEdit;  //not-autocreated

implementation

{$R *.dfm}

procedure TfrmLabDateEdit.dtpDTPress(Sender: TObject;var Key: Char);
  //method to call dropdown
  procedure SimClick(Obj : TWinControl);
  var x,y,lparam : integer;
  begin
    x := Obj.Width - 10;
    y := Obj.Height div 2;
    lParam := y*$10000 + x;
    PostMessage(Obj.Handle, WM_LBUTTONDOWN, 1, lParam);
    PostMessage(Obj.Handle, WM_LBUTTONUP, 1, lParam);
  end;

begin
  if Key = char(VK_SPACE) then begin
    SimClick(Sender as TWinControl);
    Key := char(0);
  end else if Key = char(VK_RETURN) then begin
     Key := char(VK_TAB);
  end;
end;

procedure TfrmLabDateEdit.FormShow(Sender: TObject);
var mousePos : TPoint;
begin
  GetCursorPos(mousePos);
  Top := mousePos.Y - Self.Height div 2;
  Left := mousePos.X - Self.Width div 2;
  if Left + Width > Screen.DesktopWidth then begin
    Left := Screen.DesktopWidth - Width;
  end;
  dtpDate.SetFocus;
end;

procedure TfrmLabDateEdit.InitDate(DateStr : string);
begin
  if DateStr ='' then DateStr := '1/1/2010';
  dtpDate.Date := StrToDate(DateStr);
end;


end.

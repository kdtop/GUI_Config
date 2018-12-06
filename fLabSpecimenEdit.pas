unit fLabSpecimenEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ORCtrls, ORFn;

type
  TfrmSpecimenEdit = class(TForm)
    lblSpecimen: TLabel;
    cboSpecimen: TORComboBox;
    btnCancel: TBitBtn;
    btnApply: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure cboSpecimenNeedData(Sender: TObject; const StartFrom: string;
      Direction, InsertAt: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Initialize(Str : string; IEN : int64);
    function SelectedSpecimen : string;
    function SelectedIEN : int64;
  end;

//var
//  frmSpecimenEdit: TfrmSpecimenEdit;  //not auto-created

implementation

{$R *.dfm}

uses
  fLabEntryDetails;

procedure TfrmSpecimenEdit.Initialize(Str : string; IEN : int64);
begin
  cboSpecimen.InitLongList(Str);
  cboSpecimen.SelectByIEN(IEN);
end;

function TfrmSpecimenEdit.SelectedSpecimen : string;
var Index : integer;
begin
  Result := '';
  Index := cboSpecimen.ItemIndex;
  if Index >= 0 then begin
    Result := piece(cboSpecimen.Items[Index],'^',3);
  end;
end;

function TfrmSpecimenEdit.SelectedIEN : int64;
begin
  Result := 0;
  if cboSpecimen.ItemIEN > 0 then begin
    Result := cboSpecimen.ItemIEN;
  end;
end;

procedure TfrmSpecimenEdit.cboSpecimenNeedData(Sender: TObject;
  const StartFrom: string; Direction, InsertAt: Integer);
begin
  (Sender as TORComboBox).ForDataUse(SubSetOfSpecimens(StartFrom, Direction));
end;

procedure TfrmSpecimenEdit.FormShow(Sender: TObject);
var mousePos : TPoint;
begin
  GetCursorPos(mousePos);
  Top := mousePos.Y - Self.Height div 2;
  Left := mousePos.X - Self.Width div 2;
  if Left + Width > Screen.DesktopWidth then begin
    Left := Screen.DesktopWidth - Width;
  end;
  cboSpecimen.SetFocus;
end;

end.

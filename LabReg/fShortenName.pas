unit fShortenName;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmShortenName = class(TForm)
    edtEdit: TEdit;
    btnOK: TButton;
    Label1: TLabel;
    Label2: TLabel;
    lblOrigName: TLabel;
    lblMaxLen: TLabel;
    lblCurrentLength: TLabel;
    btnCancel: TButton;
    procedure edtEditChange(Sender: TObject);
  private
    { Private declarations }
    MaxLen : integer;
  public
    { Public declarations }
    ResultName : string;
    procedure Initialize(OriginalName : string; MaxLength : integer);
  end;

//var frmShortenName: TfrmShortenName;

implementation

{$R *.dfm}

procedure TfrmShortenName.edtEditChange(Sender: TObject);
var Len : integer;
begin
  Len := Length(edtEdit.Text);
  lblCurrentLength.Caption := 'Current length is ' + IntToStr(Len);
  btnOK.Enabled := (Len <= MaxLen);
  if Len > MaxLen then begin
    edtEdit.Color := clRed;
    lblCurrentLength.Caption := lblCurrentLength.Caption + ' (too long)';
  end else begin
    edtEdit.Color := clYellow;
  end;
  ResultName := edtEdit.Text;
end;

procedure TfrmShortenName.Initialize(OriginalName : string; MaxLength : integer);
begin
  ResultName := OriginalName;
  MaxLen := MaxLength;
  lblMaxLen.Caption := 'Must be ' + IntToStr(MaxLength) + ' characters or less in length';
  lblOrigName.Caption := OriginalName;
  edtEdit.Text := OriginalName;
end;


end.


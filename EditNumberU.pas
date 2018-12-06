unit EditNumberU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TEditNumber = class(TForm)
    NumToEdit: TEdit;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    lblInstructions: TLabel;
    procedure NumToEditChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    NumDigits  : integer;
    NumDecimals : integer;
  public
    { Public declarations }
    procedure Initialize(FieldDef : string);
  end;

//var
//  EditNumber: TEditNumber;

implementation

uses SelDateTimeU;

{$R *.dfm}

  procedure TEditNumber.Initialize(FieldDef : string);
  begin
    //here I need to setup allowed digits etc.
  end;

  procedure TEditNumber.FormShow(Sender: TObject);
  var mousePos : TPoint;
  begin
    GetCursorPos(mousePos);
    Top := mousePos.Y - 39;
    Left := mousePos.X - 15;
    if Left + Width > Screen.DesktopWidth then begin
      Left := Screen.DesktopWidth - Width;
    end;
    NumToEdit.SetFocus;
  end;

  procedure TEditNumber.NumToEditChange(Sender: TObject);
  begin
    //here I need to check validity of value.
  end;

end.

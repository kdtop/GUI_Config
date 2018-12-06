unit fMemoEdit;
//kt 9/11 Added entire unit
//This is a simple TMemo editor

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TfrmMemoEdit = class(TForm)
    memEdit: TMemo;
    btnDone: TBitBtn;
    lblMessage: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMemoEdit: TfrmMemoEdit;

implementation

{$R *.dfm}

end.


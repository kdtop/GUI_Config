unit DebugU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TDebugForm = class(TForm)
    Memo: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    btnHide: TButton;
    btnClear: TButton;
    procedure btnClearClick(Sender: TObject);
    procedure btnHideClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DebugForm: TDebugForm;

implementation

{$R *.dfm}

procedure TDebugForm.btnClearClick(Sender: TObject);
begin
  Memo.Lines.Clear;
end;

procedure TDebugForm.btnHideClick(Sender: TObject);
begin
  DebugForm.Hide;
end;

end.


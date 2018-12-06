unit fTaxonomyDisplay;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, rRPCsU,
  ORNet, ORFn, Trpcb, FMErrorU;

type
  TfrmTaxonomyDisplay = class(TForm)
    pnlBottom: TPanel;
    DoneBtn: TBitBtn;
    Memo: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Initialize(IEN : string);
  end;

var
  frmTaxonomyDisplay: TfrmTaxonomyDisplay;

implementation

{$R *.dfm}

procedure TfrmTaxonomyDisplay.Initialize(IEN : string);
begin
  TaxonomyInquire(IEN, Memo.Lines);
end;

end.

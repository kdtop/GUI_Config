unit fReminderDefFilter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TfrmRemDefFilters = class(TForm)
    cbCPRS: TCheckBox;
    Label1: TLabel;
    cbRemPatList: TCheckBox;
    cbPatient: TCheckBox;
    cbRemReports: TCheckBox;
    cbRemExtracts: TCheckBox;
    cbAlmostAll: TCheckBox;
    btnCancel: TBitBtn;
    btnDone: TBitBtn;
    procedure cbAlmostAllClick(Sender: TObject);
    procedure cbRemPatListClick(Sender: TObject);
    procedure cbCPRSClick(Sender: TObject);
  private
    { Private declarations }
    procedure SetLTrue;
    procedure SetStarTrue;
  public
    { Public declarations }
    procedure Initialize(Flags : string);
    function UserChosenFlags : string;
  end;

//var
//  frmRemDefFilters: TfrmRemDefFilters;

implementation

{$R *.dfm}

procedure TfrmRemDefFilters.cbAlmostAllClick(Sender: TObject);
begin
  if not (Sender is TCheckbox) then exit;
  if TCheckBox(Sender).Checked then begin
    SetStarTrue;
  end;
end;

procedure TfrmRemDefFilters.cbCPRSClick(Sender: TObject);
begin
  if not (Sender is TCheckbox) then exit;
  if TCheckBox(Sender).Checked then begin
    cbRemPatList.Checked := False;
  end;
end;

procedure TfrmRemDefFilters.cbRemPatListClick(Sender: TObject);
begin
  if not (Sender is TCheckbox) then exit;
  if TCheckBox(Sender).Checked then begin
    SetLTrue;
  end;
end;

procedure TfrmRemDefFilters.SetLTrue;
begin
  cbCPRS.Checked := False;
  cbPatient.Checked := False;
  cbRemReports.Checked := False;
  cbRemExtracts.Checked := False;
  cbAlmostAll.Checked := False;
end;

procedure TfrmRemDefFilters.SetStarTrue;
begin
  cbCPRS.Checked := True;
  cbRemPatList.Checked := false;
  cbPatient.Checked := False;
  cbRemReports.Checked := True;
  cbRemExtracts.Checked := True;
  cbAlmostAll.Checked := True;
end;


procedure TfrmRemDefFilters.Initialize(Flags : string);
var i : integer;
begin
  for i := 1 to length(Flags) do begin
    case Flags[i] of
      'C' : cbCPRS.Checked := true;
      'L' : cbRemPatList.Checked := True;
      'P' : cbPatient.Checked := true;
      'R' : cbRemReports.Checked := True;
      'X' : cbRemExtracts.Checked := true;
      '*' : cbAlmostAll.Checked := true;
    end; {case}
  end;
end;

function TfrmRemDefFilters.UserChosenFlags : string;
begin
  Result := '';
  if cbCPRS.Checked        then Result := Result + 'C';
  if cbRemPatList.Checked  then Result := Result + 'L';
  if cbPatient.Checked     then Result := Result + 'P';
  if cbRemReports.Checked  then Result := Result + 'R';
  if cbRemExtracts.Checked then Result := Result + 'X';
  if cbAlmostAll.Checked   then Result := Result + '*';
end;



end.

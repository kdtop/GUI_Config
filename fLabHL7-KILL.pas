unit fLabHL7;

   (*
   WorldVistA Configuration Utility
   (c) 2/2013 Kevin Toppenberg
   Programmed by Kevin Toppenberg, Eddie Hagood

   Family Physicians of Greeneville, PC
   1410 Tusculum Blvd, Suite 2600
   Greeneville, TN 37745
   kdtop@yahoo.com

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
  *)


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils;

type
  TAlertInfo = class(TObject)
  private
  public
    HL7Message : TStringList;
    procedure Load(RawData : TStringList);
    procedure RPCLoad(WhichOne : string);
    procedure Clear;
    constructor Create;
    destructor Destroy;
  end;

  TfrmHandleHL7FilingErrors = class(TForm)
    lbHL7Message: TListBox;
    cboAvailAlerts: TComboBox;
    pnlLeft: TPanel;
    Splitter1: TSplitter;
    pnlRight: TPanel;
    PageControl1: TPageControl;
    tsTransform: TTabSheet;
    tsLabMap: TTabSheet;
    tsAlert: TTabSheet;
    Button1: TButton;
    memInstructions: TMemo;
    lblDisplay: TLabel;
    edtEdit: TEdit;
    btnOK: TButton;
    procedure edtEditChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure pnlLeftResize(Sender: TObject);
    procedure cboAvailAlertsChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    HL7MessagePixelWidth : integer;
    AlertComboData : TStringList;
    AlertInfo : TAlertInfo;
    function GetAlertData : string;
    procedure LoadAvailCombo;
    procedure SyncDisplay;
    procedure HandleGUIAction(Messages : TStringList);
    procedure ParseParms(Messages,OutSL : TStringList);
    procedure TrimName(Params : TStringList);
  public
    { Public declarations }
  end;

//var
//  frmHandleHL7FilingErrors: TfrmHandleHL7FilingErrors;   //not auto-created

implementation

uses
  ORFn, rHL7RPCsU, FMErrorU;

{$R *.dfm}

//========================================================================
procedure TAlertInfo.Clear;
begin
  HL7Message.Clear;
end;

function LMatch(Str,SubStr : string) : boolean;
begin
  Result := (Pos(SubStr, Str)=1);
end;

procedure TAlertInfo.Load(RawData : TStringList);
var i : integer;
    s,value : string;
begin
  Clear;
  for i := 0 to RawData.Count - 1 do begin
    s := RawData.Strings[i];
    value := Piece(s,'=',2);
    if LMatch(s,'TMGMSG') then self.HL7Message.Add(value)
  end;
end;

procedure TAlertInfo.RPCLoad(WhichOne : string);
var
  RawData : TStringList;
begin
  RawData := TStringList.Create;
  if WhichOne <> '' then GetAlertData(RawData, WhichOne);
  Self.Load(RawData);
  RawData.Free;
end;

constructor TAlertInfo.Create;
begin
  Inherited Create;
  HL7Message := TStringList.Create;
end;

destructor TAlertInfo.Destroy;
begin
  HL7Message.Free;
end;

//========================================================================
procedure TfrmHandleHL7FilingErrors.FormCreate(Sender: TObject);
begin
  AlertComboData := TStringList.Create;
  AlertInfo := TAlertInfo.Create;
  LoadAvailCombo;
end;

procedure TfrmHandleHL7FilingErrors.FormDestroy(Sender: TObject);
begin
  AlertComboData.Free;
  AlertInfo.Free;
end;

procedure TfrmHandleHL7FilingErrors.LoadAvailCombo;
var i : integer;
    FMDT : string;
    FDateTime : double;
begin
  GetAvailAlertsList(AlertComboData);
  cboAvailAlerts.Items.Clear;
  for i := 0 to AlertComboData.Count - 1 do begin
    FMDT := piece(AlertComboData.Strings[i],'^',4);
    FDateTime := StrToFloatDef(FMDT,0);
    if FDateTime <> 0 then begin
      FMDT := FormatFMDateTime('mmm dd,yy hh:nn', FDateTime);
    end else begin
      FMDT := '<invalid date>';
    end;
    cboAvailAlerts.Items.Add('Alert: '+FMDT);
  end;
  cboAvailAlerts.ItemIndex := cboAvailAlerts.Items.Count-1;
  cboAvailAlertsChange(self);
end;


procedure TfrmHandleHL7FilingErrors.pnlLeftResize(Sender: TObject);
begin
  SendMessage(lbHL7Message.Handle, LB_SETHORIZONTALEXTENT, HL7MessagePixelWidth, 0);
end;

procedure TfrmHandleHL7FilingErrors.Button1Click(Sender: TObject);
var WhichOne, Data : string;
    Messages : TStringList;
    Action : string;
begin
  Messages := TStringList.Create;
  Data := GetAlertData;
  WhichOne := Pieces(Data,'^',2,3);
  Action := Process(Messages, WhichOne);
  if Action='GUI ACTION NEEDED' then HandleGUIAction(Messages);
  Messages.Free;
end;

function TfrmHandleHL7FilingErrors.GetAlertData : string;
begin
  Result := '';
  if cboAvailAlerts.ItemIndex > -1 then Result := AlertComboData.Strings[cboAvailAlerts.ItemIndex];
end;


procedure TfrmHandleHL7FilingErrors.cboAvailAlertsChange(Sender: TObject);
var WhichOne, Data : string;
begin
  HL7MessagePixelWidth := 0;
  Data := GetAlertData;
  WhichOne := Pieces(Data,'^',2,3);
  AlertInfo.RPCLoad(WhichOne);
  SyncDisplay;
end;

procedure TfrmHandleHL7FilingErrors.SyncDisplay;
//Put data in AlertInfo object into display elements.
var i : integer;
    Line : string;
    width : integer;
begin
  lbHL7Message.Items.Clear;
  HL7MessagePixelWidth := 0;
  for i := 0 to AlertInfo.HL7Message.Count -1 do begin
    Line := AlertInfo.HL7Message.Strings[i];
    lbHL7Message.Items.Add(Line);
    width := lbHL7Message.Canvas.TextWidth(Line) + 100;
    if width > HL7MessagePixelWidth then HL7MessagePixelWidth := width;
  end;
  SendMessage(lbHL7Message.Handle, LB_SETHORIZONTALEXTENT, HL7MessagePixelWidth, 0);
end;

procedure TfrmHandleHL7FilingErrors.HandleGUIAction(Messages : TStringList);
var Cmd : string;
    Params : TStringList;
begin
  if Messages.Count = 0 then exit;
  Params := TStringList.Create;
  Cmd := Messages.Strings[0];
  ParseParms(Messages, Params);
  if Pos('TRIMNAME^TMGHL70B',Cmd)>0 then begin
    TrimName(Params);
  end else if Pos('PCKADD60^TMGHL70C',Cmd)>0 then begin
  end else if Pos('ASKSPEC^TMGHL70C',Cmd)>0 then begin
  end else if Pos('ASKWKLD^TMGHL70C',Cmd)>0 then begin
  end else if Pos('LINKDN^TMGHL70C',Cmd)>0 then begin
  end else if Pos('ASKSPEC2^TMGHL70C',Cmd)>0 then begin
  end else begin
    MessageDlg('Unhandled message: '+Cmd,mtError,[mbOK],0);
  end;
  Params.Free;
end;

procedure TfrmHandleHL7FilingErrors.ParseParms(Messages, OutSL : TStringList);
  function PosNotInQt(var S : string; Ch : char; StartIdx : integer=1) : integer;
  var  i : integer;
       InQt : boolean;
       ACh : char;
  begin
    Result := -1;
    InQt := false;
    for i := StartIdx to Length(S) do begin
      ACh := S[i];
      if ACh = '"' then begin
        InQt := not InQt;
        continue;
      end else if InQt then continue;
      if ACh <> Ch then continue;
      Result := i;
      break;
    end;
  end;

var p1, p2, i : integer;
    Args, Cmd, OneArg : string;

begin
  OutSL.Clear;
  if Messages.Count = 0 then exit;
  Cmd := Trim(Messages.Strings[0]);
  p1 := Pos('(',Cmd);  if p1 < 1 then exit;
  p2 := Length(Cmd); if Cmd[p2] <> ')' then exit;
  Args := MidStr(Cmd, p1+1, p2-p1-1);

  while (Args <> '') do begin
    p1 := PosNotInQt(Args, ',');
    if p1 = -1 then begin
      OutSL.Add(Args);
      Args := ''
    end else begin
      OneArg := MidStr(Args,1, P1-1);
      OutSL.Add(OneArg);
      Args := MidStr(Args, p1+1, Length(Args));
    end;
  end;
  for i := 0 to OutSL.Count - 1 do begin
    OneArg := OutSL.Strings[i];
    if OneArg = '' then continue;
    if OneArg[1] <> '"' then continue;
    if OneArg[Length(OneArg)] <> '"' then continue;
    OneArg := MidStr(OneArg, 2, Length(OneArg)-2);
    OutSL.Strings[i] := OneArg;
  end;
end;


procedure TfrmHandleHL7FilingErrors.TrimName(Params : TStringList);
var S : string;
begin
  //FMErrorForm.Memo.Lines.Assign(Messages);
  //FMErrorForm.PrepMessage;
  //FMErrorForm.ShowModal;

  if Params.Count > 0 then begin
    s := Params.Strings[0];
  end else begin
    MessageDlg('No string found to shorten', mtError, [mbOK],0);
    exit;
  end;


  memInstructions.Visible := true;
  lblDisplay.Visible := true;
  edtEdit.Visible := true;
  btnOK.Visible := true;

  memInstructions.Lines.Add('Please shorten test name to 30 characters.');
  lblDisplay.Caption := s;
  edtEdit.Text := s;
  edtEditChange(self);
end;


procedure TfrmHandleHL7FilingErrors.edtEditChange(Sender: TObject);
begin
  if Length(edtEdit.Text) > 30 then begin
    edtEdit.Color := clRed;
  end else begin
    edtEdit.Color := clYellow;
  end;
end;


end.


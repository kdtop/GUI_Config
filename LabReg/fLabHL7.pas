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
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Menus, fxBroker;

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
    btnProcessHL7: TButton;
    MainMenu1: TMainMenu;
    Help1: TMenuItem;
    ShowBrokerLog: TMenuItem;
    procedure ShowBrokerLogClick(Sender: TObject);
    procedure btnProcessHL7Click(Sender: TObject);
    procedure pnlLeftResize(Sender: TObject);
    procedure cboAvailAlertsChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    HL7MessagePixelWidth : integer;
    AlertComboData : TStringList;
    AlertInfo : TAlertInfo;
    PriorSpecimenName : string;
    CumulativeClientServerMessages : TStringList;
    function GetAlertData : string;
    procedure LoadAvailAlerts;
    procedure LoadAvailCombo;
    procedure SyncDisplay;
    procedure AddCumulativeServerMsg(Msg, Reply: string);
    function HandleGUIAction(ServerMessages : TStringList) : integer;  //returns mrResult type
    procedure ParseParms(ServerMessages, OutSL, Vars : TStringList);
    function TrimName(Params : TStringList) : string;
    function PickAddToFile60(Params : TStringList) : string;
    function PickAddWorkLoad(Params, Vars : TStringList) : string;
    function PickSpecimen(Params : TStringList) : string;
    function PickSpec2(Params : TStringList; PriorSpecimenName : string) : string;
    function LinkDataName(Params : TStringList) : string;
    function TrimQuotes(s : string) : string;
    function ProcessHL7 : integer;  //returns mrResult type
  public
    { Public declarations }
  end;

//var
//  frmHandleHL7FilingErrors: TfrmHandleHL7FilingErrors;   //not auto-created

implementation

uses
  ORFn, rHL7RPCsU, FMErrorU, fShortenName,
  fPickAddTo60, fPickAddWorkLoad, fPickSpecimen, fPickspec2, fPickAddDataName;

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
  PriorSpecimenName := '';
  CumulativeClientServerMessages := TStringList.Create;
  LoadAvailAlerts;
end;

procedure TfrmHandleHL7FilingErrors.FormDestroy(Sender: TObject);
begin
  AlertComboData.Free;
  AlertInfo.Free;
  CumulativeClientServerMessages.Free;
end;

procedure TfrmHandleHL7FilingErrors.LoadAvailAlerts;
begin
  lbHL7Message.Items.Clear;
  AlertComboData.Clear;
  AlertInfo.Clear;
  PriorSpecimenName := '';;
  CumulativeClientServerMessages.Clear;
  LoadAvailCombo;
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
  if cboAvailAlerts.Items.Count = 0 then begin
    if MessageDlg('No alerts found.  Close form?', mtConfirmation, [mbOK, mbCancel], 0) = mrOK then begin
      Self.Close;
    end;
  end else begin
    cboAvailAlerts.ItemIndex := cboAvailAlerts.Items.Count-1;
    cboAvailAlertsChange(self);
  end;
end;


procedure TfrmHandleHL7FilingErrors.pnlLeftResize(Sender: TObject);
begin
  SendMessage(lbHL7Message.Handle, LB_SETHORIZONTALEXTENT, HL7MessagePixelWidth, 0);
end;

function TfrmHandleHL7FilingErrors.ProcessHL7 : integer;
//Result: mrOK or mrAbort or (mrYesToAll if final processing successful)
var AlertHandle, Data : string;
    ServerMessages : TStringList;
    Action : string;
begin
  Result := mrAbort;
  ServerMessages := TStringList.Create;
  Data := GetAlertData;
  AlertHandle := Pieces(Data,'^',2,3);
  Action := rHL7RPCsU.ProcessHL7(ServerMessages, AlertHandle, CumulativeClientServerMessages);
  if Action='GUI ACTION NEEDED' then begin
    Result := HandleGUIAction(ServerMessages);
  end else if Pos('[INVALID-VAL]', Action)>0 then begin
    FMErrorForm.Memo.Lines.Clear;
    FMErrorForm.Memo.Lines.Add(Action);
    FMErrorForm.Memo.Lines.Add(' ');
    FMErrorForm.Memo.Lines.Add(' ');
    FMErrorForm.Memo.Lines.Add('This utility is unable to process this error.  Must be handled from console. ');
    FMErrorForm.PrepMessage;
    FMErrorForm.ShowModal;
  end else if Action = 'OK' then begin
    AlertHandle := Pieces(Data,'^',2,4);
    Result := ResolveHL7Error(AlertHandle);  //returns mrAbort or mrYesToAll
    LoadAvailAlerts;
  end else begin
    MessageDlg('Process result: '+Action, mtInformation, [mbOK],0);
  end;
  ServerMessages.Free;
end;

procedure TfrmHandleHL7FilingErrors.btnProcessHL7Click(Sender: TObject);
var Result : integer;
begin
  Result := ProcessHL7;
  if Result in [mrOK, mrRetry] then begin
    btnProcessHL7Click(Sender);  //call self recursively.
  end;
end;

function TfrmHandleHL7FilingErrors.GetAlertData : string;
begin
  Result := '';
  if cboAvailAlerts.ItemIndex > -1 then Result := AlertComboData.Strings[cboAvailAlerts.ItemIndex];
end;


procedure TfrmHandleHL7FilingErrors.cboAvailAlertsChange(Sender: TObject);
var AlertHandle, Data : string;
begin
  CumulativeClientServerMessages.Clear;
  HL7MessagePixelWidth := 0;
  Data := GetAlertData;
  AlertHandle := Pieces(Data,'^',2,3);
  AlertInfo.RPCLoad(AlertHandle);
  SyncDisplay;
end;

procedure TfrmHandleHL7FilingErrors.ShowBrokerLogClick(Sender: TObject);
begin
  frmBroker.Show;
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

function TfrmHandleHL7FilingErrors.TrimQuotes(s : string) : string;
begin
  Result := s;
  if s = '' then exit;
  if s[1] <> '"' then exit;
  if s[Length(s)] <> '"' then exit;
  Result := MidStr(s, 2, Length(s)-2);
end;


procedure TfrmHandleHL7FilingErrors.ParseParms(ServerMessages, OutSL, Vars : TStringList);
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
    Args, Cmd, OneArg, s : string;

begin
  OutSL.Clear;
  Vars.Clear;
  if ServerMessages.Count = 0 then exit;
  Cmd := Trim(ServerMessages.Strings[0]);
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
    OneArg := TrimQuotes(OneArg);
    //if OneArg = '' then continue;
    //if OneArg[1] <> '"' then continue;
    //if OneArg[Length(OneArg)] <> '"' then continue;
    //OneArg := MidStr(OneArg, 2, Length(OneArg)-2);
    OutSL.Strings[i] := OneArg;
  end;
  //Now look at the rest of the messages array...
  for i := 1 to ServerMessages.Count - 1 do begin
    s := ServerMessages.Strings[i];
    if Pos('VAR:',s) <> 1 then continue;
    s := MidStr(s,5, length(s));
    Vars.Add(s);
  end;

end;


function TfrmHandleHL7FilingErrors.TrimName(Params : TStringList) : string;
//Result: a string to fix problem, or '-1' if problem or user Cancel.
var S : string;
    frmShortenName: TfrmShortenName;
begin
  Result := '-1';
  if Params.Count > 0 then begin
    s := Params.Strings[0];
  end else begin
    MessageDlg('No string found to shorten', mtError, [mbOK],0);
    exit;
  end;
  frmShortenName := TfrmShortenName.Create(Self);
  frmShortenName.Initialize(s, 30);
  if frmShortenName.ShowModal = mrOK then begin
    Result := frmShortenName.ResultName;
  end;
  frmShortenName.Free;
end;

procedure TfrmHandleHL7FilingErrors.AddCumulativeServerMsg(Msg, Reply: string);
var i : integer;
begin
  i := CumulativeClientServerMessages.IndexOf(Msg);
  if i > -1 then begin  //prevent adding duplicate replies to array.
    CumulativeClientServerMessages.Delete(i+1);
    CumulativeClientServerMessages.Delete(i);
  end;
  CumulativeClientServerMessages.Add(Msg);
  CumulativeClientServerMessages.Add('REPLY='+Reply);
end;

function TfrmHandleHL7FilingErrors.HandleGUIAction(ServerMessages : TStringList) : integer;
//Result: mrOK or mrAbort
var Cmd : string;
    Params : TStringList;
    Vars   : TStringList;
    Fix : string;
begin
  Result := mrAbort;
  if ServerMessages.Count = 0 then exit;
  try
    Params := TStringList.Create;
    Vars := TStringList.Create;
    Cmd := ServerMessages.Strings[0];
    if CumulativeClientServerMessages.IndexOf(Cmd) > -1 then begin
      //MessageDlg('Server is asking for information already provided.', mtError, [mbCancel], 0);
      MessageDlg('I got confused there for a second.  Can you try again?', mtInformation, [mbOK], 0);
      CumulativeClientServerMessages.Clear;
      Result := mrRetry;
      //Result := mrAbort;
      exit;
    end;
    ParseParms(ServerMessages, Params, Vars);
    if Pos('TRIMNAME^TMGHL70B',Cmd)>0 then begin
      Fix := TrimName(Params);
      if Fix = '-1' then exit else Result := mrOK;
      AddCumulativeServerMsg(Cmd, Fix);
    end else if Pos('PCKADD60^TMGHL70C',Cmd)>0 then begin
      Fix := PickAddToFile60(Params);
      if Fix = '-1' then exit else Result := mrOK;
      AddCumulativeServerMsg(Cmd, Fix);
    end else if Pos('ASKSPEC^TMGHL70C',Cmd)>0 then begin
      Fix := PickSpecimen(Params);
      if Fix = '-1' then exit else Result := mrOK;
      AddCumulativeServerMsg(Cmd, Fix);
    end else if Pos('ASKWKLD^TMGHL70C',Cmd)>0 then begin
      Fix := PickAddWorkLoad(Params,Vars);  //Format should be e.g. 1820^Renal Panel^81143.0000
      if Fix = '-1' then exit else Result := mrOK;
      AddCumulativeServerMsg(Cmd, Fix);
    end else if Pos('LINKDN^TMGHL70C',Cmd)>0 then begin
      Fix := LinkDataName(Params);
      if Fix = '-1' then exit else Result := mrOK;
      AddCumulativeServerMsg(Cmd, Fix);
    end else if Pos('ASKSPEC2^TMGHL70C',Cmd)>0 then begin
      Fix := PickSpec2(Params, Self.PriorSpecimenName);
      if Fix = '-1' then exit else Result := mrOK;
      AddCumulativeServerMsg(Cmd, Fix);
    end else begin
      MessageDlg('Unhandled message: '+Cmd,mtError,[mbOK],0);
    end;
  finally
    Params.Free;
    Vars.Free;
  end;
end;


function TfrmHandleHL7FilingErrors.PickAddToFile60(Params : TStringList) : string;
//Result: a string to fix problem, or '-1' if problem or user Cancel.
var Mode, TestName, Data, AlertHandle : string;
    frmPickAdd60: TfrmPickAdd60;
begin
  Result := '-1';
  if Params.Count > 0 then begin
    TestName := Params.Strings[0];
  end else begin
    MessageDlg('No test name found to add', mtError, [mbOK],0);
    exit;
  end;
  if Params.Count > 3 then begin
    Mode := Params.Strings[3];
  end else begin
    Mode := '';
  end;
  Data := GetAlertData;
  AlertHandle := Pieces(Data,'^',2,3);
  frmPickAdd60 := TfrmPickAdd60.Create(Self);
  frmPickAdd60.Initialize(AlertHandle, TestName, Mode);
  if frmPickAdd60.ShowModal = mrOK then begin
    Result := frmPickAdd60.ResultIEN60;
  end;
  frmPickAdd60.Free;
end;

function TfrmHandleHL7FilingErrors.PickAddWorkLoad(Params, Vars : TStringList) : string;
//Result: a string to fix problem, or '-1' if problem or user Cancel.
var s, TestName, Data, AlertHandle : string;
    frmPickAddWorkLoad: TfrmPickAddWorkLoad;
    ExcludeVarName : string;
    ExcludeList : TStringList;
    i : integer;
begin
  Result := '-1';
  if Params.Count > 0 then begin
    TestName := Params.Strings[0];
  end else begin
    MessageDlg('No test name found to add', mtError, [mbOK],0);
    exit;
  end;
  if Params.Count > 1 then begin
    ExcludeVarName := Params.Strings[1];
    if (length(ExcludeVarName)>0) and (ExcludeVarName[1]='.') then begin
      ExcludeVarName := MidStr(ExcludeVarName, 2, length(ExcludeVarName));
    end;
  end else begin
    ExcludeVarName := '';
  end;
  ExcludeList := TStringList.Create;
  for i := 0 to Vars.Count - 1 do begin
    s := Vars.Strings[i];
    if piece(s,'(',1) <> ExcludeVarName then continue;
    s := piece(s,'(',2);
    s := piece(s,',',1);
    s := TrimQuotes(s);
    ExcludeList.Add(s);
  end;
  Data := GetAlertData;
  AlertHandle := Pieces(Data,'^',2,3);
  frmPickAddWorkLoad := TfrmPickAddWorkLoad.Create(Self);
  frmPickAddWorkLoad.Initialize(AlertHandle, TestName, ExcludeList);
  if frmPickAddWorkLoad.ShowModal = mrOK then begin
    //Result := frmPickAddWorkLoad.ResultWorkLoadCode;
    Result := frmPickAddWorkLoad.ResultWorkLoadIEN + '^' +
              frmPickAddWorkLoad.ResultWorkLoadName + '^' +
              frmPickAddWorkLoad.ResultWorkLoadCode;
  end;
  frmPickAddWorkLoad.Free;
  ExcludeList.Free;
end;


function TfrmHandleHL7FilingErrors.PickSpecimen(Params : TStringList) : string;
//Result: a string to fix problem, or '-1' if problem or user Cancel.
var TestName, Data, AlertHandle : string;
    frmPickSpecimen: TfrmPickSpecimen;
begin
  Result := '-1';
  if Params.Count > 0 then begin
    TestName := Params.Strings[0];
  end else begin
    MessageDlg('No test name found to add', mtError, [mbOK],0);
    exit;
  end;
  Data := GetAlertData;
  AlertHandle := Pieces(Data,'^',2,3);
  frmPickSpecimen := TfrmPickSpecimen.Create(Self);
  frmPickSpecimen.Initialize(AlertHandle, TestName);
  if frmPickSpecimen.ShowModal = mrOK then begin
    Result := frmPickSpecimen.ResultIEN61 + '^' + frmPickSpecimen.ResultIEN62;
    //kt check.  Does this go between different lab results?? --> PriorSpecimenName := frmPickSpecimen.Result61Name;
  end;
  FreeAndNil(frmPickSpecimen);
end;

function TfrmHandleHL7FilingErrors.PickSpec2(Params : TStringList; PriorSpecimenName : string) : string;
//Result: a string to fix problem, or '-1' if problem or user Cancel.
var TestName, Data, AlertHandle : string;
    frmPickSpec2: TfrmPickSpec2;
begin
  Result := '-1';
  if Params.Count > 0 then begin
    TestName := Params.Strings[0];
  end else begin
    MessageDlg('No test name found to add', mtError, [mbOK],0);
    exit;
  end;
  Data := GetAlertData;
  AlertHandle := Pieces(Data,'^',2,3);
  frmPickSpec2 := TfrmPickSpec2.Create(Self);
  frmPickSpec2.Initialize(AlertHandle, TestName, PriorSpecimenName);
  if frmPickSpec2.ShowModal = mrOK then begin
    Result := frmPickSpec2.ResultIEN;
  end;
  FreeAndNil(frmPickSpec2);
end;

function TfrmHandleHL7FilingErrors.LinkDataName(Params : TStringList) : string;
//1 if OK, or '-1' if problem.
var TestName, IEN60, Data, AlertHandle : string;
    StorageLoc63d04 : string;
    frmPickAddDataName: TfrmPickAddDataName;
begin
  Result := '-1';
  StorageLoc63d04 := '';
  if Params.Count > 1 then begin
    TestName := Params.Strings[1];
  end;
  if Params.Count > 2 then begin
    IEN60 := Params.Strings[2];
  end else begin
    MessageDlg('No IEN60 test found to link', mtError, [mbOK],0);
    exit;
  end;
  Data := GetAlertData;
  AlertHandle := Pieces(Data,'^',2,3);
  frmPickAddDataName := TfrmPickAddDataName.Create(Self);
  frmPickAddDataName.Initialize(AlertHandle, TestName);
  if frmPickAddDataName.ShowModal = mrOK then begin
    StorageLoc63d04 := frmPickAddDataName.StorageLoc63d04;
  end;
  FreeAndNil(frmPickAddDataName);
  if StorageLoc63d04 = '' then exit;
  //make call here to link to IEN60
  Result := Link60ToDataName(AlertHandle, piece(IEN60,'^',1), StorageLoc63d04);
end;



end.


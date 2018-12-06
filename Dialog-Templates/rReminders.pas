unit rReminders;

//vefa -- needs port

{ $DEFINE TMG_XML_DLG}  //kt added  //This takes an XML file and makes a very generic dialog.  Doesn't process XML.  Just puts it all in.
{$DEFINE TMG_ASK_DLG}  //kt added

interface
uses
  Windows,Classes, SysUtils, TRPCB, GlobalsU,
  ORNet, ORFn, {fMHTest, }StrUtils;

type
  TMHdllFound = record
  DllCheck: boolean;
  DllFound: boolean;
end;

procedure GetCurrentReminders;
procedure GetOtherReminders(Dest: TStrings);
procedure EvaluateReminders(RemList: TStringList);
function EvaluateReminder(IEN: string): string;
procedure GetEducationTopicsForReminder(ReminderID: integer);
procedure GetEducationSubtopics(TopicID: integer);
procedure GetReminderWebPages(ReminderID: string);
function DetailReminder(IEN: Integer): TStrings;
function ReminderInquiry(IEN: Integer): TStrings;
function EducationTopicDetail(IEN: Integer): TStrings;
function GetDialogInfo(IEN: string; RemIEN: boolean): TStrings;
function GetDialogPrompts(IEN: string; Historical: boolean; FindingType: string): TStrings;
procedure GetDialogStatus(AList: TStringList);
function GetRemindersActive: boolean;
function GetProgressNoteHeader: string;
function LoadMentalHealthTest(TestName: string): TStrings;
procedure MentalHealthTestResults(var AText: string; const DlgIEN: string; const TestName:
                                  string; const AProvider: Int64; const Answers: string);
procedure SaveMentalHealthTest(const TestName: string; ADate: TFMDateTime;
                               const AProvider: Int64; const Answers: string);
procedure SaveWomenHealthData(var WHData: TStringlist);
function CheckGECValue(const RemIEN: string; NoteIEN: integer): String;
procedure SaveMSTDataFromReminder(VDate, Sts, Prov, FType, FIEN, Res: string);

function GetReminderFolders: string;
procedure SetReminderFolders(const Value: string);
function GetDefLocations: TStrings;
function InsertRemTextAtCursor: boolean;

function NewRemCoverSheetListActive: boolean;
function CanEditAllRemCoverSheetLists: boolean;
function GetCoverSheetLevelData(ALevel, AClass: string): TStrings;
procedure SetCoverSheetLevelData(ALevel, AClass: string; Data: TStrings);
function GetCategoryItems(CatIEN: integer): TStrings;
function GetAllRemindersAndCategories: TStrings;
function VerifyMentalHealthTestComplete(TestName, Answers: string): String;
function MHDLLFound: boolean;
function UsedMHDllRPC: boolean;
procedure PopulateMHdll;
procedure GetMHResultText(var AText: string; ResultsGroups, Scores: TStringList);

implementation

uses
  MainU, Dialogs, Controls, XML2Dlg, EditTextU, //kt added
  fMemoEdit, //kt added
  XML_Main, //kt added
  uCore, uReminders, rCore;

var
  uLastDefLocUser: int64 = -1;
  uDefLocs: TStringList = nil;
  uRemInsertAtCursor: integer = -1;
  uNewCoverSheetListActive: integer = -1;
  uCanEditAllCoverSheetLists: integer = -1;
  MHDLL: TMHDllFound;

procedure GetCurrentReminders;
begin
  CallV('ORQQPXRM REMINDERS UNEVALUATED', [Patient.DFN, Encounter.Location]);
end;

procedure GetOtherReminders(Dest: TStrings);
begin
  CallV('ORQQPXRM REMINDER CATEGORIES', [Patient.DFN, Encounter.Location]);
  Dest.Assign(RPCBrokerV.Results);
end;

procedure EvaluateReminders(RemList: TStringList);
var
  i: integer;

begin
  with RPCBrokerV do
  begin
    ClearParameters := True;
    RemoteProcedure := 'ORQQPXRM REMINDER EVALUATION';
    Param[0].PType := literal;
    Param[0].Value := Patient.DFN;
    Param[1].PType := list;
    for i := 0 to RemList.Count-1 do
      Param[1].Mult[IntToStr(i+1)] := Piece(RemList[i],U,1);
    CallBroker;
  end;
end;

function EvaluateReminder(IEN: string): string;
var
  TmpSL: TStringList;

begin
  TmpSL := TStringList.Create;
  try
    TmpSL.Add(IEN);
    EvaluateReminders(TmpSL);
    if(RPCBrokerV.Results.Count > 0) then
      Result := RPCBrokerV.Results[0]
    else
      Result := IEN;
  finally
    TmpSL.Free;
  end;
end;

procedure GetEducationTopicsForReminder(ReminderID: integer);
begin
  CallV('ORQQPXRM EDUCATION SUMMARY', [ReminderID]);
end;

procedure GetEducationSubtopics(TopicID: integer);
begin
  CallV('ORQQPXRM EDUCATION SUBTOPICS', [TopicID]);
end;

procedure GetReminderWebPages(ReminderID: string);
begin
  if(User.WebAccess) then
    CallV('ORQQPXRM REMINDER WEB', [ReminderID])
  else
    RPCBrokerV.ClearParameters := True;
end;

function DetailReminder(IEN: Integer): TStrings; // Clinical Maintenance
begin
  if InteractiveRemindersActive then
    CallV('ORQQPXRM REMINDER DETAIL', [Patient.DFN, IEN])
  else
    CallV('ORQQPX REMINDER DETAIL', [Patient.DFN, IEN]);
  Result := RPCBrokerV.Results;
end;

function ReminderInquiry(IEN: Integer): TStrings;
begin
  CallV('ORQQPXRM REMINDER INQUIRY', [IEN]);
  Result := RPCBrokerV.Results;
end;

function EducationTopicDetail(IEN: Integer): TStrings;
begin
  CallV('ORQQPXRM EDUCATION TOPIC', [IEN]);
  Result := RPCBrokerV.Results;
end;

function GetDialogInfo(IEN: string; RemIEN: boolean): TStrings;
var tempBool : Boolean; //kt added
    tempI : integer; //kt added
    ModResult : integer;
    tempSL : TStringList; //kt
begin
  //kt begin mod ---------
  {$IFDEF TMG_XML_DLG}
  //KEEP THIS CODE!!!
  if MainU.TMG_Create_Dynamic_Dialog then begin
    MainU.MainForm.XMLDlg.XMLFile := TMG_Create_Dynamic_Dialog_XML_Filename;
    Result := MainU.MainForm.XMLDlg.GetDlgFromXML;
    exit;
  end;
  {$ELSEIF DEFINED(TMG_ASK_DLG)}
  //kt end mod ---------
  if RemIEN then begin
    CallV('ORQQPXRM REMINDER DIALOG', [IEN, Patient.DFN])
  end else begin
    CallV('PXRM REMINDER DIALOG (TIU)', [IEN, Patient.DFN]);
  end;
  Result := RPCBrokerV.Results;
  //kt begin mod ---------
  ModResult := 0;
  if TMG_Create_Dynamic_Dialog then ModResult := mrYes;
  if ModResult = mrYes then begin
    //frmMemoEdit.PrepForm('','','');
    frmMemoEdit.memEdit.Lines.Clear;
    frmMemoEdit.memEdit.Lines.Add('Seeking input information for custom dialog');
    frmMemoEdit.memEdit.Lines.Add('Format can be in reminder-dialog format, or');
    frmMemoEdit.memEdit.Lines.Add('in xml format (as put out by Athena CDSS)');
    frmMemoEdit.memEdit.Lines.Add('----------------------------------------------------');
    frmMemoEdit.memEdit.Lines.Add('Please delete ALL this text and replace with input text.');
    frmMemoEdit.memEdit.Lines.Add('');
    frmMemoEdit.memEdit.Lines.Add('Or delete lines above and use data from below');
    frmMemoEdit.memEdit.Lines.Add('');
    for tempI := 0 to Result.Count - 1 do begin
      frmMemoEdit.memEdit.Lines.Add(Result[tempI]);
    end;
    if frmMemoEdit.ShowModal = mrOK then begin
      Result := frmMemoEdit.memEdit.Lines;
      if Result.Count=0 then exit;
      if LeftStr(Result.Strings[0],5) <> '<?xml' then exit;
      XML_Main.ParseFromXMLText(frmMemoEdit, frmMemoEdit.memEdit.Lines);  //frmMemoEdit is used as handy TComponent Owner.  Could pass something else as AOwner.  XMLDocument processing requires this
      Result := XML_Main.RemDlgOutput;
      //XML_Main.GetRemDlgOutput(Result, true);
      tempBool := false;
      if tempBool = true then begin  //can change when stepping with debugger.  To display processed RemDialog text.
        frmMemoEdit.memEdit.Lines.Assign(Result);
        frmMemoEdit.ShowModal;
        frmMemoEdit.memEdit.Lines.Assign(XML_Main.RemDlgOutputPromptInfo);
        frmMemoEdit.ShowModal;
      end;
      exit;
    end;
  end;
  {$IFEND}
  (*
  if RemIEN then begin
    CallV('ORQQPXRM REMINDER DIALOG', [IEN, Patient.DFN])
  end else begin
    CallV('PXRM REMINDER DIALOG (TIU)', [IEN, Patient.DFN]);
  end;
  Result := RPCBrokerV.Results;
  *)
  //kt end mod ---------
  tempBool := false;
  if tempBool = true then begin
    frmMemoEdit.memEdit.Lines.clear;
    frmMemoEdit.memEdit.Lines.Assign(Result);
    frmMemoEdit.ShowModal;
  end;
end;

function GetDialogPrompts(IEN: string; Historical: boolean; FindingType: string): TStrings;
var RPCName : string; //kt added
    tempBool : boolean; //kt
    ModResult : integer;
begin
  //kt begin mod ---------
  {$IFDEF TMG_XML_DLG}
  //KEEP THIS CODE!!!
  if MainU.TMG_Create_Dynamic_Dialog then begin
    Result := MainU.MainForm.XMLDlg.GetResults(StrToIntDef(IEN,0));
    exit;
  end;
  {$ELSEIF DEFINED(TMG_ASK_DLG)}
  if TMG_Create_Dynamic_Dialog then begin
    tempBool := false;
    if tempBool = true then begin  //can change when stepping with debugger.  To display processed RemDialog text.
      //frmMemoEdit.PrepForm('','','');
      frmMemoEdit.memEdit.Lines.Clear;
      frmMemoEdit.memEdit.Lines.Add('Seeking additional information for dialog prompts (Optional)');
      frmMemoEdit.memEdit.Lines.Add('IEN=' + IEN + ',  Historical=' + BoolToStr(Historical) + ', FindingType = ' + FindingType);
      frmMemoEdit.memEdit.Lines.Add('-------------------------------------------------------------');
      frmMemoEdit.memEdit.Lines.Add(' ');
      frmMemoEdit.memEdit.Lines.Add('Options: ');
      frmMemoEdit.memEdit.Lines.Add('  1. Cancel this box (click the X in the top right corner).');
      frmMemoEdit.memEdit.Lines.Add('  2. Erase all this text, replace with custom reply, then press [DONE].');
      if frmMemoEdit.ShowModal = mrOK then begin
        Result := frmMemoEdit.memEdit.Lines;
        exit;
      end;
    end else begin
      Result := XML_Main.GetOnePromptInfoSL(IEN);
      exit;
    end;
  end;
  {$IFEND}
  //kt end mod ---------
  CallV('ORQQPXRM DIALOG PROMPTS', [IEN, Historical, FindingType]);
  Result := RPCBrokerV.Results;
end;

procedure GetDialogStatus(AList: TStringList);
var
  i: integer;

begin
  if(Alist.Count = 0) then exit;
  with RPCBrokerV do
  begin
    ClearParameters := True;
    RemoteProcedure := 'ORQQPXRM DIALOG ACTIVE';
    Param[0].PType := list;
    for i := 0 to AList.Count-1 do
      Param[0].Mult[AList[i]] := '';
    CallBroker;
    AList.Assign(Results);
  end;
end;

function GetRemindersActive: boolean;
begin
  CallV('ORQQPX NEW REMINDERS ACTIVE', []);
  Result := ((RPCBrokerV.Results.Count = 1) and (RPCBrokerV.Results[0] = '1'));
end;

function GetProgressNoteHeader: string;
begin
  Result := sCallV('ORQQPXRM PROGRESS NOTE HEADER', [Encounter.Location]);
end;

function LoadMentalHealthTest(TestName: string): TStrings;
begin
  CallV('ORQQPXRM MENTAL HEALTH', [TestName]);
  Result := RPCBrokerV.Results;
end;

procedure MentalHealthTestResults(var AText: string; const DlgIEN: string; const TestName:
                                  string; const AProvider: Int64; const Answers: string);
var
  i, R: integer;
  Ans, tmp: string;

begin
  with RPCBrokerV do
  begin
    ClearParameters := True;
    RemoteProcedure := 'ORQQPXRM MENTAL HEALTH RESULTS';
    Param[0].PType := literal;
    Param[0].Value := DlgIEN;
    Param[1].PType := list;
    Param[1].Mult['"DFN"'] := Patient.DFN;
    Param[1].Mult['"CODE"'] := TestName;
    Param[1].Mult['"ADATE"'] := 'T';
    Param[1].Mult['"STAFF"'] := IntToStr(AProvider);
    R := 0;
    tmp := '';
    Ans := Answers;
    repeat
      tmp := copy(Ans,1,200);
      delete(Ans,1,200);
      inc(R);
      Param[1].Mult['"R' + IntToStr(R) + '"'] := tmp;
    until(Ans = '');
    CallBroker;
    AText := '';
    for i := 0 to Results.Count-1 do
    begin
      tmp := Results[i];
      if(Piece(tmp,U,1) = '7') then
      begin
        if(AText <> '') then
        begin
          if(copy(AText, length(AText), 1) = '.') then
            AText := AText + ' ';
          AText := AText + ' ';
        end;
        AText := AText + Trim(Piece(tmp, U, 2));
      end;
    end;
  end;
end;

procedure SaveMentalHealthTest(const TestName: string; ADate: TFMDateTime;
                               const AProvider: Int64; const Answers: string);
var
  R: integer;
  Ans, tmp: string;

begin
  with RPCBrokerV do
  begin
    ClearParameters := True;
    RemoteProcedure := 'ORQQPXRM MENTAL HEALTH SAVE';
    Param[0].PType := list;
    Param[0].Mult['"DFN"'] := Patient.DFN;
    Param[0].Mult['"CODE"'] := TestName;
    Param[0].Mult['"ADATE"'] := FloatToStr(ADate);
    Param[0].Mult['"STAFF"'] := IntToStr(AProvider);
    R := 0;
    tmp := '';
    Ans := Answers;
    repeat
      tmp := copy(Ans,1,200);
      delete(Ans,1,200);
      inc(R);
      Param[0].Mult['"R' + IntToStr(R) + '"'] := tmp;
    until(Ans = '');
    CallBroker;
  end;
end;

procedure SaveWomenHealthData(var WHData: TStringlist);
begin
  if assigned(WHData) then
  begin
  CallV('ORQQPXRM WOMEN HEALTH SAVE', [WHData]);
//  if RPCBrokerV.Results<>nil then
//  infoBox(RPCBrokerV.Results.Text,'Error in Saving WH Data',MB_OK);
  end;
end;

function CheckGECValue(const RemIEN: string; NoteIEN: integer): String;
var
ans,str,str1,title: string;
fin: boolean;
i,cnt: integer;

begin
  Result := sCallV('ORQQPXRM GEC DIALOG', [RemIEN, Patient.DFN, Encounter.VisitStr, NoteIEN]);
  if Piece(Result,U,1) <> '0' then
  begin
    if Piece(Result,U,5)='1' then
        begin
            if pos('~',Piece(Result,U,4))>0 then
               begin
               str:='';
               str1 := Piece(Result,U,4);
               cnt := DelimCount(str1, '~');
               for i:=1 to cnt+1 do
                   begin
                   if i = 1 then str := Piece(str1,'~',i);
                   if i > 1 then str :=str+CRLF+Piece(str1,'~',i);
                   end;
             end
             else str := Piece(Result,U,1);
        title := Piece(Result,U,3);
        fin := (InfoBox(str,title, MB_YESNO)=IDYES);
        if fin = true then ans := '1';
        if fin = false then ans := '0';
        CallV('ORQQPXRM GEC FINISHED?',[Patient.DFN,ans]);
        end;
   Result := Piece(Result, U,2);
   end
  else Result := '';
end;

procedure SaveMSTDataFromReminder(VDate, Sts, Prov, FType, FIEN, Res: string);
begin
  CallV('ORQQPXRM MST UPDATE', [Patient.DFN, VDate, Sts, Prov, FType, FIEN, Res]);
end;

function GetReminderFolders: string;
begin
  Result := sCallV('ORQQPX GET FOLDERS', []);
end;

procedure SetReminderFolders(const Value: string);
begin
  CallV('ORQQPX SET FOLDERS', [Value]);
end;

function GetDefLocations: TStrings;
begin
  if (User.DUZ <> uLastDefLocUser) then
  begin
    if(not assigned(uDefLocs)) then
      uDefLocs := TStringList.Create;
    tCallV(uDefLocs, 'ORQQPX GET DEF LOCATIONS', []);
    uLastDefLocUser := User.DUZ;
  end;
  Result := uDefLocs;
end;

function InsertRemTextAtCursor: boolean;
begin
  if uRemInsertAtCursor < 0 then
  begin
    Result := (sCallV('ORQQPX REM INSERT AT CURSOR', []) = '1');
    uRemInsertAtCursor := ord(Result);
  end
  else
    Result := Boolean(uRemInsertAtCursor);
end;

function NewRemCoverSheetListActive: boolean;
begin
  if uNewCoverSheetListActive < 0 then
  begin
    Result := (sCallV('ORQQPX NEW COVER SHEET ACTIVE', []) = '1');
    uNewCoverSheetListActive := ord(Result);
  end
  else
    Result := Boolean(uNewCoverSheetListActive);
end;

function CanEditAllRemCoverSheetLists: boolean;
begin
  if uCanEditAllCoverSheetLists < 0 then
  begin
    Result := HasMenuOptionAccess('PXRM CPRS CONFIGURATION');
    uCanEditAllCoverSheetLists := ord(Result);
  end
  else
    Result := Boolean(uCanEditAllCoverSheetLists);
end;

function GetCoverSheetLevelData(ALevel, AClass: string): TStrings;
begin
  CallV('ORQQPX LVREMLST', [ALevel, AClass]);
  Result := RPCBrokerV.Results;
end;

procedure SetCoverSheetLevelData(ALevel, AClass: string; Data: TStrings);
var
  i: integer;

begin
  with RPCBrokerV do
  begin
    ClearParameters := True;
    RemoteProcedure := 'ORQQPX SAVELVL';
    Param[0].PType := literal;
    Param[0].Value := ALevel;
    Param[1].PType := literal;
    Param[1].Value := AClass;
    Param[2].PType := list;
    for i := 0 to Data.Count-1 do
      Param[2].Mult[IntToStr(i+1)] := Data[i];
    CallBroker;
  end;
end;

function GetCategoryItems(CatIEN: integer): TStrings;
begin
  CallV('PXRM REMINDER CATEGORY', [CatIEN]);
  Result := RPCBrokerV.Results;
end;

function GetAllRemindersAndCategories: TStrings;
begin
  CallV('PXRM REMINDERS AND CATEGORIES', []);
  Result := RPCBrokerV.Results;
end;

function VerifyMentalHealthTestComplete(TestName, Answers: string): String;

begin
    CallV('ORQQPXRM MHV', [Patient.DFN, TestName, Answers]);
    if RPCBrokerV.Results[0]='2' then
      begin
        Result := '2'+ U;
        EXIT;
      end;
    if RPCBrokerV.Results[0] = '1' then
      begin
        Result := '1' + U;
        EXIT;
      end;
    if RPCBrokerV.Results[0] = '0' then
      begin
        Result := '0' + U + RPCBrokerV.Results[1];
        EXIT;
      end;
end;

function MHDLLFound: boolean;
begin
  //kt
  result := false;
  { //kt mod
  if MHDll.DllCheck = false then
     begin
       MHDll.DllCheck := True;
       MHDLL.DllFound := CheckforMHDll;
     end;
  Result := MHDLL.DllFound;
  }
end;

function UsedMHDllRPC: boolean;
begin
  Result := sCallV('ORQQPXRM MHDLLDMS',[]) = '1';
end;

procedure PopulateMHdll;
begin
  if MHDll.DllCheck = false then
    begin
      MHDll.DllCheck := True;
      //kt  MHDll.DllFound := CheckforMHDll;
      MHDll.DllFound := false; //kt
    end;
end;

procedure GetMHResultText(var AText: string; ResultsGroups, Scores: TStringList);
var
i, j: integer;
tmp, info: string;
tempInfo: TStringList;
begin
 //AGP for some reason in some account passing two arrays in the RPC was
 //not working had to convert back to the old method for the RPC for now
 with RPCBrokerV do
  begin
    ClearParameters := True;
    RemoteProcedure := 'ORQQPXRM MHDLL';
    Param[0].PType := literal;
    Param[0].Value := PATIENT.DFN;  //*DFN*
    Param[1].PType := list;
    j := 0;
    for i := 0 to ResultsGroups.Count-1 do
      begin
        j := j + 1;
        Param[1].Mult['"RESULTS",'+ InttoStr(j)]:=ResultsGroups.Strings[i];
      end;
    j := 0;
    for i := 0 to Scores.Count-1 do
      begin
        j := j + 1;
        Param[1].Mult['"SCORES",'+ InttoStr(j)]:=Scores.Strings[i];
      end;
  end;
  CallBroker;
  //CallV('ORQQPXRM MHDLL',[ResultsGroups, Scores, Patient.DFN]);
  AText := '';
  info := '';
  for i := 0 to RPCBrokerV.Results.Count - 1 do
    begin
      tmp := RPCBrokerV.Results[i];
      if pos('[INFOTEXT]',tmp)>0 then
        begin
           if info <> '' then info := info + ' ' + Copy(tmp,11,(Length(tmp)-1))
           else info := Copy(tmp,11,(Length(tmp)-1));
        end
      else
      begin
        if(AText <> '') then
        begin
          if(copy(AText, length(AText), 1) = '.') then
            AText := AText;
          AText := AText + ' ';
        end;
        AText := AText + Trim(tmp);
      end;
  end;
  if info <> '' then
    begin
      if pos(U, info) > 0 then
        begin
          tempInfo := TStringList.Create;
          PiecestoList(info,'^',tempInfo);
          info := '';
          for i := 0 to tempInfo.Count -1 do
            begin
              if info = '' then info := tempInfo.Strings[i]
              else info := info + CRLF + tempInfo.Strings[i];
            end;
        end;
      InfoBox(info,'Attention Needed',MB_OK);
    end;
end;
initialization

finalization
  FreeAndNil(uDefLocs);

end.

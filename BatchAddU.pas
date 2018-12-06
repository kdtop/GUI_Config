unit BatchAddU;
   (* 
   WorldVistA Configuration Utility
   (c) 8/2008 Kevin Toppenberg
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
  Dialogs, StdCtrls, Buttons, Grids, ExtCtrls, ComCtrls, DateUtils;

type
  TBatchAddForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    BatchGrid: TStringGrid;
    btnCreateTemplate: TBitBtn;
    btnOpenDataFile: TBitBtn;
    btnDoRegistration: TBitBtn;
    btnClearGrid: TBitBtn;
    OpenDialog: TOpenDialog;
    btnDone: TBitBtn;
    ProgressBar: TProgressBar;
    btnSaveGrid: TBitBtn;
    btnAbortRegistration: TBitBtn;
    SaveDialog: TSaveDialog;
    EstTimeLabel: TLabel;
    procedure btnCreateTemplateClick(Sender: TObject);
    procedure btnClearGridClick(Sender: TObject);
    procedure btnOpenDataFileClick(Sender: TObject);
    function LTrim(s,subStr : string): string;
    function RTrim(s,subStr : string): string;
    function Trim(s,subStr : string): string;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnDoRegistrationClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAbortRegistrationClick(Sender: TObject);
    procedure btnSaveGridClick(Sender: TObject);
    procedure BatchGridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
  private
    { Private declarations }
    FieldNumList : TStringList;
    FAbortRegistration : boolean;
    procedure ClearGrid;
    procedure LoadData(fileName : string);
    procedure AddHeaderCol(oneEntry : string);
    procedure GetColFieldNums(List : TStringList);
    function GetOneRow(row : integer; ColFields : TStringList) : string;
    function RowToStr(row : integer) : string;
    procedure AddRowFromStr(Str : string);
    function RegisterOne(oneRow : string; Log : TStringList) : string;
    //procedure DelGridRow(BatchGrid : TStringGrid; row : integer);
  public
    { Public declarations }
  end;

var
  BatchAddForm: TBatchAddForm;

implementation

uses CreateTemplateU, StrUtils, ORNet, ORFn,
     Trpcb,  //needed for .ptype types
     FMErrorU;

const NOT_ADDED='(Not Added)';
      ADD_ROW='Add-->';
      ALREADY_ADDED='(Already Registered)';
{$R *.dfm}

  procedure TBatchAddForm.ClearGrid;
  begin
    BatchGrid.ColCount := 2;
    BatchGrid.RowCount := 3;
    BatchGrid.Cells[0,0] := 'Field NAME';
    BatchGrid.Cells[0,1] := 'Field NUM';
    BatchGrid.Cells[0,2] := '';
    BatchGrid.Cells[1,0] := '';
    BatchGrid.Cells[1,1] := '';
    BatchGrid.Cells[1,2] := '';
  end;


  procedure TBatchAddForm.btnCreateTemplateClick(Sender: TObject);
  begin
    CreateTemplateForm.PrepForm('2');
    CreateTemplateForm.ShowModal;
  end;

  procedure TBatchAddForm.btnClearGridClick(Sender: TObject);
  begin
    if MessageDlg('Clear All Patients?',mtConfirmation,mbOKCancel,0) = mrOK then begin
      ClearGrid;
      btnSaveGrid.Enabled := false;
      btnDoRegistration.Enabled := false;
      btnClearGrid.Enabled := false;
      btnCreateTemplate.Enabled := true;
      btnOpenDataFile.Enabled := true;
    end;
  end;

  procedure TBatchAddForm.btnOpenDataFileClick(Sender: TObject);
  begin
    if OpenDialog.Execute then begin
      LoadData(OpenDialog.FileName);
      btnClearGrid.Enabled := true;
      btnDoRegistration.Enabled := true;
      btnCreateTemplate.Enabled := false;
      btnOpenDataFile.Enabled := false;
    end;
  end;

  function TBatchAddForm.RTrim(s,subStr : string): string;
  var p,subLen : integer;       
  begin
    result := s;
    p := Pos(subStr,s);
    subLen := length(subStr);
    if p <> length(s)-subLen+1 then exit;
    result := MidStr(s,1, length(s)-subLen);
  end;

  
  function TBatchAddForm.LTrim(s,subStr : string): string;
  var p,subLen : integer;
  begin
    result := s;
    p := Pos(subStr,s);
    subLen := length(subStr);
    if p <> 1 then exit;
    result := MidStr(s,subLen+1,999);
  end;

  function TBatchAddForm.Trim(s,subStr : string): string;
  begin
    result := LTrim(s,subStr);
    result := RTrim(result,subStr);
  end;
  

  procedure TBatchAddForm.LoadData(fileName : string);
  var Data: TStringList;
      Line1List: TStringList;
      oneLine : string;
      value : string;
      row,i,j : integer;
      fldName,fldNum : string;
      dataFound : boolean;
      oneEntry : string;
  begin
    Data := TStringList.Create;
    Line1List := TStringList.Create;
    Data.LoadFromFile(fileName);
    if Data.Count < 3 then begin
      MessageDlg('Template file has less than 3 lines.'+#10+#13+
                 'Doesn''t appear to be valid template'+#10+#13+
                 'filled with patient data.  Please fill '+#10+#13+
                 'with patient demographics first.', mtError,[mbOK],0);
      exit;           
    end;
    ClearGrid;    
    //------- set up header rows  (name and number) ------------------
    oneLine := Data.Strings[0];
    PiecesToList(oneLine, #9, Line1List);
    oneLine := Data.Strings[1];
    PiecesToList(oneLine, #9, FieldNumList);
    for i := 1 to Line1List.Count-1 do begin
      fldName := Trim(Line1List.Strings[i],'"');
      if i < FieldNumList.Count then begin
        fldNum := LTrim(FieldNumList.Strings[i],'"<');
        fldNum := RTrim(fldNum,'>"');
      end else begin
        fldNum := '??';
      end;
      oneEntry := fldNum+'^'+fldName;
      AddHeaderCol(oneEntry);  
    end;    
    //--------- now load data ----------------------
    dataFound := true;
    for i := 2 to Data.Count-1 do begin
      if dataFound then begin
        if BatchGrid.RowCount = 3 then begin
          if BatchGrid.Cells[0,2] <> '' then BatchGrid.RowCount := BatchGrid.RowCount + 1;
        end else begin
          BatchGrid.RowCount := BatchGrid.RowCount + 1;
        end;  
      end;  
      row := BatchGrid.RowCount-1;
      oneLine := Data.Strings[i];    
      PiecesToList(oneLine, #9, Line1List);
      BatchGrid.Cells[0,row] := ADD_ROW;
      dataFound := false;  //don't advance line if data row is empty.
      for j := 1 to Line1List.Count-1 do begin  //don't use first column of data file
        value := Line1List.Strings[j];
        value := Trim(value,'"');
        if FieldNumList.Strings[j]='"<.09>"' then begin
          value := LTrim(value,'<');
          value := RTrim(value,'>');
        end;
        if value <> '' then dataFound := true;
        BatchGrid.Cells[j,row]:= value;
      end;
      if (dataFound = false) and (i = Data.Count-1) then begin
        BatchGrid.RowCount := BatchGrid.RowCount - 1;
      end;
    end;
    Data.Free;
    Line1List.Free;
  end;

  procedure TBatchAddForm.AddHeaderCol(oneEntry : string);  
  //oneEntry format: fldNum^fldName
  var i : integer;
      fldName,fldNum : string;
  begin
    CreateTemplateForm.GetNumName(oneEntry,fldName,fldNum);    
    i := BatchGrid.ColCount-1;
    if BatchGrid.Cells[i,0] <> '' then begin
      BatchGrid.ColCount := BatchGrid.ColCount + 1;
    end;
    i := BatchGrid.ColCount-1;

    BatchGrid.Cells[i,0] := fldName;      
    BatchGrid.Cells[i,1] := fldNum;      
  end;


  procedure TBatchAddForm.FormClose(Sender: TObject; var Action: TCloseAction);
  begin
    {
    if MessageDlg('Leave Batch Registration? (Later check to ensure data was saved)',mtConfirmation,mbOKCancel,0) = mrOK then begin
      Action := caHide;
    end else begin
      Action := caNone;
    end;
    }
  end;

  procedure TBatchAddForm.FormCreate(Sender: TObject);
  begin
    FieldNumList := TStringList.Create;
  end;


  procedure TBatchAddForm.btnDoRegistrationClick(Sender: TObject);
  var i,row : integer;
      FailedPatients : TStringList;
      ColFields : TStringList;
      onePostEntry : string;
      RPCResult : string;
      Log : TStringList;
      Success,Failure,PreExisting,Errors : integer;
      StartTime : TDateTime;

      procedure ShowEstTime(Pct : single);
      var  Delta : single;
           EstTotalMin : Integer;
           s : string;
      begin
        Delta := MinuteSpan(Now,StartTime);
        if Pct=0 then begin
          EstTimeLabel.caption := '';
          exit;
        end;
        EstTotalMin := Round(Delta / Pct);
        s := '';
        if EstTotalMin > 1440 then begin  //extract number of days
          s := s + IntToStr(EstTotalMin div 1440) + 'd:';
          EstTotalMIn := EstTotalMin mod 1440;
        end;
        if EstTotalMin > 60 then begin  //extract number of hours
          if s <> '' then s := s + IntToStr(EstTotalMin div 60) + 'h:'
          else s := IntToStr(EstTotalMin div 60) + ':';
          EstTotalMIn := EstTotalMin mod 60;
        end;
        s := s + IntToStr(EstTotalMin) + ':';
        EstTimeLabel.Caption := s;
      end;

  begin
    btnOpenDataFile.Enabled := false;
    btnClearGrid.Enabled := true;
    btnAbortRegistration.Enabled := True;
    btnClearGrid.Enabled := False;
    btnSaveGrid.Enabled := False;

    Log := TStringList.Create;
    Success := 0;
    Failure := 0;
    PreExisting := 0;
    Errors := 0;
    FMErrorForm.Memo.Lines.clear;
    ColFields := TStringList.Create;
    FailedPatients := TStringList.Create;
    GetColFieldNums(ColFields);
    ProgressBar.Max := BatchGrid.RowCount-1;
    FAbortRegistration := false;  //abort button can change this.
    StartTime := Now;
    EstTimeLabel.Caption := '';
    for row := 2 to BatchGrid.RowCount-1 do begin
      if FAbortRegistration = true then break;
      ProgressBar.Position := row;
      if (row mod 100) = 0 then ShowEstTime(row/(BatchGrid.RowCount-1));
      onePostEntry := GetOneRow(row,ColFields);
      RPCResult := RegisterOne(onePostEntry,Log);  //Returns: NewIEN^PrevReg^Reg'dNow^ErrorOccured
      BatchGrid.Cells[0,row] := Piece(RPCResult,'^',1);
      if Piece(RPCResult,'^',1)=NOT_ADDED then inc(Failure);
      if Piece(RPCResult,'^',2)='1' then inc(PreExisting);
      if Piece(RPCResult,'^',3)='1' then inc(Success);
      if Piece(RPCResult,'^',4)='1' then inc(Errors);
      Application.ProcessMessages;
    end;
    ProgressBar.Position := 0;
    ColFields.free;
    MessageDlg(IntToStr(Success)+' successful registrations or data refresh,  '+#10+#13+
               IntToStr(PreExisting)+' patients were already registered,'+#10+#13+
               IntToStr(Errors)+' filing errors encountered (including minor errors),'+#10+#13+
               IntToStr(Failure)+' patients NOT registered.',
               mtInformation,[mbOK],0);
    EstTimeLabel.Caption := '';
    StartTime := Now;
    if BatchGrid.RowCount > 1000 then ShowMessage('Will now clear out patients that have been registered.');
    for row := 2 to BatchGrid.RowCount-1 do begin
      if (BatchGrid.Cells[0,row] = NOT_ADDED) or (BatchGrid.Cells[0,row] = ADD_ROW) then begin
        FailedPatients.Add(RowToStr(row));
      end;
      ProgressBar.Position := row;
      if (row mod 100) = 0 then ShowEstTime(row/(BatchGrid.RowCount-1));
      Application.ProcessMessages;
    end;
    BatchGrid.RowCount := 2;
    ProgressBar.Max := FailedPatients.Count;
    StartTime := Now;
    for i := 0 to FailedPatients.Count-1 do begin
      AddRowFromStr(FailedPatients.Strings[i]);
      ProgressBar.Position := i;
      if (i mod 100) = 0 then ShowEstTime(i/(FailedPatients.Count-1));
      Application.ProcessMessages;
    end;
    {
    for row := BatchGrid.RowCount-1 downto 2 do begin
      if (BatchGrid.Cells[0,row] <> NOT_ADDED)
      and (BatchGrid.Cells[0,row] <> ADD_ROW) then begin
        DelGridRow(BatchGrid,row);  // <------- this is VERY SLOW!!@#@!
      end;
      ProgressBar.Position := row;
      if (row mod 100) = 0 then ShowEstTime((BatchGrid.RowCount-1-row)/(BatchGrid.RowCount-1));
      Application.ProcessMessages;
    end;
    }
    EstTimeLabel.Caption := '';
    if Log.Count>0 then begin
      FMErrorForm.Memo.Lines.Assign(Log);
      FMErrorForm.PrepMessage;
      FMErrorForm.ShowModal;
    end;
    Log.Free;
    if (BatchGrid.RowCount=3)and(BatchGrid.Cells[0,2]='') then begin
      btnSaveGrid.Enabled := false;
      btnDoRegistration.Enabled := false;
      btnClearGrid.Enabled := false;
      btnCreateTemplate.Enabled := true;
      btnOpenDataFile.Enabled := true;
      btnAbortRegistration.Enabled := true;
    end else begin
      btnClearGrid.Enabled := true;
      btnSaveGrid.Enabled := true;
      btnAbortRegistration.Enabled := false;
    end;
    FailedPatients.Free;

  end;

  function TBatchAddForm.RegisterOne(oneRow : string; Log : TStringList) : string;
  //Returns: NewIEN^Bool1^Bool2^Bool3
    //    NewIEN can be a #, or NOT_ADDED
    //    For each Bool, 0=false, 1=true
    //    Bool1 : Patient previously registered
    //    Bool2 : Patient registered this time (using identifier fields)
    //    Bool3 : Some Problem occurred during filing
  var tempResult,RPCResult : string;
      Msg : string;
      i : integer;
  begin
    RPCBrokerV.remoteprocedure := 'TMG CHANNEL';
    RPCBrokerV.param[0].ptype := list;
    RPCBrokerV.Param[0].Mult['"REQUEST"'] := 'REGISTER PATIENT^'+oneRow;
    CallBroker; //RPCBrokerV.Call;
    RPCResult := RPCBrokerV.Results[0];
    //returns:  error: -1^Message;  success=1^Success^IEN; or Equivical=0^Message^IEN
    //If 0 then Message is in this format
    //    [Bool1;Bool2;Bool3;Bool4;Bool5*MessageText]
    //    For each Bool, 0=false, 1=true
    //    Bool1 : Patient previously registered
    //    Bool2 : Patient registered this time (using identifier fields)
    //    Bool3 : Problem filing non-identifier fields
    //    Bool4 : Problem filing data info sub-file fields
    //    Bool5 : Problem filing HRN
    tempResult := piece(RPCResult,'^',1);
    if tempResult='1' then begin  //1=Success
      result := piece(RPCResult,'^',3)+'^0^1^0';
    end else if tempResult='0' then begin  //0=Mixed results
      Msg := piece(RPCResult,'^',2);
      result := piece(RPCResult,'^',3);
      if result = '' then result := NOT_ADDED;
      result := result + '^' + Piece(Msg,';',1) + '^' + Piece(Msg,';',2);
      if Pos('1',Pieces(Msg,';',3,5))>0 then begin
        result := result + '^1';
        if RPCBrokerV.Results.Count > 1 then begin
          Log.Add('-----------------------------------------------');
          Log.Add('There was a problem with registering a patient.');
          for i := 1 to RPCBrokerV.Results.Count-1 do begin
            Log.Add(RPCBrokerV.Results.Strings[i]);
          end;
        end;
      end else begin
        result := result + '^0';
      end;
    end else begin  //should be tempResult='-1'   //-1=Error
      FMErrorForm.Memo.Lines.Assign(RPCBrokerV.Results);
      FMErrorForm.PrepMessage;  //Does some clean up of the message format
      //FMErrorForm.ShowModal;  //later just put these in log...
      Log.Add('-----------------------------------------------');
      Log.Add('There was a problem with registering a patient.');
      for i:= 0 to FMErrorForm.Memo.Lines.Count-1 do begin
        Log.Add(FMErrorForm.Memo.Lines.Strings[i]);
      end;
      Log.Add(' ');
      FMErrorForm.Memo.Lines.Clear;
      result := NOT_ADDED+'^0^0^1';  //Not-prev-reg^Not-reg-this-time^Problem-occured
    end;
  end;

  {
  procedure TBatchAddForm.DelGridRow(BatchGrid : TStringGrid; row : integer);
  var col : integer;
  begin
    if row >= BatchGrid.RowCount then exit;
    repeat
      if row = BatchGrid.RowCount-1 then begin
        if BatchGrid.RowCount=3 then begin
          for col := 0 to BatchGrid.ColCount-1 do begin
            BatchGrid.Cells[col,row] := '';
          end;
        end else begin
          BatchGrid.RowCount := BatchGrid.RowCount-1;
        end;
        exit;
      end;
      for col := 0 to BatchGrid.ColCount-1 do begin
        BatchGrid.Cells[col,row] := BatchGrid.Cells[col,row+1]
      end;
      inc(row);
    until (1=0);
  end;
  }
  
  procedure TBatchAddForm.FormDestroy(Sender: TObject);
  begin
    FieldNumList.Free;
  end;

  procedure TBatchAddForm.GetColFieldNums(List : TStringList);
  var i : integer;
  begin
    List.Clear;
    List.Add(''); //fill 0'th column will null
    for i := 1 to BatchGrid.ColCount-1 do begin
      List.Add(BatchGrid.Cells[i,1]);
    end;
  end;

  function TBatchAddForm.GetOneRow(row : integer; ColFields : TStringList) : string;
  //Output format: FldNum1^Value1^fldNum2^Value2^FldNum3^Value3...
  var i : integer;
  begin
    result := '';
    if row >= BatchGrid.RowCount then exit;
    for i := 1 to BatchGrid.ColCount-1 do begin
      result := result + ColFields.Strings[i]+'^'+BatchGrid.Cells[i,row]+'^';
    end;
  end;

  function TBatchAddForm.RowToStr(row : integer) : string;
  //Output format: Cell0^Cell1^Cell2^Cell3^Cell4....
  var i : integer;
  begin
    result := '';
    if row >= BatchGrid.RowCount then exit;
    for i := 0 to BatchGrid.ColCount-1 do begin
      result := result + BatchGrid.Cells[i,row]+'^';
    end;
  end;

  procedure TBatchAddForm.AddRowFromStr(Str : string);
  var   row : integer;
        i : integer;
  begin
    BatchGrid.RowCount := BatchGrid.RowCount + 1;
    row := BatchGrid.RowCount-1;
    for i := 0 to BatchGrid.ColCount-1 do begin
      BatchGrid.Cells[i,row] := Piece(Str,'^',i+1);
    end;
  end;


  procedure TBatchAddForm.btnAbortRegistrationClick(Sender: TObject);
  begin
    FAbortRegistration := true;
  end;

  procedure TBatchAddForm.btnSaveGridClick(Sender: TObject);
  var DataLines : TStringList;
      Value : string;
      row,col : integer;
      Line : string;
  begin
    If SaveDialog.Execute then begin
      DataLines := TStringList.Create;
      for row := 0 to BatchGrid.RowCount-1 do begin
        Line := '';
        for col := 0 to BatchGrid.ColCount-1 do begin
          Value := BatchGrid.Cells[col,row];
          if Value = ADD_ROW then Value := ' ';          
          if (row=1)or((BatchGrid.Cells[col,1]='.09')and(row<>0)) then begin
            Value := '<'+Value+'>';  //protect field numbers as text
          end;  
          Line := Line + '"'+Value+'"' + #9
        end;  
        DataLines.Add(Line);
      end;
      DataLines.Add(' ');
      DataLines.Add('Add as many rows as needed)');
      DataLines.Add(' ');
      DataLines.Add('When done, save file and import with');
      DataLines.Add('  the WorldVista Config Utility.');
      DataLines.Add('Save in CSV format, using TAB as field');
      DataLines.Add(' delimiter, and " as text delimiter.');
      DataLines.SaveToFile(SaveDialog.FileName);
      DataLines.Free;
    end;
  end;

  procedure TBatchAddForm.BatchGridSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: String);
  begin
    btnSaveGrid.Enabled := true;
  end;

end.


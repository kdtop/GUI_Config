unit Rem2VennU;

interface

  uses frmVennU, MainU, Classes, SysUtils, StrUtils, ORFn, TypesU, rRPCsU,
       ReminderRegionManagerU, RegionManager, ReminderObjU,
       SortStringGrid, VennObject, Controls;

  procedure InitializeVenn (GridInfo : TGridInfo); overload;
  procedure InitializeVenn (Grid : TSortStringGrid; IEN : LongInt); overload;
  procedure DisplayVenns(Mode : TDisplayVMode);
  procedure HandleAgeDetailClick;
  function HandleAgeDeleteClick : boolean;

  var VinSexSubStr : string;
      VennDisplayMode : TDisplayVMode;
      ReminderGridInfo : TCompleteGridInfo;
      ReminderIENS : string;
      ReminderFile : string;

  function GetDataLine(GridData : TStringList; FileNum, IENS, FldNum : string) : string; overload;
  function GetDataLine(GridData : TStringList; FldNum : string) : string; overload;
  function GetDataLine(GridInfo : TGridInfo; FileNum, IENS, FldNum : string) : string; overload;
  function GetDataLine(GridInfo : TGridInfo; FldNum : string) : string; overload;

  function FieldValue(GridData : TStringList; FileNum, IENS, FldNum : string) : string; overload;
  function FieldValue(GridData : TStringList; FldNum : string) : string; overload;
  function FieldValue(GridInfo : TGridInfo; FileNum, IENS, FldNum : string) : string; overload;
  function FieldValue(GridInfo : TGridInfo; FldNum : string) : string; overload;

  procedure GetFieldMatches(GridData : TStringList; FileNum, FldNum : string; Results : TStringList);
  procedure GetFieldMatchesFullLine(GridData : TStringList; FileNum, FldNum : string; Results : TStringList);

  procedure HandleObjDeleteRequest(Obj : TRemObj; var DeleteOK : boolean);
  Procedure PrepFuncFindingSubVennForm(AVennForm : TVennForm; LogicStr, FindingsUsed : String);
  Procedure PrepFindingSubVennForm(AVennForm : TVennForm; LogicStr : string; FindingsUsed : String;
                                   FindingSubfileNumber, ParentIENS : string);
  procedure LoadAVennFormRgnMgr(AVennForm : TVennForm; FindingsUsed : string; Findings : TStringList;
                       HideHints : boolean = false; AllowUserManipulation : boolean = true;
                       ObjOwnsGridInfo : boolean = false);
  Procedure DisplayVennsIntoAVennForm(AVennForm: TVennForm; LogicStr, FindingsUsed: string; FindingsSL : TStringList);

  function HandleTextEdit(InitValue, FileNum, IENS, FieldNum : string;
                          GridInfo : TGridInfo;
                          var Changed, CanSelect : boolean;
                          ExtraInfo : string; ExtraInfoSL : TStringList) : string;

const
  AGE_LABEL = 'AGE';


implementation

  uses
    GridU, Dialogs, FMU, TMGStrUtils,
    fRemFnFindingEdit,
    EditFreeText;

  var
    FindingsSL : TStringList;  //Format: e.g. FF(2) (and object is GridInfo), or
                               //        e.g. FI(7) (and object is GridInfo),
                               //Objects are of type TCompleteGridInfo
                               //This list OWNS objects contained.
    CohortFindingsListStr,
    UtilityFindingsListStr,
    ResolutionFindingsListStr : string;
    CohortLogic,
    UtilityLogic,
    ResolutionLogic           : string;
    VinCohortLogicStr,
    VinUtilityLogicStr,
    VinResolutionLogicStr     : string;
    VinCohortFindingsUsed,
    VinUtilityFindingsUsed,
    VinResolutionFindingsUsed : string;

    ReminderFuncFindingBasicTemplate : TStringList;


  const OPER_CHARS = '+-><=&![]';
        NOT_CHAR = '''';
        NUM_CHARS = '0123456789';
        UTILITY_TAG = '[UTILITY]';


  procedure HandleObjDeleteRequest(Obj : TRemObj; var DeleteOK : boolean);
  //Fires when user requesting to delete object
  var
    AGridInfo : TCompleteGridInfo;  //won't own object
    Filenum, IENS : string;
    ErrMsg : string;
    Fileman : TFileman; //Owned here
    FMFile : TFMFile;  //not owned here
    FMRecord : TFMRecord; //not owned here
    RecDeleted : boolean;

  begin
    DeleteOK := false;
    ErrMsg := '';
    if MessageDlg('Permanently Delete Item: '+Obj.Name+'?',mtConfirmation, mbOKCancel,0) <> mrOK then begin
      exit;
    end;
    if (Obj.Name = AGE_LABEL) then begin
      DeleteOK := HandleAgeDeleteClick;
      exit;
    end;
    if assigned(Obj.Children) and (Obj.Children.Count > 0) then begin
      MessageDlg('Unable to Delete Item.'+#13#10+
                 'Please delete children items first.', mtError, [mbOK],0);
      exit;
    end;
    //AGridInfo := TGridInfo(Obj.ObjectPtr);
    AGridInfo := Obj.GridInfo;
    if not assigned(AGridInfo) then begin
      MessageDlg('Unable to Delete Item.'+#13#10+
                 'Can''t determine database record number.', mtError, [mbOK],0);
      exit;
    end;
    //Delete object from fileman file
    Filenum := AGridInfo.FileNum;
    IENS := AGridInfo.IENS;
    Fileman := TFileman.Create;
    FMFile := Fileman.FMFile[Filenum];
    FMRecord := FMFile.FMRecord[IENS];
    RecDeleted := FMRecord.DeleteRec;
    Fileman.Free;
    if RecDeleted then begin
      DeleteOK := true;
    end else begin
      MessageDlg('Unable to Delete Item.'+#13#10+
                 'Unexpected problem.', mtError, [mbOK],0);
    end;
  end;


  procedure Clear;
  var i : integer;
    OneFindingGridInfo : TCompleteGridInfo;  //won't own object
  begin
    for i := 0 to FindingsSL.Count - 1 do begin
      OneFindingGridInfo := TCompleteGridInfo(FindingsSL.Objects[i]);
      if assigned(OneFindingGridInfo) then begin
        OneFindingGridInfo.Destroy;  //I had to do this.  .Free wasn't working...
      end;
      //OneFindingGridInfo.Free;  <--- Didn't trigger destroy method for some reason!!
      //FreeAndNilGridInfo(OneFindingGridInfo);
    end;
    FindingsSL.Clear;
    ReminderIENS := '';
    ReminderGridInfo.Data.Clear;
    ReminderGridInfo.BasicTemplate.Clear;
    CohortFindingsListStr := '';
    UtilityFindingsListStr := '';
    ResolutionFindingsListStr := '';
    CohortLogic := '';
    UtilityLogic := '';
    ResolutionLogic := '';
    VinCohortLogicStr := '';
    VinUtilityLogicStr := '';
    VinResolutionLogicStr := '';
    VinCohortFindingsUsed := '';
    VinUtilityFindingsUsed := '';
    VinResolutionFindingsUsed := '';
  end;

  procedure GetFieldMatchesFullLine(GridData : TStringList; FileNum, FldNum : string; Results : TStringList);
  //Return all entries from given file, and fieldNum, into Results
  //Returns ENTIRE DATA LINE
  //Results is not cleared first
  var i : integer;
      dataS,value : string;
  begin
    if not assigned(Results) then exit;
    for i := 0 to GridData.Count - 1 do begin
      dataS := GridData.Strings[i];
      if ORFn.Piece(dataS, '^',1) <> FileNum then continue;
      if ORFn.Piece(dataS, '^',3) <> FldNum then continue;
      Results.Add(dataS);
    end;
  end;

  procedure GetFieldMatches(GridData : TStringList; FileNum, FldNum : string; Results : TStringList);
  //Return all entries from given file, and fieldNum, into Results
  //Results is not cleared first
  var i : integer;
      dataS,value : string;
  begin
    if not assigned(Results) then exit;
    for i := 0 to GridData.Count - 1 do begin
      dataS := GridData.Strings[i];
      if ORFn.Piece(dataS, '^',1) <> FileNum then continue;
      if ORFn.Piece(dataS, '^',3) <> FldNum then continue;
      Value := ORFn.Piece(dataS, '^', 4);
      Results.Add(Value);
    end;
  end;

  function GetDataLine(GridData : TStringList; FileNum, IENS, FldNum : string) : string; overload;
  var i : integer;
      s : string;
      dataS : string;
  begin
    Result := '';
    s := FileNum + '^' + IENS + '^' + FldNum;
    for i := 0 to GridData.Count - 1 do begin
      dataS := GridData.Strings[i];
      if Pos(s, dataS) = 0 then continue;
      Result := dataS;
      break;
    end;
  end;

  function GetDataLine(GridInfo : TGridInfo; FileNum, IENS, FldNum : string) : string; overload;
  begin
    Result := GetDataLine(GridInfo.Data, FileNum, IENS, FldNum);
  end;

  function GetDataLine(GridData : TStringList; FldNum : string) : string; overload;
  var j : integer;
      dataS, Fld : String;
  begin
    Result := '';
    if not assigned(GridData) then exit;
    for j := 0 to GridData.Count - 1 do begin
      dataS := GridData.Strings[j];
      Fld := ORFn.Piece(dataS,'^',3);
      if Fld <> FldNum then continue;
      Result := dataS;
      break;
    end;
  end;

  function GetDataLine(GridInfo : TGridInfo; FldNum : string) : string; overload;
  begin
    Result := GetDataLine(GridInfo.Data, FldNum);
  end;

  function FieldValue(GridInfo : TGridInfo; FileNum, IENS, FldNum : string) : string; overload;
  var dataS : string;
  begin
    dataS := GetDataLine(GridInfo, FileNum, IENS, FldNum);
    Result := ORFn.Piece(dataS, '^',4);
  end;

  function FieldValue(GridData : TStringList; FileNum, IENS, FldNum : string) : string; overload;
  var dataS : string;
  begin
    dataS := GetDataLine(GridData, FileNum, IENS, FldNum);
    Result := ORFn.Piece(dataS, '^',4);
  end;

  function FieldValue(GridData : TStringList; FldNum : string) : string; overload;
  var dataS : string;
  begin
    dataS := GetDataLine(GridData, FldNum);
    Result := ORFn.Piece(dataS, '^',4);
  end;

  function FieldValue(GridInfo : TGridInfo; FldNum : string) : string; overload;
  var dataS : string;
  begin
    dataS := GetDataLine(GridInfo, FldNum);
    Result := ORFn.Piece(dataS, '^',4);
  end;


  function HandleTextEdit(InitValue, FileNum, IENS, FieldNum : string;
                          GridInfo : TGridInfo;
                          var Changed, CanSelect : boolean;
                          ExtraInfo : string; ExtraInfoSL : TStringList) : string;
  var
    frmFnFindingEdit : TfrmFnFindingEdit;

  begin
    Result := InitValue;
    if (FileNum = '811.925') and (FieldNum = '3') then begin  //Function Finding:FUNCTION STRING
      //MessageDlg('Here I would use custom handler.', mtInformation, [mbOK], 0);
      frmFnFindingEdit := TfrmFnFindingEdit.Create(MainForm);
      frmFnFindingEdit.Initialize(InitValue, GridInfo.IENS);
      if frmFnFindingEdit.ShowModal = mrOK then begin
        Result := frmFnFindingEdit.Result;
        Changed := (Result <> InitValue);
        CanSelect := true;
      end;
      FreeAndNil(frmFnFindingEdit);
    end else begin
      Result := GridU.HandleTextEdit(InitValue, FileNum, IENS, FieldNum, GridInfo,
                                     Changed, CanSelect, ExtraInfo, ExtraInfoSL);
    end;
  end;

  procedure LoadFindingsAndGridIntoSL(ListStr : string; Findings : TStringList);

    procedure SetupGridForFile(GridInfo : TCompleteGridInfo; FileNum : string);
    begin
      GridInfo.FileNum := FileNum;
      if FileNum = '811.925' then begin  //Function Finding
        GridInfo.FreeTextFieldEditor := HandleTextEdit;
        GridInfo.BasicTemplate.Assign(ReminderFuncFindingBasicTemplate);
      end else if FileNum = '811.902' then begin  //Regular Finding
        //Consider adding Basic template here...
      end;
    end;

  var Len : integer;
      Name, OneF : string;
      {AddIndex,} i : integer;
      IEN, IENS : string;
      AGridInfo : TCompleteGridInfo;  //won't own object
      FileNum : string;
      ReqGender : string;

  begin
    Len := NumPieces(ListStr,';');
    for i := 1 to Len do begin
      OneF := Trim(ORFn.Piece(ListStr,';',i));
      if OneF = '' then continue;
      if (OneF='SEX') or (OneF='AGE') then begin
        FileNum := '';
        AGridInfo := nil;
        Name := OneF;
        if OneF='SEX' then begin
          ReqGender := FieldValue(ReminderGridInfo, '811.9', ReminderIENS, '1.9');
          if ReqGender = '' then begin
            ReqGender := 'MALE_OR_FEMALE';
          end;
          Name := ReqGender;
          VinSexSubStr := ReqGender;
        end;
      end else if (Pos('FF',OneF)=1) then begin
        FileNum := '811.925';
        IEN := ORFn.Piece(OneF,'FF',2);
        Name := 'FF(' + IEN + ')';
      end else if Pos('FI(',OneF)>0 then begin
        FileNum := '811.902';
        IEN := ORFn.Piece(ORFn.Piece(OneF,'FI(',2),')',1);
        Name := OneF;
      end else if (StrToIntDef(OneF,-99) = -99) then begin
        FileNum := '';
        AGridInfo := nil;
        Name := OneF;
      end else begin
        FileNum := '811.902';
        IEN := OneF;
        Name := 'FI(' + IEN + ')';
      end;
      if Findings.IndexOf(Name) > -1 then begin
        //Avoid adding entry multiple times ....
        continue;
      end;
      if FileNum <> '' then begin
        AGridInfo := TCompleteGridInfo.Create;  //NewGridInfo();
        SetupGridForFile(AGridInfo, FileNum);
        IENS := IEN + ',' + ReminderIENS;
        AGridInfo.IENS := IENS;
        GetOneRecord(FileNum, IENS, AGridInfo.Data, nil);
        {AddIndex := }Findings.AddObject(Name, AGridInfo);  //kt
      end else begin  //kt 2/25/13
        {AddIndex := }Findings.AddObject(Name, nil);
      end;
    end;
  end;

  function ObjJustName(S : string) : string;
  begin
    Result := StringReplace(S, '[#', '', [rfReplaceAll]);
    Result := StringReplace(Result, ']', '', [rfReplaceAll]);
  end;

  procedure FixMultiUseFindings(var FindingsUsed, SubLogic, tempFindingsUsed : string);
  //If a finding is used in sublogic, that is also used in a parent logic string,
  // then rename findings
  var i, count : integer;
      OneFinding, NewOneFinding : string;
  begin
    for i := 1 to NumPieces(tempFindingsUsed,';') do begin
      OneFinding := ORFn.Piece(tempFindingsUsed,';',i);
      if OneFinding = '' then continue;
      if Pos(SUBLOGIC, OneFinding) > 0 then continue;
      NewOneFinding := OneFinding;
      while (Pos(NewOneFinding, FindingsUsed)> 0) do begin
        if Pos('_', NewOneFinding) > 0 then begin
          count := StrToIntDef(ORFn.Piece(NewOneFinding, '_', 2),0);
          inc (count);
        end else begin
          count := 1
        end;
        SetPiece(NewOneFinding, '_', 2, IntToStr(count));
      end;
      if OneFinding <> NewOneFinding then begin
        SubLogic := StringReplace(SubLogic, OneFinding, NewOneFinding,[rfReplaceAll]);
        SetPiece(tempFindingsUsed, ';', i, NewOneFinding);
      end;
    end;
  end;

  function NewNumberedName(Name : string; var FindingsUsed : string) : string;
  var i: integer;
  begin
    i := 0;
    repeat
      Result := Name;
      if i>0 then Result := Result + '_' + IntToStr(i);
      if FindingsSL.IndexOf(Result) < 0 then begin
        FindingsSL.AddObject(Result, Nil);
        FindingsUsed := FindingsUsed + Result + ';';
        break;
      end;
      inc (i);
    until (0=1);
  end;


  function CheckParseLogic(LogicStr : string; var FindingsUsed : string) : string;
  var
    BoolS,ObjS, S2, SubS : string;
    tempS : string;
    FirstCycle : boolean;
    tempFindingsUsed : string;

    function IsBool(S : string) : boolean;
    begin
      Result := ((S = 'AND') or (S = 'NOT') or (S = 'OR'));
    end;

  begin
    Result := '';
    FindingsUsed := '';
    FirstCycle := true;
    tempS := Trim(LogicStr);
    while (tempS <> '') do begin
      BoolS := ORFn.Piece(tempS, ' ',1);
      if not IsBool(BoolS) then begin
        if FirstCycle then begin
          tempS := 'AND ' + tempS;
          continue;
        end else begin
          Raise Exception.Create('Expecting: "AND", "OR", or "NOT" first  Got "'+BoolS+'" in string: "' + LogicStr);
        end;
      end;
      tempS := MidStr(tempS, Length(BoolS)+2,Length(tempS));
      Result := Result + BoolS + ' ';
      ObjS := ORFn.Piece(tempS, ' ', 1);
      tempS := MidStr(tempS, Length(ObjS)+2,Length(tempS));
      if (ObjS <> '') and (ObjS[1]='(') then begin
        S2 := ObjS + ' ' + tempS;
        SubS := ExtractParens(S2, tempS);
        tempS := Trim(tempS);
        tempFindingsUsed := '';
        SubS := CheckParseLogic(SubS, tempFindingsUsed);
        FixMultiUseFindings(FindingsUsed, SubS, tempFindingsUsed);
        FindingsUsed := FindingsUsed + tempFindingsUsed;
        if (NumPieces(tempFindingsUsed,';')=2) and (RightStr(tempFindingsUsed,1)=';')
        and (ORFn.Piece(subS,' ',1)='AND') then begin
          SubS := Trim(ORFn.Piece(subS,' ',2));
          Result :=  Result + '[#' + NewNumberedName(SubS, tempFindingsUsed) + '] ';
        end else begin
          Result :=  Result + '[#' + NewNumberedName(SUBLOGIC, FindingsUsed) + ']:(' + SubS + ') ';
        end;
      end else begin
        Result := Result + ObjS + ' ';
        FindingsUsed := FindingsUsed + ObjJustName(ObjS) + ';';
      end;
      FirstCycle := false;
    end;
    Result := Trim(Result);
  end;

  function PrepLogicStr(LogicStr : string; var FindingsUsed : string; FindingsSL : TStringList) : string;
  //Convert logic string as found in Reminder record into
  ///  logic string used by Vin Diagrams.
  //  (SEX)&(AGE)&FI(2)&'FI(11)&'FI(12)&FF(1)
  //  (1)&FI(8)&FI(10)
  //
  //Example output: 'AND [#MALE] AND [#AGE] AND [#FI(1)] NOT [#FI(2)] NOT [#FI(3)] NOT [#FI(7)]'
  //  String Format: LogicTerm <space> Object <space>
  //  Object Format: [#<Name>]
  //
  var i : integer;
      name, ID : string;
  begin
    Result := LogicStr;
    Result := StringReplace(Result, '&''', ' NOT ', [rfReplaceAll]);
    Result := StringReplace(Result, '&', ' AND ', [rfReplaceAll]);
    Result := StringReplace(Result, '!', ' OR ', [rfReplaceAll]);
    Result := StringReplace(Result, '''', ' NOT ', [rfReplaceAll]);
    Result := StringReplace(Result, 'FF(0)', '^$^', [rfReplaceAll]);
    Result := StringReplace(Result, 'FI(0)', '^%^', [rfReplaceAll]);
    Result := StringReplace(Result, '(0)', '', [rfReplaceAll]);
    Result := StringReplace(Result, '^$^', 'FF(0)', [rfReplaceAll]);
    Result := StringReplace(Result, '^%^', 'FI(0)', [rfReplaceAll]);
    Result := StringReplace(Result, 'FF(1)', '^$^', [rfReplaceAll]);
    Result := StringReplace(Result, 'FI(1)', '^%^', [rfReplaceAll]);
    Result := StringReplace(Result, '(1)', '', [rfReplaceAll]);
    Result := StringReplace(Result, '^$^', 'FF(1)', [rfReplaceAll]);
    Result := StringReplace(Result, '^%^', 'FI(1)', [rfReplaceAll]);
    //Result := StringReplace(Result, '(SEX)', 'SEX', [rfReplaceAll]);
    //Result := StringReplace(Result, '(AGE)', 'AGE', [rfReplaceAll]);
    for i := 0 to FindingsSL.Count - 1 do begin
      name := FindingsSL.Strings[i];
      ID := '[#' + name + ']';
      if name = VinSexSubStr then begin
        name := 'SEX';
      end;
      Result := StringReplace(Result, '('+name+')', '^$^', [rfReplaceAll]);
      Result := StringReplace(Result, name, ID, [rfReplaceAll]);
      Result := StringReplace(Result, '^$^', ID, [rfReplaceAll]);
      if (Pos(name, FindingsUsed) = 0) and (Pos(Name, LogicStr)>0) then begin
        //FindingsUsed := FindingsUsed + name + ';';
      end;
    end;
    Result := CheckParseLogic(Result, FindingsUsed);
    Result := Trim(Result);
  end;

  function IsFnName(Name : string; out DispName : string; out FnType : TfnnName) : boolean;
  //DispName is out parameter
  var i : TfnnName;
  begin
    Result := false;
    for i := fnnCount to LAST_FN_NAME do begin
      if REM_FUNCT_INFO[i].Name <> Name then continue;
      DispName := REM_FUNCT_INFO[i].DispName;
      FnType := i;
      Result := true;
      break;
    end;
  end;

  function StripTrailingNum(S : String) : string;
  var ch : char;
  begin
    Result := S;
    while Result <> '' do begin
      ch := Result[Length(Result)];
      if (Pos(ch, NUM_CHARS) = 0) and (ch <> '_') then break;
      Result := LeftStr(Result, Length(Result)-1);
    end;
  end;

  {
  function ExtractQtValue(var TempS : string) : string;
  //Expectes first character to be a " char.  Returns terminating "
  //  Honors double "" format.
  var p, EndP : integer;
  begin
    result := '';
    EndP := 0;
    p := 1;
    repeat
      p := PosEx('"',TempS, p+1);
      if p > 0 then EndP := p;
      if (p < Length(TempS)) and (TempS[p+1] = '"') then begin
        p := PosEx('"',TempS, p+2);
      end;
    until (EndP > 0) or (p = 0);
    if p = 0 then exit;
    Result := MidStr(TempS, 1, EndP);
    TempS := MidStr(TempS, EndP+1, Length(TempS));
  end;
  }

  function ExtractNumValueAndModInput(var TempS : string) : string;
  //Expects first character to be numeric.
  var p : integer;
  begin
    Result := '';
    p := 1;
    repeat
      inc(p)
    until (p > length(tempS)) or (Pos(TempS[p], NUM_CHARS) = 0);
    Result := MidStr(TempS, 1, p-1);
    TempS := MidStr(TempS, p, Length(TempS));
  end;

  function CheckParseComparatorStr(CompStr : string; var FindingsUsed : string) : string;

   type
     TPartType = (ptNone,
                  ptReminderFn,   // an allowed function
                  ptNum,          // A number
                  ptMumpsFn,      // An allowed mumps function:
                  ptReminderVar,  // A specific reminder globally-scoped variable:
                  ptString);      // A non-executable string.

    function ExtractFnNameOrValue(Var TempS, Params : string; var ResultType : TPartType) : string;
    //Uses FindingsUsed in locally-global scope.

      //Next part can be: an allowed function
      //                  A number
      //                  An allowed mumps function:
      //                     currently, only $P (not $PIECE)
      //                  A globally-scoped variable:
      //                    PXRMAGE
      //                    PXRMDOB
      //                    PXRMLAD
      //                    PXRMSEX
      //                  A non-executable string.


      function FormatParams(Params : string; var FindingsUsed : string) : string;
        function ValInParentheses(Param : string) : string;
        begin
          Result := ORFn.Piece(Param,'(',2);
          Result := ORFn.Piece(Result,')',1);
        end;

      var i,J : integer;
          oneParam, oneUsed : string;
          Found : boolean;
          Num,Num2 : integer;
      begin
        Result := '';
        if (Pos(',', Params) = 0) then Params := Params + ',';
        Num := NumPieces(Params, ',');
        Num2 := NumPieces(FindingsUsed, ';');
        for i := 1 to Num do begin
          OneParam := ORFn.Piece(Params, ',',i);
          if OneParam = '' then continue;
          Found := false;
          for j := 1 to Num2 do begin
            oneUsed := ORFn.Piece(FindingsUsed,';',j);
            if UpperCase(ValInParentheses(oneUsed)) <> UpperCase(OneParam) then continue;
            Found := true;
            OneParam := oneUsed;
            break;
          end;
          if not Found then begin
            OneParam := 'FI(' + OneParam + ')';  //kt
            if Pos(OneParam+';', FindingsUsed)=0 then begin
              FindingsUsed := FindingsUsed + OneParam + ';';
            end;
          end;
          //kt Result := Result + 'OBJ ' + '[#FI('+OneParam+')] ';
          Result := Result + 'OBJ ' + '[#'+OneParam+'] ';
          if i <> Num then Result := Result + ', ';
        end;
        Result := Trim(Result);
      end;

    var ch : char;
        DiscardStr : string;
        DiscardFnName : TfnnName;
    begin
      Result := '';
      Params := '';
      ResultType := ptNone;
      if TempS = '' then exit;
      ch := TempS[1];
      if ch='"' then begin
        Result := ExtractQtValue(TempS);
        ResultType := ptString;
      end else if MidStr(TempS, 1,4) = 'PXRM' then begin
        //ExtractPXRMVar: PXRMAGE, PXRMDOB, PXRMLAD, PXRMSEX
        Result := MidStr(TempS, 1,8);  //all the var names are 8 characters:
        TempS := MidStr(TempS, 9, Length(TempS));
        ResultType := ptReminderVar;
      end else if Pos(ch, NUM_CHARS) > 0 then begin
        Result := ExtractNumValueAndModInput(TempS);
        ResultType := ptNum;
      end else if ch = '$' then begin
        ResultType := ptMumpsFn;
      end else begin
        Result := ORFn.Piece(tempS, '(',1);
        if (Result <> '') and (Result[1] = '$') then begin
          ResultType := ptMumpsFn;
        end else begin
          ResultType := ptReminderFn;
        end;
        if (ResultType = ptReminderFn) and (IsFnName(Result, DiscardStr, DiscardFnName)=false) then Raise Exception.Create('Expecting function name.  Got "'+Result+'" in string: "' + CompStr);
        tempS := MidStr(tempS, Length(Result)+1,Length(tempS));
        if (tempS = '') or (tempS[1] <> '(') then Raise Exception.Create('Expecting "(" after function name ' + Result + ' in string: "' + CompStr);
        Params := ExtractParens(tempS, tempS);
        if Params='' then Raise Exception.Create('No parameters found after function name ' + Result + ' in string: "' + CompStr);
        if (ResultType = ptReminderFn) then Params := FormatParams(Params, FindingsUsed);
      end;
    end;

    function ExtractComparator(var TempS : string) : string;
    begin
      Result := '';
      if Length(TempS)=0 then exit;
      if TempS[1] = '''' then begin
        Result := '''';
        TempS := MidStr(TempS, 2, Length(TempS));
      end;
      while (Length(TempS) > 0) and (Pos(TempS[1], OPER_CHARS) > 0)  do begin
        Result := Result + TempS[1];
        TempS := MidStr(TempS, 2, Length(TempS));
      end;
    end;

  var
    tempS, FnNameOrValue, CompName,
    Params, SubS, ObjName  : string;
    ResultType : TPartType;

  begin
    Result := '';
    tempS := UpperCase(CompStr);
    while tempS <> '' do begin
      tempS := Trim(tempS);
      if tempS = '' then continue;
      if tempS[1] = '(' then begin
        SubS := ExtractParens(tempS, tempS);
        SubS := CheckParseComparatorStr(SubS, FindingsUsed);
        ObjName := NewNumberedName(SUBLOGIC, FindingsUsed);
        //Result := Result + ObjName + ':(' + SubS + ') ';
        Result := Result + 'OBJ [#' + ObjName + ']:(' + SubS + ') ';
        continue;
      end;
      FnNameOrValue := ExtractFnNameOrValue(TempS, Params, ResultType);
      if ResultType = ptNum then begin
        FnNameOrValue := VALUE_PREFIX + FnNameOrValue;
      end;
      ObjName := NewNumberedName(FnNameOrValue, FindingsUsed);
      Result := Result + 'OBJ [#' + ObjName + ']';
      if Params <> '' then Result := Result + ':(' + Params + ')';
      Result := Result + ' ';
      tempS := Trim(tempS);
      if tempS = '' then continue;
      CompName := ExtractComparator(TempS);
      Result := Result + CompName + ' ';
    end;
  end;


  function PrepComparatorStr(CompStr : string; var FindingsUsed : string) : string;
  //Convert comparator string as found in function findings record into
  ///  logic string used by Venn Diagrams.
  //  'MRD(1,2)>MRD(10,11)'
  //  'DUR(2,3,4,5)'<DUR(7,8,9)

    //Example LogicStr: 'MRD(1,2)>MRD(10,11)'
    //        FindingsUsed list will contain: '1', '10', '2', '11'
    //NOTE: I need to make 1 VennObj for each function (e.g. MRD).
    //      And the parameters (which can be multiple) will be children
    //Convertinto format...
    //     or  OBJ [#A]:(OBJ [#1] OBJ [#2]) >= [#B]:(OBJ [#3] OBJ [#4])

    //Example:
    //Input: 'DIFF_DATE(8,14)>21914'
    //Output: 'OBJ [#DIFF_DATE_1]:(OBJ [#FI(8)] , OBJ [#FI(14)]) > OBJ [#VALUE_21914_1]'

    function StripLeadingSpace(S : string; Ch : char) : string;
    var tempS : string;
    begin
      Result := S;
      repeat
        tempS := StringReplace(Result, ' ' + Ch, Ch, [rfReplaceAll]);
        if tempS = Result then break;
        Result := tempS;
      until (1=0);
    end;

  var i : integer;
      Oper : char;
  begin
    Result := CompStr;
    Result := StripLeadingSpace(Result, '''');
    for i := 1 to length(OPER_CHARS)do begin
      Oper := OPER_CHARS[i];
      Result := StringReplace(Result, NOT_CHAR + Oper, '@~', [rfReplaceAll]);
      Result := StripLeadingSpace(Result, Oper);
      Result := StringReplace(Result, Oper, ' ' + Oper + ' ', [rfReplaceAll]);
      Result := StringReplace(Result, '@~', ' ' + NOT_CHAR + Oper + ' ', [rfReplaceAll]);
    end;
    Result := CheckParseComparatorStr(Result, FindingsUsed);
    Result := Trim(Result);
  end;

  function GetCohortLogic : string;
  begin
    Result := FieldValue(ReminderGridInfo, ReminderFile, ReminderIENS, '31');
    //Finish -- check for internal vs custom logic
  end;

  function GetResolutionLogic : string;
  begin
    Result := FieldValue(ReminderGridInfo, ReminderFile, ReminderIENS, '35');
    //Finish -- check for internal vs custom logic
  end;

  function GetUtilityLogic(S : string) : string;
  var i, Len : integer;
      OneF : string;
  begin
    Result := '';
    Len := NumPieces(S, ';');
    for i := 1 to Len do begin
      OneF := Trim(ORFn.Piece(S,';', i));
      if OneF = '' then continue;
      if Pos('FF', OneF) > 0 then begin
        OneF := 'FF(' + ORFn.Piece(OneF, 'FF',2) + ')';
      end;
      Result := Result + OneF + ',';
    end;
  end;

  function GetUnusedFingsList(GridInfo : TGridInfo; List1Str, List2Str : string) : string;
  //private
  var i : integer;
      RecNum : string;
      Filenum, IENS : string;
      Fileman : TFileman; //Owned here
      FMFile, FMSubFile : TFMFile;  //not owned here
      FMRecord : TFMRecord; //not owned here
      RecordList : TStringList;

      procedure HandleAString(RecordList : TStringList; S : string; IsFF : boolean = false);
      var Len, i, j : integer;
          OneF : string;
      begin
        Len := NumPieces(S,';');
        for i := 1 to Len do begin
          OneF := Trim(ORFn.Piece(S,';',i));
          if IsFF then OneF := ORFn.piece(OneF, 'FF', 2);
          j := RecordList.IndexOfName(OneF);
          if j = -1 then continue;
          RecordList.Delete(j);
        end;
      end;

  begin
    Result := '';
    Filenum := GridInfo.FileNum;
    if Filenum <> '811.9' then exit;

    IENS := GridInfo.IENS;
    Fileman := TFileman.Create;
    RecordList := TStringList.Create;
    try
      FMFile := Fileman.FMFile[Filenum];
      FMRecord := FMFile.FMRecord[IENS];
      FMSubFile := FMRecord.FMField['20'].Subfile;  //20 = FINDINGS
      FMSubFile.GetRecordsList(RecordList);
      HandleAString(RecordList, List1Str, false);
      HandleAString(RecordList, List2Str, false);
      for i := 0 to RecordList.Count - 1 do begin
        RecNum := ORFn.Piece(RecordList.Strings[i], '=', 1);
        Result := Result + 'FI(' + RecNum + ');';
      end;
      FMSubFile := FMRecord.FMField['25'].Subfile; //25 = FUNCTION FINDINGS
      FMSubFile.GetRecordsList(RecordList);
      HandleAString(RecordList, List1Str, true);
      HandleAString(RecordList, List2Str, true);
      for i := 0 to RecordList.Count - 1 do begin
        RecNum := ORFn.Piece(RecordList.Strings[i], '=', 1);
        Result := Result + 'FF' + RecNum + ';';
      end;
    finally
      Fileman.Free;
      RecordList.Free;
    end;
  end;

  function PrepObjListStr(S : string; var FindingsUsed : string) : string;
  var Len, i, j : integer;
      OneF : string;
  begin
    Result := '';
    FindingsUsed := '';
    Len := NumPieces(S,',');
    for i := 1 to Len do begin
      OneF := Trim(ORFn.Piece(S,',',i));
      if OneF = '' then continue;
      if Result <> '' then Result := Result + ' , ';
      {if Pos('FF', OneF)>0 then begin
        OneF := 'FF(' + ORFn.piece(OneF, 'FF', 2) + ')';
      end;}
      Result := Result + 'OBJ [#' + OneF + '] ';
      FindingsUsed := FindingsUsed + OneF + ';';
    end;
    Result := Trim(Result);
  end;


  procedure InitializeVenn (GridInfo : TGridInfo);
  begin
    Clear;
    //CopyGridInfo(GridInfo,ReminderGridInfo);
    ReminderGridInfo.Assign(GridInfo);
    ReminderIENS := GridInfo.IENS;
    ReminderFile := GridInfo.FileNum;

    CohortFindingsListStr     := FieldValue(ReminderGridInfo, ReminderFile, ReminderIENS, '33');
    ResolutionFindingsListStr := FieldValue(ReminderGridInfo, ReminderFile, ReminderIENS, '37');
    UtilityFindingsListStr := GetUnusedFingsList(GridInfo, CohortFindingsListStr, ResolutionFindingsListStr);

    CohortLogic     := GetCohortLogic;
    ResolutionLogic := GetResolutionLogic;
    UtilityLogic    := GetUtilityLogic(UtilityFindingsListStr);
    VinSexSubStr := '';

    LoadFindingsAndGridIntoSL(CohortFindingsListStr, FindingsSL);
    LoadFindingsAndGridIntoSL(ResolutionFindingsListStr, FindingsSL);
    LoadFindingsAndGridIntoSL(UtilityFindingsListStr, FindingsSL);

    VinCohortLogicStr     := PrepLogicStr(CohortLogic, VinCohortFindingsUsed, FindingsSL);
    VinResolutionLogicStr := PrepLogicStr(ResolutionLogic, VinResolutionFindingsUsed, FindingsSL);
    VinUtilityLogicStr    := PrepObjListStr(UtilityLogic, VinUtilityFindingsUsed);

  end;

  procedure InitializeVenn (Grid : TSortStringGrid; IEN : longInt);
  var GridInfo : TGridInfo;
  begin
    GridInfo := GetInfoObjectForGrid(Grid);
    if GridInfo = nil then exit;
    GridInfo.IENS := IntToStr(IEN)+',';
    MainForm.GetRemDefInfo(GridInfo);
    InitializeVenn(GridInfo);
  end;


  procedure LoadAVennFormRgnMgr(AVennForm : TVennForm;
                                FindingsUsed : string;
                                Findings : TStringList;
                                HideHints : boolean = false;
                                AllowUserManipulation : boolean = true;
                                ObjOwnsGridInfo : boolean = false);
  var i,Idx : integer;
      Name, PrintName, ID : string;
      Obj : TRemObj;
      AGridInfo : TCompleteGridInfo;  //won't own object
  begin
    AVennForm.LastDisplayed_FindingsUsed := FindingsUsed;
    AVennForm.RgnMgr.ClearChildren;
    for i := 1 to NumPieces(FindingsUsed, ';') do begin
      ID := ORFn.Piece(FindingsUsed,';',i);
      if ID = '' then continue;
      Obj  := AVennForm.AddRemObject;
      Obj.HideHint := HideHints;
      Obj.OnDeleteRequest := HandleObjDeleteRequest;
      Name := ID;
      Obj.ID := ID;
      if Pos(SUBLOGIC, Name) > 0 then begin
        Name := SUBLOGIC_GROUP;
        //Obj.FunctionType := fnrBoolean;
      end;
      if Pos(VALUE_PREFIX, Name) > 0 then begin
        Obj.FunctionType := fnnValue;
      end;
      Obj.Name := Name;
      Obj.CanResize := AllowUserManipulation;
      Obj.CanDelete := AllowUserManipulation;
      Obj.CanDrag := AllowUserManipulation;
      Obj.CanEject := AllowUserManipulation;
      Idx := Findings.IndexOf(ID);
      if Idx < 0 then continue;
      AGridInfo := TCompleteGridInfo(Findings.Objects[Idx]);
      Obj.GridInfo := AGridInfo;
      Obj.OwnsGridInfo := ObjOwnsGridInfo;
      if ObjOwnsGridInfo then Findings.Objects[Idx] := nil;
      if not assigned(AGridInfo) then continue;
      Name := FieldValue(AGridInfo, '.01');
      if (Pos('FF', ID) > 0) and (StrToIntDef(Name,-1)<>-1) then begin
        PrintName := FieldValue(AGridInfo, '40');
        if PrintName <> '' then PrintName := PrintName + '--';
        Name := PrintName + 'Function #' + Name;
      end;
      Obj.Name := Name;
    end;
  end;

  Procedure DisplayVennsIntoAVennForm(AVennForm: TVennForm; LogicStr, FindingsUsed: string; FindingsSL : TStringList);
  begin
    if LogicStr = '' then begin
      AVennForm.RgnMgr.ClearChildren;
      exit;
    end;
    LoadAVennFormRgnMgr(AVennForm, FindingsUsed, FindingsSL);
    AVennForm.RgnMgr.LoadFromLogicString(LogicStr);
    AVennForm.RgnMgr.AutoArrangeChildrenAndGrandchildren;
    AVennForm.RgnMgr.SetSelection(nil);
  end;

  procedure DisplayVenns(Mode : TDisplayVMode);
  var  LogicStr, FindingsUsed : string;
  begin
    VennDisplayMode := Mode;
    case Mode of
      dvmCohort :     begin
                        FindingsUsed := VinCohortFindingsUsed;
                        LogicStr := VinCohortLogicStr;
                      end;
      dvmResolution : begin
                        FindingsUsed := VinResolutionFindingsUsed;
                        LogicStr := VinResolutionLogicStr;
                      end;
      dvmUtility :    begin
                        FindingsUsed := VinUtilityFindingsUsed;
                        LogicStr := VinUtilityLogicStr
                      end;
    end; {case}
    DisplayVennsIntoAVennForm(VennForm, LogicStr, FindingsUsed, FindingsSL);
  end;

  procedure HandleAgeDetailClick;
  //This will only be called when user asks for details for AGE VennObject
  var i, Row : integer;
      CanSelect : boolean;
  begin
    //Search in RemDefGrid for cell with field number 7
    Row := -1;
    for i := 1 to MainForm.RemDefGrid.RowCount-1 do begin
     if MainForm.RemDefGrid.Cells[0,i]='7' then begin  //Searching for field #7
       Row := i;
       break
     end;
    end;
    if Row = -1 then exit;
    //Simulate click into BASELINE AGE FINDINGS field
    MainForm.GridSelectCell(MainForm.RemDefGrid, 2, Row, CanSelect);
  end;

  function HandleAgeDeleteClick : boolean;
  //Remove (AGE) from fndings
  //This won't remove age finding subfile entries.
    function NextNonLogicChar(s : string; p, Dir : integer) : integer;
    begin
      repeat
        p := p + Dir;
        if p<=1 then begin
          Result := 1;
        end else if p>=length(s) then begin
          Result := Length(s);
        end else begin
          if not (s[p] in ['`','!','&']) then break;
        end;
      until (p=1) or (p=length(s));
      Result := p;
    end;

  var
    FileMan : TFileman;            //owned here
    FMFile : TFMFile;              //not owned here
    FMRecord : TFMRecord;          //not owned here
    IEN : LongInt;
    StartP, EndP, P : integer;
    InternalCohortLogic, FindingsListStr, FindingCount : string;
    Count : integer;

  begin
    Result := true;
    IEN := MainForm.orcboSelRemDef.ItemIEN;
    if IEN < 1 then begin
      MessageDlg('Can''t determine which reminder to remove "AGE" from',
                 mtError, [mbOK], 0);
      Result := false;
      exit;
    end;
    Fileman := TFileman.Create;
    try
      FMFile := FileMan.FMFile['811.9'];
      FMRecord := FMFile.FMRecord[IntToStr(IEN)];

      //31=INTERNAL PATIENT COHORT LOGIC
      InternalCohortLogic := FMRecord.FMField['31'].Value;
      P := Pos('(AGE)', InternalCohortLogic);
      if P <> 0 then begin
        //InternalCohortLogic := '(AGE)&' + InternalCohortLogic;
        if P=1 then begin  //logic string STARTS with AGE
          p := length('(AGE)')+1;
          EndP := NextNonLogicChar(InternalCohortLogic, p, 1);
          InternalCohortLogic := MidStr(InternalCohortLogic, EndP, Length(InternalCohortLogic));
        end else begin
          EndP := p + length('(AGE)');
          StartP := NextNonLogicChar(InternalCohortLogic, p, -1);
          InternalCohortLogic := MidStr(InternalCohortLogic, 1, StartP) +
                                 MidStr(InternalCohortLogic, EndP, Length(InternalCohortLogic));
        end;
        FMRecord.FMField['31'].Value := InternalCohortLogic;
      end;
      //33=PATIENT COHORT FINDING LIST
      FindingsListStr := FMRecord.FMField['33'].Value;
      p := Pos('AGE;', FindingsListStr);
      if p = 0 then p := Pos(';AGE', FindingsListStr);
      if p <> 0 then begin
        //FindingsListStr := 'AGE;' + FindingsListStr;
        if p=1 then begin
          FindingsListStr := MidStr(FindingsListStr, Length('AGE;')+1, length(FindingsListStr));
        end else begin
          FindingsListStr := MidStr(FindingsListStr, 1, p-1) +
                             MidStr(FindingsListStr, p + Length('AGE;'), length(FindingsListStr));
        end;
        FMRecord.FMField['33'].Value := FindingsListStr;

        //32=PATIENT COHORT FINDING COUNT
        FindingCount := FMRecord.FMField['32'].Value;
        Count := StrToIntDef(FindingCount,0);
        if Count > 0 then Dec(Count);
        FMRecord.FMField['32'].Value := IntToStr(Count);
      end;
      Result := FMRecord.PostChanges;
      if Result = true then MainForm.orcboSelRemDefClick(nil);
    finally
      Fileman.Free;
    end;
  end;

  //--------------------------------------------------------------------
  //--------------------------------------------------------------------
  //Below is code to prepair fFindingDetail  //was frmFuncFindings.
  //NOTE: this is meant to be called after the above is prepaired, so
  //      the globally scoped data can still be used (it should refer to
  //      the parent record.
  Procedure PrepFuncFindingSubVennForm(AVennForm : TVennForm;
                                       LogicStr : string;
                                       FindingsUsed : String);

    function NumericComboMode(Obj : TVennObj) : boolean;
    var
      ComboMode : TCombinationStyle;
    begin
      ComboMode := Obj.CombinationMode;
      Result := (ComboMode in [FIRST_NUMERIC_COMPARATOR..LAST_NUMERIC_COMPARATOR]);
    end;

    function FormattedName(Name : string; FnType : TfnnName) : string;
    var Num : integer;
        fDays : single;
        Y,M,D : single;
        iY,iM,iD : integer;
    begin
      //Format for various types in CASE statement....
      case REM_FUNCT_INFO[FnType].ResultType of
        fnrDate :        begin
                           //convert Name string into a date
                         end;
        fnrDateDuration: begin
                           //convert name string into a number of years, months, days
                           Num := StrToIntDef(Name, NULL_CONVERT_DEF);
                           if Num <> NULL_CONVERT_DEF then begin
                             fDays := Num;
                             Y := fDays / 365.25;  fDays := fDays - Y*365.25;
                             M := fDays / 30;      fDays := fDays - M*30;
                             D := fDays;
                             Name := '';
                             iY := Round(Y); iM := Round(M); iD := Round(D);
                             if iY  > 0 then begin
                               Name := IntToStr(iY) + ' yr';
                               if iY > 1 then Name := Name + 's';
                             end;
                             if iM > 0 then begin
                               if Name <> '' then Name := Name + ', ';
                               Name := Name + IntToStr(iM) + ' m';
                             end;
                             if iD > 0 then begin
                               if Name <> '' then Name := Name + ', ';
                               Name := Name + IntToStr(iD) + ' d';
                             end;
                           end;
                         end;
      end; {case}
      Result := Name;
    end;

    procedure RenameChildrenIfNeeded(Parent : TVennObj);
    var
      i           : integer;
      Obj         : TVennObj;
      DispName, Name : string;
      ComboMode : TCombinationStyle;
      PriorObj    : TRemObj;
      ResultFnType : TfnnName;

    begin
      if not Assigned(Parent) then exit;
      if not Assigned(Parent.Children) then exit;
      for i:= 0 to Parent.Children.Count - 1 do begin
        Obj := Parent.Children[i];
        Name := Obj.Name;
        PriorObj := TRemObj(Obj.DataPtr1);
        if Pos(VALUE_PREFIX, Name) > 0 then begin
          DispName := ORFn.Piece(Name, VALUE_PREFIX, 2);
          DispName := ORFn.Piece(DispName, '_', 1);
          ComboMode := Obj.CombinationMode;
          if  NumericComboMode(Obj) and Assigned(PriorObj) then begin
            ResultFnType := PriorObj.FunctionType;
            if ResultFnType <> fnnNone then begin
              DispName := FormattedName(DispName, ResultFnType);
            end;
          end;
          Obj.Name := DispName;
        end else begin
          Name := StripTrailingNum(Name);
          if IsFnName(Name, DispName, ResultFnType) then begin
            Obj.Name := DispName;
            Obj.FunctionType := ResultFnType;
          end;
        end;
        if (Obj.FunctionType <> fnnNone) and NumericComboMode(Obj)
        and Assigned(PriorObj) and (PriorObj.FunctionType = fnnValue) then begin
          DispName := FormattedName(PriorObj.Name, Obj.FunctionType);
          PriorObj.Name := DispName;
        end;
        if Obj.Children.Count > 0 then begin
          RenameChildrenIfNeeded(Obj);
        end;
      end;
    end;

  var
    SubFindings : TStringList;
  const HIDE_HINTS = true;
        DISABLE_MANIPULATION = false;
  begin
    SubFindings := TStringList.Create;
    Try
      //Convert FM comparator string as found in function findings record into logic string used by Venn Diagrams.
      LogicStr :=PrepComparatorStr(LogicStr, FindingsUsed);
      if LogicStr = '' then exit;

      //Link finding names to GridInfo (record info) and load into SubFindings list.
      LoadFindingsAndGridIntoSL(FindingsUsed, SubFindings);

      //Add each object into Region Manager.  Objects will not yet be organized.
      LoadAVennFormRgnMgr(AVennForm, FindingsUsed, SubFindings, HIDE_HINTS, DISABLE_MANIPULATION);

      //Organize parent-child relationships for objects according to logic string.
      AVennForm.RgnMgr.LoadFromLogicString(LogicStr);

      //Set objects positions in manner for formula display
      AVennForm.RgnMgr.AutoArrangeChildrenForFormulaDisplay; //this will also arrange grandchildren etc.

      AVennForm.RgnMgr.SetSelection(nil);
      RenameChildrenIfNeeded(AVennForm.RgnMgr);

    finally
      SubFindings.Free;
    end;

  end;


  procedure LoadOtherFindingsAndGridIntoSL(ListStr : string; FindingsSL : TStringList;
                                           FindingSubfileNumber, ParentIENS : string);
  var Len : integer;
      Name, OneF : string;
      AddIndex, i : integer;
      IEN, IENS : string;
      AGridInfo : TCompleteGridInfo;  //won't own object
      FileNum : string;
      ReqGender : string;
  begin
    Len := NumPieces(ListStr,';');
    for i := 1 to Len do begin
      OneF := Trim(ORFn.Piece(ListStr,';',i));
      if OneF = '' then continue;
      if Pos('FI(',OneF)>0 then begin
        FileNum := FindingSubfileNumber;
        IEN := ORFn.Piece(ORFn.Piece(OneF,'FI(',2),')',1);
        Name := OneF;
      end else if (StrToIntDef(OneF,-99) = -99) then begin
        FileNum := '';
        AGridInfo := nil;
        Name := OneF;
      end else begin
        FileNum := FindingSubfileNumber;
        IEN := OneF;
        Name := 'FI(' + IEN + ')';
      end;
      if FindingsSL.IndexOf(Name) > -1 then begin
        //Avoid adding entry multiple times ....
        continue;
      end;
      if FileNum <> '' then begin
        AGridInfo := TCompleteGridInfo.Create; //NewGridInfo();
        AGridInfo.FileNum := FileNum;
        IENS := IEN + ',' + ParentIENS;
        AGridInfo.IENS := IENS;
        GetOneRecord(FileNum, IENS, AGridInfo.Data, nil);
        FindingsSL.AddObject(Name, AGridInfo);  //FindingsSL owns objects
      end else begin  //kt 2/25/13
        FindingsSL.AddObject(Name, nil);
      end;
    end;
  end;


  Procedure PrepFindingSubVennForm(AVennForm : TVennForm; LogicStr : string; FindingsUsed : String;
                                   FindingSubfileNumber, ParentIENS : string);
  const HIDE_HINTS : boolean = true;
        DISABLE_MANIPULATION : boolean = false;
        TRANSFER_OWNERSHIP : boolean = true;
  var
    FindingsSL : TStringList;
  begin
    FindingsSL := TStringList.Create;
    //Link finding names to GridInfo (record info) and load into FindingsSL list.
    //Upong return FindingsSL owns all the attached GridInfoObjects (but will transfer this to RgnMgr below)
    LoadOtherFindingsAndGridIntoSL(FindingsUsed, FindingsSL, FindingSubfileNumber, ParentIENS);

    //LogicStr :=PrepComparatorStr(LogicStr, FindingsUsed);
    LogicStr := PrepLogicStr(LogicStr, FindingsUsed, FindingsSL);

    //Add each object into Region Manager.  Objects will not yet be organized.
    LoadAVennFormRgnMgr(AVennForm, FindingsUsed, FindingsSL,
                        HIDE_HINTS, DISABLE_MANIPULATION, TRANSFER_OWNERSHIP);

    AVennForm.RgnMgr.LoadFromLogicString(LogicStr);
    AVennForm.RgnMgr.AutoArrangeChildrenAndGrandchildren; //this will also arrange grandchildren etc.
    AVennForm.RgnMgr.SetSelection(nil);

    FindingsSL.Free;  //Ownership of owned objects was transferred in LoadAVennFormRgnMgr()
  end;

  //--------------------------------------------------------------------
  //--------------------------------------------------------------------

initialization
  ReminderGridInfo := TCompleteGridInfo.Create;  //NewGridInfo();
  FindingsSL := TStringList.Create;
  Clear;

  ReminderFuncFindingBasicTemplate := TStringList.Create;
  GridU.InitReminderFunctionFindingTemplate(ReminderFuncFindingBasicTemplate);


finalization
  Clear;  //frees objects owned in FindingsSL
  FindingsSL.Free;
  ReminderGridInfo.Free;
  //FreeAndNilGridInfo(ReminderGridInfo);
  ReminderFuncFindingBasicTemplate.Free
end.

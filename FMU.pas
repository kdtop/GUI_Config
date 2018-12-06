unit FMU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Dialogs, StdCtrls, StrUtils, GridU, ORNet, ORFn, ComCtrls, ORCtrls,
  TypesU, GlobalsU, rRPCsU, ValEdit, UtilU, FMFindU;

//NOTE:
//  I.E.N (aka IEN) = INTERNAL ENTRY NUMBER.  This is a RECORD NUMBER.
//     these two terms will be used interchangably here.
//  IENS = INTERNAL ENTRY NUMBER STRING.  It is an expanded record number,
//       kind of like an URL.  It is:
//           IEN, Parent-IEN, Grandparent-IEN, .... ,
//       This is for subfiles.  Note string ends with a comma (,).

type
  TFMFile = class;
  TFMRecord = class;

  TFMField = class(TObject)  //note: must be class so can have constructor & destructor
  private
    FName : string;
    FFileNumber: string;
    FFldNumber : string;
    FDDInfo : String;
    FData : TStringList;  //not owned here
    FDataLine : String;
    FOriginalDataLine : String;  //Will = FDataLine until changes made by user.
    FType : TFieldType;
    FSymbolValue : TStringList;  //format:  Symbol:Meaning
    FVarPtrSymbolValue : TStringList;  //format: PREFIX=FileNumber^Name
    FSubfile : TFMFile;  //owned here.  Nil unless field is a subfile.
    FOriginalWP : TStringList;
    FWP : TStringList;
    FWPServerChecked : boolean;
    FParentRecord : TFMRecord;
    FIsComputed : boolean;
    FIsUneditable : boolean;
    function GetDateValue : TDateTime;
    procedure SetDateValue(Value : TDateTime);
    function GetValue : string;
    procedure SetValue(Value : string);
    function GetPtrIENValue : string;
    procedure SetPtrIENValue (IENValue : string);
    function GetNumberValue : Extended;
    procedure SetNumberValue(Value : Extended);
    function GetFldtype : TFieldtype;
    procedure SetupSymbolValue(SL : TStringList; PartDDInfo : string);
    procedure SetupVarPtrSymbolValue(SL : TStringList; DDInfo : TStringList);
    function GetWPData : TStringList;
    function IsLocalChanged : boolean;
    function GetSubfile : TFMFile;
    procedure SetSubfile(Value : TFMFile);
    function PostWPData : boolean;  //Only valid if Type=fmftWP
  public
    constructor Create(ParentFMRecord : TFMRecord; FieldNumber : string);
    destructor Destroy;
    procedure RefreshFromServer;
    function PointedToFile : string; //only valid for Type = fmftPtr or fmftVarPtr
    property Name : string read FName;
    property Number : string read FFldNumber;
    property FldType : TFieldType read FType;
    property Value : string read GetValue write SetValue;  //external form of field value
    property DateValue : TDateTime read GetDateValue write SetDateValue; //will be ignored if not proper type
    property OptionsOfSet : TStringList read FSymbolValue;  //Result is owned here.  Valid only if FldType=fmftSet
    property OptionsOfVarPtr : TStringList read FVarPtrSymbolValue; //Result is owned here.  Valid only if FldType=fmftVarPtr
    property WPValue : TStringList read GetWPData;  //Result is owned here.  Valid only if FldType=fmftWP
    //property PtrIENValue : string read GetPtrIENValue write SetPtrIENValue;
    property NumberValue : Extended read GetNumberValue write SetNumberValue;
    property IsComputed : boolean read FIsComputed;
    property IsUneditable : boolean read FIsUneditable;
    property FieldChanged : boolean read IsLocalChanged;
    property Subfile : TFMFile read GetSubfile write SetSubfile;  //Returned object is OWNED here.
  end;

  TFMRecord = class(TObject) //note: must be class so can have constructor & destructor
  private
    FFileNumber : string;
    FIEN : string;
    FIENS : string;
    FParentFile : TFMFile;
    FData : TStringList;
    FFieldsList : TStringList; //owns contained TFMField Objects  Strings=FldNumber^FldName
    procedure SetIENS(Value : string);
    function GetFMField(NumberOrName : string) : TFMField;
    procedure SetFMField(NumberOrName : string; Value : TFMField);
    function GetFMFieldByNumber(Number : string) : TFMField;
    procedure SetFMFieldByNumber(Number : string; Value : TFMField);
    function GetFMFieldByName(Name : string) : TFMField;
    procedure SetFMFieldByName(Name : string; Value : TFMField);
    function GetData : TStringList;
    procedure Clear;
  public
    constructor Create(ParentFMFile : TFMFile; AnIENS : string);
    destructor Destroy;
    procedure RefreshFromServer;
    function DeleteRec : boolean;  //Delete this record (with no confirmation!).  Returns TRUE if post is successful
    function PostChanges : boolean;
    property IENS : string read FIENS write setIENS;
    property IEN : string read FIEN;
    property Data : TStringList read GetData;
    property ParentFMFile : TFMFile read FParentFile;
    property FMField[NumberOrName : string] : TFMField read GetFMField write SetFMField;
    //property FMFieldByNumber[Number : string] : TFMField read GetFMFieldByNumber write SetFMFieldByNumber;
    //property FMFieldByName[Name : string] : TFMField read GetFMFieldByName write SetFMFieldByName;
  end;

  TFMFile = class(TObject)  //note: must be class (not record) so forward declaration can be used for mutually dependent objects/records
  private
    FFileNumber, FFileName : string;
    FIsSubfile : boolean;
    FIENS : string;  //only valid if FIsSubfile=TRUE.
    FDDInfo : TStringList;  //format: DDInfo.Strings[x]=Filenum^^FieldNum^DDInfo For Field
    FRecordsList : TStringList;  //owns contained TFMFileRecord objects.  String=IENS
    FScratchRecord : TFMRecord;
    FSrchResults : TSrchResults;
    procedure GetDDInfoFromServer;
    function GetDDInfo : TStringList;
    function GetFMRecord(IENorIENS : string) : TFMRecord;
    procedure HandleScratchRecordPosted(DestIEN : string);
    //procedure SetFMRecord(IEN : string; Value : TFMFileRecord);
    procedure Clear;
  protected
    procedure FreeRecord(ARec : TFMRecord);
  public
    constructor Create(FileNumber, FileName : string); overload;
    destructor Destroy;
    procedure RefreshFromServer;
    function DeleteRecord(IENorIENS : string) : boolean;  //WARNING: no confirmation asked before delete
    procedure GetRecordsList(RecordsListToFill : TStringList);
    procedure GetRecordsListRaw(RecordsListToFill : TStringList;  OUT Map : string; Fields : string = '');

    //Search1Record: Can return Nil, otherwise returned object is OWNED here.
    function Search1Record(Value: string; Flags: string = ''; Indexes: string = '';
                           Screen: string = '') : TFMRecord;

    //SearchRecords: Can return Nil, otherwise returned object is OWNED here.
    function SearchRecords(Value: string; Flags: string = ''; Number: string = '*';
                           Fields: string = '';Indexes: string = '';
                           Screen: string = ''; Identifier : string = '') : TSrchResults;

    //NOTE: Result of GetScratchRecord is owned here.  Used to create new record.
    //There is only ONE of these.  Not multiple.
    //To post changes to server, call .Post to returned TFMFileRecord pointer
    //After .Post, the record will be added to the list of records, and this
    //  scratch pointer will become invalid, and user should discard any copies.
    function GetScratchRecord : TFMRecord;
    function GetFoundRecord(OneResult : TOneSrchResult) : TFMRecord;
    property DDInfo : TStringList read GetDDInfo;
    property FileName : string read FFileName;
    property FileNumber : string read FFileNumber;
    property FMRecord[IENorIENS : string] : TFMRecord read GetFMRecord; // write SetFMRecord;  //Returned object is OWNED here.
  end;

  TFileman = class(TObject)
  private
    FMFilesPtrs : TStringList;
    function GetFMFile(NumberOrName: string) : TFMFile;
    function GetFMSubFile(NumberOrName: string; IENS : string) : TFMFile;
  public
    procedure Clear;
    constructor Create;
    destructor Destroy;
    //NOTE: TFileman will own objects returned by property FMFile and FMSubFile
    property FMFile[NumberOrName : String] : TFMFile read GetFMFile;
    //property FMSubFile[NumberOrName : String; IENS : string] : TFMFile read GetFMSubFile;
  end;


implementation

//-------------------------------------
//-------------------------------------

{
  procedure TFMVPtr.SetFMFile(Value : TFMFile);
  begin
    MessageDlg('To be implemented', mtError, [mbOK], 0);

  end;
}
//-------------------------------------
//-------------------------------------

  constructor TFMField.Create(ParentFMRecord : TFMRecord; FieldNumber : string);
  begin
    Inherited Create;
    FParentRecord := ParentFMRecord;
    FFldNumber := FieldNumber;
    FFileNumber:= FParentRecord.FFileNumber;
    FData := FParentRecord.Data;
    FDataLine := UtilU.GetOneLine(FData, FFileNumber, FFldNumber);
    FOriginalDataLine := FDataLine;
    FName := piece(FDataLine,'^',5);
    FDDInfo := Piece(FDataLine,'^',6);
    FType := GetFldtype;
    FSubfile := nil;
    FSymbolValue := TStringList.Create; //returned as property, so instantiate eve if not used
    FWP := TStringList.Create; //returned as property, so instantiate eve if not used
    FOriginalWP := TStringList.Create; //Instantiate even if not used
    FVarPtrSymbolValue := TStringList.Create; //Instantiate even if not used
    case FType of
      fmftVarPtr: SetupVarPtrSymbolValue(FVarPtrSymbolValue, FParentRecord.ParentFMFile.DDInfo);
      fmftSet: SetupSymbolValue(FSymbolValue, Piece(FDataLine,'^',7));
      fmftWP: ;
      fmftSubfile: ;  //handle later...
      else begin

      end;
    end;
  end;

  destructor TFMField.Destroy;
  begin
    FSymbolValue.Free;
    FWP.Free;
    FOriginalWP.Free;
    FVarPtrSymbolValue.Free;
    if Assigned(FSubfile) then begin
      FSubFile.Free;
    end;
    //
    inherited Destroy;
  end;

  procedure TFMField.SetupSymbolValue(SL : TStringList; PartDDInfo : string);
  begin
    PiecesToList(PartDDInfo, ';', SL);
    SL.Delimiter := ':';
  end;

  procedure TFMField.SetupVarPtrSymbolValue(SL : TStringList; DDInfo : TStringList);
  var
    i : integer;
    Lookup : string;
    OneS : string;
    P2File,Prefix,Name : string;
  begin
    SL.Clear;
    Lookup := 'INFO^DD^'+FFileNumber+'^'+FfldNumber+'^"V"';
    for i := 0 to DDInfo.Count - 1 do begin
      OneS := DDInfo[i];
      if Pos(Lookup, OneS)<1 then continue;
      OneS := Piece(OneS,'&=&',2);
      if OneS = '' then continue;
      //Now OneS format: PointedToFNum^Name^Order#^Prefix^HasScreen(Y/N)^LAYGO(Y/N)
      P2File := Piece(OneS, '^',1);
      Name := Piece(OneS, '^',2);
      Prefix := Piece(OneS, '^',4);
      OneS := IntToStr(i)+'^'+P2File+'^'+Name+'^'+Prefix;
      SL.Add(OneS);
      //SL.Add(Prefix+'='+P2File+'^'+Name);  //format: PREFIX=FileNumber^Name
    end;
  end;


  function TFMField.GetWPData : TStringList;
  begin
    if FWPServerChecked then begin
      Result := FWP;
    end else begin
      rRPCsU.GetWPField(FFileNumber, FFldNumber, FParentRecord.FIENS, FWP);
      FWPServerChecked := true;
      FOriginalWP.Assign(FWP);
    end;
  end;

  function TFMField.GetFldtype : TFieldtype;
  var
    FieldDef : string;
    discardSubFileNum : string;
  begin
    FieldDef := FDDInfo;  //just piece 6 of original line
    Result := fmftNone;
    if Pos('F',FieldDef)>0 then begin  //Free text
      Result := fmftFreeText;
    end else if Pos('N',FieldDef)>0 then begin  //Numeric value
      Result := fmftNumber;
    end else if IsSubFile(FieldDef, discardSubFileNum) then begin  //Subfiles.
      if IsWPField(CachedWPField, FFileNumber, FFldNumber) then begin
        Result := fmftWP;
      end else begin
        Result := fmftSubfile;
      end;
    end else if Pos('D',FieldDef)>0 then begin  //date field
      Result := fmftDate;
    end else if Pos('S',FieldDef)>0 then begin  //Set of Codes
      Result := fmftSet;
    end else if Pos('V',FieldDef)>0 then begin  //Variable Pointer to file.
      Result := fmftVarPtr;
    end else if Pos('P',FieldDef)>0 then begin  //Pointer to file.
      Result := fmftPtr;
    end;
    FIsComputed := (Pos('C',FieldDef)>0);  //computed fields.
    FIsUneditable := (Pos('I',FieldDef)>0);  //Uneditable field. 
  end;

  function TFMField.IsLocalChanged : boolean;
  begin
    if FType = fmftWP then begin
      Result := (FOriginalWP.Text <> FWP.Text);
    end else begin
      Result := (FOriginalDataLine <> FDataLine);
    end;
  end;

  function TFMField.GetDateValue : TDateTime;
  var FormatSettings : TFormatSettings;
      Value : string;
  begin
    //format from server is: MM/DD/YYYY@HH:MM:SS
    //Time is optional, and MM and DD can be single digits.
    Value := GetValue;
    Value := ReplaceStr(Value, '@', ' ');
    SysUtils.GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, FormatSettings);
    FormatSettings.ShortDateFormat := 'M/d/yyy'; //ensure matches server output
    Result := StrToDateTime(Value, FormatSettings);
  end;

  procedure TFMField.SetDateValue(Value : TDateTime);
  var FormatSettings : TFormatSettings;
      ValueStr : string;
  begin
    if IsComputed then exit;
    //format on server is: MM/DD/YYYY@HH:MM:SS
    //Time is optional, and MM and DD can be single digits.
    SysUtils.GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, FormatSettings);
    //Change settings here in case user local settings don't match server format...
    ValueStr := FloatToStr(Value, FormatSettings);
    //probably need to add a '@' .. FIX LATER...
    SetValue(ValueStr);
  end;

  function TFMField.GetValue : string;
  begin
    Result := piece(FDataLine,'^',4);
  end;

  procedure TFMField.SetValue(Value : string);
  begin
    if IsComputed then exit;
    SetPiece(FDataLine, '^', 4, Value);
  end;

  function TFMField.GetPtrIENValue : string;
  begin
    MessageDlg('To be implemented', mtError, [mbOK], 0);

  end;

  procedure TFMField.SetPtrIENValue (IENValue : string);
  begin
    if IsComputed then exit;
    MessageDlg('To be implemented', mtError, [mbOK], 0);

  end;

  function TFMField.PointedToFile : string;
  var
    Entry, Prefix : string;
  begin
    Result := '-1';
    if FType = fmftPtr then begin
      Result := piece(FDDInfo, 'P',2); //FDDInfo is just piece 6 of original line
    end else if FType = fmftVarPtr then begin
      Prefix := Piece(GetValue,'.',1);
      Entry := FVarPtrSymbolValue.Values[Prefix]; //format: PREFIX=FileNumber^Name
      Result := Piece(Entry, '^',1);
    end;
  end;


  function TFMField.GetNumberValue : Extended;
  //Returns -1 if invalid number;
  var FormatSettings : TFormatSettings;
  begin
    SysUtils.GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, FormatSettings);
    //Change settings here in case user local settings don't match server format...
    Result := SysUtils.StrToFloatDef(GetValue, -1, FormatSettings);
  end;

  procedure TFMField.SetNumberValue(Value : Extended);
  var FormatSettings : TFormatSettings;
      ValueStr : string;
  begin
    if IsComputed then exit;
    SysUtils.GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, FormatSettings);
    //Change settings here in case user local settings don't match server format...
    ValueStr := FloatToStr(Value, FormatSettings);
    SetValue(ValueStr);
  end;

  procedure TFMField.RefreshFromServer;
  //Discard local changes.
  begin
    //need to clear caches.
    FSymbolValue.Clear;
    FWP.Clear;
    FWPServerChecked := False;
    //FIX
    //NOTE: FDataLine could have +1 as IEN, so that must be handled.
    FOriginalDataLine := FDataLine;
    if Assigned(FSubfile) then begin
      FreeAndNil(FSubFile);
    end;
  end;


  function TFMField.GetSubfile : TFMFile;
  var Value, SubfileNum, Name : string;
  begin
    if (Assigned (FSubfile)= false) and (FType = fmftSubfile) then begin
      Value := piece(FDataLine,'^',6);
      SubFileNum := UtilU.ExtractNum(Value);
      Name := rRPCsU.ExpandFileNumber(SubFileNum);
      FSubfile := TFMFile.Create(SubfileNum, Name);
      FSubfile.FIsSubfile := true;
      FSubfile.FIENS := FParentRecord.FIENS;
    end;
    Result := FSubfile;
  end;


  procedure TFMField.SetSubfile(Value : TFMFile);
  begin
    MessageDlg('To be implemented', mtError, [mbOK], 0);
  end;

  function TFMField.PostWPData : boolean;
  begin
    Result := false; //default to not posted or error
    if FType <> fmftWP then exit;
    if rRPCsU.PostWPField(FWP, FFileNumber, FFldNumber, FParentRecord.FIENS) then begin
      FOriginalWP.Assign(FWP);
      Result := true;
    end;
  end;


//-------------------------------------
//-------------------------------------

  constructor TFMRecord.Create(ParentFMFile : TFMFile; AnIENS : string);
  begin
    inherited Create;
    IENS := AnIENS;
    FFileNumber := ParentFMFile.FileNumber;
    FParentFile := ParentFMFile;
    FData := TStringList.Create;
    FFieldsList :=TStringList.Create;
    RefreshFromServer;
    //more here if needed.

  end;

  destructor TFMRecord.Destroy;
  begin
    //more here if needed.
    FData.Free;
    Self.Clear;
    FFieldsList.Free;
    inherited Destroy;
  end;

  procedure TFMRecord.Clear;
  var AFld : TFMField;
      i : integer;
  begin
    for i := 0 to FFieldsList.Count - 1 do begin
      AFld := TFMField(FFieldsList.Objects[i]);
      AFld.Free;
    end;
    FFieldsList.Clear;
  end;

  function TFMRecord.DeleteRec : boolean;
  //Delete this record (with no confirmation!)
  //Returns TRUE if post is successful
  //NOTE: after calling this, Self is nil (invalid)
  begin
    Self.FMField['.01'].Value := '';
    Result := Self.PostChanges;
    Self.ParentFMFile.FreeRecord(Self);  //Fill free self.
    //NOTHING BELOW (Self is now invalid)
  end;



  procedure TFMRecord.RefreshFromServer;
  begin
    FData.Clear;
    Self.Clear;
    rRPCsU.GetOneRecord(FFileNumber, FIENS, FData, ParentFMFile.DDInfo);
  end;

  function TFMRecord.PostChanges : boolean;
  //Returns TRUE if posting was without error.
  var i : integer;
      AFld : TFMField;
      ChangesList : TStringList;
      AddIndex, NewIEN : string;
      OneLine : string;
  begin
    Result := true; //default to success
    if (Pos('+', FIENS)>0) then begin
      AddIndex := piece(FIENS,',',1);
      AddIndex := piece(AddIndex,'+',2);
    end else begin
      AddIndex := '';
    end;
    ChangesList := TStringList.Create;
    for i := 0 to FFieldsList.Count - 1 do begin
      AFld := TFMField(FFieldsList.Objects[i]);
      if not AFld.FieldChanged then continue;
      if AFld.FldType = fmftWP then continue;  //Will have to WP's handle differently.
      OneLine := FFileNumber+'^'+FIENS+'^'+AFld.Number+'^^'+AFld.Value;
      ChangesList.Add(OneLine);
    end;
    Result := rRPCsU.PostChanges(ChangesList);
    if Result = true then begin
      for i := 0 to FFieldsList.Count - 1 do begin
        AFld := TFMField(FFieldsList.Objects[i]);
        if not AFld.FieldChanged then continue;
        if AFld.FldType = fmftWP then continue;
        AFld.RefreshFromServer;
      end;
      If AddIndex <> '' then begin
        ChangesList.Clear;
        ChangesList.Assign(RPCBrokerV.Results);
        //ChangesList.Delete(0);
        i := UtilU.FindInSL(ChangesList,1,AddIndex);
        if i >=0 then begin
          NewIEN := Piece(ChangesList[i],'^',2);
        end else begin
          NewIEN := '';
        end;
        FParentFile.HandleScratchRecordPosted(NewIEN);
      end;
      //Now post WP changes...
      for i := 0 to FFieldsList.Count - 1 do begin
        AFld := TFMField(FFieldsList.Objects[i]);
        if AFld.FldType <> fmftWP then continue;
        if not AFld.FieldChanged then continue;
        if not AFld.PostWPData then begin
          Result := false;
          exit;
        end;
      end;
      //How to handle changes to subfiles/multiples??
    end;
    ChangesList.Free;
  end;

  procedure TFMRecord.SetIENS(Value : string);
  begin
    FIENS := Value;
    FIEN := Piece(Value,',',1);
  end;



  function TFMRecord.GetData : TStringList;
  begin
    if FData.Count = 0 then RefreshFromServer;
    Result := FData;
  end;

  function TFMRecord.GetFMFieldByNumber(Number : string) : TFMField;
  var i : integer;
      Name : string;
  begin
    i := UtilU.FindInSL(FFieldsList, 1, Number);
    if i >=0 then begin
      Result := TFMField(FFieldsList.Objects[i]);
    end else begin
      Result := TFMField.Create(Self, Number);
      Name := Result.Name;
      FFieldsList.AddObject(Number + '^' + Name, Result);
    end;
  end;

  procedure TFMRecord.SetFMFieldByNumber(Number : string; Value : TFMField);
  begin
    MessageDlg('To be implemented', mtError, [mbOK], 0);

  end;

  function TFMRecord.GetFMFieldByName(Name : string) : TFMField;
  var i : integer;
      Number : string;
  begin
    Result := nil;
    i := UtilU.FindInSL(FFieldsList, 2, Name);
    if i >=0 then begin
      Result := TFMField(FFieldsList.Objects[i]);
    end else begin
      i := UtilU.FindInSL(FData, 5, Name);
      if i = -1 then exit;
      Number := Piece(FData[i],'^',3);
      Result := TFMField.Create(Self, Number);
      FFieldsList.AddObject(Number + '^' + Name, Result);
    end;
  end;

  procedure TFMRecord.SetFMFieldByName(Name : string; Value : TFMField);
  begin
    MessageDlg('To be implemented', mtError, [mbOK], 0);
  end;

  function TFMRecord.GetFMField(NumberOrName : string) : TFMField;
  var s : string;
  begin
    s := Trim(NumberOrName);
    if UtilU.ExtractNum(s) = s then begin
      Result := GetFMFieldByNumber(s);
    end else begin
      Result := GetFMFieldByName(s);
    end;
  end;

  procedure TFMRecord.SetFMField(NumberOrName : string; Value : TFMField);
  begin
    MessageDlg('To be implemented', mtError, [mbOK], 0);
  end;


//-------------------------------------
//-------------------------------------

  constructor TFMFile.Create(FileNumber, FileName : string);
  begin
    inherited Create;
    FFileNumber := FileNumber;
    FFileName := FileName;
    FIsSubfile := false; //defaults to not a subfile.
    FDDInfo := TStringList.Create;
    FRecordsList := TStringList.Create;  //owns objects
    FScratchRecord := nil;

    //more if needed
  end;

  destructor TFMFile.Destroy;
  begin
    //more if needed
    if Assigned(FScratchRecord) then FreeAndNil(FScratchRecord);
    FDDInfo.Free;
    Self.Clear;
    FRecordsList.Free;
    FSrchResults.Free;
    inherited Destroy;
  end;

  procedure TFMFile.GetDDInfoFromServer;
  begin
    FDDInfo.Clear;
    rRPCsU.GetBlankFileInfo(FFileNumber, FDDInfo);
  end;

  function TFMFile.GetDDInfo : TStringList;
  begin
    if FDDInfo.Count = 0 then GetDDInfoFromServer;
    Result := FDDInfo;
  end;

  procedure TFMFile.Clear;
  var i : integer;
      ARec : TFMRecord;
  begin
    for i := 0 to FRecordsList.Count - 1 do begin
      ARec := TFMRecord(FRecordsList.Objects[i]);
      ARec.Free
    end;
    FRecordsList.Clear;
  end;

  procedure TFMFile.RefreshFromServer;
  begin
    Clear;
    GetDDInfoFromServer;
  end;

  function TFMFile.DeleteRecord(IENorIENS : string) : boolean;
  //Result: TRUE if was able to delete record
  var RecToDelete : TFMRecord;
  begin
    RecToDelete := GetFMRecord(IENorIENS);
    RecToDelete.FMField['.01'].Value := '@';
    Result := RecToDelete.PostChanges;
  end;


  function TFMFile.Search1Record(Value : string; Flags : string = '';
                                Indexes : string = ''; Screen : string = '') : TFMRecord;
  //Wrapper for $$FIND1^DIC
  //Returned object is OWNED here.  Can return NIL
  var FileStr, IENS : string;
      FoundIEN: string;
      IEN : longInt;
  begin
    Result := nil;
    FileStr := Self.FFileNumber;
    if Self.FIsSubfile then begin
      IENS := ',' + Self.FIENS;
    end else IENS := '';
    FoundIEN := rRPCSU.Find1Record(FileStr, Value, IENS, Flags, Indexes, Screen);
    IEN := StrToIntDef(FoundIEN, -1);
    if IEN <= 0 then exit;
    IENS := FoundIEN + ',' + Self.FIENS;
    Result := GetFMRecord(IENS);
    //Result := TFMRecord.Create(Self, IENS);
    //FRecordsList.AddObject(IENS, Result);
  end;


  function TFMFile.SearchRecords(Value: string; Flags: string = ''; Number: string = '*';
                                 Fields: string = '';Indexes: string = '';
                                 Screen: string = ''; Identifier : string = '') : TSrchResults;
  var IENS : string;
  begin
    FSrchResults.Free;  //discard any prior results.
    if Self.FIsSubfile then IENS := Self.FIENS else IENS := '';
    FSrchResults := FMFindU.FMFind(Self.FFileNumber, Value, IENS, Fields, Flags,
                                   Number, Indexes, Screen, Identifier);
    Result := FSrchResults;
  end;


  function TFMFile.GetFoundRecord(OneResult : TOneSrchResult) : TFMRecord;
  begin
    Result := nil;
    if assigned(OneResult) then Result := GetFMRecord(OneResult.IEN);
  end;


  function TFMFile.GetFMRecord(IENorIENS : string) : TFMRecord;
  var i : integer;
      IENS : string;
  begin
    if FIsSubfile then begin
      if Pos(',', IENorIENS)>0 then begin
        IENS := IENorIENS;
      end else begin
        IENS := IENorIENS + ',' + FIENS;
      end;
    end else begin
     { if (NumPieces(s, ',')=2) and (s[Length(s)]=',') then begin
        s := LeftStr(s, Length(s)-1);  //convert e.g. "139," --> "139"
      end;  }
      if Pos(',', IENorIENS) = 0 then begin
        IENS := IENorIENS + ',';
      end else begin
        IENS := IENorIENS;
      end;
    end;
    i := FRecordsList.IndexOf(IENS);
    if i >= 0 then begin
      Result := TFMRecord(FRecordsList.Objects[i]);
    end else begin
      Result := TFMRecord.Create(Self, IENS);
      FRecordsList.AddObject(IENS, Result);
      //...
    end;
  end;

  procedure TFMFile.FreeRecord(ARec : TFMRecord);
  var i : integer;
  begin
    i := FRecordsList.IndexOf(ARec.IENS);
    if i >= 0 then FRecordsList.Delete(i);
    ARec.Free;
  end;


  function TFMFile.GetScratchRecord : TFMRecord; //User will own this.
    //Result of GetScratchRecord is owned here.  Used to create new record.
    //There is only ONE of these.  Not multiple.
    //To post changes to server, call .Post to returned TFMFileRecord pointer
    //After .Post, the record will be added to the list of records, and this
    //  pointer will become invalid.

  var IENS : string;
  begin
    if not Assigned(FScratchRecord) then begin
      if FIsSubfile then begin
        IENS := '+1,' + FIENS;
      end else begin
        IENS := '+1,';
      end;
      FScratchRecord := TFMRecord.Create(Self, IENS);
    end;
    Result := FScratchRecord;
  end;

  procedure TFMFile.HandleScratchRecordPosted(DestIEN : string);
  var IENS : string;
  begin
    if DestIEN='' then DestIEN :='??'; //Give it new value, so it won't get lost.
    IENS := DestIEN + ',' + FIENS;
    FScratchRecord.IENS := IENS;
    FScratchRecord.RefreshFromServer;
    FRecordsList.AddObject(IENS, FScratchRecord);
    FScratchRecord := nil;
  end;

  procedure TFMFile.GetRecordsList(RecordsListToFill : TStringList);
  //Output format:
  //    RecordNumber=.01Value     e.g. 27=APPLE
  //    RecordNumber=.01Value          32=GRAPE
  //    RecordNumber=.01Value          45=PEAR
  var tempSL : TStringList;
      i : integer;
      s, IEN, Value : string;
      tempMap : string;
  begin
    if not assigned(RecordsListToFill) then exit;
    RecordsListToFill.Clear;
    tempSL := TStringList.Create;
    if FIsSubfile then begin
      GetAllSubRecordsRPC(FFileNumber,FIENS,tempSL, tempMap);
      for i := 0 to tempSL.Count - 1 do begin
        s := tempSL.Strings[i];
        IEN := piece(piece(s,'^',1),',',1);
        Value := piece(s,'^',2);
        RecordsListToFill.Add(IEN + '=' + Value);
      end;
    end else begin
      rRPCsU.GetRecordsList(tempSL, FFileNumber);
      for i := 0 to tempSL.Count - 1 do begin
        s := tempSL.Strings[i];
        Value := piece(s,'^',1);
        IEN := piece(s,'^',2);
        RecordsListToFill.Add(IEN + '=' + Value);
      end;
    end;
    tempSL.Free;
  end;

  procedure TFMFile.GetRecordsListRaw(RecordsListToFill : TStringList; OUT Map : string; Fields : string = '');
  //Input: Fields -- this is a fields string to pass to FIND^DIC
  //Output: RecordsListToFill is cleared and then filled with found records.
  //        Map is the mapping of the positions of the output
  //NOTE: Specifying fields is currently supported only on SUBFILES  (just haven't gotten around
  //      to changing formats for normal files)
  //Example Output format:
  // MAP = 'IEN^IX(1)^.01^2I^WID(WRITE)'
  //RecordsListToFill[0] = '18^60^60^1263^          TMG-IM TDAP DONE'
  //RecordsListToFill[1] = '19^70^70^1267^          TMG-IM IMMUNIZATIONS'


  var tempSL : TStringList;
      i : integer;
      s, IEN, Value : string;
  begin
    if not assigned(RecordsListToFill) then exit;
    RecordsListToFill.Clear;
    tempSL := TStringList.Create;
    if FIsSubfile then begin
      rRPCsU.GetAllSubRecordsRPC(FFileNumber,FIENS, RecordsListToFill, Map, Fields);
    end else begin
      rRPCsU.GetRecordsList(tempSL, FFileNumber);
      for i := 0 to tempSL.Count - 1 do begin
        s := tempSL.Strings[i];
        Value := piece(s,'^',1);
        IEN := piece(s,'^',2);
        RecordsListToFill.Add(IEN + '=' + Value);
      end;
    end;
    tempSL.Free;
  end;

//-------------------------------------
//-------------------------------------

  constructor TFileman.Create;
  begin
    Inherited Create;
    FMFilesPtrs := TStringList.Create;
    //more here if needed...
  end;

  destructor TFileman.Destroy;
  begin
    //more here if needed
    Self.Clear;
    FMFilesPtrs.Free;
    Inherited Destroy;
  end;

  procedure TFileman.Clear;
  var i : integer;
      FMFile : TFMFile;
  begin
    for i := 0 to FMFilesPtrs.Count - 1 do begin
      FMFile := TFMFile(FMFilesPtrs[i]);
      FMFile.Free;
    end;
    FMFilesPtrs.Clear;
  end;


  function TFileman.GetFMFile(NumberOrName: string) : TFMFile;
  var FMFile : TFMFile;
      AName, ANumber : string;
      Idx : integer;
  begin
    Result := nil;
    AName := rRPCsU.ExpandFileNumber(NumberOrName);  //NumberOrName will be changed to number, if input was name
    if AName = '??' then begin
      ANumber := '0';
      //Note: If invalid file sought, then a null (but not nil) record will be created
    end else begin
      ANumber := NumberOrName;
    end;
    Idx := FMFilesPtrs.IndexOf(ANumber);
    if Idx >= 0 then begin
      FMFile := TFMFile(FMFilesPtrs.Objects[Idx]);
    end else begin
      FMFile := TFMFile.Create(ANumber, AName);
      FMFilesPtrs.AddObject(ANumber,FMFile);
    end;
    Result := FMFile;
  end;


  function TFileman.GetFMSubFile(NumberOrName: string; IENS : string) : TFMFile;
  var FMFile : TFMFile;
      AName, ANumber, SLLookup : string;
      Idx : integer;
  begin
    Result := nil;
    AName := rRPCsU.ExpandFileNumber(NumberOrName);
    if AName = '??' then exit;
    ANumber := NumberOrName; //Converted to number by ExpandFileNumber
    SLLookup := ANumber + '^' + IENS;
    Idx := FMFilesPtrs.IndexOf(SLLookup);
    if Idx >= 0 then begin
      FMFile := TFMFile(FMFilesPtrs.Objects[Idx]);
    end else begin
      FMFile := TFMFile.Create(ANumber, AName);
      FMFile.FIsSubfile := true;
      FMFile.FIENS := IENS;
      FMFilesPtrs.AddObject(SLLookup,FMFile);
    end;
    Result := FMFile;
  end;


//-------------------------------------
//-------------------------------------



end.

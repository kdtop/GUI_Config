unit TestRemResultsU;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  TypesU, StrUtils, TMGStrUtils,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, ORCtrls, rCore;

type
  TRemTestResult = class(TObject)
  private
    FItemType: TFindingType;
    FFile : string;
    FParentIEN : string;
    FIEN : string;
  public
    ItemResult : boolean;
    Term : string;
    TermIEN : string;
    Details : TStringList;
    constructor Create(ParentIEN : string);
    Destructor Destroy;
    procedure Clear;
    procedure Load(SL : TStrings; Mode : TFindingType; Index : string);
  end;

  TRemTestResultMgr = class(TObject)
  private
    FList : TList;  //Will hold TRemTestResult objects
    FIEN : string;
    SourceData : TStringList;
  public
    Log : TStringList;
    DisplayResult : TStringList;
    constructor Create(ReminderIEN : string);
    Destructor Destroy;
    procedure Clear;
    procedure Load(SL : TStrings);
    function HasResults : boolean;
  end;


implementation

  constructor TRemTestResult.Create(ParentIEN : string);
  begin
    Inherited Create;
    Details := TStringList.Create;
    FFile := '';
    FParentIEN := ParentIEN;
  end;

  Destructor TRemTestResult.Destroy;
  begin
    Details.Free;
    //
    Inherited Destroy;
  end;

  procedure TRemTestResult.Load(SL : TStrings; Mode : TFindingType; Index : string);
  //Returns last line index in SL that is part of same number in result.
  var
    s, MatchTerm, MatchTerm2 : string;
    i : integer;
    Number: string;
    NumericIndex : boolean;
  const
    TERM_TXT = '"TERM")=';
    FIEVAL ='FIEVAL(';
    TFIEVAL ='TFIEVAL(';
    TERM_IEN_TXT = '"TERM IEN")=';
    NONE = '!<NONE>!';
  begin
    Self.Clear;
    FItemType:= Mode;
    NumericIndex := (ExtractNumValue(Index) = Index);
    MatchTerm := FIEVAL+Index;
    MatchTerm2 := NONE;
    //Setup File depending on Mode);
    //Scan SL for prefix and number, and load info based on that.
    case Mode of
      ftNone:      Begin
                     FFile := '';
                     MatchTerm := NONE;
                   end;
      ftFinding:   Begin
                     FFile := '811.902';
                     MatchTerm2 := TFIEVAL+Index+',';
                     FIEN := Index;
                   end;
      ftFnFinding: Begin
                     FFile := '811.925';
                     FIEN := Piece(Index,'FF',2);
                     FIEN := piece(FIEN,'"',1);
                   end;
      ftAge:       Begin
                     FFile := '';
                   end;
      ftSex:       Begin
                     FFile := '';
                   end;
    end; {case}
    for i := 0 to SL.Count - 1 do begin
      s := Trim(SL.Strings[i]);
      if Pos(MatchTerm, s)=1 then begin
        if NumericIndex then begin
          Number := ExtractNumValue(piece(s, FIEVAL,2));
          if Number <> Index then continue;
        end;
        s := MidStr(s, Length(MatchTerm)+1,Length(s));
        if Length(s)=0 then continue;
        if s[1] in [')', ','] then s := MidStr(s, 2,Length(s));
        if Length(s)=0 then continue;
        if s[1]='=' then begin
          ItemResult := (s='=1');
        end else if Pos(TERM_TXT, s)>0 then begin
          Term := Piece(s, TERM_TXT, 2);
        end else if Pos(TERM_IEN_TXT, s)>0 then begin
          TermIEN := Piece(s, TERM_IEN_TXT, 2);
        end else begin
          Details.Add(s);
        end;
      end else if Pos(MatchTerm2, s)=1 then begin
        s := Piece(s, MatchTerm2, 2);
        Details.Add('Finding: ' + s);
      end;
    end;
  end;

  procedure TRemTestResult.Clear;
  begin
    FItemType := ftNone;
    FFile :='';
    FParentIEN :='';
    FIEN :='';
    ItemResult := false;
    Term :='';
    TermIEN :='';
    Details.Clear;
  end;

//===============================================
//===============================================
//===============================================
//===============================================

  constructor TRemTestResultMgr.Create(ReminderIEN : string);
  begin
    Inherited Create;
    FIEN := ReminderIEN;
    FList := TList.Create;
    SourceData := TStringList.Create;
    Log := TStringList.Create;
    DisplayResult := TStringList.Create;
  end;

  Destructor TRemTestResultMgr.Destroy;
  begin
    Clear;
    FList.Free;
    SourceData.Free;
    Log.Free;
    DisplayResult.Free;
    //
    Inherited Destroy;
  end;

  function TRemTestResultMgr.HasResults : boolean;
  begin
    Result := (FList.Count > 0);
  end;

  procedure TRemTestResultMgr.Clear;
  var AResult : TRemTestResult;
      i : integer;
  begin
    for i := 0 to FList.Count - 1 do begin
      AResult := TRemTestResult(FList[i]);
      AResult.Free;
    end;
    FList.Clear;
    SourceData.Clear;
    Log.Clear;
  end;

  procedure TRemTestResultMgr.Load(SL : TStrings);
  var DoneSL : TStringList;
      s, Number : string;
      Mode : TFindingType;
      i : integer;
      AResult : TRemTestResult;
      FoundDisplay : boolean;

  const  FIEVAL = 'FIEVAL(';
         COMMA = ',';
         LOG_TAG = '^TMP(PXRMID,$J,';
         DISPLAY_TAG = 'Formatted Output:';
  begin
    Clear;
    SourceData.Assign(SL);
    DoneSL := TStringList.Create;
    for i := 0 to SL.Count - 1 do begin
      s := SL[i];
      if Pos(FIEVAL,s)=0 then continue;
      if Pos(COMMA, s)>0 then continue;  //Ignore FIEVAL(1,...) but not FIEVAL(1)
      s := Piece(s,FIEVAL,2);
      Number := piece(s,')',1);
      if Number = '' then continue;
      if DoneSL.IndexOf(Number) <> -1 then continue;
      if Number = '"AGE"' then Mode := ftAge
      else if Number = '"SEX"' then Mode := ftSex
      else if Pos('FF', Number)>0 then Mode := ftFnFinding
      else if ExtractNumValue(Number) = Number then Mode := ftFinding
      else Mode := ftNone;
      AResult := TRemTestResult.Create(FIEN);
      AResult.Load(SL, Mode, Number);
      DoneSL.Add(Number);
    end;
    DoneSL.Free;
    for i := 0 to SL.Count - 1 do begin
      s := SL[i];
      if Pos(LOG_TAG+FIEN,s)<1 then continue;
      s := Piece(s, LOG_TAG+FIEN+',', 2);
      Log.Add(s);
    end;
    FoundDisplay := false;
    for i := 0 to SL.Count - 1 do begin
      s := SL[i];
      if Pos(DISPLAY_TAG, s)>0 then begin
        FoundDisplay := true;
        continue;
      end;
      if not FoundDisplay then continue;
      DisplayResult.Add(s);
    end;
  end;


end.

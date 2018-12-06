unit FMFindU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Controls,
  Dialogs, StrUtils, ORNet, ORFn,
  TypesU, GlobalsU, rRPCsU, ValEdit, UtilU;

type
  TPseudoGlobal = class(TObject)
  private
    FRawFMData : TStringList;
  public
    LastIndex : integer;
    function Value(N1:string='';
                   N2:string='';
                   N3:string='';
                   N4:string='';
                   N5:string='';
                   N6:string='';
                   N7:string='';
                   N8:string='') : string;
    function Order(N1:string='';
                   N2:string='';
                   N3:string='';
                   N4:string='';
                   N5:string='';
                   N6:string='';
                   N7:string='';
                   N8:string='') : string;
    constructor Create(Source : TStrings);
    destructor Destroy;
    procedure Assign(Source : TStrings);
    procedure Clear;
  end;

  TOneSrchResult = class(TObject)
  private
  public
    IEN : string;
    Name : string;  //store .01 value
    FieldValues : TStringList;  //Format: .Strings[x]="Field=Value"
    constructor Create;
    destructor Destroy;
  end;

  TSrchResults = class(TObject)
  private
    FResultList : TList;  //will hold and own TOneSrchResult objects
    FMData : TPseudoGlobal;
    FFileNum : string;
    FNumResults : string;
    FNumRequested : string;
    FMoreAvailNum : string;
    FSearchValue : string;
    procedure ParseFMData;
    function GetOneSrchResult(Index : integer) : TOneSrchResult;
    procedure ClearResultsList;
  public
    function Count : integer;
    procedure Clear;
    property FileNum : string read FFileNum;
    property NumResults : string read FNumResults;
    property NumRequested : string read FNumRequested;
    property MoreAvailNum : string read FMoreAvailNum;
    property SearchValue : string read FSearchValue;
    //Result[] -- Owned here. i.e. This object owns returned result
    //        NOTE: can return a nil result, if Index is invalid
    property Result[Index : integer] : TOneSrchResult read GetOneSrchResult;
    constructor Create(SourceFMData : TStrings);
    destructor Destroy;
  end;

//NOTE: Caller of FMFile will own returned object, and is responsible for FREE'ing it.
//      Results can be nil if there was a Fileman error.
function FMFind(FileNum    : string;         Value      : string;
                IENS       : string = '';    Fields     : string = '';
                Flags      : string = '';    Number     : string = '*';
                Indexes    : string = '';    Screen     : string = '';
                Identifier : string = ''   ) : TSrchResults;

implementation

//----------------------------------------
//----------------------------------------

function TPseudoGlobal.Value(N1:string='';
                             N2:string='';
                             N3:string='';
                             N4:string='';
                             N5:string='';
                             N6:string='';
                             N7:string='';
                             N8:string='') : string;
var
  Term, s : string;
  i : integer;
begin
  Result := '';
  Term := 'SRCH';
  if N1<>'' then begin
    Term := Term + '(' + N1;
    if N2<>'' then begin
      Term := Term + ',' + N2;
      if N3<>'' then begin
        Term := Term + ',' + N3;
        if N4<>'' then begin
          Term := Term + ',' + N4;
          if N5<>'' then begin
            Term := Term + ',' + N5;
            if N6<>'' then begin
              Term := Term + ',' + N6;
              if N7<>'' then begin
                Term := Term + ',' + N7;
                if N8<>'' then begin
                  Term := Term + ',' + N8;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
    Term := Term + ')';
  end;
  Term := Term + '=';
  for i := 0 to FRawFMData.Count - 1 do begin
    if Pos(Term, FRawFMData.Strings[i])<1 then continue;
    s := FRawFMData.Strings[i];
    Result := MidStr(s, Length(Term)+1, Length(s));
    break;
  end;
end;

function TPseudoGlobal.Order(N1:string='';
                             N2:string='';
                             N3:string='';
                             N4:string='';
                             N5:string='';
                             N6:string='';
                             N7:string='';
                             N8:string='') : string;
var
  PriorTerm, Term, s : string;
  i : integer;
  foundAIndex : integer;
begin
  Result := '';
  Term := 'SRCH';
  if N1<>'' then begin
    PriorTerm := 'SRCH(';
    Term := Term + '(' + N1;
    if N2<>'' then begin
      PriorTerm := Term + ',';
      Term := Term + ',' + N2;
      if N3<>'' then begin
        PriorTerm := Term + ',';
        Term := Term + ',' + N3;
        if N4<>'' then begin
          PriorTerm := Term + ',';
          Term := Term + ',' + N4;
          if N5<>'' then begin
            PriorTerm := Term + ',';
            Term := Term + ',' + N5;
            if N6<>'' then begin
              PriorTerm := Term + ',';
              Term := Term + ',' + N6;
              if N7<>'' then begin
                PriorTerm := Term + ',';
                Term := Term + ',' + N7;
                if N8<>'' then begin
                  PriorTerm := Term + ',';
                  Term := Term + ',' + N8;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  foundAIndex := -1;
  for i := LastIndex to FRawFMData.Count - 1 do begin
    if Pos(Term, FRawFMData.Strings[i])<1 then begin   //e.g. TERM='SRCH(2,8'
      if foundAIndex=-1 then continue;
      s := FRawFMData.Strings[i];                      //e.g. 'SRCH(2,9,1,2,3)= ...'
      s := MidStr(s, Length(PriorTerm)+1, Length(s));  //e.g. PRIORTERM='SRCH(2,'
      s := piece(s,')',1);
      if Pos(',',s)>0 then s := piece(s,',',1);
      Result := s;
      break;
    end;
    foundAIndex := i;
  end;
end;


constructor TPseudoGlobal.Create(Source : TStrings);
begin
  Inherited Create;
  FRawFMData := TStringList.Create;
  if assigned(Source) then FRawFMData.Assign(Source);

end;

destructor TPseudoGlobal.Destroy;
begin
  FRawFMData.Free;

  Inherited Destroy;
end;

procedure TPseudoGlobal.Assign(Source : TStrings);
begin
  FRawFMData.Assign(Source);
end;

procedure TPseudoGlobal.Clear;
begin
  FRawFMData.Clear;
end;


//----------------------------------------
//----------------------------------------

constructor TOneSrchResult.Create;
begin
  Inherited Create;
  FieldValues := TStringList.Create;

  //
end;

destructor TOneSrchResult.Destroy;
begin
  FieldValues.Free;
  //
  Inherited Destroy;
end;

//----------------------------------------
//----------------------------------------

constructor TSrchResults.Create(SourceFMData : TStrings);
begin
  Inherited Create;
  FResultList := TList.Create;
  Clear; //init variables
  FMData := TPseudoGlobal.Create(SourceFMData);
  ParseFMData;
end;

destructor TSrchResults.Destroy;
begin
  Clear;
  FResultList.Free;
  FMData.Free;
  //
  Inherited Destroy;
end;


procedure TSrchResults.ClearResultsList;
var i : integer;
begin
  //clear FResultsList
  for i := 0 to FResultList.Count - 1 do begin
    TOneSrchResult(FResultList[i]).Free;
  end;
  FResultList.Clear;
end;

procedure TSrchResults.Clear;
begin
  ClearResultsList;
  FMData.Clear;
  FFileNum := '';
  FNumResults := '';
  FNumRequested := '';
  FMoreAvailNum := '';
  FSearchValue := '';

end;

function TSrchResults.Count : integer;
begin
  Result := FResultList.Count;
end;

function TSrchResults.GetOneSrchResult(Index : integer) : TOneSrchResult;
begin
  if (Index >=0) and (Index < FResultList.Count) then begin
    Result := TOneSrchResult(FResultList[Index]);
  end else begin
    Result := nil;
  end;
end;

procedure TSrchResults.ParseFMData;
//Note: for now, NON-PACKED format is assumed.
//Doesn't support requesting "I" and "E" flags (both together)
//IX field specifer not supported
var Map, Header : string;
    NumResults : integer;
    {SeqNum,} Node, Field : string;
    NodeNum : integer;
    Value : string;
    OneResult : TOneSrchResult;
begin
  ClearResultsList;
  Header := FMData.Value('0');
  FNumResults := piece(Header, '^',1);
  FNumRequested := piece(Header, '^',2);
  FMoreAvailNum  := piece(Header, '^',3);
  NumResults := StrToIntDef(FNumResults, 0);
  if NumResults=0 then exit;
  FResultList.Capacity := NumResults+1;
  Map := FMData.Value('0','"MAP"');
  OneResult := TOneSrchResult.Create;
  FResultList[0]:= OneResult;  //this will be index 0, and won't be used, because FM results start numbering at 1
  FMData.LastIndex := 0;
  Node := '0';
  repeat  //Process '1' node, which is .01 values
    Node := FMData.Order('1',Node);
    if Node='' then break;
    NodeNum := StrToIntDef(Node,0);
    if NodeNum=0 then break;
    Value := FMData.Value('1',Node);
    OneResult := TOneSrchResult.Create;
    OneResult.Name := Value;
    FResultList[NodeNum] := OneResult;
  until (Node = '');

  Node := '0';
  repeat  //Process '2' node, which is IEN values
    Node := FMData.Order('2',Node);
    if Node='' then break;
    NodeNum := StrToIntDef(Node,0);
    if NodeNum=0 then break;
    Value := FMData.Value('2',Node);  //Value = IEN
    OneResult := TOneSrchResult(FResultList[NodeNum]);
    OneResult.IEN := Value;
  until (Node = '');

  Node := '0';
  repeat  //Process 'ID' node, which are all the other fields requested.
    Node := FMData.Order('"ID"',Node);
    if Node='' then break;
    NodeNum := StrToIntDef(Node,0);
    if NodeNum=0 then break;
    OneResult := TOneSrchResult(FResultList[NodeNum]);
    Field := '0';
    repeat
      Field := FMData.Order('"ID"',Node,Field);
      if Field='' then continue;
      Value := FMData.Value('"ID"',Node,Field);  //Value = field value
      OneResult.FieldValues.Add(Field+'='+Value);
    until (Field='');
  until (Node = '');
end;




//----------------------------------------
//----------------------------------------

function FMFind(FileNum    : string;         Value      : string;
                IENS       : string = '';    Fields     : string = '';
                Flags      : string = '';    Number     : string = '*';
                Indexes    : string = '';    Screen     : string = '';
                Identifier : string = ''   ) : TSrchResults;
var
  SrchResults : TStringList;
  Success : boolean;
begin
  SrchResults := TStringList.Create;
  Success := rRPCsU.FindRecord(SrchResults, FileNum, Value, IENS, Fields,
                               Flags, Number, Indexes, Screen, Identifier);
  if Success then begin
    Result := TSrchResults.Create(SrchResults);  //will be owned by caller, who MUST free it when done.
    Result.FFileNum := FileNum;
    Result.FNumRequested := Number;
    Result.FSearchValue := Value;

  end else begin
    Result := nil;
  end;
  SrchResults.Free;
end;


end.

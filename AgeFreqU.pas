unit AgeFreqU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ComCtrls, Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TARCompare = (tarcLessThanB, tarcGreaterThanB, tarcOverlapsB);
  TAgeRange = class(TObject)
    private
      FFreq : single;   //frequency in years
      FFreqStr : string; // e.g. 11M, 200D, 5Y
      function GetFormatedFreq : string;
      function GetFreq : string;
      procedure SetFreq(Value : string);
    public
      MinAge : integer;  //Minimum age, in years  -1 for none specified
      MaxAge : integer;  //Max age, in years.  -1 for none specified
      FindingName : string;  //optional
      function MinAgeDefined : boolean;
      function MaxAgeDefined : boolean;
      function CompareTo(B : TAgeRange) : TARCompare;
      property Frequency : string read GetFreq write SetFreq;
      property FormatedFreq : string read GetFormatedFreq;
  end;

  TRangeList = class(TStringList)
    private
      FHasRangeOverlaps : boolean;
      function GetOneAgeRange(Index : integer) : TAgeRange;
      procedure SortRanges;
    public
      procedure AddRange(EntryStr : string);
      procedure ClearRanges;
      destructor Destroy;
      function MinAgeDefined : boolean;
      function MaxAgeDefined : boolean;
      function MinAge : Integer;
      function MaxAge : Integer;
      Property ARange[Index : Integer] : TAgeRange read GetOneAgeRange;
      Property HasRangeOverlaps : boolean read FHasRangeOverlaps;
  end;


  TfrmAgeFreq = class(TForm)
    pnlBottom: TPanel;
    DoneBtn: TBitBtn;
    pbCanvas: TPaintBox;
    procedure pbCanvasPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    ListOfRanges : TList;  //owns contained TRangeList objects
  public
    { Public declarations }
    procedure Render;
    procedure Initialize(Entries : TStringList);
    procedure InitializeExtra(IENS : String);
  end;

//var
//  frmAgeFreq: TfrmAgeFreq;

implementation

{$R *.dfm}

uses ORFn, StrUtils, FMU;

//---------------------------------------------------------------
//---------------------------------------------------------------
function TAgeRange.GetFreq : string;
var Digits : integer;
begin
  if Pos('D', FFreqStr)>0 then Digits :=3
  else if Pos('M', FFreqStr)>0 then Digits :=2
  else Digits := 0;
  Result := FloatToStrF(FFreq, ffNumber, 7, Digits);
end;

function TAgeRange.GetFormatedFreq : string;
var i, Len : integer;
    tempS : string;
    NumStr, DateStr : string;
begin
  //First split number and letters, e.g. '1Y' --> '1 Y'
  NumStr := '';
  i := 1;
  Len := Length(FFreqStr);
  repeat
    if FFreqStr[i] in ['0'..'9'] then begin
      NumStr := NumStr + FFreqStr[i];
    end else begin
      break;
    end;
    inc(i);
  until (i > Len);
  DateStr := '';
  while (i <= Len) do begin
    DateStr := DateStr + FFreqStr[i];
    inc(i);
  end;
  Result := NumStr;
  DateStr := UpperCase(DateStr);
  if DateStr = 'Y' then begin
    Result := Result + ' year';
  end else if DateStr = 'M' then begin
    Result := Result + ' month';
  end else if DateStr = 'D' then begin
    Result := Result + '  day';
  end;
  if NumStr <> '1' then Result := Result + 's';
end;


procedure TAgeRange.SetFreq(Value : string);
var Val, Qual : String;
    Num : single;
    Divisor : integer;
begin
  Value := UpperCase(Value);
  FFreqStr := Value;
  Qual := RightStr(Value,1);
  if Qual = 'D' then Divisor := 365
  else if Qual = 'M' then Divisor := 12
  else Divisor := 1;  //Y
  Val := piece(Value, Qual[1], 1);
  if Val='' then begin
    FFreq := -1;
  end else begin
    Num := StrToFloat(Val);
    FFreq := Num / Divisor;
  end;
end;

function TAgeRange.CompareTo(B : TAgeRange) : TARCompare;
begin
  Result := tarcOverlapsB;
  if (MinAge < B.MinAge)
    and (MaxAge <= B.MinAge) then begin
    Result := tarcLessThanB;
  end else if (B.MinAge < MinAge)
    and (B.MaxAge <= MinAge) then begin
    Result := tarcGreaterThanB;
 end;
end;

function TAgeRange.MinAgeDefined : boolean;
begin
  Result := (Self.MinAge <> -1);
end;

function TAgeRange.MaxAgeDefined : boolean;
begin
  Result := (Self.MaxAge <> -1);
end;



//---------------------------------------------------------------
//---------------------------------------------------------------

procedure TRangeList.SortRanges;
 // Bubble sort
var i : integer;
    A, B : TAgeRange;
    StrA, StrB : string;
    Reordered: boolean;
begin
  //first give every entry a starting order
  for i := 0 to Self.Count - 1 do begin
    Self.Strings[i] := IntToStr(i);
  end;
  //Now try to change names to be ordered
  FHasRangeOverlaps := false;
  Self.Sort;
  repeat
    Reordered := false;
    for i := 0 to Self.Count - 2 do begin
      A := Self.ARange[i];
      B := Self.ARange[i+1];
      case A.CompareTo(B) of
        tarcLessThanB : begin
          continue;
        end;
        tarcGreaterThanB : begin
          StrB := Self.Strings[i+1];
          StrA := Self.Strings[i];
          Self.Strings[i] := StrB;
          Self.Strings[i+1] := StrA;
          Reordered := true;
        end;
        tarcOverlapsB : begin
          FHasRangeOverlaps := true;
        end;
      end; {case}
      Self.Sort;
    end;
  until (Reordered = false);
end;

function TRangeList.MinAgeDefined : boolean;
var i : integer;
begin
  Result := true;
  for i := 0 to Self.Count - 1 do begin
    if Self.ARange[i].MinAge = -1 then begin
      Result := false;
      break;
    end;
  end;
end;

function TRangeList.MaxAgeDefined : boolean;
var i : integer;
begin
  Result := true;
  for i := 0 to Self.Count - 1 do begin
    if Self.ARange[i].MaxAge = -1 then begin
      Result := false;
      break;
    end;
  end;
end;

function TRangeList.MinAge : Integer;
var Age, i : integer;
begin
  Result := -1;
  for i := 0 to Self.Count - 1 do begin
    Age := Self.ARange[i].MinAge;
    if (Age <> -1) and (Age < Result) then begin
      Result := Age;
    end;
  end;
end;

function TRangeList.MaxAge : Integer;
var Age, i : integer;
begin
  Result := -1;
  for i := 0 to Self.Count - 1 do begin
    Age := Self.ARange[i].MaxAge;
    if (Age <> -1) and (Age > Result) then begin
      Result := Age;
    end;
  end;
end;


procedure TRangeList.AddRange(EntryStr : string);
var Freq,Min,Max : string;
    DispGroup : string;
    FindingName : string;
    OneRange: TAgeRange;

    function CheckConvertUnits(Input : string) : integer;
    var Conversion : single;
        i : integer;
    const UNIT_NAME : array[1..3] of char = ('Y', 'M',  'D');
    const UNIT_CONV : array[1..3] of single = (1, 1/12, 1/365);
    begin
      Result := -1;
      Input := UpperCase(Input);
      Conversion := 1;
      for i := 1 to 3 do begin
        if Pos(UNIT_NAME[i], Input) > 0 then begin
          Input := Piece(Input, UNIT_NAME[i], 1);
          Conversion := UNIT_CONV[i];
          break;
        end;
      end;
      Result := StrToIntDef(Input, -1);
      Result := Round(Result * Conversion);
    end;

begin
  Freq := Piece(EntryStr, '^',1);
  Min :=  Piece(EntryStr, '^', 2);
  Max :=  Piece(EntryStr, '^', 3);
  FindingName := Piece(EntryStr, '^', 4); //optional
  OneRange := TAgeRange.Create;
  OneRange.MinAge := CheckConvertUnits(Min);
  OneRange.MaxAge := CheckConvertUnits(Max);
  OneRange.Frequency := Freq;
  OneRange.FindingName := FindingName;
  Self.AddObject('', OneRange);
end;

function TRangeList.GetOneAgeRange(Index : integer) : TAgeRange;
begin
  Result := nil;
  if (Index < 0) or (Index >= Self.Count) then exit;
  Result := TAgeRange(Self.Objects[Index]);
end;

procedure TRangeList.ClearRanges;
var i : integer;
begin
  for i := 0 to Self.Count - 1 do begin
    TAgeRange(Self.Objects[i]).Free;
  end;
  Self.Clear;
end;

destructor TRangeList.Destroy;
begin
  ClearRanges;
  Inherited Destroy;
end;

//---------------------------------------------------------------
//---------------------------------------------------------------

procedure TfrmAgeFreq.FormCreate(Sender: TObject);
begin
  ListOfRanges := TList.Create;
end;

procedure TfrmAgeFreq.FormDestroy(Sender: TObject);
var i : integer;
begin
  for i := 0 to ListOfRanges.Count - 1 do begin
    TRangeList(ListOfRanges[i]).Free;
  end;
  ListOfRanges.Free;
end;

procedure TfrmAgeFreq.FormResize(Sender: TObject);
begin
  Render;
end;

procedure TfrmAgeFreq.FormShow(Sender: TObject);
begin
  Render;
end;

procedure TfrmAgeFreq.Initialize(Entries : TStringList);
//Expected input:  Entries.Strings[x]='<Frequency>^<MinAge>^<MaxAge>'
//Frequency is as found in .01 field of file 811.97 (in 811.9)
//  E.g. 7Y, or 400D, or 11M
var i : integer;
    RangesList : TRangeList;
begin
  RangesList := TRangeList.Create;
  for i := 0 to Entries.Count - 1 do begin
    RangesList.AddRange(Entries.Strings[i]);
  end;
  RangesList.SortRanges;
  ListOfRanges.Add(RangesList);
  Render;
end;

procedure TfrmAgeFreq.InitializeExtra(IENS : String);
//Input: IENS is expected to be IENS from file 811.97
var ParentIEN : string;
    FFileMan : TFileman;  //owned here
    FFMFile : TFMFile;    //owned by FFileMan
    FFindingsSubfile: TFMFile;      //owned by FFileMan
    FFuncFindingsSubfile : TFMFile; //owned by FFileMan
    FFMRecord : TFMRecord; //owned by FFileMan
    FFMFindingRecord : TFMRecord; //owned by FFileMan
    FFMFuncFindingRecord : TFMRecord; //owned by FFileMan
    FFindings : TStringList;
    FFuncFindings : TStringList;
    i : integer;
    EntryStr, MinAge,MaxAge, Freq, FindingName : string;
    SubIEN : string;
    RangeList : TRangeList;

begin
  FFileMan := TFileman.Create;
  FFindings := TStringList.Create;
  FFuncFindings := TStringList.Create;

  FFMFile := FFileMan.FMFile['811.9'];
  ParentIEN := piece(IENS, ',', 2);  //get IEN in file 811.9
  FFMRecord := FFMFile.FMRecord[ParentIEN];

  FFindingsSubfile := FFMRecord.FMField['20'].Subfile;
  FFuncFindingsSubfile := FFMRecord.FMField['25'].Subfile;
  FFindingsSubfile.GetRecordsList(FFindings);         //Output format:  RecordNumber=.01Value  e.g. 27=APPLE
  FFuncFindingsSubfile.GetRecordsList(FFuncFindings); //Output format:  RecordNumber=.01Value  e.g. 27=APPLE

  for i := 0 to FFindings.Count - 1 do begin
    SubIEN := piece(FFindings.Strings[i],'=',1);
    FFMFindingRecord := FFindingsSubfile.FMRecord[SubIEN];
    if FFMFindingRecord.FMField['3'].Value = '' then continue;
    RangeList := TRangeList.Create;
    MinAge := FFMFindingRecord.FMField['1'].Value;  //if MinAge = '' then MinAge := '0';
    MaxAge := FFMFindingRecord.FMField['2'].Value;  //if MaxAge = '' then MaxAge := '120';
    Freq   := FFMFindingRecord.FMField['3'].Value;
    FindingName := FFMFindingRecord.FMField['.01'].Value;
    EntryStr := Freq + '^' + MinAge + '^' + MaxAge + '^' + FindingName;
    RangeList.AddRange(EntryStr);
    ListOfRanges.Add(RangeList);
  end;

  for i := 0 to FFuncFindings.Count - 1 do begin
    SubIEN := piece(FFuncFindings.Strings[i],'=',1);
    FFMFuncFindingRecord := FFuncFindingsSubfile.FMRecord[SubIEN];
    if FFMFuncFindingRecord.FMField['15'].Value = '' then continue;
    RangeList := TRangeList.Create;
    MinAge := FFMFuncFindingRecord.FMField['13'].Value; //if MinAge = '' then MinAge := '0';
    MaxAge := FFMFuncFindingRecord.FMField['14'].Value; //if MaxAge = '' then MaxAge := '120';
    Freq   := FFMFuncFindingRecord.FMField['15'].Value;
    FindingName := FFMFuncFindingRecord.FMField['40'].Value;
    if FindingName = '' then FindingName := 'Function Finding #'+SubIEN;
    EntryStr := Freq + '^' + MinAge + '^' + MaxAge + '^' + FindingName;
    RangeList.AddRange(EntryStr);
    ListOfRanges.Add(RangeList);
  end;
  Render;
  FFindings.Free;
  FFuncFindings.Free;
  FFileMan.Free;
end;


procedure TfrmAgeFreq.Render;
begin
  Self.Invalidate;
end;


procedure TfrmAgeFreq.pbCanvasPaint(Sender: TObject);
  var  LP, RP : TPoint;
       i : integer;
       Min, Max : integer;

  const
    DEBUG_DRAW : boolean = false; //TRUE;

  Procedure {pbCanvasPaint:}DrawArrow(Pt : TPoint; PointsRight : boolean);
  Const W=10; H=5;
  Var P2 : TPoint;
      Dir : integer;
  begin
    pbCanvas.Canvas.MoveTo(Pt.X, Pt.Y);
    P2.Y := Pt.Y - H;
    Dir := 1;
    if PointsRight then Dir := -1;
    P2.X := Pt.X + W*Dir;
    pbCanvas.Canvas.LineTo(P2.X, P2.Y);
    P2.Y := Pt.Y + H;
    pbCanvas.Canvas.MoveTo(Pt.X, Pt.Y);
    pbCanvas.Canvas.LineTo(P2.X, P2.Y);
  end;

  Procedure {pbCanvasPaint:}DrawBall(Pt : TPoint);
  Const R = 5;  //radius
  begin
    pbCanvas.Canvas.Ellipse(Pt.X-R, Pt.Y-R, Pt.X+R, Pt.Y+R);
  end;

  function {pbCanvasPaint:}XForAge(Age : integer) : integer;
  var pct : single;
  begin
    pct := (Age - Min) / (Max - Min);
    Result := Round((RP.X - LP.X) * Pct) + LP.X;
  end;

  function {pbCanvasPaint:}PtForAge(Age : Integer) : TPoint;
  begin
    Result.Y := LP.Y;
    Result.X := XForAge(Age);
  end;

  function {pbCanvasPaint:}MidPt(P1, P2 : TPoint) : TPoint;
  begin
    Result.X := ((P2.X - P1.X) div 2) + P1.X;
    Result.Y := ((P2.Y - P1.Y) div 2) + P1.Y;
  end;

  Procedure {pbCanvasPaint:}Line(P1, P2 : TPoint; Color : TColor);
  begin
    pbCanvas.Canvas.Pen.Color := Color;
    pbCanvas.Canvas.MoveTo(P1.X, P1.Y);
    pbCanvas.Canvas.LineTo(P2.X, P2.Y);
  end;

  function {pbCanvasPaint:}PtToCenterText(P1, P2 : TPoint; Text: String) : TPoint;
  //Left to right centering.
  var Size : TSize;
  begin
    Size := pbCanvas.Canvas.TextExtent(Text);
    Result := MidPt(P1, P2);
    Result.X := Result.X - (Size.cx div 2);
    Result.Y := Result.Y - (Size.cy) * 2 - 5;
  end;

  Procedure {pbCanvasPaint:}DrawRange(R : TAgeRange; Offset : integer);
  var P1, P2, P3 : TPoint;
      TextSize : TSize;
      Color : TColor;
      Text : string;
  begin
    if R.MinAge = -1 then begin
      P1 := PtForAge(Min);
    end else begin
      P1 := PtForAge(R.MinAge);
    end;
    if R.MaxAge = -1 then begin
      P2 := PtForAge(Max);
    end else begin
      P2 := PtForAge(R.MaxAge);
    end;
    if R.Frequency = '0' then Color := clRed else Color := clGreen;
    P1.Y := P1.Y - Offset;
    P2.Y := P2.Y - Offset;
    Line(P1, P2, Color);
    if DEBUG_DRAW then Application.ProcessMessages;

    //Now draw tick marks and labels
    P3 := P1; P3.Y := P3.Y - 10;
    if R.MinAge <> -1 then begin
      Line(P1, P3, Color);
      Text := IntToStr(R.MinAge) + ' yrs';
      pbCanvas.Canvas.TextOut(P3.X +  5, P3.Y-5, Text);
    end;
    if DEBUG_DRAW then Application.ProcessMessages;

    P3 := P2; P3.Y := P3.Y - 10;
    if R.MaxAge <> -1 then Begin
      Line(P2, P3, Color);
      Text := IntToStr(R.MaxAge) + 'yrs';
      TextSize := pbCanvas.Canvas.TextExtent(Text);
      pbCanvas.Canvas.TextOut(P3.X - TextSize.cx - 5, P3.Y-5, Text);
    end;
    if DEBUG_DRAW then Application.ProcessMessages;

    Text := R.Frequency;
    if Text = '0' then begin
      Text := '(none)';
    end else begin
      //Text := 'Every ' + Text + ' yr';
      //if R.Frequency <> '1' then Text := Text + 's';
      Text := 'Every ' + R.FormatedFreq;
    end;
    if R.FindingName <> '' then begin
      Text := 'If [' + R.FindingName + '] is TRUE, then ' + Text;
    end else begin
      if ListOfRanges.Count > 1 then begin
        Text := 'Default Frequency Is ' + Text;
      end;
    end;
    P3 := PtToCenterText(P1, P2, Text);
    pbCanvas.Canvas.TextOut(P3.X, P3.Y, Text);
    if DEBUG_DRAW then Application.ProcessMessages;

  end;

  var
    RangesList : TRangeList;
    NumGroups : integer;
    GroupI : integer;
    GroupFloorY : integer;
  const
    HEIGHT_PER_GROUP = 60;
    TOP_OFFSET = 10;

begin
  //Render here
  pbCanvas.Canvas.Brush.Color := clWhite;
  pbCanvas.Canvas.Pen.Color := clWhite;

  NumGroups := ListOfRanges.Count;
  Self.Height := (NumGroups+1) * HEIGHT_PER_GROUP + pnlBottom.Height;
  if DEBUG_DRAW then Application.ProcessMessages;
  pbCanvas.Canvas.Rectangle(0, 0, pbCanvas.Width, pbCanvas.Height);
  if DEBUG_DRAW then Application.ProcessMessages;

  for GroupI := 0 to ListOfRanges.Count - 1 do begin
    RangesList := TRangeList(ListOfRanges[GroupI]);
    GroupFloorY := TOP_OFFSET + HEIGHT_PER_GROUP * (GroupI+1);

    if ListOfRanges.Count > 1 then begin
      //Draw base number line
      pbCanvas.Canvas.Pen.Color := clBlue;
      pbCanvas.Canvas.Pen.Style := psDash;
      pbCanvas.Canvas.Pen.Width := 1;
      LP.X := 1;
      LP.Y := GroupFloorY;
      RP.Y := LP.Y; RP.X := pbCanvas.Width - 1;
      pbCanvas.Canvas.MoveTo(LP.X, LP.Y);
      pbCanvas.Canvas.LineTo(RP.X, RP.Y);
      if DEBUG_DRAW then Application.ProcessMessages;
    end;

    //Draw base number line
    pbCanvas.Canvas.Pen.Color := clBlack;
    pbCanvas.Canvas.Pen.Width := 3;
    LP.X := 10;
    LP.Y := GroupFloorY - 10;   // pbCanvas.Height-10;
    RP.Y := LP.Y; RP.X := pbCanvas.Width - 10;
    pbCanvas.Canvas.MoveTo(LP.X, LP.Y);
    pbCanvas.Canvas.LineTo(RP.X, RP.Y);
    if DEBUG_DRAW then Application.ProcessMessages;

    if RangesList.MinAgeDefined then begin
      Min := RangesList.MinAge;
      DrawBall(LP);
    end else begin
      Min := 0;
      DrawArrow(LP, false);
    end;
    if DEBUG_DRAW then Application.ProcessMessages;

    if RangesList.MaxAgeDefined then begin
      Max := RangesList.MaxAge;
      DrawBall(RP);
    end else begin
      Max := 100;
      DrawArrow(RP, true);
    end;
    if DEBUG_DRAW then Application.ProcessMessages;

    //Draw each range
    for i := 0 to RangesList.Count - 1 do begin
      DrawRange(RangesList.ARange[i], 10 );
      if DEBUG_DRAW then Application.ProcessMessages;
    end;

  end;

end;


end.

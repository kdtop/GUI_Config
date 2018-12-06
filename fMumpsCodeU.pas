unit fMumpsCodeU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RichEdit, StrUtils, ORFn,
  rRPCsU, StdCtrls, Buttons, ComCtrls, ExtCtrls;

type
  TColorType = (ctCMD, ctArg, ctString, ctComment, ctLabel);
const
  LAST_COLOR_TYPE = ctLabel;

type
  TfrmMumpsCode = class(TForm)
    pnlBottom: TPanel;
    reCode: TRichEdit;
    StatusBar1: TStatusBar;
    RevertBtn: TBitBtn;
    ApplyBtn: TBitBtn;
    DoneBtn: TBitBtn;
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
    FEntryPoint: string;
    procedure GetParseInfo(Line : string; Info : TStringList);
    procedure SetColor(RE : TRichEdit; LineIdx, StartIdx, Len : integer; FGColor : TColor);
    procedure ColorizeSyntax(RE : TRichEdit);
    procedure Colorize1SyntaxLine(RE : TRichEdit; LineIndex : integer; Info : TStringList);
    procedure ScrollToEntryPoint(EntryPoint : string);
    function GetColorForType(ColorType : TColorType ) : TColor;
    function GetFirstVisibleScrollLine : longint;
    procedure SetFirstVisibleScrollLine(LineNum : longint);

  public
    { Public declarations }
    procedure Initialize(Routine, Entrypoint : string);
  end;


const
  TYPE_COLORS : array[ctCMD..LAST_COLOR_TYPE] of TColor = (
      clRed,       //ctCMD
      clGreen,     //ctArg
      clTeal,      //ctString
      clGray,      //ctComment
      clBlue       //ctLabel
   );

//var
//  frmMumpsCode: TfrmMumpsCode;

implementation

{$R *.dfm}

procedure TfrmMumpsCode.Initialize(Routine, Entrypoint : string);
begin
  FEntryPoint := Entrypoint;
  rRPCsU.GetCodeRoutine(Routine, reCode.Lines);
  ColorizeSyntax(reCode);
  ScrollToEntryPoint(FEntryPoint);
  Self.Caption := 'M/Mumps Code -- ' + EntryPoint + '^' + Routine;
end;

function TfrmMumpsCode.GetColorForType(ColorType : TColorType ) : TColor;
begin
  Result := TYPE_COLORS[ColorType];
end;


function TfrmMumpsCode.GetFirstVisibleScrollLine : longint;
begin
  Result := reCode.Perform(EM_GETFIRSTVISIBLELINE, 0, 0 );
end;

procedure TfrmMumpsCode.SetFirstVisibleScrollLine(LineNum : longint);
//Code from here: http://www.delphigroups.info/3/2/156553.html
var CurLine : longint;
begin
  CurLine := GetFirstVisibleScrollLine;
  if CurLine <> LineNum then begin
    reCode.Perform(EM_LINESCROLL, 0, LineNum-CurLine);
  end;
end;


procedure TfrmMumpsCode.ScrollToEntryPoint(EntryPoint : string);
var i : integer;
    s : string;
    TagLen : integer;
begin
  TagLen := length(EntryPoint);
  for i := 0 to reCode.Lines.Count - 1 do begin
    s := LeftStr(reCode.Lines[i],TagLen);
    if s = EntryPoint then begin
      SetFirstVisibleScrollLine(i);
      break;
    end;
  end;
end;

procedure TfrmMumpsCode.ColorizeSyntax(RE : TRichEdit);
var i : integer;
    Info : TStringList;
begin
  Info := TStringList.Create;
  //colorize comments
  for i := 0 to RE.Lines.Count - 1 do begin
    GetParseInfo(RE.Lines[i], Info);
    Colorize1SyntaxLine(RE, i, Info);
  end;
  Info.Free;
end;

procedure TfrmMumpsCode.Colorize1SyntaxLine(RE : TRichEdit; LineIndex : integer; Info : TStringList);
var i : integer;
    Entry : string;
    EType : string;
    TypeColor : TColor;
    S1,S2 : string;
    StartPos, EndPos : integer;
begin
  for i := 0 to Info.Count-1 do begin
    Entry := Info[i];
    EType := piece(Entry,'^',3);
    TypeColor := -1;
    if EType = 'LABEL' then begin
      if Trim(Piece(Entry,'^',4))<>'' then begin
        TypeColor := GetColorForType(ctLabel);
      end;
    end else if EType = 'CMD' then begin
      TypeColor := GetColorForType(ctCMD);
    end else if EType = 'ARG' then begin
      TypeColor := GetColorForType(ctArg);
    end else if EType = 'COMMENT' then begin
      TypeColor := GetColorForType(ctComment);
    end;
    if TypeColor = -1 then continue;
    S1 := Piece(Entry,'^',1);
    S2 := Piece(Entry,'^',2);
    StartPos := StrToIntDef(S1, 0)-1;
    EndPos := StrToIntDef(S2, 0)-1;
    SetColor(RE, LineIndex, StartPos, (EndPos-StartPos+1), TypeColor);
  end;
end;


procedure TfrmMumpsCode.GetParseInfo(Line : string; Info : TStringList);
{Output format:
  StartPos#^EndPos#^LABEL^labelName or Space  <-- will be leading space if no label present.
  StartPos#^EndPos#^CMD^CommandName
  StartPos#^EndPos#^ARG^0^ArgumentText
  StartPos#^EndPos#^ARG^TypeNum^SubparsedArgText
  StartPos#^EndPos#^CMD^CommandName
  ...
  StartPos#^EndPos#^COMMENT^CommentText^Line#
}
  function NextSpace(var Line : string; p : integer; var InQt : boolean) : integer;
  //Find next space AFTER starting position P
  //Doesn't count spaces inside quotes
  begin
    while p <= length(Line) do begin
      inc(p);
      if (Line[p]=' ')and not InQt then begin
        //if p=length(Line) or (Line[p+1] <> ' ') then break;
        //continue;
        break;
      end;
      if Line[p]='"' then InQt := not InQt;
    end;
    Result := p;
  end;

  function GetNextWord(var Line : string; var p : integer) : string;
  var nextP : integer;
      InQt : boolean;
  begin
    InQt := false;
    nextP := NextSpace(Line, p, InQt);
    Result := Trim(MidStr(Line, p, NextP-p));
    p := nextP;
  end;

  Procedure ParseArgs(var Line : string; var p : integer; Info : TStringList);
  //parse arguments of a command
  begin
    //Finish
  end;

type
  TMode =(lfLabel,lfCmd,lfArg);
var
  StartingP, p,p2 : integer;
  Mode : TMode;
  Entry : string;
  PostCondition, s,s2 : string;

begin
  if not assigned(Info) then exit;
  if Line='' then exit;
  Info.Clear;
  Mode := lfLabel;
  p := 1;
  while p <= length(Line) do begin
    StartingP := p;
    if Line[p] = ';' then begin
      p := Length(Line);
      s := MidStr(Line, StartingP, p);
      Entry := IntToStr(StartingP)+'^'+IntToStr(p)+'^COMMENT^'+s;
      Info.Add(Entry);
      break;
    end;
    case Mode of
      lfLabel:
        begin
          if Line[p] = ' ' then begin
            while (p <= length(Line)) and (Line[p]=' ') do inc(p);
            s := LeftStr(Line, p-1);
          end else begin
            s := GetNextWord(Line, p);
          end;
          Entry := IntToStr(StartingP)+'^'+IntToStr(p-1)+'^LABEL^'+s;
          Info.Add(Entry);
          Mode := lfCmd;
        end;
      lfCmd:
        begin
          while (p <= length(Line)) and (Line[p]=' ') do begin
            inc(p); StartingP := p;
          end;
          if Line[p] = ';' then continue;
          s := GetNextWord(Line, p);
          if Pos(':',s)>0 then begin
            s2 := s;
            s := piece(s, ':', 1);
            PostCondition := MidStr(s2, Length(s)+2, Length(s2));
            p2 := p;
            p := StartingP + Length(s);
            Entry := IntToStr(StartingP)+'^'+IntToStr(p-1)+'^CMD^'+s;
            Info.Add(Entry);
            Entry := IntToStr(p+1)+'^'+IntToStr(p2-1)+'^ARG^0^'+s;
            Info.Add(Entry);
          end else begin
            Entry := IntToStr(StartingP)+'^'+IntToStr(p-1)+'^CMD^'+s;
            Info.Add(Entry);
          end;
          Mode := lfArg;
        end;
      lfArg:
        begin
          s := GetNextWord(Line, p);
          Entry := IntToStr(StartingP)+'^'+IntToStr(p-1)+'^ARG^0^'+s;
          Info.Add(Entry);
          ParseArgs(Line, P, Info);
          Mode := lfCmd;
        end;
    end; {case}


  end;
end;

procedure TfrmMumpsCode.SetColor(RE : TRichEdit; LineIdx, StartIdx, Len : integer; FGColor : TColor);
var
  Format: CHARFORMAT2;
  LineStart,LineEnd : integer;
  temp : integer;
begin
  LineStart := RE.Perform(EM_LINEINDEX, LineIdx, 0);
  LineEnd := LineStart + Length(RE.Lines[LineIdx]);
  RE.SelStart := LineStart + StartIdx;
  //temp := RE.SelStart + Len;
  //if temp > LineEnd then temp := LineEnd;
  RE.SelLength := Len;
  //RE.SelAttributes.Style := [fsBold];
  RE.SelAttributes.Color := FGColor;
  {
  //lines below From: http://www.delphipages.com/forum/showthread.php?t=203456
  //Below sets BACKGROUND color
  FillChar(Format, SizeOf(Format), 0);
  Format.cbSize := SizeOf(Format);
  Format.dwMask := CFM_BACKCOLOR;
  Format.crBackColor := FGColor;
  RE.Perform(EM_SETCHARFORMAT, SCF_SELECTION, Longint(@Format));
  }
  //Application.ProcessMessages;  //temp;
end;




procedure TfrmMumpsCode.SpeedButton1Click(Sender: TObject);
begin
  ColorizeSyntax(reCode)
end;

end.


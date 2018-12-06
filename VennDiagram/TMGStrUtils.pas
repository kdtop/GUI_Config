unit TMGStrUtils;

interface

  Uses SysUtils, StrUtils;

function Piece(const S: string; Delim: char; PieceNum: Integer): string; overload;
function Piece(const S: string; Delim: string; PieceNum: Integer): string; overload;
function MatchedExtract(const AString : string; DivCh : char; var Pos : integer) : string;
function LTrim(Str : string; NumToCut : integer) : string;
function ExtractNumValue(TempS : string) : string;
function ExtractQtValue(var TempS : string) : string;
function ExtractParens(S : string; var StrB : string) : string;

const
  CRLF = #13#10;


implementation

function Piece(const S: string; Delim: char; PieceNum: Integer): string;   overload; //kt added 'overload;'
{ returns the Nth piece (PieceNum) of a string delimited by Delim }
var
  i: Integer;
  Strt, Next: PChar;
begin
  i := 1;
  Strt := PChar(S);
  Next := StrScan(Strt, Delim);
  while (i < PieceNum) and (Next <> nil) do
  begin
    Inc(i);
    Strt := Next + 1;
    Next := StrScan(Strt, Delim);
  end;
  if Next = nil then Next := StrEnd(Strt);
  if i < PieceNum then Result := '' else SetString(Result, Strt, Next - Strt);
end;

function Piece(const S: string; Delim: string; PieceNum: Integer): string; overload;
//kt Added entire function
var Remainder : String;
    PieceLen,p : integer;
begin
  Remainder := S;
  Result := '';
  PieceLen := Length(Delim);
  while (PieceNum > 0) and (Length(Remainder) > 0) do begin
    p := Pos(Delim,Remainder);
    if p=0 then p := length(Remainder)+1;
    Result := MidStr(Remainder,1,p-1);
    Remainder := MidStr(Remainder,p+PieceLen,9999);
    Dec(PieceNum);
  end;
end;

function MatchedExtract(const AString : string; DivCh : char; var Pos : integer) : string;
//Purpose: to return string encased by matching DivCh.
//E.g.  'This is a simple (really simple) example' --> extract 'really simple'
//E.g.  'Another (nested (1 deep)) example' --> extract 'nested (1 deep)'
//Input: AString -- the string to scan
//       DivCH --  this is the opening character.  Allowed values:
//             (, {, [, <   (the closing character will be matched to opening char)
//       Pos -- passed by reference.  this is the starting place of the scan
//              and it is changed to the closing part of the scan.
//              NOTE: if Pos starts inside a matched pair, then problems
//                    will occur.
//Results: returns the extracted string, or '' if error.
var OpenCh, CloseCh : char;
    Level : integer;
begin
  Result := '';
  OpenCh := DivCh;
  case DivCH of
    '(' : CloseCh := ')';
    '{' : CloseCh := '}';
    '[' : CloseCh := ']';
    '<' : CloseCh := '>';
    else  exit;
  end;
  Level := 0;
  repeat
    if AString[Pos] = OpenCh then begin
      Inc(Level);
      if Level = 1 then begin
        inc (Pos);
        continue;
      end;
    end else if AString[Pos] = CloseCh then begin
      Dec(Level);
      if Level <=0 then break;
    end;
    if level > 0 then Result := Result + AString[Pos];
    inc(Pos);
  until (Pos > Length(AString));
end;

function LTrim(Str : string; NumToCut : integer) : string;
begin
  Result := MidStr(Str, NumToCut+1, Length(Str));
end;


function ExtractNumValue(TempS : string) : string;
//e.g. '123abc' --> '123'
var p : integer;
const NUM_CHARS ='0123456789';
begin
  Result := '';
  p := 1;
  while (p<=Length(TempS)) and (Pos(TempS[p], NUM_CHARS)>0) do begin
    Result := Result + TempS[p];
    inc(p);
  end;
end;


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


function ExtractParens(S : string; var StrB : string) : string;
//Assumes that 1st char is '('
var i, count : integer;
begin
  Result := '';
  StrB := '';
  count := 0;
  for i := 1 to length(S) do begin
    if s[i] = '(' then inc(count);
    if s[i] = ')' then dec(count);
    if count=0 then begin
      Result :=  MidStr(S, 2, i-2);
      StrB := MidStr(S, i+1, Length(S));
      break;
    end;
  end;
end;




end.

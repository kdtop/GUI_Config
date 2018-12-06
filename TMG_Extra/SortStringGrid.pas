unit SortStringGrid;
// Written by K. Toppenberg, MD
// Copyright (C) 6/23/2010
// Released under GPL license.

interface
uses
  Windows, Messages, StrUtils, SysUtils, Classes, Graphics, Controls, Dialogs, Grids;

type
  TSortDirection = (sdNoSort,sdAscending,sdDescending);

  TSortStringGrid = class(TStringGrid)
  private
    FNumbers : TList;
    FLastSortDirection : TSortDirection;
    FLastSortedColumn : LongInt;
    function GetPreSortRowNum(CurRowNum : LongInt) : LongInt;
    procedure SetNumber(RowNum : LongInt; Value : integer);
    function GetNumber(RowNum : LongInt) : Integer;
  protected
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    property ANumber[RowNum : LongInt] : Integer read GetNumber write SetNumber;
    function Piece(const S: string; Delim: string; PieceNum: Integer): string; overload;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source : TPersistent); override;
    procedure SortCol(SortColNum : integer; SortDirection : TSortDirection);
    property SortedColumn : LongInt read FLastSortedColumn;
    property PreSortRowNum[CurRowNum : LongInt] : LongInt read GetPreSortRowNum;
  end;

  procedure Register;

implementation

  constructor TSortStringGrid.Create(AOwner: TComponent);
  begin
    inherited Create(AOwner);
    FNumbers := TList.Create;
    FLastSortedColumn := -1;
    FLastSortDirection := sdNoSort;
  end;

  destructor TSortStringGrid.Destroy;
  begin
    FNumbers.Free;
    inherited Destroy;
  end;

  procedure TSortStringGrid.Assign(Source : TPersistent);
  var Row,Col : LongInt;
      Src : TSortStringGrid;
  begin
    //Inherited Assign(Source);
    //NOTE: This is only a limited copy.  Could extend later.
    if not (Source is TSortStringGrid) then exit;
    Src := TSortStringGrid(Source);
    Self.ColCount := Src.ColCount;
    Self.RowCount := Src.RowCount;
    for Row := 0 to Self.RowCount-1 do begin
      Self.Rows[Row].Text := Src.Rows[Row].Text;
      for Col := 0 to Self.ColCount-1 do begin
        Self.Objects[Col,Row] := Src.Objects[Col,Row];
      end;
    end;
  end;


  procedure TSortStringGrid.SetNumber(RowNum : Integer; Value : integer);
  begin
    if RowNum < 0 then exit;
    while RowNum > (FNumbers.Count-1) do begin
      FNumbers.Add(TObject(0));
    end;
    FNumbers.Items[RowNum] := TObject(Value);
  end;

  function TSortStringGrid.GetNumber(RowNum : integer) : Integer;
  begin
    Result := 0; //default value
    if (RowNum < 0) or (RowNum > (FNumbers.Count-1)) then exit;
    Result := Integer(FNumbers.Items[RowNum]);
  end;

  procedure TSortStringGrid.MouseUp(Button: TMouseButton;
                                    Shift: TShiftState;
                                    X, Y: Integer);
  var  ACol,ARow : LongInt;
       SortDir : TSortDirection;
       //temp : integer;
  begin
    MouseToCell(X, Y, ACol, ARow);
    if ARow=0 then begin
      if ACol = FLastSortedColumn then begin
        case FLastSortDirection of
          sdNoSort    : SortDir := sdAscending;
          sdAscending : SortDir := sdDescending;
          sdDescending: SortDir := sdNoSort;
          else          SortDir := sdNoSort;
        end; {case}
      end else SortDir := sdAscending;
      SortCol(ACol,SortDir);
    end else begin
      //temp := Self.PreSortRowNum[ARow];
      //MessageDlg('Original Row# '+ IntToStr(temp),mtInformation,[mbOK],0);
      inherited MouseUp(Button,Shift,X,Y);
    end;
  end;

  procedure TSortStringGrid.SortCol(SortColNum : integer; SortDirection : TSortDirection);
  //Sort routine heavily modified from code found here
  //http://www.delphitricks.com/source-code/components/sort_a_stringgrid.html
  const
    DivS = '{°v°}'; //some arbitrary but unique character sequence

  var
    RowNum,ColNum         : integer;
    PreSortRowNum         : integer;
    SourceRow             : LongInt;
    DestRow               : LongInt;
    MyList                : TStringList;
    FirstSort             : boolean;
    TempGrid              : TSortStringGrid;
    InfoStr                : string;

  begin
    TempGrid := TSortStringGrid.Create(Self);
    TempGrid.Assign(Self);
    FLastSortedColumn := SortColNum;
    FLastSortDirection := SortDirection;
    MyList        := TStringList.Create;
    MyList.Sorted := False;
    try
      FirstSort := (Self.FNumbers.Count=0);
      MyList.Add('--');  //placeholder for header row-
      for RowNum := 1 to RowCount-1 do MyList.Add(''); //fill to allow random access
      if (SortDirection = sdNoSort) and FirstSort then exit; //will jump to Finally part.
      for RowNum := 1 to RowCount - 1 do begin
        PreSortRowNum := Self.PreSortRowNum[RowNum];
        if (SortDirection = sdNoSort) then DestRow := PreSortRowNum
        else begin
          DestRow := RowNum;
          if FirstSort then PreSortRowNum := RowNum;
        end;
        InfoStr := Self.Cells[SortColNum,RowNum] + DivS + IntToStr(RowNum) + DivS + IntToStr(PreSortRowNum);
        MyList.Strings[DestRow] := InfoStr;
      end;
      if (SortDirection <> sdNoSort) then Mylist.Sort;

      //Order in MyList is new order for grid
      for RowNum := 1 to RowCount - 1 do begin
        InfoStr := MyList.Strings[RowNum];
        SourceRow := StrToIntDef(Piece(InfoStr,DivS,2),0);
        DestRow := RowNum;
        if SortDirection = sdDescending then DestRow := RowCount-RowNum;
        Rows[DestRow].Text := TempGrid.Rows[SourceRow].Text;  //Copy all strings on row
        //Set up pre-sort number.
        PreSortRowNum := StrToIntDef(Piece(InfoStr,DivS,3),0);
        Self.ANumber[DestRow] := PreSortRowNum; //Set PreSortNumber
        //Copy object pointers
        for ColNum := 0 to ColCount-1 do begin
          Self.Objects[ColNum,DestRow] := TempGrid.Objects[ColNum,SourceRow];
        end;
      end;

    finally
      MyList.Free;
      TempGrid.Free;
    end;
  end;


  procedure TSortStringGrid.DrawCell(ACol, ARow: Longint;
                                     ARect: TRect;
                                     AState: TGridDrawState);
  var P,P2 : TPoint;
      OrigRect : TRect;
      OrigPen : TPen;
      i : integer;
      Dir : integer;
  begin
    //custom code here
    OrigRect := ARect;
    if (ARow=0) and (ACol = FLastSortedColumn)
    and (FLastSortDirection <> sdNoSort) then begin
      ARect.Left := ARect.Left+10; //create space for sort indicator
    end;
    inherited DrawCell(ACol,ARow,ARect,AState);
    if (ARow=0) and (ACol = FLastSortedColumn)
    and (FLastSortDirection <> sdNoSort) then begin
      OrigPen := Canvas.Pen;
      Canvas.Pen.Width := 1;
      Canvas.Pen.Color := clRed;
      P := OrigRect.TopLeft;
      P.X := OrigRect.Left+3;
      P.Y := ARect.Top + (ARect.Bottom - ARect.Top) div 2;
      if FLastSortDirection= sdAscending then Dir := 1
      else Dir := -1;
      for i := 0 to 4 do begin
        P2.X := P.X + i;
        P2.Y := P.Y + i*Dir;
        Canvas.PenPos := P2;
        Canvas.LineTo(P.X+8-i, P.Y+i*Dir);
      end;
      Canvas.Pen := OrigPen;
    end;
  end;

  function TSortStringGrid.GetPreSortRowNum(CurRowNum : LongInt) : LongInt;
  var i :integer;
  begin
    if Self.FNumbers.Count=0 then begin
      for i := 0 to RowCount-1 do begin
        SetNumber(i,i);
      end;
    end;
    Result := GetNumber(CurRowNum);
  end;

  function TSortStringGrid.Piece(const S: string; Delim: string; PieceNum: Integer): string;
  //kt 8/09 Added entire function
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


  procedure Register;
  begin
    RegisterComponents('Additional', [TSortStringGrid]);
  end;

end.


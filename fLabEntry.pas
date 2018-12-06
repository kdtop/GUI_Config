unit fLabEntry;
   (*
   WorldVistA Configuration Utility
   (c) 9/2013 Kevin Toppenberg
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
  Dialogs, ORCtrls, ExtCtrls, StdCtrls, Buttons, Grids, rCore, ORNet, ORFn,
  StrUtils, ComCtrls;

type
  TfrmLabEntry = class(TForm)
    pnlTop: TPanel;
    LabsORComboBox: TORComboBox;
    pnlBottom: TPanel;
    Splitter1: TSplitter;
    pnlAddRemoveBtns: TPanel;
    btnAddLab: TSpeedButton;
    btnRemoveLab: TSpeedButton;
    Splitter2: TSplitter;
    pnlEntryRight: TPanel;
    pnlLabEntryRightTop: TPanel;
    sgLabValues: TStringGrid;
    btnCancel: TBitBtn;
    btnLabSave: TBitBtn;
    btnAddComments: TBitBtn;
    memLabDetails: TMemo;
    btnEditDetails: TBitBtn;
    pnlMiddle: TPanel;
    lblTestsSelected: TLabel;
    tvSelLabs: TTreeView;
    pnlPadding: TPanel;
    Splitter3: TSplitter;
    lblValueInstructions: TLabel;
    Timer1: TTimer;
    procedure LabsORComboBoxDblClick(Sender: TObject);
    procedure sgLabValuesKeyPress(Sender: TObject; var Key: Char);
    procedure sgLabValuesDblClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnLabSaveClick(Sender: TObject);
    procedure btnAddCommentsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tvSelLabsChange(Sender: TObject; Node: TTreeNode);
    procedure LabsORComboBoxKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tvSelLabsKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tvSelLabsExit(Sender: TObject);
    procedure tvSelLabsEnter(Sender: TObject);
    procedure btnRemoveLabClick(Sender: TObject);
    procedure btnAddLabClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LabsORComboBoxNeedData(Sender: TObject;
      const StartFrom: string; Direction, InsertAt: Integer);
    procedure btnEditDetailsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    EditDetailsAborted : boolean;
    LabComments : TStringList;
    LabData : TStringList;
    DefaultSpec, DefaultDate : string;
    DefaultSpecIEN : int64;
    function AddToTV(Parent : TTreeNode; Name : string; IEN60 : int64;
                     Store : string; DisplayIndent : string = '') : TTreeNode;
    function GetComponentLabs(IEN : int64) : TStrings;
    function LabValuesRowForIEN(IEN60 : int64) : integer;
    function IENAlreadyPresent(IEN60 : int64) : boolean;
    procedure RemoveSelLab(SelLab : TTreeNode);
    procedure DeleteRow(DelRow : integer);
    procedure SelectRow(Row : integer);
    procedure RowMakeVisible(AGrid: TStringGrid; ARow: integer);
    procedure GatherLabData(Data : TStringList);
    function PostLabData(LabData : TStringList) : Boolean;
    procedure EditDateCell(ACol, ARow : integer);
    procedure EditSpecimenCell(ACol, ARow : integer);
    function IsPanelRow(ARow : integer) : boolean;
    function IsChildRow(ARow : integer) : boolean;
    procedure StoreToPanelChildren(StartingRow, ACol : integer; Str : string; Obj : pointer=nil);
  public
    { Public declarations }
  end;

//var
//  frmLabEntry: TfrmLabEntry;  //not auto-created.

implementation

{$R *.dfm}

uses fLabEntryDetails, flabComments,
     fLabDateEdit, fLabSpecimenEdit,
     uCore,
     TRPCB, FMErrorU;

var
  frmLabComments: TfrmLabComments;
  frmLabEntryDetails: TfrmLabEntryDetails;

const
  VALUE_COL    = 1;
  FLAG_COL     = 2;
  REFLO_COL    = 3;
  REFHI_COL    = 4;
  LAB_DATE_COL = 5;
  LAB_SPEC_COL = 6;
  LAB_CHILD_SYMBOL = ' * ';
  PANEL_NAME   = '[Panel]';
  BLANK_LINES  = '   ---------';

procedure TfrmLabEntry.FormCreate(Sender: TObject);
begin
  frmLabComments := TfrmLabComments.Create(Self);
  LabComments := TStringList.Create;
  frmLabEntryDetails := TfrmLabEntryDetails.Create(Self);
  LabData := TStringList.Create;

  sgLabValues.ColWidths[0] := 100;  //May need to fix.
  sgLabValues.Cells[0,0] := 'Lab Name';
  sgLabValues.Cells[1,0] := 'Value';
  sgLabValues.Cells[2,0] := 'Flag';
  sgLabValues.Cells[3,0] := 'Ref (Lo)';
  sgLabValues.Cells[4,0] := 'Ref (Hi)';
  sgLabValues.Cells[LAB_DATE_COL,0] := 'Date';
  sgLabValues.Cells[LAB_SPEC_COL,0] := 'Specimen';
end;

procedure TfrmLabEntry.FormDestroy(Sender: TObject);
begin
  frmLabComments.Free;
  frmLabEntryDetails.Free;
  LabComments.Free;
  LabData.Free;
end;

procedure TfrmLabEntry.FormShow(Sender: TObject);
begin
  LabsORComboBox.InitLongList('A');
  Timer1.Enabled := true;
  Timer1.Interval := 200;
end;

procedure TfrmLabEntry.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  EditDetailsAborted := false;
  btnEditDetailsClick(Self);  //Get details about entry first thing...
  if EditDetailsAborted then begin
    btnCancelClick(nil);
  end;
end;



procedure TfrmLabEntry.btnEditDetailsClick(Sender: TObject);
begin
  if frmLabEntryDetails.ShowModal = mrOK then begin
    frmLabEntryDetails.GetDetailsNarrative(memLabDetails.Lines);
    //DefaultSpecIEN := frmLabEntryDetails.cboSpecimen.ItemIEN;
    DefaultSpecIEN := -1;
    //DefaultSpec := frmLabEntryDetails.SelectedSpecimen;
    DefaultSpec := 'BLOOD';
    DefaultDate := DateToStr(frmLabEntryDetails.dtpDTTaken.DateTime);
  end else begin
    EditDetailsAborted := true;
  end;
end;

procedure TfrmLabEntry.btnLabSaveClick(Sender: TObject);
var Result : Boolean;
begin
  LabData.Clear;
  GatherLabData(LabData);
  Result := PostLabData(LabData);  //should display any errors
  if Result = true then begin
    Self.Close;
  end;
end;

//========================================================================
//========================================================================
//RPC Calls
//========================================================================
//========================================================================
function FieldHelp(FileNum, IENS, FieldNum, HelpStyle : string) : string; forward;

function BrokerErrorCheck(var RPCResult : string) : boolean;
//Result of this function: true  if all OK, or false if error.

  procedure AddHintIfPossible(ErrorSL : TStrings);
    function GetValue(Key : string) : string;
    var i : integer;
        s : string;
    begin
      Result := '';
      Key := '['+Key+']';
      for i := 0 to ErrorSL.Count - 1 do begin
        s := ErrorSL[i];
        if Pos(Key, S)<=0 then continue;
        Result := piece(S,'=',2);
        Break;
      end;
    end;

  var
    FileNum,FldNum,IENS, Value : string;
    HintText : string;

  begin
    if Pos('is not valid', ErrorSL.Text)>=0 then begin;
      Value := GetValue('3');
      FileNum := GetValue('FILE');
      FldNum := GetValue('FIELD');
      if (Value='') or (FileNum = '') or (FldNum = '') then exit;
      if FileNum = '63.04' then IENS :='1,1,' else IENS := '1,';
      HintText := FieldHelp(FileNum, IENS, FldNum, '?');
      ErrorSL.Add('');
      ErrorSL.Add('-----HINT-----');
      ErrorSL.Text := ErrorSL.Text + HintText;
    end;
  end;

begin
  Result := (RPCBrokerV.Results.Count> 0);
  if Result = false then exit;
  RPCResult := RPCBrokerV.Results[0];    //returns:  error: -1;  success=1
  RPCBrokerV.Results.Delete(0);
  if piece(RPCResult,'^',1)='-1' then begin
    Result := false;
    if RPCBrokerV.Results.Count = 0 then RPCBrokerV.Results.Add(RPCResult);
    FMErrorForm.Memo.Lines.Assign(RPCBrokerV.Results);
    FMErrorForm.PrepMessage;
    AddHintIfPossible(FMErrorForm.Memo.Lines);
    FMErrorForm.ShowModal;
  end;
end;

function CallBrokerAndErrorCheck(var RPCResult : string) : boolean;
//Result of this function: true  if all OK, or false if error.

//copied from rRPCsU, in prep of port over to CPRS

//NOTE: the RPC call must be set up prior to call this function.
//Also RPCResult is OUT parameter of the RPCBrokerV.Results[0] value
//ALSO LastRPCHadError variable (global scope) is set to error state call.
//Results of RPC Call itself will be in RPCBrokerV
begin
  RPCBrokerV.Results.Clear;
  CallBroker;
  Result := BrokerErrorCheck(RPCResult);
end;

function TfrmLabEntry.GetComponentLabs(IEN : int64) : TStrings;
{Return a list of component labs for given IEN in LABORATORY file.
 E.g. if IEN points to CBC, then this function should return list of WBC, RBC, Hgb, etc.
   parts that make up the CBC panel}
//Output format: TStrings[#]=IEN^^Name^Storage
begin
  CallV('TMG CPRS GET LAB COMPONENTS', [IEN]);
  Result := RPCBrokerV.Results;
  if Result.Count>0 then Result.Delete(0);  //0'th entry is just number of results returned.
end;

function SubSetOfTests(const StartFrom: string; Direction: Integer): TStrings;
{ returns a pointer to a list of labs (for use in a long list box) -  The return value is
  a pointer to RPCBrokerV.Results, so the data must be used BEFORE the next broker call! }
begin
  CallV('TMG CPRS GET LAB LIST', [StartFrom, Direction]);
  Result := RPCBrokerV.Results;
end;

function FieldHelp(FileNum, IENS, FieldNum, HelpStyle : string) : string;
var
   RPCResult: string;
   ParamStr : string;
begin
  Result := '';
  ParamStr := FileNum + '^' + FieldNum + '^' + HelpStyle + '^' + IENS;
  CallV('TMG CPRS GET DD HELP', [ParamStr]);
  if RPCBrokerV.Results.Count > 0 then RPCBrokerV.Results.Delete(0);
  Result := RPCBrokerV.Results.Text;
  if Result = '' then Result := ' ';
  //Maybe later replace text with "Enter F1 for more help."
  Result := ReplaceText(Result,'Enter ''??'' for more help.','');
  while Result[Length(Result)] in [#10,#13] do begin
    Result := LeftStr(Result,Length(Result)-1);
  end;
end;


function TfrmLabEntry.PostLabData(LabData : TStringList) : Boolean;
var i : integer;
    RPCResult : string;
begin
  RPCBrokerV.remoteprocedure := 'TMG CPRS POST LAB VALUES';
  RPCBrokerV.Param[0].Value := '.X';  // not used
  RPCBrokerV.param[0].ptype := list;
  RPCBrokerV.Param[0].Mult.Sorted := false;
  for i := 0 to LabData.Count-1 do begin
    RPCBrokerV.Param[0].Mult[IntToStr(i)] := LabData.Strings[i];
  end;
  CallBrokerAndErrorCheck(RPCResult);
  Result := (Piece(RPCResult,'^',1)='1');
end;

procedure GetDefaultSpecimen(IEN60 : int64; var SpecimenName : string; var SpecimenIEN : int64);
Var ResultStr : string;
begin
  CallV('TMG CPRS LAB DEF SPECIMEN GET', [IEN60]);
  //Returns IEN61^Name, or  -1^ErrorMessage.
  ResultStr := '';
  if RPCBrokerV.Results.Count> 0 then begin
    ResultStr := RPCBrokerV.Results[0];
  end;
  SpecimenName := piece(ResultStr,'^',2);
  SpecimenIEN := StrToIntDef(piece(ResultStr,'^',1), 0);
  if SpecimenIEN = -1 then begin
    MessageDlg('Error: '+SpecimenName, mtError, [mbOK], 0);
    SpecimenName := 'BLOOD';
  end;
end;

procedure SetLabDefaultSpecimen(IEN60, IEN61 : int64);
Var ResultStr : string;
begin
  CallV('TMG CPRS LAB DEF SPECIMEN SET', [IEN60,IEN61]);
  //Returns 1^Success or  -1^ErrorMessage.
  ResultStr := '';
  if RPCBrokerV.Results.Count> 0 then ResultStr := RPCBrokerV.Results[0];
  if piece(ResultStr,'^',1)='-1' then begin
    MessageDlg('Error: ' + piece(Resultstr,'^',2), mtError, [mbOK], 0);
  end;
end;


//========================================================================
//========================================================================
//Code for Lab Selector (ORComboBox
//========================================================================
//========================================================================
procedure TfrmLabEntry.LabsORComboBoxDblClick(Sender: TObject);
begin
  btnAddLabClick(Sender);
end;

procedure TfrmLabEntry.LabsORComboBoxKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key=VK_RETURN then btnAddLabClick(Sender);
end;

procedure TfrmLabEntry.LabsORComboBoxNeedData(Sender: TObject;
                                                 const StartFrom: string;
                                                 Direction, InsertAt: Integer);
var
  TestList: TStringList;
begin
  TestList := TStringList.Create;
  try
    TestList.Assign(SubSetOfTests(StartFrom, Direction));
    LabsORComboBox.ForDataUse(TestList);
  finally
    TestList.Free;
  end;
end;

procedure TfrmLabEntry.btnRemoveLabClick(Sender: TObject);
var SelNode : TTreeNode;
begin
  SelNode := tvSelLabs.Selected;
  if SelNode = nil then exit;
  if MessageDlg('Remove Lab: ' + SelNode.Text, mtConfirmation,
                [mbOK,mbCancel], 0) = mrOK then begin
    RemoveSelLab(SelNode);
  end;
end;

procedure TfrmLabEntry.btnAddCommentsClick(Sender: TObject);
begin
  frmLabComments.memComments.Lines.Assign(LabComments);
  if frmLabComments.ShowModal = mrOK then begin
    LabComments.Assign(frmLabComments.memComments.Lines);
  end;
  if LabComments.Text <> '' then begin
    btnAddComments.Caption := 'Edit Lab &Comments';
  end else begin
    btnAddComments.Caption := 'Add Lab &Comments';
  end;
end;

procedure TfrmLabEntry.btnAddLabClick(Sender: TObject);
var SelIEN60 : int64; //64 bits.  NOTE pointer = 4 bytes = 32 bits = longword = 0..4,294,967,295
    Name, Store, DataInfo : string;
    ItemIdx : integer;
begin
  SelIEN60 := LabsORComboBox.ItemIEN;
  if SelIEN60 <= 0 then exit;
  ItemIdx := LabsORComboBox.ItemIndex;
  If ItemIdx < 0 then exit;
  DataInfo := LabsORComboBox.Items[ItemIdx];
  Name := piece(DataInfo, '^',3);
  if (Pos('{',Name)>0) and (Pos('}',Name)>0) then begin
    Name := piece(Name,'{',2);
    Name := piece(Name,'}',1);
  end;
  Store := piece(DataInfo, '^',4);
  AddToTV(nil, Name, SelIEN60, Store);
  LabsORComboBox.Text := '';
  LabsORComboBox.InitLongList('A');
end;

procedure TfrmLabEntry.btnCancelClick(Sender: TObject);
begin
  Self.ModalResult := mrCancel;
end;

//========================================================================
//========================================================================
//Code for TreeView of Labs Selected
//========================================================================
//========================================================================

procedure TfrmLabEntry.tvSelLabsChange(Sender: TObject; Node: TTreeNode);
var SelNode : TTreeNode;
    IEN : Int64;
    Row : integer;
begin
  SelNode := tvSelLabs.Selected;
  if SelNode = nil then exit;
  IEN := Int64(SelNode.Data);
  if IEN > 0 then begin
    Row := LabValuesRowForIEN(IEN);
    if Row > 0 then SelectRow(Row);
  end;
end;

procedure TfrmLabEntry.tvSelLabsEnter(Sender: TObject);
begin
  btnRemoveLab.Enabled := True;
end;

procedure TfrmLabEntry.tvSelLabsExit(Sender: TObject);
begin
  btnRemoveLab.Enabled := false;
end;

procedure TfrmLabEntry.tvSelLabsKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then btnRemoveLabClick(Sender);
end;

function TfrmLabEntry.AddToTV(Parent : TTreeNode; Name : string; IEN60 : int64;
                              Store : string; DisplayIndent : string = '') : TTreeNode;
var LabNode : tTreeNode;
    DataInfo : string;
    ChildList : TStringList;
    i : integer;
    Row : integer;
    IsPanel : boolean;
    RowTitle : string;
    TextW : integer;
    SpecimenName : string;
    SpecimenIEN : int64;
begin
  Result := nil;
  if IENAlreadyPresent(IEN60) then exit;
  ChildList := TStringList.Create;
  GetDefaultSpecimen(IEN60, SpecimenName, SpecimenIEN);
  if Assigned(Parent) then begin
    LabNode := tvSelLabs.Items.AddChild(Parent,Name);  //adds to root.
  end else begin
    LabNode := tvSelLabs.Items.Add(nil,Name);  //adds to root.
  end;
  LabNode.Data := Pointer(IEN60);  //NOTE: could cause problems if IEN > 4294967295 (32-bit pointer vs 64 bit IEN)
  Result := LabNode;
  IsPanel := (Store='');
  //Add labs into table.
  if not ((sgLabValues.RowCount=2) and (sgLabValues.Cells[0,1]='')) then begin
    sgLabValues.RowCount := sgLabValues.RowCount + 1;
  end;
  if IsPanel then name := name + ' ' + PANEL_NAME;
  Row := sgLabValues.RowCount - 1;
  RowTitle := DisplayIndent + Name;
  sgLabValues.Cells[0, Row] := RowTitle;
  TextW := sgLabValues.Canvas.TextWidth(RowTitle);
  if TextW > sgLabValues.ColWidths[0] then begin
    sgLabValues.ColWidths[0] := TextW + 5;
  end;
  sgLabValues.Objects[0, Row] := pointer(IEN60);
  sgLabValues.Cells[LAB_DATE_COL,Row] := DefaultDate;
  sgLabValues.Cells[LAB_SPEC_COL,Row] := SpecimenName;  //DefaultSpec;
  sgLabValues.Objects[LAB_SPEC_COL, Row] := pointer(SpecimenIEN);  //pointer(DefaultSpecIEN);
  if IsPanel then begin  //This happens when lab is a panel.  So need to then add child tests
    for i := VALUE_COL to REFHI_COL do begin
      sgLabValues.Cells[i, Row] := BLANK_LINES;
    end;
    ChildList.Assign(GetComponentLabs(IEN60));
    if assigned(ChildList) then for i := 0 to ChildList.Count-1 do begin
      DataInfo := ChildList.Strings[i];
      IEN60 := StrToIntDef(piece(DataInfo, '^',1),-1);
      if IEN60=-1 then continue;
      Name := piece(DataInfo, '^',3);
      Store := piece(DataInfo, '^',4);
      AddToTV(LabNode, Name, IEN60, Store, DisplayIndent + LAB_CHILD_SYMBOL);
    end;
    LabNode.Expand(True);
  end;
  ChildList.Free;
end;


function TfrmLabEntry.IENAlreadyPresent(IEN60 : int64) : boolean;
var i : integer;
begin
  Result := false;
  for i := 0 to tvSelLabs.Items.Count-1 do begin
    if Int64(tvSelLabs.Items[i].Data) = IEN60 then begin
      Result := true;
      break;
    end;
  end;
end;

procedure TfrmLabEntry.RemoveSelLab(SelLab : TTreeNode);
var IEN60 : Int64;
    Row : Integer;
    ChildLab : TTreeNode;
begin
  if not assigned(SelLab) then exit;
  if SelLab.HasChildren then begin  //First remove any children.
    ChildLab := SelLab.getFirstChild;
    while Assigned(ChildLab) do begin
      RemoveSelLab(ChildLab);  //Call self recursively
      ChildLab := SelLab.getFirstChild;
    end;
  end;
  IEN60 := Int64(SelLab.Data);
  if IEN60 > 0 then begin
    Row := LabValuesRowForIEN(IEN60);
    if Row > 0 then DeleteRow(Row);
  end;
  tvSelLabs.Items.Delete(SelLab);
end;


//========================================================================
//========================================================================
//Code for StringGrid LabValues
//========================================================================
//========================================================================
function TfrmLabEntry.LabValuesRowForIEN(IEN60 : int64) : integer;
var p : pointer;
    Row : integer;
begin
  Result := -1;
  p := pointer(IEN60);
  for Row := 1 to sgLabValues.RowCount-1 do begin
    if sgLabValues.Objects[0,Row] <> p then continue;
    Result := Row;
    Break;
  end;
end;

procedure TfrmLabEntry.DeleteRow(DelRow : integer);
var ARow,ACol,MaxRow : integer;
begin
  if DelRow < 1 then exit;
  MaxRow := sgLabValues.RowCount-1;
  for ARow := DelRow+1 to MaxRow do begin
    for ACol := 0 to sgLabValues.ColCount-1 do begin
      sgLabValues.Cells[ACol, ARow-1] := sgLabValues.Cells[ACol, ARow];
      sgLabValues.Objects[ACol, ARow-1] := sgLabValues.Objects[ACol, ARow];
    end;
  end;
  for ACol := 0 to sgLabValues.ColCount-1 do begin
    sgLabValues.Cells[ACol, MaxRow] := '';
    sgLabValues.Objects[ACol, MaxRow] := nil
  end;
  if sgLabValues.RowCount >2 then sgLabValues.RowCount := sgLabValues.RowCount-1;
end;

procedure TfrmLabEntry.SelectRow(Row : integer);
var Rect : TGridRect;
begin
  Rect.Left := 1;
  Rect.Top := Row;
  Rect.Right := sgLabValues.ColCount-1;
  Rect.Bottom := Row;
  RowMakeVisible(sgLabValues, Row);
  sgLabValues.Selection := Rect;
end;

procedure TfrmLabEntry.sgLabValuesDblClick(Sender: TObject);
var ACol, ARow: Integer;

begin
  ACol := sgLabValues.Col;
  ARow := sgLabValues.Row;
  if (ARow > 0) then begin
    if (ACol = LAB_DATE_COL) then begin
      EditDateCell(ACol, ARow);
    end else if (ACol = LAB_SPEC_COL) then begin
      EditSpecimenCell(ACol, ARow);
    end;
  end;
end;

procedure TfrmLabEntry.sgLabValuesKeyPress(Sender: TObject; var Key: Char);
var ACol, ARow: Integer;
begin
  ACol := sgLabValues.Col;
  ARow := sgLabValues.Row;
  if (Key = #13 ) then begin
    if (ACol = LAB_DATE_COL) and (ARow > 0) then begin
      EditDateCell(ACol, ARow);
    end else if (ACol = LAB_SPEC_COL) and (ARow > 0) then begin
      EditSpecimenCell(ACol, ARow);
    end;
  end;
end;

function TfrmLabEntry.IsPanelRow(ARow : integer) : boolean;
var PanelTitle: string;
begin
  PanelTitle := sgLabValues.Cells[0, ARow];
  Result := (Pos(PANEL_NAME, PanelTitle)>0);
end;

function TfrmLabEntry.IsChildRow(ARow : integer) : boolean;
var PanelTitle: string;
begin
  PanelTitle := sgLabValues.Cells[0, ARow];
  Result := (Pos(LAB_CHILD_SYMBOL, PanelTitle)>0);
end;

procedure TfrmLabEntry.StoreToPanelChildren(StartingRow, ACol : integer; Str : string; Obj : pointer=nil);
//StartingRow is the row of the panel title, NOT the row of the first child.
var i : integer;
begin
  for i:= StartingRow + 1 to sgLabValues.RowCount - 1 do begin
    if IsChildRow(i)= false then break;
    sgLabValues.Cells[ACol, i] := Str;
    sgLabValues.Objects[ACol, i] := Obj;
  end;
end;

procedure TfrmLabEntry.EditDateCell(ACol, ARow : integer);
var
  frmLabDateEdit: TfrmLabDateEdit;  //not-autocreated
  DateStr : string;
begin
  frmLabDateEdit := TfrmLabDateEdit.Create(Self);
  frmLabDateEdit.InitDate(sgLabValues.Cells[ACol, ARow]);
  if frmLabDateEdit.ShowModal = mrOK then begin
    DateStr := DateToStr(frmLabDateEdit.dtpDate.Date);
    sgLabValues.Cells[ACol, ARow] := DateStr;
    if IsPanelRow(ARow) then begin
      StoreToPanelChildren(ARow, ACol, DateStr, nil);
    end;
  end;
  frmLabDateEdit.Free;
end;

procedure TfrmLabEntry.EditSpecimenCell(ACol, ARow : integer);
var
  frmSpecimenEdit: TfrmSpecimenEdit;  //not auto-created
  IEN : integer;
  InitSpec, NewSpec : string;
  IEN61Ptr : pointer;
  LabIEN60 : int64;
  LabName : string;

begin
  frmSpecimenEdit := TfrmSpecimenEdit.Create(Self);
  InitSpec := sgLabValues.Cells[ACol, ARow];
  IEN := integer(sgLabValues.Objects[ACol, ARow]);
  frmSpecimenEdit.Initialize(InitSpec,IEN);
  if frmSpecimenEdit.ShowModal = mrOK then begin
    NewSpec := frmSpecimenEdit.SelectedSpecimen;
    sgLabValues.Cells[ACol, ARow] := NewSpec;
    IEN61Ptr := pointer(frmSpecimenEdit.SelectedIEN);
    sgLabValues.Objects[ACol, ARow] := IEN61Ptr;
    if IsPanelRow(ARow) then begin
      StoreToPanelChildren(ARow, ACol, NewSpec, IEN61Ptr);
    end;
    //Later, pick/create more appropriate key
    if User.HasKey('XUPROGMODE') then begin
      LabName := sgLabValues.Cells[0, ARow];
      LabIEN60 := Integer(sgLabValues.Objects[0, ARow]);
      if MessageDlg('Change default specimen for lab' + CRLF + LabName + CRLF +
                    'to ' + NewSpec + '?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
        SetLabDefaultSpecimen(LabIEN60, Int64(IEN61Ptr)); //this will change default for children too.
      end;
    end;
  end;
  frmSpecimenEdit.Free;
end;


procedure TfrmLabEntry.RowMakeVisible(AGrid: TStringGrid; ARow: integer);
//from here: http://www.delphipages.com/forum/showthread.php?t=183427
var
  iTopRow, visRows, lastRow : integer;
begin
  if (ARow > -1) and (ARow < AGrid.RowCount) then begin
    iTopRow := AGrid.TopRow;
    visRows := AGrid.VisibleRowCount;
    lastRow := iTopRow +visRows -1;
    if ARow < iTopRow then
      AGrid.TopRow := ARow
    else if ARow > lastRow then
      AGrid.TopRow := ARow -visRows;
  end;
end;

//========================================================================
//========================================================================
//Code for processing lab values
//========================================================================
//========================================================================

procedure TfrmLabEntry.GatherLabData(Data : TStringList);
var I, Row : integer;
    LabIEN60 : int64;
    LabName, LabValue, LabFlag, LabRefLo, LabRefHi : string;
    DateStr, SpecName,SpecIEN,Specimen : string;
    OneLine : string;
Const U = '^';
  function FMDTStr(DateStr : string) : string;
  var
    TempFMDT : TFMDateTime;
    Date : TDateTime;
  begin
    Date := StrToDate(DateStr);
    TempFMDT := DateTimeToFMDateTime(Date);
    Result := FloatToStr(TempFMDT);
  end;

begin
  Data.Clear;
  frmLabEntryDetails.GetDetailsEncoded(Data);
  Data.Add('<VALUES>');
  for Row := 1 to sgLabValues.RowCount-1 do begin
    LabName := sgLabValues.Cells[0, Row];
    if Pos(PANEL_NAME, LabName) > 0 then continue;
    LabIEN60 := Int64(sgLabValues.Objects[0, Row]);
    LabValue := Trim(sgLabValues.Cells[1, Row]);
    if LabValue = '' then continue;
    If Pos(BLANK_LINES,LabValue)>0 then continue;
    LabFlag := Trim(sgLabValues.Cells[2, Row]);
    LabRefLo := Trim(sgLabValues.Cells[3, Row]);
    if LabRefLo = '' then LabRefLo := '0';
    LabRefHi := Trim(sgLabValues.Cells[4, Row]);
    If LabRefHi = '' then LabRefHi := '0';
    DateStr := FMDTStr(Trim(sgLabValues.Cells[LAB_DATE_COL, Row]));
    SpecName := Trim(sgLabValues.Cells[LAB_SPEC_COL, Row]);
    SpecIEN := IntToStr(Integer(sgLabValues.Objects[LAB_SPEC_COL, Row]));
    Specimen := SpecName+'^'+SpecIEN;
    //Below is line defining contents of each ^ piece.
    OneLine := IntToStr(LabIEN60)+U+ LabValue+U+ LabFlag+U+ LabRefLo+U+
               LabRefHi+U + DateStr+U + Specimen+U;
    Data.Add(OneLine);
  end;
  Data.Add('<COMMENTS>');
  Data.Add('NOTICE: Lab values entered manually.  Typographical/human error possible.');
  Data.Add(' ');
  for i := 0 to LabComments.Count-1 do begin
    Data.Add(LabComments.Strings[i]);
  end;
end;




end.

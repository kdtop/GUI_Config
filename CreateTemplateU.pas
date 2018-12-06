unit CreateTemplateU;
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
  UtilU,
  Dialogs, StdCtrls, Buttons, Grids, ExtCtrls, rRPCsU;

type
  TCreateTemplateForm = class(TForm)
    BottomPanel: TPanel;
    TopPanel: TPanel;
    TemplateGrid: TStringGrid;
    btnCancel: TBitBtn;
    btnSave: TBitBtn;
    Label1: TLabel;
    btnOpen: TBitBtn;
    btnAddField: TBitBtn;
    cboAddField: TComboBox;
    cboRemoveField: TComboBox;
    btnDelField: TBitBtn;
    btnDone: TBitBtn;
    SaveDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    btnClear: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAddFieldClick(Sender: TObject);
    procedure btnDelFieldClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnDoneClick(Sender: TObject);
  private
    { Private declarations }
    BlankList : TStringList;
    RequiredList, FieldsList : TStringList;
    FFileNum : String;
    FModified : boolean;
    procedure LoadGrid(ReqList,FieldsList : TStringList);
    procedure PrepLists(BlankList,ReqList,FieldsList : TStringList);
    procedure LoadCombos(FieldsList : TStringList);
    procedure AddRow(oneEntry : string; Fixed : boolean);  
    function MakeOneEntry(fldName,fldNum : string) : string;
    procedure LoadTemplate(fileName : string);
    procedure ClearGrid;
    procedure ClearComboBoxes;
    procedure MoveAddListToDelList(oneEntry : string);
    function DoSaveClick : TModalResult;
  public
    { Public declarations }
    procedure PrepForm (FileNum : String);
    procedure GetNumName(oneEntry : string; var fldName,fldNum : string);
  end;

var
  CreateTemplateForm: TCreateTemplateForm;

implementation

{$R *.dfm}
  uses
    fMultiRecEditU, ORNet, ORFn, MainU, StrUtils;

  procedure TCreateTemplateForm.PrepForm (FileNum : String);
  begin
    FFileNum := FileNum;
    ClearComboBoxes;
    PrepLists(BlankList,RequiredList,FieldsList);
    LoadGrid(RequiredList,FieldsList);
    LoadCombos(FieldsList);
    FModified := false;
  end;


  procedure TCreateTemplateForm.ClearComboBoxes;
  begin;
    cboAddField.Items.Clear;
    cboAddField.Text := '';
    cboRemoveField.Items.Clear;    
    cboRemoveField.Text := '';
  end;

  
  procedure TCreateTemplateForm.PrepLists(BlankList,ReqList,FieldsList : TStringList);
  var i,j : integer;
      oneEntry : string;
      fldName,fldNum,fldCodes : string;
      tempS : string;
      reqField : boolean;
  begin
    if BlankList.Count=0 then begin
      GetBlankFileInfo(FFileNum, BlankList); //returns: FileNum^^FieldNum^^FieldName^More DDInfo
    end;  
    ReqList.Clear;
    FieldsList.Clear;

    //---- note: for now I am going to hard code the required fields in. ------        
    ReqList.Add('.01^');       //NAME
    ReqList.Add('.02^');       //SEX
    ReqList.Add('.03^');       //DOB
    ReqList.Add('.09^');       //SSN
    ReqList.Add('0^');         //A 'pseudoField', for use with Health Record number
    ReqList.Add('.301^^NO');  //SERVICE CONNECTED?  default should be NO
    ReqList.Add('391^^NON-VETERAN (OTHER)');  //TYPE  default should be NON-VETERAN (OTHER)
    ReqList.Add('994^^NO');   //MULTIPLE BIRTH INDICATOR default should be NO
    ReqList.Add('1901^^NO');  //VETERAN (Y/N)? default should be NO

    for i:= 0 to BlankList.Count-1 do begin
      oneEntry := BlankList.Strings[i];
      if oneEntry = '1^Success' then begin  //substitute status line with pseudoField, HRN
        oneEntry:='^^0^^Health Record Number (HRN)^F'
      end;
      fldName := piece(oneEntry,'^',5);
      fldNum := piece(oneEntry,'^',3);
      fldCodes := piece(oneEntry,'^',6);
      reqField := false;
      for j := 0 to ReqList.Count-1 do begin
        if Pos(fldNum+'^',ReqList.Strings[j])=1 then begin
          tempS := ReqList.Strings[j];
          SetPiece(tempS,'^',2,fldName);
          ReqList.Strings[j] := tempS;  
          reqField := true;
          break;
        end;
      end;
      if reqField then continue;
      if Pos('C',fldCodes)>0 then continue;  //computed
      if Pos('P',fldCodes)>0 then continue;  //pointer to file
      if IsSubFile(fldCodes,tempS) then continue;  //no subfiles (including WP fields)
      if Pos('I',fldCodes)>0 then continue;  //marked uneditable.
        
      FieldsList.Add(fldNum+'^'+fldName);
    end;
  end;
  
  procedure TCreateTemplateForm.LoadGrid(ReqList,FieldsList : TStringList);
  var i : integer;
      oneEntry : string;
  begin
    ClearGrid;
    for i := 0 to ReqList.Count-1 do begin
      oneEntry := ReqList.Strings[i];
      AddRow(oneEntry,true);  
    end;
  end;

  procedure TCreateTemplateForm.ClearGrid;
  begin
    TemplateGrid.FixedCols := 0;
    TemplateGrid.FixedRows := 1;
    TemplateGrid.RowCount := 2;
    TemplateGrid.Cells[0,0] := 'NAME:';
    TemplateGrid.Cells[1,0] := 'NUMBER:';
    TemplateGrid.Cells[2,0] := 'DEFAULT:';
    TemplateGrid.Cells[0,1] := '';
    TemplateGrid.Cells[1,1] := '';
    TemplateGrid.Cells[2,1] := '';
    TemplateGrid.ColWidths[0] := 300;
    TemplateGrid.ColWidths[1] := 100;
    TemplateGrid.ColWidths[0] := 300;
//    TemplateGrid
  end;  

  procedure TCreateTemplateForm.AddRow(oneEntry : string; Fixed : boolean);  
  //oneEntry format: fldNum^fldName
  //optional format: fldNum^fldName^DefaultValue
  var i,j : integer;
      fldName,fldNum : string;
      defaultValue : string;
  begin
    GetNumName(oneEntry,fldName,fldNum);    
    defaultValue := piece(oneEntry,'^',3);
    //Add : ensure row doesn't already exist;
    for j := 0 to TemplateGrid.RowCount-1 do begin
      if TemplateGrid.Cells[1,j] = fldNum then exit;
    end;
  
    i := TemplateGrid.RowCount-1;
    if TemplateGrid.Cells[0,i] <> '' then begin
      TemplateGrid.RowCount := TemplateGrid.RowCount + 1;
    end;
    i := TemplateGrid.RowCount-1;

    TemplateGrid.Cells[0,i] := fldName;      
    TemplateGrid.Cells[1,i] := fldNum;      
    TemplateGrid.Cells[2,i] := defaultValue;
  end;

  procedure TCreateTemplateForm.LoadCombos(FieldsList : TStringList);
  var i : integer;
      oneEntry : string;
      fldName,fldNum : string;
  begin
    cboAddField.Items.clear;
    for i := 0 to FieldsList.Count-1 do begin
      oneEntry := FieldsList.Strings[i];
      GetNumName(oneEntry,fldName,fldNum);    
      cboAddField.Items.Add(MakeOneEntry(fldName,fldNum));
    end;
    cboAddField.ItemIndex := 0;
  end;
  

  procedure TCreateTemplateForm.FormCreate(Sender: TObject);
  begin
    BlankList := TStringList.create;
    RequiredList := TStringList.create;
    FieldsList := TStringList.create;
    ClearGrid;
  end;

  procedure TCreateTemplateForm.FormDestroy(Sender: TObject);
  begin
    BlankList.Free;
    RequiredList.Free;
    FieldsList.Free;
  end;

  procedure TCreateTemplateForm.btnAddFieldClick(Sender: TObject);
  var i : integer;
      oneEntry,tempEntry : string;
      fldName,fldNum : string;
      exists: boolean;
  begin
    FModified := true;
    oneEntry := cboAddField.Text;
    if oneEntry = '' then exit;
    GetNumName(oneEntry,fldName,fldNum);    
    if (fldNum = '') or (fldName = '') then exit;
    tempEntry := fldNum + '^' + fldName;
    //Add : ensure row doesn't already exist;
    exists := false;
    for i := 0 to TemplateGrid.RowCount-1 do begin
      if TemplateGrid.Cells[1,i] = fldNum then begin
        exists := true;
        break;
      end;
    end;
    if not exists then begin
      AddRow(tempEntry,false);
      MoveAddListToDelList(tempEntry);
    end;  
  end;

  
  procedure TCreateTemplateForm.MoveAddListToDelList(oneEntry : string);
  //Move entry from Add list to delete list.
  var i : integer;
      fldName,fldNum : string;
      tempEntry : string;
  begin
    GetNumName(oneEntry,fldName,fldNum);    
    tempEntry := MakeOneEntry(fldName,fldNum);
    i := cboAddField.Items.IndexOf(tempEntry);
    if i > -1 then cboAddField.Items.Delete(i);
    if i < cboAddField.Items.Count then cboAddField.ItemIndex := i
    else cboAddField.ItemIndex := cboAddField.Items.Count-1;
    //if cboAddField.Items.Count > 0 then cboAddField.ItemIndex := 0 else cboAddField.ItemIndex := -1;
    
    cboRemoveField.Items.Add(tempEntry);
    cboRemoveField.ItemIndex := cboRemoveField.Items.Count - 1;
  end;

    
  procedure TCreateTemplateForm.GetNumName(oneEntry : string; var fldName,fldNum : string);
  begin
    if Pos('^',oneEntry)>0 then begin
      fldNum := piece(oneEntry,'^',1);
      fldName := piece(oneEntry,'^',2);
    end else begin
      fldNum := piece(oneEntry,'{',2);
      fldNum := piece(fldNum,'}',1);
      fldName := piece(oneEntry,'{',1);
      fldName := Trim(fldName);
    end;  
  end;

  function TCreateTemplateForm.MakeOneEntry(fldName,fldNum : string) : string;
  begin
    result := fldName+' {'+fldNum+'}';
  end;
    
  procedure TCreateTemplateForm.btnDelFieldClick(Sender: TObject);
  var
    i : integer; 
    oneEntry : string;
    fldName,fldNum : string;
    delRow : integer;
  begin
    oneEntry := cboRemoveField.Text;
    GetNumName(oneEntry,fldName,fldNum);    
    if fldNum = '' then exit;
    delRow := -1;
    for i := 1 to TemplateGrid.RowCount-1 do begin
      if TemplateGrid.Cells[1,i] = fldNum then begin
        delRow := i;
        break;
      end;
    end;
    if delRow = -1 then exit;
    i := cboRemoveField.Items.IndexOf(oneEntry);
    if i > -1 then cboRemoveField.Items.Delete(i);
    cboRemoveField.ItemIndex := cboRemoveField.Items.Count - 1;
    cboAddField.Items.Insert(0,oneEntry);
    cboAddField.ItemIndex := 0;
    for i := delRow to TemplateGrid.RowCount-2 do begin
      TemplateGrid.Cells[0,i] := TemplateGrid.Cells[0,i+1];
      TemplateGrid.Cells[1,i] := TemplateGrid.Cells[1,i+1];
    end;
    TemplateGrid.RowCount := TemplateGrid.RowCount -1;
  end;

  procedure TCreateTemplateForm.btnSaveClick(Sender: TObject);
  begin
    DoSaveClick;
    MessageDlg('You have created an empty registration Template.'+#10+#13+
               'Now you should EDIT IT with your favorite spreadsheet '+#10+#13+
               'application (such as Microsoft Excel, or Open Office,) '+#10+#13+
               'filling it with patient demographic data.'+#10+#13+
               #10+#13+
               'Hint #1: try just a few patients initially, to make sure'+#10+#13+
               '  that all is working properly.  Built in safeguards will'+#10+#13+
               '  prevent duplicate registrations on subsequent runs.'+#10+#13+
               #10+#13 {+
               'Hint #2: Open Office tends to format the field number (e.g. ".01")'+#10+#13+
               '  as a decimal, and converts it to '0.01'.  This will prevent'+#10+#13+
               '  successful upload.  In general field numbers do NOT have a "0"'+#10+#13+
               '  before a decimal (".")'
               }
               ,mtInformation,[mbOK],0); 
  end;
  
  function TCreateTemplateForm.DoSaveClick : TModalResult;
  var TemplateLines : TStringList;
      row : integer;
      Line1,Line2,SampleLine : string;
  begin
    Line1 := 'Field NAME:';
    Line2 := 'Field NUMBER:';
    SampleLine := 'Put a patient''s data on this row -->';
    If SaveDialog.Execute then begin
      TemplateLines := TStringList.Create;
      for row := 1 to TemplateGrid.RowCount-2 do begin
        Line1 := Line1 + #9 + '"' + TemplateGrid.Cells[0,row] + '"';
        Line2 := Line2 + #9 + '"<'+TemplateGrid.Cells[1,row]+'>"';
        SampleLine := SampleLine + #9 + '"' + TemplateGrid.Cells[2,row] + '"';
      end;
      TemplateLines.Add(Line1);
      TemplateLines.Add(Line2);
      TemplateLines.Add(SampleLine);
      TemplateLines.Add(SampleLine);
      TemplateLines.Add(SampleLine);
      TemplateLines.Add('etc... (As many rows as needed)');
      TemplateLines.Add(' ');
      TemplateLines.Add('When done, save file and import with');
      TemplateLines.Add('  the WorldVista Config Utility.');
      TemplateLines.Add('Save in CSV format, using TAB as field');
      TemplateLines.Add(' delimiter, and " as text delimiter.');
      TemplateLines.SaveToFile(SaveDialog.FileName);
      TemplateLines.Free;
      Result := mrOK;
      FModified := false;
    end else begin
      Result := mrCancel;
    end;
  end;

  procedure TCreateTemplateForm.btnOpenClick(Sender: TObject);
  begin
    if OpenDialog.Execute then begin
      LoadTemplate(OpenDialog.FileName);
    end;
  end;

  procedure TCreateTemplateForm.LoadTemplate(fileName : string);
  var Lines: TStringList;
      Line1List,Line2List : TStringList;
      oneLine : string;
      i : integer;
      fldName,fldNum : string;
      oneEntry : string;
  begin
    Lines := TStringList.Create;
    Line1List := TStringList.Create;
    Line2List := TStringList.Create;
    Lines.LoadFromFile(fileName);
    if Lines.Count < 2 then begin
      MessageDlg('Template file has less than 2 lines.'+#10+#13+
                 'Doesn''t appear to be valid template.', mtError,[mbOK],0);
      exit;           
    end;
    ClearGrid;    
    oneLine := Lines.Strings[0];
    PiecesToList(oneLine, #9, Line1List);
    oneLine := Lines.Strings[1];
    PiecesToList(oneLine, #9, Line2List);
    for i := 1 to Line1List.Count-1 do begin
      fldName := Line1List.Strings[i];
      if i < Line2List.Count then begin
        fldNum := Line2List.Strings[i];      
        fldNum := AnsiReplaceStr(fldNum,'"<','');
        fldNum := AnsiReplaceStr(fldNum,'>"','');
      end else begin
        fldNum := '??';
      end;
      oneEntry := fldNum+'^'+fldName;
      AddRow(oneEntry,false);      
      MoveAddListToDelList(oneEntry);
    end;    
    Lines.Free;
    Line1List.Free;
    Line2List.Free;
  end;
  
  procedure TCreateTemplateForm.btnClearClick(Sender: TObject);
  begin
    //add confirmation box.
    if MessageDlg('Erase All Current Fields?',mtConfirmation,mbOKCancel,0) = mrOK then begin
      PrepForm (FFileNum);
    end;  
  end;

  procedure TCreateTemplateForm.btnDoneClick(Sender: TObject);
  var tempModal : TModalResult;
  begin
    if FModified then begin
      tempModal := MessageDlg('Save Template Before Leaving?',mtConfirmation,mbYesNoCancel,0);
    end else begin
      tempModal := mrNo;
    end;
    case tempModal of
      mrYes  : begin
                 tempModal := DoSaveClick;
                 if tempModal = mrOK then ModalResult := mrOK;
                 //if tempModal = mrCancel, then do nothing.
               end;                   
      mrNo   : ModalResult := mrOK;
      mrCancel : // do nothing.
    end; {case}  
  end;

end.


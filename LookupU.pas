unit LookupU;
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
  rRPCsU,
  Dialogs, StdCtrls, ORCtrls, Buttons;

type
  TFieldLookupForm = class(TForm)
    ORComboBox: TORComboBox;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    btnAdd: TBitBtn;
    cboSourceFile: TComboBox;
    lblSourceFile: TLabel;
    btnNone: TButton;
    EditBtn: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure EditBtnClick(Sender: TObject);
    procedure ORComboBoxNeedData(Sender: TObject; const StartFrom: String;
      Direction, InsertAt: Integer);
    procedure FormShow(Sender: TObject);
    procedure ORComboBoxDblClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure cboSourceFileChange(Sender: TObject);
    procedure btnNoneClick(Sender: TObject);
  private
    { Private declarations }
    FFileNum : String;
    FChangesMade : boolean;

    //File containing field, that is a pointer we are looking up options for.
    FContainingFileNum, FContainingFieldNum : string;

    cboSourceFileInitValue : string;
    procedure InitORBox(FileNum,InitValue : string);
    procedure SetMultiFileEnable(Enabled : boolean);
  public
    { Public declarations }
    //procedure InitORComboBox(ORComboBox: TORComboBox; initValue : string);
    Auto_Press_Edit_Button : boolean;
    Suppress_Positioning_Form_To_Mouse : boolean;
    procedure PrepForm(FileNum,InitValue, ContainingFileNum, ContainingFieldNum : string);
    function SelectedValue : string;
    procedure PrepFormAsMultFile(VarPtrInfo : TStringList; InitValue : string;
                                 ContainingFileNum, ContainingFieldNum : string);
    property ChangesMade : boolean read FChangesMade;  //Signal that data was changed somehow.
  end;

//var
  // FieldLookupForm: TFieldLookupForm;


implementation

uses
  ORNet, ORFn, AddOneFileEntryU, Trpcb,   //needed for .ptype types
  fOneRecEditU, MainU;

{$R *.dfm}


  procedure TFieldLookupForm.ORComboBoxNeedData(Sender: TObject;
                                                const StartFrom: String;
                                                Direction, InsertAt: Integer);
  var
    Result : TStrings;
    Screen : string;
  begin
    Screen := '[FROM ' + FContainingFileNum + ':' + FContainingFieldNum + ']';
    Result := SubSetOfFile(FFileNum, StartFrom, Direction, Screen);
    TORComboBox(Sender).ForDataUse(Result);
  end;

  procedure TFieldLookupForm.InitORBox(FileNum,InitValue : string);
  begin
    if FileNum = '9000001' then begin
      FileNum := '2';  //There is always a 1:1 relationship between these two files.  Pointers are identical
    end;
    FFileNum := FileNum;
    Self.Caption := 'Pick Entry from File # ' + FileNum;
    if (FileNum='200') and (InitValue='') then begin
      InitValue := MainForm.CurrentUserName;
    end;
    MainForm.InitORComboBox(ORComboBox,InitValue);
  end;

  procedure TFieldLookupForm.SetMultiFileEnable(Enabled : boolean);
  begin
    lblSourceFile.Enabled := Enabled;
    cboSourceFile.Enabled := Enabled;
  end;

  procedure TFieldLookupForm.PrepForm(FileNum,InitValue, ContainingFileNum, ContainingFieldNum : string);
  begin
    FContainingFileNum := ContainingFileNum;
    FContainingFieldNum := ContainingFieldNum;
    Auto_Press_Edit_Button := false;
    InitORBox(FileNum,InitValue);
    SetMultiFileEnable(false);
    Auto_Press_Edit_Button := false;
    FChangesMade := false;
  end;

  procedure TFieldLookupForm.PrepFormAsMultFile(VarPtrInfo : TStringList; InitValue : string;
                                                ContainingFileNum, ContainingFieldNum : string);
  var i, NumP : integer;
      AddedNum : integer;
      InitValIndex : integer;
      InitValPrefix, Prefix, FileNum, s, oneEntry : string;
  begin
    FContainingFileNum := ContainingFileNum;
    FContainingFieldNum := ContainingFieldNum;
    cboSourceFileInitValue := 'A';
    InitValPrefix := piece(InitValue,'.',1);
    NumP := NumPieces(InitValue,'.');
    if NumP > 1 then begin
      InitValue := pieces(InitValue,'.',2,NumP);
      cboSourceFileInitValue := InitValue;
    end;
    InitValIndex := -1;
    cboSourceFile.Items.Clear;
    for i := 0 to VarPtrInfo.Count-1 do begin
      s := VarPtrInfo.Strings[i];
      FileNum := piece(s,'^',2);
      Prefix := piece(s,'^',4);
      oneEntry := Prefix +'. ' + piece(s,'^',3) + ' (#'+FileNum+')';
      AddedNum := cboSourceFile.Items.Add(oneEntry);
      if Prefix = InitValPrefix then InitValIndex := AddedNum;
    end;
    if cboSourceFile.Items.Count > 0 then begin
      if InitValIndex = -1 then InitValIndex := 0;
      cboSourceFile.Text := cboSourceFile.Items.Strings[InitValIndex];
    end else begin
      cboSourceFile.Text := '';
    end;
    cboSourceFileChange(self);
    SetMultiFileEnable(true);
    Auto_Press_Edit_Button := false;
  end;

  procedure TFieldLookupForm.cboSourceFileChange(Sender: TObject);
  var s, Filenum : string;
  begin
    s := cboSourceFile.Text;
    FileNum := piece(piece(s,'(#', 2), ')',1);
    InitORBox(FileNum,cboSourceFileInitValue); //stores Filenum into FFilenum
  end;

  procedure TFieldLookupForm.EditBtnClick(Sender: TObject);
  var
    IEN : LongInt;
    IENS : string;
  begin
    if ORComboBox.ItemIndex < 0 then begin
      MessageDlg('Please select item first', mtWarning, [mbOK], 0);
      exit;
    end;
    IEN := ORComboBox.ItemID;  //get info from selected record
    if IEN=0 then exit;
    IENS := IntToStr(IEN) + ',';
    EditOneRecordModal(FFileNum, IENS);
  end;

function TFieldLookupForm.SelectedValue : string;
  var prefix : string;
  begin
    Result := ORComboBox.Text;
    if (Result <> '') and cboSourceFile.Enabled then begin
      prefix := piece(cboSourceFile.Text,' ',1);
      Result := prefix + Result;
    end;
  end;

  procedure TFieldLookupForm.FormCreate(Sender: TObject);
  begin
  Suppress_Positioning_Form_To_Mouse := false;
  end;

  procedure TFieldLookupForm.FormShow(Sender: TObject);
    var mousePos : TPoint;
  begin
    if not Suppress_Positioning_Form_To_Mouse then begin
      GetCursorPos(mousePos);
      Top := mousePos.Y - ORComboBox.Top; //39;
      Left := mousePos.X - ORComboBox.left - ORComboBox.Width; //15;
      if Left + Width > Screen.DesktopWidth then begin
        Left := Screen.DesktopWidth - Width;
      end;
    end;
    ORComboBox.SetFocus;
    if Auto_Press_Edit_Button then begin
      EditBtnClick(Self);
      Auto_Press_Edit_Button := false;
      ModalResult := mrCancel;  //auto cancel (close) after auto edit.
      PostMessage(Self.Handle, WM_CLOSE, 0,0);
    end;

  end;


procedure TFieldLookupForm.ORComboBoxDblClick(Sender: TObject);
begin
  Modalresult := mrOK;  //Close form, item should be selected (?)
end;

procedure TFieldLookupForm.btnAddClick(Sender: TObject);
var  AddOneFileEntry: TAddOneFileEntry;
begin
  AddOneFileEntry := TAddOneFileEntry.Create(Self);
  AddOneFileEntry.PrepForm(FFileNum);
  AddOneFileEntry.ShowModal;
  FChangesMade := FChangesMade or AddOneFileEntry.ChangesMade;
  if AddOneFileEntry.NewRecordName <> '' then begin
    MainForm.InitORComboBox(ORComboBox,AddOneFileEntry.NewRecordName);
  end;
  AddOneFileEntry.Free;
end;


procedure TFieldLookupForm.btnNoneClick(Sender: TObject);
begin
  ORComboBox.Text := '';
  Self.ModalResult := mrOK;
end;

end.


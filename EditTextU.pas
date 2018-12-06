unit EditTextU;
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
  Dialogs, StdCtrls, Buttons, ExtCtrls, StrUtils, TypesU, rRPCsU;

type
  TEditWPTextForm = class(TForm)
    Panel1: TPanel;
    Memo: TMemo;
    RevertBtn: TBitBtn;
    ApplyBtn: TBitBtn;
    DoneBtn: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RevertBtnClick(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
    procedure DoneBtnClick(Sender: TObject);
    procedure MemoChange(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FCachedText : TStringList;
    FFileNum,FFieldNum,FIENS : String;
    FPosted : boolean;
    FChangesMade : boolean;
    function GetWPField(FileNum,FieldNum,IENS : string) : TStringList;
    procedure PostWPField(Lines: TStrings; FileNum,FieldNum,IENS : string);
  public
    { Public declarations }
    procedure PrepForm(FileNum,FieldNum,IENS : string);
    function GetPreviewText : string;
    property Posted : boolean read FPosted;
    property ChangesMade : boolean read FChangesMade;
  end;

//var
//  EditWPTextForm: TEditWPTextForm;

implementation

uses FMErrorU, ORNet, ORFn, MainU,
     Trpcb ;  //needed for .ptype types

{$R *.dfm}

  procedure TEditWPTextForm.PrepForm(FileNum,FieldNum,IENS : string);
  begin
    FFileNum := FileNum;
    FFieldNum := FieldNum;
    FIENS := IENS;
    Memo.Lines.Clear;
    if Pos('+',IENS)=0 then begin
      Memo.Lines.Assign(GetWPField(FileNum,FieldNum,IENS));
    end;
    ApplyBtn.Enabled := false;
    RevertBtn.Enabled := false;
    FChangesMade := False;
  end;

  procedure TEditWPTextForm.FormCreate(Sender: TObject);
  begin
    FCachedText := TStringList.Create;

  end;

  procedure TEditWPTextForm.FormDestroy(Sender: TObject);
  begin
    FCachedText.Free;
  end;

  function TEditWPTextForm.GetPreviewText : string;
  begin
    PrepForm(FFileNum,FFieldNum,FIENS);
    Result := Memo.Lines.Text;
    Result := Trim(Result);
    Result := AnsiReplaceStr(Result, #10, '');
    Result := AnsiReplaceStr(Result, #13, '');
    if Result <> '' then begin
      Result := CLICK_TO_EDIT_TEXT + ':  ' + LeftStr(Result,20) + '...'
    end else begin
      Result := CLICK_TO_ADD_TEXT;
    end;
  end;



  function TEditWPTextForm.GetWPField(FileNum,FieldNum,IENS : string) : TStringList;
  var   RPCResult: string;
        cmd : string;
        lastLine : string;
  begin
    FCachedText.clear;
    rRPCsU.GetWPField(FileNum, FieldNum, IENS, FCachedText);
    result := FCachedText;
  end;


  procedure TEditWPTextForm.PostWPField(Lines: TStrings; FileNum,FieldNum,IENS : string);
  var   RPCResult: string;
        cmd : string;
        i : integer;
  begin
    if rRPCsU.PostWPField(Lines, FileNum,FieldNum,IENS) then begin
      FCachedText.Assign(Lines);
      FPosted := true;
      FChangesMade := True;
    end;
  end;


  procedure TEditWPTextForm.RevertBtnClick(Sender: TObject);
  begin
    if MessageDlg('Abort editing changes and revert to original?',mtWarning,mbOKCancel,0) = mrOK then begin
      Memo.Lines.Assign(FCachedText);
    end;
  end;

  procedure TEditWPTextForm.ApplyBtnClick(Sender: TObject);
  begin
    if FCachedText.Text <> Memo.Lines.Text then begin
      PostWPField(Memo.Lines,FFileNum,FFieldNum,FIENS);
    end;
    ApplyBtn.Enabled := false;
    RevertBtn.Enabled := false;
  end;

  procedure TEditWPTextForm.DoneBtnClick(Sender: TObject);
  begin
    ApplyBtnClick(self);
    ModalResult := mrOK;
  end;

  procedure TEditWPTextForm.MemoChange(Sender: TObject);
  begin
    ApplyBtn.Enabled := true;
    RevertBtn.Enabled := true;
  end;

  procedure TEditWPTextForm.FormHide(Sender: TObject);
  begin
    ApplyBtnClick(self);
  end;

  procedure TEditWPTextForm.FormClose(Sender: TObject; var Action: TCloseAction);
  begin
    ApplyBtnClick(self);
  end;

  procedure TEditWPTextForm.FormShow(Sender: TObject);
  begin
    FPosted := false;
    Memo.SetFocus;
  end;

end.


unit PostU;
(* WorldVistA Configuration Utility
   (c) 8/2008.  Released under LGPL
   Programmed by Kevin Toppenberg, Eddie Hagood  *)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ExtCtrls, rRPCsU;

type
  TPostForm = class(TForm)
    Panel1: TPanel;
    Grid: TStringGrid;
    CancelBtn: TBitBtn;
    PostBtn: TBitBtn;
    procedure PostBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FChanges : TStringList;
    procedure LoadGrid(Changes : TStringList);
  public
    { Public declarations }
    PostResults : TStringList;
    NewValue01 : string;
    FPosted : boolean;
    procedure PrepForm(Changes : TStringList);
    function SilentPost(Changes : TStringList) : TModalResult;
    function GetNewIENS(oldIENS: string) : string;
    property Posted : boolean read FPosted;
  end;

var
  PostForm: TPostForm;

implementation

{$R *.dfm}
uses
  ORNet, ORFn, ORCtrls,
  Trpcb, // needed for .ptype types
  FMErrorU, StrUtils;

  procedure TPostForm.PrepForm(Changes : TStringList);
  begin
    FChanges.Clear;
    FChanges.Assign(Changes);
    LoadGrid(Changes);
  end;

  procedure TPostForm.LoadGrid(Changes : TStringList);
  //Changes format:
  // FileNum^IENS^FieldNum^FieldName^newValue^oldValue

  var  i : integer;
       oneEntry : String;
       fieldNum,
       newValue : string;
  begin
    Grid.Cells[0,0] := 'File #';
    Grid.ColWidths[0] := 35;

    Grid.Cells[1,0] := 'Rec #';
    Grid.ColWidths[1] := 35;

    Grid.Cells[2,0] := 'Field';
    Grid.ColWidths[2] := 125;

    Grid.Cells[3,0] := 'Prior Value';
    Grid.ColWidths[3] := 250;
    
    Grid.Cells[4,0] := 'New Value';
    Grid.ColWidths[4] := 250;

    NewValue01 := '';  //default to no change;

    Grid.RowCount := Changes.Count+1;  
    for i := 0 to Changes.Count-1 do begin
      oneEntry := Changes.Strings[i];
      fieldNum := Piece(OneEntry,'^',4);
      newValue := Piece(OneEntry,'^',5);
      Grid.Cells[0,i+1] := Piece(OneEntry,'^',1); //File Num
      Grid.Cells[1,i+1] := Piece(OneEntry,'^',2); //IENS
      Grid.Cells[2,i+1] := fieldNum; //Field
      Grid.Cells[3,i+1] := Piece(OneEntry,'^',6); //Old Value
      Grid.Cells[4,i+1] := newValue; //New Value
      if fieldNum = '.01' then begin
        NewValue01 := newValue;
      end;
    end;
  end;

  procedure TPostForm.PostBtnClick(Sender: TObject);
  //var  RPCResult : string;
  //     i : integer;
  begin
    if rRPCsU.PostChanges(FChanges) = true then begin
      PostResults.Assign(RPCBrokerV.Results);
      FPosted := true;
    end else begin
      ModalResult := mrNO;  //signal error.
    end;
  end;  //form will close here because of modalresult set for button

  function TPostForm.GetNewIENS(oldIENS: string) : string;
  //If posted data had IENS of +1 (or +5 etc) then there should be returned
  //a new, actual, IENS in the database.  This should be stored in PostResults
  //in format of 4^1234, 2,4567 etc, for +4 --> converted to 1234, and +2 -->
  //converted to 4567 etc.
  //So this function will take input of +4, and return for example, 1234
  //Or return '' if no match found.
  var i : integer;
  begin
    result := '';
    if Pos('+',oldIENS)=1 then begin
      oldIENS := MidStr(oldIENS,2,999);
    end;
    if Pos(',',oldIENS)=length(oldIENS) then begin
      oldIENS := MidStr(oldIENS,1,length(oldIENS)-1);
    end;
    for i := 0 to PostResults.Count-1 do begin
      if piece(PostResults.Strings[i],'^',1)=oldIENS then begin
        result := piece(PostResults.Strings[i],'^',2);
        if result = 'Success' then result := '';
      end;
    end;
  end;
  
  
  procedure TPostForm.FormCreate(Sender: TObject);
  begin
    FChanges := TStringList.Create;
    PostResults := TStringList.Create;
  end;

  procedure TPostForm.FormDestroy(Sender: TObject);
  begin
    FChanges.Free;
    PostResults.Free;
  end;

  function TPostForm.SilentPost(Changes : TStringList) : TModalResult;
  begin
    FChanges.Clear;
    FChanges.Assign(Changes);
    PostBtnClick(self);
    result := mrOK;  //maybe later vary if there was a FM error...
  end;
 
  procedure TPostForm.CancelBtnClick(Sender: TObject);
  begin
    NewValue01 := '';
  end;

  procedure TPostForm.FormShow(Sender: TObject);
  begin
    FPosted := false;
  end;

end.


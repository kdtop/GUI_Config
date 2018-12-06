unit uSrchHelper;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ORCtrls;

type
  TSrchScreenProc = procedure(SL : TStringList) of object;

  TSrchHelper = class(TObject)
  private
    { Private declarations }
    FileNum : string;
    Timer : TTimer;
    Owner : TComponent;
    //CBO : TComboBox;
    LB : TListBox;
    EDT : TEdit;
    RawSearchResults : TStringList;
    LastSearch : string;
    procedure HandleTimer(Sender: TObject);
    procedure HandleEDTChange(Sender: TObject);
    procedure HandleLBDblClick(Sender: TObject);
    procedure HandleLBClick(Sender: TObject);
    procedure HandleEDTEnter(Sender: TObject);
    procedure LoadLB;
    procedure FireSelChange;
  public
    { Public declarations }
    SelectedIEN : string;
    SelectedName : string;
    SelectedRawData : string;
    OnSelectedChange : TNotifyEvent;
    ServerCustomizerFn : string;
    OnScreenResults : TSrchScreenProc;
    procedure InitEditBox;
    procedure RefreshSearch;
    function SelectIfExactMatch(Value : string) : boolean;
    procedure Initialize(AnEditBox : TEdit; AListBox : TListBox; FileNumber : string);
    constructor Create(AOwner : TComponent);
    destructor Destroy;
  end;


implementation
  uses rHL7RPCsU, ORNet, ORFn;

const
  INIT_TEXT = '<Type one or more search terms here, separated by spaces>';

  constructor TSrchHelper.Create(AOwner : TComponent);
  begin
    Inherited Create;
    Owner := AOwner;
    Timer := TTimer.Create(Owner);
    Timer.Enabled := false;
    Timer.OnTimer := HandleTimer;
    OnSelectedChange := nil;
    OnScreenResults := nil;
    RawSearchResults := TStringList.Create;
  end;

  destructor TSrchHelper.Destroy;
  begin
    FreeAndNil(Timer);
    RawSearchResults.Free;
  end;

  procedure TSrchHelper.HandleTimer(Sender: TObject);
  begin
    //Search on server for results
    Timer.Enabled := False;
    if EDT.Text = LastSearch then exit;
    SearchRecs(FileNum, EDT.Text, RawSearchResults, ServerCustomizerFn);
    if Assigned(OnScreenResults) then OnScreenResults(RawSearchResults);  //Allow subscriber to alter search results
    LoadLB;
    LastSearch := EDT.Text;
  end;

  procedure TSrchHelper.RefreshSearch;
  begin
    Timer.Enabled := true;
    Timer.Interval := 1;  //1 ms, i.e. NOW
  end;

  procedure TSrchHelper.LoadLB;
  //put Self.RawSrearchResults into CBO
  var i, Count : integer;
      AName : string;
  begin
    LB.Items.Clear;
    LB.ItemIndex := -1;
    SelectedIEN := '';
    SelectedName := '';
    SelectedRawData := '';
    Count := 0;
    for i := 0 to RawSearchResults.Count - 1 do begin
      AName := piece(RawSearchResults.Strings[i], '^', 3);
      LB.Items.Add(AName);
      Inc(Count);
    end;
    if Count=1 then LB.ItemIndex := 0;
    FireSelChange;
  end;


  procedure TSrchHelper.Initialize(AnEditBox : TEdit; AListBox : TListBox; FileNumber : string);
  begin
    FileNum := FileNumber;
    if not assigned(AnEditBox) then exit;
    if not assigned(AListBox) then exit;
    EDT := AnEditBox;
    LB := AListBox;
    EDT.OnChange := Self.HandleEDTChange;
    LB.OnDblClick := Self.HandleLBDblClick;
    LB.OnClick := Self.HandleLBClick;
    InitEditBox;
    SelectedIEN := '';
    SelectedName := '';
    SelectedRawData := '';
    ServerCustomizerFn := '';
  end;

  procedure TSrchHelper.InitEditBox;
  begin
    EDT.OnEnter := Self.HandleEDTEnter;
    EDT.Text := INIT_TEXT;
    EDT.Font.Color := clGray;
  end;

  procedure TSrchHelper.HandleEDTEnter(Sender: TObject);
  begin
    if EDT.Text = INIT_TEXT then begin
      EDT.Text := '';
      EDT.Font.Color := clBlack;
    end;
  end;

  procedure TSrchHelper.HandleEDTChange(Sender: TObject);
  //Action occurs immediately after the user edits the text in the edit
  //  region or selects an item from the list. The Text property gives the
  //  new value in the edit region.
  begin
    Timer.Enabled := true;
    Timer.Interval := 400;  //400 ms
  end;

  procedure TSrchHelper.FireSelChange;
  var RawStr : string;
  begin
    if (LB.ItemIndex > (RawSearchResults.count-1)) or (LB.ItemIndex = -1) then begin
      SelectedIEN := '';
      SelectedName := '';
      SelectedRawData := '';
    end else begin
      RawStr := RawSearchResults.Strings[LB.ItemIndex];
      SelectedIEN := piece(RawStr,'^',1);
      SelectedName := piece(RawStr,'^',3);
      SelectedRawData := RawStr;
    end;
    if assigned(OnSelectedChange) then begin
      OnSelectedChange(Self);
    end;
  end;


  procedure TSrchHelper.HandleLBDblClick(Sender: TObject);
  begin
    FireSelChange;
  end;

  procedure TSrchHelper.HandleLBClick(Sender: TObject);
  begin
    FireSelChange;
  end;

  function TSrchHelper.SelectIfExactMatch(Value : string) : boolean;
  //If exact match found, then select it.
  //NOTE: search is NOT case specific.
  var i : integer;
  begin
    Result := false;
    Value := UpperCase(Value);
    for i := 0 to LB.Items.Count - 1 do begin
      if UpperCase(LB.Items.Strings[i]) <> Value then continue;
      LB.ItemIndex := i;
      Result := true;
      FireSelChange;
      break;
    end;
  end;




end.


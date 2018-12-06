unit fEncnt;

//Modifed: 7/26/99
//By: Robert Bott
//Location: ISL
//Description of Mod:
//  Moved asignment of historical visit category from the cboNewVisitChange event
//   to the ckbHistoricalClick event.


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ORCtrls, ORDtTm, ORFn, ExtCtrls, ComCtrls, ORDtTmRng, fAutoSz{, rOptions};

type
  TfrmEncounter = class(TForm)
    cboPtProvider: TORComboBox;
    lblProvider: TLabel;
    cmdOK: TButton;
    cmdCancel: TButton;
    lblLocation: TLabel;
    txtLocation: TCaptionEdit;
    pgeVisit: TPageControl;
    tabClinic: TTabSheet;
    lblClinic: TLabel;
    lblDateRange: TLabel;
    lstClinic: TORListBox;
    tabAdmit: TTabSheet;
    lblAdmit: TLabel;
    lstAdmit: TORListBox;
    tabNewVisit: TTabSheet;
    lblVisitDate: TLabel;
    lblNewVisit: TLabel;
    calVisitDate: TORDateBox;
    ckbHistorical: TORCheckBox;
    cboNewVisit: TORComboBox;
    dlgDateRange: TORDateRangeDlg;
    cmdDateRange: TButton;
    lblInstruct: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure pgeVisitChange(Sender: TObject);
    procedure cmdOKClick(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
    procedure cboNewVisitNeedData(Sender: TObject; const StartFrom: String;
      Direction, InsertAt: Integer);
    procedure lstClinicClick(Sender: TObject);
    procedure calVisitDateChange(Sender: TObject);
    procedure cboNewVisitChange(Sender: TObject);
    procedure calVisitDateExit(Sender: TObject);
    procedure lstAdmitClick(Sender: TObject);
    procedure cboPtProviderNeedData(Sender: TObject;
      const StartFrom: String; Direction, InsertAt: Integer);
    procedure ckbHistoricalClick(Sender: TObject);
    procedure cmdDateRangeClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FFilter: Int64;
    FPCDate: TFMDateTime;
    FProvider: Int64;
    FLocation: Integer;
    FLocationName: string;
    FDateTime: TFMDateTime;
    FVisitCategory: Char;
    FStandAlone: Boolean;
    FFromSelf: Boolean;
    FFromDate: TFMDateTime;
    FThruDate: TFMDateTIme;
    FFromCreate: Boolean;
    FOldHintEvent: TShowHintEvent;
    OKPressed: Boolean;
    procedure AppShowHint(var HintStr: string; var CanShow: Boolean;
                          var HintInfo: THintInfo);
    procedure SetVisitCat;
  public
    { Public declarations }
  end;

procedure UpdateEncounter(PersonFilter: Int64; ADate: TFMDateTime = 0; TIULocation: integer = 0);
procedure UpdateVisit(FontSize: Integer); overload;
procedure UpdateVisit(FontSize: Integer; TIULocation: integer); overload;


implementation

{$R *.DFM}

uses rCore, uCore, uConst {, fReview, uPCE, rPCE};

const
  TC_MISSING = 'Incomplete Encounter Information';
  TX_NO_DATE = 'A valid date/time has not been entered.';
  TX_NO_TIME = 'A valid time has not been entered.';
  TX_NO_LOC  = 'A visit location has not been selected.';
  TC_LOCONLY = 'Location for Current Activities';

var
  uTIULocation: integer;
  uTIULocationName: string;

  EncounterLastVisitDateTime : String;   //kt 6-1-05
  EncounterLastLocation : Integer; //kt 6-5-05
  EncounterLastLocationValid : String; //kt 6-5-05 

procedure UpdateVisit(FontSize: Integer);
begin
  UpdateEncounter(NPF_SUPPRESS);
end;

procedure UpdateVisit(FontSize: Integer; TIULocation: integer);
begin
  UpdateEncounter(NPF_SUPPRESS, 0, TIULocation);
end;

procedure UpdateEncounter(PersonFilter: Int64; ADate: TFMDateTime = 0;  TIULocation: integer = 0);
const
  UP_SHIFT = 85;
var
  frmEncounter: TfrmEncounter;
  CanChange: Boolean;
  TimedOut: Boolean;
begin
  uTIULocation := TIULocation;
  if (uTIULocation = 0) and (EncounterLastLocation <> 0)
  and (EncounterLastLocationValid <>'') then uTIULocation := EncounterLastLocation; //kt 6-5-05
  if uTIULocation <> 0 then uTIULocationName := ExternalName(uTIULocation, FN_HOSPITAL_LOCATION);
  frmEncounter := TfrmEncounter.Create(Application);
  try
    TimedOut := False;
    ResizeAnchoredFormToFont(frmEncounter);
    frmEncounter.FFilter := PersonFilter;
    frmEncounter.FPCDate := ADate;
    if PersonFilter = NPF_SUPPRESS then           // not prompting for provider
    begin
      frmEncounter.lblProvider.Visible := False;
      frmEncounter.cboPtProvider.Visible := False;
      frmEncounter.lblInstruct.Visible := True;
      frmEncounter.Caption := TC_LOCONLY;
      frmEncounter.Height := frmEncounter.Height - UP_SHIFT;
      if frmEncounter.pgeVisit.ActivePage = frmEncounter.tabNewVisit then
      begin
        if uTIULocation <> 0 then
          frmEncounter.ActiveControl := frmEncounter.calVisitDate
        else
          frmEncounter.ActiveControl := frmEncounter.cboNewVisit;
      end;
    end
    else                                          // also prompt for provider
    begin
      // InitLongList must be done AFTER FFilter is set
      frmEncounter.cboPtProvider.InitLongList(Encounter.ProviderName);
      frmEncounter.cboPtProvider.SelectByIEN(frmEncounter.FProvider);
    end;
    if EncounterLastVisitDateTime <>'' then frmEncounter.calVisitDate.Text := EncounterLastVisitDateTime; //kt 6/1/05

    frmEncounter.ShowModal;
    if frmEncounter.OKPressed then with frmEncounter do
    begin
      EncounterLastVisitDateTime := frmEncounter.calVisitDate.Text; //kt 6/1/05
      EncounterLastLocation := FLocation;
      EncounterLastLocationValid := 'TRUE';
      CanChange := True;
      {
      if (PersonFilter <> NPF_SUPPRESS) and
         (((Encounter.Provider =  User.DUZ) and (FProvider <> User.DUZ)) or
          ((Encounter.Provider <> User.DUZ) and (FProvider =  User.DUZ)))
         then CanChange := ReviewChanges(TimedOut);
      }
      if CanChange then
      begin
        if PersonFilter <> NPF_SUPPRESS then Encounter.Provider := FProvider;
        Encounter.Location      := FLocation;
        Encounter.DateTime      := FDateTime;
        Encounter.VisitCategory := FVisitCategory;
        Encounter.StandAlone    := FStandAlone;
      end;
    end;
  finally
    frmEncounter.Release;
  end;
end;

procedure TfrmEncounter.FormCreate(Sender: TObject);
var
  ADateFrom, ADateThru: TDateTime;
  BDateFrom, BDateThru: Integer;
  BDisplayFrom, BDisplayThru: String;
begin
  inherited;
  EncounterLastLocation := 0; //kt 6-5-05

  FProvider      := Encounter.Provider;
  FLocation      := Encounter.Location;
  FLocationName  := Encounter.LocationName;
  FDateTime      := Encounter.DateTime;
  FVisitCategory := Encounter.VisitCategory;
  FStandAlone    := Encounter.StandAlone;
  //kt rpcGetApptUserDays(BDateFrom, BDateThru); // Get user's current date range settings.
  if BDateFrom > 0 then
    BDisplayFrom := 'T+' + IntToStr(BDateFrom)
  else if BDateFrom < 0 then
    BDisplayFrom := 'T-' + IntToStr(-BDateFrom)
  else
    BDisplayFrom := 'T';
  if BDateThru > 0 then
    BDisplayThru := 'T+' + IntToStr(BDateThru)
  else if BDateThru < 0 then
    BDisplayThru := 'T-' + IntToStr(-BDateThru)
  else
    BDisplayThru := 'T';
  lblDateRange.Caption := '(' + BDisplayFrom + ' thru ' + BDisplayThru + ')';
  ADateFrom := (FMDateTimeToDateTime(FMToday) + BDateFrom);
  ADateThru := (FMDateTimeToDateTime(FMToday) + BDateThru);
  FFromDate      := DateTimeToFMDateTime(ADateFrom);
  FThruDate      := DateTimeToFMDateTime(ADateThru) + 0.2359;
  FFromCreate    := True;
  with txtLocation do if Length(FLocationName) > 0 then
  begin
    Text := FLocationName + '  ';
    if (FVisitCategory <> 'H') and (FDateTime <> 0) then
      Text := Text + FormatFMDateTime('mmm dd,yy hh:nn', FDateTime);
  end
  else Text := '< Select a location from the tabs below.... >';
  OKPressed := False;
  pgeVisit.ActivePage := tabClinic;
  pgeVisitChange(Self);
  if lstClinic.Items.Count = 0 then
  begin
    pgeVisit.ActivePage := tabNewVisit;
    pgeVisitChange(Self);
  end;
  ckbHistorical.Hint := 'A historical visit or encounter is a visit that occurred at some time' + CRLF +
                        'in the past or at some other location (possibly non-VA).  Although these' + CRLF +
                        'are not used for workload credit, they can be used for setting up the' + CRLF +
                        'PCE reminder maintenance system, or other non-workload-related reasons.';
  FOldHintEvent := Application.OnShowHint;
  Application.OnShowHint := AppShowHint;
  FFromCreate := False;
end;

procedure TfrmEncounter.cboPtProviderNeedData(Sender: TObject; const StartFrom: string;
  Direction, InsertAt: Integer);
begin
  inherited;
  case FFilter of
    NPF_PROVIDER:  cboPtProvider.ForDataUse(SubSetOfProviders(StartFrom, Direction));
//    NPF_ENCOUNTER: cboPtProvider.ForDataUse(SubSetOfUsersWithClass(StartFrom, Direction, FloatToStr(FPCDate)));
    else cboPtProvider.ForDataUse(SubSetOfPersons(StartFrom, Direction));
  end;
end;

procedure TfrmEncounter.pgeVisitChange(Sender: TObject);
begin
  inherited;
  cmdDateRange.Visible := pgeVisit.ActivePage = tabClinic;
  if (pgeVisit.ActivePage = tabClinic) and (lstClinic.Items.Count = 0)
    then ListApptAll(lstClinic.Items, Patient.DFN, FFromDate, FThruDate);
  if (pgeVisit.ActivePage = tabAdmit)    and (lstAdmit.Items.Count = 0)
    then ListAdmitAll(lstAdmit.Items, Patient.DFN);
  if pgeVisit.ActivePage = tabNewVisit then
  begin
    if cboNewVisit.Items.Count = 0 then
    begin
      if FVisitCategory <> 'H' then
      begin
        if uTIULocation <> 0 then
        begin
          cboNewVisit.InitLongList(uTIULocationName);
          cboNewVisit.SelectByIEN(uTIULocation);
        end
        else
        begin
          cboNewVisit.InitLongList(FLocationName);
          if Encounter.Location <> 0 then cboNewVisit.SelectByIEN(FLocation);
        end;
        FFromSelf := True;
        with calVisitDate do if FDateTime <> 0 then FMDateTime := FDateTime else Text := 'NOW';
        FFromSelf := False;
      end
      else cboNewVisit.InitLongList('');
      ckbHistorical.Checked := FVisitCategory = 'E';
    end; {if cboNewVisit}
    if uTIULocation <> 0
      then ActiveControl := calVisitDate
    else if (FFromCreate and User.IsProvider) or (not FFromCreate) or (not cboPtProvider.Visible)
      then ActiveControl := cboNewVisit
  end; {if pgeVisit.ActivePage}
end;

procedure TfrmEncounter.cboNewVisitNeedData(Sender: TObject; const StartFrom: string;
  Direction, InsertAt: Integer);
begin
  inherited;
  cboNewVisit.ForDataUse(SubSetOfNewLocs(StartFrom, Direction));
end;

procedure TfrmEncounter.cmdDateRangeClick(Sender: TObject);
begin
  dlgDateRange.FMDateStart := FFromDate;
  dlgDateRange.FMDateStop  := FThruDate;
  if dlgDateRange.Execute then
  begin
    FFromDate := dlgDateRange.FMDateStart;
    FThruDate := dlgDateRange.FMDateStop + 0.2359;
    lblDateRange.Caption := '(' + dlgDateRange.RelativeStart + ' thru '
                                + dlgDateRange.RelativeStop + ')';
    lstClinic.Caption := lblClinic.Caption + ' ' + lblDateRange.Caption;
    lstClinic.Items.Clear;
    ListApptAll(lstClinic.Items, Patient.DFN, FFromDate, FThruDate);
  end;
end;

procedure TfrmEncounter.lstClinicClick(Sender: TObject);
// V|A;DateTime;LocIEN^DateTime^LocName^Status
begin
  inherited;
  with lstClinic do
  begin
    FLocation := StrToIntDef(Piece(ItemID, ';', 3), 0);
    FLocationName := Piece(Items[ItemIndex], U, 3);
    FDateTime := MakeFMDateTime(Piece(ItemID,';', 2));
    FVisitCategory := 'A';
    FStandAlone := CharAt(ItemID, 1) = 'V';
    with txtLocation do
    begin
      Text := FLocationName + '  ';
      if FDateTime <> 0 then Text := Text + FormatFMDateTime('mmm dd,yy hh:nn', FDateTime);
    end;
  end;
end;

procedure TfrmEncounter.lstAdmitClick(Sender: TObject);
begin
  inherited;
  with lstAdmit do
  begin
    FLocation := StrToIntDef(Piece(Items[ItemIndex], U, 2), 0);
    FLocationName := Piece(Items[ItemIndex], U, 3);
    FDateTime := MakeFMDateTime(ItemID);
    FVisitCategory := 'H';
    FStandAlone := False;
    txtLocation.Text := FLocationName;  // don't show admit date (could confuse user)
  end;
end;

procedure TfrmEncounter.cboNewVisitChange(Sender: TObject);
begin
  inherited;
  with cboNewVisit do
  begin
    FLocation := ItemIEN;
    FLocationName := DisplayText[ItemIndex];
    FDateTime := calVisitDate.FMDateTime;
    SetVisitCat;
    with txtLocation do
    begin
      Text := FLocationName + '  ';
      if FDateTime <> 0 then Text := Text + FormatFMDateTime('mmm dd,yy hh:nn', FDateTime);
    end;
  end;
end;

procedure TfrmEncounter.calVisitDateChange(Sender: TObject);
begin
  inherited;
  // The FFromSelf was added because without it, a new visit (minus the seconds gets created.
  // Setting the text of calVisit caused the text to be re-evaluated & changed the FMDateTime property.
  if FFromSelf then Exit;
  with cboNewVisit do
  begin
    FLocation := ItemIEN;
    FLocationName := DisplayText[ItemIndex];
    FDateTime := calVisitDate.FMDateTime;
    SetVisitCat;
    txtLocation.Text := FLocationName + '  ' + calVisitDate.Text;
  end;
end;

procedure TfrmEncounter.calVisitDateExit(Sender: TObject);
begin
  inherited;
  with cboNewVisit do if ItemIEN > 0 then
  begin
    FLocation := ItemIEN;
    FLocationName := DisplayText[ItemIndex];
    FDateTime := calVisitDate.FMDateTime;
    SetVisitCat;
    with txtLocation do
    begin
      Text := FLocationName + '  ';
      if FDateTime <> 0 then Text := Text + FormatFMDateTime('mmm dd,yy hh:nn', FDateTime);
    end;
  end;
end;

procedure TfrmEncounter.cmdOKClick(Sender: TObject);
var
  msg: string;

begin
  inherited;
  msg := '';
  if FLocation = 0 then msg := TX_NO_LOC;
  // added "<" to FDateTime check to trap "-1" visit dates - v23.12 (RV)
  if FDateTime <= 0 then msg := TX_NO_DATE;
  if(pos('.',FloatToStr(FDateTime)) = 0) then msg := TX_NO_TIME;
  if(msg <> '') then
  begin
    InfoBox(msg,  TC_MISSING, MB_OK);
    Exit;
  end;
  if FFilter <> NPF_SUPPRESS then FProvider := cboPtProvider.ItemIEN;
  OKPressed := True;
  Close;
end;

procedure TfrmEncounter.cmdCancelClick(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TfrmEncounter.ckbHistoricalClick(Sender: TObject);
begin
  SetVisitCat;
end;

{
procedure TfrmEncounter.cboPtProviderChange(Sender: TObject);
var
  txt: string;
  AIEN: Int64;

begin
  if(FFilter <> NPF_ENCOUNTER) then exit;
  AIEN := cboPtProvider.ItemIEN;
  if(AIEN <> 0) then
  begin
    txt := InvalidPCEProviderTxt(AIEN, FPCDate);
    if(txt <> '') then
    begin
      InfoBox(cboPtProvider.text + txt, TX_BAD_PROV, MB_OK);
      cboPtProvider.ItemIndex := -1;
    end;
  end;
end;
 }

procedure TfrmEncounter.AppShowHint(var HintStr: string;
  var CanShow: Boolean; var HintInfo: THintInfo);
const
  HistHintDelay = 30000; // 30 seconds

begin
  if (not Assigned(HintInfo.HintControl)) then exit;
  if(HintInfo.HintControl = ckbHistorical) then
    HintInfo.HideTimeout := HistHintDelay;
  if(assigned(FOldHintEvent)) then
    FOldHintEvent(HintStr, CanShow, HintInfo);
end;

procedure TfrmEncounter.FormDestroy(Sender: TObject);
begin
  //Application.OnShowHint := FOldHintEvent;     v22.11f - RV
end;

procedure TfrmEncounter.SetVisitCat;
begin
  {
  if ckbHistorical.Checked then
    FVisitCategory := 'E'
  else
    FVisitCategory := GetVisitCat('A', FLocation, Patient.Inpatient);
  FStandAlone := (FVisitCategory = 'A');
  }
end;

procedure TfrmEncounter.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Application.OnShowHint := FOldHintEvent;
end;

end.

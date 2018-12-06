unit frmVennU;

//{$I DELHIAREA.INC}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Pointf, VennObject, TMGStrUtils, TypesU, TestRemResultsU,
  ReminderRegionManagerU, RegionManager, ReminderObjU,
  Dialogs, ExtCtrls, math, StdCtrls, ComCtrls, Buttons;

const
  BALL_RADIUS = 10;
  BOTTOM_SPACING = 30;
  NUM_BALLS = 0;

type
  TVennForm = class(TForm)
    Timer1: TTimer;
    cboMode: TComboBox;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    btnDetails: TBitBtn;
    btnAddVennObj: TBitBtn;
    btnTestReminder: TBitBtn;
    btnDelItem: TBitBtn;
    procedure btnDelItemClick(Sender: TObject);
    procedure btnTestReminderClick(Sender: TObject);
    procedure btnAddVennObjClick(Sender: TObject);
    procedure btnDetailsClick(Sender: TObject);
    procedure LoadCoreXMLButtonClick(Sender: TObject);
    procedure GetLogicButtonClick(Sender: TObject);
    procedure LoadXMLButtonClick(Sender: TObject);
    procedure SaveXMLButtonClick(Sender: TObject);
    procedure CoreXMLButtonClick(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure cboModeClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FRunning : boolean;
    FOnDisplayRefreshNeeded : TNotifyEvent;
    procedure SetRunning(Value : boolean);
    procedure HandleSelectionChange(RemObject : TRemObj);
    procedure HandleRemDefVennObjectRtClick(RemObject : TRemObj);
    procedure HandleVennObjectDblClick(RemObject : TRemObj);
  public
    LastDisplayed_FindingsUsed : string;
    RgnMgr : TRemRgnManager;
    FResultsMgr : TRemTestResultMgr;
    procedure HandleRefreshNeeded(Obj : TObject);
    function AddRemObject : TRemObj;  //Caller does NOT own object (RgnMgr does)
    property Running : boolean read FRunning write SetRunning;

    //DISCUSSION: The OnDisplayRefreshNeeded may be redundant.  Every GridInfo
    //          can have an OnAfterPost event, and most of the grids have this
    //         set up.  But after this was implimented, we found that at times
    //        the Venn display was not getting refreshed consistently, so
    //       created this event--having forgotten about the first event.  It
    //       would have been better to get the first system completely implemented.
    //      These may need to be combined in the future.
    Property OnDisplayRefreshNeeded : TNotifyEvent read FOnDisplayRefreshNeeded write FOnDisplayRefreshNeeded;
  end;


var
  VennForm: TVennForm;

implementation

{$R *.dfm}
{$R IMAGES.res}

  Uses
    LogUnit, MainU, fOneRecEditU, Rem2VennU, fAddRemFinding, fTestReminder;

  procedure TVennForm.FormCreate(Sender: TObject);
  //var i : integer;
  begin
    RgnMgr := TRemRgnManager.Create(VennForm);
    RgnMgr.Canvas := Canvas;
    FormResize(nil);
    FResultsMgr := nil;
    FOnDisplayRefreshNeeded := nil;
    RgnMgr.OnSelChange := HandleSelectionChange;
    RgnMgr.OnRtClickRemObject := HandleRemDefVennObjectRtClick;
    RgnMgr.OnDblClickRemObject := HandleVennObjectDblClick;
    RgnMgr.OnRefreshNeeded := HandleRefreshNeeded;
    SetRunning(false);
  end;


  procedure TVennForm.FormDestroy(Sender: TObject);
  begin
    FResultsMgr.Free;
    RgnMgr.Destroy; //not sure why .Free didn't do this automatically...
    //RgnMgr.Free; //this frees objects
  end;

  procedure TVennForm.HandleRefreshNeeded(Obj : TObject);
  //fires when region manager needs refresh of entire display
  begin
    MainForm.orcboSelRemDefClick(Obj);  //force refresh
  end;

  function TVennForm.AddRemObject : TRemObj;
  begin
    Result := RgnMgr.NewChild;
  end;

  procedure TVennForm.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
    RgnMgr.HandleMouseDown(Sender, button, Shift, X, Y);
  end;

  procedure TVennForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,  Y: Integer);
  begin
    RgnMgr.HandleMouseMove(Sender, Shift, X, Y);
  end;

  procedure TVennForm.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
    RgnMgr.HandleMouseUp(Sender, Button, Shift, X, Y);
  end;

  procedure TVennForm.FormDblClick(Sender: TObject);
  begin
    RgnMgr.HandleDblClick(ScreenToClient(Mouse.CursorPos));
  end;

  procedure TVennForm.FormResize(Sender: TObject);
  begin
    RgnMgr.Resize(VennForm.Height-BOTTOM_SPACING, VennForm.Width);
  end;

  procedure TVennForm.btnAddClick(Sender: TObject);
  begin
    AddRemObject;
  end;

  procedure TVennForm.btnAddVennObjClick(Sender: TObject);
  var
    frmAddRemFinding: TfrmAddRemFinding;
    RefreshIndicated : boolean;
    FileNum, IENS : string;
  begin
    frmAddRemFinding := TfrmAddRemFinding.Create(Self);
    FileNum := Rem2VennU.ReminderGridInfo.FileNum;
    IENS := Rem2VennU.ReminderGridInfo.IENS;
    frmAddRemFinding.Initialize(FileNum, IENS, Rem2VennU.VennDisplayMode);
    frmAddRemFinding.ShowModal;
    RefreshIndicated := frmAddRemFinding.RefreshIndicated;
    frmAddRemFinding.Free;
    if RefreshIndicated and assigned(FOnDisplayRefreshNeeded) then begin
      FOnDisplayRefreshNeeded(Self);
    end;
    {
    if RefreshIndicated then begin
      MainForm.orcboSelRemDefClick(Self);
    end;
    }
  end;

  procedure TVennForm.CoreXMLButtonClick(Sender: TObject);
  var XML : widestring;
      Err : TStringList;
  begin
    Err := TStringList.Create;
    if assigned(RgnMgr.SelVennObject) then begin
      //XML := RgnMgr.SelVennObject.GetXMLRepresentation;
      XML := RgnMgr.SelVennObject.GetCoreXMLRepresentation(Err);
    end else begin
      //XML := RgnMgr.GetXMLRepresentation;
      XML := RgnMgr.GetCoreXMLRepresentation(Err);
    end;
    LogForm.Memo.Lines.Text := XML + CRLF + Err.Text;
    LogForm.ShowModal;
    Err.Free;
  end;

  procedure TVennForm.LoadCoreXMLButtonClick(Sender: TObject);
  var XML : widestring;
  begin
    LogForm.Memo.Lines.Clear;
    if LogForm.ShowModal <> mrOK then exit;
    XML := LogForm.Memo.Lines.Text;
    RgnMgr.LoadFromCoreXML(XML);
  end;

  procedure TVennForm.SaveXMLButtonClick(Sender: TObject);
  begin
    if SaveDialog1.Execute then begin
      RgnMgr.SaveToFile(SaveDialog1.FileName);
    end;
  end;

  procedure TVennForm.LoadXMLButtonClick(Sender: TObject);
  //Was handler for LoadXML button
  begin
    if OpenDialog1.Execute then begin
      RgnMgr.LoadFromFile(OpenDialog1.FileName);
    end;
  end;

  procedure TVennForm.GetLogicButtonClick(Sender: TObject);
  var s : string;
      Err : TStringList;
  begin
    Err := TStringList.Create;
    s := RgnMgr.GetLogicString(Err);

    LogForm.Memo.Lines.Text := s + CRLF + Err.Text;
    LogForm.ShowModal;
    Err.Free;

  end;

  procedure TVennForm.cboModeClick(Sender: TObject);
  begin
    if assigned(RgnMgr.SelVennObject) then begin
      RgnMgr.SelVennObject.CombinationMode := TCombinationStyle(cboMode.ItemIndex);
    end;
  end;

  procedure TVennForm.SetRunning(Value : boolean);
  begin
    if Value = FRunning then exit;
    FRunning := Value;
    Timer1.Enabled := FRunning;
  end;

  procedure TVennForm.Timer1Timer(Sender: TObject);
  begin
    RgnMgr.AnimateAndRender;
  end;

  procedure TVennForm.HandleSelectionChange(RemObject : TRemObj);
  var Enabled : boolean;
  begin
    Enabled := Assigned(RemObject)
      //and (VennObject.Name <> SUBLOGIC_GROUP)
      //and (VennObject.Name <> AGE_LABEL)
      and (RemObject.Name <> VinSexSubStr);
    btnDetails.Enabled := Enabled;
    btnDelItem.Enabled := Enabled; 
  end;

  procedure TVennForm.btnDelItemClick(Sender: TObject);
  begin
    RgnMgr.DeleteObj(TVennObj(RgnMgr.SelRemObject));
    if assigned(FOnDisplayRefreshNeeded) then begin
      FOnDisplayRefreshNeeded(Self);
    end;
  end;

procedure TVennForm.btnDetailsClick(Sender: TObject);
  var GridInfo : TGridInfo;
  begin
    if not Assigned(RgnMgr.SelRemObject) then exit;
    GridInfo := RgnMgr.SelRemObject.GridInfo;
    HandleRemDefVennObjectRtClick(RgnMgr.SelRemObject);
    if Assigned(GridInfo) and (GridInfo.DisplayRefreshIndicated)
    and assigned(FOnDisplayRefreshNeeded) then begin
      FOnDisplayRefreshNeeded(Self);
    end;
  end;

  procedure TVennForm.btnTestReminderClick(Sender: TObject);
  var IEN : string;
  begin
    IEN := piece(Rem2VennU.ReminderIENS,',',1);
    frmTestReminder := TfrmTestReminder.Create(Self);
    frmTestReminder.Initialize(IEN);
    frmTestReminder.ShowModal;
    FResultsMgr := frmTestReminder.GetAndTransferOwnershipOfResultsMgr;
    FreeAndNil(frmTestReminder);
    if FResultsMgr.HasResults then begin
      MessageDlg('Here I can now apply results to disply of Items.', mtInformation, [mbOK],0);
    end;
  end;

  procedure TVennForm.HandleVennObjectDblClick(RemObject : TRemObj);
  begin
    if btnDetails.Enabled then btnDetailsClick(RemObject);
  end;

  procedure TVennForm.HandleRemDefVennObjectRtClick(RemObject : TRemObj);
  var AGridInfo : TCompleteGridInfo;
      ChangesMade : Boolean;
  begin
    AGridInfo := RemObject.GridInfo;
    if RemObject.Name = AGE_LABEL then begin
      Rem2VennU.HandleAgeDetailClick;
      exit;
    end;
    if (RemObject.Name = SUBLOGIC_GROUP) then begin
      RgnMgr.ZoomIntoSelected;
      exit;
    end;
    if Assigned(AGridInfo) then begin
      //EditOneRecordModal(AGridInfo.FileNum, AGridInfo.IENS);
      ChangesMade := EditOneRecordModal(AGridInfo);
      AGridInfo.DisplayRefreshIndicated := ChangesMade;
      exit;
    end else if (RemObject.Children.Count > 0) then begin
      RgnMgr.ZoomIntoSelected;
      exit;
    end;
  end;




end.

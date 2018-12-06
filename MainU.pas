unit MainU;

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
  Dialogs, StdCtrls, StrUtils, GridU,
  ORNet, ORFn, ComCtrls, ToolWin, Grids, ORCtrls, ExtCtrls, Buttons,
  AppEvnts, Menus, ImgList, XML2Dlg, TypesU, GlobalsU,
  VennObject, DragTreeNodeU, TreeViewU,
  {$IFDEF USE_SKINS}
  ipSkinManager,
  {$ENDIF}
  Trpcb, //needed for .ptype types
  ValEdit, SortStringGrid;

type
  TMainForm = class(TForm)
    PageControl: TPageControl;
    tsUsers: TTabSheet;
    UsersTreeView: TTreeView;
    UserPageControl: TPageControl;
    tsBasicPage: TTabSheet;
    tsAdvancedPage: TTabSheet;
    RightPanel: TPanel;
    ButtonPanel: TPanel;
    btnUsersApply: TBitBtn;
    btnUsersRevert: TBitBtn;
    LeftPanel: TPanel;
    Splitter1: TSplitter;
    Panel5: TPanel;
    ApplicationEvents: TApplicationEvents;
    AdvancedUsersGrid: TSortStringGrid;
    BasicUsersGrid: TSortStringGrid;
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    ExitMenuItem: TMenuItem;
    AboutMenu: TMenuItem;
    CloneBtn: TBitBtn;
    ImageList1: TImageList;
    tsSettings: TTabSheet;
    Panel1: TPanel;
    Panel2: TPanel;
    SettingsPageControl: TPageControl;
    tsBasicSettings: TTabSheet;
    BasicSettingsGrid: TSortStringGrid;
    tsAdvancedSettings: TTabSheet;
    AdvancedSettingsGrid: TSortStringGrid;
    Panel3: TPanel;
    btnSettingsApply: TBitBtn;
    btnSettingsRevert: TBitBtn;
    Panel4: TPanel;
    SettingsTreeView: TTreeView;
    Panel6: TPanel;
    Splitter2: TSplitter;
    tsPatients: TTabSheet;
    Panel7: TPanel;
    Splitter3: TSplitter;
    Panel8: TPanel;
    PatientsPageControl: TPageControl;
    tsBasicPatients: TTabSheet;
    BasicPatientGrid: TSortStringGrid;
    tsAdvancedPatients: TTabSheet;
    AdvancedPatientGrid: TSortStringGrid;
    Panel9: TPanel;
    btnPatientApply: TBitBtn;
    btnPatientRevert: TBitBtn;
    Panel10: TPanel;
    Panel11: TPanel;
    AddBtn: TBitBtn;
    PatientORComboBox: TORComboBox;
    tsAdvanced: TTabSheet;
    Panel12: TPanel;
    Splitter4: TSplitter;
    RtAdvPanel: TPanel;
    AnyFilePageControl: TPageControl;
    TabSheet2: TTabSheet;
    AllFilesGrid: TSortStringGrid;
    Panel14: TPanel;
    btnAdvancedApply: TBitBtn;
    btnAdvancedRevert: TBitBtn;
    LeftAdvPanel: TPanel;
    BotLeftAdvBtnPanel: TPanel;
    btnAddAnyRecord: TBitBtn;
    FileORComboBox: TORComboBox;
    Label1: TLabel;
    RecordORComboBox: TORComboBox;
    Label2: TLabel;
    TopLeftAdvPanel: TPanel;
    BotLeftAdvPanel: TPanel;
    Splitter5: TSplitter;
    Panel13: TPanel;
    btnBatchAdd: TBitBtn;
    tsReminders: TTabSheet;
    pnlDialogGroup: TPanel;
    LRSplitter: TSplitter;
    pnlRight: TPanel;
    RemDlgPageControl: TPageControl;
    tsRemDlgAdvanced: TTabSheet;
    Panel17: TPanel;
    btnRDlgApply: TBitBtn;
    btnRDlgRevert: TBitBtn;
    pnlLeft: TPanel;
    pnlButtonArea: TPanel;
    btnAddChild: TBitBtn;
    pnlSelection: TPanel;
    Splitter7: TSplitter;
    pnlSelReminder: TPanel;
    pnlElements: TPanel;
    orcboSelRemDlg: TORComboBox;
    Label4: TLabel;
    tvElements: TTreeView;
    AdvRemDlgGrid: TSortStringGrid;
    tsReminderDialog: TTabSheet;
    tsRemDlgElement: TTabSheet;
    tsRemDlgPrompt: TTabSheet;
    tsRemDlgForcedValue: TTabSheet;
    tsRemDlgGroup: TTabSheet;
    tsRemDlgRsltGroup: TTabSheet;
    tsRemDlgRsltElement: TTabSheet;
    RemDlgGrid: TSortStringGrid;
    RemDlgElementGrid: TSortStringGrid;
    RemDlgPromptGrid: TSortStringGrid;
    RemDlgForcedVGrid: TSortStringGrid;
    RemDlgGroupGrid: TSortStringGrid;
    RemDlgRsltGroupGrid: TSortStringGrid;
    RemDlgRsltElementGrid: TSortStringGrid;
    cboDisplayDialogType: TComboBox;
    pnlSelTop: TPanel;
    btnLaunchRemDlg: TBitBtn;
    btnAddRemDialog: TSpeedButton;
    Help1: TMenuItem;
    ShowBrokerCalls: TMenuItem;
    cbDynamicDlgs: TCheckBox;
    tempXMLOpenDialog: TOpenDialog;
    RemindersPageControl: TPageControl;
    tsRemDialogs: TTabSheet;
    tsReminderDefs: TTabSheet;
    pnlRemDefLft: TPanel;
    Splitter6: TSplitter;
    pnlRemDefRt: TPanel;
    orcboSelRemDef: TORComboBox;
    Label3: TLabel;
    RemDefPageControl: TPageControl;
    tsRemDefGridPage: TTabSheet;
    tsRemDefVin: TTabSheet;
    pnlVennDisplay: TPanel;
    RemDefGrid: TSortStringGrid;
    Panel15: TPanel;
    btnRDefApply: TBitBtn;
    btnRDefRevert: TBitBtn;
    tcVinViewControl: TTabControl;
    btnDelElement: TBitBtn;
    btnFilter: TBitBtn;
    btnAddReminderDef: TBitBtn;
    btnDelReminder: TBitBtn;
    btnDelRemDialog: TSpeedButton;
    Labs1: TMenuItem;
    EnterLabs1: TMenuItem;
    HandleHL7FilingErrors: TMenuItem;
    procedure HandleHL7FilingErrorsClick(Sender: TObject);
    procedure EnterLabs1Click(Sender: TObject);
    procedure btnDelRemDialogClick(Sender: TObject);
    procedure btnAddRemDialogClick(Sender: TObject);
    procedure btnDelReminderClick(Sender: TObject);
    procedure RecordORComboBoxChange(Sender: TObject);
    procedure btnRDefRevertClick(Sender: TObject);
    procedure btnRDlgRevertClick(Sender: TObject);
    procedure btnFilterClick(Sender: TObject);
    procedure btnDelElementClick(Sender: TObject);
    procedure btnAddReminderDefClick(Sender: TObject);
    procedure RemindersPageControlChange(Sender: TObject);
    procedure RemDefPageControlChange(Sender: TObject);
    procedure tcVinViewControlChange(Sender: TObject);
    procedure pnlVennDisplayResize(Sender: TObject);
    procedure orcboSelRemDefClick(Sender: TObject);
    procedure orcboSelRemDefChange(Sender: TObject);
    procedure SelRemDefNeedData(Sender: TObject; const StartFrom: string; Direction, InsertAt: Integer);
    procedure FormShow(Sender: TObject);
    procedure GridSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: String);
    procedure GridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure UsersTreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure btnUsersRevertClick(Sender: TObject);
    procedure btnUsersApplyClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ExitMenuItemClick(Sender: TObject);
    procedure UserPageControlDrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure AboutMenuClick(Sender: TObject);
    procedure CloneBtnClick(Sender: TObject);
    procedure ApplicationEventsIdle(Sender: TObject; var Done: Boolean);
    procedure ApplicationEventsShowHint(var HintStr: String; var CanShow: Boolean; var HintInfo: THintInfo);
    procedure SettingsTreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure CheckShouldAllowTreeNodeChange(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
    procedure BasicSettingsGridSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: String);
    procedure PageControlChanging(Sender: TObject; var AllowChange: Boolean);
    procedure UserPageControlChanging(Sender: TObject; var AllowChange: Boolean);
    procedure PatientORComboBoxNeedData(Sender: TObject; const StartFrom: String; Direction, InsertAt: Integer);
    procedure PageControlChange(Sender: TObject);
    procedure PatientORComboBoxClick(Sender: TObject);
    procedure PatientsPageControlChanging(Sender: TObject; var AllowChange: Boolean);
    procedure SettingsPageControlChanging(Sender: TObject; var AllowChange: Boolean);
    procedure PatientsPageControlChange(Sender: TObject);
    procedure SettingsPageControlChange(Sender: TObject);
    procedure UserPageControlChange(Sender: TObject);
    procedure FileORComboBoxNeedData(Sender: TObject; const StartFrom: String; Direction, InsertAt: Integer);
    procedure FileORComboBoxClick(Sender: TObject);
    procedure RecordORComboBoxNeedData(Sender: TObject; const StartFrom: String; Direction, InsertAt: Integer);
    procedure RecordORComboBoxClick(Sender: TObject);
    procedure btnAddAnyRecordClick(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btnRevertClick(Sender: TObject);
    procedure AllFilesGridClick(Sender: TObject);
    procedure btnBatchAddClick(Sender: TObject);
    procedure ChangeSkinClick(Sender: TObject);
    procedure btnPatientApplyClick(Sender: TObject);
    procedure btnPatientRevertClick(Sender: TObject);
    procedure BasicPatientGridClick(Sender: TObject);
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
    procedure btnSettingsRevertClick(Sender: TObject);
    procedure btnSettingsApplyClick(Sender: TObject);
    function InitRemDlgTab : boolean;
    procedure RemDlgNeedData(Sender: TObject; const StartFrom: String; Direction, InsertAt: Integer);
    procedure ScreenRemDlgData(Results : TStrings; Mode : Integer);
    procedure GetRemDlgInfo;
    procedure orcboSelRemDlgClick(Sender: TObject);
    procedure tvElementsExpanding(Sender: TObject; Node: TTreeNode; var AllowExpansion: Boolean);
    procedure tvElementsClick(Sender: TObject);
    procedure btnAddChildClick(Sender: TObject);
    procedure RemDlgPageControlChange(Sender: TObject);
    procedure RemDlgPageControlChanging(Sender: TObject;
      var AllowChange: Boolean);
    function RemDlgGridOnTabSheet(TabSheet : TTabSheet) : TSortStringGrid;
    procedure cboDisplayDialogTypeChange(Sender: TObject);
    procedure btnLaunchRemDlgClick(Sender: TObject);
    procedure tvElementsCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DoDefaultDraw: Boolean);
    procedure tvElementsOpenedOrClosed(Sender: TObject; Node: TTreeNode);
    procedure tvElementsStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure tvElementsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure tvElementsDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure tvElementsEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure ShowBrokerCallsClick(Sender: TObject);
    procedure cbDynamicDlgsClick(Sender: TObject);
  private
    { Private declarations }
    BasicModeTemplate : TStringList;
    DlgTemplate : TStringList;
    DlgElementTemplate : TStringList;
    DlgPromptTemplate : TStringList;
    DlgForcedVTemplate : TStringList;
    DlgGroupTemplate : TStringList;
    DlgRsltGroupTemplate : TStringList;
    DlgRsltElementTemplate : TStringList;

    //KernelSysParams : TTreeNode;
    //HospLocNode : TTreeNode;
    //RPCBrokerParamsNode : TTreeNode;
    //Devices : TTreeNode;
    //FLastSelectedRow,FLastSelectedCol : integer;
    SelectedDialogIEN : LongInt;
    RemDlgInfo : TStringList;
    RemDlgScreenMode : integer;
    NodeBeingDraggedOver : TTreeNode;
    MainFormTriggeringRemDlgChanges : boolean;
    RemDefFilters : string;
    procedure ShowDebugClick(Sender: TObject);
    function  GetCursorImage : TCursor;
    procedure SetCursorImage(Cursor : TCursor);
    function  FileNumForSettingsNode (Node : TTreeNode) : string;
    procedure InitializeUsersTreeView;
    procedure InitializeSettingsFilesTreeView;
    Procedure LoadUsersTreeView(UsersList : TStringList);
    Procedure LoadSettingsTreeView(RecordsList : TStringList;DestNode : TTreeNode);
    procedure GetUserDataAndLoadIntoGrids(GridInfo : TGridInfo);
    procedure GetSettingsInfoAndLoadIntoGrids(GridInfo : TGridInfo);
    procedure GetPatientInfoAndLoadIntoGrids(GridInfo : TGridInfo);
    function  PatientIENSSelector() : string;
    function  AnyFileIENSSelector() : string;
    procedure GetAllFilesInfoAndLoadIntoGrids(GridInfo : TGridInfo);
    function  DisuserChanged(Changes: TStringList) : boolean;
    procedure DrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure LoadRemDlgSubRecords(IENS: String);
    procedure LoadElementTree(Parent : TTreeNode; ParentIENS: string);
    procedure ReLoadElementTreeNode(Node : TTreeNode);
    procedure HandleRemDlgOnAfterPost(GridInfo: TGridInfo; Changes : TStringList);
    procedure HandleRemDefOnAfterPost(GridInfo: TGridInfo; Changes : TStringList);
    procedure HandleUserOnAfterPost(GridInfo: TGridInfo; Changes : TStringList);
    procedure HandleVennFormRefreshRequest(Sender: TObject);
    procedure SyncTVElementToRemDlg(Node : TTreeNode; CheckNodeCB : boolean = false);
    procedure CloseAnyRemDlgForm;
    procedure MoveReminderElement(SourceNode, DestNode : TTreeNode);
    procedure SetupRemDlgGrids(IEN : LongInt; ElementType : string);
    procedure RefreshRemDefVennDisplay;
  public
    { Public declarations }
    CurrentUserName: string;
    LastSelTreeNode : TTreeNode;
    LastSelTreeView : TTreeView;
    DebugMode : boolean;
    CurrentFileEntry : TStringList;
    XMLDlg : TXMLDlg;
    RemFindingsTemplatesList : TStringList;  //will own objects
    function  RemDlgIENSSelector() : string;
    function  RemDefIENSSelector() : string;
    procedure GetRemDefInfo(GridInfo : TGridInfo);
    procedure GetRemDlgFilesInfoAndLoadIntoGrids(GridInfo : TGridInfo);
    procedure GetRemDlgFilesInfoAndLoadIntoGridsFiltered(GridInfo : TGridInfo; GridFilter : string='');
    procedure ClearRemDlgGrids;
    procedure GetRecordsInfoAndLoadIntoGrids(GridInfo : TGridInfo; GridList : TList; CmdName : string='');
    procedure SelectExternalGridCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure Initialize;
    procedure InitORComboBox(ORComboBox: TORComboBox; initValue : string);
    procedure RemDlgDisplayElement(IEN : string);
    procedure RemDlgExpandElement(IEN : string; Expanded : boolean);
  end;


var
  MainForm: TMainForm;

implementation

uses
  frmSplash, LookupU, fMultiRecEditU, fOneRecEditU, SetSelU, SelDateTimeU, PostU,
  FMErrorU, AboutU, PleaseWaitU, EditTextU, CreateTemplateU, SkinFormU,
  BatchAddU, DebugU,
  fNotes, fPtSel, fEncnt, uConst,
  fLabEntry, frmVennU,
  DrawersUnit,EditFreeText, EditNumberU,
  fReminderDialog,
  fxBroker, rRPCsU,
  Rem2VennU,
  fAddRemDlgItem, fReminderDefFilter, fAddRemDef,
  UtilU, FMU,
  fLabHL7,  //8/16/15
  uCore, {access to TUser, TEncounter}
  inifiles, AddOneFileEntryU;  //8-12-09  elh

{$R *.dfm}
const
  RPC_CONTEXT = 'TMG RPC CONTEXT GUI_CONFIG';

  //---------------------------------------------------
  //---------------------------------------------------

  procedure TMainForm.Initialize;
  var tempMenu : TMenuItem;
      INIValue : string;
    {$IFDEF USE_SKINS}
    tempSubMenu : TMenuItem;
    {$ENDIF}

    procedure SetupAfterPostHandler(Grid : TSortStringGrid; Handler : TAfterPostHandler);
    var GridInfo : TGridInfo;
    begin
      GridInfo := GetInfoObjectForGrid(Grid);
      if not assigned(GridInfo) then exit;
      GridInfo.OnAfterPost := Handler;
    end;

  begin
    //kt tsReminders.PageControl := nil;
    DebugMode := (FindParam('debug')='enable');
    if DebugMode then begin
      DebugForm.show;
      tempMenu := TMenuItem.Create(FileMenu);
      tempMenu.Caption := '&Show Debug Log';
      tempMenu.OnClick := ShowDebugClick;
      FileMenu.Add(tempMenu);
    end else begin
      DebugForm.Hide;
    end;
    {$IFDEF USE_SKINS}
    DebugForm.Memo.Lines.Add('Adding Menus');
    tempMenu := TMenuItem.Create(MainMenu);
    tempMenu.Caption := '&Appearance';
    tempSubMenu := TMenuItem.Create(tempMenu);
    tempSubMenu.Caption := '&Change Skin';
    tempSubMenu.OnClick := ChangeSkinClick;
    tempMenu.Add(tempSubMenu);
    MainMenu.Items.Add(tempMenu);
    {$ENDIF}

    DebugForm.Memo.Lines.Add('Showing Splash');
    SplashForm.show;

    RemDefFilters := 'C';
    BasicModeTemplate := TStringList.create;
    BasicModeTemplate.Sorted := false;
    DlgTemplate := TStringList.Create;
    DlgElementTemplate := TStringList.Create;
    DlgPromptTemplate := TStringList.Create;
    DlgForcedVTemplate := TStringList.Create;
    DlgGroupTemplate := TStringList.Create;
    DlgRsltGroupTemplate := TStringList.Create;
    DlgRsltElementTemplate := TStringList.Create;
    RemFindingsTemplatesList := TStringList.Create;
    CurrentFileEntry := TStringList.Create;

    DebugForm.Memo.Lines.Add('Adding Grid Info');
    {           Name,                   Grid                  Data                   BasicTemplate            DataLoader                          FileNum   ApplyBtn          RevertBtn          RecSelector       }
    AddGridInfo('BasicUsersGrid',       BasicUsersGrid,       CurrentUsersData,      BasicModeTemplate,       GetUserDataAndLoadIntoGrids,        '200',    btnUsersApply,    btnUsersRevert);
    AddGridInfo('AdvancedUsersGrid',    AdvancedUsersGrid,    CurrentUsersData,      nil,                     GetUserDataAndLoadIntoGrids,        '200',    btnUsersApply,    btnUsersRevert);
    AddGridInfo('BasicSettingsGrid',    BasicSettingsGrid,    CurrentSettingsData,   BasicModeTemplate,       GetSettingsInfoAndLoadIntoGrids,    '',       btnSettingsApply, btnSettingsRevert);
    AddGridInfo('AdvancedSettingsGrid', AdvancedSettingsGrid, CurrentSettingsData,   nil,                     GetSettingsInfoAndLoadIntoGrids,    '',       btnSettingsApply, btnSettingsRevert);
    AddGridInfo('BasicPatientGrid',     BasicPatientGrid,     CurrentPatientsData,   BasicModeTemplate,       GetPatientInfoAndLoadIntoGrids,     '2',      btnPatientApply,  btnPatientRevert);
    AddGridInfo('AdvancedPatientGrid',  AdvancedPatientGrid,  CurrentPatientsData,   nil,                     GetPatientInfoAndLoadIntoGrids,     '2',      btnPatientApply,  btnPatientRevert,  PatientIENSSelector);
    AddGridInfo('AnyFileGrid',          AllFilesGrid,         CurrentAnyFileData,    nil,                     GetAllFilesInfoAndLoadIntoGrids,    '',       btnAdvancedApply, btnAdvancedRevert, AnyFileIENSSelector);
    AddGridInfo('RemDlgGrid',           RemDlgGrid,           CurrentRemDlgFileData, DlgTemplate,             GetRemDlgFilesInfoAndLoadIntoGrids, '801.41', btnRDlgApply,     btnRDlgRevert,     RemDlgIENSSelector);
    AddGridInfo('RemDlgElementGrid',    RemDlgElementGrid,    CurrentRemDlgFileData, DlgElementTemplate,      GetRemDlgFilesInfoAndLoadIntoGrids, '801.41', btnRDlgApply,     btnRDlgRevert,     RemDlgIENSSelector);
    AddGridInfo('RemDlgPromptGrid',     RemDlgPromptGrid,     CurrentRemDlgFileData, DlgPromptTemplate,       GetRemDlgFilesInfoAndLoadIntoGrids, '801.41', btnRDlgApply,     btnRDlgRevert,     RemDlgIENSSelector);
    AddGridInfo('RemDlgForcedVGrid',    RemDlgForcedVGrid,    CurrentRemDlgFileData, DlgForcedVTemplate,      GetRemDlgFilesInfoAndLoadIntoGrids, '801.41', btnRDlgApply,     btnRDlgRevert,     RemDlgIENSSelector);
    AddGridInfo('RemDlgGroupGrid',      RemDlgGroupGrid,      CurrentRemDlgFileData, DlgGroupTemplate,        GetRemDlgFilesInfoAndLoadIntoGrids, '801.41', btnRDlgApply,     btnRDlgRevert,     RemDlgIENSSelector);
    AddGridInfo('RemDlgRsltGroupGrid',  RemDlgRsltGroupGrid,  CurrentRemDlgFileData, DlgRsltGroupTemplate,    GetRemDlgFilesInfoAndLoadIntoGrids, '801.41', btnRDlgApply,     btnRDlgRevert,     RemDlgIENSSelector);
    AddGridInfo('RemDlgRsltElementGrid',RemDlgRsltElementGrid,CurrentRemDlgFileData, DlgRsltElementTemplate,  GetRemDlgFilesInfoAndLoadIntoGrids, '801.41', btnRDlgApply,     btnRDlgRevert,     RemDlgIENSSelector);
    AddGridInfo('AdvRemDlgGrid',        AdvRemDlgGrid,        CurrentRemDlgFileData, nil,                     GetRemDlgFilesInfoAndLoadIntoGrids, '801.41', btnRDlgApply,     btnRDlgRevert,     RemDlgIENSSelector);
    //AddGridInfo('AddFileEntry',         AddOneFileEntry.AddFileEntryGrid, CurrentFileEntry,  nil,             GetRemDlgFilesInfoAndLoadIntoGrids, '',       btnRDlgApply,     btnRDlgRevert,     RemDlgIENSSelector);
    AddGridInfo('RemDefGrid',           RemDefGrid,           CurrentRemDefFileData, nil,                     GetRemDlgFilesInfoAndLoadIntoGrids, '811.9', btnRDefApply,     btnRDefRevert,      RemDefIENSSelector);

    //For each tab (Settings, DebugFients, etc, add all grids that can be worked on)
    SettingsGridList.Add(BasicSettingsGrid);
    SettingsGridList.Add(AdvancedSettingsGrid);
    UsersGridList.Add(BasicUsersGrid);
    UsersGridList.Add(AdvancedUsersGrid);
    PatientsGridList.Add(BasicPatientGrid);
    PatientsGridList.Add(AdvancedPatientGrid);
    AnyFileGridList.Add(AllFilesGrid);
    DlgsGridList.Add(AdvRemDlgGrid);
    DlgsGridList.Add(RemDlgGrid);
    DlgsGridList.Add(RemDlgElementGrid);
    DlgsGridList.Add(RemDlgPromptGrid);
    DlgsGridList.Add(RemDlgForcedVGrid);
    DlgsGridList.Add(RemDlgGroupGrid);
    DlgsGridList.Add(RemDlgRsltElementGrid);
    DlgsGridList.Add(RemDlgRsltGroupGrid);
    DlgsGridList.Add(RemDlgElementGrid);
    RemDefGridList.Add(RemDefGrid);

    SetupAfterPostHandler(BasicUsersGrid,        HandleUserOnAfterPost);
    SetupAfterPostHandler(AdvancedUsersGrid,     HandleUserOnAfterPost);
    SetupAfterPostHandler(AdvRemDlgGrid,         HandleRemDlgOnAfterPost);
    SetupAfterPostHandler(RemDlgGrid,            HandleRemDlgOnAfterPost);
    SetupAfterPostHandler(RemDlgElementGrid,     HandleRemDlgOnAfterPost);
    SetupAfterPostHandler(RemDlgPromptGrid,      HandleRemDlgOnAfterPost);
    SetupAfterPostHandler(RemDlgForcedVGrid,     HandleRemDlgOnAfterPost);
    SetupAfterPostHandler(RemDlgGroupGrid,       HandleRemDlgOnAfterPost);
    SetupAfterPostHandler(RemDlgRsltElementGrid, HandleRemDlgOnAfterPost);
    SetupAfterPostHandler(RemDlgRsltGroupGrid,   HandleRemDlgOnAfterPost);
    SetupAfterPostHandler(RemDlgElementGrid,     HandleRemDlgOnAfterPost);
    SetupAfterPostHandler(RemDefGrid,            HandleRemDefOnAfterPost);

    MainForm.Visible := false;

    DebugForm.Memo.Lines.Add('Trying to connect to server');
    if not ORNet.ConnectToServer(RPC_CONTEXT) then begin
      DebugForm.Memo.Lines.Add('Failed connection.  Closing.');
      messagedlg('Login Failed.',mtError,[mbOK],0);
      Close;
      Exit;
    end;
    User := TUser.Create;
    Encounter := TEncounter.Create;
    Patient := TPatient.Create;
    Changes := TChanges.Create;

    DebugForm.Memo.Lines.Add('Connected to server!');
    Application.ProcessMessages;
    LastSelTreeNode := nil;
    LastSelTreeView := nil;
    RPCBrokerV.ClearParameters := true;

    DebugForm.Memo.Lines.Add('Initializing Combo Boxes');
    InitORCombobox(PatientORComboBox,'A');
    InitORCombobox(FileORComboBox,'A');
    InitORCombobox(orcboSelRemDlg,'A');
    InitORCombobox(orcboSelRemDef,'A');

    GridU.InitUsersTemplateStuff(BasicModeTemplate);
    InitializeUsersTreeView;

    GridU.InitSettingsFilesTemplateStuff(BasicModeTemplate);
    InitializeSettingsFilesTreeView;

    GridU.InitRemDlgTemplate(DlgTemplate);
    GridU.InitDlgElementTemplate(DlgElementTemplate);
    GridU.InitDlgPromptTemplate(DlgPromptTemplate);
    GridU.InitDlgForcedVTemplate(DlgForcedVTemplate);
    GridU.InitDlgGroupTemplate(DlgGroupTemplate);
    GridU.InitDlgRsltGroupTemplate(DlgRsltGroupTemplate);
    GridU.InitDlgRsltElementTemplate(DlgRsltElementTemplate);
    GridU.InitRemFindingsTemplateList(RemFindingsTemplatesList);

    CurrentUserName := GetCurrentUserName;

    PageControl.ActivePage := tsUsers;
    UserPageControl.ActivePage := tsBasicPage;
    SettingsPageControl.ActivePage := tsBasicSettings;

    PageControlChange(nil); //ensure VisibleGridIdx is initialized.

    {$IFDEF USE_SKINS}
    if SkinForm.cbSkinAtStartup.Checked then begin
      DebugForm.Memo.Lines.Add('Activating Skins');
      SkinForm.ActivateCurrentSkin;
    end;
    {$ENDIF}

    self.Visible := true;
    SplashForm.Hide;

    frmNotes:= TfrmNotes.Create(Self);

    DebugForm.Memo.Lines.Add('Done Initializing.');

    RemDlgInfo := TStringList.Create;
    RemDlgScreenMode := -1;
    XMLDlg := TXMLDlg.Create(self);
    ActivePopupEditForm.RecType := vpefNone;
    //ActivePopupEditForm.ActiveSubfileEditForm := nil;
    ActivePopupEditForm.EditForm := nil;
    //Call TMG INIFILE GET  --  VistA Config Hide Patient Tab, default 0, 1 and set tabvisible to false
    //Used to hide Reminderd  PageControl.Pages[4].TabVisible := False;
  end;


  Procedure TMainForm.LoadUsersTreeView(UsersList : TStringList);
  begin
    TreeViewU.LoadUsersTreeView(UsersTreeView, UsersList);
  end;

  Procedure TMainForm.LoadSettingsTreeView(RecordsList : TStringList;DestNode : TTreeNode);
  begin
    TreeViewU.LoadSettingsTreeView(SettingsTreeView, RecordsList, DestNode);
  end;

  procedure TMainForm.InitializeUsersTreeView;
  begin
    TreeViewU.InitializeUsersTreeView(UsersTreeView);
  end;

  procedure TMainForm.InitializeSettingsFilesTreeView;
  begin
    TreeViewU.InitializeSettingsFilesTreeView(SettingsTreeView);
  end;


  procedure TMainForm.FormDestroy(Sender: TObject);
  var i : integer;
      SL : TStringList;
  begin
    //kt tsReminders.PageControl := PageControl;

    BasicModeTemplate.Free;
    DlgTemplate.Free;
    DlgPromptTemplate.Free;
    DlgForcedVTemplate.Free;
    DlgGroupTemplate.Free;
    DlgRsltGroupTemplate.Free;
    DlgElementTemplate.Free;
    DlgRsltElementTemplate.Free;
    for i := 0 to RemFindingsTemplatesList.Count - 1 do begin
      SL := TStringList(RemFindingsTemplatesList.Objects[i]);
      SL.Free
    end;
    RemFindingsTemplatesList.Free;

    CurrentFileEntry.Free;

    User.Free;
    Encounter.Free;
    Patient.Free;
    Changes.Free;
    RemDlgInfo.Free;
    XMLDlg.Free;
  end;


  procedure TMainForm.FormShow(Sender: TObject);
  Var AHandle: HWnd;
  begin
    AHandle := pnlVennDisplay.Handle;
    VennForm.ParentWindow := AHandle;
    VennForm.Show;
    VennForm.Visible := true;
    VennForm.OnDisplayRefreshNeeded := HandleVennFormRefreshRequest;
    pnlVennDisplayResize(Sender);
  end;


  procedure TMainForm.CheckShouldAllowTreeNodeChange(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
  begin
    AllowChange := (PostVisibleGrid <> mrNO);
    if AllowChange then begin
      LastSelTreeNode := Node;
      LastSelTreeView := TTreeView(Sender);
    end;
  end;

  
  procedure TMainForm.UsersTreeViewChange(Sender: TObject; Node: TTreeNode);
  var  IEN : longInt;
       GridInfo : TGridInfo;
  begin
    //get info from selected node.
    LastSelTreeNode := Node;
    LastSelTreeView := TTreeView(Sender);
    IEN := longInt(Node.Data);
    if IEN = 0 then exit;
    GridInfo := GetInfoObjectForGrid(BasicUsersGrid);
    if GridInfo = nil then exit;
    GridInfo.IENS := IntToStr(IEN) + ',';
    GetUserDataAndLoadIntoGrids(GridInfo);
  end;

  procedure TMainForm.SettingsTreeViewChange(Sender: TObject; Node: TTreeNode);
  var  IEN : longInt;
       FileNum : string;
       GridInfo : TGridInfo;
  begin
    //get info from selected node.
    LastSelTreeNode := Node;
    LastSelTreeView := TTreeView(Sender);
    GridInfo := GetInfoObjectForGrid(BasicSettingsGrid);
    if GridInfo = nil then exit;
    IEN := longInt(Node.Data);
    if IEN = 0 then exit;
    FileNum := FileNumForSettingsNode (Node);
    if FileNum = '' then exit;
    GridInfo.IENS := IntToStr(IEN) + ',';
    GridInfo.FileNum := FileNum;
    GetSettingsInfoAndLoadIntoGrids(GridInfo);
  end;

  function TMainForm.FileNumForSettingsNode (Node : TTreeNode) : string;
  var index : integer;
      Parent : TTreeNode;
  begin
    Result := '';
    Parent := Node.Parent;
    if Parent <> nil then begin
      index := integer(Parent.Data);
      if (index >0) and (index < SettingsFiles.count) then Result := SettingsFiles.Strings[index];
    end;
  end;

  function TMainForm.GetCursorImage : TCursor;
  begin
    //All should be the same, so just return first from list (See SetCursorImage)
    Result := BasicUsersGrid.Cursor;
  end;


  procedure TMainForm.SetCursorImage(Cursor : TCursor);
  begin
    BasicUsersGrid.Cursor := Cursor;
    AdvancedUsersGrid.Cursor := Cursor;
    UsersTreeView.Cursor := Cursor;

    BasicSettingsGrid.Cursor := Cursor;
    AdvancedSettingsGrid.Cursor := Cursor;
    SettingsTreeView.Cursor := Cursor;

    PatientORComboBox.Cursor := Cursor;
    BasicPatientGrid.Cursor := Cursor;
    AdvancedPatientGrid.Cursor := Cursor;
  end;

  procedure TMainForm.GetRecordsInfoAndLoadIntoGrids(GridInfo : TGridInfo; GridList : TList; CmdName : string='');
  //Purpose: Get all fields from server for one record.
  var PriorCursor : TCursor;
  begin
    PriorCursor := GetCursorImage;
    SetCursorImage(crHourGlass);
    GridU.GetRecordsInfoAndLoadIntoGrids(GridInfo, GridList, CmdName);
    SetCursorImage(PriorCursor);
  end;

  procedure TMainForm.GetUserDataAndLoadIntoGrids(GridInfo : TGridInfo);
  //Purpose: Get all fields from server for one record.
  begin
    GetRecordsInfoAndLoadIntoGrids(GridInfo, UsersGridList);
  end;

  procedure TMainForm.GetSettingsInfoAndLoadIntoGrids(GridInfo : TGridInfo);
  //Purpose: Get all fields from server for one record.
  begin
    GetRecordsInfoAndLoadIntoGrids(GridInfo, SettingsGridList);
  end;

  procedure TMainForm.GetPatientInfoAndLoadIntoGrids(GridInfo : TGridInfo);
  //Purpose: Get all fields from server for one record.
  begin
    GetRecordsInfoAndLoadIntoGrids(GridInfo, PatientsGridList);
  end;

  procedure TMainForm.GetRemDlgFilesInfoAndLoadIntoGrids(GridInfo : TGridInfo);
  //Purpose: Get all fields from server for one record.
  begin
    GetRecordsInfoAndLoadIntoGrids(GridInfo, DlgsGridList, '');
  end;

  procedure TMainForm.GetRemDlgFilesInfoAndLoadIntoGridsFiltered(GridInfo : TGridInfo; GridFilter : string='');
  //Purpose: Get all fields from server for one record.
  begin
    GetRecordsInfoAndLoadIntoGrids(GridInfo, DlgsGridList, GridFilter);
  end;

  procedure TMainForm.ClearRemDlgGrids;
  begin
    ClearGridList(DlgsGridList);
  end;

  procedure TMainForm.GetAllFilesInfoAndLoadIntoGrids(GridInfo : TGridInfo);
  //Purpose: Get all fields from server for one record.
  begin
    GetRecordsInfoAndLoadIntoGrids(GridInfo, AnyFileGridList);
  end;

  procedure TMainForm.GetRemDefInfo(GridInfo : TGridInfo);
  //Purpose: Get all fields from server for one record.
  begin
    GetRecordsInfoAndLoadIntoGrids(GridInfo, RemDefGridList);
  end;

  function TMainForm.PatientIENSSelector() : string;
  begin
    Result := IntToStr(PatientORComboBox.ItemID) + ',';
  end;

  function TMainForm.AnyFileIENSSelector() : string;
  begin
    Result := IntToStr(RecordORComboBox.ItemID) + ',';
  end;

  procedure TMainForm.GridSelectCell(Sender: TObject; ACol, ARow: Integer;
                                     var CanSelect: Boolean);
  begin
    GridU.GridSelectCell(Sender,  ACol, ARow, CanSelect, LastSelTreeNode,
                         TMG_Auto_Press_Edit_Button_In_Detail_Dialog);
  end;

  procedure TMainForm.btnUsersRevertClick(Sender: TObject);
  begin
    DoRevert(BasicUsersGrid,AdvancedUsersGrid);
  end;

  function TMainForm.DisuserChanged(Changes: TStringList) : boolean;
  var i : integer;
  //Changes format:
  // FileNum^IENS^FieldNum^FieldName^newValue^oldValue
  begin
    result := false;
    for i := 0 to Changes.Count-1 do begin
      if piece(Changes.Strings[i],'^',1)<> '200' then continue;
      if piece(Changes.Strings[i],'^',4)<> 'DISUSER' then continue;
      result := true;
      break;
    end;
  end;

  procedure TMainForm.btnUsersApplyClick(Sender: TObject);
  var result : TModalResult;
  begin
    result:= PostVisibleGrid;
    if result <> mrNone then InitializeUsersTreeView;
  end;

  procedure TMainForm.GridSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: String);
  begin
    btnUsersRevert.Enabled := true;
    btnUsersApply.Enabled := true;
  end;

  procedure TMainForm.BasicSettingsGridSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: String);
  begin
    btnSettingsRevert.Enabled := true;
    btnSettingsApply.Enabled := true;
  end;


  procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
  begin
    PostVisibleGrid;
    RPCBrokerV.Connected := false; //disconnect
  end;

  procedure TMainForm.EnterLabs1Click(Sender: TObject);
  var
    frmLabEntry: TfrmLabEntry;
  begin
    frmLabEntry := TfrmLabEntry.Create(Self);
    frmLabEntry.ShowModal;
    frmLabEntry.Free;
  end;

  procedure TMainForm.ExitMenuItemClick(Sender: TObject);
  begin
    Close;
  end;

  procedure TMainForm.UserPageControlDrawTab(Control: TCustomTabControl; TabIndex: Integer;
                                             const Rect: TRect; Active: Boolean);
  begin
    DrawTab(Control,TabIndex,Rect,Active);
  end;

  procedure TMainForm.DrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
  var
    oRect    : TRect;
    sCaption,temp : String;
    iTop     : Integer;
    iLeft    : Integer;
    i        : integer;

  begin
    oRect    := Rect;
    temp := TPageControl(Control).Pages[TabIndex].Caption;
    for i := 1 to length(temp) do begin
      if temp[i] <> '&' then sCaption := sCaption + temp[i];
    end;
    
    iTop     := Rect.Top  + ((Rect.Bottom - Rect.Top  - Control.Canvas.TextHeight(sCaption)) div 2) + 1;
    iLeft    := Rect.Left + ((Rect.Right  - Rect.Left - Control.Canvas.TextWidth (sCaption)) div 2) + 1;
    if Active then begin
       Control.Canvas.Brush.Color := TColor($0000FFFF);  //Bright yellow
       Control.Canvas.FillRect(Rect);
//       Frame3d(Control.Canvas,oRect,clBtnHighLight,clBtnShadow,3);

     end else begin
       Control.Canvas.Brush.Color := TColor($000079EFE8);  //dull yellow
       Control.Canvas.FillRect(Rect);
     end;
     Control.Canvas.TextOut(iLeft,iTop,sCaption);
  end;


  procedure TMainForm.AboutMenuClick(Sender: TObject);
  begin
    AboutForm.show;
  end;

  procedure TMainForm.CloneBtnClick(Sender: TObject);
  var IEN : longInt;
      newName : string;
      IENS,newIENS : string;
      
  begin
    if btnUsersApply.Enabled then btnUsersApplyClick(self);  //post any changes first.
    if MessageDlg('Clone user: '+LastSelTreeNode.Text+' --> New user?' + #10 + #13 +
                  'Note: This can not be undone.',
                  mtConfirmation, mbOKCancel,0) = mrCancel then exit;
    IEN := longInt(LastSelTreeNode.Data);
    IENS := IntToStr(IEN) + ',';
    WaitForm.Show;
    newName := 'TEMP,MUST-EDIT';
    newIENS := DoCloneUser(IENS,newName);
    InitializeUsersTreeView;  //refresh UsersTreeView.
    WaitForm.Hide;
    MessageDlg('A new cloned user has been created,' + #10 + #13 +
                  'named: ' + newName + #10 + #13 +
                  #10 + #13 +
                  'This user can be found in the ''Inactive users'' list,' + #10 + #13 +
                  'but must must be edited before it may be used.' + #10 + #13 +
                  'Edit it''s DISUSER field to a value of ''NO''' + #10 + #13 +
                  'to activate.',mtInformation,[mbOK],0);
  end;

  procedure TMainForm.ApplicationEventsIdle(Sender: TObject; var Done: Boolean);
  begin
  end; (*ApplicationIdle*)


  procedure TMainForm.ApplicationEventsShowHint(var HintStr: String;
                                                var CanShow: Boolean;
                                                var HintInfo: THintInfo);

    function OverWinControl(W : TWinControl; Pos : TPoint) : boolean;
    begin
      Result := false;
      if Pos.X < W.Left then exit;
      if Pos.Y < W.Top then exit;
      if Pos.X > (W.Left + W.Width) then exit;
      if Pos.Y > (W.Top + W.Height) then exit;
      Result := true;
    end;

    function TranslatePos(W : TWinControl; Pos : TPoint) : TPoint;
    begin
      Result.X := Pos.X - W.Left;
      Result.Y := Pos.Y - W.Top;
    end;

  var
      Pos         : TPoint;
      Handle      : Hwnd;
      CurClassName   : AnsiString;
      ACol,ARow   : integer;
      VisibleGridInfo : TGridInfo;
      ActiveSubfileEditForm : TfrmMultiRecEdit; //doesn't own object
      ActiveOneRecEditForm  : TfrmOneRecEdit; //doesn't own object

  begin
    CanShow := true;
    VisibleGridInfo := nil;
    Pos := Mouse.CursorPos;
    if (ActivePopupEditForm.RecType <> vpefNone) then begin
      case ActivePopupEditForm.RecType of
        vpefSubFile : begin
          ActiveSubfileEditForm := TfrmMultiRecEdit(ActivePopupEditForm.EditForm);
          Pos := ActiveSubfileEditForm.ScreenToClient(Pos);
          if not OverWinControl(ActiveSubfileEditForm.RightPanel, Pos) then exit;
          Pos := TranslatePos(ActiveSubfileEditForm.RightPanel, Pos);
          if not OverWinControl(ActiveSubfileEditForm.SubFileGrid, Pos) then exit;
          VisibleGridInfo := ActiveSubfileEditForm.GridInfo;
        end;
        vpefOneRec : begin
          ActiveOneRecEditForm := TfrmOneRecEdit(ActivePopupEditForm.EditForm);
          Pos := ActiveOneRecEditForm.ScreenToClient(Pos);
          if not OverWinControl(ActiveOneRecEditForm.pnlBottom, Pos) then exit;
          Pos := TranslatePos(ActiveOneRecEditForm.pnlBottom, Pos);
          if not OverWinControl(ActiveOneRecEditForm.OneRecGrid, Pos) then exit;
          VisibleGridInfo := ActiveOneRecEditForm.GridInfo;
        end;
      end;
    end else begin
      Handle := WindowFromPoint(Pos);
      if Handle = 0 then Exit;
      CurClassName := GetAClassName(Handle);
      if (CurClassName <> 'TSortStringGrid') then exit;
      Windows.ScreenToClient(Handle, Pos);
      VisibleGridInfo :=  GetVisibleGridInfo;
    end;
    if VisibleGridInfo = nil then exit;
    if VisibleGridInfo.Grid = nil then exit;
    VisibleGridInfo.Grid.MouseToCell(Pos.X, Pos.Y, ACol,ARow);
    HintInfo.HintStr := GetGridHint(VisibleGridInfo.Grid,VisibleGridInfo.FileNum,ACol, ARow);
    if HintInfo.HintStr = '' then CanShow := False;
    HintInfo.HideTimeout := 1000;
    HintInfo.ReshowTimeout := 2000;
    HintInfo.HintMaxWidth:= 300;  //hint box width.
  end;

  procedure TMainForm.PageControlChanging(Sender: TObject; var AllowChange: Boolean);
  begin
    AllowChange := (PostVisibleGrid <> mrNO);
    if AllowChange then begin
      LastSelTreeNode := nil;
      LastSelTreeView := nil;
    end;
  end;

  procedure TMainForm.PatientORComboBoxNeedData(Sender: TObject; const StartFrom: String; Direction, InsertAt: Integer);
  var Result : TStrings;
  begin
    Result := SubsetofFile('2', StartFrom, Direction);
    TORComboBox(Sender).ForDataUse(Result);
  end;

  procedure TMainForm.PageControlChange(Sender: TObject);
  var RemindersMessage : TObject;
  begin
    RemindersMessage := nil;  //default signal of not active
    if (PageControl.ActivePage = tsUsers) then begin
      UserPageControlChange(nil);
    end else if (PageControl.ActivePage = tsSettings) then begin
      SettingsPageControlChange(nil);
    end else if (PageControl.ActivePage = tsPatients) then begin
      PatientsPageControlChange(nil);
    end else if (PageControl.ActivePage = tsAdvanced) then begin
      SetVisibleGridIdx(AllFilesGrid);
    end else if (PageControl.ActivePage = tsReminders) then begin
      RemindersMessage := sender;  //message of active
    end;
    RemindersPageControlChange(RemindersMessage);  //nil = signal to turn off VinDiagram animation
  end;

  procedure TMainForm.PatientORComboBoxClick(Sender: TObject);
  var  IEN : longInt;
       ModalResult : TModalResult;
       GridInfo : TGridInfo;
  begin
    ModalResult := PostVisibleGrid;
    if ModalResult = mrNo then exit;
    IEN := PatientORComboBox.ItemIEN;  //get info from selected patient
    if IEN = 0 then exit;
    GridInfo := GetInfoObjectForGrid(BasicPatientGrid);
    if GridInfo = nil then exit;
    GridInfo.IENS := IntToStr(IEN)+',';
    GetPatientInfoAndLoadIntoGrids(GridInfo);
  end;

  procedure TMainForm.PatientsPageControlChanging(Sender: TObject; var AllowChange: Boolean);
  begin     
    AllowChange := (PostVisibleGrid <> mrNO);
  end;

  procedure TMainForm.pnlVennDisplayResize(Sender: TObject);
  begin
    VennForm.Width := pnlVennDisplay.Width;
    VennForm.Height := pnlVennDisplay.Height;
  end;

  procedure TMainForm.PatientsPageControlChange(Sender: TObject);
  begin
    if PatientsPageControl.ActivePage = tsBasicPatients then begin
      SetVisibleGridIdx(BasicPatientGrid);
    end else begin
      SetVisibleGridIdx(AdvancedPatientGrid);
    end;
  end;


  procedure TMainForm.UserPageControlChanging(Sender: TObject; var AllowChange: Boolean);
  var result : TModalResult;
  begin
    result := PostVisibleGrid;
    AllowChange := (result <> mrNO);
    if (result <> mrNone) then begin
      InitializeUsersTreeView;
    end;  
  end;

  procedure TMainForm.UserPageControlChange(Sender: TObject);
  begin
    if UserPageControl.ActivePage = tsBasicPage then begin
      SetVisibleGridIdx(BasicUsersGrid);
    end else begin
      SetVisibleGridIdx(AdvancedUsersGrid);        
    end;  
  end;

  
  procedure TMainForm.SettingsPageControlChanging(Sender: TObject; var AllowChange: Boolean);
  begin
    AllowChange := (PostVisibleGrid <> mrNO);
  end;

  procedure TMainForm.SettingsPageControlChange(Sender: TObject);
  begin
    if SettingsPageControl.ActivePage = tsBasicSettings then begin
      SetVisibleGridIdx(BasicSettingsGrid);        
    end else begin
      SetVisibleGridIdx(AdvancedSettingsGrid);
    end;  
  end;

  procedure TMainForm.FileORComboBoxClick(Sender: TObject);
  begin
    PostVisibleGrid;
    InitORCombobox(RecordORComboBox,'');
    ClearGrid(GetVisibleGrid);
  end;

  procedure TMainForm.FileORComboBoxNeedData(Sender: TObject; const StartFrom: String; Direction, InsertAt: Integer);
  var  Result : TStrings;
  begin
    Result := SubsetofFile('1', StartFrom, Direction);
    TORComboBox(Sender).ForDataUse(Result);
  end;


  procedure TMainForm.RecordORComboBoxNeedData(Sender: TObject; const StartFrom: String; Direction, InsertAt: Integer);
  var  Result : TStrings;
       FileNum : string;
  begin
    FileNum := FileORComboBox.ItemID;
    Result := SubsetofFile(FileNum, StartFrom, Direction);
    TORComboBox(Sender).ForDataUse(Result);
  end;

  procedure TMainForm.RecordORComboBoxChange(Sender: TObject);
  begin
    LastSelTreeNode := nil;
    LastSelTreeView := nil;
  end;

procedure TMainForm.RecordORComboBoxClick(Sender: TObject);
  var ModalResult : TModalResult;
      IEN : LongInt;
      FileNum : String;
      GridInfo : TGridInfo;
  begin
    ModalResult := PostVisibleGrid;
    if ModalResult = mrNo then exit;
    FileNum := FileORComboBox.ItemID;
    IEN := RecordORComboBox.ItemID;  //get info from selected record
    if IEN=0 then exit;
    GridInfo := GetInfoObjectForGrid(AllFilesGrid);
    if GridInfo = nil then exit;
    GridInfo.IENS := IntToStr(IEN) + ',';
    GridInfo.FileNum := FileNum;
    GetAllFilesInfoAndLoadIntoGrids(GridInfo);
  end;

  procedure TMainForm.btnAddAnyRecordClick(Sender: TObject);
  var IENS, FileNum : string;
      BlankFileInfo : TStringList;
  begin
    BlankFileInfo := Tstringlist.Create;
    btnAdvancedRevert.Enabled := True;
    btnAdvancedApply.Enabled := True;
    FileNum := FileORComboBox.ItemID;
    IENS := '+1,';
    GetOneRecord(FileNum,IENS,CurrentAnyFileData, BlankFileInfo);

    LoadAnyGrid(GetInfoObjectForGrid(AllFilesGrid));
    BlankFileInfo.Free;
  end;

  procedure TMainForm.AddBtnClick(Sender: TObject);
  var IENS : string;
      BlankFileInfo : TStringList;
      GridInfo : TGridInfo;
  begin
    BlankFileInfo := Tstringlist.Create;
    btnPatientRevert.Enabled := True;
    btnPatientApply.Enabled := True;
    GridInfo := GetVisibleGridInfo;
    IENS := '+1,';
    GetOneRecord(GridInfo.FileNum, IENS, GridInfo.Data, BlankFileInfo);
    GridInfo.IENS := IENS;
    LoadAnyGrid(GridInfo);  //load Basic or Advanced Grid
    if GridInfo.Grid = BasicPatientGrid then begin
      GridInfo := GetInfoObjectForGrid(AdvancedPatientGrid)
    end else begin  //Advanced grid is visible.
      GridInfo := GetInfoObjectForGrid(BasicPatientGrid)
    end;
    GridInfo.IENS := IENS;
    LoadAnyGrid(GridInfo);  // Load OTHER grid, Advanced or Basic grid.
    BlankFileInfo.Free;
  end;

  procedure TMainForm.btnApplyClick(Sender: TObject);
  begin
    PostVisibleGrid;
  end;

  procedure TMainForm.btnRDefRevertClick(Sender: TObject);
  begin
    DoRevert(nil,RemDefGrid);
  end;

  procedure TMainForm.btnRDlgRevertClick(Sender: TObject);
  begin
    DoRevert(DlgsGridList, AdvRemDlgGrid, 0);
  end;

  procedure TMainForm.btnRevertClick(Sender: TObject);
  begin
    DoRevert(nil,AllFilesGrid);
  end;

  procedure TMainForm.AllFilesGridClick(Sender: TObject);
  begin
    btnAdvancedApply.Enabled := True;
    btnAdvancedRevert.Enabled := True;
  end;

  procedure TMainForm.btnBatchAddClick(Sender: TObject);
  begin
    BatchAddForm.ShowModal;
    InitORCombobox(PatientORComboBox,'A');
  end;

  procedure TMainForm.ShowDebugClick(Sender: TObject);
  begin
    DebugForm.Show;
  end;

  procedure TMainForm.ChangeSkinClick(Sender: TObject);
  var result : TModalResult;
  begin
    try
      result := SkinForm.ShowModal;
      case result of
        mrOK : SkinForm.ActivateCurrentSkin;
        mrNo : SkinForm.InactivateSkin;
      end; {case}
    except
      on EInvalidOperation do MessageDlg('Error1',mtInformation,[mbOK],0);
      else MessageDlg('Error Applying Skin.  Please try another Skin.',mtInformation,[mbOK],0);
    end;
  end;

  procedure TMainForm.InitORComboBox(ORComboBox: TORComboBox; initValue : string);
  var IENStr : string;
      IEN : LongInt;
  begin
    ORComboBox.Items.Clear;
    ORComboBox.Text := initValue;
    ORComboBox.InitLongList(initValue);
    if ORComboBox.Items.Count > 0 then begin
      ORComboBox.Text := Piece(ORComboBox.Items[0],'^',2);
      IENStr := Piece(ORComboBox.Items[0],'^',1);
      if (IENStr <> '') and (Pos('.', IENStr)=0) then begin
        IEN := StrToInt(IENStr);
        ORComboBox.SelectByIEN(IEN);
      end;
    end else begin
      ORComboBox.Text := '<Start Typing to Search>';
    end;
  end;


  procedure TMainForm.btnPatientApplyClick(Sender: TObject);  //Added elh 8/15/08
  begin
    PostVisibleGrid;
    InitORCombobox(PatientORComboBox,'A');
  end;

  procedure TMainForm.btnPatientRevertClick(Sender: TObject);    //Added elh 8/15/08
  begin
    DoRevert(BasicPatientGrid,AdvancedPatientGrid);
  end;

  procedure TMainForm.BasicPatientGridClick(Sender: TObject);     //Added elh 8/15/08
  begin
    btnPatientRevert.Enabled := true;
    btnPatientApply.Enabled := true;
  end;

  procedure TMainForm.ApplicationEventsException(Sender: TObject; E: Exception);
  begin
    if E.Message <> 'Cannot focus a disabled or invisible window' then begin
      ShowException(E,nil);
    end;
  end;


  procedure TMainForm.btnSettingsRevertClick(Sender: TObject);
  begin
    DoRevert(BasicSettingsGrid, AdvancedSettingsGrid);
  end;


  procedure TMainForm.btnSettingsApplyClick(Sender: TObject);
  begin
    PostVisibleGrid;
  end;


  procedure TMainForm.btnDelElementClick(Sender: TObject);

  var ParentNode, Node : TTreeNode;
      ParentName, Name : string;
      ModalResult : TModalResult;
      ParentIEN, IEN : longInt;
      //IENS : string;
      RecToDelete : TFMRecord;
      Fileman : TFileman;

    function FindRecToDelete(ParentIEN : longint; ItemName : string) : TFMRecord;
    //Note: results can be nil;
    var ComponentsSubfile, FMRemDlgFile : TFMFile;
        RemDlgRec : TFMRecord;
    begin
      Result := nil;
      FMRemDlgFile := Fileman.FMFile['801.41'];  //REMINDER DIALOG file
      RemDlgRec := FMRemDlgFile.FMRecord[IntToStr(ParentIEN)];
      ComponentsSubfile := RemDlgRec.FMField['10'].Subfile;
      Result := ComponentsSubfile.Search1Record(ItemName,'M'); // 'M' Flag is multiple index lookup.
    end;

  begin
    Node := tvElements.Selected;
    btnDelElement.Enabled := (Node <> nil);
    if Node = nil then exit;
    ParentNode := Node.Parent;
    btnDelElement.Enabled := (ParentNode <> nil);
    if ParentNode = nil then exit;
    ModalResult := PostVisibleGrid;
    if ModalResult = mrNo then exit;
    IEN := LongInt(Node.Data);
    ParentIEN := Integer(ParentNode.Data);
    Name := Node.Text;
    if (length(Name)>0) and (Name[1]='[') then begin
      Name := piece(Name, '] ', 2);
    end;
    ParentName := ParentNode.Text;
    if IEN = 0 then exit;
    if Messagedlg('Remove Element "' + Name + '" from "'+ParentName+'"?'+#13#10+
                  'NOTE: "'+ Name + '" itself will not be deleted.',
                  mtConfirmation, mbOKCancel, 0) <> mrOK then begin
      exit;
    end;
    Fileman := TFileman.Create;
    RecToDelete := FindRecToDelete(ParentIEN, Name);
    if RecToDelete <> nil then RecToDelete.DeleteRec;  //no confirmation to delete asked.
    Fileman.Free;
    Node.Delete;
    tvElements.Selected := ParentNode;
    HandleRemDlgOnAfterPost(nil, nil);  //Refresh display.
    //orcboSelRemDlgChange(self);  //Refresh display.
  end;

procedure TMainForm.btnDelRemDialogClick(Sender: TObject);
var
      IEN : longInt;
      RecToDelete : TFMFile;
      Fileman : TFileman;
  begin
    IEN := orcboSelRemDlg.ItemIEN;
    if IEN = 0 then exit;
//    orcboSelRemDlg.Text
    if Messagedlg('Remove Reminder Dialog "' + orcboSelRemDlg.Text + '"?'+#13#10+
                  'NOTE: This will remove it permanently!',
                  mtConfirmation, mbOKCancel, 0) <> mrOK then begin
      exit;
    end;
    FileMan := TFileman.Create;
    try
      RecToDelete := FileMan.FMFile['801.41'];
      if RecToDelete.DeleteRecord(IntToStr(IEN)) then begin
        cboDisplayDialogTypeChange(Sender);
      end;
    finally
      FileMan.Free;
    end;
    {orcmbSelRemDlg.
    {btnDelElement.Enabled := (Node <> nil);
    if Node = nil then exit;
    ParentNode := Node.Parent;
    btnDelElement.Enabled := (ParentNode <> nil);
    if ParentNode = nil then exit;
    ModalResult := PostVisibleGrid;
    if ModalResult = mrNo then exit;
    IEN := LongInt(Node.Data);
    ParentIEN := Integer(ParentNode.Data);
    Name := Node.Text;
    if (length(Name)>0) and (Name[1]='[') then begin
      Name := piece(Name, '] ', 2);
    end;
    ParentName := ParentNode.Text;
    if IEN = 0 then exit;
    if Messagedlg('Remove Element "' + Name + '" from "'+ParentName+'"?'+#13#10+
                  'NOTE: "'+ Name + '" itself will not be deleted.',
                  mtConfirmation, mbOKCancel, 0) <> mrOK then begin
      exit;
    end;
    Fileman := TFileman.Create;
    RecToDelete := FindRecToDelete(ParentIEN, Name);
    if RecToDelete <> nil then RecToDelete.DeleteRec;  //no confirmation to delete asked.
    Fileman.Free;
    Node.Delete;
    tvElements.Selected := ParentNode;
    HandleRemDlgOnAfterPost(nil, nil);  //Refresh display.
    //orcboSelRemDlgChange(self);  //Refresh display.
  end;                                               }
end;

procedure TMainForm.btnDelReminderClick(Sender: TObject);
  var IEN : LongInt;
      Name : string;
      FM : TFileman;
      RemDefFile : TFMFile;
      RemDefRec : TFMRecord;  //Owned by RemDefFile
  begin
    Name := orcboSelRemDef.Text;
    IEN := orcboSelRemDef.ItemIEN;
    if (IEN=0) or (Name = '') then begin
      MessageDlg('No Reminder Definition selected to delete', mtError, [mbOK], 0);
      exit;
    end;
    if MessageDlg('PERMANENTLY DELETE: '+ #13#10#10 +
                  '"' +  Name + '"?' + #13#10#10 +
                  'NOTE: This can not be undone.',   mtWarning,
                  [mbYes,mbNo],0) <> mrYes then begin
      exit;
    end;
    FM := TFileman.Create;
    try
      RemDefFile := FM.FMFile['811.9'];
      if RemDefFile.DeleteRecord(IntToStr(IEN)) then begin
        InitORCombobox(orcboSelRemDef,'A');
        orcboSelRemDefClick(Self);
      end;
    finally
      FM.Free;
    end;
  end;

  procedure TMainForm.btnFilterClick(Sender: TObject);
  var
    frmRemDefFilters: TfrmRemDefFilters;
    //s : string;
  begin
    frmRemDefFilters := TfrmRemDefFilters.Create(Self);
    frmRemDefFilters.Initialize(RemDefFilters);
    if frmRemDefFilters.ShowModal = mrOK then begin
      RemDefFilters := frmRemDefFilters.UserChosenFlags;
      InitORCombobox(orcboSelRemDef,'A');
      btnFilter.Caption := 'Show Types: '+ RemDefFilters;
    end;
    frmRemDefFilters.Free;
  end;



  // ------------ Reminder Dialog Stuff --------------------------

const
  RemDlgLinkedReminder = 0;  //index in cboDisplayDialogType
  RemDlgAll = 1;             //index in cboDisplayDialogType

  function TMainForm.InitRemDlgTab : boolean;
  //returns true if OK, false if aborted
  var
    debugForcePickPt : boolean;
    UserCancelled: boolean;
  begin
    result := false;  //default to error
    debugForcePickPt := false;
    if (Patient.DFN = '') or debugForcePickPt then begin
      MessageDlg('To work with reminders, the system must make'+#13#10 +
                 'reference to a sample patient and encounter.'+#13#10+
                 'Please click [OK] and then select these.',mtInformation,[mbOK],0);
      SelectPatient(false, 11, UserCancelled);
      if UserCancelled then exit;
      UpdateEncounter(NPF_PROVIDER);
    end;
    if not assigned(frmNotes) then begin
      frmNotes := TfrmNotes.Create(Self);
    end;
    frmNotes.ForceReminderShow;
    Result := true;
  end;

  procedure TMainForm.RemDlgNeedData(Sender: TObject; const StartFrom: String; Direction, InsertAt: Integer);
  var  Result : TStrings;
       FileNum : string;
       Scrn    : string;
  begin
    FileNum := '801.41';  //REMINDER DIALOG file
    if (RemDlgScreenMode <> 2) then begin  //2 is index in cboDisplayDialogType = ALL elements
      Scrn := '4=reminder dialog';
    end else Scrn := '';
    Result := SubsetofFile(FileNum, StartFrom, Direction, Scrn);
    ScreenRemDlgData(Result, RemDlgScreenMode);
    TORComboBox(Sender).ForDataUse(Result);
  end;

  procedure TMainForm.ScreenRemDlgData(Results : TStrings; Mode : Integer);
  begin
    if Mode <> RemDlgLinkedReminder then exit;
    if not Assigned(RemDlgInfo) then exit;
    if RemDlgInfo.Count = 0 then GetRemDlgInfo;
    // screen Results here...
  end;

  procedure TMainForm.GetRemDlgInfo;
  begin
   //rpc call here.
  end;

  procedure TMainForm.cboDisplayDialogTypeChange(Sender: TObject);
  begin
    RemDlgInfo.Clear;
    GetRemDlgInfo;
    RemDlgScreenMode := cboDisplayDialogType.ItemIndex;
    //
    InitORCombobox(orcboSelRemDlg,'A');
  end;

  procedure TMainForm.orcboSelRemDlgClick(Sender: TObject);
  var  IEN : longInt;
       ModalResult : TModalResult;
       //GridInfo : TGridInfo;
  begin
    ModalResult := PostVisibleGrid;
    if ModalResult = mrNo then exit;
    CloseAnyRemDlgForm; //kt
    ClearRemDlgGrids;
    IEN := orcboSelRemDlg.ItemIEN;  //get info from Reminder Dialog
    //if SelectedDialogIEN = IEN then exit;
    SelectedDialogIEN := IEN;
    if IEN = 0 then exit;
    //SetupRemDlgGrids(IEN);
    btnAddChild.Enabled := false;  //default
    btnDelElement.Enabled := false; //default
    LoadRemDlgSubRecords(IntToStr(IEN)+',');
    tvElements.Selected := tvElements.TopItem;
    tvElementsClick(Self);
    btnLaunchRemDlgClick(self);  //kt
  end;

  procedure TMainForm.LoadRemDlgSubRecords(IENS: String);
  var Parent : TTreeNode;
      IEN : string;
  begin
    tvElements.Items.Clear;
    CloseAnyRemDlgForm;
    Parent := tvElements.Items.Add(nil, orcboSelRemDlg.Text); { Add root node }
    Parent.ImageIndex := 8;
    Parent.SelectedIndex := 8;
    Parent.StateIndex := 7;
    IEN := piece(IENS,',',1);
    Parent.Data := Pointer(StrToInt64Def(IEN,0));
    SetCursorImage(crHourGlass);
    LoadElementTree(Parent,IENS);
    SetCursorImage(crDefault);
    if Parent.HasChildren then Parent.Expand(False);
    //kt if tvElements.Items[0].HasChildren then begin
    //kt  tvElements.Items[0].Expand(False);
    //kt end;
  end;

  CONST
    EMPTY_NODE = '<EMPTY>';

  procedure TMainForm.LoadElementTree(Parent : TTreeNode; ParentIENS: string);
  var
    NewNode, Child : TTreeNode;
    i : integer;
    SubRecords : TStringList;
    //dataLine : integer;
    StrItemIEN : string;
    ItemIEN : longInt;
    FileNum, IENS : string;
    oneEntry, SeqNum, Name, Text : string;
    //SubFileForm : TfrmMultiRecEdit;
    GridInfo : TGridInfo;
    NodeType : string;
    //temp : boolean;
    //RPCStringsResult : TStrings;

    FM : TFileman;
    RemDlgFMFile : TFMFile;          //owned by FM
    ParentRemDlgRecord : TFMRecord;  //owned by FM
    OneRemDlgRecord : TFMRecord;     //owned by FM
    ComponentsSubFile : TFMFile;     //owned by FM
    tempMap : string;

  begin
    //-------------
    GridInfo := GetInfoObjectForGrid(AdvRemDlgGrid);
    if GridInfo = nil then exit;
    FileNum := GridInfo.FileNum;  //kt
    FM := TFileman.Create;
    //-------------
    SubRecords := TStringList.Create;
    try
      RemDlgFMFile := FM.FMFile[FileNum];
      ParentRemDlgRecord := RemDlgFMFile.FMRecord[ParentIENS];
      //Rename parent (will keep same if not changed)
      Name := ParentRemDlgRecord.FMField['.01'].Value;
      NodeType := UpperCase(ParentRemDlgRecord.FMField['4'].Value);
      Parent.Text := '[' +NodeType + '] ' + Name;

      ComponentsSubFile := ParentRemDlgRecord.FMField['10'].Subfile;
      ComponentsSubFile.GetRecordsListRaw(SubRecords, tempMap, '.01;2I');
      for i := 0 to SubRecords.Count -1 do begin
        oneEntry := SubRecords.Strings[i];
        StrItemIEN := Piece(oneEntry,'^',4);
        ItemIEN := StrToInt64Def(StrItemIEN,0);
        if ItemIEN=0 then continue;
        SeqNum := Piece(oneEntry,'^',2);
        if Pos('.',SeqNum)=0 then SeqNum := SeqNum + '.0';
        while Length(SeqNum) < 5 do SeqNum := '0'+SeqNum;
        Text := Trim(piece(oneEntry,'^',5));
        IENS := StrItemIEN + ',';  //kt
        OneRemDlgRecord := RemDlgFMFile.FMRecord[IENS];
        NodeType := UpperCase(OneRemDlgRecord.FMField['4'].Value);
        Name := SeqNum + ' [' +NodeType + '] ' + Text;
        NewNode := tvElements.Items.AddChildObject(Parent, Name, Pointer(ItemIEN));
        tvElements.Items.AddChildObject(NewNode, EMPTY_NODE, nil);
        NewNode.ImageIndex := 8;
        NewNode.SelectedIndex := 8;
        NewNode.StateIndex := 7;
        //LoadElementTree(NewNode,StrItemIEN+',', Depth+1); <-- done in Expanding Event
      end;
      Parent.AlphaSort(False);  //Sort by sequence number
      for i := 0 to Parent.Count-1 do begin
        Child := Parent.Item[i];
        Child.Text := MidStr(Child.Text, 7, Length(Child.Text));
      end;
    finally
      SubRecords.Free;
      FM.Free;
    end;

    {
    //-------------
    GridInfo := GetInfoObjectForGrid(AdvRemDlgGrid);
    if GridInfo = nil then exit;
    FileNum := GridInfo.FileNum;  //kt
    //-------------
    SubRecords := TStringList.Create;
    SubFileForm := TfrmMultiRecEdit.Create(self);
    try
      SubFileForm.PrepForm('801.412',ParentIENS);
      SubFileForm.GetAllSubRecords(SubRecords,'.01;2I');
      for i := 0 to SubRecords.Count -1 do begin
        oneEntry := SubRecords.Strings[i];
        StrItemIEN := Piece(oneEntry,'^',4);
        ItemIEN := StrToInt64Def(StrItemIEN,0);
        if ItemIEN=0 then continue;
        SeqNum := Piece(oneEntry,'^',2);
        while Length(SeqNum) < 3 do SeqNum := '0'+SeqNum;
        Text := Trim(piece(oneEntry,'^',5));
        //-------------
        //kt GridInfo.IENS := StrItemIEN + ',';
        IENS := StrItemIEN + ',';  //kt
        temp := RPCGetRecordInfo(RPCStringsResult, FileNum, IENS);   //kt
        if temp = false then continue;  //kt
        //GetRemDlgFilesInfo(GridInfo);
        //kt oneEntry := getOneLine(GridInfo.Data,'801.41','4');
        oneEntry := getOneLine(RPCStringsResult,'801.41','4');  //kt
        NodeType := UpperCase(Piece(oneEntry,'^',4));
       //-------------
        Name := SeqNum + ' [' +NodeType + '] ' + Text;
        NewNode := tvElements.Items.AddChildObject(Parent, Name, Pointer(ItemIEN));
        tvElements.Items.AddChildObject(NewNode, EMPTY_NODE, nil);
        NewNode.ImageIndex := 8;
        NewNode.SelectedIndex := 8;
        NewNode.StateIndex := 7;
        //tvElements.Invalidate;
        //Application.ProcessMessages;
        //LoadElementTree(NewNode,StrItemIEN+',', Depth+1); <-- done in Expanding Event
      end;
      Parent.AlphaSort(False);  //Sort by sequence number
      for i := 0 to Parent.Count-1 do begin
        Child := Parent.Item[i];
        Child.Text := MidStr(Child.Text,5, Length(Child.Text));
      end;
    finally
      SubRecords.Free;
      SubFileForm.Free;
    end;
    }
  end;

  procedure TMainForm.ReLoadElementTreeNode(Node : TTreeNode);
  var ItemIEN : integer;
      Expanded : boolean;
  begin
    Expanded := Node.Expanded;
    Node.DeleteChildren;
    ItemIEN := Integer(Node.Data);
    if ItemIEN > 0 then begin
      SetCursorImage(crHourGlass);
      LoadElementTree(Node,IntToStr(ItemIEN)+',');
      If Expanded then Node.Expand(false);
    end;
  end;


  procedure TMainForm.tvElementsExpanding(Sender: TObject; Node: TTreeNode;
                                          var AllowExpansion: Boolean);
  var  ItemIEN : integer;
       ChildNode : TTreeNode;
  begin
    AllowExpansion := true;
    ChildNode := Node.GetFirstChild;
    if Assigned(ChildNode) and (ChildNode.Text = EMPTY_NODE) then begin
      ChildNode.Delete;
      Node.DeleteChildren;
      ItemIEN := Integer(Node.Data);
      if ItemIEN > 0 then begin
        SetCursorImage(crHourGlass);
        LoadElementTree(Node,IntToStr(ItemIEN)+',');
        AllowExpansion := true;
        SetCursorImage(crDefault);
      end;
    end;
  end;

  procedure TMainForm.RemDlgExpandElement(IEN : string; Expanded : boolean);
  var i : integer;
      numIEN : integer;
      Node : TTreeNode;
  begin
    if MainFormTriggeringRemDlgChanges then exit;
    for i := 0 to tvElements.Items.Count-1 do begin
      try       //kt   research why this is necessary
        Node := tvElements.Items.Item[i];
        numIEN := Integer(Node.Data);
        if IntToStr(numIEN) <> IEN then continue;
        if Expanded then begin
          Node.Expand(False);
        end else begin
          Node.Collapse(False);
        end;
        tvElements.Selected := Node;
      except
        on ETreeViewError do continue;
      end;
    end;
  end;


  procedure TMainForm.RemDlgDisplayElement(IEN : string);
  //NOTE: This should only be called rendered/displayed reminder dialog
  //Assumption: That Reminder Dialog tab is displayed
  //That orcboSelRemDlg is selected to match rendered reminder dialog
  //That tvElements is loaded with all elements for reminder dialog.
  var i : integer;
      numIEN : integer;
      Node : TTreeNode;
  begin
    if MainFormTriggeringRemDlgChanges then exit;
    for i := 0 to tvElements.Items.Count-1 do begin
      Node := tvElements.Items.Item[i];
      numIEN := Integer(Node.Data);
      if IntToStr(numIEN) <> IEN then continue;
      tvElements.Select(Node);
      tvElementsClick(Self);
    end;
  end;

  procedure TMainForm.tvElementsCustomDrawItem(Sender: TCustomTreeView;
                                               Node: TTreeNode;
                                               State: TCustomDrawState;
                                               var DoDefaultDraw: Boolean);
  var
    NodeRect: TRect;
  begin
    with tvElements.Canvas do begin
      Brush.Color :=  clWindow;
      Pen.Color := clWindow;
      Rectangle(NodeRect);
      if cdsSelected in State then begin
        //Font.Assign(SelectedFontDialog.Font);
        Font.Color := clBlack;
        Font.Style := [fsBold];
        Brush.Color := clYellow;
      {
      end else if Node = NodeBeingDraggedOver then begin
        Font.Color := clBlack;
        //Brush.Color := clGreen;
        Font.Style := [fsBold];
      }
      end else begin
        Font.Color := clBlack;
        Font.Style := [];
      end;

      NodeRect := Node.DisplayRect(False);
      tvElements.Canvas.Rectangle(NodeRect);
    end;
  end;

  procedure TMainForm.tvElementsClick(Sender: TObject);
  var ParentNode, Node : TTreeNode;
      IEN : longInt;
      ModalResult : TModalResult;
      //GridInfo : TGridInfo;
      //NodeType, oneEntry : string;
      ElementType : string;
  begin
    Node := tvElements.Selected;
    btnAddChild.Enabled := (Node <> nil);
    if Node = nil then begin
      btnDelElement.Enabled := false;
      exit;
    end;
    ParentNode := Node.Parent;
    btnDelElement.Enabled := (ParentNode <> nil);
    ModalResult := PostVisibleGrid;
    if ModalResult = mrNo then exit;
    IEN := Integer(Node.Data);
    ElementType := Piece(Node.Text,']',1);
    ElementType := Piece(ElementType,'[',2);
    SetupRemDlgGrids(IEN, ElementType);
    SyncTVElementToRemDlg(Node, false);
  end;


  procedure TMainForm.SetupRemDlgGrids(IEN : LongInt; ElementType : string);
  var ModalResult : TModalResult;
      GridInfo : TGridInfo;
      ShowPage, OnePage : TTabSheet;
      AGrid : TSortStringGrid;
      i : integer;
      NodeType, oneEntry : string;
      ElementClass : string;
      GridFilter : string;
  begin
    ModalResult := PostVisibleGrid;
    if ModalResult = mrNo then exit;
    SelectedDialogIEN := IEN;
    if IEN = 0 then exit;
    GridInfo := GetInfoObjectForGrid(AdvRemDlgGrid);
    if GridInfo = nil then exit;
    GridInfo.IENS := IntToStr(IEN)+',';
    //moved lower --> GetRemDlgFilesInfoAndLoadIntoGrids(GridInfo);
    //oneEntry := getOneLine(GridInfo.Data,'801.41','4');
    //NodeType := UpperCase(Piece(oneEntry,'^',4));
    GridFilter := GRID_FILTER+'^';
    NodeType := ElementType;
    if NodeType = 'PROMPT'              then ShowPage := tsRemDlgPrompt
    else if NodeType = 'DIALOG ELEMENT' then ShowPage := tsRemDlgElement
    else if NodeType = 'FORCED VALUE'   then ShowPage := tsRemDlgForcedValue
    else if NodeType = 'DIALOG GROUP'   then ShowPage := tsRemDlgGroup
    else if NodeType = 'RESULT GROUP'   then ShowPage := tsRemDlgRsltGroup
    else if NodeType = 'RESULT ELEMENT' then ShowPage := tsRemDlgRsltElement
    else {'REMINDER DIALOG'}                 ShowPage := tsReminderDialog;
    if ShowPage <> RemDlgPageControl.ActivePage then begin
      RemDlgPageControl.ActivePage := tsRemDlgAdvanced;  //temp, while setting visibilities
    end;
    AGrid := RemDlgGridOnTabSheet(ShowPage);
    GridFilter := GridFilter + IntToStr(DlgsGridList.IndexOf(AGrid)) + '^';
    GridFilter := GridFilter + IntToStr(DlgsGridList.IndexOf(AdvRemDlgGrid)) + '^';
    for i := 0 to RemDlgPageControl.PageCount - 2 do begin  //-2 because last page is AdvancedPage - always visable.
      OnePage := RemDlgPageControl.Pages[i];
      OnePage.TabVisible := (OnePage = ShowPage);
    end;
    GetRemDlgFilesInfoAndLoadIntoGridsFiltered(GridInfo, GridFilter);
    oneEntry := getOneLine(GridInfo.Data,'801.41','100');
    ElementClass := Piece(oneEntry,'^',4);
    //Later allow user authorization to over-ride read-only status...
    GridInfo.ReadOnly := (ElementClass = 'NATIONAL') or (ElementClass = 'VISN');
    RemDlgPageControl.ActivePage := ShowPage;
    RemDlgPageControlChange(Self);  //Ensure VisibleGridIdx is correct
  end;


  procedure TMainForm.SyncTVElementToRemDlg(Node : TTreeNode; CheckNodeCB : boolean = false);
  var
    tempIEN : longInt;
    SelectedIENStr, IENStr : string;
    i, i2 : integer;
    ParentSL : TStringList;
    Parent : TTreeNode;
  begin
    if not assigned(frmRemDlg) then exit;
    if not assigned(Node) then exit;
    SelectedIENStr := IntToStr(Integer(Node.Data));
    ParentSL := TStringList.Create;
    repeat
      Parent := Node.Parent;
      if assigned(Parent) then begin
        TempIEN := Integer(Node.Data);
        ParentSL.Add(IntToStr(TempIEN));
        Node := Parent;
      end;
    until not assigned(Parent);
    MainFormTriggeringRemDlgChanges := true;
    if CheckNodeCB then i2 := 0 else i2 := 1;
    for i := ParentSL.Count-1 downto i2 do begin
      IENStr := ParentSL.Strings[i];
      frmRemDlg.TMGSetCBValueForControl(IENStr, true);
    end;
    MainFormTriggeringRemDlgChanges := false;
    Application.ProcessMessages;
    frmRemDlg.TMGHighlightControl(SelectedIENStr);
    ParentSL.Free;
  end;

  procedure TMainForm.tvElementsOpenedOrClosed(Sender: TObject; Node: TTreeNode);
  var
    SelectedIENStr : string;
  begin
    if MainFormTriggeringRemDlgChanges then exit;
    if not assigned(Node) then exit;
    if not assigned(frmRemDlg) then exit;
    SelectedIENStr := IntToStr(Integer(Node.Data));
    MainFormTriggeringRemDlgChanges := true;
    frmRemDlg.TMGSetCBValueForControl(SelectedIENStr, Node.Expanded);
    MainFormTriggeringRemDlgChanges := false;
    Application.ProcessMessages;
    frmRemDlg.TMGHighlightControl(SelectedIENStr);
  end;

  function TMainForm.RemDlgIENSSelector() : string;
  begin
    //Later I will vary this depending on if Advanced or basic shown...
    Result := IntToStr(SelectedDialogIEN) + ',';
  end;

  function TMainForm.RemDefIENSSelector() : string;
  begin
    Result := IntToStr(orcboSelRemDef.ItemID) + ',';
  end;

  procedure TMainForm.btnAddChildClick(Sender: TObject);
  //NOTE: if Sender=nil then coming from btnAddRemDialogClick
  var Node : TTreeNode;
      IEN : longInt;
      strIEN : string;
      ModalResult : TModalResult;
      frmAddRemDlgItem: TfrmAddRemDlgItem;

  begin
    ModalResult := PostVisibleGrid;
    if ModalResult = mrNo then exit;
    if Sender = nil then begin
      strIEN := '+1';
    end else begin
      Node := tvElements.Selected;
      btnAddChild.Enabled := (Node <> nil);
      if Node = nil then exit;
      IEN := Integer(Node.Data);
      if IEN = 0 then exit;
      strIEN := IntToStr(IEN);
    end;
    frmAddRemDlgItem := TfrmAddRemDlgItem.Create(Self);
    frmAddRemDlgItem.Initialize(strIEN);
    frmAddRemDlgItem.ShowModal;
    if frmAddRemDlgItem.RefreshIndicated then begin
      HandleRemDlgOnAfterPost(nil, nil);
      //orcboSelRemDlgClick(Sender); //refresh tree;
    end;
    frmAddRemDlgItem.Free;
  end;

  function TMainForm.RemDlgGridOnTabSheet(TabSheet : TTabSheet) : TSortStringGrid;
  begin
    if TabSheet = tsReminderDialog then begin
      Result := RemDlgGrid;
    end else if TabSheet = tsRemDlgElement then begin
      Result := RemDlgElementGrid;
    end else if TabSheet = tsRemDlgPrompt then begin
      Result := RemDlgPromptGrid;
    end else if TabSheet = tsRemDlgForcedValue then begin
      Result := RemDlgForcedVGrid;
    end else if TabSheet = tsRemDlgGroup then begin
      Result := RemDlgGroupGrid;
    end else if TabSheet = tsRemDlgRsltGroup then begin
      Result := RemDlgRsltGroupGrid;
    end else if TabSheet = tsRemDlgRsltElement then begin
      Result := RemDlgRsltElementGrid;
    end else if TabSheet = tsRemDlgAdvanced then begin
      Result := AdvRemDlgGrid;
    end else begin
      Result := nil;
    end;
  end;

  procedure TMainForm.RemDlgPageControlChange(Sender: TObject);
  //Note: if Sender = nil, that will be taken as signal that a parent
  //      page control is on different page.
  var AGrid : TSortStringGrid;
  begin
    if not assigned(Sender) then exit;
    AGrid := RemDlgGridOnTabSheet(RemDlgPageControl.ActivePage);
    SetVisibleGridIdx(AGrid);
    {
    if RemDlgPageControl.ActivePage = tsReminderDialog then begin
      SetVisibleGridIdx(RemDlgGrid);
    end else if RemDlgPageControl.ActivePage = tsRemDlgElement then begin
      SetVisibleGridIdx(RemDlgElementGrid);
    end else if RemDlgPageControl.ActivePage = tsRemDlgPrompt then begin
      SetVisibleGridIdx(RemDlgPromptGrid);
    end else if RemDlgPageControl.ActivePage = tsRemDlgForcedValue then begin
      SetVisibleGridIdx(RemDlgForcedVGrid);
    end else if RemDlgPageControl.ActivePage = tsRemDlgGroup then begin
      SetVisibleGridIdx(RemDlgGroupGrid);
    end else if RemDlgPageControl.ActivePage = tsRemDlgRsltGroup then begin
      SetVisibleGridIdx(RemDlgRsltGroupGrid);
    end else if RemDlgPageControl.ActivePage = tsRemDlgRsltElement then begin
      SetVisibleGridIdx(RemDlgRsltElementGrid);
    end else begin
      SetVisibleGridIdx(AdvRemDlgGrid);
    end;
    }
  end;

  procedure TMainForm.RemDlgPageControlChanging(Sender: TObject; var AllowChange: Boolean);
  begin
    AllowChange := (PostVisibleGrid <> mrNO);
  end;

  procedure TMainForm.SelectExternalGridCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
  begin
     GridSelectCell(Sender, ACol, ARow, CanSelect);
  end;

  procedure TMainForm.btnLaunchRemDlgClick(Sender: TObject);
  var  IEN, PrintName : string ;
  begin
    if InitRemDlgTab = false then exit;
    //if cbDynamicDlgs.Checked then begin
    {if TMG_Create_Dynamic_Dialog then begin
      IEN := '0';
      PrintName := 'CUSTOM DIALOG';
    end else} begin
      if orcboSelRemDlg.ItemIndex < 0 then exit;
      //if InitRemDlgTab = false then exit;
      IEN := IntToStr(orcboSelRemDlg.ItemIEN);
      if (IEN='0') or (IEN='') then exit;
      PrintName := Piece(orcboSelRemDlg.Items[orcboSelRemDlg.ItemIndex],'^',2);
      if (PrintName = '') then exit;
    end;
    MainFormTriggeringRemDlgChanges := true;
    TMGViewReminderDialog(IEN, PrintName, true);
    MainFormTriggeringRemDlgChanges := false;
    if assigned(frmRemDlg) then begin
      //Later: could enable this based on user authorization...
      frmRemDlg.btnFinish.Enabled := false;  //prevent posting of test data.
    end;
  end;

  //==============================================================
  //== Reminder definition / dialog Stuff                       ==
  //==============================================================

  procedure TMainForm.SelRemDefNeedData(Sender: TObject; const StartFrom: string; Direction, InsertAt: Integer);
  var  Result : TStrings;
       FileNum : string;
       Scrn    : string;
  begin
    FileNum := '811.9';  //REMINDER DEFINITION file
    Scrn := '[REMDEF FLAGS:'+RemDefFilters+']';
    Result := SubsetofFile(FileNum, StartFrom, Direction, Scrn);
    TORComboBox(Sender).ForDataUse(Result);
  end;

  procedure TMainForm.orcboSelRemDefChange(Sender: TObject);
  begin
    //Here I need to change the view of the Vin Diagram Stuff
    LastSelTreeNode := nil;
    LastSelTreeView := nil;
  end;

  procedure TMainForm.orcboSelRemDefClick(Sender: TObject);
  var  IEN : longInt;
       tempIENS : string;
       ModalResult : TModalResult;
       GridInfo : TGridInfo;
  begin
    ModalResult := PostVisibleGrid;
    if ModalResult = mrNo then exit;
    IEN := orcboSelRemDef.ItemIEN;  //get info from Reminder Dialog
    SelectedDialogIEN := IEN;
    btnDelReminder.Enabled := (IEN <> 0);
    if IEN = 0 then exit;
    tempIENS := IntToStr(IEN)+',';
    GridInfo := GetInfoObjectForGrid(RemDefGrid);
    tcVinViewControl.TabIndex := 0;
    if (Rem2VennU.ReminderIENS <> (tempIENS))
    or (GridInfo.DisplayRefreshIndicated) then begin
      RefreshRemDefVennDisplay
    end;
    if RemDefPageControl.ActivePage = tsRemDefVin then begin
      tcVinViewControlChange(Self);
    end;
  end;

  procedure TMainForm.tcVinViewControlChange(Sender: TObject);
  //Note: if Sender = nil, that will be taken as signal that a parent
  //      page control is on different page.
  begin
    if Assigned(Sender) then begin
      VennForm.Running := true;
      Rem2VennU.DisplayVenns(TDisplayVMode(tcVinViewControl.TabIndex));
      VennForm.Running := true;
    end else begin
      VennForm.Running := false;
    end;
  end;

  procedure TMainForm.RemDefPageControlChange(Sender: TObject);
  //Note: if Sender = nil, that will be taken as signal that a parent
  //      page control is on different page.
  var
     GridInfo : TGridInfo;
  begin
    GridInfo := GetInfoObjectForGrid(RemDefGrid);
    if RemDefPageControl.ActivePage = tsRemDefVin then begin
      GridInfo := GetInfoObjectForGrid(RemDefGrid);
      if GridInfo.DisplayRefreshIndicated then begin
        RefreshRemDefVennDisplay;
      end;
      tcVinViewControlChange(Sender);
    end else begin
      tcVinViewControlChange(nil);  //notify that it is not active
    end;
    //page tsRemDefGridPage doesn't need any notification
  end;

  procedure TMainForm.RefreshRemDefVennDisplay;
  begin
    Rem2VennU.InitializeVenn(RemDefGrid, orcboSelRemDef.ItemIEN);
    tcVinViewControlChange(Self);
  end;


  procedure TMainForm.RemindersPageControlChange(Sender: TObject);
  //Note: if Sender = nil, that will be taken as signal that a parent
  //      page control is on different page.
  begin
    if (PageControl.ActivePage <> tsReminders) then exit;   //elh
    if (RemindersPageControl.ActivePage = tsReminderDefs) then begin  // 1 = Reminder Definitions tab
      RemDefPageControlChange(Sender);
      SetVisibleGridIdx(RemDefGrid);
      RemDlgPageControlChange(nil);  //notify that it is not active
    end else if (RemindersPageControl.ActivePage = tsRemDialogs) then begin  // 1 = Reminder Definitions tab
      RemDlgPageControlChange(Sender);
      RemDefPageControlChange(nil);  //notify that it is not active
    end;
  end;

  procedure TMainForm.CloseAnyRemDlgForm;
  begin
    if assigned(frmRemDlg) then begin
      FreeAndNil(frmRemDlg);
    end;
  end;


  procedure TMainForm.HandleVennFormRefreshRequest(Sender: TObject);
  begin
    if Sender = VennForm then begin
      RefreshRemDefVennDisplay;
    end;
  end;

  procedure TMainForm.HandleHL7FilingErrorsClick(Sender: TObject);
  var
    frmHandleHL7FilingErrors: TfrmHandleHL7FilingErrors;
  begin
    frmHandleHL7FilingErrors := TfrmHandleHL7FilingErrors.Create(Self);
    frmHandleHL7FilingErrors.ShowModal;
    frmHandleHL7FilingErrors.Free;
  end;

  procedure TMainForm.HandleRemDefOnAfterPost(GridInfo: TGridInfo; Changes : TStringList);
  begin
    if orcboSelRemDef.ItemIEN = 0 then exit;
    RefreshRemDefVennDisplay;
  end;

  procedure TMainForm.HandleRemDlgOnAfterPost(GridInfo: TGridInfo; Changes : TStringList);
  //Note: input values can be nil.
  var Node : TTreeNode;
  begin
    if assigned(frmRemDlg) then begin
      //frmRemDlg.ReminderDlg.RemWipe := 1;
      frmRemDlg.Close;
      frmRemDlg.Free;
      frmRemDlg := nil;
    end;
    btnLaunchRemDlgClick(Self);
    Node := tvElements.Selected;
    if assigned(Node) then begin
      ReLoadElementTreeNode(Node);
      SyncTVElementToRemDlg(Node);
    end;
  end;

  procedure TMainForm.HandleUserOnAfterPost(GridInfo: TGridInfo; Changes : TStringList);
  begin
    if not Assigned(Changes) then exit;
    if DisuserChanged(Changes) then begin  //looks for change in file 200, field 4
      InitializeUsersTreeView;
    end;
  end;

  procedure TMainForm.btnAddRemDialogClick(Sender: TObject);
  begin
    btnAddChildClick(nil);  //note: nil is signal that it comes from here
    cboDisplayDialogTypeChange(Sender);
  end;

procedure TMainForm.btnAddReminderDefClick(Sender: TObject);
  var
    frmAddRemDef: TfrmAddRemDef;
  begin
    frmAddRemDef := TfrmAddRemDef.Create(Self);
    if frmAddRemDef.ShowModal = mrOK then begin
      InitORCombobox(orcboSelRemDef,frmAddRemDef.ReminderName);
      orcboSelRemDefClick(Self);
    end;
    frmAddRemDef.Free;
  end;

  procedure TMainForm.tvElementsStartDrag(Sender: TObject; var DragObject: TDragObject);
  var //TextRect : TRect;
      SelNode : TTreeNode;
  begin
    DragObject := TDragTreeNode.Create;  //will automatically be deleted by Delphi because derived from TDragObjectEx
    SelNode := tvElements.Selected;
    TDragTreeNode(DragObject).TreeNode := SelNode;

    tvElements.DragCursor := crDrag;
  end;


  procedure TMainForm.tvElementsDragOver(Sender, Source: TObject; X, Y: Integer;
                                         State: TDragState; var Accept: Boolean);
  var ANode: TTreeNode;
      Title : string;
      PriorNodeBeingDraggedOver : TTreeNode;
  begin
    Accept := false;
    if Sender <> tvElements then exit;
    ANode := tvElements.GetNodeAt(X, Y);
    if not assigned(ANode) then exit;
    Title := ANode.Text;
    Title := Piece(Piece(Title,'[',2),']',1);
    Accept := (Title = 'DIALOG GROUP') or
              not assigned(ANode.Parent);
    PriorNodeBeingDraggedOver := NodeBeingDraggedOver;
    case State of
      dsDragEnter, DsDragMove : NodeBeingDraggedOver := ANode;
      dsDragLeave             : NodeBeingDraggedOver := nil;
    end;
    if NodeBeingDraggedOver <> PriorNodeBeingDraggedOver then begin
      //tvElements.Repaint;
    end;
  end;

  procedure TMainForm.tvElementsDragDrop(Sender, Source: TObject; X, Y: Integer);
  var SourceNode, DestNode: TTreeNode;
  begin
    if not IsDragObject(Source) then exit;
    SourceNode := TDragTreeNode(Source).TreeNode;
    if not assigned(SourceNode) then exit;
    DestNode := tvElements.GetNodeAt(X, Y);
    if not assigned(DestNode) then exit;
    MoveReminderElement(SourceNode, DestNode);
  end;

  procedure TMainForm.tvElementsEndDrag(Sender, Target: TObject; X, Y: Integer);
  begin
    NodeBeingDraggedOver := nil;
    //tvElements.Repaint;
    //Application.ProcessMessages;
  end;

  procedure TMainForm.MoveReminderElement(SourceNode, DestNode : TTreeNode);
  begin
    if rRPCsU.MoveReminderElement(SourceNode, DestNode) then begin
      CloseAnyRemDlgForm;
      btnLaunchRemDlgClick(self);
    end;
  end;

  //==============================================================
  //==============================================================

  procedure TMainForm.ShowBrokerCallsClick(Sender: TObject);
  begin
    //fxBroker.ShowBroker;
    frmBroker.Show;
  end;

  procedure TMainForm.cbDynamicDlgsClick(Sender: TObject);
  begin
    TMG_Create_Dynamic_Dialog := cbDynamicDlgs.Checked;
{$IFDEF TMG_XML_DLG}
    if TMG_Create_Dynamic_Dialog then begin
      if tempXMLOpenDialog.FileName = '' then begin
        tempXMLOpenDialog.FileName := 'C:\Documents and Settings\kdtop\My Documents\Downloads\1316243HTN.xml';
      end;
      if tempXMLOpenDialog.Execute then begin
        TMG_Create_Dynamic_Dialog_XML_Filename := tempXMLOpenDialog.FileName;
      end;
    end else begin
      TMG_Create_Dynamic_Dialog_XML_Filename := '';
    end;
{$ENDIF}
  end;

initialization
  TMG_Auto_Press_Edit_Button_In_Detail_Dialog := false;
end.



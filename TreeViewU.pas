unit TreeViewU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, StrUtils, GridU,
  ORNet, ORFn, ComCtrls, ToolWin, Grids, ORCtrls, ExtCtrls, Buttons,
  AppEvnts, Menus, ImgList, TypesU, GlobalsU,
  DragTreeNodeU,
  ValEdit, SortStringGrid;

var
  InactiveUsers : TTreeNode;
  ActiveUsers : TTreeNode;
  AllUsersNode : TTreeNode;
  AllSettingsNode : TTreeNode;
  KernelSysParamsNode : TTreeNode;
  HospLocNode : TTreeNode;
  RPCBrokerParamsNode : TTreeNode;
  Devices : TTreeNode;

Procedure LoadUsersTreeView(UsersTreeView : TTreeview; UsersList : TStringList);
Procedure LoadSettingsTreeView(SettingsTreeView : TTreeview; RecordsList : TStringList;DestNode : TTreeNode);
procedure InitializeUsersTreeView(UsersTreeView : TTreeview);
procedure InitializeSettingsFilesTreeView(SettingsTreeView : TTreeview);


implementation

  uses rRPCsU;

  Procedure LoadUsersTreeView(UsersTreeView : TTreeview; UsersList : TStringList);
  //UsersList Format:
  // Name^IEN^FileNum^Disuser(1 or 0)
  // Name^IEN^FileNum^Disuser(1 or 0)

    procedure AddChild(Parent : TTreeNode; Name : string;IEN : longInt);
    var Node : TTreeNode;
    begin
      Node := UsersTreeView.Items.AddChildObject(Parent,Name,pointer(IEN));
      if Parent=InactiveUsers then begin
        Node.ImageIndex := 1;
        Node.SelectedIndex := 4;
      end else begin
        Node.ImageIndex := 0;
        Node.SelectedIndex := 5;
      end;
    end;

  var i : integer;
      oneEntry,Name,IENStr,inactive : string;
      IEN : longInt;
  begin
    for i := 0 to UsersList.Count-1 do begin
      oneEntry := UsersList.Strings[i];
      Name := Piece(oneEntry,'^',1);
      IENStr := Piece(oneEntry,'^',2);
      inactive := Piece(oneEntry,'^',4);
      if (Pos('.',IENStr)=0) then begin
        IEN := StrToInt64(IENStr);
        if (inactive='1') then begin
          AddChild(InactiveUsers,Name,IEN)
        end else begin
          AddChild(ActiveUsers,Name,IEN)
        end;
      end;
    end;
  end;

  Procedure LoadSettingsTreeView(SettingsTreeView : TTreeview; RecordsList : TStringList;DestNode : TTreeNode);
  //RecordsList Format:
  // .01Value^IEN^FileNum
  // .01Value^IEN^FileNum
  //Note: Will ADD into tree view, leaving prior entries intact

  var i : integer;
      oneEntry,Name,IENStr : string;
      IEN : longInt;
      Node: TTreeNode;
  begin
    for i := 0 to RecordsList.Count-1 do begin
      oneEntry := RecordsList.Strings[i];
      Name := Piece(oneEntry,'^',1);
      IENStr := Piece(oneEntry,'^',2);
      IEN := StrToInt64(IENStr);
      //Node := UsersTreeView.Items.AddChildObject(DestNode,Name,pointer(IEN));
      Node := SettingsTreeView.Items.AddChildObject(DestNode,Name,pointer(IEN));
      Node.ImageIndex := 9;  //change later for icon
      Node.SelectedIndex := 10; //change later for icon
    end;
  end;

  procedure InitializeUsersTreeView(UsersTreeView : TTreeview);
  var UsersList : TStringList;
      i : integer;
      AGrid : TSortStringGrid;
  begin
    CurrentUsersData.Clear;
    //ClearGrid(AdvancedUsersGrid);
    //ClearGrid(BasicUsersGrid);
    for i := 0 to UsersGridList.Count - 1 do begin
      AGrid := TSortStringGrid(UsersGridList[i]);
      ClearGrid(AGrid);
    end;
    UsersTreeView.Items.Clear;
    AllUsersNode := UsersTreeView.Items.Add(nil, 'All Users'); { Add root node }
    AllUsersNode.ImageIndex := 2;
    AllUsersNode.SelectedIndex := 2;
    ActiveUsers := UsersTreeView.Items.AddChild(AllUsersNode,'Active Users');
    ActiveUsers.ImageIndex := 0;
    ActiveUsers.SelectedIndex := 0;
    InactiveUsers := UsersTreeView.Items.AddChild(AllUsersNode,'Inactive Users');
    InactiveUsers.ImageIndex := 1;
    InactiveUsers.SelectedIndex := 1;
    AllUsersNode.Expand(true);
    UsersList := TStringList.create;
    UsersList.Sorted := false;
    GetUsersList(UsersList,false);
    LoadUsersTreeView(UsersTreeView, UsersList);
    UsersList.free;
  end;


  procedure InitializeSettingsFilesTreeView(SettingsTreeView : TTreeview);
  var
    RecordsList : TStringList;
    index : integer;
    i : integer;
    AGrid : TSortStringGrid;
  begin
    RecordsList := TStringList.Create;
    SettingsFiles.Clear;
    SettingsFiles.Add('<blank line>');  // to index 0 is not used for file info.
    //ClearGrid(AdvancedSettingsGrid);
    //ClearGrid(BasicSettingsGrid);
    for i := 0 to UsersGridList.Count - 1 do begin
      AGrid := TSortStringGrid(UsersGridList[i]);
      ClearGrid(AGrid);
    end;
    SettingsTreeView.Items.Clear;
    AllSettingsNode := SettingsTreeView.Items.Add(nil, 'All Settings Files'); { Add root node }
    AllSettingsNode.ImageIndex := 8;
    AllSettingsNode.SelectedIndex := 8;
    AllSettingsNode.StateIndex := 7;

    index := SettingsFiles.Add('8989.3');
    KernelSysParamsNode := SettingsTreeView.Items.AddChildObject(AllSettingsNode,'Kernel System Parameters',Pointer(index));
    KernelSysParamsNode.ImageIndex := 8;
    KernelSysParamsNode.SelectedIndex := 8;
    KernelSysParamsNode.StateIndex := 7;
    GetRecordsList(RecordsList,'8989.3');  // KERNEL SYSTEM PARAMETERS file
    LoadSettingsTreeView(SettingsTreeView, RecordsList, KernelSysParamsNode);
    RecordsList.Clear;

    index := SettingsFiles.Add('44');
    HospLocNode := SettingsTreeView.Items.AddChildObject(AllSettingsNode,'Practice Locations',Pointer(index));
    HospLocNode.ImageIndex := 8;
    HospLocNode.SelectedIndex := 8;
    HospLocNode.StateIndex := 7;
    GetRecordsList(RecordsList,'44');  //HOSPITAL LOCATION file
    LoadSettingsTreeView(SettingsTreeView, RecordsList,HospLocNode);
    RecordsList.Clear;

    index := SettingsFiles.Add('8994.1');
    RPCBrokerParamsNode := SettingsTreeView.Items.AddChildObject(AllSettingsNode,'RPC Broker Settings',Pointer(index));
    RPCBrokerParamsNode.ImageIndex := 8;
    RPCBrokerParamsNode.SelectedIndex := 8;
    RPCBrokerParamsNode.StateIndex := 7;
    GetRecordsList(RecordsList,'8994.1');  // RPC BROKER SITE PARAMETERS
    LoadSettingsTreeView(SettingsTreeView, RecordsList,RPCBrokerParamsNode);
    RecordsList.Clear;

    index := SettingsFiles.Add('3.5');
    Devices := SettingsTreeView.Items.AddChildObject(AllSettingsNode,'Devices',Pointer(index));
    Devices.ImageIndex := 8;
    Devices.SelectedIndex := 8;
    Devices.StateIndex := 7;
    GetRecordsList(RecordsList,'3.5');  // DEVICE
    LoadSettingsTreeView(SettingsTreeView, RecordsList,Devices);
    RecordsList.Clear;

    RecordsList.Free;
  end;


end.

unit GlobalsU;

   (*
   WorldVistA Configuration Utility
   (c) 2/2013 Kevin Toppenberg
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
    Dialogs, StdCtrls, StrUtils,
    ORNet, ORFn, ComCtrls, Grids, ORCtrls, ExtCtrls, Buttons,
    TypesU, SortStringGrid;


var
  ActivePopupEditForm : TVariantPopupEdit;
  TMG_Create_Dynamic_Dialog : boolean;
  TMG_Create_Dynamic_Dialog_XML_Filename : String;
  TMG_Auto_Press_Edit_Button_In_Detail_Dialog : boolean;

  DataForGrid : TStringList;   // Owns contained TGridInfo objects
  RemDefGridList : TList;
  SettingsGridList : TList;
  PatientsGridList : TList;
  UsersGridList : TList;
  AnyFileGridList : TList;
  DlgsGridList : TList;
  CachedHelp : TStringList;
  CachedHelpIdx : TStringList;
  CachedWPField : TStringList;
  VisibleGridIdx : integer;

  CurrentUsersData : TStringList;
  CurrentSettingsData : TStringList;
  CurrentPatientsData : TStringList;
  CurrentAnyFileData : TStringList;
  CurrentRemDlgFileData : TStringList;
  CurrentRemDefFileData : TStringList;

  SettingsFiles : TStringList;

  //forward declarations
  procedure FreeAndDeleteDataForGridListItem(i : integer);

implementation

  procedure FreeAndDeleteDataForGridListItem(i : integer);
  var s : string;
      AGridInfo : TGridInfo;
      ACompleteGridInfo : TCompleteGridInfo; //kt 5/15/13
  begin
    if (i < 0) or (i >= DataForGrid.Count) then exit;
    AGridInfo := TGridInfo(DataForGrid.Objects[i]);
    //kt 5/15/13 -- DataForGrid now owns objects
    if AGridInfo is TCompleteGridInfo then begin         //kt 5/15/13
      ACompleteGridInfo := TCompleteGridInfo(AGridInfo); //kt 5/15/13
      FreeAndNil(ACompleteGridInfo);                     //kt 5/15/13
    end else begin
      FreeAndNil(AGridInfo);                             //kt 5/15/13
    end;
    DataForGrid.Delete(i);
  end;

  procedure ClearDataForGridList;
  var i : integer;
  begin
    for i := DataForGrid.Count-1 downto 0 do begin
      FreeAndDeleteDataForGridListItem(i);
    end;
  end;

//----------------------------------------------

initialization
  DataForGrid := TStringList.Create;  //will own GridInfo objects.
  RemDefGridList := TList.Create;
  SettingsGridList := TList.Create;
  PatientsGridList := TList.Create;
  UsersGridList := TList.Create;
  AnyFileGridList := TList.Create;
  DlgsGridList := TList.Create;
  CachedWPField := TStringList.Create;
  CachedHelp := TStringList.Create;
  CachedHelpIdx := TStringList.Create;

  SettingsFiles := TStringList.Create;
  CurrentUsersData := TStringList.create;
  CurrentSettingsData := TStringList.Create;
  CurrentPatientsData := TStringList.Create;
  CurrentAnyFileData := TStringList.Create;
  CurrentRemDlgFileData := TStringList.Create;
  CurrentRemDefFileData := TStringList.Create;



finalization
  ClearDataForGridList;
  DataForGrid.Free;
  RemDefGridList.Free;
  SettingsGridList.Free;
  PatientsGridList.Free;
  UsersGridList.Free;
  AnyFileGridList.Free;
  DlgsGridList.Free;
  CachedWPField.Free;
  CachedHelp.Free;
  CachedHelpIdx.Free;

  CurrentUsersData.Free;
  CurrentSettingsData.Free;
  CurrentPatientsData.Free;
  CurrentAnyFileData.Free;
  CurrentRemDlgFileData.Free;
  CurrentRemDefFileData.Free;

  SettingsFiles.Free;


end.

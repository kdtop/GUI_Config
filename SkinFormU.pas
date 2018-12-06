unit SkinFormU;
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


  //==========================================================================
  //==========================================================================
  //  NOTICE BELOW...
  //==========================================================================
  //==========================================================================
   (*
   NOTICE:  
   This unit makes use of propriatary, commercial, binary files
   (.DCU files) that are bound by a *separate* license.  Please see that
   license which is in the \GUI-Config\SkinStuff\ folder
   *)

//NOTE: If the compilation directive USE_SKINS is not defined, then this
//      form compiles without the skin manager, and is essentially useless.
//      I chose not to remove the entire form for programming reasons, but
//      it will not be accessible to the user unless active.

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  {$IFDEF USE_SKINS} 
  ipSkinManager, 
  {$ENDIF}
  StdCtrls, ExtCtrls, ComCtrls, Buttons, DBCtrls, Mask;

type
  TSkinForm = class(TForm)
    Panel3: TPanel;
    SkinsListBox: TListBox;
    ApplySkinButton: TButton;
    btnDisable: TButton;
    Label12: TLabel;
    Button6: TButton;
    Button1: TButton;
    cbSkinAtStartup: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure ApplySkinButtonClick(Sender: TObject);
    procedure SkinsListBoxDblClick(Sender: TObject);
    procedure SkinsListBoxKeyPress(Sender: TObject; var Key: Char);
    procedure Button6Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    {$IFDEF USE_SKINS}     
    SkinManager : TipSkinManager;
    {$ENDIF}
    FINIFileName : string;
    procedure FillSkinList;
  public
    { Public declarations }
    CurrentSkinFile : string;
    procedure ActivateCurrentSkin;
    procedure InactivateSkin;
  end;

var
  SkinForm: TSkinForm;

//CONST
//   SKIN_NONE = '<TURN OFF SKINS>'  ;

implementation

{$R *.DFM}

uses ShellAPI, inifiles;

  procedure TSkinForm.FillSkinList;
  var
    SRec : TSearchRec;
    R : Integer;
  begin
    SkinsListBox.Items.Clear;
//    SkinsListBox.Items.Add (SKIN_NONE);
    R := FindFirst (ExtractFilePath (Application.ExeName) + '\SkinStuff\Skins\*.ipz', faAnyFile, SRec);
    while R = 0 do
    begin
      SkinsListBox.Items.Add (SRec.Name);
      R := FindNext (SRec);
    end;
    SkinsListBox.Sorted := true;
    SkinsListBox.ItemIndex := 0;
  end;


  procedure TSkinForm.FormCreate(Sender: TObject);
  var  iniFile : TIniFile;
  begin
    {$IFDEF USE_SKINS} 
    SkinManager := TipSkinManager.Create(self);   
    {$ENDIF}
    FINIFileName := ExtractFilePath(ParamStr(0)) + 'GUI_Config.ini';
    iniFile := TIniFile.Create(FINIFileName);
    cbSkinAtStartup.Checked := iniFile.ReadBool('Skin','Load At Startup',false);
    CurrentSkinFile := iniFile.ReadString('Skin','Default Skin','SkinStuff\Skins\ICQ_Longhorn_v.1.2.ipz');
    iniFile.Free;
  end;

  procedure TSkinForm.FormDestroy(Sender: TObject);
  var iniFile : TIniFile;
  begin
    iniFile := TIniFile.Create(FINIFileName);
    iniFile.WriteString('Skin','Default Skin',CurrentSkinFile);
    iniFile.WriteBool('Skin','Load At Startup',cbSkinAtStartup.Checked);
    iniFile.Free;
    {$IFDEF USE_SKINS} 
    SkinManager.Free;
    {$ENDIF}
  end;

  procedure TSkinForm.ApplySkinButtonClick(Sender: TObject);
  var fileS : String;
  begin
    fileS := '';
    if SkinsListBox.ItemIndex > -1 then begin
      fileS := SkinsListBox.Items [SkinsListBox.ItemIndex];
    end;  
//    if fileS = SKIN_NONE then fileS := '';
    CurrentSkinFile := 'SkinStuff\Skins\' +fileS;
    ModalResult := mrOK;
  end;

  procedure TSkinForm.SkinsListBoxDblClick(Sender: TObject);
  begin
    ApplySkinButtonClick (Self);
  end;

  procedure TSkinForm.SkinsListBoxKeyPress(Sender: TObject; var Key: Char);
  begin
    if Key = #13 then ApplySkinButtonClick (Self);
  end;

  procedure TSkinForm.Button6Click(Sender: TObject);
  begin
    ShellExecute (Handle, 'open', 'http://www2.wincustomize.com/Skins.aspx?LibID=12&view=1&sortby=9&sortdir=DESC&p=1&advanced=0&mode=1&u=0', nil, nil, SW_SHOWNORMAL);
  end;

  procedure TSkinForm.ActivateCurrentSkin;
  begin
    {$IFDEF USE_SKINS} 
    SkinManager.SkinFile := ExtractFilePath (Application.ExeName) + CurrentSkinFile;
    if FileExists(SkinManager.SkinFile)=false then begin
      SkinManager.SkinFile := '';
    end;
    if SkinManager.SkinFile <>'' then begin
      try
        SkinManager.Active := true;
      except
        on EInvalidOperation do begin
          MessageDlg('Error Applying Skin.  Please try another.',mtInformation,[mbOK],0);
        end;
        else  begin
          MessageDlg('Error Applying Skin.  Please try another.',mtInformation,[mbOK],0);
        end;
      end;     
    end else begin
      SkinManager.Active := false;
    end;  
    {$ENDIF}     
  end;
  

  procedure TSkinForm.InactivateSkin;
  begin
    {$IFDEF USE_SKINS}   
    SkinManager.Active := false;
    {$ENDIF}
  end;
  
  procedure TSkinForm.FormShow(Sender: TObject);
  begin
    FillSkinList;
  end;

  end.

program GUI_Config;
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

uses
  Forms,
  MainU in 'MainU.pas' {MainForm},
  frmSplash in 'frmSplash.pas' {SplashForm},
  LookupU in 'LookupU.pas' {FieldLookupForm},
  fMultiRecEditU in 'fMultiRecEditU.pas' {frmMultiRecEdit},
  SetSelU in 'SetSelU.pas' {SetSelForm},
  EditDateTimeU in 'EditDateTimeU.pas' {EditDateTimeForm},
  PostU in 'PostU.pas' {PostForm},
  FMErrorU in 'FMErrorU.pas' {FMErrorForm},
  AboutU in 'AboutU.pas' {AboutForm},
  PleaseWaitU in 'PleaseWaitU.pas' {WaitForm},
  EditTextU in 'EditTextU.pas' {EditWPTextForm},
  CreateTemplateU in 'CreateTemplateU.pas' {CreateTemplateForm},
  SkinFormU in 'SkinFormU.pas' {SkinForm},
  BatchAddU in 'BatchAddU.pas' {BatchAddForm},
  DebugU in 'DebugU.pas' {DebugForm},
  SortStringGrid in 'TMG_Extra\SortStringGrid.pas',
  AddOneFileEntryU in 'AddOneFileEntryU.pas' {AddOneFileEntry},
  uTemplates in 'Dialog-Templates\uTemplates.pas',
  dShared in 'Dialog-Templates\dShared.pas' {dmodShared: TDataModule},
  uTIU in 'Dialog-Templates\uTIU.pas',
  VAUtils in 'Dialog-Templates\VAUtils.pas',
  VA508AccessibilityManager in 'Dialog-Templates\VA508AccessibilityManager.pas',
  fPage in 'Dialog-Templates\fPage.pas',
  fHSplit in 'Dialog-Templates\fHSplit.pas',
  fNotes in 'Dialog-Templates\fNotes.pas' {frmNotes},
  uCore in 'Dialog-Templates\uCore.pas',
  fReminderDialog in 'Dialog-Templates\fReminderDialog.pas' {frmRemDlg},
  EditFreeText in 'EditFreeText.pas' {EditFreeTextForm},
  fxBroker in 'fxBroker.pas' {frmBroker},
  fMemoEdit in 'fMemoEdit.pas' {frmMemoEdit},
  RemDlgCreator in 'Dialog-Templates\RemDlgCreator.pas',
  XML2Dlg in 'Dialog-Templates\XML2Dlg.pas',
  XML_Main in 'XML-Athena Parsing\XML_Main.pas',
  frmVennU in 'VennDiagram\frmVennU.pas' {VennForm},
  ColorUtil in 'VennDiagram\ColorUtil.pas',
  EllipseObject in 'VennDiagram\EllipseObject.pas',
  Gradient in 'VennDiagram\Gradient.pas',
  LogUnit in 'VennDiagram\LogUnit.pas' {LogForm},
  Pointf in 'VennDiagram\Pointf.pas',
  Rectf in 'VennDiagram\Rectf.pas',
  RegionManager in 'VennDiagram\RegionManager.pas',
  TMGGraphUtil in 'VennDiagram\TMGGraphUtil.pas',
  TMGStrUtils in 'VennDiagram\TMGStrUtils.pas',
  VennObject in 'VennDiagram\VennObject.pas',
  Accessibility_TLB in 'CPRS-Lib\Accessibility_TLB.pas',
  EditNumberU in 'EditNumberU.pas' {EditNumber},
  fOneRecEditU in 'fOneRecEditU.pas' {frmOneRecEdit},
  Rem2VennU in 'Rem2VennU.pas',
  AgeFreqU in 'AgeFreqU.pas' {frmAgeFreq},
  fFindingDetail in 'VennDiagram\fFindingDetail.pas' {FindingDetailForm},
  TypesU in 'TypesU.pas',
  fTaxonomyDisplay in 'fTaxonomyDisplay.pas' {frmTaxonomyDisplay},
  rRPCsU in 'rRPCsU.pas',
  GridU in 'GridU.pas',
  UtilU in 'UtilU.pas',
  GlobalsU in 'GlobalsU.pas',
  DragTreeNodeU in 'DragTreeNodeU.pas',
  TreeViewU in 'TreeViewU.pas',
  fAddRemFinding in 'fAddRemFinding.pas' {frmAddRemFinding},
  FMU in 'FMU.pas',
  ORNet in 'CPRS-Lib\ORNet.pas',
  ORFn in 'CPRS-Lib\ORFn.pas',
  fTestReminder in 'fTestReminder.pas' {frmTestReminder},
  rCore in 'rCore.pas',
  ReminderObjU in 'VennDiagram\ReminderObjU.pas',
  ReminderRegionManagerU in 'VennDiagram\ReminderRegionManagerU.pas',
  TestRemResultsU in 'TestRemResultsU.pas',
  fAddRemDlgItem in 'fAddRemDlgItem.pas' {frmAddRemDlgItem},
  FMFindU in 'FMFindU.pas',
  fReminderDefFilter in 'fReminderDefFilter.pas' {frmRemDefFilters},
  fCopyRemDlgItem in 'fCopyRemDlgItem.pas' {frmCopyRemDlgItem},
  TRPCB in 'BDK32\Source\TRPCB.pas',
  fPtSel in 'Dialog-Templates\fPtSel.pas' {frmPtSel},
  fMumpsCodeU in 'fMumpsCodeU.pas' {frmMumpsCode},
  fAddRemDef in 'fAddRemDef.pas' {frmAddRemDef},
  fRemFnFindingEdit in 'fRemFnFindingEdit.pas' {frmFnFindingEdit},
  fLabEntry in 'fLabEntry.pas' {frmLabEntry},
  fLabEntryDetails in 'fLabEntryDetails.pas' {frmLabEntryDetails},
  flabComments in 'flabComments.pas' {frmLabComments},
  fLabDateEdit in 'fLabDateEdit.pas' {frmLabDateEdit},
  fLabSpecimenEdit in 'fLabSpecimenEdit.pas' {frmSpecimenEdit},
  fLabHL7 in 'LabReg\fLabHL7.pas' {frmHandleHL7FilingErrors},
  rHL7RPCsU in 'LabReg\rHL7RPCsU.pas',
  fShortenName in 'LabReg\fShortenName.pas' {frmShortenName},
  fPickAddTo60 in 'LabReg\fPickAddTo60.pas' {frmPickAdd60},
  uSrchHelper in 'LabReg\uSrchHelper.pas',
  fPickAddWorkLoad in 'LabReg\fPickAddWorkLoad.pas' {frmPickAddWorkLoad},
  fPickSpecimen in 'LabReg\fPickSpecimen.pas' {frmPickSpecimen},
  fPickSpec2 in 'LabReg\fPickSpec2.pas' {frmPickSpec2},
  fPickAddDataName in 'LabReg\fPickAddDataName.pas' {frmPickAddDataName};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Astronaut Configuration Utility';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSkinForm, SkinForm);
  Application.CreateForm(TSplashForm, SplashForm);
  Application.CreateForm(TPostForm, PostForm);
  Application.CreateForm(TFMErrorForm, FMErrorForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TWaitForm, WaitForm);
  Application.CreateForm(TCreateTemplateForm, CreateTemplateForm);
  Application.CreateForm(TBatchAddForm, BatchAddForm);
  Application.CreateForm(TDebugForm, DebugForm);
  Application.CreateForm(TdmodShared, dmodShared);
  Application.CreateForm(TfrmBroker, frmBroker);
  Application.CreateForm(TfrmMemoEdit, frmMemoEdit);
  Application.CreateForm(TVennForm, VennForm);
  Application.CreateForm(TLogForm, LogForm);
  Application.CreateForm(TfrmPtSel, frmPtSel);
  MainForm.Initialize;
  Application.Run;
end.


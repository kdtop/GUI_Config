object frmPtSel: TfrmPtSel
  Left = 199
  Top = 128
  BorderIcons = []
  Caption = 'Patient Selection'
  ClientHeight = 297
  ClientWidth = 414
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  OnClose = FormClose
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlPtSel: TORAutoPanel
    Left = 0
    Top = 0
    Width = 414
    Height = 297
    Align = alClient
    BevelWidth = 2
    TabOrder = 0
    OnResize = pnlPtSelResize
    DesignSize = (
      414
      297)
    object lblPatient: TLabel
      Left = 17
      Top = 8
      Width = 33
      Height = 13
      Caption = 'Patient'
      ShowAccelChar = False
    end
    object cboPatient: TORComboBox
      Left = 17
      Top = 22
      Width = 272
      Height = 262
      Hint = 'Enter name,Full SSN ,Last 4 (x1234),'#39'HRN'#39',DOB, or Phone#'
      Style = orcsSimple
      AutoSelect = True
      Caption = 'Patient'
      Color = clWindow
      DropDownCount = 8
      ItemHeight = 13
      ItemTipColor = clWindow
      ItemTipEnable = True
      ListItemsOnly = False
      LongList = True
      LookupPiece = 2
      MaxLength = 0
      ParentShowHint = False
      Pieces = '2,3'
      ShowHint = True
      Sorted = False
      SynonymChars = '<>'
      TabPositions = '20,25,30,60'
      TabOrder = 0
      OnChange = cboPatientChange
      OnDblClick = cboPatientDblClick
      OnEnter = cboPatientEnter
      OnExit = cboPatientExit
      OnKeyDown = cboPatientKeyDown
      OnKeyPause = cboPatientKeyPause
      OnMouseClick = cboPatientMouseClick
      OnNeedData = cboPatientNeedData
      CharsNeedMatch = 1
    end
    object cmdOK: TButton
      Left = 327
      Top = 22
      Width = 78
      Height = 19
      Anchors = [akTop, akRight]
      Caption = 'OK'
      TabOrder = 1
      OnClick = cmdOKClick
    end
    object cmdCancel: TButton
      Left = 327
      Top = 43
      Width = 78
      Height = 19
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 2
      OnClick = cmdCancelClick
    end
  end
  object popNotifications: TPopupMenu
    Left = 68
    Top = 219
    object mnuProcess: TMenuItem
      Caption = 'Process'
    end
    object mnuForward: TMenuItem
      Caption = 'Forward'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object mnuRemove: TMenuItem
      Caption = 'Remove'
    end
  end
end

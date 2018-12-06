object frmEncounter: TfrmEncounter
  Left = 404
  Top = 175
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Provider & Location for Current Activities'
  ClientHeight = 367
  ClientWidth = 384
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    384
    367)
  PixelsPerInch = 96
  TextHeight = 13
  object lblInstruct: TLabel
    Left = 6
    Top = 6
    Width = 253
    Height = 31
    AutoSize = False
    Caption = 
      'Select the appointment or visit that should be associated with t' +
      'he note or orders .'
    Visible = False
    WordWrap = True
  end
  object lblLocation: TLabel
    Tag = 9
    Left = 6
    Top = 149
    Width = 93
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Encounter Location'
  end
  object lblProvider: TLabel
    Left = 6
    Top = 6
    Width = 91
    Height = 13
    Caption = 'Encounter Provider'
  end
  object cmdOK: TButton
    Left = 306
    Top = 20
    Width = 72
    Height = 21
    Caption = 'OK'
    Default = True
    TabOrder = 4
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 306
    Top = 49
    Width = 72
    Height = 21
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = cmdCancelClick
  end
  object txtLocation: TCaptionEdit
    Tag = 9
    Left = 6
    Top = 163
    Width = 212
    Height = 21
    Anchors = [akLeft, akBottom]
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 1
    Text = '< Select a location from the tabs below.... >'
    Caption = 'Encounter Location'
  end
  object pgeVisit: TPageControl
    Tag = 9
    Left = 6
    Top = 194
    Width = 372
    Height = 167
    ActivePage = tabNewVisit
    Anchors = [akLeft, akBottom]
    TabOrder = 2
    TabStop = False
    OnChange = pgeVisitChange
    object tabClinic: TTabSheet
      Caption = 'Clinic Appointments'
      object lblClinic: TLabel
        Left = 4
        Top = 4
        Width = 127
        Height = 13
        Caption = 'Clinic Appointments / Visits'
      end
      object lblDateRange: TLabel
        Left = 138
        Top = 4
        Width = 71
        Height = 13
        Caption = '(T-30 thru T+1)'
      end
      object lstClinic: TORListBox
        Left = 4
        Top = 18
        Width = 352
        Height = 117
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = lstClinicClick
        OnDblClick = cmdOKClick
        Caption = 'Clinic Appointments / Visits (T-30 thru T+1)'
        ItemTipColor = clWindow
        LongList = False
        Pieces = '3,2,4'
        TabPositions = '20'
      end
    end
    object tabAdmit: TTabSheet
      Caption = 'Hospital Admissions'
      object lblAdmit: TLabel
        Left = 4
        Top = 4
        Width = 93
        Height = 13
        Caption = 'Hospital Admissions'
      end
      object lstAdmit: TORListBox
        Left = 4
        Top = 18
        Width = 352
        Height = 117
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = lstAdmitClick
        OnDblClick = cmdOKClick
        Caption = 'Hospital Admissions'
        ItemTipColor = clWindow
        LongList = False
        Pieces = '3,5,4'
        TabPositions = '20'
      end
    end
    object tabNewVisit: TTabSheet
      Caption = 'New Visit'
      object lblVisitDate: TLabel
        Left = 220
        Top = 4
        Width = 85
        Height = 13
        Caption = 'Date/Time of Visit'
        Visible = False
      end
      object lblNewVisit: TLabel
        Left = 4
        Top = 4
        Width = 63
        Height = 13
        Caption = 'Visit Location'
      end
      object calVisitDate: TORDateBox
        Left = 220
        Top = 18
        Width = 140
        Height = 21
        TabOrder = 1
        Text = 'NOW'
        OnChange = calVisitDateChange
        OnExit = calVisitDateExit
        DateOnly = False
        RequireTime = True
      end
      object ckbHistorical: TORCheckBox
        Left = 220
        Top = 50
        Width = 140
        Height = 81
        Caption = 
          'Historical Visit: a visit that occurred at some time in the past' +
          ' or at some other location (possibly non-VA) but is not used for' +
          ' workload credit.'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        WordWrap = True
        OnClick = ckbHistoricalClick
        AutoSize = True
      end
      object cboNewVisit: TORComboBox
        Left = 4
        Top = 18
        Width = 208
        Height = 117
        Style = orcsSimple
        AutoSelect = True
        Caption = 'Visit Location'
        Color = clWindow
        DropDownCount = 8
        ItemHeight = 13
        ItemTipColor = clWindow
        ItemTipEnable = True
        ListItemsOnly = True
        LongList = True
        LookupPiece = 0
        MaxLength = 0
        Pieces = '2'
        Sorted = False
        SynonymChars = '<>'
        TabOrder = 0
        OnChange = cboNewVisitChange
        OnDblClick = cmdOKClick
        OnNeedData = cboNewVisitNeedData
      end
    end
  end
  object cmdDateRange: TButton
    Tag = 9
    Left = 288
    Top = 177
    Width = 90
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = 'Date Range...'
    TabOrder = 3
    OnClick = cmdDateRangeClick
  end
  object cboPtProvider: TORComboBox
    Left = 6
    Top = 20
    Width = 292
    Height = 117
    Style = orcsSimple
    AutoSelect = True
    Caption = 'Encounter Provider'
    Color = clWindow
    DropDownCount = 8
    ItemHeight = 13
    ItemTipColor = clWindow
    ItemTipEnable = True
    ListItemsOnly = True
    LongList = True
    LookupPiece = 2
    MaxLength = 0
    Pieces = '2,3'
    Sorted = False
    SynonymChars = '<>'
    TabOrder = 0
    OnDblClick = cmdOKClick
    OnNeedData = cboPtProviderNeedData
  end
  object dlgDateRange: TORDateRangeDlg
    DateOnly = True
    Instruction = 'Show appointments / visits in the date range:'
    LabelStart = 'From'
    LabelStop = 'Through'
    RequireTime = False
    Format = 'mmm d,yyyy'
    Left = 264
    Top = 4
  end
end

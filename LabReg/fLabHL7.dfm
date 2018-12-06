object frmHandleHL7FilingErrors: TfrmHandleHL7FilingErrors
  Left = 0
  Top = 0
  Caption = 'Handle HL7 Lab Filing Errors'
  ClientHeight = 506
  ClientWidth = 830
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 400
    Top = 0
    Width = 5
    Height = 506
    Color = clActiveBorder
    ParentColor = False
    ExplicitHeight = 526
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 0
    Width = 400
    Height = 506
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    OnResize = pnlLeftResize
    DesignSize = (
      400
      506)
    object lbHL7Message: TListBox
      Left = 3
      Top = 35
      Width = 394
      Height = 458
      Anchors = [akLeft, akTop, akRight, akBottom]
      Font.Charset = ARABIC_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Fixedsys'
      Font.Style = []
      ItemHeight = 15
      ParentFont = False
      TabOrder = 0
    end
    object cboAvailAlerts: TComboBox
      Left = 2
      Top = 5
      Width = 394
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 1
      OnChange = cboAvailAlertsChange
    end
  end
  object pnlRight: TPanel
    Left = 405
    Top = 0
    Width = 425
    Height = 506
    Align = alClient
    TabOrder = 1
    object PageControl1: TPageControl
      Left = 1
      Top = 1
      Width = 423
      Height = 504
      ActivePage = tsAlert
      Align = alClient
      TabOrder = 0
      object tsTransform: TTabSheet
        Caption = 'Message Transformation'
      end
      object tsLabMap: TTabSheet
        Caption = 'Lab Mapping'
        ImageIndex = 1
      end
      object tsAlert: TTabSheet
        Caption = 'Alert Stuff'
        ImageIndex = 2
        object btnProcessHL7: TButton
          Left = 3
          Top = 10
          Width = 118
          Height = 25
          Caption = 'Test Process'
          TabOrder = 0
          OnClick = btnProcessHL7Click
        end
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 96
    Top = 176
    object Help1: TMenuItem
      Caption = 'Help'
      object ShowBrokerLog: TMenuItem
        Caption = 'Show Broker Log'
        OnClick = ShowBrokerLogClick
      end
    end
  end
end

object frmHandleHL7FilingErrors: TfrmHandleHL7FilingErrors
  Left = 0
  Top = 0
  Caption = 'Handle HL7 Lab Filing Errors'
  ClientHeight = 526
  ClientWidth = 830
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 400
    Top = 0
    Width = 5
    Height = 526
    Color = clActiveBorder
    ParentColor = False
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 0
    Width = 400
    Height = 526
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    OnResize = pnlLeftResize
    DesignSize = (
      400
      526)
    object lbHL7Message: TListBox
      Left = 3
      Top = 35
      Width = 394
      Height = 478
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
    Height = 526
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 403
    ExplicitWidth = 427
    object PageControl1: TPageControl
      Left = 1
      Top = 1
      Width = 423
      Height = 524
      ActivePage = tsAlert
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 425
      object tsTransform: TTabSheet
        Caption = 'Message Transformation'
        ExplicitWidth = 417
      end
      object tsLabMap: TTabSheet
        Caption = 'Lab Mapping'
        ImageIndex = 1
        ExplicitWidth = 417
      end
      object tsAlert: TTabSheet
        Caption = 'Alert Stuff'
        ImageIndex = 2
        ExplicitLeft = 5
        ExplicitTop = 28
        DesignSize = (
          415
          496)
        object lblDisplay: TLabel
          Left = 3
          Top = 144
          Width = 409
          Height = 15
          Anchors = [akLeft, akTop, akRight]
          Caption = 'lblDisplay'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Times New Roman'
          Font.Style = []
          ParentFont = False
          Visible = False
        end
        object Button1: TButton
          Left = 3
          Top = 10
          Width = 118
          Height = 25
          Caption = 'Test Process'
          TabOrder = 0
          OnClick = Button1Click
        end
        object memInstructions: TMemo
          Left = 3
          Top = 41
          Width = 409
          Height = 89
          Anchors = [akLeft, akTop, akRight]
          BevelEdges = []
          BevelInner = bvNone
          BevelOuter = bvNone
          BorderStyle = bsNone
          Color = clCream
          TabOrder = 1
          Visible = False
        end
        object edtEdit: TEdit
          Left = 3
          Top = 165
          Width = 409
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 2
          Text = 'edtEdit'
          Visible = False
          OnChange = edtEditChange
        end
        object btnOK: TButton
          Left = 328
          Top = 192
          Width = 84
          Height = 25
          Anchors = [akTop, akRight]
          Caption = '&OK'
          TabOrder = 3
          Visible = False
        end
      end
    end
  end
end

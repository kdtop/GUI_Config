object frmPickWorkLoad: TfrmPickWorkLoad
  Left = 0
  Top = 0
  Caption = 'Select or Add VA Test Code'
  ClientHeight = 563
  ClientWidth = 729
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    729
    563)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 174
    Height = 13
    Caption = 'Select a VistA laboratory test CODE '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 28
    Width = 63
    Height = 16
    Caption = 'HL7 Name:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblLabName: TLabel
    Left = 77
    Top = 27
    Width = 218
    Height = 18
    Caption = '<laboratory test name here>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object rgSelectMode: TRadioGroup
    Left = 1
    Top = 51
    Width = 209
    Height = 57
    Caption = 'Reuse Existing or Make New?'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Items.Strings = (
      'Select an existing test code'
      'Add a new test code')
    ParentFont = False
    TabOrder = 0
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 522
    Width = 729
    Height = 41
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 1
    ExplicitLeft = -104
    ExplicitTop = 503
    ExplicitWidth = 833
    DesignSize = (
      729
      41)
    object btnCancel: TButton
      Left = 565
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 0
      ExplicitLeft = 669
    end
    object btnOK: TButton
      Left = 646
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&OK'
      Enabled = False
      TabOrder = 1
      ExplicitLeft = 750
    end
  end
  object pnlMain: TPanel
    Left = 0
    Top = 114
    Width = 729
    Height = 408
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvLowered
    TabOrder = 2
    object lblInstructions: TLabel
      Left = 5
      Top = 5
      Width = 135
      Height = 16
      Caption = '<Instructions here>'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object pnlPick: TPanel
      Left = 0
      Top = 24
      Width = 729
      Height = 233
      TabOrder = 0
      object edtLabSrch: TEdit
        Left = 1
        Top = 1
        Width = 727
        Height = 21
        Align = alTop
        TabOrder = 0
        ExplicitLeft = 0
        ExplicitTop = 49
        ExplicitWidth = 573
      end
      object lbLabSrch: TListBox
        Left = 1
        Top = 22
        Width = 727
        Height = 210
        Align = alClient
        ItemHeight = 13
        TabOrder = 1
        ExplicitLeft = 0
        ExplicitTop = 70
        ExplicitWidth = 573
      end
    end
  end
end

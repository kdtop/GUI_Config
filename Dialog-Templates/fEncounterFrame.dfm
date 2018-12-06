object frmEncounterFrame: TfrmEncounterFrame
  Left = 316
  Top = 161
  Width = 640
  Height = 451
  Caption = 'Encounter Frame'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIForm
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 0
    Width = 632
    Height = 2
    Align = alTop
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 417
    Width = 632
    Height = 0
    Panels = <>
  end
  object pnlPage: TPanel
    Left = 0
    Top = 24
    Width = 632
    Height = 393
    Align = alClient
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object TabControl: TTabControl
    Left = 0
    Top = 2
    Width = 632
    Height = 22
    Align = alTop
    TabOrder = 2
    TabStop = False
    OnChange = TabControlChange
    OnChanging = TabControlChanging
    OnExit = TabControlExit
  end
end

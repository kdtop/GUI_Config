object DebugForm: TDebugForm
  Left = 324
  Top = 204
  Width = 518
  Height = 488
  Caption = 'Message Log'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  PixelsPerInch = 96
  TextHeight = 13
  object Memo: TMemo
    Left = 0
    Top = 33
    Width = 510
    Height = 380
    Align = alClient
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 510
    Height = 33
    Align = alTop
    TabOrder = 1
    object Label1: TLabel
      Left = 10
      Top = 7
      Width = 82
      Height = 19
      Caption = 'Message Log'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 413
    Width = 510
    Height = 41
    Align = alBottom
    TabOrder = 2
    Visible = False
    DesignSize = (
      510
      41)
    object btnHide: TButton
      Left = 422
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Hide'
      TabOrder = 0
      OnClick = btnHideClick
    end
    object btnClear: TButton
      Left = 334
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Clear'
      TabOrder = 1
      OnClick = btnClearClick
    end
  end
end

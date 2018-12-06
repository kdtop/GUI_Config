object frmPtSelDemog: TfrmPtSelDemog
  Left = 619
  Top = 324
  BorderStyle = bsNone
  Caption = 'frmPtSelDemog'
  ClientHeight = 150
  ClientWidth = 178
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object orapnlMain: TORAutoPanel
    Left = 0
    Top = 0
    Width = 178
    Height = 150
    Align = alClient
    Anchors = [akLeft, akTop, akRight]
    BevelOuter = bvNone
    TabOrder = 0
    object Memo: TCaptionMemo
      Left = 0
      Top = 0
      Width = 178
      Height = 150
      Align = alClient
      HideSelection = False
      Lines.Strings = (
        'Memo')
      ReadOnly = True
      TabOrder = 12
      Visible = False
      WantReturns = False
    end
    object lblPtName: TStaticText
      Tag = 2
      Left = 1
      Top = 2
      Width = 166
      Height = 17
      Caption = 'Winchester,Charles Emerson'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 11
    end
    object lblSSN: TStaticText
      Tag = 1
      Left = 1
      Top = 21
      Width = 29
      Height = 17
      Caption = 'SSN:'
      TabOrder = 0
    end
    object lblPtSSN: TStaticText
      Tag = 2
      Left = 31
      Top = 21
      Width = 64
      Height = 17
      Caption = '123-45-1234'
      TabOrder = 1
    end
    object lblDOB: TStaticText
      Tag = 1
      Left = 1
      Top = 39
      Width = 30
      Height = 17
      Caption = 'DOB:'
      TabOrder = 2
    end
    object lblPtDOB: TStaticText
      Tag = 2
      Left = 31
      Top = 39
      Width = 63
      Height = 17
      Caption = 'Jun 26,1957'
      TabOrder = 3
    end
    object lblPtSex: TStaticText
      Tag = 2
      Left = 1
      Top = 57
      Width = 66
      Height = 17
      Caption = 'Male, age 39'
      TabOrder = 4
    end
    object lblPtVet: TStaticText
      Tag = 2
      Left = 1
      Top = 75
      Width = 41
      Height = 17
      Caption = 'Veteran'
      TabOrder = 5
    end
    object lblPtSC: TStaticText
      Tag = 2
      Left = 1
      Top = 93
      Width = 118
      Height = 17
      Caption = 'Service Connected 50%'
      TabOrder = 6
    end
    object lblLocation: TStaticText
      Tag = 1
      Left = 1
      Top = 111
      Width = 48
      Height = 17
      Caption = 'Location:'
      TabOrder = 7
    end
    object lblPtRoomBed: TStaticText
      Tag = 2
      Left = 61
      Top = 131
      Width = 32
      Height = 17
      Caption = '257-B'
      ShowAccelChar = False
      TabOrder = 8
    end
    object lblPtLocation: TStaticText
      Tag = 2
      Left = 61
      Top = 111
      Width = 41
      Height = 17
      Caption = '2 EAST'
      ShowAccelChar = False
      TabOrder = 9
    end
    object lblRoomBed: TStaticText
      Tag = 1
      Left = 1
      Top = 131
      Width = 57
      Height = 17
      Caption = 'Room-Bed:'
      TabOrder = 10
    end
    object lblPtHRN: TStaticText
      Tag = 2
      Left = 104
      Top = 21
      Width = 4
      Height = 4
      TabOrder = 13
    end
  end
end

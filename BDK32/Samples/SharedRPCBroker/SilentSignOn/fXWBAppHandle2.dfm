object Form1: TForm1
  Left = 201
  Top = 168
  Width = 460
  Height = 279
  Caption = 'XWBAppHandle2 - Started by lmAppHandle (RPCBroker)'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblDUZ: TLabel
    Left = 54
    Top = 17
    Width = 23
    Height = 13
    Caption = 'DUZ'
  end
  object lblName: TLabel
    Left = 54
    Top = 51
    Width = 28
    Height = 13
    Caption = 'Name'
  end
  object lblDTime: TLabel
    Left = 54
    Top = 84
    Width = 31
    Height = 13
    Caption = 'DTime'
  end
  object lblDivision: TLabel
    Left = 54
    Top = 118
    Width = 37
    Height = 13
    Caption = 'Division'
  end
  object lblUserName: TLabel
    Left = 54
    Top = 152
    Width = 50
    Height = 13
    Caption = 'UserName'
  end
  object edtDuz: TEdit
    Left = 118
    Top = 8
    Width = 280
    Height = 21
    TabStop = False
    TabOrder = 0
  end
  object edtName: TEdit
    Left = 118
    Top = 42
    Width = 280
    Height = 21
    TabStop = False
    TabOrder = 2
  end
  object edtDTime: TEdit
    Left = 118
    Top = 76
    Width = 280
    Height = 21
    TabStop = False
    TabOrder = 3
  end
  object edtUserName: TEdit
    Left = 118
    Top = 143
    Width = 280
    Height = 21
    TabStop = False
    TabOrder = 4
  end
  object btnClose: TButton
    Left = 188
    Top = 192
    Width = 75
    Height = 25
    Caption = 'Close'
    Default = True
    TabOrder = 1
    OnClick = btnCloseClick
  end
  object edtDivision: TEdit
    Left = 118
    Top = 109
    Width = 280
    Height = 21
    TabStop = False
    TabOrder = 5
  end
  object MainMenu1: TMainMenu
    Left = 8
    Top = 40
    object File1: TMenuItem
      Caption = '&File'
      object Exit1: TMenuItem
        Caption = 'E&xit'
        OnClick = Exit1Click
      end
    end
    object About1: TMenuItem
      Caption = '&Help'
      object About2: TMenuItem
        Caption = '&About'
        OnClick = About2Click
      end
    end
  end
  object brkrRPCB: TSharedRPCBroker
    ClearParameters = True
    ClearResults = True
    ListenerPort = 0
    RpcVersion = '0'
    LogIn.Mode = lmAVCodes
    LogIn.PromptDivision = False
    AllowShared = True
    RPCTimeLimit = 30
    Left = 24
    Top = 192
  end
end

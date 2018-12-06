object Form1: TForm1
  Left = 201
  Top = 168
  Width = 635
  Height = 334
  Caption = 
    'XWBAppHandle2 - UCX RPCBroker BackwardsCompatible - Started by l' +
    'mAppHandle (P40)'
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
  object Label1: TLabel
    Left = 56
    Top = 184
    Width = 59
    Height = 13
    Caption = 'IsProduction'
  end
  object Label2: TLabel
    Left = 56
    Top = 216
    Width = 64
    Height = 13
    Caption = 'DomainName'
  end
  object edtDuz: TEdit
    Left = 126
    Top = 8
    Width = 280
    Height = 21
    TabStop = False
    TabOrder = 0
  end
  object edtName: TEdit
    Left = 126
    Top = 42
    Width = 280
    Height = 21
    TabStop = False
    TabOrder = 2
  end
  object edtDTime: TEdit
    Left = 126
    Top = 76
    Width = 280
    Height = 21
    TabStop = False
    TabOrder = 3
  end
  object edtUserName: TEdit
    Left = 126
    Top = 143
    Width = 280
    Height = 21
    TabStop = False
    TabOrder = 4
  end
  object btnClose: TButton
    Left = 188
    Top = 248
    Width = 75
    Height = 25
    Caption = 'Close'
    Default = True
    TabOrder = 1
    OnClick = btnCloseClick
  end
  object edtDivision: TEdit
    Left = 126
    Top = 109
    Width = 280
    Height = 21
    TabStop = False
    TabOrder = 5
  end
  object edtIsProduction: TEdit
    Left = 126
    Top = 176
    Width = 281
    Height = 21
    TabOrder = 6
  end
  object edtDomainName: TEdit
    Left = 126
    Top = 208
    Width = 281
    Height = 21
    TabOrder = 7
  end
  object brkrRPCB: TRPCBroker
    ClearParameters = True
    ClearResults = True
    Connected = False
    ListenerPort = 9200
    RpcVersion = '0'
    Server = 'DHCPSERVER'
    KernelLogIn = True
    LogIn.Mode = lmAVCodes
    LogIn.PromptDivision = False
    Left = 8
    Top = 160
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
end

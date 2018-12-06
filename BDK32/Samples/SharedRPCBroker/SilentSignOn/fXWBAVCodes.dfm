object Form1: TForm1
  Left = 190
  Top = 138
  Width = 574
  Height = 393
  Caption = 
    'XWBAVCodes - Silent Login with lmAVCodes (XWB*1.1*40 SharedRPCBr' +
    'oker)'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object lblAccessCode: TLabel
    Left = 24
    Top = 71
    Width = 79
    Height = 13
    Caption = 'Access Code:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblVerifyCode: TLabel
    Left = 24
    Top = 96
    Width = 70
    Height = 13
    Caption = 'Verify Code:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblDUZ: TLabel
    Left = 48
    Top = 176
    Width = 26
    Height = 13
    Caption = 'DUZ:'
  end
  object lblName: TLabel
    Left = 48
    Top = 216
    Width = 31
    Height = 13
    Caption = 'Name:'
  end
  object lblDTime: TLabel
    Left = 48
    Top = 256
    Width = 34
    Height = 13
    Caption = 'DTime:'
  end
  object lblUserName: TLabel
    Left = 48
    Top = 288
    Width = 56
    Height = 13
    Caption = 'User Name:'
  end
  object lblServer: TLabel
    Left = 24
    Top = 21
    Width = 42
    Height = 13
    Caption = 'Server:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblListenerPort: TLabel
    Left = 24
    Top = 46
    Width = 73
    Height = 13
    Caption = 'ListenerPort:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object edtDUZ: TEdit
    Left = 112
    Top = 168
    Width = 233
    Height = 21
    TabOrder = 3
  end
  object edtName: TEdit
    Left = 112
    Top = 208
    Width = 233
    Height = 21
    TabOrder = 2
  end
  object edtDTime: TEdit
    Left = 112
    Top = 248
    Width = 233
    Height = 21
    TabOrder = 1
  end
  object edtUserName: TEdit
    Left = 112
    Top = 280
    Width = 233
    Height = 21
    TabOrder = 0
  end
  object btnConnect: TButton
    Left = 175
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Connect'
    Default = True
    TabOrder = 8
    OnClick = btnConnectClick
  end
  object edtAccessCode: TEdit
    Left = 112
    Top = 66
    Width = 249
    Height = 21
    PasswordChar = '*'
    TabOrder = 6
  end
  object edtVerifyCode: TEdit
    Left = 112
    Top = 91
    Width = 249
    Height = 21
    PasswordChar = '*'
    TabOrder = 7
  end
  object btnExit: TButton
    Left = 174
    Top = 312
    Width = 75
    Height = 25
    Caption = 'Exit'
    TabOrder = 9
    OnClick = btnExitClick
  end
  object edtServer: TEdit
    Left = 112
    Top = 16
    Width = 249
    Height = 21
    TabOrder = 4
  end
  object edtListenerPort: TEdit
    Left = 112
    Top = 41
    Width = 105
    Height = 21
    TabOrder = 5
  end
  object Memo1: TMemo
    Left = 384
    Top = 16
    Width = 153
    Height = 233
    Lines.Strings = (
      'This application provides an '
      'example of a silent login.  The '
      'server, Listener Port, Access '
      'Code, and Verify Code need to '
      'be filled in - these data would '
      'be supplied in some manner for '
      'a silent login (Division can also '
      'be supplied for a multidivision '
      'individual).  After fillng in the '
      'information enter Return or '
      'click on the Connect button.  '
      'The connection should be '
      'made without the broker login '
      'form appearing.  User '
      'information will be filled in for '
      'the logged in user.')
    TabOrder = 10
  end
  object MainMenu1: TMainMenu
    Left = 24
    Top = 144
    object mnuFile: TMenuItem
      Caption = '&File'
      object mnuFileExit: TMenuItem
        Caption = 'E&xit'
        OnClick = mnuFileExitClick
      end
    end
    object mnuHelp: TMenuItem
      Caption = '&Help'
      object mnuHelpAbout: TMenuItem
        Caption = '&About'
        OnClick = mnuHelpAboutClick
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
    OldConnectionOnly = False
    AllowShared = True
    RPCTimeLimit = 30
    Left = 32
    Top = 312
  end
end

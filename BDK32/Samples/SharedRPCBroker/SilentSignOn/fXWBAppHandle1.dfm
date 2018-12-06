object Form1: TForm1
  Left = 230
  Top = 122
  Width = 503
  Height = 319
  Caption = 
    'XWBAppHandle1 -- use of lmAppHandle to start a second applicatio' +
    'n'
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
  object lblOtherProgram: TLabel
    Left = 44
    Top = 176
    Width = 71
    Height = 13
    Caption = 'Other Program:'
  end
  object lblOptional: TLabel
    Left = 52
    Top = 192
    Width = 45
    Height = 13
    Caption = '(Optional)'
  end
  object lblWithFull: TLabel
    Left = 124
    Top = 200
    Width = 232
    Height = 13
    Caption = 'With Full Directory Path if not on the System Path'
  end
  object btnConnect: TButton
    Left = 85
    Top = 232
    Width = 75
    Height = 25
    Caption = '&Connect'
    TabOrder = 0
    OnClick = btnConnectClick
  end
  object btnStartApp2: TButton
    Left = 210
    Top = 232
    Width = 75
    Height = 25
    Caption = 'Start App2'
    TabOrder = 1
    OnClick = btnStartApp2Click
  end
  object edtOtherProgram: TEdit
    Left = 124
    Top = 168
    Width = 233
    Height = 21
    TabOrder = 2
  end
  object Memo1: TMemo
    Left = 31
    Top = 8
    Width = 433
    Height = 153
    Lines.Strings = (
      
        'This application can be used to start other programs, including ' +
        'ones that use the '
      
        'RPCBroker for connection to a server using a server generated to' +
        'ken.'
      ''
      
        'To connect with the server, simply press the connect button to s' +
        'elect a server/listener port '
      
        'combination, then sign in.  After you are signed in, you can sta' +
        'rt another Broker application '
      
        '(XWBAppHandle2) by simply clicking on the "Start App2" button (w' +
        'ith the Other Program '
      'edit box empty of text).'
      ''
      
        'A program such as Notepad with or without command line arguments' +
        ', can be started at '
      
        'any time by entering the name (and arguments if any) in the Othe' +
        'r Program edit box, then '
      'clicking on the Start App2 button.'
      '')
    TabOrder = 3
  end
  object btnExit: TButton
    Left = 335
    Top = 232
    Width = 75
    Height = 25
    Caption = 'Exit'
    TabOrder = 4
    OnClick = btnExitClick
  end
  object MainMenu1: TMainMenu
    Left = 8
    Top = 184
    object File1: TMenuItem
      Caption = '&File'
      object Exit1: TMenuItem
        Caption = '&E&xit'
        OnClick = Exit1Click
      end
    end
    object Help1: TMenuItem
      Caption = '&Help'
      object About1: TMenuItem
        Caption = '&About'
        OnClick = About1Click
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
    Left = 32
    Top = 232
  end
end

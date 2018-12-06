object Form1: TForm1
  Left = 230
  Top = 122
  Width = 736
  Height = 319
  Caption = 
    'XWBAppHandle1 - UCX RPCBroker (see Options) use of lmAppHandle t' +
    'o start a second application (p40)'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = mnuMainMenu
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
    Left = 201
    Top = 232
    Width = 75
    Height = 25
    Caption = '&Connect'
    TabOrder = 0
    OnClick = btnConnectClick
  end
  object btnStartApp2: TButton
    Left = 326
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
    Width = 269
    Height = 21
    TabOrder = 2
  end
  object Memo1: TMemo
    Left = 31
    Top = 8
    Width = 666
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
    Left = 451
    Top = 232
    Width = 75
    Height = 25
    Caption = 'Exit'
    TabOrder = 4
    OnClick = btnExitClick
  end
  object brkrRPCB: TRPCBroker
    ClearParameters = True
    ClearResults = True
    Connected = False
    ListenerPort = 9500
    RpcVersion = '0'
    Server = 'NXT-Server'
    KernelLogIn = True
    LogIn.Mode = lmAVCodes
    LogIn.PromptDivision = False
    OldConnectionOnly = False
    Left = 16
    Top = 224
  end
  object mnuMainMenu: TMainMenu
    Left = 8
    Top = 184
    object mnuFile: TMenuItem
      Caption = '&File'
      object mnuFileExit: TMenuItem
        Caption = '&E&xit'
        OnClick = mnuFileExitClick
      end
    end
    object mnuOptions: TMenuItem
      Caption = 'Options'
      object OnlyOldConnection1: TMenuItem
        Caption = 'OnlyOldConnection'
      end
      object BackwardsCompatible1: TMenuItem
        Action = actBackwardsCompatible
      end
      object DebugMode1: TMenuItem
        Action = actDebugMode
      end
    end
    object Help1: TMenuItem
      Caption = '&Help'
      object mnuAbout: TMenuItem
        Caption = '&About'
        OnClick = mnuAboutClick
      end
    end
  end
  object ActionList1: TActionList
    Left = 64
    Top = 224
    object actOldConnectionOnly: TAction
      Caption = 'Old Connection Mode Only'
      OnExecute = actOldConnectionOnlyExecute
    end
    object actBackwardsCompatible: TAction
      Caption = 'Backwards Compatible'
      Checked = True
      OnExecute = actBackwardsCompatibleExecute
    end
    object actDebugMode: TAction
      Caption = 'Debug Mode'
      OnExecute = actDebugModeExecute
    end
  end
end

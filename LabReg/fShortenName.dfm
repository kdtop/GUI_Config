object frmShortenName: TfrmShortenName
  Left = 0
  Top = 0
  Caption = 'Shorten Lab Name'
  ClientHeight = 145
  ClientWidth = 433
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  DesignSize = (
    433
    145)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 205
    Height = 22
    Caption = 'Make Lab Name Shorter'
    Font.Charset = ARABIC_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 36
    Width = 70
    Height = 13
    Caption = 'Original Name:'
  end
  object lblOrigName: TLabel
    Left = 84
    Top = 36
    Width = 94
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    Caption = '<Original Name>'
  end
  object lblMaxLen: TLabel
    Left = 8
    Top = 55
    Width = 201
    Height = 13
    Caption = 'Must be <30> characters or less in length'
  end
  object lblCurrentLength: TLabel
    Left = 8
    Top = 101
    Width = 218
    Height = 13
    Caption = 'Current Length is <50> characters (too long)'
  end
  object edtEdit: TEdit
    Left = 8
    Top = 74
    Width = 417
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = '<name to shorten will go here>'
    OnChange = edtEditChange
  end
  object btnOK: TButton
    Left = 341
    Top = 112
    Width = 84
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Enabled = False
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 251
    Top = 112
    Width = 84
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end

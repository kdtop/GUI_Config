object AddOneFileEntry: TAddOneFileEntry
  Left = 217
  Top = 175
  Caption = 'AddOneFileEntry'
  ClientHeight = 331
  ClientWidth = 526
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    526
    331)
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 523
    Height = 274
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Panel1'
    TabOrder = 0
    ExplicitWidth = 464
    object AddFileEntryGrid: TSortStringGrid
      Left = 1
      Top = 1
      Width = 521
      Height = 272
      Cursor = crHandPoint
      Hint = 'Edit User Fields Here'
      Align = alClient
      BorderStyle = bsNone
      ColCount = 3
      FixedCols = 2
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goDrawFocusSelected, goRowSizing, goColSizing, goRowMoving, goEditing, goAlwaysShowEditor, goThumbTracking]
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = AddFileEntryGridClick
      OnSelectCell = AddFileEntryGridSelectCell
      OnSetEditText = AddFileEntryGridSetEditText
      ExplicitWidth = 462
      RowHeights = (
        24
        24)
    end
  end
  object btnCancel: TBitBtn
    Left = 352
    Top = 291
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Close'
    ModalResult = 2
    TabOrder = 1
    OnClick = btnCancelClick
    ExplicitLeft = 293
  end
  object btnOk: TBitBtn
    Left = 433
    Top = 291
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Save'
    TabOrder = 2
    OnClick = btnOkClick
    ExplicitLeft = 374
  end
end

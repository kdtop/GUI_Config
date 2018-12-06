object frmDrawers: TfrmDrawers
  Left = 285
  Top = 335
  BorderStyle = bsNone
  Caption = 'frmDrawers'
  ClientHeight = 365
  ClientWidth = 189
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnCanResize = FormCanResize
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pnlRemindersButton: TKeyClickPanel
    Left = 0
    Top = 193
    Width = 189
    Height = 22
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Reminders'
    TabOrder = 4
    TabStop = True
    OnClick = sbRemindersClick
    OnEnter = pnlTemplatesButtonEnter
    OnExit = pnlTemplatesButtonExit
    object sbReminders: TORAlignSpeedButton
      Left = 0
      Top = 0
      Width = 189
      Height = 22
      AllowAllUp = True
      GroupIndex = 1
      Caption = 'Reminders'
      Glyph.Data = {
        3E010000424D3E010000000000007600000028000000280000000A0000000100
        040000000000C800000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
        888888888888888888888888888888887788888888FF88888888FF88888888FF
        88888888F7888888887F888888887F888888880F8888888F877888888778F888
        888788F888888078F888888F887888888788F888888788F888888078F88888F8
        8877888877888F888878888F888807888F8888F88887888878888F888878888F
        888807888F888F8888877887788888F887888888F880788888F88FFFFFFF7887
        777777F887777777F880000000F8888888888888888888888888888888888888
        8888}
      Margin = 60
      NumGlyphs = 4
      Spacing = 2
      OnClick = sbRemindersClick
      Align = alClient
      OnResize = sbResize
    end
  end
  object pnlEncounterButton: TKeyClickPanel
    Left = 0
    Top = 107
    Width = 189
    Height = 22
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Encounter'
    TabOrder = 2
    TabStop = True
    OnClick = sbEncounterClick
    OnEnter = pnlTemplatesButtonEnter
    OnExit = pnlTemplatesButtonExit
    object sbEncounter: TORAlignSpeedButton
      Left = 0
      Top = 0
      Width = 189
      Height = 22
      AllowAllUp = True
      GroupIndex = 1
      Caption = 'Encounter'
      Glyph.Data = {
        3E010000424D3E010000000000007600000028000000280000000A0000000100
        040000000000C800000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
        888888888888888888888888888888887788888888FF88888888FF88888888FF
        88888888F7888888887F888888887F888888880F8888888F877888888778F888
        888788F888888078F888888F887888888788F888888788F888888078F88888F8
        8877888877888F888878888F888807888F8888F88887888878888F888878888F
        888807888F888F8888877887788888F887888888F880788888F88FFFFFFF7887
        777777F887777777F880000000F8888888888888888888888888888888888888
        8888}
      Margin = 60
      NumGlyphs = 4
      Spacing = 2
      OnClick = sbEncounterClick
      Align = alClient
      OnResize = sbResize
    end
  end
  object pnlTemplatesButton: TKeyClickPanel
    Left = 0
    Top = 0
    Width = 189
    Height = 22
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Templates'
    TabOrder = 0
    TabStop = True
    OnClick = sbTemplatesClick
    OnEnter = pnlTemplatesButtonEnter
    OnExit = pnlTemplatesButtonExit
    object sbTemplates: TORAlignSpeedButton
      Left = 0
      Top = 0
      Width = 189
      Height = 22
      AllowAllUp = True
      GroupIndex = 1
      Caption = 'Templates'
      Glyph.Data = {
        3E010000424D3E010000000000007600000028000000280000000A0000000100
        040000000000C800000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
        888888888888888888888888888888887788888888FF88888888FF88888888FF
        88888888F7888888887F888888887F888888880F8888888F877888888778F888
        888788F888888078F888888F887888888788F888888788F888888078F88888F8
        8877888877888F888878888F888807888F8888F88887888878888F888878888F
        888807888F888F8888877887788888F887888888F880788888F88FFFFFFF7887
        777777F887777777F880000000F8888888888888888888888888888888888888
        8888}
      Margin = 60
      NumGlyphs = 4
      PopupMenu = popTemplates
      Spacing = 2
      OnClick = sbTemplatesClick
      Align = alClient
      OnResize = sbResize
    end
  end
  object pnlOrdersButton: TKeyClickPanel
    Left = 0
    Top = 279
    Width = 189
    Height = 22
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Orders'
    TabOrder = 6
    TabStop = True
    OnClick = sbOrdersClick
    OnEnter = pnlTemplatesButtonEnter
    OnExit = pnlTemplatesButtonExit
    object sbOrders: TORAlignSpeedButton
      Left = 0
      Top = 0
      Width = 189
      Height = 22
      AllowAllUp = True
      GroupIndex = 1
      Caption = 'Orders'
      Glyph.Data = {
        3E010000424D3E010000000000007600000028000000280000000A0000000100
        040000000000C800000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
        888888888888888888888888888888887788888888FF88888888FF88888888FF
        88888888F7888888887F888888887F888888880F8888888F877888888778F888
        888788F888888078F888888F887888888788F888888788F888888078F88888F8
        8877888877888F888878888F888807888F8888F88887888878888F888878888F
        888807888F888F8888877887788888F887888888F880788888F88FFFFFFF7887
        777777F887777777F880000000F8888888888888888888888888888888888888
        8888}
      Margin = 60
      NumGlyphs = 4
      Spacing = 11
      OnClick = sbOrdersClick
      Align = alClient
      OnResize = sbResize
    end
  end
  object lbOrders: TORListBox
    Left = 0
    Top = 301
    Width = 189
    Height = 64
    Align = alTop
    ItemHeight = 13
    Items.Strings = (
      'Orders')
    ParentShowHint = False
    ShowHint = True
    TabOrder = 7
    Visible = False
    Caption = 'Orders'
    ItemTipColor = clWindow
    LongList = False
  end
  object lbEncounter: TORListBox
    Left = 0
    Top = 129
    Width = 189
    Height = 64
    Align = alTop
    ItemHeight = 13
    Items.Strings = (
      'Encounter')
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    Visible = False
    Caption = 'Encounter'
    ItemTipColor = clWindow
    LongList = False
  end
  object pnlTemplates: TPanel
    Left = 0
    Top = 22
    Width = 189
    Height = 85
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    Visible = False
    object tvTemplates: TORTreeView
      Left = 0
      Top = 38
      Width = 189
      Height = 47
      Align = alClient
      DragMode = dmAutomatic
      HideSelection = False
      Images = dmodShared.imgTemplates
      Indent = 19
      ParentShowHint = False
      PopupMenu = popTemplates
      ReadOnly = True
      RightClickSelect = True
      ShowHint = False
      TabOrder = 1
      OnClick = tvTemplatesClick
      OnCollapsing = tvTemplatesCollapsing
      OnDblClick = tvTemplatesDblClick
      OnExpanding = tvTemplatesExpanding
      OnGetImageIndex = tvTemplatesGetImageIndex
      OnGetSelectedIndex = tvTemplatesGetSelectedIndex
      OnKeyDown = tvTemplatesKeyDown
      OnKeyUp = tvTemplatesKeyUp
      Caption = 'Templates'
      NodePiece = 2
      OnDragging = tvTemplatesDragging
    end
    object pnlTemplateSearch: TPanel
      Left = 0
      Top = 0
      Width = 189
      Height = 38
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      OnResize = pnlTemplateSearchResize
      DesignSize = (
        189
        38)
      object btnFind: TORAlignButton
        Left = 134
        Top = 0
        Width = 55
        Height = 21
        Hint = 'Find Template'
        Anchors = [akTop, akRight]
        Caption = 'Find'
        ParentShowHint = False
        PopupMenu = popTemplates
        ShowHint = True
        TabOrder = 1
        OnClick = btnFindClick
      end
      object edtSearch: TCaptionEdit
        Left = 0
        Top = 0
        Width = 134
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        OnChange = edtSearchChange
        OnEnter = edtSearchEnter
        OnExit = edtSearchExit
        Caption = 'Text to find'
      end
      object cbMatchCase: TCheckBox
        Left = 0
        Top = 21
        Width = 80
        Height = 17
        Caption = 'Match Case'
        TabOrder = 2
        OnClick = cbFindOptionClick
      end
      object cbWholeWords: TCheckBox
        Left = 80
        Top = 21
        Width = 109
        Height = 17
        Caption = 'Whole Words Only'
        TabOrder = 3
        OnClick = cbFindOptionClick
      end
    end
  end
  object tvReminders: TORTreeView
    Left = 0
    Top = 215
    Width = 189
    Height = 64
    HelpContext = 11300
    Align = alTop
    HideSelection = False
    Images = dmodShared.imgReminders
    Indent = 23
    ReadOnly = True
    RightClickSelect = True
    StateImages = dmodShared.imgReminders
    TabOrder = 5
    OnCollapsed = tvRemindersCurListChanged
    OnExpanded = tvRemindersCurListChanged
    OnKeyDown = tvRemindersKeyDown
    OnMouseUp = tvRemindersMouseUp
    Caption = 'Reminders'
    NodePiece = 0
    OnNodeCaptioning = tvRemindersNodeCaptioning
  end
  object popTemplates: TPopupMenu
    OnPopup = popTemplatesPopup
    Left = 8
    Top = 70
    object mnuCopyTemplate: TMenuItem
      Caption = 'Copy Template Text'
      ShortCut = 16451
      OnClick = mnuCopyTemplateClick
    end
    object mnuInsertTemplate: TMenuItem
      Caption = '&Insert Template'
      ShortCut = 16429
      OnClick = mnuInsertTemplateClick
    end
    object mnuPreviewTemplate: TMenuItem
      Caption = '&Preview/Print Template'
      ShortCut = 16471
      OnClick = mnuPreviewTemplateClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object mnuGotoDefault: TMenuItem
      Caption = '&Goto Default'
      ShortCut = 16455
      OnClick = mnuGotoDefaultClick
    end
    object mnuDefault: TMenuItem
      Caption = '&Mark as Default'
      ShortCut = 16416
      OnClick = mnuDefaultClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object mnuViewNotes: TMenuItem
      Caption = '&View Template Notes'
      ShortCut = 16470
      OnClick = mnuViewNotesClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object mnuFindTemplates: TMenuItem
      Caption = '&Find Templates'
      ShortCut = 16454
      OnClick = mnuFindTemplatesClick
    end
    object mnuCollapseTree: TMenuItem
      Caption = '&Collapse Tree'
      OnClick = mnuCollapseTreeClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object mnuEditTemplates: TMenuItem
      Caption = '&Edit Templates'
      OnClick = mnuEditTemplatesClick
    end
    object mnuNewTemplate: TMenuItem
      Caption = 'Create &New Template'
      OnClick = mnuNewTemplateClick
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object mnuViewTemplateIconLegend: TMenuItem
      Caption = 'Template Icon Legend'
      OnClick = mnuViewTemplateIconLegendClick
    end
  end
end

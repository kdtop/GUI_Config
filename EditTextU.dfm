object EditWPTextForm: TEditWPTextForm
  Left = 299
  Top = 202
  Caption = 'Edit Text'
  ClientHeight = 446
  ClientWidth = 658
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 408
    Width = 658
    Height = 38
    Align = alBottom
    TabOrder = 0
    ExplicitWidth = 667
    DesignSize = (
      658
      38)
    object RevertBtn: TBitBtn
      Left = 399
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Revert'
      Enabled = False
      TabOrder = 0
      OnClick = RevertBtnClick
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000120B0000120B00000000000000000000FF00FFFF00FF
        FF00FFFF00FFFF00FF000288010893010B99010C99010893000389FF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000186010D9D021CAF021FB402
        1FB5021FB5021FB2021CB0010F9F000287FF00FFFF00FFFF00FFFF00FFFF00FF
        00038A0118B2021FB7021EB1021DB1021DB1021DB1021DB1021EB2021FB40219
        AC00048EFF00FFFF00FFFF00FF0001830118BB0220CC011CBF0015B4011AB002
        1DB1021DB1011CB00015AD011BB0021FB4021AAC000287FF00FFFF00FF010CA7
        0121E0011CD30726CC4966D70B28BC0018B00019AF0622B44A66CE0D2BB7011B
        B0021FB5010F9FFF00FF000187011CDC0120ED0017DC3655E2FFFFFFA4B4ED05
        20BB0119B28B9EE1FFFFFF4E6ACF0014AC021EB2021CB000038900069A0120F8
        011FF6001DE9031FE1738BEEFFFFFFA0B1ED93A5E7FFFFFF91A4E20823B4011B
        B0021DB1021FB4010895020CAA0A2EFE0323FB011FF6001CEB0018E1788FF0FF
        FFFFFFFFFF96A7EA021BB50019AF021DB1021DB10220B5010C99040EAC294DFE
        0D30FB011FFA001CF7011CEE8EA1F4FFFFFFFFFFFFA6B6EE0520C20018B6021D
        B1021DB10220B5010B980208A04162FB2F51FC001EFA0725FA8AA0FEFFFFFF8E
        A3F67991F2FFFFFFA3B4EE0C29C6011BB8021DB4021FB2000793000189314FEF
        7690FF0F2DFA3354FBFFFFFF91A5FE021EF30017E7738BF3FFFFFF4765E00016
        C2021FBD021CB2000288FF00FF0C1BBC819AFF728BFE1134FA3456FB0526FA00
        1CFA001CF40220ED3353ED0625DA011DD00220CB010DA1FF00FFFF00FF000189
        2943E6A5B7FF849AFC2341FB0323FA011FFA011FFA001EF7011BEE021FE50121
        E20118BF000184FF00FFFF00FFFF00FF01038F2A45E693A9FFABBBFF758FFE49
        69FC3658FB3153FC2346FC092CF70118CB00038BFF00FFFF00FFFF00FFFF00FF
        FF00FF0001890F1DBF3E5BF36B87FE728CFF5E7BFE395BFB1231EB010FB50001
        84FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000189030AA306
        11B2050FB10107A0000188FF00FFFF00FFFF00FFFF00FFFF00FF}
      ExplicitLeft = 408
    end
    object ApplyBtn: TBitBtn
      Left = 483
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Apply'
      Enabled = False
      TabOrder = 1
      OnClick = ApplyBtnClick
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000120B0000120B00000000000000000000FF00FF0274AC
        0274AC0274AC0274AC0274AC0274AC0274AC0274AC0274AC0274AC0274AC0274
        AC0274ACFF00FFFF00FF0274AC48BCF60274AC8CD8FA4BBFF74ABFF64ABFF74A
        BFF74ABFF64ABFF74ABFF64BBFF62398CC97E0F20274ACFF00FF0274AC4FC4F7
        0274AC92DDFB54C7F854C7F753C7F854C7F754C7F854C7F854C7F853C7F7279D
        CE9DE3F20274ACFF00FF0274AC57CAF80274AC99E3FB5ED1FA5ED1FA5ED1FA5E
        D1FA5ED1FA5FD1FA5ED1F85ED1F82CA1CEA3E9F30274ACFF00FF0274AC5ED3FA
        0274ACA1E9FC69DCFA2C9D6703690804740A2C9C675ED0E269DCFA6ADDFB2FA6
        CFA9EEF30274ACFF00FF0274AC67D9F70274ABA7EFFC74E5FB74E5FB39AC7E05
        7F0B04800B157F2E70E2F674E5FB33A9CFACF0F40274ACFF00FF0274AC6FE3FA
        0274ABFFFFFFBAF4FEB8F4FEBAF4FE58B27E05860D047E0A1E812DB8F4FE83C9
        E0D4F7FA0274ACFF00FF0274AC7AEBFE0274AC0274AC0274AC0274AC0274AC02
        6C7005830C06910D03681102709A0274AC0274AC0274ACFF00FF0274AC83F2FE
        82F3FE82F3FE83F2FC83F3FE82F3FE5BC7B00A80140A9A14047B0B49B591036F
        A7FF00FFFF00FFFF00FF0274ACFEFEFE89FAFF89FAFE89FAFE8AF8FE8AFAFE6C
        D9C90F871F13A926098E122D9754036FA7FF00FFFF00FFFF00FFFF00FF0274AC
        FEFEFE8FFEFF046B0B046B0B046B0B046B0B15932A1FB53812A123046B0B046B
        0B046B0B046B0BFF00FFFF00FFFF00FF0274AC0274AC027399046B0B107D1D36
        CE6032C95A27BC471DB03614A527098713046B0BFF00FFFF00FFFF00FFFF00FF
        FF00FFFF00FFFF00FFFF00FF046B0B1D993541DE7535CC5D2BC24D1AA732046B
        0BFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF04
        6B0B27AC4546E37A35CA5C046B0BFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
        FF00FFFF00FFFF00FFFF00FFFF00FFFF00FF046B0B2DB851046B0BFF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
        00FFFF00FF046B0BFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF}
      ExplicitLeft = 492
    end
    object DoneBtn: TBitBtn
      Left = 565
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Done'
      TabOrder = 2
      OnClick = DoneBtnClick
      Glyph.Data = {
        BE060000424DBE06000000000000360400002800000024000000120000000100
        0800000000008802000000000000000000000001000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
        A600000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000F0FBFF00A4A0A000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00030303030303
        0303030303030303030303030303030303030303030303030303030303030303
        03030303030303030303030303030303030303030303FF030303030303030303
        03030303030303040403030303030303030303030303030303F8F8FF03030303
        03030303030303030303040202040303030303030303030303030303F80303F8
        FF030303030303030303030303040202020204030303030303030303030303F8
        03030303F8FF0303030303030303030304020202020202040303030303030303
        0303F8030303030303F8FF030303030303030304020202FA0202020204030303
        0303030303F8FF0303F8FF030303F8FF03030303030303020202FA03FA020202
        040303030303030303F8FF03F803F8FF0303F8FF03030303030303FA02FA0303
        03FA0202020403030303030303F8FFF8030303F8FF0303F8FF03030303030303
        FA0303030303FA0202020403030303030303F80303030303F8FF0303F8FF0303
        0303030303030303030303FA0202020403030303030303030303030303F8FF03
        03F8FF03030303030303030303030303FA020202040303030303030303030303
        0303F8FF0303F8FF03030303030303030303030303FA02020204030303030303
        03030303030303F8FF0303F8FF03030303030303030303030303FA0202020403
        030303030303030303030303F8FF0303F8FF03030303030303030303030303FA
        0202040303030303030303030303030303F8FF03F8FF03030303030303030303
        03030303FA0202030303030303030303030303030303F8FFF803030303030303
        030303030303030303FA0303030303030303030303030303030303F803030303
        0303030303030303030303030303030303030303030303030303030303030303
        0303}
      NumGlyphs = 2
      ExplicitLeft = 574
    end
  end
  object Memo: TMemo
    Left = 0
    Top = 0
    Width = 658
    Height = 408
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Fixedsys'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 1
    OnChange = MemoChange
    ExplicitWidth = 667
  end
end

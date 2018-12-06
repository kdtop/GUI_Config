object FindingDetailForm: TFindingDetailForm
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'View Finding Item Detail'
  ClientHeight = 356
  ClientWidth = 639
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBottom: TPanel
    Left = 0
    Top = 321
    Width = 639
    Height = 35
    Align = alBottom
    TabOrder = 0
    ExplicitWidth = 636
    DesignSize = (
      639
      35)
    object RevertBtn: TBitBtn
      Left = 397
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Revert'
      TabOrder = 0
      Visible = False
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
      ExplicitLeft = 394
    end
    object ApplyBtn: TBitBtn
      Left = 478
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Apply'
      TabOrder = 1
      Visible = False
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
      ExplicitLeft = 475
    end
    object DoneBtn: TBitBtn
      Left = 559
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Done'
      ModalResult = 1
      TabOrder = 2
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        0400000000000001000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555555555
        5555555555555555555555555555555555555555555555555555555555555555
        5555555555555555555555555555555555555555555555555555555555055555
        5555555555555555555555555000555555555555555555555555555500000555
        5555555555555555555555550050005555555555555555555555555505550005
        5555555555555555555555555555500555555555555555555555555555555505
        5555555555555555555555555555555555555555555555555555555555555555
        5555555555555555555555555555555555555555555555555555555555555555
        5555555555555555555555555555555555555555555555555555}
      NumGlyphs = 2
      ExplicitLeft = 556
    end
    object btnDetails: TBitBtn
      Left = 16
      Top = 6
      Width = 137
      Height = 21
      Anchors = [akLeft, akBottom]
      Caption = 'Examine &Details'
      TabOrder = 3
      OnClick = btnDetailsClick
      Glyph.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        20000000000000040000120B0000120B000000000000000000002F373AFF2F37
        3AFF043464FF6E7D88FF9BA7A9FFA8B5B8FFB5C3C6FFD8E9ECFFD8E9ECFFD8E9
        ECFFD8E9ECFFD8E9ECFFD8E9ECFFD8E9ECFFD8E9ECFFD8E9ECFF2F373AFFDDE1
        C0FF053F7AFF043464FFA5B6C0FFD8E9ECFFD8E9ECFFD8E9ECFFD8E9ECFFD8E9
        ECFFD8E9ECFFD8E9ECFFD8E9ECFFD8E9ECFFD8E9ECFFD8E9ECFF135C9CFF9FD7
        F4FF1764A5FF053F7AFF013E7BFFAABDC8FFA9B1ADFF84847CFF79776DFF7775
        6BFF82827AFFA5ACA8FFD2E2E4FFD8E9ECFFD8E9ECFFD8E9ECFFD8E9ECFF135C
        9CFFCAF3FDFF043261FF273D5CFF5A5852FF7F705CFFAB8F70FFCAA47DFFC8A2
        7BFFA98B6DFF7B6C59FF6E6A5EFFB6C1BFFFD8E9ECFFD8E9ECFFD8E9ECFFACC1
        CCFF135C9CFF273D5CFF635D51FFB99976FFFED4A1FFFEF2DFFFFFFFF2FFFFFF
        F3FFFEFADEFFFDDFABFFC09F7CFF645E51FFB5BFBEFFD8E9ECFFD8E9ECFFD8E9
        ECFFA9BCC7FF5B5951FFB19171FFFEE0AFFFFEF0C1FFFEF1BDFFFEEBB2FFFDE9
        AFFFFEEDB4FFFFF6C3FFFEECB9FFC8AA84FF6B665BFFCFDFE0FFD8E9ECFFD8E9
        ECFFA2A8A4FF806F5BFFFDD8A9FFFCD8A6FFFCD8A6FFFBD7A2FFFCD88FFFFCD9
        92FFFCD68EFFFCD69FFFFCDDADFFFDDEADFF91846BFF9BA09BFFD8E9ECFFD8E9
        ECFF7F7F76FFC59977FFFDC896FFFAC491FFF8C391FFF8C593FFF8CC90FFF9CE
        91FFFACC96FFF9C190FFF9BD89FFFBCB9AFFC2A17DFF7A796EFFD8E9ECFFD8E9
        ECFF6E6A5EFFDEAD85FFF9B987FFF6BC89FFF0B280FFEEB07EFFEEB280FFF0B5
        83FFEFB382FFF1B27EFFF4B683FFF9BA88FFD8B089FF6A6557FFD8E9ECFFD8E9
        ECFF6C685CFFDAA67EFFF5B582FFEEB07DFFECAA78FFECAA78FFECAA78FFECAA
        78FFECAA78FFECAA78FFEFAE7BFFF8B985FFD6AA84FF645E51FFD8E9ECFFD8E9
        ECFF7A796FFFBE9876FFF0AF7FFFF0B07DFFEDAB78FFECAA78FFECAA78FFECAA
        78FFECAA78FFEEAC7AFFF3B481FFF5B583FFBC9878FF737066FFD8E9ECFFD8E9
        ECFF9BA09BFF8F7E66FFE09E75FFF4B784FFF4B682FFF3B380FFF1B17EFFF1B0
        7DFFF2B37FFFF6B884FFF9BC88FFE9A87BFF8E7F68FF949892FFD8E9ECFFD8E9
        ECFFCCDBDDFF757061FFA27D61FFDD9F74FFF8C391FFFFFBEFFFFFFFFFFFFFFF
        FFFFFFFCF1FFFBCF9EFFEAAA7CFFAC8466FF726C5DFFC7D5D5FFD8E9ECFFD8E9
        ECFFD8E9ECFFAEB7B4FF675F52FFA77F62FFD8A078FFF6DCC1FFFEFCFBFFFFFD
        FBFFF8E0C7FFE7AC81FFAD8466FF665F51FFA5ACA8FFD8E9ECFFD8E9ECFFD8E9
        ECFFD8E9ECFFD8E9ECFFB3BDBAFF6C685CFF7D6A57FFA98063FFC38E6BFFC590
        6DFFAC8365FF7E6B58FF696559FFAEB7B4FFD8E9ECFFD8E9ECFFD8E9ECFFD8E9
        ECFFD8E9ECFFD8E9ECFFD8E9ECFFCEDDDFFF939690FF6E6A5EFF635D50FF635D
        50FF6C685CFF90938CFFCBDADBFFD8E9ECFFD8E9ECFFD8E9ECFF}
    end
  end
  object pnlVennDisplay: TPanel
    Left = 0
    Top = 0
    Width = 639
    Height = 321
    Align = alClient
    TabOrder = 1
    OnResize = pnlVennDisplayResize
    ExplicitWidth = 636
  end
end
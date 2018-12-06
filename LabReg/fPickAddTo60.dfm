object frmPickAdd60: TfrmPickAdd60
  Left = 0
  Top = 0
  Caption = 'Select or Add Laboratory Test'
  ClientHeight = 562
  ClientWidth = 830
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    830
    562)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 294
    Height = 13
    Caption = 'Select a VistA laboratory test to use for storing HL7 lab result'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 28
    Width = 63
    Height = 16
    Caption = 'HL7 Name:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblLabName: TLabel
    Left = 77
    Top = 27
    Width = 218
    Height = 18
    Caption = '<laboratory test name here>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label6: TLabel
    Left = 8
    Top = 50
    Width = 58
    Height = 16
    Caption = 'HL7 Type:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblLabType: TLabel
    Left = 77
    Top = 51
    Width = 51
    Height = 13
    Caption = 'lblLabType'
  end
  object Image1: TImage
    Left = 410
    Top = 2
    Width = 64
    Height = 64
    Picture.Data = {
      07544269746D617036300000424D363000000000000036000000280000004000
      000040000000010018000000000000300000130B0000130B0000000000000000
      0000FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFC3C3C3C6C6C6FF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FF858585A6A6A68D8D8DA6A6A6FF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FF7C7B7B9392907776728C8C8BFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFA0A0A07776745A5852504D463B36284E4A407E7D7AFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FF9494936F6D6955534C525049716E699F9E9A97948C5752453E392B5B5851
      888886FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF89888664
      625D4F4C4557534C7F7C77AAA8A5B3B2AFAFAEAB9E9D99ABA9A48E8B83524D41
      444035686560929291FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF7D7B785957504D49415F
      5C548D8B86B2B0ADAFADAA96948F828180ACACAC8E8E8D8685809E9C97ADABA6
      86837B504B404D494173716FFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FF999998706E6A524E474D49406B67609C9A95B5
      B4B0A9A7A393918C8B898388868080807FADADAD8E8E8E85837F8B88838E8C86
      A4A29DACAAA57E7B734F4B4256534E7F7E7CFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FF8E8C8B65625D4B483F504C4379756EA8A6A2B4B3AFA19F9B90
      8D888C89848D8A858D8B8589878280807FADADAD8E8E8E86847F8C8A848C8A84
      8B8883918F8AA9A7A3AAA8A376736C524E46615F5AFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FF807F7C59564F48433958544A88867FB0AEAAB1AFAB9B99948E8C878D8B858E
      8B868E8B868D8B868E8B868A878280807FADADAD8E8E8E86847F8D8A858C8A84
      8D8A858C8A848B898395938EAEADA9A5A49F706D6755534D6B6A67FF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF9E9E9D74716D4F4C
      43474338646057989590B5B3AFABA9A597948F8F8C878F8D878F8C878F8C878F
      8C868F8C868E8C868E8C868A888280807FADADAD8F8E8E8685808D8B858D8A85
      8D8B858D8B858D8B858D8A848C8A849A9893B3B1ADA09E9A6B69645B59557575
      74FF00FF9797979B9B9B979797FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FF91908E66645D49443A4A453A7370
      67A6A39EB6B4B0A5A39F94918C908D88908D89908E89908E888F8D888F8D878F
      8C878F8C878F8C878F8C868B888380807FADADAD8F8E8E8785808E8B868D8B85
      8E8B858E8B858E8B858E8B858D8B858D8A858E8C86A09E9AB6B4B19A99956967
      63605F5C949493A3A3A38A8A8AFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FF8583805A564F433E33524D41838078AFADA9B3B1
      AE9F9D9993908C918F8A928F8A928F8A918E89918E89918E88908D88908D8890
      8D87908D878F8D878F8D878B898380807FADADAD8F8F8E8886818F8C868E8C86
      8E8C868E8C868E8C868E8C868E8C868E8B868E8C868D8B85918E89A7A6A1B7B6
      B39392906F6F6C7777767E7E7EFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFB1B1B19E9E9E999999
      FF00FFFF00FF7775704F4B41423D305E594E94918AB5B3AFAEACA99B98949390
      8C93908C93918C93908B92908B928F8A928F8A928F8A918E89908E89908E8890
      8D88908D88908D87908D878C898480807FADADAD8F8F8E8886818F8C868E8C86
      8E8B858D8B858D8A848D8A848D8A848D8A848D8A848D8B858D8B858D8A859391
      8CAEACA8B6B5B38C8B8A696867797878FF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF8B8B8BA4A4A4898886
      605E57464136453F326E695FA3A09AB7B5B2A9A7A499969294928D95928E9592
      8E94928D94918C93918C93908B93908B928F8A928F8A928F89918E89918E8991
      8E88918E89908E88908E888C898480807FADADAD8F8E8E85837D8B87808A877F
      8A867F8A877F8A87808987818987838987838A88848C89838C8A848D8A858D8B
      858C89849E9D99BCBBB9B3B2B1878686FF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF767572646057443E31
      4B46387F7B72AFADA8B6B4B2A4A29F98959296949097949096948F96938F9593
      8E95928E95928D94918C94918C93918B93908B93908B93908A928F8A918E8990
      8D878F8C858C89828B878086837B7F7E7DADADAD8E8E8D82807989857D89867E
      89867E8987808A8781968E73A69760AA9A5C9F946C8F8B818C8A858E8B858E8C
      8682807D9D9D9DA2A2A2929191B6B6B6FF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFA6A6A3524D433C37285651448C887E
      ABA8A1AAA8A39C9A9596949098959198959297959297949197949096948F9693
      8F95938E95928E94928D94918C93908B918E89908C868D8A828A877F88847C86
      827A868278858178868279837F777F7E7CADADAD8E8E8D83807989857D89867E
      89867F8D897CBBA349EBC325FAD235FCD539F5CB24D1B1339991778D8B868C8A
      857D7C7A9D9D9DA3A3A3898989FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FF84837D6762569A968EB0ADA7969289
      7D786B7B76697F7A6E817D73858177918972999070958E778D89818C89838D89
      828C89818B88808A867E88847C868279858077837F75837F75837F75847F7684
      8077858177858178868279837F777F7E7CADADAD8E8E8D83807989857D89867E
      89867FBBA349FBD848FFF4BFFFFDF0FFFFF4FFF9D5FFE15CCFB03795938DFF00
      FF8383839D9D9DA3A3A38C8C8CFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFA6A4A187857E9F9E9D8F8E8B
      7873677B75687A75698D8159C5A52DE6BE1FEEC522E7BE1DC3A5308C82627E7A
      707F7B6F807B70807C71817C71817D72827D73827E74837F74837F7584807684
      8077858177858178868279837F777F7E7CADADAD8E8E8D83807989857D88857F
      958D6FEBCA46FFF9DBFBFAF9E6DAC5D5C09CD6C2A0ECDCB7EFCE47C2B994FF00
      FF8A8A8A9D9D9DA3A3A38C8C8CFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF8A8989A0A0A1919190
      7773687A74698D8159E1BB27FFE472FFF4C1FFF8D4FFF4BAFFDF56D6B226877F
      687F7A70807B70807C71817C72817D72827D73827E74837F75837F7584807684
      8077858177858178868279837F777F7E7CADADAD8E8E8D83807989857D878580
      A49662F8E494FAF7F3CBB385A67C2EA073218C641B937032D2AF43C7B776FF00
      FF8A8A8A9D9D9DA3A3A38C8C8CFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF939393A0A0A0929292
      FF00FF817E74C2A638FFEB92FFFFFDFBF9F8F1EBE5EFE8E2F7EFDFFCDB56AB96
      467E7A71807B70807C71817C72817D72827D73827E74837F75837F7584807684
      8077858177858178868279837F777F7E7CADADAD8E8E8D83807989857D87847F
      A4976AF8ECBEE1D2B6AD863EAA8237A88036664E21644C21AF8928C4B372FF00
      FF8A8A8A9D9D9DA3A3A38C8C8CFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF939393A0A0A0929292
      FF00FFFF00FFE0C761FFFEF1F1EAE2D2BA9EC6A986BFA280C1A98EE5CB87C8AB
      3B7F7A6F807B70807C71817C72807C74807C75807D76817E76837F7684807684
      8077858177858178868279837F777F7E7CADADAD8E8E8D817F798C8A85FF00FF
      AFA681F3E7BDD1BA90B48F4DB48F4CB18D4A6F582E816637C49C3DC4B373FF00
      FF8A8A8A9D9D9DA3A3A38C8C8CFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF939393A0A0A0929292
      FF00FFFF00FFE5D698FBF8F4D5C0A6C9AD8CCCB090A28D757F7060B69D71C7AA
      43807B6E807B70807C71827D70988B5CAE9946B49C41A593528B846E837F7784
      80778581778581788682798380777F7E7CADADAD8E8E8E9D9D9CFF00FFFF00FF
      C6BD9AF0E3B6D1BB90BD9E64BC9C5FB9985C76623B826B42C6A249C4B375FF00
      FF8A8A8A9D9D9DA3A3A38C8C8CFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF939393A0A0A0929292
      FF00FFFF00FFE5D7A3F1E9DED5BFA3D3BCA0D4BC9FA694808D7F6FD3BA90C6AA
      49807B6D7F7B7187806AC4A634F4CB2AFEDB4EFFDD54FBD331DDB723988C6283
      807885817785817885827C84827E7E7E7DAEAEAE8F8F8FB5B5B5FF00FFFF00FF
      C5BC9AEEE0B1D7C29BC7AC7AC5A770C0A36C6C5C3D6B5B3EBC9E4EC4B376FF00
      FF8A8A8A9D9D9DA3A3A38C8C8CFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF939393A0A0A0929292
      FF00FFFF00FFE3D5A0EFE6D8DDCBB4DBC8B0DBC7AEAD9E8C94887ADAC49DC4AA
      507F7B70807B70BEA43AFEDF5EFFF8D9FFFFFCFFFFFDFFFBE9FFE779D9B62A89
      8371888681FF00FFFF00FFFF00FF7979798B8B8A6967619C9C9AFF00FFFF00FF
      C4BB9AECDDACDBC9A4D0B98FCDB280C8AE7B6B5D42847353D4B465C1B178FF00
      FF8A8A8A9D9D9DA3A3A38C8C8CFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF939393A0A0A0929292
      FF00FFFF00FFE0D19DF2E9DAE5D8C4E3D4BEE3D2BBACA090827A70C4B393C4AC
      5FA4A3A1989073EBCD50FFFCE9FAF9F7E8DCCEDBC9B3DCCAB6ECDFCAF4D453AE
      A273FF00FFFF00FFA1A1A17878786565665D5D5B352F22403A2D77746EFF00FF
      BAB192EBDAA9E0CFAED9C7A5D4BD90CFB88974674D897A5DD6B96FC0B079FF00
      FF8A8A8A9D9D9DA3A3A38C8C8CFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF939393A0A0A0929292
      FF00FFFF00FFDDCD9BF4ECDCEDE3D2EADECBEADDC8AAA193878077E1D2B2C6AE
      66FF00FFC5BC97F4E4A3FBFAF9D9C6AFC6A885C4A682B19676B29A7FDBBE6BAC
      9D5F86878A6E6E6E6363636262626E6E6E898988716D633D3728332D1F47433A
      797053DACB9EE7D8B8E4D6BBDCC89FD7C2978D806384785FC7AE6DC0AF7CFF00
      FF8A8A8A9D9D9DA3A3A38C8C8CFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF939393A0A0A0929292
      FF00FFFF00FFDAC998F6EEDEF3ECDEF1E8D6F1E7D3B0AA9C8E8980EBDEC0C4AD
      6BFF00FFC9C1A3F5ECC8ECE3D8CFB597CFB596CCB3958174646F665C8177646F
      6C5F6161626565667C7C7CA09F9FBCBCBCBFBFBEB5B4B3A5A39F757167454034
      3C3729625B4BA59B86DDD4C2E5D5B0DFCDA5796F5A958971E0C887BDAD7CFF00
      FF8A8A8A9D9D9DA3A3A38C8C8CFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF939393A0A0A0929292
      FF00FFFF00FFD7C696F7F0DDF8F2E6F6EFDEF6EEDAC2BCAD979389D2C8ADC2AD
      6EFF00FFC8C1A5F3EAC7E8DACAD6C1A8C2B0999E92836C696562616162626370
      7172959595C6C5C3DDDCD7D4D3CDD3D2CFD8D7D6D5D4D2B7B6B3B4B3B1A8A7A3
      7D7A734E4A404541386A665CA99F89D9CBAC7E76649C937EE8D297BCAC7EFF00
      FF8A8A8A9D9D9DA3A3A38C8C8CFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF939393A0A0A0929292
      FF00FFFF00FFD4C294F6EED9F9F3E6F6EFDCF6EDD6B8B2A2959185E7DBBCBEA9
      6EFF00FFC5BDA2E5DAB8BFB7AD8F88806E6C69616161696969848484A6A5A5C7
      C7C5E6E4DEBEBDB68887826967645958565453515F5E5B7977739C9A95ABAAA6
      AEADACADACA983817B56534C4E4B44726D627772658B8065C9A952BBA979FF00
      FF8A8A8A9D9D9DA3A3A38C8C8CFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF939393A0A0A0929292
      FF00FFFF00FFD1BF92F5EBD4F9F3E5F5EDD8F5EAD1B0A9988E897CEEE1BFB8A1
      6AFF00FF8381777D7A6F656565626363767676999998B4B4B3B6B5B4A9A8A6CF
      CDC68886824746463B3B3B3736373332322E2E2E2929292424242B2A2A63625F
      9594929B9B99AEADACAFAEAC8988845F5D5953524E615A46967A30AB9D74FF00
      FF8A8A8A9D9D9DA3A3A38C8C8CFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF939393A0A0A0929292
      FF00FFFF00FFCFBC90F4EAD1F9F4E6F4EBD4F5E8C8AFA791837E72BAB19A7F75
      5C5E5D5B5D5D5C6A6A6A888889AAAAAAB7B7B6ADACAB9D9C9A9695939A9997BB
      B9B45E5E5D4948484646464241413D3D3D3938383434342F2F2F292828323232
      8887859797959695939C9B99AEAEACB4B3B191918E696867605F5B6D6B678A8A
      8A7D7D7D9E9E9EA3A3A38C8C8CFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF939393A0A0A0929292
      FF00FFFF00FFC9B487E7D3A4F4E8CBE7CD81CDB05584795356544E56544F5A59
      567473719F9F9DC3C3C1CAC9C6BCBBB7AFAEAAA7A6A39F9E9C989795969694A2
      A19E908F8C6463625151514949494444443F3F3F3B3B3B3A39394343426E6E6D
      9695939797959796949695939494929A9A98AEAEACB6B5B49796966F6F6F6262
      626767678C8C8C9D9D9D8D8D8DFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF939393A0A0A0929292
      FF00FFFF00FFB6965CB88F3DB1A27F7D704A554D364D4A425F5D58868481ADAC
      AAD5D4D0DBD9D3BEBDB6A7A5A09C9B969B9A96A2A19CADACA7B2B1ACA2A19E97
      97959B9A979796948988867A797871706F6D6D6C7171707D7C7B8E8D8C989896
      9796959B9A98A5A5A1AFAEAAB3B2ADB1B0ABAAA9A6A6A5A2B0AFAEB8B7B79A9A
      9A7070706464646E6E6E7A7A7AFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF939393A1A1A1949494
      9D9D9D95928C776A50584E37433F334A47406D6A65999894B4B4B2B1B0AFC2C0
      BCBCBAB47473725D5D5D5959595858585858585959595D5D5C6E6E6D9493909B
      9A989898969998969A99979A99979999979A99979A99979A9997999896999896
      B4B2ADD9D4C9EAE3D4F7F4EEF1EADCEDE3D1CFC9BAC3BEB3C6C1B8A8A6A2B1B0
      AFBAB9B99999996F6F6F6262626F6F6FFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF91919191908E716E68
      4A463D3C372B3B362A534F46807D77A9A7A4B4B3B2A8A7A59B9A98979694BAB8
      B38584825555565959595A5A5A5A5A5A5A5A5A5A5A5A5A5A5A57575766656595
      9492999997999896999896999896999896999896999896999896989795ABABA8
      D2C4AFDECBAFF0E6D4FCF9F5F4ECE0EDE2CE999185898378D6C5ABAE9D879898
      96A1A09EBDBCBBC0C0C09A9A9A767676C7C7C7FF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF9594905551483B3527312A1B
      3E382A6662589E9C96C7C6C1D0CFCAC5C3BEBDBBB6B7B5B0ACABA79E9D9B9E9D
      9B9E9C997676746262625C5C5C5A5A5A5A5A5A5B5B5B5E5E5E69696985858399
      98969998969897969998979B9A989C9B999B9A98999896999896999896A7A7A4
      B7A48BD9C4A9F5EEE1FDFBF8F7F2E9F3EBDC9C968D7D7973C0AE97977F629696
      94B0AFAECFCECEC9C9C8B4B4B3A9A9A8FF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FF8A8883332D1D2F28174A45367E7B71
      AAA9A4CFCCC6E5DCCEF1EBDEFAF8F3F4EFE4F3EBDCCEC9BDB9B6ADD8D4CBB7B5
      AF9D9C999B9A989392908988878382818181808584838D8C8B9695949B9A989A
      9997A6A4A1BAB8B3C1BFB9C0BEB8BDBBB5BBB9B4B7B5B0ACABA79D9C9A9A9998
      A3907BDECBB4F9F6EFFDFDFBFAF7F2F8F3EB9795908D8B87E2D1BCA1896D9696
      95959493A09F9EFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FF8B88846864589E9B94C4C3C1BCBBBA
      ABAAA8C6BCADC9B091F5EEE2FDFCF9F7F2E9F5EDE0B7B2A887847ECCC3B5C4AF
      93A3A19D9998979A99979B9A989B9A989B9A989B9A989B9A989A99979A9997B6
      B4B0C4C2BB9998937B7B796F6E6D6B6B6A6E6E6D7A797791908CA7A5A19D9D9B
      9F8D77E1D1BEFEFDFCFEFEFEFDFCFBFDFBF9A7A6A59B9B9AE3D5C59C876DAFB0
      B0FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFBFBFBEACACAAACACABC4C4C3BDBDBC
      A2A2A0B0A698C8AF91F8F4ECFEFDFBFAF6F0F9F3EAB5B2AC928F8BEAE0D3A78A
      6794908C9A99989A99979A99979A99979A99979A99979A99979A99979D9C9AC6
      C4BE7373715859595A5A5A5B5B5B5B5B5B5B5B5B5A5A5A5A5A5A6A6A69949493
      A08E78E2D4C2FFFFFFFFFFFFFFFFFFFFFFFFC8C8C8A7A8A9C5B8AAA38E75FF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFC9C9C9A9A8A7969695
      9594939B9185CAB396FCF9F5FEFEFDFCFAF7FCF9F4BDBBB79D9B99EFE8DEB093
      719996919A99979998969B9A989E9D9BA1A09DA1A09D9F9E9C9B9A98999896AB
      AAA681807E6060605B5B5B5B5B5B5B5B5B5B5B5B5B5B5B5E5E5E6F6F6E949493
      A08E78E2D3C2FFFFFFFFFFFEFFFEFCFFFEFCFFFFFEFFFFFFE5D8CAA28D74FF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      BFBFC09A9187C9B399FFFEFDFFFFFEFEFEFDFFFEFDCFCECDA6A6A6D4CFC8B195
      74999691A2A19FBCB9B3D4CFC6E4E1DBE5E0D6E2DCCFCAC6BCC9C5BDB9B7B1A0
      9F9C9D9C99908F8D7F7F7D7575747171707473727B7B7A878785929290939393
      978670E4D0ACFAEFD0EEDFB9E3D0A8D9C29BD5BD98DCC7A9D6BFA1A18C72FF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFC7B299FFFFFFFFFEFDFEFDF9FEFCF8FCFBF9F8F8F8EEEAE5B194
      73A09D98C2BBB0D3C1A8F4EBDBFCFAF6F6EFE4ECE2D1938E84B9B2A6CEB99DA5
      9F969A99989B9A989B9A989B9A97999896969593959493A1A0A0FF00FFFF00FF
      C1B8A0EEE5C9E3DDD0EBE5DDDAD3CBB4AA9F9183737C644A8D653A977551FF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFCBB389F7EBC9ECDCB4E3CFA6D9C299D3BB95D6BF9EDCC7ABAD8E
      69A09D99B2A89ACBB496F6EFE4FCFBF8F8F3EAEEE6DA8D8983A29D96B59B7A8D
      857A9B9A99999896959593959493A1A1A0FF00FFFF00FFFF00FFFF00FFFF00FF
      CFCFCECCCBCACAC8C7EFEFEFDEDEDEAEAEAD7F7E7D4E4E4C4C3C2C8F7050FF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFE5D8B9D9D1C1E5DFD7E3DED7BEB8B09990867E6F5F8568499F76
      4A988F859C9388CFB99EF9F5EDFDFCFAFAF7F1F1ECE4898782BFBCB5C7AE8F95
      8D83959594A2A2A2FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      C5C5C5A6A5A3CBCAC8F1F1F1E0E0DFB0B0AF817F7E4F4E4C423E39B1ACA8FF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFD0CDCBC0BEBCE8E8E7E8E9E9BBBBBA8C8B8A5B5B5A3E3831876A
      4B9F9891999187CEBAA2FDFAF7FEFDFCFDFBF8F6F3EFA1A09DCAC7C4C4AD91A7
      A098FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      E1E1E1A7A5A2CBC9C4C9C7C3B0AEAA94928F79777454524F474644FF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFA4A3A1BFBDBBEAE9E8EBEAEABDBDBC8E8D8B5D5C5A3A3834938F
      8BFF00FFB9B2A9CDBBA6FFFFFFFFFFFFFFFFFFFCFCFCCECECEC2C2C1B8A288BF
      B9B1FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFB4B2AD77746E4A484346433F46433E4744404845415D5B58FF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFABAAA8C5C3BEC9C8C4B8B6B3A09E9B8A88856C6A67474543AAAA
      A9FF00FFBBB4ABCDBBA5FFFEF9FBF7EBF9F2E4F8F1E4FAF5ECFCFAF7C2AC93BF
      B8B0FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFCDCCCC8B8A8764636158565358565363615E7E7D7BFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFBBBAB798969062605C5E5C58605D59605D5965635F686664BBBB
      BAFF00FFBBB4A6D7C396EEE0BCE6D6B4D9C6A6C5AF8FB9A07EC0A482B08E67B5
      ADA4FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFAAAAA882817F74737171706E7978758C8B8AB4B4B4FF00
      FFFF00FFC3C0B8DFD9CDCECBC6ECEBEADAD9D9A8A6A5797572594F44856340A2
      907EFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFC5C4C4B3B1AFC5C4C2EEEEEDDCDCDBA8A7A67473713F3E3C65584BFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFA2A19FCAC8C5E4E3E1CDCDCAA6A4A27C7A78484644727170FF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFB3B2AF9E9B9573716D6B686467656165625F5A5855858483FF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FF8685825B5957514F4C52504D5E5C597E7D7BFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FF}
    Transparent = True
  end
  object rgSelectMode: TRadioGroup
    Left = 1
    Top = 72
    Width = 209
    Height = 57
    Caption = 'Reuse Existing or Make New?'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Items.Strings = (
      'Select an existing lab test'
      'Add a new lab test')
    ParentFont = False
    TabOrder = 0
    OnClick = rgSelectModeClick
  end
  object pnlMain: TPanel
    Left = 0
    Top = 136
    Width = 830
    Height = 385
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvLowered
    TabOrder = 1
    ExplicitWidth = 833
    ExplicitHeight = 367
    object pnlPick: TPanel
      Left = 8
      Top = 16
      Width = 185
      Height = 233
      TabOrder = 0
      object edtLabSrch: TEdit
        Left = 1
        Top = 1
        Width = 183
        Height = 21
        Align = alTop
        TabOrder = 0
      end
      object lbLabSrch: TListBox
        Left = 1
        Top = 22
        Width = 183
        Height = 210
        Align = alClient
        ItemHeight = 13
        TabOrder = 1
      end
    end
    object pnlAdd: TPanel
      Left = 48
      Top = 0
      Width = 673
      Height = 353
      TabOrder = 1
      object pnlPickDN: TPanel
        Left = 13
        Top = 16
        Width = 644
        Height = 201
        BevelOuter = bvLowered
        TabOrder = 0
        DesignSize = (
          644
          201)
        object Label3: TLabel
          Left = 1
          Top = 3
          Width = 298
          Height = 13
          Caption = 
            'Pick existing storage location for storage of HL7 lab test resul' +
            't'
        end
        object edtDNSrch: TEdit
          Left = 0
          Top = 22
          Width = 644
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
        end
        object lbDNSrch: TListBox
          Left = 1
          Top = 49
          Width = 642
          Height = 157
          Anchors = [akLeft, akTop, akRight, akBottom]
          ItemHeight = 13
          TabOrder = 1
        end
      end
      object pnlNewTest: TPanel
        Left = 13
        Top = 239
        Width = 609
        Height = 100
        BevelOuter = bvLowered
        TabOrder = 1
        object Label4: TLabel
          Left = 10
          Top = 51
          Width = 297
          Height = 13
          Caption = 'Enter shortened / abbreviated lab name (7 characters or less)'
        end
        object Label7: TLabel
          Left = 10
          Top = 5
          Width = 274
          Height = 13
          Caption = 'Enter name for new lab test name (30 characters or less)'
        end
        object edtAbrvDNName: TEdit
          Left = 10
          Top = 70
          Width = 55
          Height = 21
          MaxLength = 7
          TabOrder = 0
          OnChange = edtAbrvDNNameChange
        end
        object edtNewLabTestName: TEdit
          Left = 10
          Top = 24
          Width = 207
          Height = 21
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 30
          ParentFont = False
          TabOrder = 1
          OnChange = edtNewLabTestNameChange
        end
      end
      object pnlAddDN: TPanel
        Left = 101
        Top = 174
        Width = 530
        Height = 59
        BevelOuter = bvLowered
        TabOrder = 2
        DesignSize = (
          530
          59)
        object Label5: TLabel
          Left = 10
          Top = 5
          Width = 315
          Height = 13
          Caption = 'Enter name for new storage location name (30 characters or less)'
        end
        object edtNewDNName: TEdit
          Left = 10
          Top = 24
          Width = 207
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 30
          ParentFont = False
          TabOrder = 0
          OnChange = edtNewDNNameChange
        end
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 521
    Width = 830
    Height = 41
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 2
    ExplicitTop = 503
    ExplicitWidth = 833
    DesignSize = (
      830
      41)
    object btnCancel: TButton
      Left = 666
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 0
      ExplicitLeft = 669
    end
    object btnOK: TButton
      Left = 747
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&OK'
      Enabled = False
      TabOrder = 1
      OnClick = btnOKClick
      ExplicitLeft = 750
    end
  end
  object rgIsPanel: TRadioGroup
    Left = 216
    Top = 72
    Width = 209
    Height = 58
    Caption = 'Is Lab a Panel?  (e.g. '#39'CBC'#39' is a panel)'
    ItemIndex = 1
    Items.Strings = (
      'Lab is  a PANEL'
      'Lab is NOT a panel')
    TabOrder = 3
    OnClick = rgIsPanelClick
  end
  object rgDataName: TRadioGroup
    Left = 431
    Top = 72
    Width = 274
    Height = 58
    Caption = 'Option for Storage Location  (a.k.a. '#39'Data Name'#39')'
    ItemIndex = 0
    Items.Strings = (
      'Select an existing storage location'
      'Add a new storage location')
    TabOrder = 4
    OnClick = rgDataNameClick
  end
end
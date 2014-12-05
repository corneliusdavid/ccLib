object frmEDBTableLookup: TfrmEDBTableLookup
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'Lookup'
  ClientHeight = 306
  ClientWidth = 501
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 432
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Verdana'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  DesignSize = (
    501
    306)
  PixelsPerInch = 96
  TextHeight = 16
  object SearchCharacterLabel: TLabel
    Left = 8
    Top = 12
    Width = 129
    Height = 16
    Caption = '&Search Characters:'
    FocusControl = edtSearchChars
  end
  object lblSearchBy: TLabel
    Left = 8
    Top = 248
    Width = 93
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'Search &Index:'
    FocusControl = cmbSearchBy
  end
  object dbCtrlGrid: TDBCtrlGrid
    Left = 8
    Top = 35
    Width = 485
    Height = 204
    AllowDelete = False
    AllowInsert = False
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = srcLookup
    PanelHeight = 68
    PanelWidth = 468
    TabOrder = 5
    SelectedColor = clGradientActiveCaption
    OnDblClick = dbCtrlGridDblClick
    object Label1: TLabel
      Left = 0
      Top = 0
      Width = 17
      Height = 68
      Align = alLeft
      AutoSize = False
      Transparent = True
      ExplicitHeight = 86
    end
    object edtMemo: TDBMemo
      Left = 17
      Top = 0
      Width = 451
      Height = 68
      Align = alClient
      Ctl3D = False
      DataSource = srcLookup
      ParentCtl3D = False
      ReadOnly = True
      TabOrder = 0
      OnDblClick = edtMemoDblClick
    end
  end
  object edtSearchChars: TEdit
    Left = 153
    Top = 8
    Width = 340
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    CharCase = ecUpperCase
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 0
    OnChange = edtSearchCharsChange
    OnKeyDown = edtSearchCharsKeyDown
  end
  object dbgLookup: TDBGrid
    Left = 8
    Top = 35
    Width = 485
    Height = 205
    Anchors = [akLeft, akTop, akRight, akBottom]
    Ctl3D = False
    DataSource = srcLookup
    Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
    ParentCtl3D = False
    TabOrder = 6
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -13
    TitleFont.Name = 'Verdana'
    TitleFont.Style = []
    OnDblClick = dbgLookupDblClick
    Columns = <
      item
        Expanded = False
        Visible = True
      end>
  end
  object cmbSearchBy: TComboBox
    Left = 153
    Top = 245
    Width = 340
    Height = 24
    AutoDropDown = True
    Style = csDropDownList
    Anchors = [akLeft, akRight, akBottom]
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 1
    OnChange = cmbSearchByChange
  end
  object btn1: TBitBtn
    Left = 8
    Top = 275
    Width = 80
    Height = 26
    Anchors = [akLeft, akBottom]
    Caption = 'btn1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object btn2: TBitBtn
    Left = 89
    Top = 275
    Width = 80
    Height = 26
    Anchors = [akLeft, akBottom]
    Caption = 'btn2'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
  object btn3: TBitBtn
    Left = 171
    Top = 275
    Width = 80
    Height = 26
    Anchors = [akLeft, akBottom]
    Caption = 'btn3'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
  end
  object btn4: TBitBtn
    Left = 251
    Top = 275
    Width = 80
    Height = 26
    Anchors = [akLeft, akBottom]
    Caption = 'btn4'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
    TabOrder = 7
  end
  object btnOK: TBitBtn
    Left = 337
    Top = 275
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      18000000000000030000130B0000130B00000000000000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFBFBFBC1C4C08793836D83656B8264849080BDC1BCF9F9F9FFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD1D3D059784F23760B1D89001F
      91001F9100208B01207708547749CACBC9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      C1C6C030751E2197021E9E001CA0001EA2011DA20022A30223A0042098022A75
      16B7BBB6FFFFFFFFFFFFFFFFFFE0E1E0327723209E0517A10048B936B8E8B3BD
      E9B890D78620AD0421AB0421A5061F9E042C791BD7D9D7FFFFFFFFFFFF73906E
      1C9D061BA7041AAF06B4E6B0FFFFFFFDFFFFF0FCF44AC1381AB20122B30A1EA9
      071C9E06678A61FDFDFDE0E0DF3289281EAB0D0EAE005ECB53F3FEF7F1FFF3EE
      FEF0FAFFFD99DE9418B50621B80F1DB40A1DAB0C2D8B20D3D5D2A4B0A21F9A15
      1CB20F27BD1BD0F2D0FFFFFFBCEABC99DD95F9FFFBE1F8E338C32D1BBD0F20BC
      151FB4141C9E1292A59085A0831CA51715B70D6CD169E2F3E4D8EFD959CE5444
      CA3EE9F9EAFDFFFF82DB7F19C21224C41E20BA191CA717789B758BA5891EAA1E
      20BE1F30C83035C93538CB3835CC3435CC34B0E7B1FFFFFFCFF3D12FCA2E1FC7
      1E21BF211EAC1D7DA07CB6C2B628AA2C23C22722CB2626CF2A2DD03137D23B31
      D0356BDA6EF5FDF6F9FEFA68DB6B18C91C22C22724AD28A6B6A5EEF0EE4BA54F
      24C32D26CD2F29D3332ED43732D53B31D53A35D43DC7F0CAFFFFFFB9EFBD1FCA
      2923C42C42A546E8EAE8FFFFFF9AB59C28BD3527C9342AD4372CD73B2ED83C31
      D83F23D53181E288FFFFFFFDFFFE5BD4651EC02C8FB291FFFFFFFFFFFFF7F7F7
      6AB16F2BC43B2ACE3B2CD53E2DD93E2EDA4029D93B3DD94DACE7B3BCEBC27ADA
      8458A95EF1F2F1FFFFFFFFFFFFFFFFFFECF1EC70BC782EBF3F2AC83E2CD0402D
      D3412ED3422AD03E22C63728C03A64AF6BE3E6E3FFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFAFBFAB1DAB56ACB753CC04E34C14734C1463BC04C65CA71ADDBB1F7F9
      F7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFDFAE1F3E3BE
      E5C2BCE4C0DFF2E1F9FDF9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
    ModalResult = 1
    ParentFont = False
    TabOrder = 8
    OnClick = btnOKClick
  end
  object btnCancel: TBitBtn
    Left = 418
    Top = 275
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      18000000000000030000130B0000130B00000000000000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFAFAFAC0C0C5838395656583646483818192BCBCC2F7F7F7FFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD0D0D450507A0D0D7B01018C01
      019301019301018D0B0B7B4A4A7AC9C9CCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      C1C1C51E1E7900009500009C0000A30202A50202A50000A300009C0000961717
      7AB7B7BDFFFFFFFFFFFFFFFFFFDFDFE023237C0000995858BD6363C70000A904
      04B10404B10000AA5454C35E5EC000009B1A1A7DD7D7D9FFFFFFFEFEFE6E6E91
      00009B5353BCF8F8FDFBFBFD5F5FCB0000B20000B24D4DC7F0F0FAFEFEFF6262
      C100009C5E5E8CFCFCFCE0E0E226268C0000A94747C1E9E9F4FFFFFFF4F4FB59
      59CE4747C9EDEDF9FFFFFFF3F3F75A5AC60000A91D1D8FD5D5D7AAAAB611119E
      0B0BB50000B84040C6E6E6F3FFFFFFF6F6FCF2F2FBFFFFFFEFEFF75252CA0000
      B80C0CB60D0DA09696AA8484A31212A81313BB1616C50909C34646CCE9E9F7FF
      FFFFFFFFFFF3F3F95757CF0606C11515C51313BC1111AA74749B8C8CA81818AE
      1919C11C1CCA1212C95656D7ECECF9FFFFFFFFFFFFF5F5FB6767D91111C81B1B
      C91919C11818AF7D7DA2BBBBC72828AF2121C51212CB5C5CDAF0F0FAFFFFFFF2
      F2F8EEEEF7FFFFFFF6F6FC6E6EDE1212CB2121C62525B3A9A9B9EEEEF04C4CA8
      2020C76666D8F3F3FCFFFFFFF3F3F86969DB5959D9EBEBF6FFFFFFFCFCFE7676
      DC1F1FC64545ACE8E8EBFFFFFF9D9DB92B2BC36A6AD5F4F4F9F6F6FA7070DF2A
      2AD82A2AD96161DDEDEDF8F8F8FA7474D72B2BC78F8FB1FFFFFFFFFFFFF6F6F6
      7070B52E2ECA7070D77878DE2C2CDA3B3BDD3C3CDD2C2CDA6E6EDD7575D72F2F
      CC6565B3F0F0F2FFFFFFFFFFFFFFFFFFEAEAF07777C03A3AC43737CD4141D542
      42D84141D84242D53838CE3A3AC86E6EB7E3E3EAFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFF9F9FBB1B1DC7272CE5353C84A4AC84A4AC85050C66F6FCEAEAEDBF5F5
      F7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8F8FCE1E1F3BB
      BBE4B9B9E4DFDFF2F7F7FCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
    ModalResult = 2
    ParentFont = False
    TabOrder = 9
  end
  object srcLookup: TDataSource
    Left = 80
    Top = 128
  end
  object tmrKeystroke: TTimer
    Enabled = False
    Interval = 300
    OnTimer = tmrKeystrokeTimer
    Left = 160
    Top = 160
  end
end

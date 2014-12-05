object frmTableLookup: TfrmTableLookup
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
    Top = 247
    Width = 93
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'Search &Index:'
    FocusControl = cmbSearchBy
    ExplicitTop = 280
  end
  object RzDialogBtns: TRzDialogButtons
    Left = 0
    Top = 270
    Width = 501
    CaptionOk = 'OK'
    CaptionCancel = 'Cancel'
    CaptionHelp = '&Help'
    HotTrack = True
    ModalResultOk = 1
    ModalResultCancel = 2
    ModalResultHelp = 0
    ShowGlyphs = True
    OnClickOk = RzDialogBtnsClickOk
    TabOrder = 6
  end
  object dbCtrlGrid: TDBCtrlGrid
    Left = 8
    Top = 35
    Width = 485
    Height = 201
    AllowDelete = False
    AllowInsert = False
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = srcLookup
    PanelHeight = 67
    PanelWidth = 468
    TabOrder = 5
    SelectedColor = clGradientActiveCaption
    OnDblClick = dbCtrlGridDblClick
    object Label1: TLabel
      Left = 0
      Top = 0
      Width = 17
      Height = 67
      Align = alLeft
      AutoSize = False
      Transparent = True
      ExplicitHeight = 86
    end
    object edtMemo: TDBMemo
      Left = 17
      Top = 0
      Width = 451
      Height = 67
      Align = alClient
      Ctl3D = False
      DataSource = srcLookup
      ParentCtl3D = False
      ReadOnly = True
      TabOrder = 0
      OnDblClick = edtMemoDblClick
    end
  end
  object btn1: TRzBitBtn
    Left = 8
    Top = 275
    Width = 80
    Height = 26
    Anchors = [akLeft, akBottom]
    Caption = 'btn1'
    HotTrack = True
    TabOrder = 2
    Margin = -1
  end
  object btn2: TRzBitBtn
    Left = 89
    Top = 275
    Width = 80
    Height = 26
    Anchors = [akLeft, akBottom]
    Caption = 'btn2'
    HotTrack = True
    TabOrder = 3
    Margin = -1
  end
  object btn3: TRzBitBtn
    Left = 170
    Top = 275
    Width = 80
    Height = 26
    Anchors = [akLeft, akBottom]
    Caption = 'btn3'
    HotTrack = True
    TabOrder = 4
    Margin = -1
  end
  object cmbSearchBy: TRzComboBox
    Left = 152
    Top = 243
    Width = 341
    Height = 24
    Anchors = [akLeft, akRight, akBottom]
    AutoDropDown = True
    Style = csDropDownList
    Ctl3D = False
    ItemHeight = 16
    ParentCtl3D = False
    TabOrder = 1
    OnChange = cmbSearchByChange
  end
  object edtSearchChars: TRzEdit
    Left = 153
    Top = 8
    Width = 340
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    CharCase = ecUpperCase
    TabOrder = 0
    OnChange = edtSearchCharsChange
    OnKeyDown = edtSearchCharsKeyDown
  end
  object dbgLookup: TRzDBGrid
    Left = 8
    Top = 35
    Width = 485
    Height = 202
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = srcLookup
    Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
    TabOrder = 7
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -13
    TitleFont.Name = 'Verdana'
    TitleFont.Style = []
    OnDblClick = dbgLookupDblClick
  end
  object btn4: TRzBitBtn
    Left = 251
    Top = 275
    Width = 80
    Height = 26
    Anchors = [akLeft, akBottom]
    Caption = 'btn4'
    HotTrack = True
    TabOrder = 8
    Margin = -1
  end
  object srcLookup: TDataSource
    Left = 80
    Top = 128
  end
end

object frmIniPersistDemo: TfrmIniPersistDemo
  Left = 0
  Top = 0
  Caption = 'IniPersist Demo'
  ClientHeight = 379
  ClientWidth = 634
  Color = clBtnFace
  Constraints.MinHeight = 415
  Constraints.MinWidth = 650
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  DesignSize = (
    634
    379)
  TextHeight = 17
  object Label1: TLabel
    AlignWithMargins = True
    Left = 10
    Top = 10
    Width = 614
    Height = 51
    Margins.Left = 10
    Margins.Top = 10
    Margins.Right = 10
    Margins.Bottom = 5
    Align = alTop
    Caption = 
      'This program demonstrates the uConfigIniPersist unit in the \Sou' +
      'rce\Misc folder of this library. This unit defines a class that ' +
      'allows very simple loading and storing of configuration data to ' +
      'and from a standard .INI file.'
    WordWrap = True
    ExplicitWidth = 612
  end
  object Label2: TLabel
    Left = 384
    Top = 232
    Width = 101
    Height = 17
    Caption = 'Favorite Number:'
  end
  object Label3: TLabel
    Left = 493
    Top = 152
    Width = 80
    Height = 17
    Caption = 'Random Date'
  end
  object mmoRawConfig: TMemo
    AlignWithMargins = True
    Left = 10
    Top = 69
    Width = 368
    Height = 305
    Margins.Left = 10
    Margins.Bottom = 5
    TabStop = False
    Align = alLeft
    Lines.Strings = (
      '==RAW Config File==')
    ReadOnly = True
    TabOrder = 0
  end
  object edtDescription: TLabeledEdit
    Left = 384
    Top = 89
    Width = 228
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 66
    EditLabel.Height = 17
    EditLabel.Caption = '&Description'
    TabOrder = 1
    Text = ''
  end
  object chkOption1: TCheckBox
    Left = 384
    Top = 160
    Width = 75
    Height = 17
    Caption = 'Option 1'
    TabOrder = 2
  end
  object chkOption2: TCheckBox
    Left = 384
    Top = 183
    Width = 75
    Height = 17
    Caption = 'Option 2'
    TabOrder = 3
  end
  object edtFavNum: TSpinEdit
    Left = 384
    Top = 255
    Width = 121
    Height = 27
    MaxValue = 0
    MinValue = 0
    TabOrder = 4
    Value = 0
  end
  object btnLoad: TButton
    Left = 384
    Top = 312
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 5
    OnClick = btnLoadClick
  end
  object btnSave: TButton
    Left = 384
    Top = 343
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 6
    OnClick = btnSaveClick
  end
  object edtDateTimePicker: TDateTimePicker
    Left = 493
    Top = 175
    Width = 89
    Height = 25
    Date = 45422.000000000000000000
    Time = 0.974756909723510000
    TabOrder = 7
  end
  object grpConfigType: TRadioGroup
    Left = 480
    Top = 288
    Width = 146
    Height = 80
    Caption = 'Config Type'
    ItemIndex = 0
    Items.Strings = (
      'INI File'
      'TXT w/ Semicolons')
    TabOrder = 8
    OnClick = grpConfigTypeClick
  end
end

object frmRegLayoutSaver: TfrmRegLayoutSaver
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Registry Layout Saver Demo'
  ClientHeight = 196
  ClientWidth = 259
  Color = clBtnFace
  Constraints.MinHeight = 235
  Constraints.MinWidth = 275
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
  object Label1: TLabel
    Left = 40
    Top = 120
    Width = 47
    Height = 13
    Caption = 'Int Value:'
  end
  object edtStrValue: TLabeledEdit
    Left = 40
    Top = 40
    Width = 169
    Height = 21
    EditLabel.Width = 61
    EditLabel.Height = 13
    EditLabel.Caption = 'String Value:'
    TabOrder = 0
  end
  object edtBoolValue: TCheckBox
    Left = 40
    Top = 80
    Width = 97
    Height = 17
    Caption = 'Boolean Value'
    TabOrder = 1
  end
  object edtIntValue: TSpinEdit
    Left = 40
    Top = 139
    Width = 65
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 2
    Value = 0
  end
  object ccRegistryLayoutSaver1: TccRegistryLayoutSaver
    Location = 'Software\bds'
    Section = 'frmRegLayoutSaver'
    OnBeforeRestore = ccRegistryLayoutSaver1BeforeRestore
    OnBeforeSave = ccRegistryLayoutSaver1BeforeSave
    Left = 160
    Top = 136
  end
end

object frmTestAppIdleWarn: TfrmTestAppIdleWarn
  Left = 451
  Top = 420
  Width = 364
  Height = 282
  Caption = 'AppIdleWarn Test App'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object Label1: TLabel
    Left = 48
    Top = 24
    Width = 265
    Height = 73
    AutoSize = False
    Caption = 
      'Demo of using the CloseApplication component. Close-down set to ' +
      '%d minute with a %d second warning.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object chkShowAppName: TCheckBox
    Left = 48
    Top = 121
    Width = 265
    Height = 17
    Caption = 'Show Application Name in Warning Message'
    Checked = True
    State = cbChecked
    TabOrder = 0
    OnClick = chkShowAppNameClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 232
    Width = 356
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object chkUseCustomWarningMessage: TCheckBox
    Left = 48
    Top = 152
    Width = 257
    Height = 17
    Caption = 'Use Custom Warning Event Handler'
    TabOrder = 2
    OnClick = chkUseCustomWarningMessageClick
  end
  object CloseApplication1: TCloseApplication
    MinutesAppAllowedToBeIdle = 1
    SecondsPromptedOnShutdown = 20
    ShowAppName = True
    TimerInterval = 0
    OnResume = CloseApplication1Resume
    Left = 110
    Top = 182
  end
end

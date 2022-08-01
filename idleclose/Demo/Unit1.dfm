object frmTestAppIdleWarn: TfrmTestAppIdleWarn
  Left = 0
  Top = 0
  Caption = 'AppIdleWarn Test App'
  ClientHeight = 483
  ClientWidth = 717
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -24
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  PixelsPerInch = 192
  TextHeight = 32
  object Label1: TLabel
    Left = 96
    Top = 48
    Width = 529
    Height = 145
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    AutoSize = False
    Caption = 
      'Demo of using the CloseApplication component. Close-down set to ' +
      '1 minute with a 20 second warning.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object chkShowAppName: TCheckBox
    Left = 96
    Top = 242
    Width = 529
    Height = 34
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Caption = 'Show Application Name in Warning Message'
    TabOrder = 0
    OnClick = chkShowAppNameClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 445
    Width = 717
    Height = 38
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Panels = <>
    SimplePanel = True
  end
  object chkUseCustomWarningMessage: TCheckBox
    Left = 96
    Top = 304
    Width = 513
    Height = 34
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Caption = 'Use Custom Warning Event Handler'
    TabOrder = 2
    OnClick = chkUseCustomWarningMessageClick
  end
  object CloseApplication1: TCloseApplication
    MinutesAppAllowedToBeIdle = 1
    SecondsPromptedOnShutdown = 20
    TimerInterval = 0
    OnResume = CloseApplication1Resume
    Left = 184
    Top = 344
  end
  object tmrStatusMessage: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = tmrStatusMessageTimer
    Left = 512
    Top = 336
  end
end

object frmTextViewer: TfrmTextViewer
  Left = 258
  Top = 281
  Width = 438
  Height = 430
  Caption = 'Text Viewer'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  PixelsPerInch = 96
  TextHeight = 13
  object mmoText: TRzMemo
    Left = 0
    Top = 0
    Width = 430
    Height = 367
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    PopupMenu = mnuTextViewer
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    FrameStyle = fsStatus
  end
  object RzDialogButtons: TRzDialogButtons
    Left = 0
    Top = 367
    Width = 430
    ActionOk = actDone
    CaptionOk = '&Done'
    CaptionCancel = 'Cancel'
    CaptionHelp = '&Help'
    ShowCancelButton = False
    TabOrder = 1
  end
  object mnuTextViewer: TPopupMenu
    Left = 80
    Top = 96
    object itmTextEditCopy: TMenuItem
      Action = actEditCopy
    end
    object itmTextEditSelectAll: TMenuItem
      Action = actEditSelectAll
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object itmTextSizeLarger: TMenuItem
      Action = actTextSizeLarger
    end
    object itmTextSizeSmaller: TMenuItem
      Action = actTextSizeSmaller
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object itmTextViewerDone: TMenuItem
      Action = actDone
    end
  end
  object lstTextViewerActions: TActionList
    Left = 72
    Top = 184
    object actTextSizeLarger: TAction
      Category = 'TextSize'
      Caption = 'Text Size &Larger'
      ShortCut = 16460
      OnExecute = actTextSizeLargerExecute
    end
    object actTextSizeSmaller: TAction
      Category = 'TextSize'
      Caption = 'Text Size &Smaller'
      ShortCut = 16467
      OnExecute = actTextSizeSmallerExecute
    end
    object actEditCopy: TEditCopy
      Category = 'Edit'
      Caption = '&Copy'
      Hint = 'Copy'
      ImageIndex = 1
      ShortCut = 16451
    end
    object actEditSelectAll: TEditSelectAll
      Category = 'Edit'
      Caption = 'Select &All'
      ShortCut = 16449
    end
    object actDone: TAction
      Caption = '&Done'
      ShortCut = 27
      OnExecute = actDoneExecute
    end
  end
end

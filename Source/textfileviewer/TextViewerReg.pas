unit TextViewerReg;

interface

{$I cc.inc}

uses
  {$IFDEF	Delphi5}
  Dsgnintf;
  {$ELSE}
    {$IFDEF Delphi6AndUp}
    DesignEditors, DesignIntf;
    {$ENDIF}
  {$ENDIF}


type
  TTextViewerEditor = class(TComponentEditor)
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

procedure Register;


implementation

uses
  Classes, Windows,
  ufrmTextViewer;

procedure Register;
begin
  RegisterComponentEditor(TccTextViewer, TTextViewerEditor);
  RegisterComponents('cc', [TccTextViewer]);
end;

{ TTextViewerEditor }

procedure TTextViewerEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: MessageBox(0, 'TccTextViewer vr. 1.2'#13#10 +
                     'Copyright (c) 2015 by Cornelius concepts.',
                     PChar('About this component ...'),
                     MB_OK + MB_ICONINFORMATION);
    1: MessageBox(0, 'TccTextViewer is, as the name implies, a simple text file viewer. With ' +
                     'it, you can simply set the FileName property and call Execute, or ' +
                     'do it all in one step by calling Execute(Filename) to pop up a simple ' +
                     'viewer for text files.  It is called in a modal fashion and it must be ' +
                     'closed before the application can continue.  The text in the scrollable ' +
                     'viewed region can be selected and copied to the clipboard.  The font size ' +
                     'can be increased or decreased by pressing Ctrl+L (larger) or Ctrl+S (smaller), ' +
                     'respectively.  A pop-up menu is also available for these commands by ' +
                     'right-clicking with the mouse anywhere in the text viewer part of the window.',
                     PChar('Component Help...'),
                     MB_OK + MB_ICONINFORMATION);
  end;
end;

function TTextViewerEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := '&Version and Copyright info...';
    1: Result := 'Component Help...';
  end;
end;

function TTextViewerEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;

end.

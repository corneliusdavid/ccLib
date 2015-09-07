unit EDBTableLookupReg;

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
  TEDBTableLookupEditor = class(TComponentEditor)
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

procedure RegisterEDBTableLookup;


implementation

uses
  SysUtils, Classes, Windows, Graphics, ToolsAPI,
  ufrmEDBTableLookup;

procedure RegisterEDBTableLookup;
begin
  RegisterComponentEditor(TccEDBLookup, TEDBTableLookupEditor);
  RegisterComponents('Cornelius Concepts', [TccEDBLookup]);
end;

{ TTextViewerEditor }

procedure TEDBTableLookupEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: MessageBox(0, 'TccEDBLookup vr. 1.0'#13#10 +
                     'Copyright 2007 by Cornelius Concepts, Inc.',
                     PChar('About this component ...'),
                     MB_OK + MB_ICONINFORMATION);
    1: MessageBox(0, 'TEDBTableLookup is a component that provides a form filled with records from the'#13#10 +
                     'supplied LookupTable property and waits for the user to select one.  When the user'#13#10 +
                     'presses OK, the result of the Execute function is True, otherwise it is False.  There'#13#10 +
                     'are three optional "user" buttons, Button 1, 2, and 3, each of which can be made'#13#10 +
                     'visible or invisible, have a custom caption, and be assigned an OnClick event.'#13#10 +
                     'The end result is a lookup dialog box similar to the one from Woll2Woll''s InfoPower,'#13#10 +
                     'but uses Raize Components instead and is built for use with ElevateDB.',
                     PChar('Component Help...'),
                     MB_OK + MB_ICONINFORMATION);
  end;
end;

function TEDBTableLookupEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := '&Version and Copyright info...';
    1: Result := 'Component Help...';
  end;
end;

function TEDBTableLookupEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;

end.

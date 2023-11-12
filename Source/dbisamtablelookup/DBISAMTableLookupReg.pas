unit DBISAMTableLookupReg;

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
  TDBISAMTableLookupEditor = class(TComponentEditor)
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

procedure Register;


implementation

uses
  Classes, Windows,
  ufrmDBISAMTableLookup;

procedure Register;
begin
  RegisterComponentEditor(TccDBISAMLookup, TDBISAMTableLookupEditor);
  RegisterComponents('cc', [TccDBISAMLookup]);
end;

{ TTextViewerEditor }

procedure TDBISAMTableLookupEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: MessageBox(0, 'TccDBISAMLookup vr. 1.1'#13#10 +
                     'Copyright 2007 by Cornelius Concepts, Inc.',
                     PChar('About this component ...'),
                     MB_OK + MB_ICONINFORMATION);
    1: MessageBox(0, 'TDBISAMTableLookup is a component that provides a form filled with records from the'#13#10 +
                     'supplied LookupTable property and waits for the user to select one.  When the user'#13#10 +
                     'presses OK, the result of the Execut function is True, otherwise it is False.  There'#13#10 +
                     'are four optional "user" buttons, Button 1, 2, 3, and 4 each of which can be made'#13#10 +
                     'visible or invisible, have a custom caption, and be assigned an OnClick event.'#13#10 +
                     'The end result is a lookup dialog box similar to the one from Woll2Woll''s InfoPower,'#13#10 +
                     'but uses Raize Components, looks classier, has more buttons, and uses DBISAM.',
                     PChar('Component Help...'),
                     MB_OK + MB_ICONINFORMATION);
  end;
end;

function TDBISAMTableLookupEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := '&Version and Copyright info...';
    1: Result := 'Component Help...';
  end;
end;

function TDBISAMTableLookupEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;

end.

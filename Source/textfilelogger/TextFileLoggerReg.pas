unit TextFileLoggerReg;
(*
 * as: TextFileLoggerReg
 * by: David Cornelius
 * to: register the TextFileLogger component
 *)

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
  TTextFileLoggerEditor = class(TComponentEditor)
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

procedure RegisterTextFileLogger;


implementation

uses
  Classes, Windows, TextFileLogger;

procedure RegisterTextFileLogger;
begin
  RegisterComponentEditor(TccTextFileLogger, TTextFileLoggerEditor);
  RegisterComponents('cc', [TccTextFileLogger]);
end;

{ TTextFileLoggerEditor }

procedure TTextFileLoggerEditor.ExecuteVerb(Index: Integer);
const
  CR = #13;
  LF = #10;
begin
  case Index of
    0: MessageBox(0, 'TccTextFileLogger vr. 1.1' + CR + LF +
                     'Copyright (c) 2001-2015 by Cornelius Concepts.',
                     PChar('About this component ...'),
                     MB_OK + MB_ICONINFORMATION);
    1: MessageBox(0, 'TccTextfileLogger provides quick and easy logging to a text file. ' +
                     'In fact, all you have to do is drop the component on a form and call ' +
                     'its LOG method passing in a string message.  By default, a file in the ' +
                     'same directory as the running application and with the same name but ' +
                     'with a .LOG extension is used for logging the messages.  The following ' +
                     'is a list of the properties and their purpose:' + CR + LF +
                     LF +
                     'FileName: The name of the file where the log messages are stored; if ' +
                     'left blank and UseDefaultFilename is True, it will be set to the same ' +
                     'name as the application and in the same directory, but with a .LOG extension.' + CR + LF +
                     LF +
                     'KeepOpen: If True, the log file is kept open between log writes. You might ' +
                     'want to set this False if the file system is unreliable or there are few log ' +
                     'messages with long delays between writes.' + CR + LF +
                     LF +
                     'Overwrite: If True, the log file will be erased and recreated the first time ' +
                     'it is written to.' + CR + LF +
                     LF +
                     'UseDefaultFileName: If True and the FileName property is blank, the FileName ' +
                     'will be set to the same name as the application and in the same directory, but ' +
                     'with a .LOG extension.' + CR + LF +
                     LF +
                     'WriteHeader: If True, the current date and time will be written out between ' +
                     'a set of dashes the first time the log file is written to.',
                     PChar('Component Help...'),
                     MB_OK + MB_ICONINFORMATION);
  end;
end;

function TTextFileLoggerEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := '&Version and Copyright info...';
    1: Result := 'Component Help...';
  end;
end;

function TTextFileLoggerEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;

end.

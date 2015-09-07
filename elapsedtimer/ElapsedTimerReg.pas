unit ElapsedTimerReg;
(*
 * as: ElapsedTimerReg
 * by: David Cornelius
 * to: register the ElapsedTimer component
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
  TElapsedTimerEditor = class(TComponentEditor)
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

procedure RegisterElapsedTimer;


implementation

uses
  SysUtils, Classes, Windows, Graphics, ToolsAPI,
  {$IFDEF UseCodeSite} CodeSiteLogging, {$ENDIF}
  ElapsedTimer;

procedure RegisterElapsedTimer;
begin
  RegisterComponentEditor(TccElapsedTimer, TElapsedTimerEditor);
  RegisterComponents('Cornelius Concepts', [TccElapsedTimer]);
end;

{ TElapsedTimerEditor }

procedure TElapsedTimerEditor.ExecuteVerb(Index: Integer);
const
  TAB = #9;
  CR = #13;
  LF = #10;
begin
  case Index of
    0: MessageBox(0, 'TElapsedTimer vr. 1.0' + CR + LF +
                     'Freeware by Cornelius Concepts.',
                     PChar('About this component ...'),
                     MB_OK + MB_ICONINFORMATION);
    1: MessageBox(0, 'TElapsedTimer makes it easy to time things and get the elapsed time in whatever precision you want. ' +
                     'Simply call the Start method, do your timed process, then call Stop and get the elapsed time ' + CR + LF +
                     TAB + 'in DateTime format with ElapsedTime,' + CR + LF +
                     TAB + 'in seconds with ElapsedSeconds,' + CR + LF +
                     TAB + 'in minutes with ElapsedMinutes,' + CR + LF +
                     TAB + 'in hours with ElapsedHours,' + CR + LF +
                     TAB + 'in days with ElapsedDays,' + CR + LF +
                     TAB + 'in months with ElapsedMonths, or ' + CR + LF +
                     TAB + 'in years with ElapsedYears.'  + CR + LF +
                     'These seconds through years results are floating point values (Double).',
                     PChar('Component Help ...'),
                     MB_OK + MB_ICONINFORMATION);
  end;
end;

function TElapsedTimerEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := '&Version Info...';
    1: Result := 'Component Help...';
  end;
end;

function TElapsedTimerEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;

end.

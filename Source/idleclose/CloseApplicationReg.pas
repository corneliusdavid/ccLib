unit CloseApplicationReg;
(*
 * as: ElapsedTimerReg
 * by: Neil <someone on DBISAM newsgroups>
 * to: register as a component, a class that Neil wrote
 *)

interface

{$I ..\..\source\cc.inc}

uses
  {$IFDEF	Delphi5}
  Dsgnintf;
  {$ELSE}
    {$IFDEF Delphi6AndUp}
    DesignEditors, DesignIntf;
    {$ENDIF}
  {$ENDIF}

type
  TCloseAppComponent = class(TComponentEditor)
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

procedure RegisterCloseApp;


implementation

uses
  SysUtils, Classes, Windows, Graphics, ToolsAPI,
  CloseApplication;

procedure RegisterCloseApp;
begin
  RegisterComponentEditor(TCloseApplication, TCloseAppComponent);
  RegisterComponents('Cornelius Concepts', [TCloseApplication]);
end;

{ TCloseAppComponent }

procedure TCloseAppComponent.ExecuteVerb(Index: Integer);
const
  TAB = #9;
  CR = #13;
  LF = #10;
begin
  case Index of
    0: MessageBox(0, 'Written by someone named Neil on the DBISAM newsgroups several years ago, ' +
                     'this nifty component automatically closes an application after a specified ' +
                     'amount of time without any keyboard or mouse activitiy.  Cornelius Concepts ' +
                     'turned this into a component.',
                     PChar('Component Help ...'),
                     MB_OK + MB_ICONINFORMATION);
  end;
end;

function TCloseAppComponent.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Component Help...';
  end;
end;

function TCloseAppComponent.GetVerbCount: Integer;
begin
  Result := 1;
end;

end.

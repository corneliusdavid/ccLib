unit CloseApplicationReg;
(*
 * as: ElapsedTimerReg
 * by: Neil <someone on DBISAM newsgroups>
 * to: register as a component, a class that Neil wrote
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

resourcestring
  ComponentPkgName = 'Cornelius Concepts - Auto Close Application';
  ComponentPkgLic  = 'Freeware by Cornelius Concepts';
  ComponentPkgDesc = 'A component to automatically close an application after a specified time of no activity';

var
  AboutBoxServices : IOTAAboutBoxServices = nil;
  AboutBoxIndex : Integer = 0;

procedure RegisterSplashScreen;
var
  Bmp: TBitmap;
begin
  Bmp := TBitmap.Create;
  try
    Bmp.LoadFromResourceName( HInstance, 'CCLIB');
    {$IFDEF VERSION2005orHigher}
    SplashScreenServices.AddPluginBitmap(ComponentPkgName, Bmp.Handle, False,
                                         ComponentPkgLic,
                                         ComponentPkgDesc);
    SplashScreenServices.StatusMessage('Loaded ' + ComponentPkgName);
    {$ENDIF}
  finally
    Bmp.Free;
  end;
end;

procedure RegisterAboutBox;
begin
  {$IFDEF VERSION2005orHigher}
  if Supports(BorlandIDEServices,IOTAAboutBoxServices, AboutBoxServices) then
    AboutBoxIndex := AboutBoxServices.AddPluginInfo(ComponentPkgName,
                                                    ComponentPkgDesc,
                                                    LoadBitmap(HInstance, 'CCLIB'),
                                                    False,
                                                    ComponentPkgLic);
  {$ENDIF}
end;

procedure RegisterCloseApp;
begin
  RegisterSplashScreen;
  RegisterAboutBox;
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

procedure UnregisterAboutBox;
begin
  {$IFDEF VERSION2005orHigher}
  if (AboutBoxIndex <> 0) and Assigned(AboutBoxServices) then begin
    AboutBoxServices.RemovePluginInfo(AboutBoxIndex);
    AboutBoxIndex := 0;
    AboutBoxServices := nil;
  end;
  {$ENDIF}
end;

initialization
finalization
  UnregisterAboutBox;
end.

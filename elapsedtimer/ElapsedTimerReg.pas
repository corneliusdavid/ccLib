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

resourcestring
  ComponentPkgName = 'Elapsed Timer';
  ComponentPkgLic  = 'Freeware';
  ComponentPkgDesc = 'A convenient stopwatch component';

var
  AboutBoxServices : IOTAAboutBoxServices = nil;
  AboutBoxIndex : Integer = 0;

procedure RegisterSplashScreen;
var
  Bmp: TBitmap;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod('RegisterSplashScreen');{$ENDIF}

  Bmp := TBitmap.Create;
  try
    Bmp.LoadFromResourceName( HInstance, 'CCLIB');
    {$IFDEF VERSION2005or Higher}
    ForceDemandLoadState(dlDisable);
    SplashScreenServices.AddPluginBitmap(ComponentPkgName, Bmp.Handle, False,
                                         ComponentPkgLic,
                                         ComponentPkgDesc);
    SplashScreenServices.StatusMessage('Loaded ' + ComponentPkgName + ' from Cornelius Concepts');
    {$ENDIF}
  finally
    Bmp.Free;
  end;

  {$IFDEF UseCodeSite}CodeSite.ExitMethod('RegisterSplashScreen');{$ENDIF}
end;

procedure RegisterAboutBox;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod('RegisterAboutBox');{$ENDIF}

  {$IFDEF VERSION2005orHigher}
  Supports(BorlandIDEServices,IOTAAboutBoxServices, AboutBoxServices);
  AboutBoxIndex := AboutBoxServices.AddPluginInfo(ComponentPkgName,
                                                  ComponentPkgDesc,
                                                  LoadBitmap(HInstance, 'CCLIB'),
                                                  False,
                                                  ComponentPkgLic);
  {$ENDIF}

  {$IFDEF UseCodeSite}CodeSite.ExitMethod('RegisterAboutBox');{$ENDIF}
end;

procedure RegisterElapsedTimer;
begin
  RegisterSplashScreen;
  RegisterAboutBox;
  RegisterComponentEditor(TccElapsedTimer, TElapsedTimerEditor);
  RegisterComponents('cc', [TccElapsedTimer]);
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
                     'Copyright (c) 2001-2002 by Cornelius Concepts.',
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
    0: Result := '&Version and Copyright info...';
    1: Result := 'Component Help...';
  end;
end;

function TElapsedTimerEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;

procedure UnregisterAboutBox;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod('UnregisterAboutBox');{$ENDIF}

  {$IFDEF VERSION2005orHigher}
  if (AboutBoxIndex <> 0) and Assigned(AboutBoxServices) then begin
    AboutBoxServices.RemovePluginInfo(AboutBoxIndex);
    AboutBoxIndex := 0;
    AboutBoxServices := nil;
  end;
  {$ENDIF}

  {$IFDEF UseCodeSite}CodeSite.ExitMethod('UnregisterAboutBox');{$ENDIF}
end;

initialization
finalization
  UnregisterAboutBox;
end.

unit cc_reg;

interface

procedure Register;

implementation

{$I ..\..\source\cc.inc}

uses
  SysUtils, Windows, Graphics, ToolsAPI,
  {$IFDEF	Delphi5}
  Dsgnintf,
  {$ELSE}
    {$IFDEF Delphi6AndUp}
    DesignEditors, DesignIntf,
    {$ENDIF}
  {$ENDIF}
  CloseApplicationReg, {$IFNDEF 103RioOrHigher} ElapsedTimerReg, {$ENDIF} LayoutSaverReg;

{$R cc.res}

resourcestring
  ComponentPkgName = 'Cornelius Concepts Components';
  ComponentPkgLic  = 'OpenSource by Cornelius Concepts';
  ComponentPkgDesc = {$IFNDEF 103RioOrHigher}
                     'TccElapsedTimer - simple stopwatch;' + #13#10 +
                     {$ENDIF}
                     'TCloseApplication - auto close an application with no activity;' + #13#10 +
                     'TccIniLayoutSaver/TccRegistryLayoutSaver - save/restore form size/position.';

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
                                         ComponentPkgLic);
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

procedure Register;
begin
  RegisterSplashScreen;
  RegisterAboutBox;

  RegisterCloseApp;
  {$IFNDEF 103RioOrHigher}
  RegisterElapsedTimer;
  {$ENDIF}
  RegisterLayoutSaver;

  ForceDemandLoadState(dlDisable);
end;

initialization
finalization
  UnregisterAboutBox;
end.


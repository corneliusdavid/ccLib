unit ccRegCommon;

interface

procedure RegisterAboutBox;
procedure UnregisterAboutBox;


implementation

{$I cc.inc}

uses
  SysUtils, Windows, Vcl.Graphics,
  {$IFDEF	Delphi5}
  Dsgnintf,
  {$ELSE}
    {$IFDEF Delphi6AndUp}
    DesignEditors, DesignIntf,
    {$ENDIF}
  {$ENDIF}
  ToolsAPI;

resourcestring
  ComponentPkgName = 'Cornelius Concepts Components';
  ComponentPkgLic  = 'OpenSource by Cornelius Concepts';
  ComponentPkgDesc = 'TccIniLayoutSaver/TccRegistryLayoutSaver - save/restore form size/position.';

var
  AboutBoxServices : IOTAAboutBoxServices = nil;
  AboutBoxIndex : Integer = 0;

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

initialization
finalization
  UnregisterAboutBox;
end.


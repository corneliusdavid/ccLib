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
  {$IFDEF UseCodeSite} CodeSiteLogging, {$ENDIF}
  ufrmEDBTableLookup;

resourcestring
  ComponentPkgName = 'EDB Table Lookup';
  ComponentPkgLic  = 'Freeware';
  ComponentPkgDesc = 'A flexible lookup dialog for ElevateDB Tables';

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

procedure RegisterEDBTableLookup;
begin
  RegisterSplashScreen;
  RegisterAboutBox;
  RegisterComponentEditor(TccEDBLookup, TEDBTableLookupEditor);
  RegisterComponents('cc', [TccEDBLookup]);
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

unit cc_splash;

interface

procedure Register;

implementation

uses
  SysUtils, Windows, Graphics, ToolsAPI, DesignIntf,
  {$IFDEF UseCodeSite} CodeSiteLogging, {$ENDIF}
  CloseApplicationReg, ElapsedTimerReg,
  LayoutSaverReg;

{$R cc.res}

procedure Register;
begin
  RegisterCloseApp;
  RegisterElapsedTimer;
  RegisterLayoutSaver;
end;

end.


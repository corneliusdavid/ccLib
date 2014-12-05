unit cc_splash;

interface

procedure Register;

implementation

uses
  SysUtils, Windows, Graphics, ToolsAPI, DesignIntf,
  {$IFDEF UseCodeSite} CodeSiteLogging, {$ENDIF}
  EDBTableLookupReg, CloseApplicationReg, ElapsedTimerReg,
  LayoutSaverReg, MergeTxtReg, TextFileLoggerReg;

{$R cc.res}

procedure Register;
begin
  RegisterEDBTableLookup;
  RegisterCloseApp;
  RegisterElapsedTimer;
  RegisterLayoutSaver;
  RegisterMergeText;
  RegisterTextFileLogger;
end;

end.


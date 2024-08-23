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

procedure RegisterCloseApp;
begin
  RegisterComponentEditor(TCloseApplication, TCloseAppComponent);
  RegisterComponents('Cornelius Concepts', [TCloseApplication]);
end;

{ TCloseAppComponent }

procedure TCloseAppComponent.ExecuteVerb(Index: Integer);
const
  {$IFDEF VER130}
  sLineBreak = #13#10;
  {$ENDIF}
begin
  case Index of
    0: MessageBox(0, 'This nifty component automatically closes an application after a specified amount of time without ' +
                     'any keyboard or mouse activitiy. The original library code was written by someone named Neil on the ' +
                     'DBISAM newsgroups several years ago. The library was turned into a component by Cornelius Concepts. ',
                     PChar('About TCloseApplication'),
                     MB_OK + MB_ICONINFORMATION);
    1: MessageBox(0, 'MinutesAppAllowedToBeIdle: This Integer number is how many minutes without any keyboard or mouse ' +
                     'activity before the shut-down warning appears.' +
                     sLineBreak + sLineBreak +
                     'PreventCancelEditInserts: This Boolean value, if True, prevents the component from shutting ' +
                     'the program down if there are pending edits or inserts of TDataSet components (TTable or TQuery or ' +
                     'any TDataSet descendants) found on any of the application''s Forms or DataModules.' +
                     sLineBreak + sLineBreak +
                     'SecondsPromptedOnShutdown: This Integer number is how many seconds to show a prompt to the user ' +
                     'that the application will close down before it actually closes. This gives the user a chance to ' +
                     'stop the shut-down and continue using the program.' +
                     sLineBreak + sLineBreak +
                     'ShowAppName: This Boolean value determines how the message shown in the standard shut-down warning ' +
                     'message refers to the program being shut-down; if False, it says, "This application..."; if True, ' +
                     'it uses the main form''s Caption as the application name.' +
                     sLineBreak + sLineBreak +
                     'TimerInterval: This Integer value allows you to change the number of milliseconds elapsed between ' +
                     '"minute" intervals in the component. If this value is left at 0 (the default), then 60,000 is used ' +
                     'internally by this component (1,000 milliseconds * 60 seconds). The TimerInterval is multiplied by ' +
                     'the MinutesAllowedToBeIdle property to determine the actual idle time. In other words, changing ' +
                     'this property allows you to have shorter or longer "minute" intervals. It is recommended to leave ' +
                     'this at zero unless you are testing.',
                     PChar('TCloseApplication Properties'),
                     MB_OK + MB_ICONINFORMATION);
    2: MessageBox(0, 'OnAppTermination: This event handler allows you to add custom code that is executed when this ' +
                     'component is ready to shut down the application. This could be code that you would not normally ' +
                     'need to call if the application was shutting down normally. Note: there is no way to prevent ' +
                     'the component from trying to halt the program; to do that, use the OnWarning event.' +
                     sLineBreak + sLineBreak +
                     'OnResume: This event can be used to write to a log or set a status that the timed shut-down was canceled.' +
                     sLineBreak + sLineBreak +
                     'OnWarning: If this event handler is not used, a form is shown to the user that the application will ' +
                     'be shut down if the user does not stop it. The form shows the number of seconds remaining and has a ' +
                     'button to cancel the shut-down. To override this functionality with your own warning window or ' +
                     'status message, use this event handler. Two parameters are passed: 1) CloseTime, an Integer for ' +
                     'the number of seconds remaining until shut-down; and 2) ShouldShowAppName, a Boolean indicating ' +
                     'whether to use the main form''s caption (True) or not.',
                     PChar('TCloseApplication Events'),
                     MB_OK + MB_ICONINFORMATION);
  end;
end;

function TCloseAppComponent.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'About this Component...';
    1: Result := 'Properties Help...';
    2: Result := 'Events Help...';
  end;
end;

function TCloseAppComponent.GetVerbCount: Integer;
begin
  Result := 1;
end;         

{$IFDEF VER130}
// for Delphi 5, register ONLY the TCloseApplication component
initialization
  RegisterCloseApp;
{$ENDIF}
end.

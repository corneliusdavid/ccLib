unit CloseApplication;

interface

{$I ..\..\source\cc.inc}

uses
  {$IFDEF XE2orHIGHER}
  System.SysUtils, System.Classes, VCL.Graphics, VCL.Controls, VCL.Forms, VCL.Dialogs,
  Winapi.Windows, Winapi.Messages, Data.DB,
  VCL.ExtCtrls, VCL.StdCtrls, AppIdleWarn;
  {$ELSE}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, DB, StdCtrls, AppIdleWarn;
  {$ENDIF}


type
  TOnApplicationMsg = procedure(var Msg: TMsg; var Handled: Boolean) of object;
  TAppIdleWarnFunc = function(CloseTime: Integer; const ShouldShowAppName: Boolean = False): Integer of object;

  [ComponentPlatforms(pidWin32 or pidWin64)]
  TCloseApplication = class(TComponent)
    procedure IdleTimerTimer(Sender: TObject);
  private
    FCountDownScreenDisplayed: Boolean; // Var To Prevent Proc CloseAppBecauseIdleTimeExceeded From Being Called Recursively
    FMinutesAppAllowedToBeIdle: Integer; // Number of Minutes App Allowed To Be Idle
    FSecondsPromptedOnShutdown: Integer; // Number of Seconds Prevent Shutdown Screen Is Displayed Before App Shutdown Occurs
    FTimerInterval: Integer; // Interval Of IdleTimer (Should Be 60000 to simulate 1 minute)
    FOnAppTermination: TNotifyEvent; // Pointer To App Termination Event (if Defined)

    FPreventCancelEditInserts: Boolean; // Flag To Prevent Cancellation of Edits & Inserts On Shutdown
    IdleTimer: TTimer;
    FShowAppName: Boolean;
    FOnWarning: TAppIdleWarnFunc;
    FOnResume: TNotifyEvent;

    procedure CloseAppBecauseIdleTimeExceeded;
    procedure CancelEditsInsertsInDatamodules;
    procedure CancelEditsInsertsInOpenForms;

    procedure SetMinutesAppAllowedToBeIdle(Minutes: Integer);
    procedure SetSecondsPromptedOnShutdown(Seconds: Integer);
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property MinutesAppAllowedToBeIdle: Integer read FMinutesAppAllowedToBeIdle write SetMinutesAppAllowedToBeIdle default 60;
    property PreventCancelEditInserts: Boolean read FPreventCancelEditInserts write FPreventCancelEditInserts default False;
    property SecondsPromptedOnShutdown: Integer read FSecondsPromptedOnShutdown write SetSecondsPromptedOnShutdown default 90;
    property ShowAppName: Boolean read FShowAppName write FShowAppName default False;
    property TimerInterval: Integer read FTimerInterval write FTimerInterval default 60000;
    property OnAppTermination: TNotifyEvent read FOnAppTermination write FOnAppTermination;
    property OnWarning: TAppIdleWarnFunc read FOnWarning write FOnWarning;
    property OnResume: TNotifyEvent read FOnResume write FOnResume;
  end;

// Windows Hook Procedures To Intercept Keyboard & Mouse Input
function TrapKeyboardInput(nCode: Integer; wp: wParam; lp: lParam): LResult; stdcall;
function TrapMouseInput(nCode: Integer; wp: wParam; lp: lParam): LResult; stdcall;


implementation

var
  KeyboardHook, MouseHook: hHook;
  MinutesAppHasBeenIdle: Integer; // Unit Variable To Determine How Long App Has Been Idle


destructor TCloseApplication.Destroy;
begin
  if (not (csDesigning in ComponentState)) then begin
      // Release Windows Hooks
    {$IFDEF XE2orHIGHER}
    UnhookWindowsHookEx(MouseHook);
    UnHookWindowsHookEx(KeyboardHook);
    {$ELSE}
    Windows.UnhookWindowsHookEx(MouseHook);
    Windows.UnHookWindowsHookEx(KeyboardHook);
    {$ENDIF}
      // Free Timer
    IdleTimer.Free;
  end;
  inherited Destroy;
end;

constructor TCloseApplication.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  if (not (csDesigning in ComponentState)) then begin // Only Allocate Resources If App Is Run
    //Set Flag To Ensure Terminate Window Not Called Recursively
    FCountDownScreenDisplayed := False;
    FShowAppName := False;

    // Set WindowsHook Procedures
    MouseHook := SetWindowsHookEx(WH_MOUSE, TrapMouseInput, 0, GetCurrentThreadID);
    KeyboardHook := SetWindowsHookEx(WH_KEYBOARD, TrapKeyboardInput, 0, GetCurrentThreadID);

    // Create system timer & Set Properties
    IdleTimer := TTimer.Create(Self);
    IdleTimer.Enabled := False;
    IdleTimer.OnTimer := IdleTimerTimer;
    IdleTimer.Enabled := True;
    // Assign Variables Used To Track Idle Time
    MinutesAppHasBeenIdle := 0;
  end;
end;

procedure TCloseApplication.Loaded;
// Proc To Load Properties After Component Creation And After Component properties have been streamed in
begin
  inherited Loaded;

  if (not (csDesigning in ComponentState)) then begin
    if FTimerInterval <> 0 then
      IdleTimer.Interval := FTimerInterval
    else
      IdleTimer.Interval := 60000; // One Minute Interval
    if FMinutesAppAllowedToBeIdle < 1 then
      FMinutesAppAllowedToBeIdle := 60;
  end;
end;

function TrapKeyboardInput(nCode: Integer; wp: wParam; lp: lParam): LResult; stdcall;
// Windows Hook Procedure To Intercept Keyboard Input
begin
  // This Structure is Defined By The Windows API
  if nCode < 0 then
    Result := CallNextHookEx(KeyBoardHook, nCode, wp, lp)
  else begin
    if nCode = HC_ACTION then begin
      // All Keyoard Activity Gets Here
      MinutesAppHasBeenIdle := 0;
      Result := 0;
    end
    else
      Result := 0;
  end;
end;

function TrapMouseInput(nCode: Integer; wp: wParam; lp: lParam): LResult; stdcall;
// Windows Hook Procedure To Intercept Mouse Input
begin
  // This Structure is Defined By The Windows API
  if nCode < 0 then
    Result := CallNextHookEx(MouseHook, nCode, wp, lp)
  else begin
    if nCode = HC_ACTION then begin
      // Must Test For Specific Mouse Input Here
      case wp of
        WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_MBUTTONDOWN: MinutesAppHasBeenIdle := 0; // 0 Counter For App Idle Time
        WM_LBUTTONDBLCLK, WM_RBUTTONDBLCLK, WM_MBUTTONDBLCLK: MinutesAppHasBeenIdle := 0; // 0 Counter For App Idle Time
      end;
      Result := 0;
    end else
      result := 0;
  end;
end;

procedure TCloseApplication.IdleTimerTimer(Sender: TObject);
begin
  // Increment App Idle Timer Every 60 Seconds
  MinutesAppHasBeenIdle := MinutesAppHasBeenIdle + 1;
  if (MinutesAppHasBeenIdle >= FMinutesAppAllowedToBeIdle) and
    (FCountDownScreenDisplayed <> True) then // Test For Recursive Calling of CloseAppBecauseIdleTimeExceeded
    CloseAppBecauseIdleTimeExceeded; // TimeOut Detected
end;

procedure TCloseApplication.CloseAppBecauseIdleTimeExceeded;
// Application Has Been Idle For Too Long
var
  ShouldClose: Boolean;
begin
  // Set Flag To Ensure Proc Is Not Called Recursively By Timer Event
  FCountDownScreenDisplayed := True;

  // Prompt User With About To Close Warning
  // TfmAppIdleWarn.OpenfmAppIdleWarn Opens The User Prompt To Keep The Application Open
  if Assigned(FOnWarning) then
    ShouldClose := FOnWarning(FSecondsPromptedOnShutdown, FShowAppName) = 0
  else
    ShouldClose := TfmAppIdleWarn.OpenfmAppIdleWarn(FSecondsPromptedOnShutdown, FShowAppName) = 0;

  if ShouldClose then begin
    // No Response From User - Close App

    // Call AppOnTerminate Event If Defined
    if Assigned(FOnAppTermination) then
      FOnAppTermination(Self);

    // Cancel All DataSet Edits/Inserts Unless Prevent=True
    if FPreventCancelEditInserts <> True then begin // Cancel All Pending Edits/Inserts In Tables
      CancelEditsInsertsInDatamodules;
      CancelEditsInsertsInOpenForms;
    end;
    Application.Terminate;
  end else begin
    // User Elected To Keep App Open
    MinutesAppHasBeenIdle := 0;

    // notify caller
    if Assigned(FOnResume) then
      FOnResume(self);
  end;

  FCountDownScreenDisplayed := False;
end;

procedure TCloseApplication.CancelEditsInsertsInDatamodules;
var
  I, J: Integer;
  TheDMod: TDatamodule;
  TheDataSet: TDataSet;
begin
  // Procedure To Loop Through All Table Elements of Datamodule
  // Any Table In Edit/Insert Mode Will Have Edit/Insert Cancelled
  for I := 0 to Screen.DataModuleCount - 1 do begin
    TheDMod := TDatamodule(Screen.DataModules[I]);
    for J := 0 to TheDMod.ComponentCount - 1 do
      if TheDMod.Components[J] is TDataSet then begin
        TheDataSet := TDataSet(TheDMod.Components[J]);
        if TheDataSet.State in [DsEdit, DsInsert] then
          TheDataSet.Cancel;
      end;
  end;
end;

procedure TCloseApplication.CancelEditsInsertsInOpenForms;
var
  TheForm: TForm;
  TheDataSet: TDataset;
  I, J: Integer;
begin
  // Procedure To Loop Through All Table Elements of Every Form In App
  // Any Table In Edit/Insert Mode Will Have Edit/Insert Cancelled
  for I := 0 to Screen.FormCount - 1 do begin
    TheForm := Screen.Forms[I];
    for J := 0 to TheForm.ComponentCount - 1 do
      if TheForm.Components[J] is TDataset then begin
        TheDataSet := TDataSet(TheForm.Components[J]);
        if TheDataSet.State in [DsEdit, DsInsert] then
          TheDataSet.Cancel;
      end;
  end;
end;

procedure TCloseApplication.SetMinutesAppAllowedToBeIdle(Minutes: Integer);
begin
  if FMinutesAppAllowedToBeIdle <> Minutes then begin
    if (Minutes > 0) then
      FMinutesAppAllowedToBeIdle := Minutes
    else
      Showmessage('Minutes must not be zero.');
  end;
end;

procedure TCloseApplication.SetSecondsPromptedOnShutdown(Seconds: Integer);
begin
  if FSecondsPromptedOnShutdown <> Seconds then begin
    if (Seconds > 1) and (Seconds <= 1000) then
      FSecondsPromptedOnShutdown := Seconds
    else
      Showmessage('Seconds Must Be From 1-1000');
  end;
end;

end.


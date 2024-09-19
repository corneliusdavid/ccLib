unit Unit1;

interface

{$I ..\source\cc.inc}

uses
  {$IFDEF XE2orHigher}
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  {$ELSE}
  Forms, Messages, Dialogs, SysUtils, ExtCtrls, ComCtrls, Controls, StdCtrls, Classes,
  {$ENDIF}
  CloseApplication;

type
  TfrmTestAppIdleWarn = class(TForm)
    CloseApplication1: TCloseApplication;
    Label1: TLabel;
    chkShowAppName: TCheckBox;
    StatusBar1: TStatusBar;
    chkUseCustomWarningMessage: TCheckBox;
    procedure CloseApplication1Resume(Sender: TObject);
    function CloseApplication1Warning(CloseTime: Integer; const ShouldShowAppName: Boolean): Integer;
    procedure chkUseCustomWarningMessageClick(Sender: TObject);
    procedure chkShowAppNameClick(Sender: TObject);
  end;

var
  frmTestAppIdleWarn: TfrmTestAppIdleWarn;

implementation

uses
  Dialogs;

{$R *.dfm}


function TfrmTestAppIdleWarn.CloseApplication1Warning(CloseTime: Integer; const ShouldShowAppName: Boolean): Integer;
var
  AppName: string;
begin
  {$IFDEF VER130}
  if ShouldShowAppName then
    AppName := frmTestAppIdleWarn.Caption
  else
    AppName := 'This application';
  {$ELSE}
  AppName := IfThen(ShouldShowAppName, frmTestAppIdleWarn.Caption, 'This application');
  {$ENDIF}

  {$IFDEF VER130}
  if (MessageDlg(AppName + ' will close in ' + IntToStr(CloseTime) + ' seconds. Allow it?', mtConfirmation,
               [mbYes, mbNo], 0) = mrYes) then
  {$ELSE}
  if MessageDlg(AppName + ' will close in ' + IntToStr(CloseTime) + ' seconds. Allow it?', TMsgDlgType.mtConfirmation,
                mbYesNo, 0) = mrYes then
  {$ENDIF}
    Result := 0
  else
    Result := 1;
end;

procedure TfrmTestAppIdleWarn.FormCreate(Sender: TObject);
begin
  Label1.Caption := Format(Label1.Caption, [CloseApplication1.MinutesAppAllowedToBeIdle,
                                            CloseApplication1.SecondsPromptedOnShutdown]);
end;

procedure TfrmTestAppIdleWarn.chkShowAppNameClick(Sender: TObject);
begin
  CloseApplication1.ShowAppName := chkShowAppName.Checked;
end;

procedure TfrmTestAppIdleWarn.chkUseCustomWarningMessageClick(Sender: TObject);
begin
  if chkUseCustomWarningMessage.Checked then
    CloseApplication1.OnWarning := CloseApplication1Warning
  else
    CloseApplication1.OnWarning := nil;
end;

procedure TfrmTestAppIdleWarn.CloseApplication1Resume(Sender: TObject);
begin
  StatusBar1.SimpleText := 'Application close prevented--resuming.';
end;

end.

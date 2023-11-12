unit Unit1;

interface

{$I ..\source\cc.inc}

uses
  {$IFDEF XE2orHigher}
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  {$ELSE}
  Forms, Messages, SysUtils, ExtCtrls, ComCtrls, Controls, StdCtrls, Classes,
  {$ENDIF}
  CloseApplication;

type
  TfrmTestAppIdleWarn = class(TForm)
    CloseApplication1: TCloseApplication;
    Label1: TLabel;
    chkShowAppName: TCheckBox;
    StatusBar1: TStatusBar;
    tmrStatusMessage: TTimer;
    chkUseCustomWarningMessage: TCheckBox;
    procedure CloseApplication1Resume(Sender: TObject);
    function CloseApplication1Warning(CloseTime: Integer; const ShouldShowAppName: Boolean): Integer;
    procedure tmrStatusMessageTimer(Sender: TObject);
    procedure chkUseCustomWarningMessageClick(Sender: TObject);
    procedure chkShowAppNameClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTestAppIdleWarn: TfrmTestAppIdleWarn;

implementation

{$R *.dfm}

uses
  StrUtils;

function TfrmTestAppIdleWarn.CloseApplication1Warning(CloseTime: Integer; const ShouldShowAppName: Boolean): Integer;
var
  AppName: string;
begin
  AppName := IfThen(ShouldShowAppName, frmTestAppIdleWarn.Caption, 'This application');

  if MessageDlg(AppName + ' will close in ' + IntToStr(CloseTime) + ' seconds. Allow it?', TMsgDlgType.mtConfirmation,
                mbYesNo, 0) = mrYes then
    Result := 0
  else
    Result := 1;
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
  tmrStatusMessage.Enabled := True;
end;

procedure TfrmTestAppIdleWarn.tmrStatusMessageTimer(Sender: TObject);
begin
  tmrStatusMessage.Enabled := False;
  StatusBar1.SimpleText := EmptyStr;
end;

end.

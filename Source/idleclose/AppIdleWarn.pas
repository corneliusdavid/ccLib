unit AppIdleWarn;

interface

{$I cc.inc}

uses
  {$IFDEF XE2orHIGHER}
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.IOUtils,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls, VCL.ExtCtrls,
  {$ELSE}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, {$IFNDEF VER130} IOUtils, {$ENDIF}
  StdCtrls, Buttons, ExtCtrls;
  {$ENDIF}

type
  TfmAppIdleWarn = class(TForm)
    BBCancel: TBitBtn;
    TimerClose: TTimer;
    LabSeconds: TLabel;
    procedure BBCancelClick(Sender: TObject);
    procedure TimerCloseTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    {$IFNDEF VER130}
    MyFormatSettings: TFormatSettings;
    {$ENDIF}
    SecondsTillClose: Integer;
    AppName: string;
    procedure UpdateCaption;
  public
    CloseCode: Integer;
    SecondsWarning: Integer;
    ShowAppName: Boolean;
    class function OpenfmAppIdleWarn(CloseTime: Integer; const ShouldShowAppName: Boolean = False): Integer;
  end;

implementation

{$R *.DFM}

class function TfmAppIdleWarn.OpenfmAppIdleWarn(CloseTime: Integer; const ShouldShowAppName: Boolean = False): Integer;
var
  instance: TfmAppIdleWarn;
begin
  instance := TfmAppIdleWarn.Create(nil);
  try
    Instance.SecondsWarning := CloseTime;
    Instance.ShowAppName := ShouldShowAppName;
    instance.Showmodal;
    Result := instance.CloseCode;
  finally
    instance.Free;
  end;
end;


procedure TfmAppIdleWarn.FormShow(Sender: TObject);
begin
  {$IFNDEF VER130}
  MyFormatSettings := TFormatSettings.Create;
  {$ENDIF}

  if ShowAppName then
    AppName := Application.MainForm.Caption
  else
    AppName := 'This Application';

  CloseCode := 0;
  SecondsTillClose := SecondsWarning;
  UpdateCaption;
  TimerClose.Enabled := True;
end;

procedure TfmAppIdleWarn.BBCancelClick(Sender: TObject);
begin
  CloseCode := 1;
  Close;
end;

procedure TfmAppIdleWarn.TimerCloseTimer(Sender: TObject);
begin
  SecondsTillClose := SecondsTillClose - 1;
  UpdateCaption;
  Application.ProcessMessages;
  if SecondsTillClose < 1 then
    Close;
end;

procedure TfmAppIdleWarn.UpdateCaption;
begin
  LabSeconds.Caption := Format('%s will close in %d seconds.', [AppName, SecondsTillClose]
                              {$IFNDEF VER130}, MyFormatSettings{$ENDIF});
end;

end.




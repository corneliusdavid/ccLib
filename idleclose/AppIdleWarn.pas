unit AppIdleWarn;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TfmAppIdleWarn = class(TForm)
    BBCancel: TBitBtn;
    TimerClose: TTimer;
    LabSeconds: TLabel;
    procedure BBCancelClick(Sender: TObject);
    procedure TimerCloseTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    SecondsTillClose: Integer;
  public
    CloseCode: Integer;
    SecondsWarning: Integer;
    class function OpenfmAppIdleWarn(CloseTime: Integer): Integer;
  end;


implementation

{$R *.DFM}

class function TfmAppIdleWarn.OpenfmAppIdleWarn(CloseTime: Integer): Integer;
var
  instance: TfmAppIdleWarn;
begin
  instance := TfmAppIdleWarn.Create(nil);
  try
    Result := 0;
    Instance.SecondsWarning := CloseTime;
    instance.Showmodal;
    Result := instance.CloseCode;
  finally
    instance.Free;
  end;
end;

const
  AppCloseMsg1 = 'Application will close in ';
  AppCloseMsg2 = ' seconds';

procedure TfmAppIdleWarn.FormShow(Sender: TObject);
begin
  CloseCode := 0;
  SecondsTillClose := SecondsWarning;
  LabSeconds.Caption := AppCloseMsg1 + IntToStr(SecondsWarning) + AppCloseMsg2;
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
  LabSeconds.Caption := AppCloseMsg1 + InttoStr(SecondsTillClose) + AppCloseMsg2;
  Application.ProcessMessages;
  if SecondsTillClose < 1 then
    Close;
end;

end.


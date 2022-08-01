program AppIdleCloseTest;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {frmTestAppIdleWarn};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmTestAppIdleWarn, frmTestAppIdleWarn);
  Application.Run;
end.

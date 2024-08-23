program AppIdleCloseTest;

uses
  Forms,
  Unit1 in 'Unit1.pas' {frmTestAppIdleWarn};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmTestAppIdleWarn, frmTestAppIdleWarn);
  Application.Run;
end.

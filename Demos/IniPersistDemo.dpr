program IniPersistDemo;

uses
  Vcl.Forms,
  ufrmIniPersistDemo in 'ufrmIniPersistDemo.pas' {frmIniPersistDemo},
  uConfigIniPersist in '..\Source\misc\uConfigIniPersist.pas',
  uIniPersistDemoSettings in 'uIniPersistDemoSettings.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmIniPersistDemo, frmIniPersistDemo);
  Application.Run;
end.

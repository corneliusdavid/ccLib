program IniLayoutSaverDemo;

uses
  Forms,
  ufrmIniLayoutSaverDemo in 'ufrmIniLayoutSaverDemo.pas' {frmIniLayoutSaver};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmIniLayoutSaver, frmIniLayoutSaver);
  Application.Run;
end.

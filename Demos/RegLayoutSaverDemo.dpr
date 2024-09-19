program RegLayoutSaverDemo;

uses
  Forms,
  ufrmRegLayoutSaverDemo in 'ufrmRegLayoutSaverDemo.pas' {frmRegLayoutSaver};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmRegLayoutSaver, frmRegLayoutSaver);
  Application.Run;
end.

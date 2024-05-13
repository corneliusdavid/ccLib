unit ufrmIniPersistDemo;

interface

uses
  Controls, Forms, Dialogs, StdCtrls, Spin, Mask, ExtCtrls, ComCtrls, Classes, SysUtils;

type
  TfrmIniPersistDemo = class(TForm)
    Label1: TLabel;
    mmoRawConfig: TMemo;
    edtDescription: TLabeledEdit;
    chkOption1: TCheckBox;
    chkOption2: TCheckBox;
    edtFavNum: TSpinEdit;
    Label2: TLabel;
    btnLoad: TButton;
    btnSave: TButton;
    edtDateTimePicker: TDateTimePicker;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    function GetIniFilename: string;
    procedure ShowRawConfigFile(const IniFilename: string);
    procedure LoadConfigFile;
    procedure SaveConfigFile;
    procedure FillGUIFromSettings;
    procedure FillSettingsFromGUI;
  end;

var
  frmIniPersistDemo: TfrmIniPersistDemo;

implementation

{$R *.dfm}

uses
  uConfigIniPersist,
  uIniPersistDemoSettings;

var
  IniPersistSettings: TIniPersisteDemoSettings;


procedure TfrmIniPersistDemo.btnLoadClick(Sender: TObject);
begin
  LoadConfigFile;
end;

procedure TfrmIniPersistDemo.btnSaveClick(Sender: TObject);
begin
  SaveConfigFile;
end;

procedure TfrmIniPersistDemo.FillGuiFromSettings;
begin
  edtDescription.Text := IniPersistSettings.Description;
  chkOption1.Checked := IniPersistSettings.Option1;
  chkOption2.Checked := IniPersistSettings.Option2;
  edtFavNum.Value := IniPersistSettings.FavoriteNumber;
  edtDateTimePicker.DateTime := IniPersistSettings.RandomDate;
end;

procedure TfrmIniPersistDemo.FillSettingsFromGUI;
begin
  IniPersistSettings.Description := edtDescription.Text;
  IniPersistSettings.Option1 := chkOption1.Checked;
  IniPersistSettings.Option2 := chkOption2.Checked;
  IniPersistSettings.FavoriteNumber := edtFavNum.Value;
  IniPersistSettings.RandomDate := edtDateTimePicker.DateTime;
end;

procedure TfrmIniPersistDemo.FormCreate(Sender: TObject);
begin
  IniPersistSettings := TIniPersisteDemoSettings.Create;
  LoadConfigFile;
end;

function TfrmIniPersistDemo.GetIniFilename: string;
begin
  Result := ChangeFileExt(Application.ExeName, '.ini');
end;

procedure TfrmIniPersistDemo.LoadConfigFile;
var
  ConfigFile: string;
begin
  ConfigFile := GetIniFilename;
  IniPersistSettings.Load(ConfigFile);
  ShowRawConfigFile(ConfigFile);

  FillGuiFromSettings;
end;

procedure TfrmIniPersistDemo.SaveConfigFile;
var
  IniFilename: string;
begin
  FillSettingsFromGUI;

  IniFilename := GetIniFileName;
  IniPersistSettings.Save(IniFilename);
  ShowRawConfigFile(IniFilename);
end;

procedure TfrmIniPersistDemo.ShowRawConfigFile(const IniFilename: string);
begin
  mmoRawConfig.Lines.Clear;
  if FileExists(IniFilename) then
    mmoRawConfig.Lines.LoadFromFile(IniFilename);
  mmoRawConfig.Lines.Insert(0, '== Raw Config File ==');
end;

end.

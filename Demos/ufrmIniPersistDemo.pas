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
    grpConfigType: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure grpConfigTypeClick(Sender: TObject);
  private
    function GetIniFilename: string;
    function GetTxtFilename: string;
    procedure ShowRawConfigFile(const CfgFilename: string);
    procedure LoadSemicolonTxtFile;
    procedure SaveSemicolonTxtFile;
    procedure LoadConfigFile;
    procedure SaveConfigFile;
    procedure LoadSettings;
    procedure SaveSettings;
    procedure FillGUIFromIniSettings;
    procedure FillIniSettingsFromGUI;
    procedure FillGUIFromTxtSettings;
    procedure FillTxtSettingsFromGUI;
  end;

var
  frmIniPersistDemo: TfrmIniPersistDemo;

implementation

{$R *.dfm}

uses
  uConfigIniPersist,
  uIniPersistDemoSettings,
  uStrPersistDemoSettings;

var
  IniPersistSettings: TIniPersisteDemoSettings;
  StrPersistSettings: TStrPersisteDemoSettings;


procedure TfrmIniPersistDemo.btnLoadClick(Sender: TObject);
begin
  LoadSettings;
end;

procedure TfrmIniPersistDemo.btnSaveClick(Sender: TObject);
begin
  SaveSettings;
end;

procedure TfrmIniPersistDemo.FillGuiFromIniSettings;
begin
  edtDescription.Text := IniPersistSettings.Description;
  chkOption1.Checked := IniPersistSettings.Option1;
  chkOption2.Checked := IniPersistSettings.Option2;
  edtFavNum.Value := IniPersistSettings.FavoriteNumber;
  edtDateTimePicker.DateTime := IniPersistSettings.RandomDate;
end;

procedure TfrmIniPersistDemo.FillGUIFromTxtSettings;
begin
  edtDescription.Text := StrPersistSettings.Description;
  chkOption1.Checked := StrPersistSettings.Option1;
  chkOption2.Checked := StrPersistSettings.Option2;
  edtFavNum.Value := StrPersistSettings.FavoriteNumber;
  edtDateTimePicker.DateTime := StrPersistSettings.RandomDate;
end;

procedure TfrmIniPersistDemo.FillIniSettingsFromGUI;
begin
  IniPersistSettings.Description := edtDescription.Text;
  IniPersistSettings.Option1 := chkOption1.Checked;
  IniPersistSettings.Option2 := chkOption2.Checked;
  IniPersistSettings.FavoriteNumber := edtFavNum.Value;
  IniPersistSettings.RandomDate := edtDateTimePicker.DateTime;
end;

procedure TfrmIniPersistDemo.FillTxtSettingsFromGUI;
begin
  StrPersistSettings.Description := edtDescription.Text;
  StrPersistSettings.Option1 := chkOption1.Checked;
  StrPersistSettings.Option2 := chkOption2.Checked;
  StrPersistSettings.FavoriteNumber := edtFavNum.Value;
  StrPersistSettings.RandomDate := edtDateTimePicker.DateTime;
end;

procedure TfrmIniPersistDemo.FormCreate(Sender: TObject);
begin
  IniPersistSettings := TIniPersisteDemoSettings.Create;
  StrPersistSettings := TStrPersisteDemoSettings.Create;
  LoadConfigFile;
end;

function TfrmIniPersistDemo.GetIniFilename: string;
begin
  Result := ChangeFileExt(Application.ExeName, '.ini');
end;

function TfrmIniPersistDemo.GetTxtFilename: string;
begin
  Result := ChangeFileExt(Application.ExeName, '.txt');
end;

procedure TfrmIniPersistDemo.grpConfigTypeClick(Sender: TObject);
begin
  ///
end;

procedure TfrmIniPersistDemo.LoadConfigFile;
var
  ConfigFile: string;
begin
  ConfigFile := GetIniFilename;
  IniPersistSettings.Load(ConfigFile);
  ShowRawConfigFile(ConfigFile);

  FillGuiFromIniSettings;
end;

procedure TfrmIniPersistDemo.LoadSemicolonTxtFile;
var
  ConfigFile: string;
  TxtFile: TStreamReader;
  ConfigStr: string;
begin
  ConfigFile := GetTxtFilename;
  TxtFile := TStreamReader.Create(ConfigFile);
  try
    ConfigStr := EmptyStr;
    while not TxtFile.EndOfStream do
    begin
      var s := TxtFile.ReadLine;
      if not s.IsEmpty then
        ConfigStr := ConfigStr + s;
    end;
    StrPersistSettings.Load(ConfigStr);
    ShowRawConfigFile(ConfigFile);

    FillGUIFromTxtSettings;
  finally
    TxtFile.Free;
  end;
end;

procedure TfrmIniPersistDemo.LoadSettings;
begin
  case grpConfigType.ItemIndex of
    0: LoadConfigFile;
    1: LoadSemicolonTxtFile;
  end;
end;

procedure TfrmIniPersistDemo.SaveConfigFile;
var
  IniFilename: string;
begin
  FillIniSettingsFromGUI;

  IniFilename := GetIniFileName;
  IniPersistSettings.Save(IniFilename);
  ShowRawConfigFile(IniFilename);
end;

procedure TfrmIniPersistDemo.SaveSemicolonTxtFile;
var
  ConfigFile: string;
  TxtFile: TStreamWriter;
  ConfigStr: string;
begin
  FillTxtSettingsFromGUI;

  ConfigFile := GetTxtFilename;
  TxtFile := TStreamWriter.Create(ConfigFile, False);
  try
    StrPersistSettings.Save(ConfigStr);
    TxtFile.WriteLine(ConfigStr);
  finally
    TxtFile.Free;
  end;
  ShowRawConfigFile(ConfigFile);
end;

procedure TfrmIniPersistDemo.SaveSettings;
begin
  case grpConfigType.ItemIndex of
    0: SaveConfigFile;
    1: SaveSemicolonTxtFile;
  end;
end;

procedure TfrmIniPersistDemo.ShowRawConfigFile(const CfgFilename: string);
begin
  mmoRawConfig.Lines.Clear;
  if FileExists(CfgFilename) then
    mmoRawConfig.Lines.LoadFromFile(CfgFilename);
  mmoRawConfig.Lines.Insert(0, '== Raw Config File ==');
end;

end.

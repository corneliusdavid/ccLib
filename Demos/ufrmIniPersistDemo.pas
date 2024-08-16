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

procedure TfrmIniPersistDemo.FillIniSettingsFromGUI;
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
  IniPersistSettings.LoadFromFile(ConfigFile);
  ShowRawConfigFile(ConfigFile);

  FillGuiFromIniSettings;
end;

procedure TfrmIniPersistDemo.LoadSemicolonTxtFile;
var
  ConfigFile: string;
  TxtFile: TStreamReader;
  s: string;
  ConfigStr: string;
begin
  ConfigFile := GetTxtFilename;
  TxtFile := TStreamReader.Create(ConfigFile);
  try
    ConfigStr := EmptyStr;
    while not TxtFile.EndOfStream do begin
      s := TxtFile.ReadLine;
      if Length(s) > 0 then
        ConfigStr := ConfigStr + s;
    end;
    IniPersistSettings.LoadFromStr(ConfigStr);
    ShowRawConfigFile(ConfigFile);

    FillGUIFromIniSettings;
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
  IniPersistSettings.SaveToFile(IniFilename);
  ShowRawConfigFile(IniFilename);
end;

procedure TfrmIniPersistDemo.SaveSemicolonTxtFile;
var
  ConfigFile: string;
  TxtFile: TStreamWriter;
  ConfigStr: string;
begin
  FillGUIFromIniSettings;

  ConfigFile := GetTxtFilename;
  TxtFile := TStreamWriter.Create(ConfigFile, False);
  try
    IniPersistSettings.SaveToStr(ConfigStr);
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

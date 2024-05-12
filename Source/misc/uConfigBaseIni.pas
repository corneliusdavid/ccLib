unit uConfigBaseIni;

interface

{$TYPEINFO ON}

type
  TBaseCustomConfigSettings = class
  strict private
    FSection: string;
    FAppDataPath: string;
    FConfigFilename: string;
  private
    function GetSection: string;
    function GetConfigFilename: string;
    procedure SetSection(const AValue: string);
    procedure SetConfigFilename(const Value: string);
  protected
    procedure CheckConfigReady(const Action: string);
  public
    constructor Create(ASection: string = ''); overload; virtual;
    procedure Save; virtual; abstract;
    procedure Load; virtual; abstract;
  published
    property AppDataPath: string read FAppDataPath write FAppDataPath;
    property Section: string read GetSection write SetSection;
    property Configfilename: string read GetConfigFilename write SetConfigFilename;
  end;

  /// <summary>
  ///   old-style settings class where each descendent must define the custom
  ///   load and save method for storing config settings
  /// </summary>
  TCustomConfigSettings = class(TBaseCustomConfigSettings)
  protected
    procedure CustomSave; virtual; abstract;
    procedure CustomLoad; virtual; abstract;
  public
    procedure Save; override;
    procedure Load; override;
  end;

  /// <summary>
  ///   Convenient method of storing settings in .INI files by using code attributes to
  ///   specify NAME=Value pairs in the config file.
  /// </summary>
  /// <remarks>
  ///   If the class attribute [IniClass()] is used, then only one instance of the settings
  ///   class can be stored in the config file because the [Section] is defined at design-time
  ///   in the parameter to IniClass().  If using [IniValue()] for the properties instead, then the
  ///   Section property of the class is used and each instance of the settings class can specify
  ///   a different [Section].
  /// </remarks>
  TIniPersistConfigSettings = class(TBaseCustomConfigSettings)
  public
    procedure Save; override;
    procedure Load; override;
  end;


implementation

uses
  SysUtils, uConfigIniPersist;

{$REGION 'TBaseCustomConfigSettings'}

constructor TBaseCustomConfigSettings.Create(ASection: string = '');
begin
  FSection := ASection;
end;


function TBaseCustomConfigSettings.GetConfigFilename: string;
begin
  Result := FConfigFilename;
end;

function TBaseCustomConfigSettings.GetSection: string;
begin
  Result := FSection;
end;

procedure TBaseCustomConfigSettings.SetConfigFilename(const Value: string);
begin
  FConfigFilename := Value;
end;

procedure TBaseCustomConfigSettings.SetSection(const AValue: string);
begin
  FSection := AValue;
end;

procedure TBaseCustomConfigSettings.CheckConfigReady(const Action: string);
begin
  if Length(FConfigFilename) = 0 then
    raise EProgrammerNotFound.Create(Action + ': Did not set configuration filename: ' + self.ClassName);
  if Length(FSection) = 0 then
    raise EProgrammerNotFound.Create(Action + ': Did not set configuration Section name: ' + self.ClassName);
end;

{$ENDREGION}

{ TCustomConfigSettings }

procedure TCustomConfigSettings.Load;
begin
  CheckConfigReadY('Load');
  CustomLoad;
end;

procedure TCustomConfigSettings.Save;
begin
  CheckConfigReady('Save');
  CustomSave;
end;

{ TIniPersistConfigSettings }

procedure TIniPersistConfigSettings.Load;
begin
  CheckConfigReadY('Load');
  TIniPersist.Load(Configfilename, Self);
end;

procedure TIniPersistConfigSettings.Save;
begin
  CheckConfigReady('Save');
  TIniPersist.Save(Configfilename, Self);
end;

end.
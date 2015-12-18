unit uConfigBaseIni;

interface

{$TYPEINFO ON}

type
  IIniConfigurableSection = interface
  ['{41935A6A-6FFE-45D8-A3D6-FF74BD3E0655}']
    {$REGION 'Private Getters and Setters'}
    function GetSection: string;
    function GetAppDataPath: string;
    function GetConfigFilename: string;
    procedure SetSection(const Value: string);
    procedure SetAppDataPath(const Value: string);
    procedure SetConfigFilename(const Value: string);
    {$ENDREGION}
    procedure Save;
    procedure Load;
    property Section: string read GetSection write SetSection;
    property AppDataPath: string read GetAppDataPath write SetAppDataPath;
    property Configfilename: string read GetConfigFilename write SetConfigFilename;
  end;

  TCustomIniSettings = class(TObject, IIniConfigurableSection)
  strict private
    {$REGION 'private fields'}
    FSection: string;
    FAppDataPath: string;
    FConfigFilename: string;
    {$ENDREGION}
  private
    {$REGION 'IConfigurable getters and setters'}
    function GetSection: string;
    function GetAppDataPath: string;
    function GetConfigFilename: string;
    procedure SetSection(const AValue: string);
    procedure SetAppDataPath(const Value: string);
    procedure SetConfigFilename(const Value: string);
    {$ENDREGION}
  protected
    procedure CustomSave; virtual; abstract;
    procedure CustomLoad; virtual; abstract;
    // IInterface
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    constructor Create(ASection: string = ''); overload; virtual;
    procedure Save; virtual;
    procedure Load; virtual;
  published
    property Section: string read GetSection write SetSection;
    property AppDataPath: string read GetAppDataPath write SetAppDataPath;
    property Configfilename: string read GetConfigFilename write SetConfigFilename;
  end;



implementation

uses
  {$IFDEF UseCodeSite} CodeSiteLogging, {$ENDIF}
  SysUtils;

{$REGION 'TCustomSettings'}

constructor TCustomIniSettings.Create(ASection: string = '');
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'Create'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('ASection', ASection); {$ENDIF}

  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  FSection := ASection;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'Create'); {$ENDIF}
end;

function TCustomIniSettings.GetAppDataPath: string;
begin
  Result := FAppDataPath;
end;

function TCustomIniSettings.GetConfigFilename: string;
begin
  Result := FConfigFilename;
end;

function TCustomIniSettings.GetSection: string;
begin
  Result := FSection;
end;

procedure TCustomIniSettings.Load;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'Load'); {$ENDIF}

  if Length(FConfigFilename) = 0 then
    raise EProgrammerNotFound.Create('[Load] Did not set configuration filename: ' + self.ClassName);

  CustomLoad;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'Load'); {$ENDIF}
end;

procedure TCustomIniSettings.Save;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'Save'); {$ENDIF}

  if Length(FConfigFilename) = 0 then
    raise EProgrammerNotFound.Create('[Save] Did not set configuration filename: ' + self.ClassName);

  CustomSave;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'Save'); {$ENDIF}
end;

procedure TCustomIniSettings.SetAppDataPath(const Value: string);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'SetAppDataPath'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('value', value); {$ENDIF}

  FAppDataPath := Value;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'SetAppDataPath'); {$ENDIF}
end;

procedure TCustomIniSettings.SetConfigFilename(const Value: string);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'SetConfigFilename'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('value', value); {$ENDIF}

  FConfigFilename := Value;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'SetConfigFilename'); {$ENDIF}
end;

procedure TCustomIniSettings.SetSection(const AValue: string);
begin
  FSection := AValue;
end;

function TCustomIniSettings.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TCustomIniSettings._AddRef: Integer;
begin
  // don't reference count
  Result := -1;
end;

function TCustomIniSettings._Release: Integer;
begin
  // don't reference count
  Result := -1;
end;

{$ENDREGION}

end.
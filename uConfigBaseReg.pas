unit uConfigBaseReg;

interface

{$TYPEINFO ON}

uses
  Winapi.Windows, Registry;

type
  IRegConfigurableSection = interface
  ['{41935A6A-6FFE-45D8-A3D6-FF74BD3E0655}']
    {$REGION 'Private Getters and Setters'}
    function GetSection: string;
    function GetRootKey: HKEY;
    function GetRootPath: string;
    procedure SetSection(const Value: string);
    procedure SetRootKey(const Value: HKEY);
    procedure SetRootPath(const Value: string);
    {$ENDREGION}
    procedure Save;
    procedure Load;
    property Section: string read GetSection write SetSection;
    property RootKey: HKEY read GetRootKey write SetRootKey;
    property RootPath: string read GetRootPath write SetRootPath;
  end;

  TCustomRegSettings = class(TInterfacedObject, IRegConfigurableSection)
  strict private
    {$REGION 'private fields'}
    FSection: string;
    FRootPath: string;
    FRootKey: HKEY;
    {$ENDREGION}
  private
    {$REGION 'IConfigurable getters and setters'}
    function GetSection: string;
    function GetRootKey: HKEY;
    function GetRootPath: string;
    procedure SetSection(const AValue: string);
    procedure SetRootKey(const Value: HKEY);
    procedure SetRootPath(const Value: string);
    {$ENDREGION}
  public
//    constructor Create(ASection: string); overload;
    procedure Save; virtual;
    procedure Load; virtual;
  published
    property Section: string read GetSection write SetSection;
    property RootKey: HKEY read GetRootKey write SetRootKey;
    property RootPath: string read GetRootPath write SetRootPath;
  end;



implementation

uses
  {$IFDEF UseCodeSite} CodeSiteLogging, {$ENDIF}
  SysUtils, uConfigRegPersist;

{$REGION 'TCustomRegSettings'}

(*
constructor TCustomRegSettings.Create(ASection: string);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'Create'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('ASection', ASection); {$ENDIF}

  if Length(ASection) = 0 then
    raise EProgrammerNotFound.Create('Did not set the Section of the configuration object: ' + self.ClassName);

  FSection := ASection;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'Create'); {$ENDIF}
end;
*)

function TCustomRegSettings.GetRootKey: HKEY;
begin
  Result := FRootKey;
end;

function TCustomRegSettings.GetRootPath: string;
begin
  Result := FRootPath;
end;

function TCustomRegSettings.GetSection: string;
begin
  Result := FSection;
end;

procedure TCustomRegSettings.Load;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'Load'); {$ENDIF}

  if Length(FRootPath) = 0 then
    raise EProgrammerNotFound.Create('[Load] Did not set configuration root path: ' + self.ClassName);

  TRegPersist.Load(FRootKey, FRootPath, Self);

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'Load'); {$ENDIF}
end;

procedure TCustomRegSettings.Save;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'Save'); {$ENDIF}

  if Length(FRootPath) = 0 then
    raise EProgrammerNotFound.Create('[Save] Did not set configuration root path: ' + self.ClassName);

  TRegPersist.Save(FRootKey, FRootPath, Self);

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'Save'); {$ENDIF}
end;

procedure TCustomRegSettings.SetRootKey(const Value: HKEY);
begin
  FRootKey := Value;
end;

procedure TCustomRegSettings.SetRootPath(const Value: string);
begin
  FRootPath := Value;
end;

procedure TCustomRegSettings.SetSection(const AValue: string);
begin
  FSection := AValue;
end;
{$ENDREGION}

end.
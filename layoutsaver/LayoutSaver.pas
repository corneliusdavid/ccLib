unit LayoutSaver;
(*
  * as: LayoutSaver
  * by: David Cornelius
  * to: make saving/restoring the size/position of a form (and other controls and properties) very easy
*)


interface

{$I cc.inc}

uses
  {$IFDEF XE2orHIGHER}
  System.SysUtils, System.Classes,
  System.Win.Registry,
  System.IniFiles;
  {$ELSE}
  SysUtils, Classes,
  Registry,
  IniFiles;
{$ENDIF}

type
  {
    CustomLayoutSaver
    base class that could be extended to use any save/restore mechanism
    (i.e. Registry or .INI file)
  }
  TccCustomLayoutSaver = class(TComponent)
  private
    FLocation: string;
    FSection: string;
    FUseDefaultNames: Boolean;
    FOnBeforeRestore: TNotifyEvent;
    FOnBeforeSave: TNotifyEvent;
    procedure SetUseDefaultNames(Value: Boolean);
    procedure CheckSaveOnDestroy(Sender: TObject);
    procedure CheckRestoreOnCreate(Sender: TObject);
  protected
    FAutoSave: Boolean;
    FAutoRestore: Boolean;
    FSaveOnCreate: TNotifyEvent;
    FSaveOnDestroy: TNotifyEvent;
    procedure DoBeforeRestore;
    procedure DoBeforeSave;
    procedure AssignDefaultLocation; virtual; abstract;
    procedure AssignDefaultSection; virtual;
    function Open: Boolean; virtual;
    procedure Close; virtual; abstract;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Restore; virtual;
    procedure Save; virtual;
    procedure SaveIntValue(const name: string; const Value: Integer); virtual; abstract;
    function RestoreIntValue(const name: string; const default: Integer = 0): Integer; virtual; abstract;
    procedure SaveStrValue(const name: string; const Value: string); virtual; abstract;
    function RestoreStrValue(const name: string; const default: string = ''): string; virtual; abstract;
    procedure SaveBoolValue(const name: string; const Value: Boolean); virtual; abstract;
    function RestoreBoolValue(const name: string; const default: Boolean = False): Boolean; virtual; abstract;
  published
    property Location: string read FLocation write FLocation;
    property Section: string read FSection write FSection;
    property UseDefaultNames: Boolean read FUseDefaultNames write SetUseDefaultNames default True;
    property AutoSave: Boolean read FAutoSave write FAutoSave default True;
    property AutoRestore: Boolean read FAutoRestore write FAutoRestore default True;
    property OnBeforeRestore: TNotifyEvent read FOnBeforeRestore write FOnBeforeRestore;
    property OnBeforeSave: TNotifyEvent read FOnBeforeSave write FOnBeforeSave;
  end;


  {
    INI LayoutSaver
    extended from CustomLayoutSaver to use an .INI file
  }
  TccIniLayoutSaver = class(TccCustomLayoutSaver)
  private
    FIniFile: TIniFile;
    FUseAppDataFolder: Boolean;
    function GetAppDataPath: string;
  protected
    procedure AssignDefaultLocation; override;
    procedure Close; override;
    function Open: Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SaveIntValue(const name: string; const Value: Integer); override;
    function RestoreIntValue(const name: string; const default: Integer = 0): Integer; override;
    procedure SaveStrValue(const name: string; const Value: string); override;
    function RestoreStrValue(const name: string; const default: string = ''): string; override;
    procedure SaveBoolValue(const name: string; const Value: Boolean); override;
    function RestoreBoolValue(const name: string; const default: Boolean = False): Boolean; override;
  published
    property UseAppDataFolder: Boolean read FUseAppDataFolder write FUseAppDataFolder default True;
  end;


  {
    Registry LayoutSaver
    extended from CustomLayoutSaver to use the registry
  }
  TccRegistryLayoutSaver = class(TccCustomLayoutSaver)
  private
    FRegistry: TRegistry;
  protected
    procedure AssignDefaultLocation; override;
    procedure Close; override;
    function Open: Boolean; override;
  public
    procedure SaveIntValue(const name: string; const Value: Integer); override;
    function RestoreIntValue(const name: string; const default: Integer = 0): Integer; override;
    procedure SaveStrValue(const name: string; const Value: string); override;
    function RestoreStrValue(const name: string; const default: string = ''): string; override;
    procedure SaveBoolValue(const name: string; const Value: Boolean); override;
    function RestoreBoolValue(const name: string; const default: Boolean = False): Boolean; override;
  end;

implementation


uses
  {$IFDEF UseCodeSite} CodeSiteLogging, {$ENDIF}
  {$IFDEF XEorHIGHER}
  Winapi.Windows, Winapi.SHFolder,
  VCL.Forms;
  {$ELSE}
Windows, SHFolder,
  Forms;
{$ENDIF}

const
  sFormTop    = 'FormTop';
  sFormLeft   = 'FormLeft';
  sFormWidth  = 'FormWidth';
  sFormHeight = 'FormHeight';

  { TccCustomLayoutSaver }


constructor TccCustomLayoutSaver.Create(AOwner: TComponent);
begin
  inherited;

  FLocation        := EmptyStr;
  FSection         := EmptyStr;
  FUseDefaultNames := True;

  FAutoRestore := True;
  FAutoSave    := True;
  if not(csDesigning in ComponentState) then begin
    if Assigned((AOwner as TForm).OnCreate) then
      FSaveOnCreate := (AOwner as TForm).OnCreate;
    if Assigned((AOwner as TForm).OnDestroy) then
      FSaveOnDestroy := (AOwner as TForm).OnDestroy;

    (AOwner as TForm).OnCreate  := CheckRestoreOnCreate;
    (AOwner as TForm).OnDestroy := CheckSaveOnDestroy;
  end;
end;


procedure TccCustomLayoutSaver.DoBeforeRestore;
begin
  if Assigned(FOnBeforeRestore) then
    FOnBeforeRestore(self);
end;

procedure TccCustomLayoutSaver.DoBeforeSave;
begin
  if Assigned(FOnBeforeSave) then
    FOnBeforeSave(self);
end;

function TccCustomLayoutSaver.Open: Boolean;
begin
  if (Length(FLocation) = 0) or FUseDefaultNames then
    AssignDefaultLocation;
  if (Length(FSection) = 0) or FUseDefaultNames then
    AssignDefaultSection;

  // default--override in descendant class
  Result := False;
end;

procedure TccCustomLayoutSaver.Restore;
begin
  DoBeforeRestore;
  (Owner as TForm).Top    := RestoreIntValue(sFormTop, (Owner as TForm).Top);
  (Owner as TForm).Left   := RestoreIntValue(sFormLeft, (Owner as TForm).Left);
  (Owner as TForm).Width  := RestoreIntValue(sFormWidth, (Owner as TForm).Width);
  (Owner as TForm).Height := RestoreIntValue(sFormHeight, (Owner as TForm).Height);
end;

procedure TccCustomLayoutSaver.Save;
begin
  DoBeforeSave;
  SaveIntValue(sFormTop, (Owner as TForm).Top);
  SaveIntValue(sFormLeft, (Owner as TForm).Left);
  SaveIntValue(sFormWidth, (Owner as TForm).Width);
  SaveIntValue(sFormHeight, (Owner as TForm).Height);
end;

procedure TccCustomLayoutSaver.SetUseDefaultNames(Value: Boolean);
begin
  if FUseDefaultNames <> Value then begin
    FUseDefaultNames := Value;
    if FUseDefaultNames then begin
      AssignDefaultSection;
      AssignDefaultLocation;
    end;
  end;
end;


procedure TccCustomLayoutSaver.AssignDefaultSection;
begin
  FSection := (Owner as TForm).Name;
end;

procedure TccCustomLayoutSaver.CheckRestoreOnCreate(Sender: TObject);
begin
  if Assigned(FSaveOnCreate) then
    FSaveOnCreate(Sender);
  if FAutoRestore and (not(csDesigning in ComponentState)) then
    Restore;
end;


procedure TccCustomLayoutSaver.CheckSaveOnDestroy(Sender: TObject);
begin
  if FAutoSave and (not(csDesigning in ComponentState)) then
    Save;
  if Assigned(FSaveOnDestroy) then
    FSaveOnDestroy(Sender);
end;

{ TccIniLayoutSaver }


constructor TccIniLayoutSaver.Create(AOwner: TComponent);
begin
  inherited;
  FUseAppDataFolder := True;
end;


function TccIniLayoutSaver.GetAppDataPath: string;
var
  LStr: array [0 .. MAX_PATH] of Char;
begin
  SetLastError(ERROR_SUCCESS);

  if SHGetFolderPath(0, CSIDL_LOCAL_APPDATA, 0, 0, @LStr) = S_OK then
    Result := LStr;
end;


procedure TccIniLayoutSaver.AssignDefaultLocation;
var
  AppDataFolder: string;
begin
  inherited;

  if FUseAppDataFolder then begin
    AppDataFolder := IncludeTrailingPathDelimiter(GetAppDataPath) +
      ChangeFileExt(ExtractFileName(Application.ExeName), '');
    {$IFDEF UseCodeSite} CodeSite.Send('using AppDataFolder', AppDataFolder); {$ENDIF}
    ForceDirectories(AppDataFolder);
    FLocation := IncludeTrailingPathDelimiter(AppDataFolder) +
      ChangeFileExt(ExtractFileName(Application.ExeName), '.INI');
  end
  else
    FLocation := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) +
      ChangeFileExt(ExtractFileName(Application.ExeName), '.INI');

  {$IFDEF UseCodeSite} CodeSite.Send('location', FLocation); {$ENDIF}
  {$IFDEF UseCodeSite}CodeSite.ExitMethod(Self, 'AssignDefaultLocation'); {$ENDIF}
end;


function TccIniLayoutSaver.Open: Boolean;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod(Self, 'Open'); {$ENDIF}
  inherited Open;

  if Length(FLocation) > 0 then begin
    FIniFile := TIniFile.Create(FLocation);
    Result   := True;
  end
  else
    Result := False;

  {$IFDEF UseCodeSite}CodeSite.ExitMethod(Self, 'Open'); {$ENDIF}
end;


procedure TccIniLayoutSaver.Close;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod(Self, 'Close'); {$ENDIF}
  inherited Open;

  FIniFile.Free;

  {$IFDEF UseCodeSite}CodeSite.ExitMethod(Self, 'Close'); {$ENDIF}
end;


procedure TccIniLayoutSaver.SaveIntValue(const name: string; const Value: Integer);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod(Self, 'SaveIntValue'); {$ENDIF}
  inherited;

  if Open then begin
    FIniFile.WriteInteger(Section, name, Value);
    Close;
  end;

  {$IFDEF UseCodeSite}CodeSite.ExitMethod(Self, 'SaveIntValue'); {$ENDIF}
end;


function TccIniLayoutSaver.RestoreIntValue(const name: string; const default: Integer = 0): Integer;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod(Self, 'RestoreIntValue'); {$ENDIF}
  inherited;

  if Open and FIniFile.ValueExists(FSection, name) then begin
    Result := FIniFile.ReadInteger(FSection, name, default);
    Close;
  end
  else
    Result := default;

  {$IFDEF UseCodeSite}CodeSite.ExitMethod(Self, 'RestoreIntValue'); {$ENDIF}
end;


procedure TccIniLayoutSaver.SaveStrValue(const name, Value: string);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'SaveStrValue'); {$ENDIF}
  inherited;

  if Open then begin
    FIniFile.WriteString(Section, name, Value);
    Close;
  end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'SaveStrValue'); {$ENDIF}
end;


function TccIniLayoutSaver.RestoreStrValue(const name: string; const default: string = ''): string;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'RestoreStrValue'); {$ENDIF}
  inherited;

  if Open and FIniFile.ValueExists(FSection, name) then begin
    Result := FIniFile.ReadString(FSection, name, default);
    Close;
  end
  else
    Result := default;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'RestoreStrValue'); {$ENDIF}
end;


procedure TccIniLayoutSaver.SaveBoolValue(const name: string; const Value: Boolean);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'SaveBoolValue'); {$ENDIF}
  inherited;

  if Open then begin
    FIniFile.WriteBool(Section, name, Value);
    Close;
  end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'SaveBoolValue'); {$ENDIF}
end;


function TccIniLayoutSaver.RestoreBoolValue(const name: string; const default: Boolean = False): Boolean;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'RestoreBoolValue'); {$ENDIF}
  inherited;

  if Open and FIniFile.ValueExists(FSection, name) then begin
    Result := FIniFile.ReadBool(FSection, name, default);
    Close;
  end
  else
    Result := default;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'RestoreBoolValue'); {$ENDIF}
end;

{ TccRegsitryLayoutSaver }

procedure TccRegistryLayoutSaver.AssignDefaultLocation;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'AssignDefaultLocation'); {$ENDIF}
  FLocation := 'Software\' + ChangeFileExt(ExtractFileName(Application.ExeName), '');
  {$IFDEF UseCodeSite} CodeSite.Send('location', FLocation); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'AssignDefaultLocation'); {$ENDIF}
end;

procedure TccRegistryLayoutSaver.Close;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'Close'); {$ENDIF}
  FRegistry.CloseKey;
  FRegistry.Free;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'Close'); {$ENDIF}
end;

function TccRegistryLayoutSaver.Open: Boolean;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'Open'); {$ENDIF}
  inherited Open;

  if Length(FLocation) > 0 then begin
    FRegistry         := TRegistry.Create;
    FRegistry.RootKey := HKEY_CURRENT_USER;
    Result            := FRegistry.OpenKey(IncludeTrailingPathDelimiter(FLocation) + FSection, True);
  end
  else
    Result := False;

  {$IFDEF UseCodeSite} CodeSite.Send('Result', Result); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'Open'); {$ENDIF}
end;

procedure TccRegistryLayoutSaver.SaveBoolValue(const name: string; const Value: Boolean);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'SaveBoolValue'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('Name', name); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('Value', Value); {$ENDIF}
  if Open then begin
    FRegistry.WriteBool(name, Value);
    Close;
  end;

  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'SaveBoolValue'); {$ENDIF}
end;

function TccRegistryLayoutSaver.RestoreBoolValue(const name: string; const default: Boolean = False): Boolean;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'RestoreBoolValue'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('Name', name); {$ENDIF}
  Result := default;

  if Open then begin
    if FRegistry.ValueExists(name) then
      Result := FRegistry.ReadBool(name);
    Close;
  end;

  {$IFDEF UseCodeSite} CodeSite.Send('Result', Result); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'RestoreBoolValue'); {$ENDIF}
end;

procedure TccRegistryLayoutSaver.SaveIntValue(const name: string; const Value: Integer);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'SaveIntValue'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('Name', name); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('Value', Value); {$ENDIF}
  inherited;

  if Open then begin
    FRegistry.WriteInteger(name, Value);
    Close;
  end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'SaveIntValue'); {$ENDIF}
end;

function TccRegistryLayoutSaver.RestoreIntValue(const name: string; const default: Integer = 0): Integer;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'RestoreIntValue'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('Name', name); {$ENDIF}
  Result := default;

  if Open then begin
    if FRegistry.ValueExists(name) then
      Result := FRegistry.ReadInteger(name);
    Close;
  end;

  {$IFDEF UseCodeSite} CodeSite.Send('Result', Result); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'RestoreIntValue'); {$ENDIF}
end;

procedure TccRegistryLayoutSaver.SaveStrValue(const name, Value: string);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'SaveStrValue'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('Name', name); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('Value', Value); {$ENDIF}
  if Open then begin
    FRegistry.WriteString(name, Value);
    Close;
  end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'SaveStrValue'); {$ENDIF}
end;

function TccRegistryLayoutSaver.RestoreStrValue(const name: string; const default: string = ''): string;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'RestoreStrValue'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('Name', name); {$ENDIF}
  Result := default;

  if Open then begin
    if FRegistry.ValueExists(name) then
      Result := FRegistry.ReadString(name);
    Close;
  end;

  {$IFDEF UseCodeSite} CodeSite.Send('Result', Result); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'RestoreStrValue'); {$ENDIF}
end;

end.

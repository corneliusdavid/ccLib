unit LayoutSaver;
(*
  * as: LayoutSaver
  * by: David Cornelius
  * to: make saving/restoring the size/position of a form (and other controls and properties) very easy
*)


interface


uses
  SysUtils, Classes,
  Registry,
  IniFiles;

type
  {
    CustomLayoutSaver
    base class that could be extended to use any save/restore mechanism
    (i.e. Registry or .INI file)
  }
  TccCustomLayoutSaver = class(TComponent)
  private
    FLocation:string;
    FSection:string;
    FUseDefaultNames: Boolean;
    procedure SetUseDefaultNames(Value: Boolean);
    procedure CheckSaveOnDestroy(Sender: TObject);
    procedure CheckRestoreOnCreate(Sender: TObject);
  protected
    FAutoSave: Boolean;
    FAutoRestore: Boolean;
    FSaveOnCreate: TNotifyEvent;
    FSaveOnDestroy: TNotifyEvent;
    procedure AssignDefaultLocation; virtual; abstract;
    procedure AssignDefaultSection; virtual;
    function Open: Boolean; virtual;
    procedure Close; virtual; abstract;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Restore; virtual;
    procedure Save; virtual;
    procedure SaveIntValue(const Name:string;const Value: Integer); virtual; abstract;
    function RestoreIntValue(const Name:string): Integer; virtual; abstract;
    procedure SaveStrValue(const Name:string;const Value:string); virtual; abstract;
    function ResstoreStrValue(const Name:string):string; virtual; abstract;
    procedure SaveBoolValue(const Name:string;const Value: Boolean); virtual; abstract;
    function RestoreBoolValue(const Name:string): Boolean; virtual; abstract;
  published
    property Location:string read FLocation write FLocation;
    property Section:string read FSection write FSection;
    property UseDefaultNames: Boolean read FUseDefaultNames write SetUseDefaultNames default True;
    property AutoSave: Boolean read FAutoSave write FAutoSave default True;
    property AutoRestore: Boolean read FAutoRestore write FAutoRestore default True;
  end;


  {
    INI LayoutSaver
    extended from CustomLayoutSaver to use an .INI file
  }
  TccIniLayoutSaver = class(TccCustomLayoutSaver)
  private
    FIniFile: TIniFile;
    FUseAppDataFolder: Boolean;
    function GetAppDataPath:string;
  protected
    procedure AssignDefaultLocation; override;
    procedure Close; override;
    function Open: Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SaveIntValue(const Name:string;const Value: Integer); override;
    function RestoreIntValue(const Name:string): Integer; override;
    procedure SaveStrValue(const Name:string;const Value:string); override;
    function ResstoreStrValue(const Name:string):string; override;
    procedure SaveBoolValue(const Name:string;const Value: Boolean); override;
    function RestoreBoolValue(const Name:string): Boolean; override;
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
    procedure SaveIntValue(const Name:string;const Value: Integer); override;
    function RestoreIntValue(const Name:string): Integer; override;
    procedure SaveStrValue(const Name:string;const Value:string); override;
    function ResstoreStrValue(const Name:string):string; override;
    procedure SaveBoolValue(const Name:string;const Value: Boolean); override;
    function RestoreBoolValue(const Name:string): Boolean; override;
  end;

implementation


uses
  {$IFDEF UseCodeSite} CodeSiteLogging, {$ENDIF}
  Windows, SHFolder,
  Forms;

const
  sFormTop = 'FormTop';
  sFormLeft = 'FormLeft';
  sFormWidth = 'FormWidth';
  sFormHeight = 'FormHeight';

  { TccCustomLayoutSaver }


constructor TccCustomLayoutSaver.Create(AOwner: TComponent);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod(Self, 'Create'); {$ENDIF}
  inherited;

  FLocation := EmptyStr;
  FSection := EmptyStr;
  FUseDefaultNames := True;

  FAutoRestore := True;
  FAutoSave := True;
  if not(csDesigning in ComponentState)then begin
    if Assigned((AOwner as TForm).OnCreate)then
      FSaveOnCreate :=(AOwner as TForm).OnCreate;
    if Assigned((AOwner as TForm).OnDestroy)then
      FSaveOnDestroy :=(AOwner as TForm).OnDestroy;

    (AOwner as TForm).OnCreate := CheckRestoreOnCreate;
    (AOwner as TForm).OnDestroy := CheckSaveOnDestroy;
  end;

  {$IFDEF UseCodeSite}CodeSite.ExitMethod(Self, 'Create'); {$ENDIF}
  {$IFDEF UseCodeSite}CodeSite.ExitMethod(Self, 'Create'); {$ENDIF}
end;


function TccCustomLayoutSaver.Open: Boolean;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'Open'); {$ENDIF}

  if (Length(FLocation) = 0) or FUseDefaultNames then
    AssignDefaultLocation;
  if (Length(FSection) = 0) or FUseDefaultNames then
    AssignDefaultSection;

  // default--override in descendant class
  Result := False;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'Open'); {$ENDIF}
end;

procedure TccCustomLayoutSaver.Restore;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod(Self, 'Restore'); {$ENDIF}

  (Owner as TForm).Top := RestoreIntValue(sFormTop);
  (Owner as TForm).Left := RestoreIntValue(sFormLeft);
  (Owner as TForm).Width := RestoreIntValue(sFormWidth);
  (Owner as TForm).Height := RestoreIntValue(sFormHeight);

  {$IFDEF UseCodeSite}CodeSite.ExitMethod(Self, 'Restore'); {$ENDIF}
end;

procedure TccCustomLayoutSaver.Save;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod(Self, 'Save'); {$ENDIF}
  SaveIntValue(sFormTop,(Owner as TForm).Top);
  SaveIntValue(sFormLeft,(Owner as TForm).Left);
  SaveIntValue(sFormWidth,(Owner as TForm).Width);
  SaveIntValue(sFormHeight,(Owner as TForm).Height);

  {$IFDEF UseCodeSite}CodeSite.ExitMethod(Self, 'Save'); {$ENDIF}
end;

procedure TccCustomLayoutSaver.SetUseDefaultNames(Value: Boolean);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod(Self, 'SetUseDefaultNames'); {$ENDIF}
  if FUseDefaultNames <> Value then begin
    FUseDefaultNames := Value;
    if FUseDefaultNames then begin
      AssignDefaultSection;
      AssignDefaultLocation;
    end;
  end;

  {$IFDEF UseCodeSite}CodeSite.ExitMethod(Self, 'SetUseDefaultNames'); {$ENDIF}
end;


procedure TccCustomLayoutSaver.AssignDefaultSection;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod(Self, 'AssignDefaultSection'); {$ENDIF}
  FSection := (Owner as TForm).Name;

  {$IFDEF UseCodeSite}CodeSite.ExitMethod(Self, 'AssignDefaultSection'); {$ENDIF}

end;

procedure TccCustomLayoutSaver.CheckRestoreOnCreate(Sender: TObject);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod(Self, 'CheckRestoreOnCreate'); {$ENDIF}
  if Assigned(FSaveOnCreate)then
    FSaveOnCreate(Sender);
  if FAutoRestore and(not(csDesigning in ComponentState))then
    Restore;

  {$IFDEF UseCodeSite}CodeSite.ExitMethod(Self, 'CheckRestoreOnCreate'); {$ENDIF}
end;


procedure TccCustomLayoutSaver.CheckSaveOnDestroy(Sender: TObject);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod(Self, 'CheckSaveOnDestroy'); {$ENDIF}
  if FAutoSave and(not(csDesigning in ComponentState))then
    Save;
  if Assigned(FSaveOnDestroy)then
    FSaveOnDestroy(Sender);

  {$IFDEF UseCodeSite}CodeSite.ExitMethod(Self, 'CheckSaveOnDestroy'); {$ENDIF}
end;

{ TccIniLayoutSaver }


constructor TccIniLayoutSaver.Create(AOwner: TComponent);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'Create'); {$ENDIF}
  inherited;
  FUseAppDataFolder := True;
  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'Create'); {$ENDIF}
end;


function TccIniLayoutSaver.GetAppDataPath:string;
var
  LStr: array[0 .. MAX_PATH] of Char;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'GetAppDataPath'); {$ENDIF}
  SetLastError(ERROR_SUCCESS);

  if SHGetFolderPath(0, CSIDL_LOCAL_APPDATA, 0, 0,@LStr)= S_OK then
    Result := LStr;

  {$IFDEF UseCodeSite} CodeSite.Send('Result', Result); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'GetAppDataPath'); {$ENDIF}
end;


procedure TccIniLayoutSaver.AssignDefaultLocation;
var
  AppDataFolder: string;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod(Self, 'AssignDefaultLocation'); {$ENDIF}

  inherited;

  if FUseAppDataFolder then begin
    AppDataFolder := IncludeTrailingPathDelimiter(GetAppDataPath) +
                     ChangeFileExt(ExtractFileName(Application.ExeName), '');
    {$IFDEF UseCodeSite} CodeSite.Send('using AppDataFolder', AppDataFolder); {$ENDIF}
    ForceDirectories(AppDataFolder);
    FLocation := IncludeTrailingPathDelimiter(AppDataFolder) +
                 ChangeFileExt(ExtractFileName(Application.ExeName), '.INI');
  end else
    FLocation := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) +
      ChangeFileExt(ExtractFileName(Application.ExeName), '.INI');

  {$IFDEF UseCodeSite} CodeSite.Send('location', FLocation); {$ENDIF}
  {$IFDEF UseCodeSite}CodeSite.ExitMethod(Self, 'AssignDefaultLocation'); {$ENDIF}
end;


function TccIniLayoutSaver.Open: Boolean;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod(Self, 'Open'); {$ENDIF}

  inherited;

  if Length(FLocation)> 0 then begin
    FIniFile := TIniFile.Create(FLocation);
    Result := True;
  end else
    Result := False;

  {$IFDEF UseCodeSite}CodeSite.ExitMethod(Self, 'Open'); {$ENDIF}
end;


procedure TccIniLayoutSaver.Close;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod(Self, 'Close'); {$ENDIF}

  inherited;

  FIniFile.Free;

  {$IFDEF UseCodeSite}CodeSite.ExitMethod(Self, 'Close'); {$ENDIF}
end;


procedure TccIniLayoutSaver.SaveIntValue(const Name: string; const Value: Integer);
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod(Self, 'SaveIntValue'); {$ENDIF}

  inherited;

  if Open then begin
    FIniFile.WriteInteger(Section, name, Value);
    Close;
  end;

  {$IFDEF UseCodeSite}CodeSite.ExitMethod(Self, 'SaveIntValue'); {$ENDIF}
end;


function TccIniLayoutSaver.RestoreIntValue(const Name: string): Integer;
begin
  {$IFDEF UseCodeSite}CodeSite.EnterMethod(Self, 'RestoreIntValue'); {$ENDIF}

  inherited;

  if Open and FIniFile.ValueExists(FSection, name)then begin
    Result := FIniFile.ReadInteger(FSection, name, 0);
    Close;
  end
  else
    Result := 0;

  {$IFDEF UseCodeSite}CodeSite.ExitMethod(Self, 'RestoreIntValue'); {$ENDIF}
end;


procedure TccIniLayoutSaver.SaveStrValue(const Name, Value:string);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'SaveStrValue'); {$ENDIF}

  inherited;

  if Open then begin
    FIniFile.WriteString(Section, name, Value);
    Close;
  end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'SaveStrValue'); {$ENDIF}
end;


function TccIniLayoutSaver.ResstoreStrValue(const Name:string):string;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'ResstoreStrValue'); {$ENDIF}

  inherited;

  if Open and FIniFile.ValueExists(FSection, name)then begin
    Result := FIniFile.ReadString(FSection, name, EmptyStr);
    Close;
  end
  else
    Result := EmptyStr;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'ResstoreStrValue'); {$ENDIF}
end;


procedure TccIniLayoutSaver.SaveBoolValue(const Name:string;const Value: Boolean);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'SaveBoolValue'); {$ENDIF}

  inherited;

  if Open then begin
    FIniFile.WriteBool(Section, name, Value);
    Close;
  end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'SaveBoolValue'); {$ENDIF}
end;


function TccIniLayoutSaver.RestoreBoolValue(const Name:string): Boolean;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'RestoreBoolValue'); {$ENDIF}

  inherited;

  if Open and FIniFile.ValueExists(FSection, name)then begin
    Result := FIniFile.ReadBool(FSection, name, False);
    Close;
  end
  else
    Result := False;

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
  inherited;

  if Length(FLocation)> 0 then begin
    FRegistry := TRegistry.Create;
    FRegistry.RootKey := HKEY_CURRENT_USER;
    Result := FRegistry.OpenKey(IncludeTrailingPathDelimiter(FLocation) + FSection, True);
  end
  else
    Result := False;

  {$IFDEF UseCodeSite} CodeSite.Send('Result', Result); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'Open'); {$ENDIF}
end;

procedure TccRegistryLayoutSaver.SaveBoolValue(const Name: string; const Value: Boolean);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'SaveBoolValue'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('Name', Name); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('Value', Value); {$ENDIF}

  if Open then begin
    FRegistry.WriteBool(Name, Value);
    Close;
  end;

  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'SaveBoolValue'); {$ENDIF}
end;

function TccRegistryLayoutSaver.RestoreBoolValue(const Name: string): Boolean;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'RestoreBoolValue'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('Name', Name); {$ENDIF}

  Result := False;

  if Open then begin
    if FRegistry.ValueExists(Name) then
      Result := FRegistry.ReadBool(Name);
    Close;
  end;

  {$IFDEF UseCodeSite} CodeSite.Send('Result', Result); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'RestoreBoolValue'); {$ENDIF}
end;

procedure TccRegistryLayoutSaver.SaveIntValue(const Name: string; const Value: Integer);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'SaveIntValue'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('Name', Name); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('Value', Value); {$ENDIF}

  inherited;

  if Open then begin
    FRegistry.WriteInteger(Name, Value);
    Close;
  end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'SaveIntValue'); {$ENDIF}
end;

function TccRegistryLayoutSaver.RestoreIntValue(const Name: string): Integer;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'RestoreIntValue'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('Name', Name); {$ENDIF}

  Result := 0;

  if Open then begin
    if FRegistry.ValueExists(Name) then
      Result := FRegistry.ReadInteger(Name);
    Close;
  end;

  {$IFDEF UseCodeSite} CodeSite.Send('Result', Result); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'RestoreIntValue'); {$ENDIF}
end;

procedure TccRegistryLayoutSaver.SaveStrValue(const Name, Value: string);
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'SaveStrValue'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('Name', Name); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('Value', Value); {$ENDIF}

  if Open then begin
    FRegistry.WriteString(Name, Value);
    Close;
  end;

  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'SaveStrValue'); {$ENDIF}
end;

function TccRegistryLayoutSaver.ResstoreStrValue(const Name: string): string;
begin
  {$IFDEF UseCodeSite} CodeSite.EnterMethod(Self, 'ResstoreStrValue'); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.Send('Name', Name); {$ENDIF}

  Result := EmptyStr;

  if Open then begin
    if FRegistry.ValueExists(Name) then
      Result := FRegistry.ReadString(Name);
    Close;
  end;

  {$IFDEF UseCodeSite} CodeSite.Send('Result', Result); {$ENDIF}
  {$IFDEF UseCodeSite} CodeSite.ExitMethod(Self, 'ResstoreStrValue'); {$ENDIF}
end;

end.

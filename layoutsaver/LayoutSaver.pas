unit LayoutSaver;
(*
 * as: LayoutSaver
 * by: David Cornelius
 * to: make saving/restoring the size/position of a form (and other controls) very easy
 *)

interface

uses
  SysUtils, Classes,
  IniFiles;

type
  {
    CustomLayoutSaver
    base class that could be extended to use any save/restore mechanism
    (i.e. Registry or .INI file)
  }
  TccCustomLayoutSaver = class (TComponent)
  private
    FLocation: string;
    FSection: string;
    FUseDefaultNames: Boolean;
    procedure SetUseDefaultNames(Value: Boolean);
  protected
    procedure AssignDefaultLocation; virtual; abstract;
    procedure AssignDefaultSection; virtual; abstract;
    procedure Close; virtual; abstract;
    function  Open: Boolean; virtual; abstract;
  public
    constructor Create(AOwner: TComponent); override;
    function  RestoreDimension(const Name: string): Integer; virtual; abstract;
    procedure SaveDimension(const Name: string; const Value: Integer); virtual; abstract;
  published
    property Location: string read FLocation write FLocation;
    property Section: string read FSection write FSection;
    property UseDefaultNames: Boolean read FUseDefaultNames write SetUseDefaultNames default True;
  end;

  {
    LayoutSaver
    extended from CustomLayoutSaver to use an .INI file and written to work specifically with forms
  }
  EccLayoutSaver = Exception;

  TccLayoutSaver = class (TccCustomLayoutSaver)
  private
    FIniFile: TIniFile;
    FAutoSave: Boolean;
    FAutoRestore: Boolean;
    FSaveOnCreate: TNotifyEvent;
    FSaveOnDestroy: TNotifyEvent;
    procedure CheckSaveOnDestroy(Sender: TObject);
    procedure CheckRestoreOnCreate(Sender: TObject);
  protected
    procedure AssignDefaultLocation; override;
    procedure AssignDefaultSection; override;
    procedure Close; override;
    function Open: Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Restore;
    procedure Save;
    procedure SaveDimension(const Name: string; const value: Integer); override;
    function  RestoreDimension(const Name: string): Integer; override;
  published
    property AutoSave: Boolean read FAutoSave write FAutoSave default True;
    property AutoRestore: Boolean read FAutoRestore write FAutoRestore default True;
  end;


implementation

uses
  Forms;

const
  sFormTop = 'FormTop';
  sFormLeft = 'FormLeft';
  sFormWidth = 'FormWidth';
  sFormHeight = 'FormHeight';


{ TccCustomLayoutSaver }

constructor TccCustomLayoutSaver.Create(AOwner: TComponent);
begin
  inherited;

  FLocation := '';
  FSection := '';
  FUseDefaultNames := True;
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

{ TccLayoutSaver }

constructor TccLayoutSaver.Create(AOwner: TComponent);
begin
  inherited;

  FAutoRestore := True;
  FAutoSave := True;
  if not (csDesigning in ComponentState) then begin
    if Assigned((AOwner as TForm).OnCreate) then
      FSaveOnCreate := (AOwner as TForm).OnCreate;
    if Assigned((AOwner as TForm).OnDestroy) then
      FSaveOnDestroy := (AOwner as TForm).OnDestroy;
    (AOwner as TForm).OnCreate := CheckRestoreOnCreate;
    (AOwner as TForm).OnDestroy := CheckSaveOnDestroy;
  end;
end;

procedure TccLayoutSaver.AssignDefaultLocation;
begin
  FLocation := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) +
               ChangeFileExt(ExtractFileName(Application.ExeName), '.INI');
end;

procedure TccLayoutSaver.AssignDefaultSection;
begin
  FSection := (Owner as TForm).Name;
end;

procedure TccLayoutSaver.CheckRestoreOnCreate(Sender: TObject);
begin
  if Assigned(FSaveOnCreate) then
    FSaveOnCreate(Sender);
  if FAutoRestore and (not (csDesigning in ComponentState)) then
    Restore;
end;

procedure TccLayoutSaver.CheckSaveOnDestroy(Sender: TObject);
begin
  if FAutoSave and (not (csDesigning in ComponentState)) then
    Save;
  if Assigned(FSaveOnDestroy) then
    FSaveOnDestroy(Sender);
end;

function TccLayoutSaver.Open: Boolean;
begin
  if (Length(FLocation) = 0) and FUseDefaultNames then
    AssignDefaultLocation;
  if (Length(FSection) = 0) and FUseDefaultNames then
    AssignDefaultSection;

  if Length(FLocation) > 0 then begin
    FIniFile := TIniFile.Create(FLocation);
    Result := True;
  end else
    Result := False;
end;

procedure TccLayoutSaver.Close;
begin
  FIniFile.Free;
end;

procedure TccLayoutSaver.SaveDimension(const Name: string; const value: Integer);
begin
  if Open then begin
    FIniFile.WriteInteger(Section, Name, Value);
    Close;
  end;
end;

function TccLayoutSaver.RestoreDimension(const Name: string): Integer;
begin
  if Open and FIniFile.ValueExists(FSection, Name) then begin
    Result := FIniFile.ReadInteger(FSection, Name, 0);
    Close;
  end else
    raise EccLayoutSaver.Create('Value not available for [' + Name + ']');
end;

procedure TccLayoutSaver.Save;
begin
  SaveDimension(sFormTop, (Owner as TForm).Top);
  SaveDimension(sFormLeft, (Owner as TForm).Left);
  SaveDimension(sFormWidth, (Owner as TForm).Width);
  SaveDimension(sFormHeight, (Owner as TForm).Height);
end;

procedure TccLayoutSaver.Restore;
begin
  try
    (Owner as TForm).Top := RestoreDimension(sFormTop);
  except
    ;
  end;
  try
    (Owner as TForm).Left := RestoreDimension(sFormLeft);
  except
    ;
  end;
  try
    (Owner as TForm).Width := RestoreDimension(sFormWidth);
  except
    ;
  end;
  try
    (Owner as TForm).Height := RestoreDimension(sFormHeight);
  except
    ;
  end;
end;

end.

unit uStrPersistDemoSettings;

interface

uses
  uConfigIniPersist;

type
  [IniClass('StrPersisteDemo')]
  TStrPersisteDemoSettings = class(TStrPersist)
  private
    // file export
    FDescription: string;
    FOption1: Boolean;
    FOption2: Boolean;
    FFirstDate: TDateTime;
    FLastDate: TDateTime;
    FFavNum: Integer;
    FRandomDateStr: string;
    function GetRandomDate: TDateTime;
    procedure SetRandomDate(const Value: TDateTime);
  public
    [IniDefault('Test of the ConfigStrPersist library')]
    property Description: string read FDescription write FDescription;
    [IniDefault('True')]
    property Option1: Boolean read FOption1 write FOption1;
    [IniDefault('False')]
    property Option2: Boolean read FOption2 write FOption2;
    [IniDefault('84')]
    property FavoriteNumber: Integer read FFavNum write FFavNum;
    [IniIgnore]
    property RandomDate: TDateTime read GetRandomDate write SetRandomDate;
    property RandomDateAsString: string read FRandomDateStr write FRandomDateStr;
  end;

implementation

uses
  SysUtils, DateUtils;

{ TStrPersisteDemoSettings }

function TStrPersisteDemoSettings.GetRandomDate: TDateTime;
begin
  if Length(FRandomDateStr) > 0 then
    {$IFDEF CONDITIONALEXPRESSIONS}
      {$IF CompilerVersion >= 23.0}
      Result := ISO8601ToDate(FRandomDateStr, False)
      {$ELSE}
      Result := StrToDate(FRandomDateStr)
      {$IFEND}
    {$ELSE}
    Result := StrToDate(FRandomDateStr)
    {$ENDIF}
  else
    Result := Date;
end;

procedure TStrPersisteDemoSettings.SetRandomDate(const Value: TDateTime);
begin
  {$IFDEF CONDITIONALEXPRESSIONS}
    {$IF CompilerVersion >= 23.0}
    FRandomDateStr := DateToISO8601(Value, False);
    {$ELSE}
    FRandomDateStr := DateToStr(Value);
    {$IFEND}
  {$ELSE}
  FRandomDateStr := DateToStr(Value);
  {$ENDIF}
end;

end.

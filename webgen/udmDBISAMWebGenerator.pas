unit udmDBISAMWebGenerator;
(*
 * as: udmDBISAMWebGenerator
 * by: Cornelius Concepts
 * on: June, 2002
 * to: provide DBISAM database support in a descendent class of TdmCustomWebGenerator
 *
 * This data module expects, as a minimum, the following DBISAM tables (in DBISAM 4):

/* SQL-92 Table Creation Script with DBISAM Extensions */

CREATE TABLE IF NOT EXISTS "General"
(
   "Name" VARCHAR(30) NOT NULL,
   "IntVal" INTEGER,
   "FloatVal" FLOAT,
   "DateVal" DATE,
   "TimeVal" TIME,
   "StrVal" VARCHAR(200),
   "MemoVal" MEMO,
PRIMARY KEY ("RecordID") COMPRESS NONE
LOCALE CODE 0
USER MAJOR VERSION 1
);

CREATE UNIQUE NOCASE INDEX IF NOT EXISTS "Name" ON "General" ("Name") COMPRESS FULL;

CREATE TABLE IF NOT EXISTS "StoredSQL"
(
   "Name" VARCHAR(30) NOT NULL,
   "SQL" BLOB,
PRIMARY KEY ("RecordID") COMPRESS NONE
LOCALE CODE 0
USER MAJOR VERSION 1
);

CREATE UNIQUE NOCASE INDEX IF NOT EXISTS "Name" ON "StoredSQL" ("Name") COMPRESS FULL;

CREATE TABLE IF NOT EXISTS "WebPics"
(
   "Name" VARCHAR(20) NOT NULL,
   "PicFile" VARCHAR(200),
   "Desc" VARCHAR(400),
PRIMARY KEY ("RecordID") COMPRESS NONE
LOCALE CODE 0
USER MAJOR VERSION 1
);

CREATE UNIQUE NOCASE INDEX IF NOT EXISTS "Name" ON "WebPics" ("Name") COMPRESS FULL;

 *
 *)

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  {$IFDEF UseCodeSite} CSIntf, CSIntfEx, {$ENDIF}
  UDMCUSTOMWEBGENERATOR, DBWeb, HTTPApp, Db, DBISAMTb, HTTPProd;

type
  TWebPageProcessEvent = procedure (const FileName: string; const Count, Max: Integer) of Object;

  TdmDBISAMWebGenerator = class(TdmCustomWebGenerator)
    qryWebPics: TDBISAMQuery;
    qryGeneral: TDBISAMQuery;
    qryStoredProcs: TDBISAMQuery;
    qryDynamic: TDBISAMQuery;
    qryWebPicsPicFile: TStringField;
    qryWebPicsDesc: TStringField;
    qryGeneralIntVal: TIntegerField;
    qryGeneralDateVal: TDateField;
    qryGeneralTimeVal: TTimeField;
    qryGeneralMemoVal: TBlobField;
    qryGeneralFloatVal: TFloatField;
    qryStoredProcsname: TStringField;
    qryStoredProcssql: TMemoField;
    qryGeneralStrVal: TStringField;
    procedure DataModuleCreate(Sender: TObject);
    procedure qryAfterOpen(DataSet: TDataSet);
  private
    FDynamicDataSet: TDataSet;
    FAppPath: string;
    FDataDirectory: string;
    FDBISAMDatabaseName: string;
    FDBISAMSessionName: string;
    function GetStoredSelect(const SqlName: string): string;
    function GetGeneralValue(const ValName, TypeName: string): OleVariant;
    procedure GenValNotFoundError(const ValName: string);
    procedure BlobGetText(Sender: TField; var Text: String; DisplayText: Boolean);
    procedure SetDBISAMDatabaseName(const Value: string);
    procedure SetDBISAMSessionName(const Value: string);
  public
    // general purpose values
    function GetStrVal(const ValName: string): string; override;
    function GetMemoVal(const ValName: string): string; override;
    function GetIntVal(const ValName: string): Integer; override;
    function GetFloatVal(const ValName: string): Extended; override;
    function GetDateVal(const ValName: string): TDate; override;
    function GetTimeVal(const ValName: string): TTime; override;
    procedure GetPicFilename(const PicName: string; var PicFilename, PicDescription: string); override;
    // database access
    function GetSQLVal(const SQLStatement, FieldName: string): string; override;
    function GetStoredProcVal(const StoredProcName, FieldName: string): string; override;
    procedure PrepareDynamicDataSet(const DataSetType: TDataSetType; const DataSetText: string); override;
    function  GetDynamicDataSet: TDataSet; override;
    procedure PruneDataSetFields(const KeepFields: TStrings); override;
    procedure OpenDynamicDataSet; override;
    procedure CloseDynamicDataSet; override;
  published
    property AppPath: string read FAppPath;
    property DataDirectory: string read FDataDirectory write FDataDirectory;
    property DBISAMSessionName: string  read FDBISAMSessionName write SetDBISAMSessionName;
    property DBISAMDatabaseName: string read FDBISAMDatabaseName write SetDBISAMDatabaseName;
    // redeclare inherited properties to surface them
    property TemplatePath;
    property UploadPath;
    property FloatFormat;
    property DateFormat;
    property TimeFormat;
    property DateTimeFormat;
    property OnWebDataErrorEvent;
    property OnStartWebPageSearchEvent;
    property OnFinishWebPageSearchEvent;
    property OnStartBatchWebProcessEvent;
    property OnFinishBatchWebProcessEvent;
    property OnStartOneWebProcessEvent;
    property OnFinishOneWebProcessEvent;
  end;


implementation

{$R *.DFM}

procedure TdmDBISAMWebGenerator.DataModuleCreate(Sender: TObject);
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(Self, 'DataModuleCreate');
  {$ENDIF};

  inherited;

  FAppPath := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  // set defaults
  TemplatePath := FAppPath + 'templates';
  UploadPath := FAppPath + 'upload';
  DataDirectory := FAppPath + 'dbisam';

  FDBISAMSessionName := EmptyStr;
  FDBISAMDatabaseName := EmptyStr;
end;

procedure TdmDBISAMWebGenerator.SetDBISAMDatabaseName(const Value: string);
var
  i: Integer;
begin
  FDBISAMDatabaseName := Value;
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TDBISAMDBDataset then
      (Components[i] as TDBISAMDBDataSet).DatabaseName := Value;
end;

procedure TdmDBISAMWebGenerator.SetDBISAMSessionName(const Value: string);
var
  i: Integer;
begin
  FDBISAMSessionName := Value;
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TDBISAMDBDataset then
      (Components[i] as TDBISAMDBDataSet).SessionName := Value;
end;

procedure TdmDBISAMWebGenerator.qryAfterOpen(DataSet: TDataSet);
var
  i: Integer;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(Self, 'qryAfterOpen');
  {$ENDIF};

  // we want to see the text, not just "(MEMO)" as Blob fields return
  for i := 0 to DataSet.FieldCount - 1 do
    if DataSet.Fields[i].DataType = ftMemo then begin
      TBlobField(DataSet.Fields[i]).OnGetText := BlobGetText;
      {$IFDEF UseCodeSite} CodeSite.SendFmtMsg('Field[%s] is a blob type', [DataSet.Fields[i].FieldName]); {$ENDIF};
    end;
end;

procedure TdmDBISAMWebGenerator.BlobGetText(Sender: TField; var Text: String; DisplayText: Boolean);
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(Self, 'BlobGetText');
  {$ENDIF};

  Text := (Sender as TMemoField).AsString;

  {$IFDEF UseCodeSite}
  CodeSite.Send('BlobText', Text);
  {$ENDIF};
end;


procedure TdmDBISAMWebGenerator.CloseDynamicDataSet;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(Self, 'CloseDynamicDataSet');
  {$ENDIF};

  if FDynamicDataSet <> nil then
    qryDynamic.Close;
end;

procedure TdmDBISAMWebGenerator.GenValNotFoundError(const ValName: string);
begin
  RaiseWebDataError(Format('Name value not found: [%s]', [ValName]));
end;

function TdmDBISAMWebGenerator.GetDateVal(const ValName: string): TDate;
begin
  Result := GetGeneralValue(ValName, 'Date');
end;

function TdmDBISAMWebGenerator.GetDynamicDataSet: TDataSet;
begin
  Result := FDynamicDataSet;
end;

function TdmDBISAMWebGenerator.GetFloatVal(const ValName: string): Extended;
begin
  Result := GetGeneralValue(ValName, 'Float');
end;

function TdmDBISAMWebGenerator.GetGeneralValue(const ValName, TypeName: string): OleVariant;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(Self, 'GetGeneralValue');
  CodeSite.Send('Value Name', ValName);
  CodeSite.Send('Type', TypeName);
  {$ENDIF};

//  Assert(qryGeneral.Database <> nil, 'Programmer Error!  The "General" query does not have a DBISAM Database component attached.');
//  Assert(qryGeneral.DBSession <> nil, 'Programmer Error!  The "General" query does not have a DBISAM Session component attached.');

  qryGeneral.Params.ParamByName('Name').Value := ValName;
  qryGeneral.Open;
  try
    if qryGeneral.Active and (qryGeneral.RecordCount > 0) and
       (not qryGeneral.FieldByName(TypeName + 'Val').IsNull) then
      Result := qryGeneral.FieldByName(TypeName + 'Val').Value
    else begin
      GenValNotFoundError(ValName);
      if (TypeName = 'String') or (TypeName = 'Memo') then
        Result := EmptyStr
      else
        Result := 0;
    end;
  finally
    qryGeneral.Close;
  end;

  {$IFDEF UseCodeSite}
  CodeSite.Send('Result', Widestring(Result));
  {$ENDIF};
end;

function TdmDBISAMWebGenerator.GetIntVal(const ValName: string): Integer;
begin
  Result := GetGeneralValue(ValName, 'Int');
end;

procedure TdmDBISAMWebGenerator.GetPicFilename(const PicName: string; var PicFilename, PicDescription: string);
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(Self, 'GetPicFilename');
  CodeSite.Send('PicName', PicName);
  {$ENDIF};

  Assert(qryWebPics.Database <> nil, 'Programmer Error!  The "WebPics" query does not have a DBISAM Database component attached.');
  Assert(qryWebPics.DBSession <> nil, 'Programmer Error!  The "WebPics" query does not have a DBISAM Session component attached.');

  qryWebPics.Params.ParamByName('Name').Value := PicName;
  qryWebPics.Open;
  try
    if qryWebPics.Active and (qryWebPics.RecordCount > 0) then begin
      PicFileName := qryWebPicsPicFile.AsString;
      PicDescription := qryWebPicsDesc.AsString;
    end else begin
      // not found, so just clear result fields
      PicFilename := EmptyStr;
      PicDescription := EmptyStr;
    end;
  finally
    qryWebPics.Close;
  end;

  {$IFDEF UseCodeSite}
  CodeSite.Send('PicFilename', PicFilename);
  CodeSite.Send('Description', PicDescription);
  {$ENDIF};
end;

function TdmDBISAMWebGenerator.GetSQLVal(const SQLStatement, FieldName: string): string;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(Self, 'GetSQLVal');
  CodeSite.Send('SQL Statement', SQLStatement);
  CodeSite.Send('Field name', FieldName);
  {$ENDIF};

  Assert(qryDynamic.Database <> nil, 'Programmer Error!  The "Dynamic" query does not have a DBISAM Database component attached.');
  Assert(qryDynamic.DBSession <> nil, 'Programmer Error!  The "Dynamic" query does not have a DBISAM Session component attached.');

  qryDynamic.Close; // fail-safe

  if UpperCase(Copy(Trim(SQLStatement), 1, 6)) <> 'SELECT' then
    raise EWebDataError.Create('DBISAM SQL ERROR: SQL Statement is not a "SELECT" statement.');

  qryDynamic.SQL.Text := SQLStatement;
  qryDynamic.Open;
  try
    Result := qryDynamic.Fields.FieldByName(FieldName).AsString;
  finally
    qryDynamic.Close;
  end;

  {$IFDEF UseCodeSite}
  CodeSite.Send('result', Result);
  {$ENDIF};
end;

function TdmDBISAMWebGenerator.GetStoredProcVal(const StoredProcName, FieldName: string): string;
var
  SqlStatement: string;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(Self, 'GetStoredProcVal');
  CodeSite.Send('StoredProcName', StoredProcName);
  CodeSite.Send('FieldName', FieldName);
  {$ENDIF};

  Assert(qryDynamic.Database <> nil, 'Programmer Error!  The "Dynamic" query does not have a DBISAM Database component attached.');
  Assert(qryDynamic.DBSession <> nil, 'Programmer Error!  The "Dynamic" query does not have a DBISAM Session component attached.');

  SqlStatement := GetStoredSelect(StoredProcName);
  if Length(SqlStatement) > 0 then
    Result := GetSQLVal(SqlStatement, FieldName)
  else
    Result := '';

  {$IFDEF UseCodeSite}
  CodeSite.Send('result', WideString(Result));
  {$ENDIF};
end;

function TdmDBISAMWebGenerator.GetStoredSelect(const SqlName: string): string;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(Self, 'GetStoredSelect');
  CodeSite.Send('SqlName', SqlName);
  {$ENDIF};

//  Assert(qryStoredProcs.DatabaseName = EmptyStr, 'Programmer Error!  The "StoredProcs" query does not have a DBISAM Database component attached.');
//  Assert(qryStoredProcs.SessionName = EmptyStr, 'Programmer Error!  The "StoredProcs" query does not have a DBISAM Session component attached.');

  qryStoredProcs.ParamByName('name').Value := SqlName;
  qryStoredProcs.Open;
  try
    Result := qryStoredProcsSql.AsString;
  finally
    qryStoredProcs.Close;
  end;

  {$IFDEF UseCodeSite}
  CodeSite.Send('Result', Result);
  {$ENDIF};
end;

function TdmDBISAMWebGenerator.GetStrVal(const ValName: string): string;
begin
  Result := GetGeneralValue(ValName, 'Str');
end;

function TdmDBISAMWebGenerator.GetMemoVal(const ValName: string): string;
begin
  Result := GetGeneralValue(ValName, 'Memo');
end;

function TdmDBISAMWebGenerator.GetTimeVal(const ValName: string): TTime;
begin
  Result := GetGeneralValue(ValName, 'Time');
end;

procedure TdmDBISAMWebGenerator.OpenDynamicDataSet;
begin
  {$IFDEF UseCodeSite}
  CodeSite.TraceMethod(Self, 'OpenDynamicDataSet');
  {$ENDIF};

  if FDynamicDataSet <> nil then
    qryDynamic.Open;
end;

procedure TdmDBISAMWebGenerator.PrepareDynamicDataSet(const DataSetType: TDataSetType; const DataSetText: string);
var
  SqlStatement: string;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(Self, 'PrepareDynamicDataSet');
  CodeSite.SendEnum('DataSetType', TypeInfo(TDataSetType), Ord(DataSetType));
  CodeSite.Send('DataSetText', DataSetText);
  {$ENDIF};

//  Assert(qryDynamic.Database <> nil, 'Programmer Error!  The "Dynamic" query does not have a DBISAM Database component attached.');
//  Assert(qryDynamic.DBSession <> nil, 'Programmer Error!  The "Dynamic" query does not have a DBISAM Session component attached.');

  qryDynamic.Close; // fail-safe

  if DataSetType = dstSQL then begin
    qryDynamic.SQL.Text := DataSetText;
    FDynamicDataSet := qryDynamic;
  end else if DataSetType = dstStoredProcedure then begin
    SqlStatement := GetStoredSelect(DataSetText);
    if Length(SqlStatement) > 0 then begin
      qryDynamic.SQL.Text := SqlStatement;
      FDynamicDataSet := qryDynamic;
    end else
      FDynamicDataSet := nil;
  end else
    FDynamicDataSet := nil;
end;

procedure TdmDBISAMWebGenerator.PruneDataSetFields(const KeepFields: TStrings);
{
 Because the dataset may include more fields than are needed for a certain
 display, such as a table, this function will remove all but the given fields
 from the the field list in the dynamic dataset.
}
var
  i: Integer;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(Self, 'PruneDataSetFields');
  CodeSite.Send('current field count', FDynamicDataSet.Fields.Count);
  CodeSite.SendStringList('KeepFields', Keepfields);
  {$ENDIF};

  i := 0;
  while i < FDynamicDataSet.Fields.Count do begin
    {$IFDEF UseCodeSite}
    CodeSite.Send('checking field', FDynamicDataSet.Fields[i].FieldName);
    {$ENDIF};
    if KeepFields.IndexOf(FDynamicDataSet.Fields[i].FieldName) = -1 then begin
      {$IFDEF UseCodeSite}
      CodeSite.Send('removing field', FDynamicDataSet.Fields[i].FieldName);
      {$ENDIF};
      FDynamicDataSet.Fields.Remove(FDynamicDataSet.Fields[i]);
    end else
      Inc(i);
  end;

  {$IFDEF UseCodeSite}
  CodeSite.Send('pruned field count', FDynamicDataSet.Fields.Count);
  codeSite.SendStringList('pruned field list', FDynamicDataSet.FieldList);
  {$ENDIF};
end;

end.

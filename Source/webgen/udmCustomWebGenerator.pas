unit udmCustomWebGenerator;
(* as: udmCustomWebGenerator
 * by: Cornelius Concepts
 * on: June, 2002
 * to: provide generic web page generation for WebBroker;
       updated February, 2004

This class is designed to be implemented in a descendant class to provide
database lookup, or at least value substitution for the abstract methods
below.  It will process an HTML file with the following special tags
(upper case words are the required reserved words):
  <#MEMO NAME=value>
  <#STRING NAME=value>
  <#INT NAME=value>
  <#HEX NAME=value> (returns the INT value in hex form prefixed with # in a string)
  <#FLOAT NAME=value>
  <#DATE NAME=value>
  <#TIME NAME=value>
  <#SQL SQL=value FIELD=value>
  <#STOREDPROC NAME=value FIELD=value>
  <#SPACEOUT TYPE=STRING NAME=value>
  <#SPACEOUT TYPE=SQL SQL=value FIELD=name>
  <#SPACEOUT TYPE=STOREDPROC NAME=value FIELD=value>
  <#INCLUDE FILE=filename>

  <#LINKLIST TYPE=SQL|STOREDPROC NAME=value PRETEXT=value TARGET=value CLASS=value>
  The LinkList tag will build a list of items from the three fields expected in
  the dataset: Link, DisplayName, and Filler.  Link is just a URL. DisplayName is
  what is displayed between the <A HREF...> and the closing </a>. Filler is what
  goes after </a> and before the next <A HREF...> but is not appended after the
  last list item. PRETEXT is what is prepended to each link (before the HREF) for
  example if you want a bullet .GIF. TARGET is the target of the HREF link.
  CLASS is the CSS class name that will be used inside the HREF tag.
  This tag is great for building a set of navigation links and is flexible enough
  to allow a single set of simple names and links in a table that, with the tags
  here, can format the links for either a vertical navigation bar or one typically
  found at the bottom of a page.

  <#LIST TYPE=SQL|STOREDPROC NAME=value>
  The List tag will build a list of items from the two fields expected in
  the dataset: Text, and Filler.  "Text" is any HTML text. "Filler" is what goes
  between each set of "Text", but only between the items--never before the first
  one and never after the last one.  It's good when you want to build a list of
  items that have either pagination or some other form of separater between, but
  don't want to use <UL>, <OL>, or tables.

The standard Delphi WebBroker tags can be used in an expanded way as well:
  <#IMAGE NAME=value>   This takes NAME and returns a filename and
                        description for use in the HTML Image tag.
  <#TABLE ALIGN=value WIDTH=value BORDER=value BGCOLOR=value
    COLHEADERS=ON|OFF CUSTOM=value CELLPADDING=value CELLSPACING=value
    CELLFONTCOLOR=value CELLFONTFACE=value CELLFONTSIZE=value CELLCUSTOM=value
    SQL=value|STOREDPROC=value FIELDS=value TDVALIGN=values TDALIGN=values>
  The #TABLE tag must have either the SQL parameter or the STOREDPROC parameter
  so that the DataSetTableProducer knows where to get its data.  The DataSet
  must be a TDataSet descendent. All other parameters listed above are optional.
  The FIELDS value is a comma-separated list of fields to keep in the dataset
    --all others are removed before the table is built.
  The TDVAlign and TDAlign tags are comma-separated lists of HTML-VAlign and
  HTML-Align tags that match the number of columns in the table.
*)

interface

uses
  SysUtils, Controls, Classes, DB, Forms,
  DBWeb, HTTPApp, HTTPProd, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdExplicitTLSClientServerBase, IdFTP;

type
  EWebDataError = class(Exception)
  end;

  // used by the DataSetTableProducerFormatCell method
  TDataSetType = (dstNone, dstStoredProcedure, dstSQL);

  // event handler types
  TOnWebDataErrorEvent = procedure (const Msg: string) of Object;
  TWebPageStartProcessEvent = procedure (const FileName: string;
                              const Count, Max: Integer; var Skip: Boolean) of Object;
  TWebPageEndProcessEvent = procedure (const FileName: string;
                            const Count, Max: Integer) of Object;
  TWebPageSearchEvent = procedure of Object;
  TWebTagFoundEvent = procedure (HTMLTag: string; TagParams: TStrings) of Object;
  TWebTagReplaceEvent = procedure (HTMLTag: string; ReplaceTag: string) of Object;

  // THE CLASS!
  TdmCustomWebGenerator = class(TDataModule)
    PageProducer: TPageProducer;
    DataSetTableProducer: TDataSetTableProducer;
    procedure PageProducerHTMLTag(Sender: TObject; Tag: TTag; const TagString: String;
                     TagParams: TStrings; var ReplaceText: String); virtual;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataSetTableProducerFormatCell(Sender: TObject; CellRow,
      CellColumn: Integer; var BgColor: THTMLBgColor;
      var Align: THTMLAlign; var VAlign: THTMLVAlign; var CustomAttrs,
      CellData: String);
  private
    FAppPath: string;
    FHeaderCellSuppress: Boolean;
    FDataCellCustom: string;
    FDataCellFontFace: string;
    FDataCellFontColor: string;
    FDataCellFontSize: Integer;
    FDataSetType: TDataSetType;
    FDataSetText: string;
    FTableCellTDAlignList: TStringList;
    FTableCellTDVAlignList: TStringList;
    FTableCdellTDClassList: TStringList;
    FTableCdellTDWidthList: TStringList;
    FUploadPath: string;
    FTemplatePath: string;
    FFloatFormat: string;
    FDateFormat: string;
    FTimeFormat: string;
    FDateTimeFormat: string;
    FCurrWebFilename: string;
    FCurrWebFileNum, FMaxWebFiles: Integer;
    FReprocess: Boolean;
    FTemplateFileMask: string;
    FUploadFileMask: string;
    FOnWebDataErrorEvent: TOnWebDataErrorEvent;
    FOnStartBatchWebProcessEvent: TNotifyEvent;
    FOnFinishBatchWebProcessEvent: TNotifyEvent;
    FOnStartOneWebProcessEvent: TWebPageStartProcessEvent;
    FOnFinishOneWebProcessEvent: TWebPageEndProcessEvent;
    FOnStartWebPageSearchEvent: TWebPageSearchEvent;
    FOnFinishWebPageSearchEvent: TWebPageSearchEvent;
    FOnWebTagFoundEvent: TWebTagFoundEvent;
    FOnWebTagReplaceEvent: TWebTagReplaceEvent;
    FOnStartOneWebUploadEvent: TWebPageStartProcessEvent;
    FOnFinishOneWebUploadEvent: TWebPageEndProcessEvent;
    FOnStartBatchWebUploadingEvent: TNotifyEvent;
    FOnFinishBatchWebUploadingEvent: TNotifyEvent;
    function EnsureIntVal(const TagValue: string): Integer;
    function EnsurePositiveInt(const TagValue: string): Integer;
    function GetAlignValue(const TagValue: string): THTMLAlign;
    function GetVAlignValue(const TagValue: string): THTMLVAlign;
    function GetSpacedText(const Value: string): string;
    // event handlers
    procedure DoStartBatchProcessingEvent;
    procedure DoFinishBatchProcessingEvent;
    procedure DoStartOneProcessEvent(var Skip: Boolean);
    procedure DoFinishOneProcessEvent;
    procedure DoStartWebPageSearchEvent;
    procedure DoFinishWebPageSearchEvent;
    procedure DoWebTagFoundEvent(HTMLTag: string; TagParams: TStrings);
    procedure DoWebTagReplaceEvent(HTMLTag: string; ReplaceTag: string);
    procedure DoStartOneUploadEvent(var Skip: Boolean);
    procedure DoFinishOneUploadEvent;
    procedure DoStartBatchUploadingEvent;
    procedure DoFinishBatchUploadingEvent;
  protected
    function  GetTableContent(const TagParams: TStrings): string; virtual;
    function  GetLinkListContent(const TagParams: TStrings): string; virtual;
    function  GetListContent(const TagParams: TStrings): string; virtual;
    function  GetIncludeContent(const IncFilename: string): string; virtual;
    function  GetTemplatePath: string; virtual;
    function  GetUploadPath: string; virtual;
    procedure SetTemplatePath(const Value: string); virtual;
    procedure SetUploadPath(const Value: string); virtual;
    // database access
    function  GetSQLVal(const SQLStatement, FieldName: string): string; virtual; abstract;
    function  GetStoredProcVal(const StoredProcName, FieldName: string): string; virtual; abstract;
    procedure PrepareDynamicDataSet(const DataSetType: TDataSetType;
                                const DataSetText: string); virtual; abstract;
    function  GetDynamicDataSet: TDataSet; virtual; abstract;
    procedure PruneDataSetFields(const KeepFields: TStrings); virtual; abstract;
    procedure OpenDynamicDataSet; virtual; abstract;
    procedure CloseDynamicDataSet; virtual; abstract;
    // general purpose values
    function  GetStrVal(const ValName: string): string; virtual; abstract;
    function  GetMemoVal(const ValName: string): string; virtual; abstract;
    function  GetIntVal(const ValName: string): Integer; virtual; abstract;
    function  GetHexVal(const ValName: string): string; virtual;
    function  GetFloatVal(const ValName: string): Extended; virtual; abstract;
    function  GetDateVal(const ValName: string): TDate; virtual; abstract;
    function  GetTimeVal(const ValName: string): TTime; virtual; abstract;
    procedure GetPicFilename(const PicName: string; var PicFilename,
                                PicDescription: string); virtual; abstract;
    procedure UploadOneFileToWebServer(const Filename: string); virtual; abstract;
  public
    // main processor
    procedure ProcessOneFile(const SrcFilename, DestFilename: string);
    // errors
    procedure RaiseWebDataError(const Msg: string); virtual;
    // the main method called in applications
    procedure ProcessFiles(FileList: TStringList);
    // alternatively, this method automatically does all files in the TemplatePath directory
    procedure ProcessAllFiles;

    // upload functions
    procedure UploadOneWebFile(const Filename: string);
    procedure UploadWebFiles(FileList: TStringList);
    procedure UploadAllWebFiles;
  published
    // field properties
    property AppPath: string read FAppPath;
    property TemplatePath: string read GetTemplatePath write SetTemplatePath;
    property UploadPath: string read GetUploadPath write SetUploadPath;
    property TemplateFileMask: string read FTemplateFileMask write FTemplateFileMask;
    property UploadfileMask: string read FUploadfileMask write FUploadfileMask;
    property FloatFormat: string read FFloatFormat write FFloatFormat;
    property DateFormat: string read FDateFormat write FDateFormat;
    property TimeFormat: string read FTimeFormat write FTimeFormat;
    property DateTimeFormat: string read FDateTimeFormat write FDateTimeFormat;
    property MaxWebFiles: Integer read FMaxWebFiles;
    // events
    property OnWebDataErrorEvent: TOnWebDataErrorEvent read FOnWebDataErrorEvent write FOnWebDataErrorEvent;
    property OnStartWebPageSearchEvent: TWebPageSearchEvent read FOnStartWebPageSearchEvent write FOnStartWebPageSearchEvent;
    property OnFinishWebPageSearchEvent: TWebPageSearchEvent read FOnFinishWebPageSearchEvent write FOnFinishWebPageSearchEvent;
    property OnStartBatchWebProcessEvent: TNotifyEvent read FOnStartBatchWebProcessEvent write FOnStartBatchWebProcessEvent;
    property OnFinishBatchWebProcessEvent: TNotifyEvent read FOnFinishBatchWebProcessEvent write FOnFinishBatchWebProcessEvent;
    property OnStartOneWebProcessEvent: TWebPageStartProcessEvent read FOnStartOneWebProcessEvent write FOnStartOneWebProcessEvent;
    property OnFinishOneWebProcessEvent: TWebPageEndProcessEvent read FOnFinishOneWebProcessEvent write FOnFinishOneWebProcessEvent;
    property OnWebTagFoundEvent: TWebTagFoundEvent read FOnWebTagFoundEvent write FOnWebTagFoundEvent;
    property OnWebTagReplaceEvent: TWebTagReplaceEvent read FOnWebTagReplaceEvent write FOnWebTagReplaceEvent;
    property OnStartOneWebUploadEvent: TWebPageStartProcessEvent read FOnStartOneWebUploadEvent write FOnStartOneWebUploadEvent;
    property OnFinishOneWebUploadEvent: TWebPageEndProcessEvent read FOnFinishOneWebUploadEvent write FOnFinishOneWebUploadEvent;
    property OnStartBatchWebUploadingEvent: TNotifyEvent read FOnStartBatchWebUploadingEvent write FOnStartBatchWebUploadingEvent;
    property OnFinishBatchWebUploadingEvent: TNotifyEvent read FOnFinishBatchWebUploadingEvent write FOnFinishBatchWebUploadingEvent;
  end;


implementation

uses
  {$IFDEF UseCodeSite}
  CSIntf, CSIntfEx,
  {$ENDIF}
  Dialogs;

{$R *.dfm}

const
  TAG_NAME = 'NAME';
  TAG_SQL = 'SQL';
  TAG_FIELD = 'FIELD';
  TAG_TYPE = 'TYPE';
  TAG_VALUE = 'VALUE';
  TAGSTR_MEMO = 'MEMO';
  TAGSTR_STRING = 'STRING';
  TAGSTR_INT = 'INT';
  TAGSTR_HEX = 'HEX';
  TAGSTR_FLOAT = 'FLOAT';
  TAGSTR_DATE = 'DATE';
  TAGSTR_TIME = 'TIME';
  TAGSTR_SPACEOUT = 'SPACEOUT';
  TAGSTR_INCLUDE = 'INCLUDE';
  TAGSTR_FILE = 'FILE';
  TAGSTR_LINKLIST = 'LINKLIST';
  TAGSTR_LIST = 'LIST';
  TAGSTR_STOREDPROC = 'STOREDPROC';
  TAGSTR_SQL = 'SQL';
  TAGSTR_FIELDS = 'FIELDS';
  TAGSTR_TDALIGN = 'TDALIGN';
  TAGSTR_TDVALIGN = 'TDVALIGN';
  TAGSTR_TDCLASS = 'TDCLASS';
  TAGSTR_TDWIDTH = 'TDWIDTH';

{ TdmCustomWebGenerator }

procedure TdmCustomWebGenerator.DataModuleCreate(Sender: TObject);
// setup defaults
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'DataModuleCreate');
  {$ENDIF}

  FAppPath := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  TemplatePath := AppPath + 'templates';
  UploadPath := AppPath + 'upload';

  FloatFormat := 'g';
  DateFormat := 'mm/dd/yyyy';
  TimeFormat := 'hh:nn:ss';
  DateTimeFormat := 'mm/dd/yyyy hh:nn:ss';
  TemplateFileMask := '*.*';
  UploadFileMask := '*.*';
end;

procedure TdmCustomWebGenerator.RaiseWebDataError(const Msg: string);
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'RaiseWebDataError');
  CodeSite.Send('msg', msg);
  {$ENDIF}

  if Assigned(FOnWebDataErrorEvent) then
    FOnWebDataErrorEvent(Msg)
  else
    raise EWebDataError.Create(Msg);
end;

function TdmCustomWebGenerator.GetTemplatePath: string;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'GetTemplatePath');
  {$ENDIF}

  Result := IncludeTrailingPathDelimiter(FTemplatePath);

  {$IFDEF UseCodeSite}
  CodeSite.Send('Result', Result);
  {$ENDIF}
end;

function TdmCustomWebGenerator.GetUploadPath: string;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'GetUploadPath');
  {$ENDIF}

  Result := IncludeTrailingPathDelimiter(FUploadPath);

  {$IFDEF UseCodeSite}
  CodeSite.Send('Result', Result);
  {$ENDIF}
end;

procedure TdmCustomWebGenerator.SetTemplatePath(const Value: string);
// set-property method; ensures a trailing backslash
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'SetTemplatePath');
  CodeSite.Send('value', value);
  {$ENDIF}

  FTemplatePath := IncludeTrailingPathDelimiter(Value);
end;

procedure TdmCustomWebGenerator.SetUploadPath(const Value: string);
// set-property method; ensures a trailing backslash
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'SetUploadPath');
  CodeSite.Send('value', value);
  {$ENDIF}

  FUploadPath := IncludeTrailingPathDelimiter(Value);
end;

function TdmCustomWebGenerator.GetHexVal(const ValName: string): string;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'GetHexVal');
  CodeSite.Send('valname', valname);
  {$ENDIF}

  Result := Format('%.6x', [GetIntVal(ValName)]);
  Result := '#' + Copy(Result, 5, 2) + Copy(Result, 3, 2) + Copy(Result, 1, 2);

  {$IFDEF UseCodeSite}
  CodeSite.Send('Result', Result);
  {$ENDIF}
end;

function TdmCustomWebGenerator.EnsureIntVal(const TagValue: string): Integer;
// make sure the string value for this parameter is an integer
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'EnsureIntVal');
  CodeSite.Send('TagValue', TagValue);
  {$ENDIF}
  try
    Result := StrToInt(TagValue);
  except
    on e: EConvertError do
      Result := 0;
  end;

  {$IFDEF UseCodeSite}
  CodeSite.SendInteger('Result', Result);
  {$ENDIF}
end;

function TdmCustomWebGenerator.EnsurePositiveInt(const TagValue: string): Integer;
// make sure the string value for this parameter is a non-negative integer
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'EnsurePositiveInt');
  {$ENDIF}

  Result := Abs(EnsureIntVal(TagValue));

  {$IFDEF UseCodeSite}
  CodeSite.SendInteger('Result', Result);
  {$ENDIF}
end;

function TdmCustomWebGenerator.GetAlignValue(const TagValue: string): THTMLAlign;
// sets the alignment property in the table producer
var
  s: string;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'GetAlignValue');
  CodeSite.Send('TagValue', TagValue);
  {$ENDIF}

  s := UpperCase(TagValue);
  if s = 'LEFT' then
    Result := haLeft
  else if s = 'RIGHT' then
    Result := haRight
  else if s = 'CENTER' then
    Result := haCenter
  else
    Result := haDefault;

  {$IFDEF UseCodeSite}
  CodeSite.SendEnum('Result', TypeInfo(THTMLAlign), Ord(Result));
  {$ENDIF}
end;

function TdmCustomWebGenerator.GetVAlignValue(const TagValue: string): THTMLVAlign;
// sets the v-alignment property in the table producer
var
  s: string;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'GetVAlignValue');
  CodeSite.Send('TagValue', TagValue);
  {$ENDIF}

  s := UpperCase(TagValue);
  if s = 'TOP' then
    Result := haTop
  else if s = 'MIDDLE' then
    Result := haMiddle
  else if s = 'BOTTOM' then
    Result := haBottom
  else if s = 'BASELINE' then
    Result := haBaseline
  else
    Result := havDefault;

  {$IFDEF UseCodeSite}
  CodeSite.SendEnum('Result', TypeInfo(THTMLAlign), Ord(Result));
  {$ENDIF}
end;

function TdmCustomWebGenerator.GetSpacedText(const Value: string): string;
// returns the given string with HTML spaces (&nbsp;) between every character
var
  i: Integer;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'GetSpacedText');
  CodeSite.Send('Value', Value);
  {$ENDIF}

  Result := EmptyStr;
  for i := 1 to Length(Value) - 1 do
    Result := Result + Value[i] + '&nbsp;';
  if Length(Value) > 0 then
    Result := Result + Value[Length(Value)];  // get the last one, but w/o the extra space char at the end

  {$IFDEF UseCodeSite}
  CodeSite.Send('Result', Result);
  {$ENDIF}
end;

function TdmCustomWebGenerator.GetTableContent(const TagParams: TStrings): string;
// returns a possibly huge string with the complete HTML specification for a table (attributes, data, everything)
const
  STR_ALIGN = 'ALIGN';
  STR_WIDTH = 'WIDTH';
  STR_BORDER = 'BORDER';
  STR_BGCOLOR = 'BGCOLOR';
  STR_CUSTOM = 'CUSTOM';
  STR_COLHEADERS = 'COLHEADERS';
  STR_CELLCUSTOM = 'CELLCUSTOM';
  STR_CELLPADDING = 'CELLPADDING';
  STR_CELLSPACING = 'CELLSPACING';
  STR_CELLFONTCOLOR = 'CELLFONTCOLOR';
  STR_CELLFONTFACE = 'CELLFONTFACE';
  STR_CELLFONTSIZE = 'CELLFONTSIZE';
var
  i: Integer;
  s: string;
  FieldList: TStringList;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'GetTableContent');
  CodeSite.SendStringList('TagParams', TagParams);
  {$ENDIF}

  FieldList := TStringList.Create;
  FTableCellTDAlignList := TStringList.Create;
  FTableCellTDVAlignList := TStringList.Create;
  FTableCdellTDClassList := TStringList.Create;
  FTableCdellTDWidthList := TStringList.Create;
  Result := EmptyStr;

  // set defaults
  with DataSetTableProducer do begin
    TableAttributes.Align := haDefault;
    TableAttributes.BgColor := EmptyStr;
    TableAttributes.Border := 0;
    TableAttributes.CellPadding := 0;
    TableAttributes.CellSpacing := 0;
    TableAttributes.Custom := EmptyStr;
    TableAttributes.Width := 0;
    FHeaderCellSuppress := False;
    FDataCellFontFace := EmptyStr;
    FDataCellFontColor := EmptyStr;
    FDataCellFontSize := 0;
    FDataCellCustom := EmptyStr;
    FDataSetType := dstNone;
    FDataSetText := EmptyStr;

    // now override with any parameters found
    for i := 0 to TagParams.Count - 1 do begin
      s := UpperCase(TagParams.Names[i]);
      if s = STR_BGCOLOR then
        TableAttributes.BgColor := TagParams.Values[STR_BGCOLOR]
      else if s = STR_BORDER then
        TableAttributes.Border := EnsurePositiveInt(TagParams.Values[STR_BORDER])
      else if s = STR_CELLSPACING then
        TableAttributes.CellSpacing := EnsurePositiveInt(TagParams.Values[STR_CELLSPACING])
      else if s = STR_CELLPADDING then
        TableAttributes.CellPadding := EnsurePositiveInt(TagParams.Values[STR_CELLPADDING])
      else if s = STR_WIDTH then
        TableAttributes.Width := EnsurePositiveInt(TagParams.Values[STR_WIDTH])
      else if s = STR_ALIGN then
        TableAttributes.Align := GetAlignValue(TagParams.Values[STR_ALIGN])
      else if s = STR_CUSTOM then
        TableAttributes.Custom := TagParams.Values[STR_CUSTOM]
      else if s = STR_CELLFONTFACE then
        FDataCellFontFace := TagParams.Values[STR_CELLFONTFACE]
      else if s = STR_CELLFONTCOLOR then
        FDataCellFontColor := TagParams.Values[STR_CELLFONTCOLOR]
      else if s = STR_CELLFONTSIZE then
        FDataCellFontSize := EnsureIntVal(TagParams.Values[STR_CELLFONTSIZE])
      else if s = STR_COLHEADERS then
        FHeaderCellSuppress := UpperCase(TagParams.Values[STR_COLHEADERS]) = 'OFF'
      else if s = STR_CELLCUSTOM then
        FDataCellCustom := TagParams.Values[STR_CELLCUSTOM]
      else if s = TAGSTR_STOREDPROC then begin
        FDataSetType := dstStoredProcedure;
        FDataSetText := TagParams.Values[TAGSTR_STOREDPROC];
      end else if s = TAGSTR_SQL then begin
        FDataSetType := dstSQL;
        FDataSetText := TagParams.Values[TAGSTR_SQL];
      end else if s = TAGSTR_FIELDS then
        FieldList.CommaText := TagParams.Values[TAGSTR_FIELDS]
      else if s = TAGSTR_TDALIGN then
        FTableCellTDAlignList.CommaText := TagParams.Values[TAGSTR_TDAlign]
      else if s = TAGSTR_TDVALIGN then
        FTableCellTDVAlignList.CommaText := TagParams.Values[TAGSTR_TDVAlign]
      else if s = TAGSTR_TDCLASS then
        FTableCdellTDClassList.CommaText := TagParams.Values[TAGSTR_TDCLASS]
      else if s = TAGSTR_TDWIDTH then
        FTableCdellTDWidthList.CommaText := TagParams.Values[TAGSTR_TDWIDTH];
    end;

    if FDataSetType = dstNone then
      // no dataset--just return the table
      Result := Content
    else begin
      // set up the data set
      PrepareDynamicDataSet(FDataSetType, FDataSetText);
      OpenDynamicDataSet;

      PruneDataSetFields(FieldList);

      DataSet := GetDynamicDataSet;
      if DataSet = nil then
        RaiseWebDataError('GetTableContent: GetDynamicDataSet returned nil, DataSetText:' + FDataSetText);
      try
        // now that everything's all set up for our custom table output, call the Content method.
        Result := Content;
        DataSet := nil;
      finally
        CloseDynamicDataSet;
        FieldList.Free;
      end;
    end;
  end;

  {$IFDEF UseCodeSite}
  CodeSite.Send('Result', Result);
  {$ENDIF}
end;

procedure TdmCustomWebGenerator.DataSetTableProducerFormatCell(
  Sender: TObject; CellRow, CellColumn: Integer; var BgColor: THTMLBgColor;
  var Align: THTMLAlign; var VAlign: THTMLVAlign; var CustomAttrs,
  CellData: String);
// formats cells on-the-fly
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'DataSetTableProducerFormatCell');
  CodeSite.SendInteger('CellRow', CellRow);
  CodeSite.SendInteger('CellColumn', CellColumn);
  CodeSite.SendString('BgColor', BgColor);
  CodeSite.SendEnum('Align', TypeInfo(THTMLAlign), Ord(Align));
  CodeSite.SendEnum('VAlign', TypeInfo(THTMLVAlign), Ord(VAlign));
  CodeSite.Send('CustomAttrs', CustomAttrs);
  CodeSite.Send('CellData', CellData);
  {$ENDIF}

  // font color
  if Length(FDataCellFontColor) > 0 then
    CellData := Format('<FONT Color=%s>%s</FONT>', [FDataCellFontColor, CellData]);
  // font face
  if Length(FDataCellFontFace) > 0 then
    CellData := Format('<FONT Face=%s>%s</FONT>', [FDataCellFontFace, CellData]);
  // font size
  if FDataCellFontSize <> 0 then
    CellData := Format('<FONT Size=%d>%s</FONT>', [FDataCellFontSize, CellData]);
  // custom alignment
  if FTableCellTDAlignList.Count > CellColumn then
    Align := GetAlignValue(FTableCellTDAlignList[CellColumn]);
  // custom verticle alignmnet
  if FTableCellTDVAlignList.Count > CellColumn then
    VAlign := GetVAlignValue(FTableCellTDVAlignList[CellColumn]);
  // custom attributes of table cell
  if Length(FDataCellCustom) > 0 then
    CustomAttrs := FDataCellCustom;
  // custom width per cell
  if FTableCdellTDWidthList.Count > CellColumn then
    CustomAttrs := CustomAttrs + ' width="' + FTableCdellTDWidthList[CellColumn] + '"';
  // custom class per cell
  if FTableCdellTDClassList.Count > CellColumn then
    CustomAttrs := CustomAttrs + ' class="' + FTableCdellTDClassList[CellColumn] + '"';

  if (CellRow = 0) and FHeaderCellSuppress then
    CellData := EmptyStr;

  {$IFDEF UseCodeSite}
  CodeSite.Send('exit values...');
  CodeSite.SendString('BgColor', BgColor);
  CodeSite.SendEnum('Align', TypeInfo(THTMLAlign), Ord(Align));
  CodeSite.SendEnum('VAlign', TypeInfo(THTMLVAlign), Ord(VAlign));
  CodeSite.Send('CustomAttrs', CustomAttrs);
  CodeSite.Send('CellData', CellData);
  {$ENDIF}
end;

function TdmCustomWebGenerator.GetLinkListContent(const TagParams: TStrings): string;
const
  STR_LINK = 'LINK';
  STR_NAME = 'DISPLAYNAME';
  STR_CLASS = 'CLASS';
  STR_FILLER = 'FILLER';
  STR_TARGET = 'TARGET';
  STR_PRETEXT = 'PRETEXT';
var
  i: Integer;
  s: string;
  FieldList: TStringList;
  ADataSet: TDataSet;
  FirstField: Boolean;
  PreText, FillerText,
  ClassText, TargetText: string;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'GetLinkListContent');
  CodeSite.SendStringList('TagParams', TagParams);
  {$ENDIF}

  FieldList := TStringList.Create;
  FirstField := True;
  Result := EmptyStr;

  FDataSetType := dstNone;
  FDataSetText := EmptyStr;

  PreText := EmptyStr;
  FillerText := EmptyStr;
  TargetText := EmptyStr;

  for i := 0 to TagParams.Count - 1 do begin
    s := UpperCase(TagParams.Names[i]);
    if s = TAG_TYPE then begin
      s := UpperCase(TagParams.Values[TAG_TYPE]);
      if s = TAGSTR_STOREDPROC then
        FDataSetType := dstStoredProcedure
      else if s = TAGSTR_SQL then
        FDataSetType := dstSQL
      else
        RaiseWebDataError('GetLinkListContent: Invalid data type, ' + s);
    end else if s = TAG_NAME then
      FDataSetText := TagParams.Values[TAG_NAME]
    else if s = STR_PRETEXT then
      PreText := TagParams.Values[STR_PRETEXT]
    else if s = STR_TARGET then
      TargetText := ' target="' + TagParams.Values[STR_TARGET] + '"'
    else if s = STR_CLASS then
      ClassText := ' class="' + TagParams.Values[STR_CLASS] + '"'
    else if s = TAGSTR_FIELDS then
      FieldList.CommaText := TagParams.Values[TAGSTR_FIELDS];
  end;

  // set up the data set
  if FDataSetType <> dstNone then begin
    PrepareDynamicDataSet(FDataSetType, FDataSetText);
    OpenDynamicDataSet;

    ADataSet := GetDynamicDataSet;
    if ADataSet = nil then
      RaiseWebDataError('GetLinkListContent: GetDynamicDataSet returned nil, DataSetText:' + FDataSetText);
    try
      // now that everything's all set up for our custom table output, call the Content method for each row
      if (ADataSet.FieldByName(STR_LINK) = nil) or
         (ADataSet.FieldByName(STR_NAME) = nil) or
         (ADataSet.FieldByName(STR_FILLER) = nil) then
        RaiseWebDataError('GetLinkListContent: An expected field is missing (Expected fields: Link, Name, Filler)')
      else
        while not ADataSet.Eof do begin
          // is this the first iteration?
          if FirstField then
            // yes, turn the flag off
            FirstField := False
          else
            // no, add the filler to the end of the previous link list item
            Result := Result + ADataSet.FieldByName(STR_FILLER).AsString + #10#13;
          // build the list content
          Result := Result + PreText +    '<a href="' + ADataSet.FieldByName(STR_LINK).AsString +
                             '"' + TargetText + ClassText + '>' + ADataSet.FieldByName(STR_NAME).AsString + '</A>';

          ADataSet.Next;
        end;
    finally
      CloseDynamicDataSet;
      FieldList.Free;
    end;
  end;

  {$IFDEF UseCodeSite}
  CodeSite.Send('Result', Result);
  {$ENDIF}
end;

function TdmCustomWebGenerator.GetListContent(const TagParams: TStrings): string;
const
  STR_TEXT = 'TEXT';
  STR_FILLER = 'FILLER';
var
  i: Integer;
  s: string;
  FieldList: TStringList;
  ADataSet: TDataSet;
  FirstRow: Boolean;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'GetListContent');
  CodeSite.SendStringList('TagParams', TagParams);
  {$ENDIF}

  FieldList := TStringList.Create;
  FirstRow := True;
  Result := EmptyStr;

  FDataSetType := dstNone;
  FDataSetText := EmptyStr;

  for i := 0 to TagParams.Count - 1 do begin
    s := UpperCase(TagParams.Names[i]);
    if s = TAG_TYPE then begin
      s := UpperCase(TagParams.Values[TAG_TYPE]);
      if s = TAGSTR_STOREDPROC then
        FDataSetType := dstStoredProcedure
      else if s = TAGSTR_SQL then
        FDataSetType := dstSQL
      else
        RaiseWebDataError('GetListContent: Invalid data type, ' + s);
    end else if s = TAG_NAME then
      FDataSetText := TagParams.Values[TAG_NAME]
    else if s = TAGSTR_FIELDS then
      FieldList.CommaText := TagParams.Values[TAGSTR_FIELDS];
  end;

  // set up the data set
  if FDataSetType <> dstNone then begin
    PrepareDynamicDataSet(FDataSetType, FDataSetText);
    OpenDynamicDataSet;

    ADataSet := GetDynamicDataSet;
    if ADataSet = nil then
      RaiseWebDataError('GetListContent: GetDynamicDataSet returned nil, DataSetText:' + FDataSetText);
    try
      // now that everything's all set up for our custom table output, call the Content method.
      if (ADataSet.FieldByName(STR_TEXT) = nil) or (ADataSet.FieldByName(STR_FILLER) = nil) then
        RaiseWebDataError('GetListContent: An expected field is missing (Expected fields: Text, Filler)')
      else
        while not ADataSet.Eof do begin
          // is this the first iteration?
          if FirstRow then
            // turn, turn the flag off
            FirstRow := False
          else
            // no, add the filler to the end of the previous link list item
            Result := Result + ADataSet.FieldByName(STR_FILLER).AsString + #10#13;
          // build the list content
          Result := Result + ADataSet.FieldByName(STR_TEXT).AsString;

          ADataSet.Next;
        end;
    finally
      CloseDynamicDataSet;
      FieldList.Free;
    end;
  end;

  {$IFDEF UseCodeSite}
  CodeSite.Send('Result', Result);
  {$ENDIF}
end;

function TdmCustomWebGenerator.GetIncludeContent(const IncFilename: string): string;
var
  IncFile: TextFile;
  s, FullIncFilename: string;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'GetIncludeContent');
  CodeSite.Send('Include Filename', IncFilename);
  {$ENDIF}

  if Length(IncFilename) = 0 then begin
    RaiseWebDataError('No filename given for INCLUDE tag.');
    Exit;
  end;

  // check to see if it has a hard-coded path
  if (IncFilename[1] = '/') or (IncFilename[1] = '\') or
     ((IncFilename[1] in ['A'..'Z','a'..'z']) and (Length(IncFilename) > 1) and
                                                  (IncFilename[2] = ':')) then
    // if so, simply use it
    FullIncFilename := IncFilename
  else
    // if not, it's relative to the current file
    // therefore, prepend the path of the current file
    FullIncFilename := IncludeTrailingPathDelimiter(ExtractFilePath(FCurrWebFilename)) +
                        IncFilename;

  if FileExists(FullIncFilename) then begin
    AssignFile(IncFile, FullIncFilename);
    try
      // open the file
      Reset(IncFile);
      // initialize the result string
      Result := EmptyStr;
      // read in the whole file
      while not Eof(IncFile) do begin
        ReadLn(IncFile, s);
        Result := Result + s;
      end;
    finally
      CloseFile(IncFile);
    end;
    // since this file may contain more tags to parse, set the reprocess flag
    FReprocess := True;
  end else
    RaiseWebDataError('Include file not found: ' + FullIncFilename);

  {$IFDEF UseCodeSite}
  CodeSite.Send('Result', Result);
  {$ENDIF}
end;

procedure TdmCustomWebGenerator.PageProducerHTMLTag(Sender: TObject;
  Tag: TTag; const TagString: String; TagParams: TStrings; var ReplaceText: String);
// this is the meat of the entire class--substituting custom HTML tags with data values
var
  s: string;
  FileName, FileDesc: string;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'PageProducerHTMLTag');
  CodeSite.SendEnum('Tag', TypeInfo(TTag), Ord(Tag));
  CodeSite.Send('TagString', TagString);
  CodeSite.SendStringList('TagParams', TagParams);
  {$ENDIF}

  DoWebTagFoundEvent(TagString, TagParams);

  s := UpperCase(TagString);
  try
    case Tag of
      tgCustom:
        if s = TAGSTR_STRING then
          ReplaceText := GetStrVal(TagParams.Values[TAG_NAME])
        else if s = TAGSTR_MEMO then
          ReplaceText := GetMemoVal(TagParams.Values[TAG_NAME])
        else if s = TAGSTR_INT then
          ReplaceText := IntToStr(GetIntVal(TagParams.Values[TAG_NAME]))
        else if s = TAGSTR_HEX then
          ReplaceText := GetHexVal(TagParams.Values[TAG_NAME])
        else if s = TAGSTR_FLOAT then
          ReplaceText := Format(FFloatFormat, [GetFloatVal(TagParams.Values[TAG_NAME])])
        else if s = TAGSTR_DATE then
          ReplaceText := Format(FDateFormat, [GetDateVal(TagParams.Values[TAG_NAME])])
        else if s = TAGSTR_TIME then
          ReplaceText := Format(FTimeFormat, [GetTimeVal(TagParams.Values[TAG_NAME])])
        else if s = TAGSTR_SQL then
          ReplaceText := GetSQLVal(TagParams.Values[TAGSTR_SQL], TagParams.Values[TAG_FIELD])
        else if s = TAGSTR_STOREDPROC then
          ReplaceText := GetStoredProcVal(TagParams.Values[TAG_NAME], TagParams.Values[TAG_FIELD])
        else if s = TAGSTR_LINKLIST then
          ReplaceText := GetLinkListContent(TagParams)
        else if s = TAGSTR_LIST then
          ReplaceText := GetListContent(TagParams)
        else if s = TAGSTR_SPACEOUT then begin
          if UpperCase(TagParams.Values[TAG_TYPE]) = TAGSTR_STRING then
            ReplaceText := GetSpacedText(GetStrVal(TagParams.Values[TAG_NAME]))
          else if UpperCase(TagParams.Values[TAG_TYPE]) = TAGSTR_STOREDPROC then
            ReplaceText := GetSpacedText(GetStoredProcVal(TagParams.Values[TAG_NAME], TagParams.Values[TAG_FIELD]))
          else if UpperCase(TagParams.Values[TAG_TYPE]) = TAGSTR_SQL then
            ReplaceText := GetSQLVal(TagParams.Values[TAG_SQL], TagParams.Values[TAG_FIELD]);
        end else IF s = TAGSTR_INCLUDE then
          ReplaceText := GetIncludeContent(TagParams.Values[TAGSTR_FILE])
        else
          RaiseWebDataError('Unknown WebBroker Tag: ' + TagString);
      tgImage: begin
        GetPicFilename(TagParams.Values[TAG_NAME], FileName, FileDesc);
        if Length(FileName) > 0 then
          ReplaceText := '<IMG SRC="' + FileName + '" ALT="' + FileDesc + '">'
        else
          ReplaceText := EmptyStr;
      end;
      tgTable:
        ReplaceText := GetTableContent(TagParams);
      else begin
        ReplaceText := EmptyStr;
        RaiseWebDataError('Unknown WebBroker Tag: ' + TagString);
      end;
    end;

    DoWebTagReplaceEvent(TagString, ReplaceText);
  except
    ReplaceText := EmptyStr;
    raise;
  end;

  {$IFDEF UseCodeSite}
  CodeSite.Send('ReplaceText', ReplaceText);
  {$ENDIF}
end;

procedure TdmCustomWebGenerator.DoStartOneProcessEvent(var Skip: Boolean);
begin
  if Assigned(FOnStartOneWebProcessEvent) then
    FOnStartOneWebProcessEvent(FCurrWebFilename, FCurrWebFileNum, FMaxWebFiles, Skip);
end;

procedure TdmCustomWebGenerator.DoFinishOneProcessEvent;
begin
  if Assigned(FOnFinishOneWebProcessEvent) then
    FOnFinishOneWebProcessEvent(FCurrWebFilename, FCurrWebFileNum, FMaxWebFiles);
end;

procedure TdmCustomWebGenerator.DoStartBatchProcessingEvent;
begin
  if Assigned(FOnStartBatchWebProcessEvent) then
    FOnStartBatchWebProcessEvent(self);
end;

procedure TdmCustomWebGenerator.DoFinishBatchProcessingEvent;
begin
  if Assigned(FOnFinishBatchWebProcessEvent) then
    FOnFinishBatchWebProcessEvent(self);
end;

procedure TdmCustomWebGenerator.DoFinishWebPageSearchEvent;
begin
  if Assigned(FOnFinishWebPageSearchEvent) then
    FOnFinishWebPageSearchEvent;
end;

procedure TdmCustomWebGenerator.DoStartWebPageSearchEvent;
begin
  if Assigned(FOnStartWebPageSearchEvent) then
    FOnStartWebPageSearchEvent;
end;

procedure TdmCustomWebGenerator.DoWebTagFoundEvent(HTMLTag: string; TagParams: TStrings);
begin
  if Assigned(FOnWebTagFoundEvent) then
    FOnWebTagFoundEvent(HTMLTag, TagParams);
end;

procedure TdmCustomWebGenerator.DoWebTagReplaceEvent(HTMLTag, ReplaceTag: string);
begin
  if Assigned(FOnWebTagReplaceEvent) then
    FOnWebTagReplaceEvent(HTMLTag, ReplaceTag);
end;

procedure TdmCustomWebGenerator.DoStartOneUploadEvent(var Skip: Boolean);
begin
  if Assigned(FOnStartOneWebUploadEvent) then
    FOnStartOneWebUploadEvent(FCurrWebFilename, FCurrWebFileNum, FMaxWebFiles, Skip);
end;

procedure TdmCustomWebGenerator.DoFinishOneUploadEvent;
begin
  if Assigned(FOnFinishOneWebUploadEvent) then
    FOnFinishOneWebUploadEvent(FCurrWebFilename, FCurrWebFileNum, FMaxWebFiles);
end;

procedure TdmCustomWebGenerator.DoStartBatchUploadingEvent;
begin
  if Assigned(FOnFinishBatchWebUploadingEvent) then
    FOnFinishBatchWebUploadingEvent(self);
end;

procedure TdmCustomWebGenerator.DoFinishBatchUploadingEvent;
begin
  if Assigned(FOnStartBatchWebUploadingEvent) then
    FOnStartBatchWebUploadingEvent(self);
end;

procedure TdmCustomWebGenerator.ProcessOneFile(const SrcFilename, DestFilename: string);
// runs the file specified by SrcFilename through the PageProduce and creates an uploadable HTML file (DestFilename)
var
  s: string;
  lg: Integer;
  UploadFile: TFileStream;
  Skip: Boolean;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'ProcessOneFile');
  CodeSite.Send('Source file', SrcFilename);
  CodeSite.Send('Dest file', DestFilename);
  {$ENDIF}

  FCurrWebFilename := SrcFilename;

  Skip := False;
  DoStartOneProcessEvent(Skip);

  if not Skip then begin
    PageProducer.HTMLFile := SrcFilename;
    UploadFile := TFileStream.Create(DestFilename, fmCreate or fmOpenWrite);
    try
      FReprocess := False;
      s := PageProducer.Content;
      while FReprocess do begin
        FReprocess := False;
        s := PageProducer.ContentFromString(s)
      end;
      lg := Length(s);
      UploadFile.Write(s[1], lg);
    finally
      UploadFile.Free;
    end;
  end;
  DoFinishOneProcessEvent;
end;

procedure TdmCustomWebGenerator.ProcessFiles(FileList: TStringList);
// runs the list of files in FileList through ProcessOneFile generating a whole batch of processed HTML files
var
  i: Integer;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'ProcessFiles');
  CodeSite.SendStringList('file list', FileList);
  {$ENDIF}

  if FileList.Count = 0 then
    RaiseWebDataError('No files to process.')
  else begin
    DoStartBatchProcessingEvent;
    FMaxWebFiles := FileList.Count;
    for i := 0 to FileList.Count - 1 do begin
      FCurrWebFileNum := i + 1;
      ProcessOneFile(TemplatePath + FileList.Strings[i], UploadPath + FileList.Strings[i]);
    end;
    DoFinishBatchProcessingEvent;
  end;
end;

procedure TdmCustomWebGenerator.ProcessAllFiles;
var
  SearchRec: TSearchRec;
  Done: Boolean;
  FileList: TStringList;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'ProcessAllFiles');
  {$ENDIF}

  DoStartWebPageSearchEvent;
  FileList := TStringList.Create;
  try
    // get list of files
    Done := FindFirst(IncludeTrailingPathDelimiter(TemplatePath) + TemplateFileMask, faAnyFile, SearchRec) <> 0;
    try
      while not Done do begin
        if (SearchRec.Attr and faDirectory) <> faDirectory then
          FileList.Add(ExtractFileName(SearchRec.Name));
        Done := FindNext(SearchRec) <> 0;
      end;
    finally
      FindClose(SearchRec);
    end;
    DoFinishWebPageSearchEvent;
    ProcessFiles(FileList);
  finally
    FileList.Free;
  end;
end;

procedure TdmCustomWebGenerator.UploadOneWebFile(const Filename: string);
var
  Skip: Boolean;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'UploadOneWebFile');
  CodeSite.Send('Filename', Filename);
  {$ENDIF}

  FCurrWebFilename := Filename;

  Skip := False;
  DoStartOneUploadEvent(Skip);

  if not Skip then
    UploadOneFileToWebServer(Filename);

  DoFinishOneUploadEvent;
end;

procedure TdmCustomWebGenerator.UploadWebFiles(FileList: TStringList);
var
  i: Integer;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'UploadWebFiles');
  CodeSite.SendStringList('FileList', FileList);
  {$ENDIF}

  if FileList.Count = 0 then
    RaiseWebDataError('No files to process.')
  else begin
    DoStartBatchUploadingEvent;
    FMaxWebFiles := FileList.Count;
    for i := 0 to FileList.Count - 1 do begin
      FCurrWebFileNum := i + 1;
      UploadOneWebFile(UploadPath + FileList.Strings[i]);
    end;
    DoFinishBatchUploadingEvent;
  end;
end;

procedure TdmCustomWebGenerator.UploadAllWebFiles;
var
  SearchRec: TSearchRec;
  Done: Boolean;
  FileList: TStringList;
begin
  {$IFDEF UseCodeSite}
  CodeSiteEx.TraceMethod(self, 'UploadAllWebFiles');
  {$ENDIF}

  DoStartWebPageSearchEvent;
  FileList := TStringList.Create;
  try
    // get list of files
    Done := FindFirst(IncludeTrailingPathDelimiter(UploadPath) + UploadFileMask, faAnyFile, SearchRec) <> 0;
    try
      while not Done do begin
        if (SearchRec.Attr and faDirectory) <> faDirectory then
          FileList.Add(ExtractFileName(SearchRec.Name));
        Done := FindNext(SearchRec) <> 0;
      end;
    finally
      FindClose(SearchRec);
    end;
    DoFinishWebPageSearchEvent;
    UploadWebFiles(FileList);
  finally
    FileList.Free;
  end;
end;

end.


unit uXmlDates;

interface

type
  TXMLDateZeroOptions = (dzoBlank, dzoZero, dzoNow);

function GetTimestampWithTimeZone(const ADateTime: TDateTime): string;
function GetXmlDate(const ADateTime: TDateTime; const DateZeroOption: TXMLDateZeroOptions = dzoBlank): string;
function ConvertToDelphiDateFromXml(const ADateTime: string): TDateTime;

implementation

uses
  {$IFDEF UseCodeSite} CodeSiteLogging, {$ENDIF}
  Windows, SysUtils, StrUtils, DateUtils;

function GetTimestampWithTimeZone(const ADateTime: TDateTime): string;
var
  LZoneInfo: TTimeZoneInformation;
  LFormatSettings: TFormatSettings;
  LZoneOffset: string;
  LXMLImportDate: string;
begin
  LFormatSettings := TFormatSettings.Create;

  GetTimeZoneInformation(LZoneInfo);
  LZoneOffset := FormatFloat('00', LZoneInfo.Bias div -60) + ':00';

  if ADateTime <> 0 then
    LXMLImportDate := FormatDateTime('yyyy-mm-dd"T"hh:mm:ss', ADateTime, LFormatSettings)
  else
    LXMLImportDate := FormatDateTime('yyyy-mm-dd"T"hh:mm:ss', Now, LFormatSettings);

  Result := LXMLImportDate + LZoneOffset;

  {$IFDEF UseCodeSite} CodeSite.Send('Result', Result); {$ENDIF}
end;

function GetXmlDate(const ADateTime: TDateTime; const DateZeroOption: TXMLDateZeroOptions = dzoBlank): string;
var
  LFormatSettings: TFormatSettings;
begin
  LFormatSettings := TFormatSettings.Create;

  if (ADateTime <> 0) or (DateZeroOption = dzoZero) then
    Result := FormatDateTime('yyyy-mm-dd"T"hh:mm:ss', ADateTime, LFormatSettings)
  else
    case DateZeroOption of
      dzoBlank:
        Result := EmptyStr;
      dzoNow:
        Result := FormatDateTime('yyyy-mm-dd"T"hh:mm:ss', Now, LFormatSettings);
    else
      raise Exception.Create('Invalid "DateZero" option when converting XML Dates (GetXmlDate)');
    end;
end;

function ConvertToDelphiDateFromXml(const ADateTime: string): TDateTime;
var
  LXmlDateTime: string;
  LYear, LMonth, LDay: Word;
  LHour, LMinute, LSecond: Word;
begin

  LXmlDateTime := Trim(ADateTime);

  if LXmlDateTime = EmptyStr then
    raise Exception.Create('ADateTime Parameter Can Not Be An Empty String');

  {$IFDEF UseCodeSite}
  CodeSite.Send(Format('Year: %s, Month: %s, Day: %s, Hour: %s, Minute: %s, Second: %s', [
                       LeftStr(LXmlDateTime, 4),
                       MidStr(LXmlDateTime, 6, 2),
                       MidStr(LXmlDateTime, 9, 2),
                       MidStr(LXmlDateTime, 12, 2),
                       MidStr(LXmlDateTime, 15, 2),
                       RightStr(LXmlDateTime, 2)
                       ]));
  {$ENDIF}

  LYear   := StrToInt(LeftStr(LXmlDateTime, 4));
  LMonth  := StrToInt(MidStr(LXmlDateTime, 6, 2));
  LDay    := StrToInt(MidStr(LXmlDateTime, 9, 2));

  LHour   := StrToInt(MidStr(LXmlDateTime, 12, 2));
  LMinute := StrToInt(MidStr(LXmlDateTime, 15, 2));
  LSecond := StrToInt(RightStr(LXmlDateTime, 2));

  Result := EncodeDateTime(LYear, LMonth, LDay, LHour, LMinute, LSecond, 0);

end;


end.

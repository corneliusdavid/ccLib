unit uTestUtils;

interface

type
  TTestUtils = class
  private
    class function RandStr(const MaxLen: Integer): string; static;
  public
    class function RandYear: Word;
    class function RandMonth: Word;
    class function RandDay: Word;
    class function RandHour: Word;
    class function RandMinute: Word;
    class function RandSecond: Word;
    class function RandMillisecond: Word;
    class function RandDate: TDateTime;
    class function RandDateStr: string;
    class function RandTime: TDateTime;
    class function RandTimeStr: string;

    class function RandString(const Len: integer = 100): string;
    class function RandInt(const MaxLen: Integer): Integer;
    class function RandIntStr(const MaxLen: Integer): string;
    class function RandDouble: Double;
    class function RandDoubleStr: string;
    class function RandBool: Boolean;
    class function RandBoolStr: string;
    class function RandCardType: string;
    class function RandPayType: string;
  end;


implementation

uses
  SysUtils, Math;

class function TTestUtils.RandString(const Len: integer = 100): string;
{ only returns upper-case letters }
var
  i: Integer;
begin
  Result := EmptyStr;
  for i := 1 to Len do
    Result := Result + Char(Random(26) + Ord('A'))
end;

class function TTestUtils.RandBool: Boolean;
const
  FalseTrueArray: array[0..1] of Boolean = (False, True);
begin
  Result := FalseTrueArray[Random(2)];
end;

class function TTestUtils.RandBoolStr: string;
const
  FalseTrue: array[Boolean] of string = ('False', 'True');
begin
  Result := FalseTrue[RandBool];
end;

class function TTestUtils.RandMillisecond: Word;
begin
  Result := Random(999) + 1;
end;

class function TTestUtils.RandMinute: Word;
begin
  Result := Random(59) + 1;
end;

class function TTestUtils.RandMonth: Word;
begin
  Result := Random(12) + 1;
end;

class function TTestUtils.RandYear: Word;
const
  YearsBack = 10;
begin
  Result := Random(YearsBack) + CurrentYear - YearsBack;
end;

class function TTestUtils.RandDate: TDateTime;
var
  year, month, day: Word;
begin
  year := RandYear;
  month := RandMonth;
  day := RandDay;
  Result := EncodeDate(year, month, day);
end;

class function TTestUtils.RandDateStr: string;
begin
  Result := FormatDateTime('yyyy-mm-dd', RandDate);
end;

class function TTestUtils.RandDay: Word;
begin
  Result := Random(28) + 1;
end;

class function TTestUtils.RandHour: Word;
begin
  Result := Random(24) + 1;
end;

class function TTestUtils.RandSecond: Word;
begin
  Result := Random(59) + 1;
end;

class function TTestUtils.RandTime: TDateTime;
var
  hour, min, sec, msec: Word;
begin
  hour := RandHour;
  min := RandMinute;
  sec := RandSecond;
  msec := RandMillisecond;
  Result := EncodeTime(hour, min, sec, msec);
end;

class function TTestUtils.RandTimeStr: string;
begin
  Result := FormatDateTime('yyyy-mm-dd', RandTime);
end;

class function TTestUtils.RandPayType: string;
const
  PaymentTypes: array[0..3] of string = ('Cash', 'CreditCard', 'COD', 'Gift');
begin
  Result := PaymentTypes[Random(4)];
end;

class function TTestUtils.RandCardType: string;
const
  CardTypes: array[0..2] of string = ('VISA', 'MC', 'DISC');
begin
  Result := CardTypes[Random(3)];
end;

class function TTestUtils.RandDouble: Double;
begin
  Result := Round(Random * 10000.0) / 100.0;
end;

class function TTestUtils.RandDoubleStr: string;
begin
  Result := FloatToStr(RandDouble);
end;

class function TTestUtils.RandInt(const MaxLen: Integer): Integer;
begin
  Result := Random(Round(Power(10, MaxLen)));
end;

class function TTestUtils.RandIntStr(const MaxLen: Integer): string;
begin
  Result := IntToStr(RandInt(MaxLen));
end;

class function TTestUtils.RandStr(const MaxLen: Integer): string;
var
  i: Integer;
begin
  Result := EmptyStr;
  for i := 1 to MaxLen do
    Result := Result + Chr(Random(26) + 65);
end;

end.

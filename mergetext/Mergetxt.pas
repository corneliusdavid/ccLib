unit MergeTxt;
(*
 * as: MergeTxt
 * by: David Cornelius
 * to: merge a bunch of Name=Value strings with a file replacing "Names" with "Values"
 *)

interface

uses
  Classes;

const
  tmNoMergeStrings = -1;
  tmNoMergeText    = -2;
type
  TccTextMerge = class(TComponent)
  private
    FMergeStrings: TStrings;
    FMergeText: TStrings;
    FStartDelim: string;
    FEndDelim: string;
    fReplaceBlanks: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    function MergeAString(var s: string): Byte;
    function Execute: Integer;
  published
    property MergeStrings: TStrings read FMergeStrings write FMergeStrings;
    property MergeText: TStrings read FMergeText write FMergeText;
    property StartDelim: string read FStartDelim write FStartDelim;
    property EndDelim: string read FEndDelim write FEndDelim;
    property ReplaceBlanks: Boolean read fReplaceBlanks write fReplaceBlanks default True;
  end;


implementation

constructor TccTextMerge.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FStartDelim := '<<';
  FEndDelim := '>>';
  FReplaceBlanks := True;
end;

function TccTextMerge.MergeAString(var s: string): Byte;
var
  sub: string;
  sstart: Byte;
  p1, p2: Byte;
  token, replstr: string;
begin
  Result := 0;

  { if there is no string to merge, don't waste the time trying }
  if Length(s) = 0 then
    Exit;

  sstart := 1;
  repeat
    sub := Copy(s, sstart, 255);
    p1 := Pos(FStartDelim, sub);
    if p1 > 0 then begin
      p2 := Pos(FEndDelim, sub);
      if p2 > 0 then begin
        token := Copy(sub, p1+Length(FStartDelim), p2-p1-Length(FStartDelim)-Length(FEndDelim)+2);
        replstr := FMergeStrings.Values[token];
        if (replstr <> '') or fReplaceBlanks then begin
          { here's the meat! }
          Delete(s, sstart+p1-1, p2-p1+Length(EndDelim));
          Insert(replstr, s, sstart+p1-1);
          Inc(Result);
          p1 := sstart + Length(replstr);
        end else
          p1 := sstart + Length(FStartDelim)+Length(token)+Length(FEndDelim);
      end else
        Inc(p1, sstart + Length(FStartDelim) - 1);
      sstart := p1;
    end;
  until p1 = 0;
end;

function TccTextMerge.Execute: Integer;
var
  i: Integer;
  Count: Byte;
  temp: string;
begin
  { make sure there is a set of strings to merge with }
  if not Assigned(FMergeStrings) then begin
    Result := tmNoMergeStrings;
    Exit;
  end;

  { make sure there is a set of strings to merge into }
  if not Assigned(FMergeText) then begin
    Result := tmNoMergeText;
    Exit;
  end;

  { initialize the counter, then do the merge on each string in the text }
  Count := 0;
  for i := 0 to FMergeText.Count - 1 do begin
    temp := FMergeText.Strings[i];
    Inc(Count, MergeAString(temp));
    FMergeText.Strings[i] := temp;
  end;

  { return the number of fields merged ( < 0  means error) }
  Result := Count;
end;

end.
 
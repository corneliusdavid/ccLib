unit MergeTxtReg;
(*
 * as: MergeTxtReg
 * by: David Cornelius
 * to: register the MergeTxt component
 *)

interface

{$I cc.inc}

uses
  {$IFDEF	Delphi5}
  Dsgnintf;
  {$ELSE}
    {$IFDEF Delphi6AndUp}
    DesignEditors, DesignIntf;
    {$ENDIF}
  {$ENDIF}

type
  TTextMergeEditor = class(TComponentEditor)
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

procedure RegisterMergeText;


implementation

uses
  Classes, Windows, MergeTxt;

procedure RegisterMergeText;
begin
  RegisterComponentEditor(TccTextMerge, TTextMergeEditor);
  RegisterComponents('cc', [TccTextMerge]);
end;

{ TTextMergeEditor }

procedure TTextMergeEditor.ExecuteVerb(Index: Integer);
const
  CR = #13;
  LF = #10;
begin
  case Index of
    0: MessageBox(0, 'TccTextMerge vr. 1.0' + CR + LF +
                     'Copyright (c) 2001-2015 by Cornelius Concepts.',
                     PChar('About this component ...'),
                     MB_OK + MB_ICONINFORMATION);
    1: MessageBox(0, 'TccTextMerge allows you to merge a set of Name=Value pairs into a string containg "Names" ' +
                     'delimited by StartDelim and EndDelim, replacing each occurance with the matching "Value".  ' +
                     'If ReplaceBlanks is True, any tokens that are not found in the Name=Value list, are replaced ' +
                     'with blanks--in other words, they are simply removed.' + CR + LF + LF +
                     'Once MergeText (the list of Name=Value pairs) and MergeStrings (the text to merge with) ' +
                     'are set, simply call the Execute method, which returns the number of tokens found ' +
                     'and replaced, or -1 (tmNoMergeStrings), or -2 (tmNoMergeText).',
                     PChar('Component Help...'),
                     MB_OK + MB_ICONINFORMATION);
  end;
end;

function TTextMergeEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := '&Version and Copyright info...';
    1: Result := 'Component Help...';
  end;
end;

function TTextMergeEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;

end.

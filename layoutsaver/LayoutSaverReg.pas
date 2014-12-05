unit LayoutSaverReg;
(*
 * as: LayoutSaverReg
 * by: David Cornelius
 * to: register the LayoutSaver component
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
  TLayoutSaverEditor = class(TComponentEditor)
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

procedure RegisterLayoutSaver;


implementation

uses
  Classes, Windows, LayoutSaver;

procedure RegisterLayoutSaver;
begin
  RegisterComponentEditor(TccLayoutSaver, TLayoutSaverEditor);
  RegisterComponents('cc', [TccLayoutSaver]);
end;

{ TLayoutSaverEditor }

procedure TLayoutSaverEditor.ExecuteVerb(Index: Integer);
const
  CR = #13;
  LF = #10;
begin
  case Index of
    0: MessageBox(0, 'TccLayoutSaver vr. 1.1' + CR + LF +
                     'Copyright (c) 2001-2002 by Cornelius Concepts.',
                     PChar('About this component ...'),
                     MB_OK + MB_ICONINFORMATION);
    1: MessageBox(0, 'TccLayoutSaver saves the form''s Top, Left, Width, and Height settings in an ' +
                     '.INI file specified by the Location property and in the section specified by ' +
                     'the Section property. By setting UseDefaultNames to True, the Location is ' +
                     'automatically assigned the Application.ExeName value in the current directory ' +
                     'and the Section is set to the form''s name upon which the component resides.' + CR + LF +
                     LF +
                     'The AutoSave and AutoRestore properties allow a form to be ' +
                     'automatically saved and restored upon creation and destruction of the form.  ' +
                     'Therefore, by simply dropping this component on a form, its size and position will ' +
                     'automatically be saved and restored--with no code!' + CR + LF +
                     LF +
                     'Note: If the Position property of the form is set to poScreenCenter, the form will still ' +
                     'retain its size (width and height), but always start centered.' + CR + LF +
                     LF +
                     'Also provided are two public methods, SaveDimension and RestoreDimension that ' +
                     'will save any integer values in the same section of the .INI file ' +
                     'as the rest of the "layout" settings.',
                     PChar('Component Help ...'),
                     MB_OK + MB_ICONINFORMATION);
  end;
end;

function TLayoutSaverEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := '&Version and Copyright info...';
    1: Result := 'Component Help...';
  end;
end;

function TLayoutSaverEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;

end.

unit LayoutSaverReg;
(*
 * as: LayoutSaverReg
 * by: David Cornelius
 * to: register the LayoutSaver component
 *)

interface

{$I cc.inc}

uses
  Classes,
  {$IFDEF	Delphi5}
  Dsgnintf;
  {$ELSE}
    {$IFDEF Delphi6AndUp}
    DesignEditors, DesignIntf;
    {$ENDIF}
  {$ENDIF}

type
  {$IFDEF 103RioOrHigher}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
  {$ENDIF}
  TccIniLayoutSaverEditor = class(TComponentEditor)
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

  {$IFDEF 103RioOrHigher}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
  {$ENDIF}
  TccRegistryLayoutSaverEditor = class(TComponentEditor)
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

procedure RegisterLayoutSaver;


implementation

uses
  SysUtils, Windows, Graphics, ToolsAPI,
  LayoutSaver;

procedure RegisterLayoutSaver;
begin
  RegisterComponentEditor(TccIniLayoutSaver, TccIniLayoutSaverEditor);
  RegisterComponentEditor(TccRegistryLayoutSaver, TccRegistryLayoutSaverEditor);
  RegisterComponents('Cornelius Concepts', [TccIniLayoutSaver, TccRegistryLayoutSaver]);
end;

{ TccIniLayoutSaverEditor }

procedure TccIniLayoutSaverEditor.ExecuteVerb(Index: Integer);
const
  CR = #13;
  LF = #10;
begin
  case Index of
    0: MessageBox(0, 'TccIniLayoutSaver vr. 2.0' + CR + LF +
                     'Freeware by Cornelius Concepts',
                     PChar('About this component ...'),
                     MB_OK + MB_ICONINFORMATION);
    1: MessageBox(0, 'TccIniLayoutSaver saves the form''s Top, Left, Width, and Height settings in an ' +
                     '.INI file specified by the Location property and in the section specified by ' +
                     'the Section property. By setting UseDefaultNames to True, the Location is ' +
                     'automatically assigned the Application.ExeName value in the Local Application Path ' +
                     '(if UseAppPath is True or the application''s directory otherwise) ' +
                     'and the Section is set to the form''s name upon which the component resides.' + CR + LF +
                     LF +
                     'The AutoSave and AutoRestore properties allow a form to be ' +
                     'automatically saved and restored upon creation and destruction of the form.  ' +
                     'Therefore, by simply dropping this component on a form, its size and position will ' +
                     'automatically be saved and restored in an .INI file--with no code!' + CR + LF +
                     'You can use the OnBeforeRestore and OnBeforeSave events to modify behavior just before ' +
                     'those actions take place.' + sLineBreak +
                     sLineBreak +
                     LF +
                     'Note: If the Position property of the form is set to poScreenCenter, the form will still ' +
                     'retain its size (width and height), but always start centered.' + CR + LF +
                     LF +
                     'Also provided are three sets of public methods, SaveIntValue/RestoreIntValue, ' +
                     'SaveStrValue/RestoreStrValue and SaveBoolValue/RestoreBoolValue that ' +
                     'will save/resotre any integer, string, or boolean values (respectively) in the same ' +
                     'section of the .INI file as the rest of the "layout" settings for your convenience.',
                     PChar('Component Help ...'),
                     MB_OK + MB_ICONINFORMATION);
  end;
end;

function TccIniLayoutSaverEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := '&Version Info...';
    1: Result := 'Component Help...';
  end;
end;

function TccIniLayoutSaverEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;

{ TccRegistryLayoutSaverEditor }

procedure TccRegistryLayoutSaverEditor.ExecuteVerb(Index: Integer);
const
  CR = #13;
  LF = #10;
begin
  case Index of
    0: MessageBox(0, 'TccRegistryLayoutSaver vr. 1.0' + sLineBreak +
                     'Freeware by Cornelius Concepts',
                     PChar('About this component ...'),
                     MB_OK + MB_ICONINFORMATION);
    1: MessageBox(0, 'TccRegistryLayoutSaver saves the form''s Top, Left, Width, and Height settings in the ' +
                     'CURRENT_USER root key. By setting UseDefaultNames to True, the Location property is ' +
                     'automatically assigned the Application.ExeName and and the Section property is ' +
                     'set to the form''s name upon which the component resides.' + sLineBreak +
                     sLineBreak +
                     'The AutoSave and AutoRestore properties allow a form to be ' +
                     'automatically saved and restored upon creation and destruction of the form.  ' +
                     'Therefore, by simply dropping this component on a form, its size and position will ' +
                     'automatically be saved and restored in the registry--with no code!' + sLineBreak +
                     sLineBreak +
                     'You can use the OnBeforeRestore and OnBeforeSave events to modify behavior just before ' +
                     'those actions take place.' + sLineBreak +
                     sLineBreak +
                     'Note: If the Position property of the form is set to poScreenCenter, the form will still ' +
                     'retain its size (width and height), but always start centered.' + sLineBreak +
                     sLineBreak +
                     'Also provided are three sets of public methods, SaveIntValue/RestoreIntValue, ' +
                     'SaveStrValue/RestoreStrValue and SaveBoolValue/RestoreBoolValue that ' +
                     'will save/resotre any integer, string, or boolean values (respectively) in the same ' +
                     'section of the registry as the rest of the "layout" settings for your convenience.',
                     PChar('Component Help ...'),
                     MB_OK + MB_ICONINFORMATION);
  end;
end;

function TccRegistryLayoutSaverEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := '&Version Info...';
    1: Result := 'Component Help...';
  end;
end;

function TccRegistryLayoutSaverEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;

end.

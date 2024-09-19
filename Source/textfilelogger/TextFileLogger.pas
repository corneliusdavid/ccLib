unit TextFileLogger;
(*
 * as: TextFileLogger
 * by: David Cornelius
 * to: provide easy logging to a text file
 *)

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  ETextFileLogger = Exception;

  TccTextFileLogger = class(TComponent)
  private
    FWriteHeader: Boolean;
    FLogFile: TextFile;
    FLogFileCreated: Boolean;
    FLogFileName: string;
    FOverwrite: Boolean;
    FKeepOpen: Boolean;
    FUseDefaultFilename: Boolean;
    procedure   SetFilename(const NewFilename: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   Log(const Msg: string);
  published
    property FileName: string read FLogFilename write SetFilename;
    property KeepOpen: Boolean read FKeepOpen write FKeepOpen default True;
    property Overwrite: Boolean read FOverwrite write FOverwrite default False;
    property UseDefaultFileName: Boolean read FUseDefaultFilename write FUseDefaultFilename default True;
    property WriteHeader: Boolean read FWriteHeader write FWriteHeader default True;
  end;



implementation


constructor TccTextFileLogger.Create(AOwner: TComponent);
begin
  inherited;

  FOverwrite := False;
  FLogFileName := '';
  FLogFileCreated := False;
  FWriteHeader := True;
  FUseDefaultFileName := True;
end;

destructor TccTextFileLogger.Destroy;
begin
  if (not (csDesigning in ComponentState)) and FLogFileCreated and FKeepOpen then
    CloseFile(FLogFile);

  inherited;
end;

procedure TccTextFileLogger.Log(const Msg: string);
begin
  // have we written to the log file yet?
  if not FLogFileCreated then begin
    if Length(FLogFileName) = 0 then
      if FUseDefaultFilename then
        FLogFileName := ChangeFileExt(Application.Exename, '.LOG')
      else begin
        FLogFileCreated := False;
        raise ETextFileLogger.Create('No filename for the log file.');
      end;

    AssignFile(FLogFile, FLogFileName);
    if FileExists(FLogFileName) and (not FOverwrite) then
      Append(FLogFile)
    else
      Rewrite(FLogFile);

    FLogFileCreated := True;

    if FWriteHeader then
      Writeln(FLogFile, '-----[ ', FormatDateTime('mm-dd-yyyy  hh:nn:ss', Now), ' ]-----');
  end;

  // only write out stuff if we know the file was created
  if FLogFileCreated then begin
    if not FKeepOpen then
      Append(FLogFile);

    Writeln(FLogFile, Msg);

    if not FKeepOpen then
      CloseFile(FLogFile);
  end;
end;

procedure TccTextFileLogger.SetFilename(const NewFilename: string);
begin
  if FLogFileName <> NewFilename then begin
    FLogFilename := NewFilename;
    if FLogFileCreated and FKeepOpen then
      CloseFile(FLogFile);
    FLogFileCreated := False;
  end;
end;

end.

unit ElapsedTimer;
(*
 * as: ElapsedTimer
 * by: David Cornelius
 * to: provide a convenient way of timing things
 *)

interface

uses
  SysUtils, Classes;

type
  TccElapsedTimer = class(TComponent)
  private
    FStartTime,
    FStopTime: TDateTime;
    FDiffTime: TDateTime;
    FElapsedSeconds: Double;
    FElapsedMinutes: Double;
    FElapsedHours: Double;
    FElapsedMonths: Double;
    FElapsedDays: Double;
    FElapsedYears: Double;
    procedure CalcTime;
  public
    procedure Start;
    procedure Stop;
    property StartTime: TDateTime read FStartTime;
    property StopTime: TDateTime read FStopTime;
    property ElapsedTime: TDateTime read FDiffTime;
    property ElapsedSeconds: Double read FElapsedSeconds;
    property ElapsedMinutes: Double read FElapsedMinutes;
    property ElapsedHours: Double read FElapsedHours;
    property ElapsedDays: Double read FElapsedDays;
    property ElapsedMonths: Double read FElapsedMonths;
    property ElapsedYears: Double read FElapsedYears;
  end;


implementation

procedure TccElapsedTimer.CalcTime;
begin
  FDiffTime := FStopTime - FStartTime;
  FElapsedDays := FDiffTime;
  FElapsedMonths := FElapsedDays / 30.4;  // average
  FElapsedYears := FElapsedDays / 365.25;
  FElapsedHours := FElapsedDays * 24.0;
  FElapsedMinutes := FElapsedHours * 60.0;
  FElapsedSeconds := FElapsedMinutes * 60.0;
end;

procedure TccElapsedTimer.Start;
begin
  FStartTime := Now;
end;

procedure TccElapsedTimer.Stop;
begin
  FStopTime := Now;
  CalcTime;
end;

end.

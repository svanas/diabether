unit Misc;

interface

type
  TGlucoseUnit = (guMMOL, guMGDL);

const
  GlucoseUnitText: array[TGlucoseUnit] of string = ('mmol/L', 'mg/dL');

type
  TInsulinTime = (itMorning, itDay, itEvening);

function InsulinTime: TInsulinTime;

type
  MMOL = Double;
  MGDL = Integer;

function MMOL2MGDL(Value: MMOL): MGDL;
function MGDL2MMOL(Value: MGDL): MMOL;

function ToMMOL(Value: Double): MMOL;
function ToMGDL(Value: Double): MGDL;

function FormatGlucose(Value: Double): string;

implementation

uses
  // Delphi
  System.SysUtils,
  // Project
  Settings;

function InsulinTime: TInsulinTime;
begin
  Result := itMorning;
  if Time > 11/24 then
    if Time > 16/24 then
      Result := itEvening
    else
      Result := itDay;
end;

function MMOL2MGDL(Value: MMOL): MGDL;
begin
  Result := Round(Value * 18.0182);
end;

function MGDL2MMOL(Value: MGDL): MMOL;
begin
  Result := Value / 18.0182;
end;

function ToMMOL(Value: Double): MMOL;
begin
  Result := Value;
  if Settings.Get.GlucoseUnit = guMGDL then
    Result := MGDL2MMOL(Round(Value));
end;

function ToMGDL(Value: Double): MGDL;
begin
  Result := Round(Value);
  if Settings.Get.GlucoseUnit = guMMOL then
    Result := MMOL2MGDL(Value);
end;

function FormatGlucose(Value: Double): string;
begin
  case Settings.Get.GlucoseUnit of
    guMMOL: Result := Format('%.1f', [Value], TSettings.Format);
    guMGDL: Result := Format('%.0f', [Value], TSettings.Format);
  end;
end;

end.

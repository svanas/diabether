unit Misc;

interface

{-------------------------------- TGlucoseUnit --------------------------------}

type
  TGlucoseUnit = (guMMOL, guMGDL);

const
  GlucoseUnitText: array[TGlucoseUnit] of string = ('mmol/L', 'mg/dL');

{-------------------------------- TInsulinUnit --------------------------------}

type
  TInsulinUnit = (iuHalf, iuWhole);

function RoundInsulin(Value: Double): Double;

{-------------------------------- TInsulinTime --------------------------------}

type
  TInsulinTime = (itMorning, itDay, itEvening);

function InsulinTime: TInsulinTime;

{--------------------------------- MMOL/MGDL ----------------------------------}

type
  MMOL = Double;
  MGDL = Integer;

function MMOL2MGDL(Value: MMOL): MGDL;
function MGDL2MMOL(Value: MGDL): MMOL;

{------------------------------- TBloodGlucose --------------------------------}

type
  TBloodGlucose = record
  private
    Inner: Double;
  public
    constructor Create(Value: Double);
    function Format: string;
    function ToMMOL: MMOL;
    function ToMGDL: MGDL;
    class operator Equal(const Left: TBloodGlucose; Right: Double): Boolean;
    class operator GreaterThanOrEqual(const Left: TBloodGlucose; Right: Double): Boolean;
    class operator Implicit(const Value: TBloodGlucose): Double;
    class operator LessThan(const Left, Right: TBloodGlucose): Boolean;
    class operator Subtract(const Left: TBloodGlucose; Right: Double): Double;
  end;

implementation

uses
  // Delphi
  System.SysUtils,
  // Project
  Settings;

function RoundInsulin(Value: Double): Double;
begin
  if Value < 0 then
  begin
    Result := 0;
    EXIT;
  end;
  Result := Value;
  const settings = Settings.Get;
  if settings.InsulinUnit = iuWhole then
    Result := Round(Result)
  else if settings.InsulinUnit = iuHalf then
  begin
    const frac = Frac(Result);
    if frac < 0.25  then
      Result := Int(Result)
    else if frac > 0.75 then
      Result := Round(Result)
    else
      Result := Int(Result) + 0.5;
  end;
end;

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

constructor TBloodGlucose.Create(Value: Double);
begin
  Self.Inner := Value;
end;

function TBloodGlucose.ToMMOL: MMOL;
begin
  Result := Self.Inner;
  if Settings.Get.GlucoseUnit = guMGDL then
    Result := MGDL2MMOL(Round(Self.Inner));
end;

function TBloodGlucose.ToMGDL: MGDL;
begin
  Result := Round(Self.Inner);
  if Settings.Get.GlucoseUnit = guMMOL then
    Result := MMOL2MGDL(Self.Inner);
end;

function TBloodGlucose.Format: string;
begin
  case Settings.Get.GlucoseUnit of
    guMMOL: Result := System.SysUtils.Format('%.1f', [Self.Inner], TSettings.Format);
    guMGDL: Result := System.SysUtils.Format('%.0f', [Self.Inner], TSettings.Format);
  end;
end;

class operator TBloodGlucose.Equal(const Left: TBloodGlucose; Right: Double): Boolean;
begin
  Result := Left.Inner = Right;
end;

class operator TBloodGlucose.GreaterThanOrEqual(const Left: TBloodGlucose; Right: Double): Boolean;
begin
  Result := left.Inner >= Right;
end;

class operator TBloodGlucose.Implicit(const Value: TBloodGlucose): Double;
begin
  Result := Value.Inner;
end;

class operator TBloodGlucose.LessThan(const Left, Right: TBloodGlucose): Boolean;
begin
  Result := Left.Inner < Right.Inner;
end;

class operator TBloodGlucose.Subtract(const Left: TBloodGlucose; Right: Double): Double;
begin
  Result := Left.Inner - Right;
end;

end.

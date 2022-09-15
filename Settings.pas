unit Settings;

interface

uses
  // Delphi
  System.Classes,
  System.SysUtils,
  // FireDAC
  FireDAC.Comp.Client,
  // Project
  Database,
  Misc;

type
  TSettings = class
  private
    FFirstTime: Boolean;
    FDatabase: TDatabase;
    FQuery: TFDQuery;
    FOnGlucoseUnitChange: TNotifyEvent;

    function Database: TDatabase;
    function Query: TFDQuery;
    procedure AfterConnect(Sender: TObject);

    function GetTarget(Time: TInsulinTime): Double;
    procedure SetTarget(Time: TInsulinTime; Value: Double);

    function GetCarbRatio(Time: TInsulinTime): Integer;
    procedure SetCarbRatio(Time: TInsulinTime; Value: Integer);

    function GetCorrUnits(Glucose: Double): Double;
    procedure SetCorrUnits(Glucose, Value: Double);

    function GetGlucoseUnit: TGlucoseUnit;
    procedure SetGlucoseUnit(Value: TGlucoseUnit);
  public
    destructor Destroy; override;
    class function Format: TFormatSettings;

    function FirstTime: Boolean;
    function CorrRatio(IT: TInsulinTime): Double;

    property Target[Time: TInsulinTime]: Double read GetTarget write SetTarget;
    property CarbRatio[Time: TInsulinTime]: Integer read GetCarbRatio write SetCarbRatio;
    property CorrUnits[Glucose: Double]: Double read GetCorrUnits write SetCorrUnits;

    property GlucoseUnit: TGlucoseUnit read GetGlucoseUnit write SetGlucoseUnit;
    property OnGlucoseUnitChange: TNotifyEvent read FOnGlucoseUnitChange write FOnGlucoseUnitChange;
  end;

function Get: TSettings;

implementation

var
  varSettings: TSettings = nil;

function Get: TSettings;
begin
  if not Assigned(varSettings) then
    varSettings := TSettings.Create;
  Result := varSettings;
end;

{ TSettings }

destructor TSettings.Destroy;
begin
  if Assigned(FQuery) then
  try
    if FQuery.Active then FQuery.Close;
  finally
    FQuery.Free;
  end;
  if Assigned(FDatabase) then
    FDatabase.Free;
  inherited Destroy;
end;

class function TSettings.Format: TFormatSettings;
begin
  Result := FormatSettings;
  Result.DecimalSeparator := '.';
end;

function TSettings.FirstTime: Boolean;
begin
  Self.Query;
  Result := FFirstTime;
end;

function TSettings.Database: TDatabase;
begin
  if not Assigned(FDatabase) then
  begin
    FDatabase := TDatabase.Create;
    FDatabase.Connection.AfterConnect := AfterConnect;
  end;
  Result := FDatabase;
end;

procedure TSettings.AfterConnect;
begin
  FFirstTime := not Database.TableExists('SETTINGS');
  if FFirstTime then
    if Database.Execute('CREATE TABLE SETTINGS (ID INTEGER PRIMARY KEY' +
    ', TARGET_MORNING REAL, TARGET_DAY REAL, TARGET_EVENING REAL' +
    ', CARB_MORNING INTEGER, CARB_DAY INTEGER, CARB_EVENING INTEGER' +
    ', CORR_ABOVE_8 REAL, CORR_ABOVE_10 REAL, CORR_ABOVE_12 REAL, CORR_ABOVE_14 REAL, CORR_ABOVE_16 REAL, CORR_ABOVE_18 REAL, CORR_ABOVE_20 REAL, CORR_ABOVE_22 REAL, CORR_ABOVE_24 REAL);') > -1 then
      Database.Execute(System.SysUtils.Format('INSERT INTO SETTINGS (' +
        'TARGET_MORNING, TARGET_DAY, TARGET_EVENING, CARB_MORNING, CARB_DAY, CARB_EVENING, CORR_ABOVE_8, CORR_ABOVE_10, CORR_ABOVE_12, CORR_ABOVE_14, CORR_ABOVE_16, CORR_ABOVE_18, CORR_ABOVE_20, CORR_ABOVE_22, CORR_ABOVE_24) ' +
        'VALUES(%.2f, %.2f, %.2f, %d, %d, %d, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f);',
        [5.8, 5.8, 8.0, 0, 0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], TSettings.Format));
end;

function TSettings.Query: TFDQuery;
begin
  if not Assigned(FQuery) then
  begin
    FQuery := TFDQuery.Create(nil);
    FQuery.Connection := Database.Connection;
  end;
  Result := FQuery;
  if not Result.Active then
    Result.Open('SELECT * FROM SETTINGS');
end;

function TSettings.GetTarget(Time: TInsulinTime): Double;
begin
  if Time = itEvening then
    Result := Query.FieldByName('TARGET_EVENING').AsFloat
  else if Time = itDay then
    Result := Query.FieldByName('TARGET_DAY').AsFloat
  else
    Result := Query.FieldByName('TARGET_MORNING').AsFloat;
end;

procedure TSettings.SetTarget(Time: TInsulinTime; Value: Double);
begin
  Query.Edit;
  try
    case Time of
      itMorning: Query.FieldByName('TARGET_MORNING').AsFloat := Value;
      itDay    : Query.FieldByName('TARGET_DAY').AsFloat := Value;
      itEvening: Query.FieldByName('TARGET_EVENING').AsFloat := Value;
    end;
  finally
    Query.Post;
  end;
end;

function TSettings.GetCarbRatio(Time: TInsulinTime): Integer;
begin
  if Time = itMorning then
    Result := Query.FieldByName('CARB_MORNING').AsInteger
  else if Time = itDay then
    Result := Query.FieldByName('CARB_DAY').AsInteger
  else
    Result := Query.FieldByName('CARB_EVENING').AsInteger;
end;

procedure TSettings.SetCarbRatio(Time: TInsulinTime; Value: Integer);
begin
  Query.Edit;
  try
    if Time = itMorning then
      Query.FieldByName('CARB_MORNING').AsInteger := Value
    else if Time = itDay then
      Query.FieldByName('CARB_DAY').AsInteger := Value
    else
      Query.FieldByName('CARB_EVENING').AsInteger := Value;
  finally
    Query.Post;
  end;
end;

function TSettings.GetCorrUnits(Glucose: Double): Double;
begin
  if Glucose >= 24 then
    Result := Query.FieldByName('CORR_ABOVE_24').AsFloat
  else if Glucose >= 22 then
    Result := Query.FieldByName('CORR_ABOVE_22').AsFloat
  else if Glucose >= 20 then
    Result := Query.FieldByName('CORR_ABOVE_20').AsFloat
  else if Glucose >= 18 then
    Result := Query.FieldByName('CORR_ABOVE_18').AsFloat
  else if Glucose >= 16 then
    Result := Query.FieldByName('CORR_ABOVE_16').AsFloat
  else if Glucose >= 14 then
    Result := Query.FieldByName('CORR_ABOVE_14').AsFloat
  else if Glucose >= 12 then
    Result := Query.FieldByName('CORR_ABOVE_12').AsFloat
  else if Glucose >= 10 then
    Result := Query.FieldByName('CORR_ABOVE_10').AsFloat
  else
    Result := Query.FieldByName('CORR_ABOVE_8').AsFloat;
end;

procedure TSettings.SetCorrUnits(Glucose, Value: Double);
begin
  Query.Edit;
  try
    if Glucose >= 24 then
      Query.FieldByName('CORR_ABOVE_24').AsFloat := Value
    else if Glucose >= 22 then
      Query.FieldByName('CORR_ABOVE_22').AsFloat := Value
    else if Glucose >= 20 then
      Query.FieldByName('CORR_ABOVE_20').AsFloat := Value
    else if Glucose >= 18 then
      Query.FieldByName('CORR_ABOVE_18').AsFloat := Value
    else if Glucose >= 16 then
      Query.FieldByName('CORR_ABOVE_16').AsFloat := Value
    else if Glucose >= 14 then
      Query.FieldByName('CORR_ABOVE_14').AsFloat := Value
    else if Glucose >= 12 then
      Query.FieldByName('CORR_ABOVE_12').AsFloat := Value
    else if Glucose >= 10 then
      Query.FieldByName('CORR_ABOVE_10').AsFloat := Value
    else
      Query.FieldByName('CORR_ABOVE_8').AsFloat := Value;
  finally
    Query.Post;
  end;
end;

function TSettings.CorrRatio(IT: TInsulinTime): Double;
begin
  for var G in [8, 10, 12, 14, 16, 18, 20, 22, 24] do
  begin
    Result := (G - 5.8) / Self.CorrUnits[G];
    if Result > 0 then
      EXIT;
  end;
  Result := 0;
end;

function TSettings.GetGlucoseUnit: TGlucoseUnit;
begin
  Result := guMMOL;
  const F = Query.FindField('GlucoUnit');
  if Assigned(F) then
    Result := TGlucoseUnit(F.AsInteger);
end;

procedure TSettings.SetGlucoseUnit(Value: TGlucoseUnit);
begin
  const F = Query.FindField('GlucoUnit');

  if not Assigned(F) then
    if Database.Execute('ALTER TABLE SETTINGS ADD COLUMN GlucoUnit INTEGER') > 0 then
    begin
      Database.Execute(System.SysUtils.Format('UPDATE SETTINGS SET GlucoUnit = %d', [Ord(Value)]));
      Database.Connection.Close;
      EXIT;
    end;

  if Assigned(F) then
  begin
    Query.Edit;
    try
      F.AsInteger := Ord(Value);
    finally
      Query.Post;
    end;
  end;

  if Assigned(FOnGlucoseUnitChange) then FOnGlucoseUnitChange(Self);
end;

end.
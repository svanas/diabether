unit Database;

interface

uses
  // FireDAC
  FireDAC.Comp.Client,
  FireDAC.DApt,
  FireDAC.FMXUI.Wait,
  FireDAC.Phys.SQLite,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def;

type
  TDatabase = class
  private
    FConnection: TFDConnection;
    class function FileName: string;
  public
    constructor Create;
    destructor Destroy; override;
    function Connection: TFDConnection;
    function Execute(const SQL: string): LongInt;
    function TableExists(const TableName: string): Boolean;
  end;

implementation

uses
  // Delphi
  System.IOUtils,
  System.SysUtils;

constructor TDatabase.Create;
begin
  inherited Create;
  FConnection := nil;
end;

destructor TDatabase.Destroy;
begin
  if Assigned(FConnection) then
  try
    if FConnection.Connected then FConnection.Close;
  finally
    FConnection.Free;
  end;
  inherited Destroy;
end;

class function TDatabase.FileName: string;
begin
  Result := TPath.Combine(TPath.GetDocumentsPath, 'Diabether.sqlite');
end;

function TDatabase.Connection: TFDConnection;
begin
  if not Assigned(FConnection) then
  begin
    FConnection := TFDConnection.Create(nil);
    FConnection.Params.Values['DriverID'] := 'SQLite';
    FConnection.Params.Values['Database'] := FileName;
  end;
  Result := FConnection;
end;

function TDatabase.Execute(const SQL: string): LongInt;
begin
  Result := Connection.ExecSQL(SQL);
end;

function TDatabase.TableExists(const TableName: string): Boolean;
begin
  Result := False;
  const Q = TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.Open(Format('SELECT name FROM sqlite_master WHERE type=''table'' AND name=''%s''', [TableName]));
    if Q.Active then
    begin
      Q.First;
      const F = Q.FindField('name');
      if Assigned(F) then
        Result := F.AsString <> '';
    end;
  finally
    Q.Free;
  end;
end;

end.

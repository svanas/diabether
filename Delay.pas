unit Delay;

interface

uses
  // Delphi
  System.SysUtils;

type
  IDelay = interface
    procedure &Set(proc: TProc; interval: Cardinal);
  end;

function Create: IDelay;

implementation

uses
  // FireMonkey
  FMX.Platform,
  FMX.Types;

type
  TDelay = class(TInterfacedObject, IDelay)
  private
    FHandle: TFmxHandle;
    FProc: TProc;
    FTimer: IFMXTimerService;
    procedure Timer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure &Set(proc: TProc; interval: Cardinal);
    procedure Clear;
  end;

constructor TDelay.Create;
begin
  inherited Create;
  FHandle := cIdNoTimer;
  FTimer := TPlatformServices.Current.GetPlatformService(IFMXTimerService) as IFMXTimerService;
end;

destructor TDelay.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TDelay.Timer;
begin
  Clear;
  if Assigned(FProc) then FProc;
end;

procedure TDelay.&Set(proc: TProc; interval: Cardinal);
begin
  Clear;
  FProc := proc;
  FHandle := FTimer.CreateTimer(interval, Timer);
end;

procedure TDelay.Clear;
begin
  if FHandle <> cIdNoTimer then
  begin
    FTimer.DestroyTimer(FHandle);
    FHandle := cIdNoTimer;
  end;
end;

function Create: IDelay;
begin
  Result := TDelay.Create;
end;

end.

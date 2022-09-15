unit Keyboard;

interface

uses
  // Delphi
  System.Classes,
  System.SysUtils,
  // FireMonkey
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Forms,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Types;

type
  TfrmKeyboard = class(TForm)
    pnlCallout: TCalloutPanel;
    rct1: TRoundRect;
    btn1: TButton;
    rct2: TRoundRect;
    btn2: TButton;
    rct3: TRoundRect;
    btn3: TButton;
    rct4: TRoundRect;
    btn4: TButton;
    rct5: TRoundRect;
    btn5: TButton;
    rct6: TRoundRect;
    btn6: TButton;
    rct7: TRoundRect;
    btn7: TButton;
    rct8: TRoundRect;
    btn8: TButton;
    rct9: TRoundRect;
    btn9: TButton;
    rctAC: TRoundRect;
    btnAC: TButton;
    rct0: TRoundRect;
    btn0: TButton;
    rctOK: TRoundRect;
    btnOK: TButton;
    procedure btnNumClick(Sender: TObject);
    procedure btnACClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    FButton: TButton;
    FDigits: Integer;
    FDecimals: Integer;
    FCallback: TProc;
    procedure Callback;
    procedure Clear;
    procedure KeyPress(Value: Integer);
    procedure SetButton(Value: TButton);
  public
    property Button: TButton read FButton write SetButton;
    property Digits: Integer read FDigits write FDigits;
    property Decimals: Integer read FDecimals write FDecimals;
  end;

function Get(callback: TProc): TfrmKeyboard;

implementation

{$R *.fmx}

uses
  // Delphi
  System.Types,
  // Project
  Settings;

var
  varKeyboard: TfrmKeyboard = nil;

function Get(callback: TProc): TfrmKeyboard;
begin
  if not Assigned(varKeyboard) then
    varKeyboard := TfrmKeyboard.Create(Application);
  varKeyboard.FCallback := callback;
  Result := varKeyboard;
end;

function GetParentTab(aComponent: TFMXObject): TContent;
begin
  Result := nil;
  var P := aComponent.Parent;
  while Assigned(P) do
  begin
    if P is TContent then
    begin
      Result := TContent(P);
      EXIT;
    end;
    P := P.Parent;
  end;
end;

{ TfrmKeyboard }

procedure TfrmKeyboard.Callback;
begin
  if Assigned(FCallback) then FCallback;
end;

procedure TfrmKeyboard.Clear;
begin
  if not Assigned(FButton) then
    EXIT;
  FButton.Text := '0';
  if FDecimals > 0 then
    FButton.Text := FButton.Text + '.0';
end;

procedure TfrmKeyboard.KeyPress(Value: Integer);
begin
  if not Assigned(FButton) then
    EXIT;

  if (FButton.Text <> '') and (StrToFloat(FButton.Text, TSettings.Format) = 0) then
    FButton.Text := '';

  if FDecimals = 0 then
  begin
    if Length(FButton.Text) < FDigits then
      FButton.Text := FButton.Text + IntToStr(Value);
    EXIT;
  end;

  var D1: string := '0';
  var D2: string := '0';

  if FButton.Text <> '' then
  begin
    const I = Pos('.', FButton.Text);
    if I > 0 then
    begin
      D1 := Copy(FButton.Text, 1, I - 1);
      D2 := Copy(FButton.Text, I + 1, MaxInt);
    end;
  end;

  if (StrToIntDef(D1, 0) = 0) and ((StrToIntDef(D2, 0) = 0) or (Length(D2) < FDecimals)) then
  begin
    FButton.Text := D1 + '.';
    if StrToIntDef(D2, 0) <> 0 then
      FButton.Text := FButton.Text + D2;
    FButton.Text := FButton.Text + IntToStr(Value);
    EXIT;
  end;

  if (StrToIntDef(D1, 0) = 0) or (Length(D1) < FDigits) then
  begin
    FButton.Text := '';
    if StrToIntDef(D1, 0) <> 0 then
      FButton.Text := D1;
    if D2 <> '' then
      FButton.Text := FButton.Text + D2[Low(D2)];
    FButton.Text := FButton.Text + '.';
    for var I := 1 to Pred(Length(D2)) do
      FButton.Text := FButton.Text + D2[I];
    FButton.Text := FButton.Text + IntToStr(Value);
    EXIT;
  end;
end;

procedure TfrmKeyboard.SetButton(Value: TButton);
begin
  if Value = FButton then
    EXIT;
  FButton := Value;
  if Assigned(FButton) then
  begin
    Self.Clear;
    pnlCallout.Parent := GetParentTab(FButton);
    pnlCallout.Position.Y := FButton.LocalToAbsolute(TPointF.Create(0, FButton.Height)).Y - 6;
    pnlCallout.Position.X := (GetParentTab(FButton).Width - pnlCallout.Width) / 2;
    pnlCallout.Height := GetParentTab(FButton).Height - pnlCallout.Position.Y - 6;
  end;
  pnlCallout.Visible := Assigned(FButton);
end;

{ event handlers }

procedure TfrmKeyboard.btnNumClick(Sender: TObject);
begin
  if Sender is TButton then
    Self.KeyPress(StrToInt(TButton(Sender).Text));
  Self.Callback;
end;

procedure TfrmKeyboard.btnACClick(Sender: TObject);
begin
  Self.Clear;
  Self.Callback;
end;

procedure TfrmKeyboard.btnOKClick(Sender: TObject);
begin
  Self.Button := nil;
end;

end.

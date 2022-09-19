unit Main;

interface

uses
  // Delphi
  System.Classes,
  System.ImageList,
  // FireMonkey
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.Forms,
  FMX.ImgList,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Objects,
  FMX.Platform,
  FMX.StdCtrls,
  FMX.TabControl,
  FMX.Types,
  // Project
  Delay,
  Misc;

type
  TfrmMain = class(TForm)
    TC: TTabControl;
    tabCalculate: TTabItem;
    tabIOB: TTabItem;
    tabSettings: TTabItem;
    TB: TToolBar;
    btnAuto: TSpeedButton;
    btnMorning: TSpeedButton;
    btnDay: TSpeedButton;
    btnEvening: TSpeedButton;
    GB: TGroupBox;
    lblUnits: TLabel;
    Line1: TLine;
    GL: TGridPanelLayout;
    lblGlucoseLeft: TLabel;
    rctGlucose: TRoundRect;
    btnGlucose: TButton;
    lblGlucoseRight: TLabel;
    lblCarbsLeft: TLabel;
    rctCarbs: TRoundRect;
    btnCarbs: TButton;
    lblCarbsRight: TLabel;
    LB: TListBox;
    lbhTarget: TListBoxGroupHeader;
    lbiTargetMorning: TListBoxItem;
    lbiTargetDay: TListBoxItem;
    lbiTargetEvening: TListBoxItem;
    edtTargetMorning: TEdit;
    edtTargetDay: TEdit;
    edtTargetEvening: TEdit;
    IL: TImageList;
    lghCarbRatio: TListBoxGroupHeader;
    lbiCarbRatioMorning: TListBoxItem;
    lbiCarbRatioDay: TListBoxItem;
    lbiCarbRatioEvening: TListBoxItem;
    edtCarbRatioMorning: TEdit;
    edtCarbRatioDay: TEdit;
    edtCarbRatioEvening: TEdit;
    lghInjectionSchedule: TListBoxGroupHeader;
    lbiAbove8: TListBoxItem;
    edtAbove8: TEdit;
    lbiAbove10: TListBoxItem;
    edtAbove10: TEdit;
    lbiAbove12: TListBoxItem;
    edtAbove12: TEdit;
    lbiAbove14: TListBoxItem;
    edtAbove14: TEdit;
    lbiAbove16: TListBoxItem;
    edtAbove16: TEdit;
    lbiAbove18: TListBoxItem;
    edtAbove18: TEdit;
    lbiAbove20: TListBoxItem;
    edtAbove20: TEdit;
    lbiAbove22: TListBoxItem;
    edtAbove22: TEdit;
    lbiAbove24: TListBoxItem;
    edtAbove24: TEdit;
    procedure btnGlucoseClick(Sender: TObject);
    procedure btnCarbsClick(Sender: TObject);
    procedure tbClick(Sender: TObject);
    procedure edtTargetMorningExit(Sender: TObject);
    procedure edtTargetDayExit(Sender: TObject);
    procedure edtTargetEveningExit(Sender: TObject);
    procedure edtCarbRatioKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure edtCarbRatioMorningExit(Sender: TObject);
    procedure edtCarbRatioDayExit(Sender: TObject);
    procedure edtCarbRatioEveningExit(Sender: TObject);
    procedure edtAboveExit(Sender: TObject);
  private
    FDelay: IDelay;

    function ApplicationEvent(aAppEvent: TApplicationEvent; aContext: TObject): Boolean;
    procedure Calculate;
    procedure edtTargetExit(edit: TEdit; time: TInsulinTime; default: Double);
    function GetButtonTime(btn: TSpeedButton): TInsulinTime;

    procedure GlucoseUnitChanged(Sender: TObject);
    procedure InsulinUnitChanged(Sender: TObject);

    function GetUnits: Double;
    procedure SetUnits(Value: Double);

    function GetGlucose: TBloodGlucose;
    procedure SetGlucose(Value: TBloodGlucose);

    function GetCarbs: Integer;
    procedure SetCarbs(Value: Integer);
  public
    constructor Create(aOwner: TComponent); override;
    property Units: Double read GetUnits write SetUnits;
    property Glucose: TBloodGlucose read GetGlucose write SetGlucose;
    property Carbs: Integer read GetCarbs write SetCarbs;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses
  // Delphi
  System.SysUtils,
  System.UITypes,
  // FireMonkey
  FMX.DialogService,
{$IFDEF IOS}
  FMX.Platform.iOS,
{$ENDIF}
  // Project
  Keyboard,
  Settings;

{ TfrmMain }

constructor TfrmMain.Create(aOwner: TComponent);
resourcestring
  RS_FIRST_TIME = 'Always consult your physician or diabetes clinic before use and please adjust the settings before using the calculator for the first time.';
begin
  inherited Create(aOwner);

  if TPlatformServices.Current.SupportsPlatformService(IFMXApplicationEventService) then
  begin
    const AE = IFMXApplicationEventService(TPlatformServices.Current.GetPlatformService(IFMXApplicationEventService));
    AE.SetApplicationEventHandler(Self.ApplicationEvent);
  end;

  const settings = Settings.Get;
  settings.OnGlucoseUnitChange := GlucoseUnitChanged;
  settings.OnInsulinUnitChange := InsulinUnitChanged;
  GlucoseUnitChanged(Self);

  edtTargetMorning.Text := settings.Target[itMorning].Format;
  edtTargetDay.Text     := settings.Target[itDay].Format;
  edtTargetEvening.Text := settings.Target[itEvening].Format;

  edtCarbRatioMorning.Text := IntToStr(settings.CarbRatio[itMorning]);
  edtCarbRatioDay.Text     := IntToStr(settings.CarbRatio[itDay]);
  edtCarbRatioEvening.Text := IntToStr(settings.CarbRatio[itEvening]);

  edtAbove8.Text  := Format('%.1f', [settings.CorrUnits[TBloodGlucose.Create(8)]], TSettings.Format);
  edtAbove10.Text := Format('%.1f', [settings.CorrUnits[TBloodGlucose.Create(10)]], TSettings.Format);
  edtAbove12.Text := Format('%.1f', [settings.CorrUnits[TBloodGlucose.Create(12)]], TSettings.Format);
  edtAbove14.Text := Format('%.1f', [settings.CorrUnits[TBloodGlucose.Create(14)]], TSettings.Format);
  edtAbove16.Text := Format('%.1f', [settings.CorrUnits[TBloodGlucose.Create(16)]], TSettings.Format);
  edtAbove18.Text := Format('%.1f', [settings.CorrUnits[TBloodGlucose.Create(18)]], TSettings.Format);
  edtAbove20.Text := Format('%.1f', [settings.CorrUnits[TBloodGlucose.Create(20)]], TSettings.Format);
  edtAbove22.Text := Format('%.1f', [settings.CorrUnits[TBloodGlucose.Create(22)]], TSettings.Format);
  edtAbove24.Text := Format('%.1f', [settings.CorrUnits[TBloodGlucose.Create(24)]], TSettings.Format);

  if settings.FirstTime then
  begin
    FDelay := Delay.Create;
    FDelay.&Set(procedure
    begin
      TDialogService.MessageDialog(RS_FIRST_TIME, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, procedure(const aResult: TModalResult)
      begin
        TC.ActiveTab := tabSettings;
      end);
    end, 500);
  end;

  TC.ActiveTab := tabCalculate;
end;

function TfrmMain.ApplicationEvent(aAppEvent: TApplicationEvent; aContext: TObject): Boolean;
begin
{$IFDEF IOS}
  if aAppEvent = TApplicationEvent.OpenURL then
    if Assigned(aContext) then
      if aContext is TiOSOpenApplicationContext then
      begin
        var S := TiOSOpenApplicationContext(aContext).URL;
        var I := Pos('carbs=', S);
        if I > 0 then
        begin
          Delete(S, Low(S), I + 5);
          // delete non-numeric characters
          I := Low(S);
          while I < Length(S) do
             if CharInSet(S[I], ['0'..'9']) then
              Inc(I)
            else
              Delete(S, I, MaxInt);
          // do we have carbs?
          if S <> '' then
          begin
            btnCarbs.Text := S;
            Self.Calculate;
          end;
        end;
      end;
{$ENDIF}
  Result := True;
end;

procedure TfrmMain.Calculate;
begin
  const glucose = Self.Glucose;
  if (glucose.ToMMOL < 4) or (glucose.ToMMOL > 10) then
    btnGlucose.TextSettings.FontColor := TAlphaColorRec.Darkred
  else
    btnGlucose.TextSettings.FontColor := TAlphaColorRec.Null;

  var Result := 0.0;
  try
    var IT := InsulinTime;

    if not btnAuto.IsPressed then
    begin
      const aParent = btnAuto.Parent;
      for var I := 0 to Pred(aParent.ChildrenCount) do
        if aParent.Children[I] is TSpeedButton then
          if TSpeedButton(aParent.Children[I]) <> btnAuto then
            if TSpeedButton(aParent.Children[I]).IsPressed then
            begin
              IT := GetButtonTime(TSpeedButton(aParent.Children[I]));
              BREAK;
            end;
    end;

    const carbRatio = Settings.Get.CarbRatio[IT];
    if carbRatio = 0 then
      EXIT;

    Result := Self.Carbs / carbRatio;

    if glucose = 0 then
      EXIT;

    const target = Settings.Get.Target[IT];
    if glucose.ToMMOL > 8 then
      Result := Result + Settings.Get.CorrUnits[glucose]
    else
      if glucose < target then
      begin
        const corrRatio = Settings.Get.CorrRatio(IT);
        if corrRatio > 0 then
          Result := Result + ((glucose - target) / corrRatio);
      end;
  finally
    Units := RoundInsulin(Result);
  end;
end;

function TfrmMain.GetButtonTime(btn: TSpeedButton): TInsulinTime;
begin
  Result := itMorning;
  if btn = btnDay then
    Result := itDay
  else if btn = btnEvening then
    Result := itEvening;
end;

procedure TfrmMain.GlucoseUnitChanged(Sender: TObject);
begin
  const text = GlucoseUnitText[Settings.Get.GlucoseUnit];
  lblGlucoseRight.Text := text;
  lbhTarget.Text := Format('Target (%s)', [text]);
  for var I in [lbiAbove8, lbiAbove10, lbiAbove12, lbiAbove14, lbiAbove16, lbiAbove18, lbiAbove20, lbiAbove22, lbiAbove24] do
    I.Text := Format('Above %d %s', [I.Children[0].Tag, text]);
end;

procedure TfrmMain.InsulinUnitChanged(Sender: TObject);
begin
  Self.Calculate;
end;

function TfrmMain.GetUnits: Double;
begin
  Result := StrToFloatDef(lblUnits.Text, 0, TSettings.Format);
end;

procedure TfrmMain.SetUnits(Value: Double);
begin
  case Settings.Get.InsulinUnit of
    iuHalf : lblUnits.Text := Format('%.1f', [Value], TSettings.Format);
    iuWhole: lblUnits.Text := Format('%.0f', [Value], TSettings.Format);
  end;
end;

function TfrmMain.GetGlucose: TBloodGlucose;
begin
  Result := TBloodGlucose.Create(StrToFloat(btnGlucose.Text, TSettings.Format));
end;

procedure TfrmMain.SetGlucose(Value: TBloodGlucose);
begin
  btnGlucose.Text := Value.Format;
end;

function TfrmMain.GetCarbs: Integer;
begin
  Result := StrToIntDef(btnCarbs.Text, 0);
end;

procedure TfrmMain.SetCarbs(Value: Integer);
begin
  btnCarbs.Text := IntToStr(Value);
end;

{ event handlers }

procedure TfrmMain.tbClick(Sender: TObject);
begin
  Self.Calculate;
end;

procedure TfrmMain.btnGlucoseClick(Sender: TObject);
begin
  const keyboard = Keyboard.Get(Self.Calculate);
  if keyboard.Button = Sender then
  begin
    keyboard.Button := nil;
    EXIT;
  end;
  case Settings.Get.GlucoseUnit of
    guMMOL: begin
      Keyboard.Digits   := 2;
      Keyboard.Decimals := 1;
    end;
    guMGDL: begin
      Keyboard.Digits   := 3;
      Keyboard.Decimals := 0;
    end;
  end;
  keyboard.Button := Sender as TButton;
  Self.Calculate;
end;

procedure TfrmMain.btnCarbsClick(Sender: TObject);
begin
  const keyboard = Keyboard.Get(Self.Calculate);
  if Keyboard.Button = Sender then
  begin
    Keyboard.Button := nil;
    EXIT;
  end;
  Keyboard.Digits   := 3;
  Keyboard.Decimals := 0;
  Keyboard.Button   := Sender as TButton;
  Self.Calculate;
end;

procedure TfrmMain.edtTargetExit(edit: TEdit; time: TInsulinTime; default: Double);
begin
  const T = TBloodGlucose.Create(
    StrToFloatDef(edit.Text, (function(Value: MMOL): Double
    begin
      Result := Value;
      if Settings.Get.GlucoseUnit = guMGDL then
        Result := MMOL2MGDL(Result);
    end)(default), TSettings.Format)
  );

  edit.Text := T.Format;

  Settings.Get.Target[time] := TBloodGlucose.Create(StrToFloat(edit.Text, TSettings.Format));
end;

procedure TfrmMain.edtTargetMorningExit(Sender: TObject);
begin
  edtTargetExit(edtTargetMorning, itMorning, 5.8);
end;

procedure TfrmMain.edtTargetDayExit(Sender: TObject);
begin
  edtTargetExit(edtTargetDay, itDay, 5.8);
end;

procedure TfrmMain.edtTargetEveningExit(Sender: TObject);
begin
  edtTargetExit(edtTargetEvening, itEvening, 8.0);
end;

procedure TfrmMain.edtCarbRatioKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if KeyChar = '.' then KeyChar := #0
end;

procedure TfrmMain.edtCarbRatioMorningExit(Sender: TObject);
begin
  edtCarbRatioMorning.Text := IntToStr(StrToIntDef(edtCarbRatioMorning.Text, 0));
  Settings.Get.CarbRatio[itMorning] := StrToInt(edtCarbRatioMorning.Text);
end;

procedure TfrmMain.edtCarbRatioDayExit(Sender: TObject);
begin
  edtCarbRatioDay.Text := IntToStr(StrToIntDef(edtCarbRatioDay.Text, 0));
  Settings.Get.CarbRatio[itDay] := StrToInt(edtCarbRatioDay.Text);
end;

procedure TfrmMain.edtCarbRatioEveningExit(Sender: TObject);
begin
  edtCarbRatioEvening.Text := IntToStr(StrToIntDef(edtCarbRatioEvening.Text, 0));
  Settings.Get.CarbRatio[itEvening] := StrToInt(edtCarbRatioEvening.Text);
end;

procedure TfrmMain.edtAboveExit(Sender: TObject);
begin
  const E = Sender as TEdit;
  const V = StrToFloatDef(E.Text, 0, TSettings.Format);
  E.Text := Format('%.1f', [V], TSettings.Format);
  Settings.Get.CorrUnits[TBloodGlucose.Create(E.Tag)] := StrToFloat(E.Text, TSettings.Format);
end;

end.

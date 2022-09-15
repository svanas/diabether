program Diabether;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main in 'Main.pas' {frmMain},
  Settings in 'Settings.pas',
  Keyboard in 'Keyboard.pas' {frmKeyboard},
  Database in 'Database.pas',
  Delay in 'Delay.pas',
  Misc in 'Misc.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

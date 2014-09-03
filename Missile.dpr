program Missile;

uses
  Forms,
  UPrincipal in 'UPrincipal.pas' {FmMain},
  UFrameRate in 'UFrameRate.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFmMain, FmMain);
  Application.Run;
end.

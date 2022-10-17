program togyz;

uses
  System.StartUpCopy,
  FMX.Forms,
  main in 'main.pas' {TogyzForm},
  tog in 'tog.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TTogyzForm, TogyzForm);
  Application.Run;
end.

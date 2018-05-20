program Resizer;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  Process in 'Process.pas' {ProcessForm},
  SpecialDirectory in 'SpecialDirectory.pas',
  ImageWriter in 'ImageWriter.pas',
  NColorReduction in 'NColorReduction.pas',
  ImageFilter in 'ImageFilter.pas',
  Log in 'Log.pas',
  exif in 'exif.pas',
  pstretchf in 'pstretchf.pas',
  ParallelUtils in 'ParallelUtils.pas',
  SpiUtils in 'SpiUtils.pas',
  XpiUtils in 'XpiUtils.pas',
  AboutUtils in 'AboutUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := '藤 -Resizer-';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TProcessForm, ProcessForm);
  Application.Run;
end.

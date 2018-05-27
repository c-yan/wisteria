program Resizer;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  Process in 'Process.pas' {ProcessForm},
  SpecialDirectory in 'SpecialDirectory.pas',
  Log in 'Log.pas',
  ParallelUtils in 'ParallelUtils.pas',
  {$IFNDEF WIN64}
  SpiUtils in 'SpiUtils.pas',
  {$ENDIF }
  AboutUtils in 'AboutUtils.pas',
  Helper in 'Helper.pas',
  ImageFilter in 'ImageLib\ImageFilter.pas',
  ImageWriter in 'ImageLib\ImageWriter.pas',
  NColorReduction in 'ImageLib\NColorReduction.pas',
  pstretchf in 'ImageLib\pstretchf.pas',
  exif in 'ImageLib\exif.pas',
  ImageTypes in 'ImageLib\ImageTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := '藤 -Resizer-';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TProcessForm, ProcessForm);
  Application.Run;
end.

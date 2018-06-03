program Resizer;

{$WEAKLINKRTTI ON}

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  Process in 'Process.pas' {ProcessForm},
  ImageFilter in 'ImageLib\ImageFilter.pas',
  ImageWriter in 'ImageLib\ImageWriter.pas',
  NColorReduction in 'ImageLib\NColorReduction.pas',
  pstretchf in 'ImageLib\pstretchf.pas',
  exif in 'ImageLib\exif.pas',
  ImageTypes in 'ImageLib\ImageTypes.pas',
  SpiUtils in 'ImageLib\SpiUtils.pas',
  AboutUtils in 'Lib\AboutUtils.pas',
  Log in 'Lib\Log.pas',
  ParallelUtils in 'Lib\ParallelUtils.pas',
  Helper in 'Lib\Helper.pas',
  CommonUtils in 'Lib\CommonUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := '藤 -Resizer-';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TProcessForm, ProcessForm);
  Application.Run;
end.

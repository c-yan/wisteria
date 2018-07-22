program Resizer;

{$WEAKLINKRTTI ON}

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm} ,
  Process in 'Process.pas' {ProcessForm} ,
  ExifReader in 'ImageLib\ExifReader.pas',
  ImageColorQuantizer in 'ImageLib\ImageColorQuantizer.pas',
  ImageFilters in 'ImageLib\ImageFilters.pas',
  ImageFunctions in 'ImageLib\ImageFunctions.pas',
  ImageStretcher in 'ImageLib\ImageStretcher.pas',
  ImageTypes in 'ImageLib\ImageTypes.pas',
  ImageWriters in 'ImageLib\ImageWriters.pas',
  SpiUtils in 'ImageLib\SpiUtils.pas',
  AboutUtils in 'Lib\AboutUtils.pas',
  CommonUtils in 'Lib\CommonUtils.pas',
  Helpers in 'Lib\Helpers.pas',
  Logging in 'Lib\Logging.pas',
  ParallelUtils in 'Lib\ParallelUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := '藤 -Resizer-';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TProcessForm, ProcessForm);
  Application.Run;

end.

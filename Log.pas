unit Log;

interface

uses
  SysUtils;

procedure InitLog(FileName: string);
procedure Error(Text: string);
procedure Warn(Text: string);
procedure Info(Text: string);
procedure Debug(Text: string);

var
  DebugEnabled: Boolean = False;

implementation

var
  LogFileName: string = '';

procedure InitLog(FileName: string);
var
  F: TextFile;
begin
  LogFileName := FileName;
  if LogFileName = '' then Exit;
  if not DirectoryExists(ExtractFilePath(LogFileName)) then
    ForceDirectories(ExtractFilePath(LogFileName));
  if not FileExists(LogFileName) then
  begin
    AssignFile(F, LogFileName);
    try
      Rewrite(F);
    finally
      Close(F);
    end;
  end;
end;

procedure Logging(Category, Text: string);
var
  F: TextFile;
  T: string;
begin
  if LogFileName = '' then Exit;
  AssignFile(F, LogFileName);
  T := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now());
  try
    Append(F);
    Writeln(F, Format('%s %-5s - %s', [T, Category, Text]));
  finally
    CloseFile(F);
  end;
end;

procedure Error(Text: string);
begin
  Logging('ERROR', Text);
end;

procedure Warn(Text: string);
begin
  Logging('WARN', Text);
end;

procedure Info(Text: string);
begin
  Logging('INFO', Text);
end;

procedure Debug(Text: string);
begin
  if DebugEnabled then Logging('DEBUG', Text);
end;

end.

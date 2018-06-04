unit ExifReader;

interface

uses
  System.Classes, System.SysUtils, System.Math, Helpers;

function GetOriginalDateTime(FileName: string): AnsiString;
function GetModel(FileName: string): AnsiString;
function GetOrientation(FileName: string): Integer;
function GetGamma(FileName: string): Double;
function GetColorSpace(FileName: string): Integer;

implementation

var
  IsLittleEndian: Boolean;

function TrimNullString(const S: AnsiString): AnsiString;
var
  I: Integer;
begin
  I := Length(S);
  while (I > 0) and (S[I] = #0) do Dec(I);
  Result := Copy(S, 1, I);
end;

procedure CheckExifHeader(FileStream: TFileStream);
var
  S: AnsiString;
  B: Byte;
begin
  IsLittleEndian := True;

  // SOI Marker
  if FileStream.ReadByte <> $FF then raise Exception.Create('Marker ID is missing');
  if FileStream.ReadByte <> $D8 then raise Exception.Create('SOI Marker is missing');

  // APP Marker
  if FileStream.ReadByte <> $FF then raise Exception.Create('Marker ID is missing');
  B := FileStream.ReadByte;
  if B = $E0 then
  begin
    // APP0 Marker
    FileStream.Skip(16);

    // APP1 marker
    if FileStream.ReadByte <> $FF then raise Exception.Create('Marker ID is missing');
    if FileStream.ReadByte <> $E1 then raise Exception.Create('APP1 Marker is missing');
  end
  else if B <> $E1 then raise Exception.Create('APP1 Marker is missing');

  FileStream.ReadByte;
  FileStream.ReadByte;

  // Exif Header
  if FileStream.ReadString(6) <> 'Exif'#0#0 then raise Exception.Create('EXIF Header is missing');
  S := FileStream.ReadString(2);
  if S = 'II' then IsLittleEndian := True
  else if S = 'MM' then IsLittleEndian := False
  else raise Exception.Create('EXIF Header endian is corrupted');

  // TAG Mark
  if FileStream.ReadCardinal(2, IsLittleEndian) <> $002a then raise Exception.Create('TAG Mark is missing');

  // Offset to first IFD
  if FileStream.ReadCardinal(4, IsLittleEndian) <> $00000008 then raise Exception.Create('Offset is corrupted');
end;

function IsValue(FileStream: TFileStream; Size: Integer; Value: Cardinal): Boolean;
begin
  Result := FileStream.ReadCardinal(Size, IsLittleEndian) = value;
end;

procedure SetOffset(FileStream: TFileStream);
var
  NextPos: Integer;
begin
  NextPos := 12 + FileStream.ReadCardinal(4, IsLittleEndian);
  if FileStream.Seek(NextPos, soFromBeginning) <> NextPos then
    raise Exception.Create('SetOffset failed');
end;

procedure SearchEntry(FileStream: TFileStream; Tag: Cardinal);
var
  I, EntryCount: Integer;
begin
  // Directory Entry Count
  EntryCount := FileStream.ReadCardinal(2, IsLittleEndian);
  for I := 0 to EntryCount - 1 do
  begin
    if IsValue(FileStream, 2, Tag) then Exit;
    FileStream.Skip(10);
  end;
  raise Exception.Create('Tag is not found');
end;

procedure SearchExifIfd(FileStream: TFileStream);
begin
  // Search ExifIFDPointer(34665)
  SearchEntry(FileStream, $8769);
  if not IsValue(FileStream, 2, $0004) then raise Exception.Create('Corrupted Data');
  if not IsValue(FileStream, 4, $00000001) then raise Exception.Create('Corrupted Data');
  SetOffset(FileStream);
end;

function GetOriginalDateTime(FileName: string): AnsiString;
const
  DATE_TIME_LEN = 19;
var
  FileStream: TFileStream;
begin
  Result := '';
  FileStream := TFileStream.Create(FileName, fmOpenRead);
  try
    CheckExifHeader(FileStream);
    SearchExifIfd(FileStream);
    // 0x9003
    SearchEntry(FileStream, $9003);
    if not isValue(FileStream, 2, $0002) then raise Exception.Create('Corrupted Data');
    if not isValue(FileStream, 4, 20) then raise Exception.Create('Corrupted Data');
    SetOffset(FileStream);
    Result := FileStream.ReadString(DATE_TIME_LEN);
  except
    on Exception do;
  end;
  FileStream.Free;
end;

function GetModel(FileName: string): AnsiString;
const
  MODEL_MAX_LEN = 255;
var
  FileStream: TFileStream;
  ModelLength: Cardinal;
begin
  Result := '';
  FileStream := TFileStream.Create(FileName, fmOpenRead);
  try
    CheckExifHeader(FileStream);
    // 0x0110
    SearchEntry(FileStream, $0110);
    if not isValue(FileStream, 2, $0002) then raise Exception.Create('Corrupted Data');
    ModelLength := Min(FileStream.ReadCardinal(4, IsLittleEndian), MODEL_MAX_LEN);
    SetOffset(FileStream);
    Result := TrimNullString(FileStream.ReadString(ModelLength));
  except
    on Exception do;
  end;
  FileStream.Free;
end;

function GetOrientation(FileName: string): Integer;
var
  FileStream: TFileStream;
begin
  Result := -1;
  FileStream := TFileStream.Create(FileName, fmOpenRead);
  try
    CheckExifHeader(FileStream);
    // 0x0112
    SearchEntry(FileStream, $0112);
    if not isValue(FileStream, 2, $0003) then raise Exception.Create('Corrupted Data');
    if not isValue(FileStream, 4, $00000001) then raise Exception.Create('Corrupted Data');
    Result := FileStream.ReadCardinal(2, IsLittleEndian);
  except
    on Exception do;
  end;
  FileStream.Free;
end;

function GetGamma(FileName: string): Double;
var
  FileStream: TFileStream;
  Numerator, Denominator: Cardinal;
begin
  Result := 0;
  FileStream := TFileStream.Create(FileName, fmOpenRead);
  try
    CheckExifHeader(FileStream);
    SearchExifIfd(FileStream);
    // Search Gamma Value(42240)
    SearchEntry(FileStream, $a500);
    if not isValue(FileStream, 2, $0005) then raise Exception.Create('Corrupted Data');
    if not isValue(FileStream, 4, $00000001) then raise Exception.Create('Corrupted Data');
    SetOffset(FileStream);

    Numerator := FileStream.ReadCardinal(4, IsLittleEndian);
    Denominator := FileStream.ReadCardinal(4, IsLittleEndian);
    if Denominator = 0 then raise Exception.Create('Denominator is 0');
    Result := Numerator / Denominator;
  except
    on Exception do;
  end;
  FileStream.Free;
end;

function GetColorSpace(FileName: string): Integer;
var
  FileStream: TFileStream;
begin
  Result := -1;
  FileStream := TFileStream.Create(FileName, fmOpenRead);
  try
    CheckExifHeader(FileStream);
    SearchExifIfd(FileStream);
    // 0xA001 sRGB = 1,  Uncalibrated = 65535
    SearchEntry(FileStream, $A001);
    if not isValue(FileStream, 2, $0003) then raise Exception.Create('Corrupted Data');
    if not isValue(FileStream, 4, $00000001) then raise Exception.Create('Corrupted Data');
    Result := FileStream.ReadCardinal(2, IsLittleEndian);
  except
    on Exception do;
  end;
  FileStream.Free;
end;

end.

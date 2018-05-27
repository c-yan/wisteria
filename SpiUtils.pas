unit SpiUtils;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, Vcl.Forms, Vcl.Graphics;

function IsLoadableBySpi(Ext: string): Boolean;
function IsSavableByXpi(Ext: string): Boolean;
procedure LoadBySpi(FileName: string; Src: TBitmap);
procedure SaveByXpi(FileName: string; Src: TBitmap);
procedure DumpSpiMapInfo();
procedure DumpXpiMapInfo();

implementation

type
  TPictureInfo = packed record
    Left: Longint;
    Top: Longint;
    Width: Longint;
    Height: Longint;
    XDensity: Word;
    YDensitiy: Word;
    ColorDepth: SmallInt;
    Info: HLOCAL;
  end;

  TProgressCallback = function(nNum, nDenom: Integer; lData: Longint): Integer; stdcall;
  TGetPluginInfo = function(InfoNo: Longint; Buf: PAnsiChar; BufLen: Longint): Integer; stdcall;
  TGetPicture = function(Buf: PAnsiChar; Len: Longint; Flag: Longword; var HBInfo: HLOCAL; var HBm: HLOCAL; ProgressCallback: TProgressCallback; lData: Longint): Integer; stdcall;
  TCreatePicture = function(FilePath: PAnsiChar; Flag: Longword; HBInfo: PHANDLE; HBm: PHANDLE; var PictureInfo: TPictureInfo; ProgressCallback: TProgressCallback; lData: Longint): Integer; stdcall;

var
  GetPluginInfo: TGetPluginInfo;
  GetPicture: TGetPicture;
  CreatePicture: TCreatePicture;
  SpiMapInfo: TStrings;
  XpiMapInfo: TStrings;

function IsLoadableBySpi(Ext: string): Boolean;
begin
  Result := SpiMapInfo.IndexOfName(Ext) <> -1;
end;

function IsSavableByXpi(Ext: string): Boolean;
begin
  Result := XpiMapInfo.IndexOfName(Ext) <> -1;
end;

procedure InitSpi();
  procedure AddSpi(FileName: string);
  var
    I: Cardinal;
    A: AnsiString;
    S: string;
    List: TStringList;
    HDLL: HINST;
  const
    BufSize = 256;
  begin
    HDLL := LoadLibrary(PChar(FileName));
    GetPluginInfo := GetProcAddress(HDLL, 'GetPluginInfo');
    SetLength(A, 5);
    GetPluginInfo(0, PAnsiChar(A), 5);
    SetLength(A, 4);
    if A = '00IN' then
    begin
      SetLength(A, BufSize);
      GetPluginInfo(2, PAnsiChar(A), BufSize);
      SetLength(A, StrLen(PAnsiChar(A)));
      S := LowerCase(string(A));
      S := StringReplace(S, '*.', '', [rfReplaceAll]);
      S := StringReplace(S, ' ', '', [rfReplaceAll]);
      List := TStringList.Create;
      try
        List.Text := StringReplace(S, ';', #13#10, [rfReplaceAll]);
        for I := 0 to List.Count - 1 do
        begin
          SpiMapInfo.Values[List.Strings[I]] := FileName;
        end;
      finally
        List.Free;
      end;
    end;
    FreeLibrary(HDLL);
  end;

  procedure GetSpiList(Dir: string; FileList: TStrings);
  var
    Handle: THandle;
    Data: TWin32FindData;
  begin
    Handle := Winapi.Windows.FindFirstFile(PChar(Dir + '*.spi'), Data);
    if Handle = INVALID_HANDLE_VALUE then Exit;
    FileList.Add(Dir + Data.cFileName);
    while Winapi.Windows.FindNextFile(Handle, Data) = True do
    begin
      FileList.Add(Dir + Data.cFileName);
    end;
    Winapi.Windows.FindClose(Handle);
  end;

  var
  I: Integer;
  SpiList: TStrings;
begin
  SpiList := TStringList.Create;
  try
    GetSpiList(ExtractFilePath(Application.ExeName), SpiList);
    for I := 0 to SpiList.Count - 1 do
    begin
      AddSpi(SpiList.Strings[I]);
    end;
  finally
    SpiList.Free;
  end;
end;

procedure InitXpi();
  procedure AddXpi(FileName: string);
  var
    I: Cardinal;
    A: AnsiString;
    S: string;
    List: TStringList;
    HDLL: HINST;
  const
    BufSize = 256;
  begin
    HDLL := LoadLibrary(PChar(FileName));
    GetPluginInfo := GetProcAddress(HDLL, 'GetPluginInfo');
    SetLength(A, 5);
    GetPluginInfo(0, PAnsiChar(A), 5);
    SetLength(A, 4);
    if A = 'T0XN' then
    begin
      SetLength(A, BufSize);
      GetPluginInfo(2, PAnsiChar(A), BufSize);
      SetLength(A, StrLen(PAnsiChar(A)));
      S := LowerCase(string(A));
      S := StringReplace(S, '*.', '', [rfReplaceAll]);
      S := StringReplace(S, ' ', '', [rfReplaceAll]);
      List := TStringList.Create;
      try
        List.Text := StringReplace(S, ';', #13#10, [rfReplaceAll]);
        for I := 0 to List.Count - 1 do
        begin
          XpiMapInfo.Values[List.Strings[I]] := FileName;
        end;
      finally
        List.Free;
      end;
    end;
    FreeLibrary(HDLL);
  end;

  procedure GetXpiList(Dir: string; FileList: TStrings);
  var
    Handle: THandle;
    Data: TWin32FindData;
  begin
    Handle := Winapi.Windows.FindFirstFile(PChar(Dir + '*.xpi'), Data);
    if Handle = INVALID_HANDLE_VALUE then Exit;
    FileList.Add(Dir + Data.cFileName);
    while Winapi.Windows.FindNextFile(Handle, Data) = True do
    begin
      FileList.Add(Dir + Data.cFileName);
    end;
    Winapi.Windows.FindClose(Handle);
  end;

  var
  I: Integer;
  XpiList: TStrings;
begin
  XpiList := TStringList.Create;
  try
    GetXpiList(ExtractFilePath(Application.ExeName), XpiList);
    for I := 0 to XpiList.Count - 1 do
    begin
      AddXpi(XpiList.Strings[I]);
    end;
  finally
    XpiList.Free;
  end;
end;

procedure LoadBySpi(FileName: string; Src: TBitmap);
var
  pHBInfo, pHBm: HLOCAL;
  BitmapInfo: ^TBitmapInfo;
  Ext: string;
  HDLL: HINST;
begin
  Ext := ExtractFileExt(FileName);
  Ext := Copy(Ext, 2, Length(Ext));
  if IsLoadableBySpi(Ext) then
  begin
    HDLL := LoadLibrary(PChar(SpiMapInfo.Values[Ext]));
    GetPicture := GetProcAddress(HDLL, 'GetPicture');
    if GetPicture(PAnsiChar(AnsiString(FileName)), 0, 0, pHBInfo, pHBm, nil, 0) = 0 then
    begin
      BitmapInfo := LocalLock(pHBInfo);
      Src.Width := BitmapInfo^.bmiHeader.biWidth;
      Src.Height := BitmapInfo^.bmiHeader.biHeight;
      Src.PixelFormat := pf24bit;
      SetDIBits(Src.Canvas.Handle, Src.Handle, 0, BitmapInfo^.bmiHeader.biHeight,
        LocalLock(pHBm), BitmapInfo^, DIB_RGB_COLORS);
      LocalUnlock(pHBm);
      LocalUnlock(pHBInfo);
      LocalFree(pHBInfo);
      LocalFree(pHBm);
    end;
    FreeLibrary(HDLL);
  end;
end;

procedure SaveByXpi(FileName: string; Src: TBitmap);
var
  Ext: string;
  HDLL: HINST;
  PictureInfo: TPictureInfo;
  DS: TDIBSECTION;
begin
  Ext := ExtractFileExt(FileName);
  Ext := Copy(Ext, 2, Length(Ext));
  if IsSavableByXpi(Ext) then
  begin
    HDLL := LoadLibrary(PChar(XpiMapInfo.Values[Ext]));
    CreatePicture := GetProcAddress(HDLL, 'CreatePicture');
    ZeroMemory(@PictureInfo, SizeOf(PictureInfo));
    GetObject(Src.Handle, sizeof(DIBSECTION), @DS);
    CreatePicture(PAnsiChar(AnsiString(FileName)), 1, @DS.dsBmih, DS.dsBm.bmBits, PictureInfo, nil, 0);
    FreeLibrary(HDLL);
  end;
end;

procedure DumpSpiMapInfo();
begin
  SpiMapInfo.SaveToFile(ExtractFilePath(Application.ExeName) + '\spi.ini');
end;

procedure DumpXpiMapInfo();
begin
  XpiMapInfo.SaveToFile(ExtractFilePath(Application.ExeName) + '\xpi.ini');
end;

initialization
  SpiMapInfo := TStringList.Create;
  XpiMapInfo := TStringList.Create;
  InitSpi();
  InitXpi();

finalization
  XpiMapInfo.Free;
  SpiMapInfo.Free;

end.

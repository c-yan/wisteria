unit SpiUtils;


interface

uses Windows, Classes, SysUtils, Forms, Graphics;

procedure LoadViaSpi(FileName: string; Src: TBitmap);
function IsLoadableViaSpi(Ext: string): Boolean;
procedure DumpMapInfo();

implementation

type
  TProgressCallback = function(nNum, nDenom: Integer; lData: Longint): Integer; stdcall;
  TGetPluginInfo = function(InfoNo: Longint; Buf: PAnsiChar; BufLen: Longint): Integer; stdcall;
  TGetPicture = function(Buf: PAnsiChar; Len: Longint; Flag: Longword; var HBInfo: HLOCAL; var HBm: HLOCAL; ProgressCallback: TProgressCallback; lData: Longint): Integer; stdcall;

var
  GetPluginInfo: TGetPluginInfo;
  GetPicture: TGetPicture;
  MapInfo: TStrings;

function IsLoadableViaSpi(Ext: string): Boolean;
begin
  Result := MapInfo.IndexOfName(Ext) <> -1;
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
          MapInfo.Values[List.Strings[I]] := FileName;
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
    Handle := Windows.FindFirstFile(PChar(Dir + '*.spi'), Data);
    if Handle = INVALID_HANDLE_VALUE then Exit;
    FileList.Add(Dir + Data.cFileName);
    while Windows.FindNextFile(Handle, Data) = True do
    begin
      FileList.Add(Dir + Data.cFileName);
    end;
    Windows.FindClose(Handle);
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

procedure DumpMapInfo();
begin
  MapInfo.SaveToFile(ExtractFilePath(Application.ExeName) + '\spi.ini');
end;

procedure LoadViaSpi(FileName: string; Src: TBitmap);
var
  pHBInfo, pHBm: HLOCAL;
  BitmapInfo: ^TBitmapInfo;
  Ext: string;
  HDLL: HINST;
begin
  Ext := ExtractFileExt(FileName);
  Ext := Copy(Ext, 2, Length(Ext));
  if IsLoadableViaSpi(Ext) then
  begin
    HDLL := LoadLibrary(PChar(MapInfo.Values[Ext]));
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

initialization
  MapInfo := TStringList.Create;
  InitSpi();

finalization
  MapInfo.Free;

end.

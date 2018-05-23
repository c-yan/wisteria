unit XpiUtils;


interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, Vcl.Forms, Vcl.Graphics;

procedure SaveViaXpi(FileName: string; Src: TBitmap);
function IsLoadableViaXpi(Ext: string): Boolean;
procedure DumpMapInfo();

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
  TCreatePicture = function(FilePath: PAnsiChar; Flag: Longword; HBInfo: PHANDLE; HBm: PHANDLE; var PictureInfo: TPictureInfo; ProgressCallback: TProgressCallback; lData: Longint): Integer; stdcall;

var
  GetPluginInfo: TGetPluginInfo;
  CreatePicture: TCreatePicture;
  MapInfo: TStrings;

function IsLoadableViaXpi(Ext: string): Boolean;
begin
  Result := MapInfo.IndexOfName(Ext) <> -1;
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
          MapInfo.Values[List.Strings[I]] := FileName;
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

procedure DumpMapInfo();
begin
  MapInfo.SaveToFile(ExtractFilePath(Application.ExeName) + '\xpi.ini');
end;

procedure SaveViaXpi(FileName: string; Src: TBitmap);
var
  Ext: string;
  HDLL: HINST;
  PictureInfo: TPictureInfo;
  DS: TDIBSECTION;
begin
  Ext := ExtractFileExt(FileName);
  Ext := Copy(Ext, 2, Length(Ext));
  if IsLoadableViaXpi(Ext) then
  begin
    HDLL := LoadLibrary(PChar(MapInfo.Values[Ext]));
    CreatePicture := GetProcAddress(HDLL, 'CreatePicture');
    ZeroMemory(@PictureInfo, SizeOf(PictureInfo));
    GetObject(Src.Handle, sizeof(DIBSECTION), @DS);
    CreatePicture(PAnsiChar(AnsiString(FileName)), 1, @DS.dsBmih, DS.dsBm.bmBits, PictureInfo, nil, 0);
    FreeLibrary(HDLL);
  end;
end;

initialization
  MapInfo := TStringList.Create;
  InitXpi();

finalization
  MapInfo.Free;

end.

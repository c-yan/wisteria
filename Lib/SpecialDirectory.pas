unit SpecialDirectory;

interface

uses
  Winapi.Windows, System.SysUtils, Winapi.ShlObj;

function MyDocumentsDirectory: string;
function DesktopDirectory: string;

implementation

function GetSpecialDirectory(FolderID: Integer): string;
var
  PIDL: PItemIDList;
begin
  SetLength(Result, MAX_PATH);
  SHGetSpecialFolderLocation(0, FolderID, PIDL);
  SHGetPathFromIDList(PIDL, PChar(Result));
  SetLength(Result, StrLen(PChar(Result)));
end;

function MyDocumentsDirectory: string;
begin
  Result := GetSpecialDirectory(CSIDL_PERSONAL);
end;

function DesktopDirectory: string;
begin
  Result := GetSpecialDirectory(CSIDL_DESKTOPDIRECTORY);
end;

end.

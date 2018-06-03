unit AboutUtils;

interface

uses
  Winapi.Windows, Vcl.Forms, Winapi.ShellApi;

resourcestring
  MailAddress = 'recv@cyanet.jp';
  WebAddress = 'http://hp.vector.co.jp/authors/VA015850/';
  GitHubAddress = 'https://github.com/c-yan/wisteria/';
  GitHubIssuesAddress = 'https://github.com/c-yan/wisteria/issues';
  TwitterId = '@c_nyan';

procedure AboutBox;
procedure GoWeb;
procedure GoGitHub;
procedure GoGitHubIssues;
procedure SendMail;

implementation

procedure AboutBox;
var
  BuffSize, Ignore: Cardinal;
  P: Pointer;
  FileDescription, LegalCopyright, ProductName, ProductVersion: PChar;
begin
  BuffSize := GetFileVersionInfoSize(PChar(Application.ExeName), Ignore);
  GetMem(P, BuffSize);
  try
    if GetFileVersionInfo(PChar(Application.ExeName), Ignore, BuffSize, P) then
    begin
      VerQueryValue(P, PChar('\StringFileInfo\041103A4\FileDescription'), Pointer(FileDescription), Ignore);
      VerQueryValue(P, PChar('\StringFileInfo\041103A4\LegalCopyright'),  Pointer(LegalCopyright),  Ignore);
      VerQueryValue(P, PChar('\StringFileInfo\041103A4\ProductName'),     Pointer(ProductName),     Ignore);
      VerQueryValue(P, PChar('\StringFileInfo\041103A4\ProductVersion'),  Pointer(ProductVersion),  Ignore);
      Application.MessageBox(
        PChar(
          FileDescription + string(' ') + ProductVersion + #13#10 +
          LegalCopyright                                 + #13#10 +
          ''                                             + #13#10 +
          'mail: '    + MailAddress                      + #13#10 +
          'twitter: ' + TwitterId                        + #13#10 +
          'webpage: ' + WebAddress                       + '    '
        ),
        ProductName,
        MB_OK
      );
    end;
  finally
    FreeMem(P);
  end;
end;

procedure OpenUrl(const URL: string);
begin
  ShellExecute(0, nil, PChar(URL), nil, nil, SW_SHOW);
end;

procedure GoWeb;
begin
  OpenUrl(WebAddress);
end;

procedure GoGitHub;
begin
  OpenUrl(GitHubAddress);
end;

procedure GoGitHubIssues;
begin
  OpenUrl(GitHubIssuesAddress);
end;

procedure SendMail;
begin
  ShellExecute(0, nil, PChar('mailto:' + MailAddress), nil, nil, SW_SHOW);
end;

end.

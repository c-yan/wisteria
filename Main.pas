unit Main;

interface

{$DEFINE NoJPEGSubsampling}

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellApi, Winapi.ShlObj,
  System.SysUtils, System.Classes, System.SyncObjs, System.IniFiles,
  System.Win.ComObj, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Menus, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Clipbrd,
  Vcl.FileCtrl, Vcl.Imaging.GIFImg, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage,
  Process, ImageTypes, ExifReader, ImageWriters, ImageStretcher, ImageFilters,
  SpiUtils, ImageColorQuantizer, Logging, AboutUtils, ParallelUtils,
  CommonUtils;

type
  TValueType = (vtAbsolute, vtRelative);
  TRatioBase = (rbWidth, rbHeight, rbLong, rbShort, rbMax, rbMin);

  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    StatusBar: TStatusBar;
    ExitMenu: TMenuItem;
    ConfigMenu: TMenuItem;
    SizeGroupBox: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    UnitLabel1: TLabel;
    UnitLabel2: TLabel;
    FilePatternGroupBox: TGroupBox;
    FilePatternEdit: TEdit;
    SizeRadioGroup: TRadioGroup;
    OnTopMenu: TMenuItem;
    HelpMenu: TMenuItem;
    AboutMenu: TMenuItem;
    RatioKeepCheckBox: TCheckBox;
    HTMLCheckBox: TCheckBox;
    N1: TMenuItem;
    GoWebMenu: TMenuItem;
    SendMailMenu: TMenuItem;
    N2: TMenuItem;
    ClipBoardMenu: TMenuItem;
    CopyTimeStampMenu: TMenuItem;
    JpegQualityMenu: TMenuItem;
    HTMLReversePlaceMenu: TMenuItem;
    SampleMenu: TMenuItem;
    OpenFolderMenu: TMenuItem;
    N4: TMenuItem;
    SharpValueMenu: TMenuItem;
    PngCompressMenu: TMenuItem;
    N5: TMenuItem;
    SaveMenu: TMenuItem;
    OpenMenu: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    AvoidCollisionMenu: TMenuItem;
    NonMagnifyMenu: TMenuItem;
    EffectMenu: TMenuItem;
    SharpEffectMenu: TMenuItem;
    CleanEffectMenu: TMenuItem;
    NormalizeMenu: TMenuItem;
    GrayscaleMenu: TMenuItem;
    CleanValueMenu: TMenuItem;
    ProgressiveJpegMenu: TMenuItem;
    GammaFixMenu: TMenuItem;
    GammaValueMenu: TMenuItem;
    ContrastFixMenu: TMenuItem;
    ContrastValueMenu: TMenuItem;
    NormalizeRangeMenu: TMenuItem;
    LumaFixMenu: TMenuItem;
    LumaRangeMenu: TMenuItem;
    ValuesMenu: TMenuItem;
    CondGroupBox: TGroupBox;
    CondComboBox: TComboBox;
    TrimMenu: TMenuItem;
    TrimValueMenu: TMenuItem;
    TurnOverMenu: TMenuItem;
    RotateMenu: TMenuItem;
    RotateAngleMenu: TMenuItem;
    GrayscaleMethodMenu: TMenuItem;
    OutputMenu: TMenuItem;
    LMapMenu: TMenuItem;
    LMapValueMenu: TMenuItem;
    WidthEdit: TEdit;
    HeightEdit: TEdit;
    AutoIndexedMenu: TMenuItem;
    WhiteValueMenu: TMenuItem;
    ExifAutoRotateMenu: TMenuItem;
    WhiteFilterMenu: TMenuItem;
    IncludeSubDirMenu: TMenuItem;
    IdleModeMenu: TMenuItem;
    FileListSortMenu: TMenuItem;
    N7: TMenuItem;
    N3: TMenuItem;
    Enlarge1Menu: TMenuItem;
    Enlarge2Menu: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    Reduce1Menu: TMenuItem;
    Reduce2Menu: TMenuItem;
    Reduce4Menu: TMenuItem;
    Reduce3Menu: TMenuItem;
    Enlarge3Menu: TMenuItem;
    Enlarge4Menu: TMenuItem;
    Reduce5Menu: TMenuItem;
    Enlarge5Menu: TMenuItem;
    CompressionMenu: TMenuItem;
    N8: TMenuItem;
    {$IFNDEF NoJPEGSubsampling}
    JPEGSubsamplingMenu: TMenuItem;
    {$ENDIF}
    N6: TMenuItem;
    LinearizedReductionMenu: TMenuItem;
    ShowHelpMenu: TMenuItem;
    GoGitHubMenu: TMenuItem;
    GoGitHubIssuesMenu: TMenuItem;
    procedure WhiteValueMenuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ExitMenuClick(Sender: TObject);
    procedure AboutMenuClick(Sender: TObject);
    procedure RatioKeepCheckBoxClick(Sender: TObject);
    procedure SizeRadioGroupClick(Sender: TObject);
    procedure WidthEditChange(Sender: TObject);
    procedure HeightEditChange(Sender: TObject);
    procedure OnTopMenuClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GoWebMenuClick(Sender: TObject);
    procedure SendMailMenuClick(Sender: TObject);
    procedure ClipBoardMenuClick(Sender: TObject);
    procedure JpegQualityMenuClick(Sender: TObject);
    procedure SampleMenuXClick(Sender: TObject);
    procedure SharpValueMenuClick(Sender: TObject);
    procedure OpenMenuClick(Sender: TObject);
    procedure SaveMenuClick(Sender: TObject);
    procedure CheckMenuClick(Sender: TObject);
    procedure CleanValueMenuClick(Sender: TObject);
    procedure GammaValueMenuClick(Sender: TObject);
    procedure ContrastValueMenuClick(Sender: TObject);
    procedure NormalizeRangeMenuClick(Sender: TObject);
    procedure LumaRangeMenuClick(Sender: TObject);
    procedure TrimValueMenuClick(Sender: TObject);
    procedure RotateAngleMenuClick(Sender: TObject);
    procedure GrayscaleMethodMenuClick(Sender: TObject);
    procedure LMapValueMenuClick(Sender: TObject);
    procedure PngCompressMenuClick(Sender: TObject);
    procedure IdleModeMenuClick(Sender: TObject);
    procedure ShowHelpMenuClick(Sender: TObject);
    procedure GoGitHubMenuClick(Sender: TObject);
    procedure GoGitHubIssuesMenuClick(Sender: TObject);
  private
    FileList: TStringList;
    FJpegQuality: Integer;
    FClipboardFile: string;
    FSharpValue: Integer;
    FHtmlNth: Integer;
    FHTMLOnRemain: string;
    FHTMLOnStart: string;
    FHTMLOnEnd: string;
    FHTMLOnNth: string;
    FHTMLOnItem: string;
    FTimeFormat: string;
    FLastDirectory: string;
    FSampleDirectory: string;
    FSpiDirectory: string;
    FHTMLTemplateFile: string;
    FHTMLFileName: string;
    FMapFile: string;
    FFloatMode: Boolean;
    FCleanValue: Integer;
    FGammaValue: Extended;
    FContrastValue: Extended;
    FLumaMax: Integer;
    FLumaMin: Integer;
    FNormalizeMin: Integer;
    FNormalizeMax: Integer;
    FTrimRect: string;
    FRotateAngle: Integer;
    FGrayscaleMethod: Integer;
    FLMapValue: string;
    FEnableLMap: Boolean;
    FWhiteValue: Integer;
    FPngCompress: Integer;
    FPostExec: string;
    FDisableIL: Boolean;
    FMinimizedStart: Boolean;
    FTrimRectError: Boolean;
    FTrimRectFillColor: string;
    FFilterOrder: string;
    FDisableIS: Boolean;
    FMaxThreads: Integer;
    FContinueOnError: Boolean;
    FLogFileName: string;
    procedure AppHint(Sender: TObject);
    procedure AppException(Sender: TObject; E: Exception);
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    procedure MainProcess;
    procedure AddFile(FileName: string);
    procedure ParamExecute(Sender: TObject; var Done: Boolean);
    procedure ResetCondComboBoxEnabled;
    function GetStayOnTop: Boolean;
    procedure SetStayOnTop(const Value: Boolean);
    procedure SetFilepattern(const Value: string);
    function GetFilePattern: string;
    function GetHTMLGenerate: Boolean;
    procedure SetHTMLGenerate(const Value: Boolean);
    procedure SetValueType(const Value: TValueType);
    function GetValueType: TValueType;
    procedure SetKeepRatio(const Value: Boolean);
    function GetKeepRatio: Boolean;
    procedure SetHeightValue(const Value: Extended);
    procedure SetWidthValue(const Value: Extended);
    function GetHeightValue: Extended;
    function GetWidthValue: Extended;
    procedure SetStatusView(const Value: string);
    function GetStatusView: string;
    procedure SetRatioBase(const Value: TRatioBase);
    function GetRatioBase: TRatioBase;
    procedure SetJpegQuality(const Value: Integer);
    procedure SetTimeStampCopy(const Value: Boolean);
    function GetTimeStampCopy: Boolean;
    function GetHTMLReversePlace: Boolean;
    procedure SetHTMLReversePlace(const Value: Boolean);
    procedure LoadIniFile(FileName: string);
    procedure SaveIniFile(FileName: string);
    procedure SetOpenFolder(const Value: Boolean);
    function GetOpenFolder: Boolean;
    procedure SetDoSharpen(const Value: Boolean);
    function GetDoSharpen: Boolean;
    procedure SetAvoidCollision(const Value: Boolean);
    function GetAvoidCollision: Boolean;
    function GetNonMagnify: Boolean;
    procedure SetNonMagnify(const Value: Boolean);
    function GetDoClean: Boolean;
    procedure SetDoClean(const Value: Boolean);
    function GetDoGrayscale: Boolean;
    function GetDoNormalize: Boolean;
    procedure SetDoGrayscale(const Value: Boolean);
    procedure SetDoNormalize(const Value: Boolean);
    function GetProgressiveJpeg: Boolean;
    procedure SetProgressiveJpeg(const Value: Boolean);
    function GetDoGammaFix: Boolean;
    procedure SetDoGammaFix(const Value: Boolean);
    function GetDoContrastFix: Boolean;
    procedure SetDoContrastFix(const Value: Boolean);
    function GetDoLumaFix: Boolean;
    procedure SetDoLumaFix(const Value: Boolean);
    function GetDoTrim: Boolean;
    procedure SetDoTrim(const Value: Boolean);
    procedure SetDoRotate(const Value: Boolean);
    procedure SetDoTurnOver(const Value: Boolean);
    function GetDoRotate: Boolean;
    function GetDoTurnOver: Boolean;
    function GetDoLMap: Boolean;
    procedure SetDoLMap(const Value: Boolean);
    procedure SetAutoIndexed(const Value: Boolean);
    function GetAutoIndexed: Boolean;
    procedure SetAutoRotate(const Value: Boolean);
    function GetAutoRotate: Boolean;
    procedure SetDoWhite(const Value: boolean);
    function GetDoWhite: boolean;
    function GetIncludeSubDir: Boolean;
    procedure SetIncludeSubDir(const Value: Boolean);
    function GetIdleMode: Boolean;
    procedure SetIdleMode(const Value: Boolean);
    function GetSortFileList: Boolean;
    procedure SetSortFileList(const Value: Boolean);
    function GetMethod: Integer;
    procedure SetMethod(const Value: Integer);
    {$IFNDEF NoJPEGSubsampling}
    procedure SetJPEGSubsampling(const Value: Boolean);
    function GetJPEGSubsampling: Boolean;
    {$ENDIF}
    function GetLinearizedReduction: Boolean;
    procedure SetLinearizedReduction(const Value: Boolean);
    procedure SetMaxThreads(const Value: Integer);
  protected
    procedure CreateWnd; override;
  public
    property StayOnTop: Boolean read GetStayOnTop write SetStayOnTop;
    property ValueType: TValueType read GetValueType write SetValueType;
    property KeepRatio: Boolean read GetKeepRatio write SetKeepRatio;
    property WidthValue: Extended read GetWidthValue write SetWidthValue;
    property HeightValue: Extended read GetHeightValue write SetHeightValue;
    property ClipboardFile: string read FClipboardFile write FClipboardFile;
    property MapFile: string read FMapFile write FMapFile;
    property FilePattern: string read GetFilePattern write SetFilePattern;
    property StatusView: string read GetStatusView write SetStatusView;
    property RatioBase: TRatioBase read GetRatioBase write SetRatioBase;
    property Method: Integer read GetMethod write SetMethod;
    property JpegQuality: Integer read FJpegQuality write SetJpegQuality;
    {$IFNDEF NoJPEGSubsampling}
    property JpegSubsampling: Boolean read GetJPEGSubsampling write SetJPEGSubsampling;
    {$ENDIF}
    property TimeStampCopy: Boolean read GetTimeStampCopy write SetTimeStampCopy;
    property DoTrim: Boolean read GetDoTrim write SetDoTrim;
    property TrimRect: string read FTrimRect write FTrimRect;
    property DoTurnOver: Boolean read GetDoTurnOver write SetDoTurnOver;
    property DoRotate: Boolean read GetDoRotate write SetDoRotate;
    property RotateAngle: Integer read FRotateAngle write FRotateAngle;
    property DoGammaFix: Boolean read GetDoGammaFix write SetDoGammaFix;
    property GammaValue: Extended read FGammaValue write FGammaValue;
    property DoNormalize: Boolean read GetDoNormalize write SetDoNormalize;
    property NormalizeMin: Integer read FNormalizeMin write FNormalizeMin;
    property NormalizeMax: Integer read FNormalizeMax write FNormalizeMax;
    property DoLumaFix: Boolean read GetDoLumaFix write SetDoLumaFix;
    property LumaMin: Integer read FLumaMin write FLumaMin;
    property LumaMax: Integer read FLumaMax write FLumaMax;
    property DoContrastFix: Boolean read GetDoContrastFix write SetDoContrastFix;
    property ContrastValue: Extended read FContrastValue write FContrastValue;
    property DoClean: Boolean read GetDoClean write SetDoClean;
    property CleanValue: Integer read FCleanValue write FCleanValue;
    property DoSharpen: Boolean read GetDoSharpen write SetDoSharpen;
    property SharpValue: Integer read FSharpValue write FSharpValue;
    property DoGrayscale: Boolean read GetDoGrayscale write SetDoGrayscale;
    property GrayscaleMethod: Integer read FGrayscaleMethod write FGrayscaleMethod;
    property PngCompress: Integer read FPngCompress write FPngCompress;
    property ProgressiveJpeg: Boolean read GetProgressiveJpeg write SetProgressiveJpeg;
    property LastDirectory: string read FLastDirectory write FLastDirectory;
    property AvoidCollision: Boolean read GetAvoidCollision write SetAvoidCollision;
    property NonMagnify: Boolean read GetNonMagnify write SetNonMagnify;
    property SampleDirectory: string read FSampleDirectory write FSampleDirectory;
    property SpiDirectory: string read FSpiDirectory write FSpiDirectory;
    property HTMLGenerate: Boolean read GetHTMLGenerate write SetHTMLGenerate;
    property HTMLReversePlace: Boolean read GetHTMLReversePlace write SetHTMLReversePlace;
    property HTMLTemplateFile: string read FHTMLTemplateFile write FHTMLTemplateFile;
    property HTMLFileName: string read FHTMLFileName write FHTMLFileName;
    property HtmlNth: Integer read FHtmlNth write FHtmlNth;
    property HTMLOnStart: string read FHTMLOnStart write FHTMLOnStart;
    property HTMLOnItem: string read FHTMLOnItem write FHTMLOnItem;
    property HTMLOnNth: string read FHTMLOnNth write FHTMLOnNth;
    property HTMLOnRemain: string read FHTMLOnRemain write FHTMLOnRemain;
    property HTMLOnEnd: string read FHTMLOnEnd write FHTMLOnEnd;
    property TimeFormat: string read FTimeFormat write FTimeFormat;
    property OpenFolder: Boolean read GetOpenFolder write SetOpenFolder;
    property FloatMode: Boolean read FFloatMode write FFloatMode;
    property AutoIndexed: Boolean read GetAutoIndexed write SetAutoIndexed;
    property AutoRotate: Boolean read GetAutoRotate write SetAutoRotate;
    property DoWhite: Boolean read GetDoWhite write SetDoWhite;
    property WhiteValue: Integer read FWhiteValue write FWhiteValue;
    property DoLMap: Boolean read GetDoLMap write SetDoLMap;
    property LMapValue: string read FLMapValue write FLMapValue;
    property EnableLMap: Boolean read FEnableLMap write FEnableLMap;
    property IncludeSubDir: Boolean read GetIncludeSubDir write SetIncludeSubDir;
    property PostExec: string read FPostExec write FPostExec;
    property IdleMode: Boolean read GetIdleMode write SetIdleMode;
    property SortFileList: Boolean read GetSortFileList write SetSortFileList;
    property LinearizedReduction: Boolean read GetLinearizedReduction write SetLinearizedReduction;
    property DisableIL: Boolean read FDisableIL write FDisableIL;
    property DisableIS: Boolean read FDisableIS write FDisableIS;
    property MinimizedStart: Boolean read FMinimizedStart write FMinimizedStart;
    property TrimRectError: Boolean read FTrimRectError write FTrimRectError;
    property TrimRectFillColor: string read FTrimRectFillColor write FTrimRectFillColor;
    property FilterOrder: string read FFilterOrder write FFilterOrder;
    property MaxThreads: Integer read FMaxThreads write SetMaxThreads;
    property ContinueOnError: Boolean read FContinueOnError write FContinueOnError;
    property LogFileName: string read FLogFileName write FLogFileName;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

var
  AppPath: string;
  CriticalSection: TCriticalSection;
  PrevProgressUpdateTick: Cardinal = 0;
const
  ProgressUpdateIntervalTicks = 200;

type
  TProcInfo = record
    Name: string;
    Width: Integer;
    Height: Integer;
    NewWidth: Integer;
    NewHeight: Integer;
    CreationTime: TFileTime;
    LastWriteTime: TFileTime;
    Size: Cardinal;
    Order: Integer;
    OriginalTime: TDateTime;
    ModelName: string;
    Orient: Integer;
    Grayscale: Boolean;
  end;

function Eval(Expr: string; var X: Extended): Boolean;
var
  S: string;
  Error: Boolean;

  function RemoveSpace(const S: string): string;
  var
    I, J, Count: Integer;
  begin
    Count := 0;
    for I := 1 to Length(S) do if S[I] <> ' ' then Inc(Count);
    SetLength(Result, Count);
    J := 1;
    for I := 1 to Length(S) do
    begin
      if S[I] <> ' ' then
      begin
        Result[J] := S[I];
        Inc(J);
      end;
    end;
  end;

  function Exp: Extended; forward;

  function GetToken: string;
  var
    I: Integer;
  begin
    Result := '';

    if S = '' then Exit;

    if CharInSet(S[1], ['(', ')', '+', '-', '*', '/']) then I := 1
    else
    begin
      I := 1;
      while (I <= Length(S)) and CharInSet(S[1], ['0'..'9', '.']) do
        Inc(I);
      Dec(I);
    end;

    Result := Copy(S, 1, I);
    Delete(S, 1, I);
  end;

  function Factor: Extended;
  var
    Token: string;
  begin
    Result := 0;
    if S = '' then Error := True;

    Token := GetToken;
    if Token = '' then Exit;

    case Token[1] of
      '0'..'9', '.':
        if not TextToFloat(PChar(Token), Result, fvExtended) then Error := True;
      '(':
        begin
          Result := Exp;
          Token := GetToken;
          if Token <> ')' then Error := True;
        end;
      else Error := True;
    end;
  end;

  function Term: Extended;
  var
    Token: string;
    X: Extended;
  begin
    Result := Factor;

    Token := GetToken;
    while (Token = '*') or (Token = '/') do
    begin
      if Token = '*' then Result := Result * Factor
      else if Token = '/' then
      begin
        X := Factor;
        if X <> 0 then Result := Result / X
        else Error := True;
      end;
      Token := GetToken;
    end;
    S := Token + S;
  end;

  function Exp: Extended;
  var
    Token: string;
  begin
    Token := GetToken;

    if Token = '+' then Result := Term
    else if Token = '-' then Result := -Term
    else
    begin
      S := Token + S;
      Result := Term;
    end;

    Token := GetToken;
    while (Token = '+') or (Token = '-') do
    begin
      if Token = '+' then Result := Result + Term
      else if Token = '-' then Result := Result - Term;
      Token := GetToken;
    end;
    S := Token + S;
  end;

begin
  S := RemoveSpace(Expr);
  Error := False;
  X := Exp;
  Result := not Error;
end;

function EvalDef(Expr: string; Default: Extended): Extended;
var
  X: Extended;
begin
  if Eval(Expr, X) then Result := X
  else Result := Default;
end;

procedure ProgressProc(Progress: Integer);
begin
  CriticalSection.Acquire;
  try
    if Progress = 0 then
    begin
      PrevProgressUpdateTick := GetTickCount;
      ProcessForm.LocalProgress := 0;
      Exit;
    end;
    if GetTickCount - PrevProgressUpdateTick < ProgressUpdateIntervalTicks then Exit;

    PrevProgressUpdateTick := GetTickCount;
    if ProcessForm.LocalProgress < Progress then
      ProcessForm.LocalProgress := Progress;
    Application.ProcessMessages;
  finally
    CriticalSection.Release
  end;
end;

procedure TMainForm.CreateWnd;
begin
  inherited CreateWnd;
  DragAcceptFiles(Handle, True);
end;

function DecodePathExp(const S: string): string;
var
  I: Integer;
begin
  Result := '';
  I := 1;
  while I <= Length(S) do
  begin
    if S[I] <> '%' then Result := Result + S[I]
    else
    begin
      Inc(I);
      case S[I] of
        'a': Result := Result + AppPath;
        'd': Result := Result + DesktopDirectory;
        'm': Result := Result + MyDocumentsDirectory;
        '%': Result := Result + '%';
      else
        Result := Result + '$ERROR$';
      end;
    end;
    Inc(I);
  end;
end;

procedure TMainForm.MainProcess;
var
  HTMLTemplate: string;

  procedure LoadHTMLTemplate;
  var
    FileName: string;
  begin
    FileName := DecodePathExp(SampleDirectory) + HTMLTemplateFile;
    if FileExists(FileName) then HTMLTemplate := ReadAllText(FileName)
    else HTMLTemplate := '%s';
  end;

  function DecodeAExp(const S: string; HrefURL, ImgURL: string; Quantity: Integer): string; overload;
  var
    I: Integer;
  begin
    Result := '';
    I := 1;
    while I <= Length(S) do
    begin
      if S[I] <> '@' then Result := Result + S[I]
      else
      begin
        Inc(I);
        case S[I] of
          'n': Result := Result + #13#10;
          's': Result := Result + HrefURL;
          'o': Result := Result + ImgURL;
          'q': Result := Result + IntToStr(Quantity);
          '@': Result := Result + '@';
        else
          Result := Result + '$ERROR$';
        end;
      end;
      Inc(I);
    end;
  end;

  function DecodeAExp(const S: string; Quantity: Integer): string; overload;
  begin
    Result := DecodeAExp(S, '', '', Quantity);
  end;

  function DecodePExp(const S: string; ProcInfo: TProcInfo; Order: Integer): string;
    function DateTimeToString(const DateTime: TDateTime): string;
    begin
      Result := '';
      if DateTime = -1 then Exit;
      try
        Result := FormatDateTime(TimeFormat, DateTime);
      except
      on EConvertError do
        ;
      end;
    end;

    function HumanReadableSize(Size: Int64): string;
    var
      Denomination, Figures: Integer;
      X: Extended;
    begin
      X := Size;
      Denomination := 0;

      while X >= 1000 do
      begin
        if X >= 1000 then
        begin
          Inc(Denomination);
          X := X / 1024;
        end;
      end;
      Figures := Length(IntToStr(Trunc(X)));

      case Denomination of
        0: Result := Format('%.0f Bytes', [X]);
        1: Result := Format('%.*f KB', [3 - Figures, X]);
        2: Result := Format('%.*f MB', [3 - Figures, X]);
        3: Result := Format('%.*f GB', [3 - Figures, X]);
      else
        Result := 'ERROR';
      end;
    end;

    function ParamValues: string;
    begin
      Result := '';
      if DoGammaFix then Result := Result + Format('ガンマ補正(%f) ', [GammaValue]);
      if DoNormalize then Result := Result + Format('正規化(%d-%d) ', [NormalizeMin, NormalizeMax]);
      if DoLumaFix then Result := Result + Format('輝度補正(%d-%d) ', [LumaMin, LumaMax]);
      if DoContrastFix then Result := Result + Format('コントラスト補正(%f) ', [ContrastValue]);
      if DoClean then Result := Result + Format('ノイズ除去(%d) ', [CleanValue]);
      if DoSharpen then Result := Result + Format('輪郭強調(%d) ', [SharpValue]);
      if Result <> '' then Result := Copy(Result, 1, Length(Result) - 1);
    end;

    function ExtractFilePathWithoutDrive(S: string): string;
    begin
      Result := ExcludeTrailingPathDelimiter(ExtractFilePath(S));
      Result := Copy(Result, Length(ExtractFileDrive(S)) + 1, Length(S));
    end;

  var
    I: Integer;
  begin
    Result := '';
    I := 1;
    while I <= Length(S) do
    begin
      if S[I] <> '%' then Result := Result + S[I]
      else
      begin
        Inc(I);
        case S[I] of
          'D': Result := Result + ExtractFileDrive(ProcInfo.Name);
          'P': Result := Result + ExtractFilePathWithoutDrive(ProcInfo.Name);
          'p': Result := Result + StringReplace(ExcludeTrailingPathDelimiter(ExtractFilePath(ProcInfo.Name)), '%', '%%', [rfReplaceAll]);
          'r': Result := Result + ExtractFileName(ExtractFileDir(ProcInfo.Name));
          'n': Result := Result + StringReplace(ChangeFileExt(ExtractFileName(ProcInfo.Name), ''), '%', '%%', [rfReplaceAll]);
          'e': Result := Result + StringReplace(Copy(ExtractFileExt(ProcInfo.Name), 2, Length(ExtractFileExt(ProcInfo.Name))), '%', '%%', [rfReplaceAll]);
          'w': Result := Result + IntToStr(ProcInfo.Width);
          'h': Result := Result + IntToStr(ProcInfo.Height);
          'x': Result := Result + IntToStr(ProcInfo.NewWidth);
          'y': Result := Result + IntToStr(ProcInfo.NewHeight);
          't': Result := Result + DateTimeToString(FileTimeToDateTime(ProcInfo.LastWriteTime));
          's': Result := Result + HumanReadableSize(ProcInfo.Size);
          '1'..'9':
               Result := Result + Format('%.*d', [Ord(S[I]) - Ord('0'), Order]);
          'f': Result := Result + IntToStr(Method);
          'j': Result := Result + Format('%.2d', [JpegQuality]);
          'v': Result := Result + ParamValues;
          'c': Result := Result + DateTimeToString(Now);
          'E':
          begin
            Inc(I);
            case S[I] of
              'o': Result := Result + DateTimeToString(ProcInfo.OriginalTime);
              'm': Result := Result + ProcInfo.ModelName;
            else
              Result := Result + '%E' + S[I];
            end;
          end;
        else
          Result := Result + '%' + S[I];
        end;
      end;
      Inc(I);
    end;
    Result := DecodePathExp(Result);
  end;

  {$IF CompilerVersion >= 21.0}
  function LoadByWIC(var ProcInfo: TProcInfo; Src: TBitmap): Boolean;
  var
    WICImage: TWICImage;
  begin
    Result := True;
    WICImage := TWICImage.Create;
    try
      try
        WICImage.LoadFromFile(ProcInfo.Name);
      except
        Result := False;
        Exit;
      end;
      Src.Assign(WICImage);
    finally
      FreeAndNil(WICImage);
    end;
  end;
  {$ELSE}
  function LoadByIL(var ProcInfo: TProcInfo; Src: TBitmap): Boolean;
  var
    FileExt: string;
    PNG: TPngImage;
    GIF: TGIFImage;
    JPEG: TJPEGImage;
  begin
    Result := True;
    FileExt := ExtractFileExt(ProcInfo.Name);
    if FileExtInSet(FileExt, ['.bmp']) then Src.LoadFromFile(ProcInfo.Name)
    else if FileExtInSet(FileExt, ['.jpg', '.jpeg']) then
    begin
      JPEG := TJPEGImage.Create;
      try
        JPEG.PixelFormat := jf24bit;
        JPEG.LoadFromFile(ProcInfo.Name);
        Src.Assign(JPEG);
      finally
        FreeAndNil(JPEG);
      end;
      if GetColorSpace(ProcInfo.Name) = 65535 then ConvertFromAdobeRGB(Src);
    end
    else if FileExtInSet(FileExt, ['.png']) then
    begin
      PNG := TPngImage.Create;
      try
        PNG.LoadFromFile(ProcInfo.Name);
        Src.Assign(PNG);
      finally
        FreeAndNil(PNG);
      end;
    end
    else if FileExtInSet(FileExt, ['.gif']) then
    begin
      GIF := TGIFImage.Create;
      try
        GIF.LoadFromFile(ProcInfo.Name);
        Src.Assign(GIF);
      finally
        FreeAndNil(GIF);
      end;
    end
    else Result := False;
  end;
  {$IFEND}

  function Load(var ProcInfo: TProcInfo; Src: TBitmap): Boolean;
  begin
    {$IF CompilerVersion >= 21.0}
    Result := LoadByWIC(ProcInfo, Src);
    {$ELSE}
    Result := LoadByIL(ProcInfo, Src);
    {$IFEND}
    if FileExtInSet(ExtractFileExt(ProcInfo.Name), ['.jpg', '.jpeg']) then
    begin
      ProcInfo.OriginalTime := ExifDateTimeToDateTime(string(GetOriginalDateTime(ProcInfo.Name)));
      ProcInfo.ModelName := string(GetModel(ProcInfo.Name));
      ProcInfo.Orient := GetOrientation(ProcInfo.Name);
    end;
  end;

  function Save(SaveName: string; Grayscale: Boolean; Src: TBitmap): Boolean;
  var
    FileExt: string;
    PNG: TPngImage;
    GIF: TGIFImage;
    JPEG: TJPEGImage;
  begin
    Result := True;
    FileExt := ExtractFileExt(SaveName);
    if FileExtInSet(FileExt, ['.bmp']) then Src.SaveToFile(SaveName)
    else if FileExtInSet(FileExt, ['.jpg', '.jpeg']) then
    begin
      JPEG := TJPEGImage.Create;
      try
        JPEG.ProgressiveEncoding := ProgressiveJpeg;
        JPEG.CompressionQuality  := JpegQuality;
        {$IFNDEF NoJPEGSubsampling}
        JPEG.Subsampling := JpegSubsampling;
        {$ENDIF}
        JPEG.Grayscale := Grayscale;
        JPEG.Assign(Src);
        JPEG.SaveToFile(SaveName);
      finally
        FreeAndNil(JPEG);
      end;
    end
    else if FileExtInSet(FileExt, ['.png']) then
    begin
      PNG := TPngImage.Create();
      try
        PNG.CompressionLevel := PngCompress;
        if (PngCompress = 0) or (PngCompress = 1) then PNG.Filters := [pfNone]
        else PNG.Filters := [pfNone, pfSub, pfUp, pfAverage, pfPaeth];
        PNG.Assign(Src);
        if Grayscale then
        begin
          PNG.Header.ColorType := COLOR_GRAYSCALE;
          PNG.Chunks.RemoveChunk(PNG.Chunks.ItemFromClass(TChunkPLTE));
        end;
        PNG.SaveToFile(SaveName);
      finally
        FreeAndNil(PNG);
      end;
    end
    else if FileExtInSet(FileExt, ['.gif']) then
    begin
      GIF := TGIFImage.Create;
      try
        GIF.Assign(Src);
        GIF.SaveToFile(SaveName);
      finally
        FreeAndNil(GIF);
      end;
    end
    else if FileExtInSet(FileExt, ['.pnm', '.ppm']) then
    begin
      Src.PixelFormat := pf24bit;
      if Src.Palette <> 0 then DeleteObject(Src.ReleasePalette);
      SaveAsPPM(Src, SaveName);
    end
    else if FileExtInSet(FileExt, ['.psd']) then
    begin
      if (not Grayscale) and (Src.PixelFormat <> PixelBits) then
      begin
        Src.PixelFormat := PixelBits;
        if Src.Palette <> 0 then DeleteObject(Src.ReleasePalette);
      end;
      SaveAsPSD(Src, SaveName);
    end
    else Result := False;
  end;

  function ValidateSizeInput: Boolean;
  begin
    Result := (EvalDef(WidthEdit.Text, -1) > 0) and (EvalDef(HeightEdit.Text, -1) > 0);
  end;

  function RectStringToRect(RectData: string; W, H: Integer): TRect;
  begin
    with TStringList.Create do
    begin
      Text := StringReplace(RectData, ',', #13#10, [rfReplaceAll]);
      if Count = 4 then
      begin
        Result := Rect(StrToIntDef(Strings[0], 0),
                       StrToIntDef(Strings[1], 0),
                       StrToIntDef(Strings[2], W),
                       StrToIntDef(Strings[3], H));
      end
      else Result := Rect(0, 0, W, H);
      Free;
    end;
  end;

  procedure ExecCmd(Cmd: string);
  var
    PI: TProcessInformation;
    SI: TStartupInfo;
  begin
    FillChar(SI, SizeOf(SI), 0);
    SI.cb := SizeOf(SI);
    CreateProcess(nil, PChar(Cmd), nil, nil, false, 0, nil, nil, SI, PI);
  end;

var
  I: Integer;
  SaveName: string;
  Src: TBitmap;
  ProcInfo: TProcInfo;
  Html: string;
  ViewWidth: Integer;
  {$IF CompilerVersion >= 21.0}
  TaskBarList : ITaskbarList3;

  procedure InitializeTaskbarProgress;
  begin
    TaskBarList := CreateComObject(CLSID_TaskbarList) as ITaskBarList3;
    TaskBarList.SetProgressState(Handle, TBPF_NORMAL);
  end;

  procedure UpdateTaskbarProgress(ProgressValue: Integer);
  begin
    TaskBarList.SetProgressValue(Handle, ProgressValue, 100);
  end;

  procedure FinalizeTaskbarProgress;
  begin
    TaskBarList.SetProgressState(Handle, TBPF_NOPROGRESS);
    TaskBarList := nil;
  end;
  {$IFEND}

  function AbortRequire: Boolean;
  begin
    Application.ProcessMessages;
    Result := ProcessForm.AbortRequire;
  end;

  function ProcessImageLoading: Boolean;
  begin
    Result := True;

    Src := TBitmap.Create;

    ProcInfo.Order := I;
    ProcInfo.Name := ExpandFileName(FileList.Strings[I]);
    GetTimeStamp(ProcInfo.Name, @ProcInfo.CreationTime, @ProcInfo.LastWriteTime);
    ProcInfo.OriginalTime := -1;
    ProcInfo.Size := GetFileSize(ProcInfo.Name);
    ProcInfo.Orient := -1;
    ProcInfo.Grayscale := False;

    ViewWidth := ProcessForm.Width - ProcessForm.FileNameLabel.Left - 20;
    ProcessForm.ProcessingFile := MinimizeName(ProcInfo.Name, ProcessForm.FileNameLabel.Canvas, ViewWidth);
    ProcessForm.ProcessSituation := 'ファイルを読み込み中';
    ProcessForm.GlobalProgress := (I * 100) div FileList.Count;
    {$IF CompilerVersion >= 21.0}
    if CheckWin32Version(6, 1) then UpdateTaskbarProgress((I * 100) div FileList.Count);
    {$IFEND}
    ProcessForm.LocalProgress := 0;
    Application.ProcessMessages;

    if DisableIL then LoadBySpi(ProcInfo.Name, Src)
    else
    begin
      if not Load(ProcInfo, Src) then LoadBySpi(ProcInfo.Name, Src);
    end;

    if AbortRequire then
    begin
      Result := False;
      Exit;
    end;
  end;

  function ProcessFixedOrderFilters: Boolean;
  var
    Rect: TRect;
  begin
    Result := True;

    if AutoRotate then
    begin
      if (ProcInfo.Orient >= 1) and (ProcInfo.Orient <= 8) then
      begin
        ProcessForm.ProcessSituation := '回転中';
        Application.ProcessMessages;
        case ProcInfo.Orient of
          3, 4: RotateFilter(Src, 180, ProgressProc);
          5, 8: RotateFilter(Src, 270, ProgressProc);
          6, 7: RotateFilter(Src, 90, ProgressProc);
        end;
        ProcessForm.ProcessSituation := '反転中';
        Application.ProcessMessages;
        case ProcInfo.Orient of
          2, 4, 5, 7: TurnOverFilter(Src, ProgressProc);
        end;
      end;
    end;

    if AbortRequire then
    begin
      Result := False;
      Exit;
    end;

    if DoWhite then
    begin
      ProcessForm.ProcessSituation := '白色化中';
      Application.ProcessMessages;
      WhiteFilter(Src, WhiteValue, ProgressProc);
    end;

    if AbortRequire then
    begin
      Result := False;
      Exit;
    end;

    if DoTrim then
    begin
      ProcessForm.ProcessSituation := '切り抜き中';
      Application.ProcessMessages;
      Rect := RectStringToRect(TrimRect, Src.Width, Src.Height);
      if TrimRectError and ((Rect.Left < 0) or (Rect.Top < 0)
        or (Rect.Right > Src.Width) or (Rect.Bottom > Src.Height)) then
      begin
        ShowMessage('TrimRect Error');
        Result := False;
        Exit;
      end;
      TrimFilter(Src, Rect, TrimRectFillColor, ProgressProc);
    end;

    if AbortRequire then
    begin
      Result := False;
      Exit;
    end;

    if DoTurnOver then
    begin
      ProcessForm.ProcessSituation := '反転中';
      Application.ProcessMessages;
      TurnOverFilter(Src, ProgressProc);
    end;

    if AbortRequire then
    begin
      Result := False;
      Exit;
    end;

    if DoRotate then
    begin
      ProcessForm.ProcessSituation := '回転中';
      Application.ProcessMessages;
      RotateFilter(Src, RotateAngle, ProgressProc);
    end;

    if AbortRequire then
    begin
      Result := False;
      Exit;
    end;
  end;

  procedure ComputeNewImageSize;
  var
    Flag: Boolean;
    NewWidth, NewHeight: Integer;
  begin
    ProcInfo.Width := Src.Width;
    ProcInfo.Height := Src.Height;

    if ValueType = vtRelative then
    begin
      NewWidth := Trunc(WidthValue * ProcInfo.Width / 100 + 0.5);
      NewHeight := Trunc(HeightValue * ProcInfo.Height / 100 + 0.5);
    end
    else
    begin
      if KeepRatio then
      begin
        Flag := True;
        case RatioBase of
          //rbWidth: Flag := True;
          rbHeight: Flag := False;
          rbLong:   Flag := ProcInfo.Width > ProcInfo.Height;
          rbShort:  Flag := ProcInfo.Width < ProcInfo.Height;
          rbMax:    Flag := ProcInfo.Width / ProcInfo.Height > WidthValue / HeightValue;
          rbMin:    Flag := ProcInfo.Width / ProcInfo.Height < WidthValue / HeightValue;
        end;
        if Flag then
        begin
          NewWidth := Trunc(WidthValue + 0.5);
          NewHeight := Trunc(ProcInfo.Height * (NewWidth / ProcInfo.Width) + 0.5);
        end
        else
        begin
          NewHeight := Trunc(HeightValue + 0.5);
          NewWidth := Trunc(ProcInfo.Width * (NewHeight / ProcInfo.Height) + 0.5);
        end;
      end
      else
      begin
        NewWidth := Trunc(WidthValue + 0.5);
        NewHeight := Trunc(HeightValue + 0.5);
      end;
    end;

    if NonMagnify and ((NewWidth > ProcInfo.Width) or (NewHeight > ProcInfo.Height)) then
    begin
      NewWidth := ProcInfo.Width;
      NewHeight := ProcInfo.Height;
    end;

    ProcInfo.NewWidth := NewWidth;
    ProcInfo.NewHeight := NewHeight;
  end;

  function ProcessReordableFilters: Boolean;
  var
    J: Integer;
  begin
    Result := True;

    for J := 1 to Length(FilterOrder) do
    begin
      case FilterOrder[J] of
      '0':
        if DoLMap then
        begin
          ProcessForm.ProcessSituation := 'LMap中';
          Application.ProcessMessages;
          LMapFilter(Src, LMapValue, ProgressProc);
        end;
      '1':
        if DoGammaFix then
        begin
          ProcessForm.ProcessSituation := 'ガンマ補正中';
          Application.ProcessMessages;
          GammaFixFilter(Src, GammaValue, ProgressProc);
        end;
      '2':
        if DoNormalize then
        begin
          ProcessForm.ProcessSituation := '正規化中';
          Application.ProcessMessages;
          NormalizeFilter(Src, NormalizeMin, NormalizeMax, ProgressProc);
        end;
      '3':
        if DoLumaFix then
        begin
          ProcessForm.ProcessSituation := '輝度補正中';
          Application.ProcessMessages;
          LumaFixFilter(Src, LumaMin, LumaMax, ProgressProc);
        end;
      '4':
        if DoContrastFix then
        begin
          ProcessForm.ProcessSituation := 'コントラスト補正中';
          Application.ProcessMessages;
          ContrastFixFilter(Src, ContrastValue, ProgressProc);
        end;
      '5':
        if DoClean then
        begin
          ProcessForm.ProcessSituation := 'ノイズ除去中 (1/2)';
          Application.ProcessMessages;
          ConditionedAverage(Src, CleanValue, 1, ProgressProc);
          ProcessForm.ProcessSituation := 'ノイズ除去中 (2/2)';
          Application.ProcessMessages;
          ConditionedAverage(Src, CleanValue shr 1, 2, ProgressProc);
        end;
      '6':
        if (ProcInfo.Width <> ProcInfo.NewWidth) or (ProcInfo.Height <> ProcInfo.NewHeight) then
        begin
          ProcessForm.ProcessSituation := 'サイズ変更中';
          Application.ProcessMessages;
          if LinearizedReduction then SetLinearizeOnReduce(1)
          else SetLinearizeOnReduce(0);
          Stretch(Src, ProcInfo.NewWidth, ProcInfo.NewHeight, Method, ProgressProc);
        end;
      '7':
        if DoSharpen then
        begin
          ProcessForm.ProcessSituation := '輪郭強調中';
          Application.ProcessMessages;
          SharpenFilter(Src, (100 - SharpValue) + 21, ProgressProc);
        end;
      '8':
        if DoGrayscale then
        begin
          ProcessForm.ProcessSituation := '白黒化中';
          Application.ProcessMessages;
          GrayscaleFilter(Src, GrayscaleMethod, ProgressProc);
          ProcInfo.Grayscale := True;
        end
        else
        begin
          if AutoIndexed then
          begin
            ProcessForm.ProcessSituation := 'インデックス化中';
            Application.ProcessMessages;
            IndexedFilter(Src, ProcInfo.Grayscale, ProgressProc);
          end;
        end;
    end;

    if AbortRequire then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;

  procedure ProcessImageSaving;
  var
    FilePath: string;
    ImgURL, HrefURL: string;
    FileExt: string;
  begin
    ProcessForm.ProcessSituation := '出力中';
    ProcessForm.LocalProgress := 100;
    Application.ProcessMessages;

    //for Clipboards
    if FilePattern = '*' then
    begin
      Clipboard.Assign(Src);
      FreeAndNil(Src);
      Exit;
    end;

    SaveName := DecodePExp(FilePattern, ProcInfo, I);

    FileExt := ExtractFileExt(SaveName);

    if FileExtInSet(FileExt, ['.png8', '.bmp8', '.gif']) then
    begin
      if Src.PixelFormat = pf24bit then ReduceColor(Src, 256, true);
      if not FileExtInSet(FileExt, ['.gif']) then SaveName := ChangeFileExt(SaveName, Chop(ExtractFileExt(SaveName)));
    end;

    if FileExtInSet(FileExt, ['.png4', '.bmp4']) then
    begin
      ReduceColor(Src, 16, true);
      Convert8BitTo4Bit(Src, nil);
      SaveName := ChangeFileExt(SaveName, Chop(ExtractFileExt(SaveName)));
    end;

    if AvoidCollision then SaveName := AvoidCollisionName(SaveName);
    FilePath := ExtractFilePath(SaveName);
    if not System.SysUtils.DirectoryExists(FilePath) then System.SysUtils.ForceDirectories(FilePath);

    ViewWidth := ProcessForm.Width - ProcessForm.SituationLabel.Left - 20 - ProcessForm.SituationLabel.Canvas.TextWidth('出力中 ""');
    ProcessForm.ProcessSituation := Format('出力中 "%s"', [MinimizeName(SaveName, ProcessForm.SituationLabel.Canvas, ViewWidth)]);
    Application.ProcessMessages;

{$IFNDEF WIN64}
    if DisableIS then SaveByXpi(SaveName, Src)
    else
    begin
      if not Save(SaveName, ProcInfo.Grayscale, Src) then SaveByXpi(SaveName, Src);
    end;
{$ELSE}
    Save(SaveName, ProcInfo.Grayscale, Src);
{$ENDIF}

    if TimeStampCopy then SetTimeStamp(SaveName, @ProcInfo.CreationTime, @ProcInfo.LastWriteTime);
    if HTMLGenerate then
    begin
      if HTMLReversePlace then
      begin
        HrefURL := StringReplace(ExtractRelativePath(ExtractFilePath(SaveName), ProcInfo.Name), '\', '/', [rfReplaceAll]);
        ImgURL := ExtractFileName(SaveName);
      end
      else
      begin
        HrefURL := ExtractFileName(ProcInfo.Name);
        ImgURL := StringReplace(ExtractRelativePath(ExtractFilePath(ProcInfo.Name), SaveName), '\', '/', [rfReplaceAll]);
      end;
      Html := Html + DecodeAExp(DecodePExp(HTMLOnItem, ProcInfo, I), HrefURL, ImgURL, FileList.Count);
      if (HtmlNth <> 0) and (((I + 1) mod HTMLNth) = 0) and (I <> FileList.Count - 1) then
      begin
        Html := Html + DecodeAExp(HTMLOnNth, FileList.Count);
      end;
    end;
    FreeAndNil(Src);
  end;

var
  StartTick: Cardinal;
  FileName: string;
begin
  if not ValidateSizeInput then
  begin
    StatusView := '値が不正です';
    Exit;
  end;

  StartTick := GetTickCount;
  LoadHTMLTemplate;
  Html := '';

  if SortFileList then FileList.Sort;

  try
    if StayOnTop then FormStyle := fsNormal;
    if not MinimizedStart then SetForegroundWindow(Handle);
    ProcessForm.Left := Left + (Width - ProcessForm.Width) div 2;
    ProcessForm.Top := Top + (Height - ProcessForm.Height) div 2;
    ProcessForm.ProcessingFile := '';
    ProcessForm.ProcessSituation := '';
    ProcessForm.GlobalProgress := 0;
    ProcessForm.LocalProgress := 0;
    if not MinimizedStart then ProcessForm.Show;
    Enabled := False;

    if HTMLGenerate then Html := Html + DecodeAExp(HTMLOnStart, FileList.Count);

    Info('*** START ***');
    {$IF CompilerVersion >= 21.0}
    if CheckWin32Version(6, 1) then InitializeTaskbarProgress;
    {$IFEND}
    for I := 0 to FileList.Count - 1 do
    begin
      try
        if not ProcessImageLoading then Break;
        if not ProcessFixedOrderFilters then Break;
        ComputeNewImageSize;
        if not ProcessReordableFilters then Break;
        ProcessImageSaving;
        Info(Format('Succeded: %s', [ProcInfo.Name]));
      except
        on E: Exception do
        begin
          Warn(Format('%s', [E.Message]));
          Info(Format('Failed: %s', [ProcInfo.Name]));
          if not ContinueOnError then Break;
        end;
      end;
    end;
    Info('*** END ***');

    if HTMLGenerate then
    begin
      if HTMLNth <> 0 then
      begin
        if (FileList.Count mod HTMLNth) <> 0 then
        begin
          for I := 0 to (HTMLNth - (FileList.Count mod HTMLNth)) - 1 do
          begin
            Html := Html + DecodeAExp(HTMLOnRemain, FileList.Count);
          end;
        end;
      end;
      Html := Html + DecodeAExp(HTMLOnEnd, FileList.Count);
      Html := Format(HTMLTemplate, [Html]);
      if HTMLReversePlace then FileName := ExtractFilePath(SaveName) + HTMLFileName
      else FileName := ExtractFilePath(ProcInfo.Name) + HTMLFileName;
      WriteAllText(FileName, Html);
    end;
  finally
    {$IF CompilerVersion >= 21.0}
    if CheckWin32Version(6, 1) then FinalizeTaskbarProgress;
    {$IFEND}
    if StayOnTop then FormStyle := fsStayOnTop;
    ProcessForm.Hide;
    Enabled := True;
  end;
  if OpenFolder then
  begin
    if PostExec = '' then
    begin
      ShellExecute(0, nil, PChar(ExtractFilePath(SaveName)), nil, nil, SW_SHOW)
    end
    else
    begin
      ExecCmd(StringReplace(PostExec, '?', ExtractFilePath(SaveName), [rfReplaceAll]));
    end;
  end;
  StatusView := Format('%.2fs', [(GetTickCount - StartTick) / 1000]);
end;

procedure TMainForm.FormCreate(Sender: TObject);
  procedure LoadSampleTitle;
  var
    I: Integer;
    IniFile: TIniFile;
    MenuItem: TMenuItem;
  begin
    IniFile := TIniFile.Create(DecodePathExp(MapFile));
    try
      I := 1;
      while IniFile.ReadString('map', Format('sample%d', [I]), '') <> '' do
      begin
        MenuItem := TMenuItem.Create(Self);
        with MenuItem do
        begin
          Name := Format('Sample%dMenu', [I]);
          Caption := IniFile.ReadString('map', Format('sample%d', [I]), '');
          Hint := '雛型から設定情報を取り込みます';
          OnClick := SampleMenuXClick;
        end;
        SampleMenu.Add(MenuItem);
        Inc(I);
      end;
    finally
      FreeAndNil(IniFile);
    end;
  end;

begin
  Application.OnException := AppException;
  AppPath := ExcludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  Application.OnHint := AppHint;
  FileList := TStringList.Create;
  CriticalSection := TCriticalSection.Create;

  //初期設定
  MapFile := '%a\map.ini';
  ClipboardFile := '%a\clipboard.bmp';

  RatioBase := rbHeight;
  Method := 0;
  FloatMode := False;
  JPEGQuality := 80;
  PngCompress := 5;
  NormalizeMin := 0;
  NormalizeMax := 255;
  LumaMin := 0;
  LumaMax := 255;
  SharpValue := 60;
  CleanValue := 24;
  GammaValue := 1.0;
  ContrastValue := 1.0;
  GrayscaleMethod := 0;
  TimeFormat := 'yyyy"年"mm"月"dd"日" hh"時"nn"分"';
  TrimRect := '0,0,0,0';
  EnableLMap := False;
  WhiteValue := 230;
  DisableIL := False;
  DisableIS := False;
  MinimizedStart := False;
  TrimRectError := False;
  TrimRectFillColor := '#ffffff';
  FilterOrder := '012345678';
  MaxThreads := 0;
  ContinueOnError := False;

  SampleDirectory := '%a\samples\';
  SpiDirectory := '%a\';
  LastDirectory := AppPath + '\samples\';

  HTMLFileName := 'template.html';
  HTMLTemplateFile := 'template.html';
  HTMLOnStart := '<p>@n';
  HTMLOnItem := '<a href="@s"><img src="@o" width="%x" height="%y" alt="%n.%e"></a>@n';
  HTMLOnNth := '';
  HTMLOnRemain := '';
  HTMLOnEnd := '</p>';

  if IdleMode then SetPriorityClass(GetCurrentProcess, IDLE_PRIORITY_CLASS);

  LoadIniFile(AppPath + '\wisteria.ini');
  InitLogging(LogFileName);
  LoadSampleTitle;

  if ParamCount > 0 then
  begin
    if FileExtInSet(ExtractFileExt(ParamStr(1)), ['.ini']) then
    begin
      LoadIniFile(ParamStr(1));
      if ParamCount > 1 then Application.OnIdle := ParamExecute;
    end;
  end;

  if MinimizedStart then WindowState := wsMinimized;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  SaveIniFile(AppPath + '\wisteria.ini');
  FreeAndNil(CriticalSection);
  FreeAndNil(FileList);
end;

procedure TMainForm.LoadIniFile(FileName: string);
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(FileName);
  try
    with IniFile do
    begin
      //Window
      Top                 := ReadInteger('Window', 'Top', Top);
      Left                := ReadInteger('Window', 'Left', Left);
      StayOnTop           := ReadBool('Window', 'StayOnTop', StayOnTop);
      IdleMode            := ReadBool('Window', 'Idle', IdleMode);

      //Files
      MapFile             := ReadString('Files', 'MapFile', MapFile);
      ClipboardFile       := ReadString('Files', 'ClipboardFile', ClipboardFile);

      //Directories
      LastDirectory       := ReadString('Directories', 'LastDirectory', LastDirectory);
      SampleDirectory     := ReadString('Directories', 'SampleDirectory', SampleDirectory);
      SpiDirectory        := ReadString('Directories', 'SpiDirectory', SpiDirectory);

      //Resize
      ValueType           := TValueType(ReadInteger('Resize', 'ValueType', Ord(ValueType)));
      Keepratio           := ReadBool('Resize', 'KeepRatio', KeepRatio);
      WidthValue          := ReadFloat('Resize', 'WidthValue', WidthValue);
      HeightValue         := ReadFloat('Resize', 'HeightValue', HeightValue);
      RatioBase           := TRatioBase(ReadInteger('Resize', 'RatioBase', Ord(RatioBase)));
      Method              := ReadInteger('Resize', 'Method', Method);
      FloatMode           := ReadBool('Resize', 'FloatMode', FloatMode);
      NonMagnify          := ReadBool('Resize', 'NonMagnify', NonMagnify);
      LinearizedReduction := ReadBool('Resize', 'LinearizedReduction', LinearizedReduction);

      //Output
      FilePattern         := ReadString('Output', 'FilePattern', FilePattern);
      AvoidCollision      := ReadBool('Output', 'AvoidCollision', AvoidCollision);
      JPEGQuality         := ReadInteger('Output', 'JPEGQuality', JPEGQuality);
      {$IFNDEF NoJPEGSubsampling}
      JpegSubsampling     := ReadBool('Output', 'JPEGSubsampling', JpegSubsampling);
      {$ENDIF}
      ProgressiveJpeg     := ReadBool('Output', 'ProgressiveJPEG', ProgressiveJpeg);
      PngCompress         := ReadInteger('Output', 'PNGCompressLevel', PNGCompress);
      TimeStampCopy       := ReadBool('Output', 'TimeStampCopy', TimeStampCopy);
      AutoIndexed         := ReadBool('Output', 'AutoIndexed', AutoIndexed);
      AutoRotate          := ReadBool('Output', 'AutoRotate', AutoRotate);

      //HTML
      HTMLGenerate        := ReadBool('HTML', 'Generate', HTMLGenerate);
      HTMLFileName        := ReadString('HTML', 'FileName', HTMLFileName);
      HTMLReversePlace    := ReadBool('HTML', 'ReversePlace', HTMLReversePlace);
      HTMLTemplateFile    := ReadString('HTML', 'TemplateFile', HTMLTemplateFile);
      HtmlNth             := ReadInteger('HTML', 'Nth', 0);
      HTMLOnStart         := ReadString('HTML', 'OnStart', HTMLOnStart);
      HTMLOnItem          := ReadString('HTML', 'OnItem', HTMLOnItem);
      HTMLOnNth           := ReadString('HTML', 'OnNth', HTMLOnNth);
      HTMLOnRemain        := ReadString('HTML', 'OnRemain', HTMLOnRemain);
      HTMLOnEnd           := ReadString('HTML', 'OnEnd', HTMLOnEnd);

      //Filter
      DoTrim              := ReadBool('Filter', 'TrimFilter', DoTrim);
      TrimRect            := ReadString('Filter', 'TrimRect', TrimRect);
      DoTurnOver          := ReadBool('Filter', 'TurnOverFilter', DoTurnOver);
      DoRotate            := ReadBool('Filter', 'RotateFilter', DoRotate);
      RotateAngle         := ReadInteger('Filter', 'RotateAngle', RotateAngle);
      DoNormalize         := ReadBool('Filter', 'NormalizeFilter', DoNormalize);
      NormalizeMin        := ReadInteger('Filter', 'NormalizeMin', NormalizeMin);
      NormalizeMax        := ReadInteger('Filter', 'NormalizeMax', NormalizeMax);
      DoLumaFix           := ReadBool('Filter', 'LuminanceCorrectionFilter', DoLumaFix);
      LumaMin             := ReadInteger('Filter', 'LuminanceMin', LumaMin);
      LumaMax             := ReadInteger('Filter', 'LuminanceMax', LumaMax);
      DoGammaFix          := ReadBool('Filter', 'GammaCorrectionFilter', DoGammaFix);
      GammaValue          := ReadFloat('Filter', 'GammaCorrectionValue', GammaValue);
      DoContrastFix       := ReadBool('Filter', 'ContrastCorrectionFilter', DoContrastFix);
      ContrastValue       := ReadFloat('Filter', 'ContrastCorrectionValue', ContrastValue);
      DoSharpen           := ReadBool('Filter', 'SharpFilter', DoSharpen);
      SharpValue          := ReadInteger('Filter', 'SharpValue', SharpValue);
      DoClean             := ReadBool('Filter', 'CleanFilter', DoClean);
      CleanValue          := ReadInteger('Filter', 'CleanValue', CleanValue);
      DoGrayscale         := ReadBool('Filter', 'GrayscaleFilter', DoGrayscale);
      GrayscaleMethod     := ReadInteger('Filter', 'GrayscaleMethod', GrayscaleMethod);
      DoWhite             := ReadBool('Filter', 'WhiteFilter', DoWhite);
      WhiteValue          := ReadInteger('Filter', 'WhiteValue', WhiteValue);
      DoLMap              := ReadBool('Filter', 'LMapFilter', DoLMap);
      LMapValue           := ReadString('Filter', 'LMapValue', LMapValue);

      //Other
      TimeFormat          := ReadString('Other', 'TimeFormat', TimeFormat);
      OpenFolder          := ReadBool('Other', 'OpenFolder', OpenFolder);
      EnableLMap          := ReadBool('Other', 'EnableLMap', EnableLMap);
      IncludeSubDir       := ReadBool('Other', 'IncludeSubDir', IncludeSubDir);
      PostExec            := ReadString('Other', 'PostExec', PostExec);
      SortFileList        := ReadBool('Other', 'SortFileList', SortFileList);
      DisableIL           := ReadBool('Other', 'DisableIL', DisableIL);
      DisableIS           := ReadBool('Other', 'DisableIS', DisableIS);
      MinimizedStart      := ReadBool('Other', 'MinimizedStart', MinimizedStart);
      TrimRectError       := ReadBool('Other', 'TrimRectError', TrimRectError);
      TrimRectFillColor   := ReadString('Other', 'TrimRectFillColor', TrimRectFillColor);
      FilterOrder         := ReadString('Other', 'FilterOrder', FilterOrder);
      MaxThreads          := ReadInteger('Other', 'MaxThreads', MaxThreads);
      ContinueOnError     := ReadBool('Other', 'ContinueOnError', ContinueOnError);
      LogFileName         := ReadString('Other', 'LogFileName', LogFileName);

      LMapMenu.Visible := EnableLMap;
      LMapValueMenu.Visible := EnableLMap;
    end;
  finally
    FreeAndNil(IniFile);
  end;
  ResetCondComboBoxEnabled;
end;

procedure TMainForm.SaveIniFile(FileName: string);
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(FileName);
  try
    with IniFile do
    begin
      //Window
      WriteBool('Window', 'StayOnTop', StayOnTop);
      WriteInteger('Window', 'Top', Top);
      WriteInteger('Window', 'Left', Left);
      WriteBool('Window', 'Idle', IdleMode);

      //Files
      WriteString('Files', 'MapFile', MapFile);
      WriteString('Files', 'ClipboardFile', ClipboardFile);

      //Directories
      WriteString('Directories', 'SpiDirectory', SpiDirectory);
      WriteString('Directories', 'SampleDirectory', SampleDirectory);
      WriteString('Directories', 'LastDirectory', LastDirectory);

      //Output
      WriteString('Output', 'FilePattern', FilePattern);
      WriteBool('Output', 'AvoidCollision', AvoidCollision);
      WriteInteger('Output', 'JPEGQuality', JPEGQuality);
      {$IFNDEF NoJPEGSubsampling}
      WriteBool('Output', 'JPEGSubsampling', JpegSubsampling);
      {$ENDIF}
      WriteBool('Output', 'ProgressiveJPEG', ProgressiveJpeg);
      WriteInteger('Output', 'PNGCompressLevel', PNGCompress);
      WriteBool('Output', 'TimeStampCopy', TimeStampCopy);
      WriteBool('Output', 'AutoIndexed', AutoIndexed);
      WriteBool('Output', 'AutoRotate', AutoRotate);

      //Resize
      WriteInteger('Resize', 'ValueType', Ord(ValueType));
      WriteBool('Resize', 'KeepRatio', KeepRatio);
      WriteFloat('Resize', 'WidthValue', WidthValue);
      WriteFloat('Resize', 'HeightValue', HeightValue);
      WriteInteger('Resize', 'RatioBase', Ord(RatioBase));
      WriteInteger('Resize', 'Method', Method);
      WriteBool('Resize', 'FloatMode', FloatMode);
      WriteBool('Resize', 'NonMagnify', NonMagnify);
      WriteBool('Resize', 'LinearizedReduction', LinearizedReduction);

      //HTML
      WriteBool('HTML', 'Generate', HTMLGenerate);
      WriteString('HTML', 'FileName', HTMLFileName);
      WriteBool('HTML', 'ReversePlace', HTMLReversePlace);
      WriteString('HTML', 'TemplateFile', HTMLTemplateFile);
      WriteInteger('HTML', 'Nth', HTMLNth);
      WriteString('HTML', 'OnStart', HTMLOnStart);
      WriteString('HTML', 'OnItem', HTMLOnItem);
      WriteString('HTML', 'OnNth', HTMLOnNth);
      WriteString('HTML', 'OnRemain', HTMLOnRemain);
      WriteString('HTML', 'OnEnd', HTMLOnEnd);

      //Filter
      WriteBool('Filter', 'TrimFilter', DoTrim);
      WriteString('Filter', 'TrimRect', TrimRect);
      WriteBool('Filter', 'TurnOverFilter', DoTurnOver);
      WriteBool('Filter', 'RotateFilter', DoRotate);
      WriteInteger('Filter', 'RotateAngle', RotateAngle);
      WriteBool('Filter', 'NormalizeFilter', DoNormalize);
      WriteInteger('Filter', 'NormalizeMin', NormalizeMin);
      WriteInteger('Filter', 'NormalizeMax', NormalizeMax);
      WriteBool('Filter', 'LuminanceCorrectionFilter', DoLumaFix);
      WriteInteger('Filter', 'LuminanceMin', LumaMin);
      WriteInteger('Filter', 'LuminanceMax', LumaMax);
      WriteBool('Filter', 'GammaCorrectionFilter', DoGammaFix);
      WriteFloat('Filter', 'GammaCorrectionValue', GammaValue);
      WriteBool('Filter', 'ContrastCorrectionFilter', DoContrastFix);
      WriteFloat('Filter', 'ContrastCorrectionValue', ContrastValue);
      WriteBool('Filter', 'SharpFilter', DoSharpen);
      WriteInteger('Filter', 'SharpValue', SharpValue);
      WriteBool('Filter', 'CleanFilter', DoClean);
      WriteInteger('Filter', 'CleanValue', CleanValue);
      WriteBool('Filter', 'GrayscaleFilter', DoGrayscale);
      WriteInteger('Filter', 'GrayscaleMethod', GrayscaleMethod);
      WriteBool('Filter', 'WhiteFilter', DoWhite);
      WriteInteger('Filter', 'WhiteValue', WhiteValue);
      WriteBool('Filter', 'LMapFilter', DoLMap);
      WriteString('Filter', 'LMapValue', LMapValue);

      //Other
      WriteString('Other', 'TimeFormat', TimeFormat);
      WriteBool('Other', 'OpenFolder', OpenFolder);
      WriteBool('Other', 'EnableLMap', EnableLMap);
      WriteBool('Other', 'IncludeSubDir', IncludeSubDir);
      WriteString('Other', 'PostExec', PostExec);
      WriteBool('Other', 'SortFileList', SortFileList);
      WriteBool('Other', 'DisableIL', DisableIL);
      WriteBool('Other', 'DisableIS', DisableIS);
      WriteBool('Other', 'MinimizedStart', MinimizedStart);
      WriteBool('Other', 'TrimRectError', TrimRectError);
      WriteString('Other', 'TrimRectFillColor', TrimRectFillColor);
      WriteString('Other', 'FilterOrder', FilterOrder);
      WriteInteger('Other', 'MaxThreads', MaxThreads);
      WriteBool('Other', 'ContinueOnError', ContinueOnError);
      WriteString('Other', 'LogFileName', LogFileName);
    end;
  finally
    FreeAndNil(IniFile);
  end;
end;

procedure TMainForm.WMDropFiles(var Msg: TWMDropFiles);
var
  FileName: string;
  I, Count: Cardinal;
begin
  FileList.Clear;
  try
    Count := DragQueryFile(Msg.Drop, $FFFFFFFF, nil, 0);
    for I := 0 to Count - 1 do
    begin
      SetLength(FileName, MAX_PATH + 1);
      DragQueryFile(Msg.Drop, I, PChar(FileName), MAX_PATH);
      SetLength(FileName, StrLen(PChar(FileName)));
      AddFile(FileName);
    end;
    MainProcess;
  finally
    DragFinish(Msg.Drop);
  end;
end;

procedure TMainForm.ExitMenuClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.AboutMenuClick(Sender: TObject);
begin
  AboutBox;
end;

procedure TMainForm.RatioKeepCheckBoxClick(Sender: TObject);
begin
  ResetCondComboBoxEnabled;
end;

procedure TMainForm.SizeRadioGroupClick(Sender: TObject);
begin
  case SizeRadioGroup.ItemIndex of
    0:
      begin
        WidthEdit.Text := IntToStr(GetSystemMetrics(SM_CXSCREEN));
        HeightEdit.Text := IntToStr(GetSystemMetrics(SM_CYSCREEN));
        UnitLabel1.Caption := 'ピクセル';
        UnitLabel2.Caption := 'ピクセル';
      end;
    1:
      begin
        WidthEdit.Text := '100';
        HeightEdit.Text := '100';
        UnitLabel1.Caption := '%';
        UnitLabel2.Caption := '%';
      end;
  else ; //error
  end;
  ResetCondComboBoxEnabled;
end;

procedure TMainForm.WidthEditChange(Sender: TObject);
var
  X: Extended;
begin
  if RatioKeepCheckBox.Checked and (SizeRadioGroup.ItemIndex = 1) then
  begin
    X := EvalDef(WidthEdit.Text, -1);
    if X <> -1 then
    begin
      HeightEdit.OnChange := nil;
      HeightEdit.Text := FloatToStr(X);
      HeightEdit.OnChange := HeightEditChange;
    end;
  end;
end;

procedure TMainForm.HeightEditChange(Sender: TObject);
var
  X: Extended;
begin
  if RatioKeepCheckBox.Checked and (SizeRadioGroup.ItemIndex = 1) then
  begin
    X := EvalDef(HeightEdit.Text, -1);
    if X <> -1 then
    begin
      WidthEdit.OnChange := nil;
      WidthEdit.Text := FloatToStr(X);
      WidthEdit.OnChange := WidthEditChange;
    end;
  end;
end;

procedure TMainForm.IdleModeMenuClick(Sender: TObject);
begin
  TMenuItem(Sender).Checked := not TMenuItem(Sender).Checked;
  if TMenuItem(Sender).Checked then
    SetPriorityClass(GetCurrentProcess, IDLE_PRIORITY_CLASS)
  else
    SetPriorityClass(GetCurrentProcess, NORMAL_PRIORITY_CLASS);
end;

procedure TMainForm.OnTopMenuClick(Sender: TObject);
begin
  StayOnTop := not StayOnTop;
end;

procedure TMainForm.GoGitHubIssuesMenuClick(Sender: TObject);
begin
  GoGitHubIssues;
end;

procedure TMainForm.GoGitHubMenuClick(Sender: TObject);
begin
  GoGitHub;
end;

procedure TMainForm.GoWebMenuClick(Sender: TObject);
begin
  GoWeb;
end;

procedure TMainForm.SendMailMenuClick(Sender: TObject);
begin
  SendMail;
end;

procedure TMainForm.AppException(Sender: TObject; E: Exception);
begin
  Error(Format('[BUG] %s', [E.Message]));
  Close();
end;

procedure TMainForm.AppHint(Sender: TObject);
begin
  StatusView := Application.Hint;
end;

procedure TMainForm.ClipBoardMenuClick(Sender: TObject);
var
  Bitmap: TBitmap;
  S: string;
begin
  if not ClipBoard.HasFormat(CF_BITMAP) then
  begin
    StatusView := 'クリップボードにビットマップファイルが存在しません';
    Exit;
  end;

  S := DecodePathExp(ClipboardFile);
  Bitmap := TBitmap.Create;
  try
    Bitmap.LoadFromClipBoardFormat(CF_BITMAP, ClipBoard.GetAsHandle(CF_BITMAP), 0);
    Bitmap.SaveToFile(S);
  finally
    FreeAndNil(Bitmap);
  end;

  FileList.Clear;
  AddFile(S);
  MainProcess;
end;

procedure TMainForm.JpegQualityMenuClick(Sender: TObject);
var
  X: Integer;
begin
  X := StrToIntDef(InputBox('JPEG 画質', '画質 (1～100)', IntToStr(JpegQuality)), 80);
  if (X < 1) or (X > 100) then X := 80;
  JpegQuality := X;
end;

procedure TMainForm.SharpValueMenuClick(Sender: TObject);
var
  S: string;
begin
  S := IntToStr(SharpValue);
  if InputQuery('輪郭強調度', '強さ (0～100)', S) then
  begin
    SharpValue := StrToIntDefWithRange(S, SharpValue, 0, 100);
    DoSharpen := True;
  end;
end;

procedure TMainForm.ShowHelpMenuClick(Sender: TObject);
begin
  ShellExecute(0, nil, PChar(AppPath + '\help\index.html'), nil, nil, SW_SHOW);
end;

procedure TMainForm.OpenMenuClick(Sender: TObject);
begin
  OpenDialog.InitialDir := LastDirectory;
  if OpenDialog.Execute then
  begin
    LoadIniFile(OpenDialog.FileName);
    LastDirectory := ExtractFilePath(OpenDialog.FileName);
  end;
end;

procedure TMainForm.SaveMenuClick(Sender: TObject);
begin
  SaveDialog.InitialDir := LastDirectory;
  if SaveDialog.Execute then
  begin
    SaveIniFile(SaveDialog.FileName);
    LastDirectory := ExtractFilePath(SaveDialog.FileName);
  end;
end;

procedure TMainForm.CheckMenuClick(Sender: TObject);
begin
  TMenuItem(Sender).Checked := not TMenuItem(Sender).Checked;
end;

function TMainForm.GetStayOnTop: Boolean;
begin
  Result := OnTopMenu.Checked;
end;

procedure TMainForm.SetStayOnTop(const Value: Boolean);
begin
  if OnTopMenu.Checked <> Value then
  begin
    OnTopMenu.Checked := Value;
    if Value then FormStyle := fsStayOnTop
    else FormStyle := fsNormal;
  end;
end;

procedure TMainForm.SetFilePattern(const Value: string);
begin
  FilePatternEdit.Text := Value;
end;

function TMainForm.GetFilePattern: string;
begin
  Result := FilePatternEdit.Text;
end;

function TMainForm.GetHTMLGenerate: Boolean;
begin
  Result := HTMLCheckBox.Checked;
end;

procedure TMainForm.SetHTMLGenerate(const Value: Boolean);
begin
  HTMLCheckBox.Checked := Value;
end;

procedure TMainForm.SetValueType(const Value: TValueType);
begin
  case Value of
    vtAbsolute: SizeRadioGroup.ItemIndex := 0;
    vtRelative: SizeRadioGroup.ItemIndex := 1;
  else
    SizeRadioGroup.ItemIndex := 1; //error
  end;
end;

function TMainForm.GetValueType: TValueType;
begin
  case SizeRadioGroup.ItemIndex of
    0: Result := vtAbsolute;
    1: Result := vtRelative;
  else
    Result := vtRelative; //error
  end;
end;

procedure TMainForm.SetKeepRatio(const Value: Boolean);
begin
  RatioKeepCheckBox.Checked := Value;
end;

procedure TMainForm.SetLinearizedReduction(const Value: Boolean);
begin
  LinearizedReductionMenu.Checked := Value;
end;

procedure TMainForm.SetMaxThreads(const Value: Integer);
begin
  FMaxThreads := Value;
  SetThreadCount(Value);
end;

procedure TMainForm.SetMethod(const Value: Integer);
begin
  if Value < 16 then Exit;
  TMenuItem(FindComponent(Format('Enlarge%dMenu', [Value and $F]))).Checked := True;
  TMenuItem(FindComponent(Format('Reduce%dMenu', [(Value shr 4) and $F]))).Checked := True;
end;

function TMainForm.GetKeepRatio: Boolean;
begin
  Result := RatioKeepCheckBox.Checked;
end;

function TMainForm.GetLinearizedReduction: Boolean;
begin
  Result := LinearizedReductionMenu.Checked;
end;

function TMainForm.GetMethod: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to 5 do
  begin
    if TMenuItem(FindComponent(Format('Enlarge%dMenu', [I]))).Checked then
      Result := Result + I;
    if TMenuItem(FindComponent(Format('Reduce%dMenu', [I]))).Checked then
      Result := Result + (I shl 4);
  end;
end;

procedure TMainForm.SetHeightValue(const Value: Extended);
begin
  HeightEdit.Text := FloatToStr(Value);
end;

procedure TMainForm.SetWidthValue(const Value: Extended);
begin
  WidthEdit.Text := FloatToStr(Value);
end;

function TMainForm.GetHeightValue: Extended;
begin
  Result := EvalDef(HeightEdit.Text, 0);
end;

function TMainForm.GetWidthValue: Extended;
begin
  Result := EvalDef(WidthEdit.Text, 0);
end;

procedure TMainForm.SetSortFileList(const Value: Boolean);
begin
  FileListSortMenu.Checked := Value;
end;

procedure TMainForm.SetStatusView(const Value: string);
begin
  StatusBar.SimpleText := Value;
end;

function TMainForm.GetSortFileList: Boolean;
begin
  Result := FileListSortMenu.Checked;
end;

function TMainForm.GetStatusView: string;
begin
  Result := StatusBar.SimpleText;
end;

procedure TMainForm.SetRatioBase(const Value: TRatioBase);
begin
  case Value of
    rbWidth:  CondComboBox.ItemIndex := 0;
    rbHeight: CondComboBox.ItemIndex := 1;
    rbLong:   CondComboBox.ItemIndex := 2;
    rbShort:  CondComboBox.ItemIndex := 3;
    rbMax:    CondComboBox.ItemIndex := 4;
    rbMin:    CondComboBox.ItemIndex := 5;
  else
    CondComboBox.ItemIndex := 1; //error
  end;
end;

function TMainForm.GetRatioBase: TRatioBase;
begin
  case CondComboBox.ItemIndex of
    0: Result := rbWidth;
    1: Result := rbHeight;
    2: Result := rbLong;
    3: Result := rbShort;
    4: Result := rbMax;
    5: Result := rbMin;
  else
    Result := rbHeight; //error
  end;
end;

procedure TMainForm.SetJpegQuality(const Value: Integer);
begin
  FJpegQuality := Value;
end;

{$IFNDEF NoJPEGSubsampling}
procedure TMainForm.SetJPEGSubsampling(const Value: Boolean);
begin
  JPEGSubsamplingMenu.Checked := Value;
end;
{$ENDIF}

function TMainForm.GetHTMLReversePlace: Boolean;
begin
  Result := HTMLReversePlaceMenu.Checked;
end;

function TMainForm.GetIdleMode: Boolean;
begin
  Result := IdleModeMenu.Checked;
end;

function TMainForm.GetIncludeSubDir: Boolean;
begin
  Result := IncludeSubDirMenu.Checked;
end;

{$IFNDEF NoJPEGSubsampling}
function TMainForm.GetJPEGSubsampling: Boolean;
begin
  Result := JPEGSubsamplingMenu.Checked;
end;
{$ENDIF}

procedure TMainForm.SetHTMLReversePlace(const Value: Boolean);
begin
  HTMLReversePlaceMenu.Checked := Value;
end;

procedure TMainForm.SetIdleMode(const Value: Boolean);
begin
  if Value <> IdleModeMenu.Checked then
  begin
    if Value then
      SetPriorityClass(GetCurrentProcess, IDLE_PRIORITY_CLASS)
    else
      SetPriorityClass(GetCurrentProcess, NORMAL_PRIORITY_CLASS);
  end;
  IdleModeMenu.Checked := Value;
end;

procedure TMainForm.SetIncludeSubDir(const Value: Boolean);
begin
  IncludeSubDirMenu.Checked := Value;
end;

procedure TMainForm.SampleMenuXClick(Sender: TObject);
var
  S: string;
begin
  S := TMenuItem(Sender).Caption;
  LoadIniFile(DecodePathExp(SampleDirectory) + S + '.ini');
end;

procedure TMainForm.SetTimeStampCopy(const Value: Boolean);
begin
  CopyTimeStampMenu.Checked := Value;
end;

function TMainForm.GetTimeStampCopy: Boolean;
begin
  Result := CopyTimeStampMenu.Checked;
end;

procedure TMainForm.SetOpenFolder(const Value: Boolean);
begin
  OpenFolderMenu.Checked := Value;
end;

function TMainForm.GetOpenFolder: Boolean;
begin
  Result := OpenFolderMenu.Checked;
end;

procedure TMainForm.SetDoSharpen(const Value: Boolean);
begin
  SharpEffectMenu.Checked := Value;
end;

function TMainForm.GetDoSharpen: Boolean;
begin
  Result := SharpEffectMenu.Checked;
end;

procedure TMainForm.SetAvoidCollision(const Value: Boolean);
begin
  AvoidCollisionMenu.Checked := Value;
end;

function TMainForm.GetAvoidCollision: Boolean;
begin
  Result := AvoidCollisionMenu.Checked;
end;

function TMainForm.GetNonMagnify: Boolean;
begin
  Result := NonMagnifyMenu.Checked;
end;

procedure TMainForm.SetNonMagnify(const Value: Boolean);
begin
  NonMagnifyMenu.Checked := Value;
end;

function TMainForm.GetDoClean: Boolean;
begin
  Result := CleanEffectMenu.Checked;
end;

procedure TMainForm.SetDoClean(const Value: Boolean);
begin
  CleanEffectMenu.Checked := Value;
end;

procedure TMainForm.CleanValueMenuClick(Sender: TObject);
var
  S: string;
begin
  S := IntToStr(CleanValue);
  if InputQuery('ノイズ除去度', '強さ (0～100)', S) then
  begin
    CleanValue := StrToIntDefWithRange(S, CleanValue, 0, 100);
    DoClean := True;
  end;
end;

function TMainForm.GetDoGrayscale: Boolean;
begin
  Result := GrayscaleMenu.Checked;
end;

function TMainForm.GetDoNormalize: Boolean;
begin
  Result := NormalizeMenu.Checked;
end;

procedure TMainForm.SetDoGrayscale(const Value: Boolean);
begin
  GrayscaleMenu.Checked := Value;
end;

procedure TMainForm.SetDoNormalize(const Value: Boolean);
begin
  NormalizeMenu.Checked := Value;
end;

function TMainForm.GetProgressiveJpeg: Boolean;
begin
  Result := ProgressiveJpegMenu.Checked;
end;

procedure TMainForm.SetProgressiveJpeg(const Value: Boolean);
begin
  ProgressiveJpegMenu.Checked := Value;
end;

procedure TMainForm.AddFile(FileName: string);
  procedure DirectoryScan(const Path: string);
  var
    F: TSearchRec;
  begin
    if FindFirst(Path + '\*.*', faAnyFile - faDirectory, F) = 0 then
    begin
      repeat
        AddFile(Path + '\' + F.Name);
      until FindNext(F) <> 0;
      FindClose(F);
    end;

    if IncludeSubDir then
    begin
      if FindFirst(Path + '\*.*', faDirectory, F) = 0 then
      begin
        repeat
          if not StringInSet(F.Name, ['.', '..']) then
          begin
            DirectoryScan(Path + '\' + F.Name)
          end;
        until FindNext(F) <> 0;
        FindClose(F);
      end;
    end;
  end;

  function FormatCheck(const FileName: string): Boolean;
  var
    Ext: string;
  begin
    Ext := ExtractFileExt(FileName);
    if DisableIL then Result := False
{$IF CompilerVersion >= 21.0}
    else Result := FileExtInSet(Ext, ['.bmp', '.jpg', '.jpeg', '.gif', '.png',
                                      '.ico', '.tif', '.tiff', '.jxr', '.hdp', '.wdp']);
{$ELSE}
    else Result := FileExtInSet(Ext, ['.bmp', '.jpg', '.jpeg', '.gif', '.png']);
{$IFEND}
    Result := Result or IsLoadableBySpi(Copy(Ext, 2, Length(Ext)));
    if not Result then Warn(Format('Unsupported image format: %s', [FileName]));
  end;

begin
  if IsDirectory(FileName) then
    DirectoryScan(FileName)
  else
    if FormatCheck(FileName) then FileList.Add(FileName);
end;

procedure TMainForm.ParamExecute(Sender: TObject; var Done: Boolean);
var
  I: Integer;
begin
  Application.OnIdle := nil;
  FileList.Clear;
  for I := 2 to ParamCount do AddFile(ParamStr(I));
  MainProcess;
  Close;
end;

procedure TMainForm.PngCompressMenuClick(Sender: TObject);
var
  S: string;
begin
  S := IntToStr(PngCompress);
  if InputQuery('PNG圧縮率', '圧縮率 (0～9)', S) then
  begin
    PngCompress := StrToIntDefWithRange(S, PngCompress, 0, 9);
  end;
end;

function TMainForm.GetDoGammaFix: Boolean;
begin
  Result := GammaFixMenu.Checked;
end;

procedure TMainForm.SetDoGammaFix(const Value: Boolean);
begin
  GammaFixMenu.Checked := Value;
end;

procedure TMainForm.GammaValueMenuClick(Sender: TObject);
var
  S: string;
begin
  S := FloatToStr(GammaValue);
  if InputQuery('相対ガンマ値', '値', S) then
  begin
    GammaValue := StrToFloatDef(S, GammaValue);
    DoGammaFix := True;
  end;
end;

procedure TMainForm.ContrastValueMenuClick(Sender: TObject);
var
  S: string;
begin
  S := FloatToStr(ContrastValue);
  if InputQuery('コントラスト補正値', '値', S) then
  begin
    ContrastValue := StrToFloatDef(S, ContrastValue);
    DoContrastFix := True;
  end;
end;

function TMainForm.GetDoContrastFix: Boolean;
begin
  Result := ContrastFixMenu.Checked;
end;

procedure TMainForm.SetDoContrastFix(const Value: Boolean);
begin
  ContrastFixMenu.Checked := Value;
end;

function TMainForm.GetDoLumaFix: Boolean;
begin
  Result := LumaFixMenu.Checked;
end;

procedure TMainForm.SetDoLumaFix(const Value: Boolean);
begin
  LumaFixMenu.Checked := Value;
end;

procedure TMainForm.NormalizeRangeMenuClick(Sender: TObject);
var
  S: string;
begin
  S := Format('%d/%d', [NormalizeMin, NormalizeMax]);
  if InputQuery('正規化範囲', '範囲: Min/Max', S) then
  begin
    NormalizeMin := StrToIntDef(Copy(S, 1, Pos('/', S) - 1), 0);
    NormalizeMax := StrToIntDef(Copy(S, Pos('/', S) + 1,  Length(S)), 255);
    DoNormalize := True;
  end;
end;

procedure TMainForm.LumaRangeMenuClick(Sender: TObject);
var
  S: string;
begin
  S := Format('%d/%d', [LumaMin, LumaMax]);
  if InputQuery('輝度範囲', '範囲: Min/Max', S) then
  begin
    LumaMin := StrToIntDef(Copy(S, 1, Pos('/', S) - 1), 0);
    LumaMax := StrToIntDef(Copy(S, Pos('/', S) + 1,  Length(S)), 255);
    DoLumaFix := True;
  end;
end;

procedure TMainForm.ResetCondComboBoxEnabled;
begin
  if RatioKeepCheckBox.Checked and (SizeRadioGroup.ItemIndex = 0) then
    CondComboBox.Enabled := True
  else CondComboBox.Enabled := False;
end;

procedure TMainForm.TrimValueMenuClick(Sender: TObject);
var
  S: string;
begin
  S := TrimRect;
  if InputQuery('切り抜き範囲', '範囲: x1,y1,x2,y2', S) then
  begin
    TrimRect := S;
    DoTrim := True;
  end;
end;

function TMainForm.GetDoTrim: Boolean;
begin
  Result := TrimMenu.Checked;
end;

procedure TMainForm.SetDoTrim(const Value: Boolean);
begin
  TrimMenu.Checked := Value;
end;

procedure TMainForm.RotateAngleMenuClick(Sender: TObject);
var
  S: string;
begin
  S := IntToStr(RotateAngle);
  if InputQuery('回転角度', '角度: 0 or 90 or 180 or 270', S) then
  begin
    RotateAngle := StrToIntDef(S, 0);
    DoRotate := True;
  end;
end;

procedure TMainForm.SetDoRotate(const Value: Boolean);
begin
  RotateMenu.Checked := Value;
end;

procedure TMainForm.SetDoTurnOver(const Value: Boolean);
begin
  TurnOverMenu.Checked := Value;
end;

function TMainForm.GetDoRotate: Boolean;
begin
  Result := RotateMenu.Checked;
end;

function TMainForm.GetDoTurnOver: Boolean;
begin
  Result := TurnOverMenu.Checked;
end;

procedure TMainForm.GrayscaleMethodMenuClick(Sender: TObject);
var
  S: string;
begin
  S := IntToStr(GrayscaleMethod);
  if InputQuery('白黒化法', '手法 (0～2)', S) then
  begin
    GrayscaleMethod := StrToIntDefWithRange(S, GrayscaleMethod, 0, 2);
    DoGrayscale := True;
  end;
end;

procedure TMainForm.LMapValueMenuClick(Sender: TObject);
var
  S: string;
begin
  S := LMapValue;
  if InputQuery('LMap', 'x1=y1,x2=y2,x3=y3,...', S) then
  begin
    LMapValue := S;
    DoLMap := True;
  end;
end;

function TMainForm.GetDoLMap: Boolean;
begin
  Result := LMapMenu.Checked;
end;

procedure TMainForm.SetDoLMap(const Value: Boolean);
begin
  LMapMenu.Checked := Value;
end;

procedure TMainForm.SetAutoIndexed(const Value: Boolean);
begin
  AutoIndexedMenu.Checked := Value;
end;

function TMainForm.GetAutoIndexed: Boolean;
begin
  Result := AutoIndexedMenu.Checked;
end;

procedure TMainForm.SetAutoRotate(const Value: Boolean);
begin
  ExifAutoRotateMenu.Checked := Value;
end;

function TMainForm.GetAutoRotate: Boolean;
begin
  Result := ExifAutoRotateMenu.Checked;
end;

procedure TMainForm.SetDoWhite(const Value: Boolean);
begin
  WhiteFilterMenu.Checked := Value;
end;

function TMainForm.GetDoWhite: Boolean;
begin
  Result := WhiteFilterMenu.Checked;
end;

procedure TMainForm.WhiteValueMenuClick(Sender: TObject);
var
  S: string;
begin
  S := IntToStr(WhiteValue);
  if InputQuery('白色化閾値', '閾値 (0～255)', S) then
  begin
    WhiteValue := StrToIntDefWithRange(S, WhiteValue, 0, 255);
    DoWhite := True;
  end;
end;

end.

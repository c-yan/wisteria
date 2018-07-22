unit Process;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  Vcl.ComCtrls;

type
  TProcessForm = class(TForm)
    GlobalLabel: TLabel;
    LocalLabel: TLabel;
    GlobalProgressBar: TProgressBar;
    LocalProgressBar: TProgressBar;
    FileNameLabel: TLabel;
    SituationLabel: TLabel;
    AbortButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    procedure AbortButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FAbortRequire: Boolean;
    procedure SetGlobalProgress(const Value: Integer);
    procedure SetLocalProgress(const Value: Integer);
    procedure SetProcessingFile(const Value: string);
    procedure SetProcessingSituation(const Value: string);
    function GetGlobalProgress: Integer;
    function GetLocalProgress: Integer;
  public
    property GlobalProgress: Integer read GetGlobalProgress
      write SetGlobalProgress;
    property LocalProgress: Integer read GetLocalProgress
      write SetLocalProgress;
    property ProcessingFile: string write SetProcessingFile;
    property ProcessSituation: string write SetProcessingSituation;
    property AbortRequire: Boolean read FAbortRequire write FAbortRequire;
  end;

var
  ProcessForm: TProcessForm;

implementation

{$R *.DFM}
{ TProcessForm }

procedure TProcessForm.SetGlobalProgress(const Value: Integer);
begin
  GlobalLabel.Caption := IntToStr(Value) + '%';
  GlobalProgressBar.Position := Value;
end;

procedure TProcessForm.SetLocalProgress(const Value: Integer);
begin
  LocalLabel.Caption := IntToStr(Value) + '%';
  LocalProgressBar.Position := Value;
end;

procedure TProcessForm.SetProcessingFile(const Value: string);
begin
  FileNameLabel.Caption := Value;
end;

procedure TProcessForm.SetProcessingSituation(const Value: string);
begin
  SituationLabel.Caption := Value;
end;

procedure TProcessForm.AbortButtonClick(Sender: TObject);
begin
  AbortRequire := True;
end;

procedure TProcessForm.FormShow(Sender: TObject);
begin
  AbortRequire := False;
end;

function TProcessForm.GetGlobalProgress: Integer;
begin
  Result := GlobalProgressBar.Position;
end;

function TProcessForm.GetLocalProgress: Integer;
begin
  Result := LocalProgressBar.Position;
end;

end.

unit ParallelUtils;

interface

uses
  Winapi.Windows, System.SysUtils, Vcl.Forms;

procedure ParallelFor(Start, Stop: Integer; Block: TProc<Integer, Integer>); overload;
procedure ParallelFor(Start, Stop: Integer; Block: TProc<Integer>); overload;
procedure SetThreadCount(Count: Integer);

implementation

var
  ThreadCount: Integer;

type
  TThreadInfo = record
    Start: Integer;
    Stop: Integer;
    Proc: TProc<Integer, Integer>;
    ThreadId: LongWord;
    ThreadHandle: Integer;
  end;
  PThreadInfo = ^TThreadInfo;

function GetNumberOfProcessors: Integer;
var
  SystemInfo: TSystemInfo;
begin
  GetSystemInfo(SystemInfo);
  Result := SystemInfo.dwNumberOfProcessors;
end;

procedure SetThreadCount(Count: Integer);
begin
  if Count > 0 then ThreadCount := Count
  else ThreadCount := GetNumberOfProcessors;
end;

function PallarelForThreadFunc(Parameter: Pointer): Integer;
begin
  Result := 0;
  with PThreadInfo(Parameter)^ do
    Proc(Start, Stop);
  EndThread(0);
end;

procedure ParallelFor(Start, Stop: Integer; Block: TProc<Integer, Integer>); overload;
var
  I: Integer;
  Infos: array of TThreadInfo;
begin
  SetLength(Infos, ThreadCount);
  for I := 0 to ThreadCount - 1 do
  begin
    Infos[I].Start := Start + (Stop - Start + 1) * I div ThreadCount;
    Infos[I].Stop := Start + (Stop - Start + 1) * (I + 1) div ThreadCount - 1;
    Infos[I].Proc := Block;
    Infos[I].ThreadHandle := BeginThread(nil, 0, PallarelForThreadFunc, @Infos[I], 0, Infos[I].ThreadId);
  end;
  for I := 0 to ThreadCount - 1 do
  begin
    while WaitForSingleObject(Infos[I].ThreadHandle, 0) = WAIT_TIMEOUT do
    begin
      Application.ProcessMessages;
      Sleep(1);
    end;
    CloseHandle(Infos[I].ThreadHandle);
  end;
end;

procedure ParallelFor(Start, Stop: Integer; Block: TProc<Integer>); overload;
begin
  ParallelFor(Start, Stop,
    procedure (Start, Stop: Integer)
    var
      I: Integer;
    begin
      for I := Start to Stop do Block(I);
    end);
end;

initialization
  ThreadCount := GetNumberOfProcessors;

end.

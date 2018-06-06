unit ImageFunctions;

interface

uses
  Winapi.Windows, Vcl.Graphics, ImageTypes;

procedure NullProgressProc(Progress: Integer);
function Clamp(Value, Min, Max: Int64): Int64; inline; overload;
function Clamp(Value, Min, Max: Integer): Integer; inline; overload;
function Clamp(Value, Min, Max: Single): Single; inline; overload;
function Clamp(Value, Min, Max: Double): Double; inline; overload;
procedure ConvertToTrueColor(const Src: TBitmap); inline;

implementation

procedure NullProgressProc(Progress: Integer);
begin
end;

function Clamp(Value, Min, Max: Int64): Int64; inline; overload;
begin
  if Value < Min then Result := Min
  else if Value > Max then Result := Max
  else Result := Value;
end;

function Clamp(Value, Min, Max: Integer): Integer; inline; overload;
begin
  if Value < Min then Result := Min
  else if Value > Max then Result := Max
  else Result := Value;
end;

function Clamp(Value, Min, Max: Single): Single; inline; overload;
begin
  if Value < Min then Result := Min
  else if Value > Max then Result := Max
  else Result := Value;
end;

function Clamp(Value, Min, Max: Double): Double; inline; overload;
begin
  if Value < Min then Result := Min
  else if Value > Max then Result := Max
  else Result := Value;
end;

procedure ConvertToTrueColor(const Src: TBitmap); inline;
begin
  Src.PixelFormat := PixelBits;
  if Src.Palette <> 0 then DeleteObject(Src.ReleasePalette);
end;

end.

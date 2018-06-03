unit ImageFunctions;

interface

function Clamp(Value, Min, Max: Integer): Integer; inline; overload;
function Clamp(Value, Min, Max: Single): Single; inline; overload;
function Clamp(Value, Min, Max: Double): Double; inline; overload;

implementation

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

end.

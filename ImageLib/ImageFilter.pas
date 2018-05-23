unit ImageFilter;

interface

uses
  Winapi.Windows, Vcl.Graphics, System.Classes, System.SysUtils, System.Math,
  ImageTypes;

procedure GrayscaleFilter(Src: TBitmap; Method: Integer; PProc: TProgressProc);
procedure SharpenFilter(Src: TBitmap; V: Integer; PProc: TProgressProc);
procedure ConditionedAverage(Src: TBitmap; V, T: Integer; PProc: TProgressProc);
procedure GammaFixFilter(Src: TBitmap; V: Extended; PProc: TProgressProc);
procedure ContrastFixFilter(Src: TBitmap; V: Extended; PProc: TProgressProc);
procedure NormalizeFilter(Src: TBitmap; Min, Max: Integer; PProc: TProgressProc);
procedure LumaFixFilter(Src: TBitmap; Min, Max: Integer; PProc: TProgressProc);
procedure TurnOverFilter(Src: TBitmap; PProc: TProgressProc);
procedure RotateFilter(Src: TBitmap; Angle: Integer; PProc: TProgressProc);
procedure TrimFilter(Src: TBitmap; R: TRect; FillColor: string; PProc: TProgressProc);
procedure IndexedFilter(Src: TBitmap; var Grayscale: Boolean; PProc: TProgressProc);
procedure Convert8BitTo4Bit(Src: TBitmap; PProc: TProgressProc);

procedure WhiteFilter(Src: TBitmap; Threshold: Integer; PProc: TProgressProc);
procedure LMapFilter(Src: TBitmap; VList: string; PProc: TProgressProc);
procedure LumaMapFilter(Src: TBitmap; PProc: TProgressProc);

procedure ConvertFromAdobeRGB(Src: TBitmap);

{
procedure ScaleImage(Src, Obj: TBitmap);
procedure SharpenImage(Src, Obj: TBitmap; Str: Integer);
procedure CleanImage(Src, Obj: TBitmap; Str, Rad: Integer);
procedure NormalizeImage(Src, Obj: TBitmap);
procedure MonochromeImage(Src, Obj: TBitmap);
}

implementation

type
  TMapProc = function(X, Y, W, H: Integer): Integer;

  TDoubleArray = array[0..400000] of Double;
  PDoubleArray = ^TDoubleArray;

  TSingleQuad = array[0..3] of Single;

function AdobeRGBToXYZ(C: TByteQuad): TSingleQuad; inline;
  function Linearlize(C: TByteQuad): TSingleQuad; inline;
  var
    I: Integer;
  begin
    for I := 0 to 2 do Result[I] := Power(C[I] / 255, 2.19921875);
    Result[3] := 0;
  end;

  function ConvertToXYZ(C: TSingleQuad): TSingleQuad; inline;
  begin
    Result[3] := 0;
    Result[2] := 0.57667 * C[2] + 0.18556 * C[1] + 0.18823 * C[0];
    Result[1] := 0.29734 * C[2] + 0.62736 * C[1] + 0.07529 * C[0];
    Result[0] := 0.02703 * C[2] + 0.07069 * C[1] + 0.99134 * C[0];
  end;
begin
  Result := ConvertToXYZ(Linearlize(C));
end;

function XYZTosRGB(C: TSingleQuad): TByteQuad; inline;
  function ConvertFromXYZ(C: TSingleQuad): TSingleQuad; inline;
  begin
    Result[3] :=  0;
    Result[2] :=  3.2410 * C[2] - 1.5374 * C[1] - 0.4986 * C[0];
    Result[1] := -0.9692 * C[2] + 1.8760 * C[1] + 0.0416 * C[0];
    Result[0] :=  0.0556 * C[2] - 0.2040 * C[1] + 1.0570 * C[0];
  end;

  function Clamp(C: Single): Single; inline;
  begin
    if C < 0 then Result := 0
    else if C > 1 then Result := 1
    else Result := C;
  end;

  function Nonlinearlize(C: TSingleQuad): TByteQuad; inline;
  var
    I: Integer;
  begin
    for I := 0 to 2 do
      if C[I] <= 0.00304 then Result[I] := Trunc(Clamp(C[I]) * 12.92 * 255 + 0.5)
      else Result[I] := Trunc((1.055 * Power(Clamp(C[I]), 1 / 2.4) - 0.055) * 255 + 0.5);
    Result[3] := 0;
  end;
begin
  Result := Nonlinearlize(ConvertFromXYZ(C));
end;

procedure NullProgressProc(Progress: Integer);
begin
end;

procedure ConvertToTrueColor(Src: TBitmap); inline;
begin
  Src.PixelFormat := PixelBits;
  if Src.Palette <> 0 then DeleteObject(Src.ReleasePalette);
end;

var
  LumaMap: array[0..4080] of Integer;

procedure LumaMapFilter(Src: TBitmap; PProc: TProgressProc);
var
  Dst: TBitmap;
  X, Y: Integer;
  L, U, V: Integer;
  SP, DP: PRGBArray;
  R, G, B: Integer;
begin
  if (Src = nil) or Src.Empty then Exit;
  ConvertToTrueColor(Src);
  if not Assigned(PProc) then PProc := NullProgressProc;

  PProc(0);
  Dst := TBitmap.Create;
  Dst.Assign(Src);
  for Y := 0 to Src.Height - 1 do
  begin
    SP := Src.ScanLine[Y];
    DP := Dst.ScanLine[Y];
    for X := 0 to Src.Width - 1 do
    begin
      L := (306 * SP[X].R + 601 * SP[X].G + 117 * SP[X].B + 32) shr 6;
      U := ((578 * ((SP[X].B shl 4) - L) + 512 + (255 shl 22)) shr 10) - (255 shl 12);
      V := ((730 * ((SP[X].R shl 4) - L) + 512 + (255 shl 22)) shr 10) - (255 shl 12);
      L := LumaMap[L];
      R := ((L shl 10) + 1436 * V + 8192);
      G := ((L shl 10) -  352 * U -  731 * V + 8192);
      B := ((L shl 10) + 1815 * U + 8192);
      if R > (255 shl 14) then DP[X].R := 255 else if R < 0 then DP[X].R := 0
      else DP[X].R := R shr 14;
      if G > (255 shl 14) then DP[X].G := 255 else if G < 0 then DP[X].G := 0
      else DP[X].G := G shr 14;
      if B > (255 shl 14) then DP[X].B := 255 else if B < 0 then DP[X].B := 0
      else DP[X].B := B shr 14;
    end;
    PProc(100 * Y div (Src.Height - 1));
  end;
  Src.Assign(Dst);
  Dst.Free;
end;

procedure TurnOverFilter(Src: TBitmap; PProc: TProgressProc);
var
  Dst: TBitmap;
  SP, DP: PPixelArray;
  W: Integer;
  X, Y: Integer;
begin
  if (Src = nil) or Src.Empty then Exit;
  ConvertToTrueColor(Src);
  if not Assigned(PProc) then PProc := NullProgressProc;

  W := Src.Width - 1;
  Dst := TBitmap.Create;
  Dst.Assign(Src);
  for Y := 0 to Dst.Height - 1 do
  begin
    SP := Src.ScanLine[Y];
    DP := Dst.ScanLine[Y];
    for X := 0 to Dst.Width - 1 do
    begin
      DP[X][0] := SP[W - X][0];
      DP[X][1] := SP[W - X][1];
      DP[X][2] := SP[W - X][2];
    end;
    PProc((100 * Y) div (Dst.Height - 1));
  end;
  Src.Assign(Dst);
  Dst.Free;
end;

function MapToX(X, Y, W, H: Integer): Integer;
begin
  Result := X;
end;

function MapToY(X, Y, W, H: Integer): Integer;
begin
  Result := Y;
end;

function MapToHX(X, Y, W, H: Integer): Integer;
begin
  Result := H - X;
end;

function MapToHY(X, Y, W, H: Integer): Integer;
begin
  Result := H - Y;
end;

function MapToWX(X, Y, W, H: Integer): Integer;
begin
  Result := W - X;
end;

function MapToWY(X, Y, W, H: Integer): Integer;
begin
  Result := W - Y;
end;

procedure RotateFilter(Src: TBitmap; Angle: Integer; PProc: TProgressProc);
const
  MapXArray: array[0..3] of TMapProc = (MapToX, MapToY,  MapToWX, MapToWY);
  MapYArray: array[0..3] of TMapProc = (MapToY, MapToHX, MapToHY, MapToX);
var
  Dst: TBitmap;
  SP: array of PPixelArray;
  DP: PPixelArray;
  H, W: Integer;
  MapX, MapY: TMapProc;
  X, Y: Integer;
begin
  if Angle < 0 then Angle := Angle mod 360 + 360
  else Angle := Angle mod 360;

  if (Src = nil) or Src.Empty or (Angle div 90 = 0) then Exit;
  ConvertToTrueColor(Src);
  if not Assigned(PProc) then PProc := NullProgressProc;

  W := Src.Width - 1;
  H := Src.Height - 1;

  SetLength(SP, Src.Height);
  for Y := 0 to Src.Height - 1 do SP[Y] := Src.ScanLine[Y];
  MapX := MapXArray[Angle div 90];
  MapY := MapYArray[Angle div 90];

  Dst := TBitmap.Create;
  if (Angle = 0) or (Angle = 180) then Dst.Assign(Src)
  else
  begin
    Dst.PixelFormat := PixelBits;
    Dst.Width := Src.Height;
    Dst.Height := Src.Width;
  end;

  for Y := 0 to Dst.Height - 1 do
  begin
    DP := Dst.ScanLine[Y];
    for X := 0 to Dst.Width - 1 do
    begin
      DP[X][0] := SP[MapY(X, Y, W, H)][MapX(X, Y, W, H)][0];
      DP[X][1] := SP[MapY(X, Y, W, H)][MapX(X, Y, W, H)][1];
      DP[X][2] := SP[MapY(X, Y, W, H)][MapX(X, Y, W, H)][2];
    end;
    PProc((100 * Y) div (Dst.Height - 1));
  end;

  Src.Assign(Dst);
  Dst.Free;
end;

procedure ContrastFixFilter(Src: TBitmap; V: Extended; PProc: TProgressProc);
  function Clamp(X, Min, Max: Integer): Integer;
  begin
    if X < Min then Result := Min
    else if X > Max then Result := Max
    else Result := X;
  end;
var
  Dst: TBitmap;
  X, Y: Integer;
  SP: PRGBArray;
  DP: PRGBArray;
  Table: array[0..255] of Integer;
begin
  if (Src = nil) or Src.Empty then Exit;
  ConvertToTrueColor(Src);
  if not Assigned(PProc) then PProc := NullProgressProc;

  PProc(0);
  Dst := TBitmap.Create;
  Dst.Assign(Src);
  for X := 0 to 255 do Table[X] := Clamp(Trunc((X - 127.5) * V + 127.5 + 0.5), 0, 255);
  for Y := 0 to Src.Height - 1 do
  begin
    SP := Src.ScanLine[Y];
    DP := Dst.ScanLine[Y];
    for X := 0 to Src.Width - 1 do
    begin
      DP[X].B := Table[SP[X].B];
      DP[X].G := Table[SP[X].G];
      DP[X].R := Table[SP[X].R];
    end;
    PProc(100 * Y div (Src.Height - 1));
  end;
  Src.Assign(Dst);
  Dst.Free;
end;

procedure GammaFixFilter(Src: TBitmap; V: Extended; PProc: TProgressProc);
var
  Dst: TBitmap;
  X, Y: Integer;
  SP: PRGBArray;
  DP: PRGBArray;
  Table: array[0..255] of Integer;
begin
  if (Src = nil) or Src.Empty then Exit;
  ConvertToTrueColor(Src);
  if not Assigned(PProc) then PProc := NullProgressProc;

  PProc(0);
  Dst := TBitmap.Create;
  Dst.Assign(Src);
  for X := 0 to 255 do Table[X] := Trunc(Power(X / 255, V) * 255 + 0.5);
  for Y := 0 to Src.Height - 1 do
  begin
    SP := Src.ScanLine[Y];
    DP := Dst.ScanLine[Y];
    for X := 0 to Src.Width - 1 do
    begin
      DP[X].B := Table[SP[X].B];
      DP[X].G := Table[SP[X].G];
      DP[X].R := Table[SP[X].R];
    end;
    PProc(100 * Y div (Src.Height - 1));
  end;
  Src.Assign(Dst);
  Dst.Free;
end;

procedure ConditionedAverage(Src: TBitmap; V, T: Integer; PProc: TProgressProc);
const
  PF = 16;
  PV = 1 shl PF;
  PH = 1 shl PF shr 1;
var
  SP: array of PRGBArray;
  DP, APP: PRGBArray;
  CP, AP: PRGB;
  Dst: TBitmap;
  H, W: Integer;
  X, Y, XX, YY: Integer;
  Threshold: Integer;
  R, G, B: Integer;
  RC, GC, BC: Integer;
  Reciprocal: array of Integer;
begin
  if (Src = nil) or Src.Empty or (Src.Width < T * 2) or (Src.Height < T * 2) then Exit;
  ConvertToTrueColor(Src);
  if not Assigned(PProc) then PProc := NullProgressProc;

  PProc(0);
  if V < 1 then V := 1;
  Threshold := Trunc(V / 8 / 0.587 + 0.5) + 1;
  W := Src.Width - 1;
  H := Src.Height - 1;
  Dst := TBitmap.Create;
  Dst.Assign(Src);
  SetLength(SP, Src.Height);
  for Y := 0 to Src.Height - 1 do SP[Y] := Src.ScanLine[Y];
  Y := (T * 2 + 1) * (T * 2 + 1);
  SetLength(Reciprocal, Y);
  for X := 1 to Y do Reciprocal[X - 1] := (PV + X shr 1) div X;

  for Y := T to H - T do
  begin
    DP := Dst.ScanLine[Y];
    for X := T to W - T do
    begin
      R := 0;  G := 0;  B := 0;
      RC := 0; GC := 0; BC := 0;
      CP := @SP[Y][X];
      for YY := Y - T to Y + T do
      begin
        APP := SP[YY];
        for XX := X - T to X + T do
        begin
          AP := @APP[XX];
          if Abs(AP.B - CP.B) < Threshold then
          begin
            Inc(B, AP.B);
            Inc(BC);
          end;
          if Abs(AP.G - CP.G) < Threshold then
          begin
            Inc(G, AP.G);
            Inc(GC);
          end;
          if Abs(AP.R - CP.R) < Threshold then
          begin
            Inc(R, AP.R);
            Inc(RC);
          end;
        end;
      end;
      DP[X].B := (B * Reciprocal[BC - 1] + PH) shr PF;
      DP[X].G := (G * Reciprocal[GC - 1] + PH) shr PF;
      DP[X].R := (R * Reciprocal[RC - 1] + PH) shr PF;
    end;
    PProc(100 * Y div (H - T));
  end;

  Y := 0;
  while Y <= H do //for Y := 0..T-1, H-T+1..H
  begin
    DP := Dst.ScanLine[Y];
    X := 0;
    while X <= W do //for X := 0..W-1, W-T+1..W
    begin
      R := 0;  G := 0;  B := 0;
      RC := 0; GC := 0; BC := 0;
      CP := @SP[Y][X];
      for YY := Y - T to Y + T do
      begin
        if YY < 0 then APP := SP[0] else if YY > H then APP := SP[H]
        else APP := SP[YY]; //for warning
        for XX := X - T to X + T do
        begin
          if XX < 0 then AP := @APP[0] else if XX > W then AP := @APP[W]
          else AP := @APP[XX]; //for warning
          if Abs(AP.B - CP.B) < Threshold then
          begin
            Inc(B, AP.B);
            Inc(BC);
          end;
          if Abs(AP.G - CP.G) < Threshold then
          begin
            Inc(G, AP.G);
            Inc(GC);
          end;
          if Abs(AP.R - CP.R) < Threshold then
          begin
            Inc(R, AP.R);
            Inc(RC);
          end;
        end;
      end;
      DP[X].B := (B * Reciprocal[BC - 1] + PH) shr PF;
      DP[X].G := (G * Reciprocal[GC - 1] + PH) shr PF;
      DP[X].R := (R * Reciprocal[RC - 1] + PH) shr PF;
      Inc(X);
      if X = T then X := W - T + 1;
    end;
    Inc(Y);
    if Y = T then Y := H - T + 1;
  end;
  Src.Assign(Dst);
  Dst.Free;
end;

procedure SharpenFilter(Src: TBitmap; V: Integer; PProc: TProgressProc);
const
  PF = 16;
  PV = 1 shl PF;
  PH = 1 shl PF shr 1;
var
  SP: array[0..2] of PPixelArray;
  DP: PPixelArray;
  Dst: TBitmap;
  X, Y: Integer;
  I, J: Integer;
  Reciprocal: Integer;
begin
  if (Src = nil) or Src.Empty then Exit;
  ConvertToTrueColor(Src);
  if not Assigned(PProc) then PProc := NullProgressProc;

  PProc(0);
  if V < 21 then V := 21;
  Reciprocal := (PV + (V - 20) shr 1) div (V - 20);
  Dst := TBitmap.Create;
  Dst.Assign(Src);
  DP := Dst.ScanLine[0];
  SP[1] := Src.ScanLine[0];
  for X := 0 to Src.Width - 1 do DP[X] := SP[1][X];
  for Y := 1 to Src.Height - 2 do
  begin
    DP := Dst.ScanLine[Y];
    SP[0] := Src.ScanLine[Y - 1];
    SP[1] := Src.ScanLine[Y];
    SP[2] := Src.ScanLine[Y + 1];
    DP[0] := SP[1][0];
    for X := 1 to Src.Width - 2 do
    begin
      for I := 0 to 2 do
      begin
        J := 0;
        Inc(J, - SP[0][X - 1][I] * 2 - SP[0][X][I] * 3 - SP[0][X + 1][I] * 2);
        Inc(J, - SP[1][X - 1][I] * 3 + SP[1][X][I] * V - SP[1][X + 1][I] * 3);
        Inc(J, - SP[2][X - 1][I] * 2 - SP[2][X][I] * 3 - SP[2][X + 1][I] * 2);
        if J < 0 then DP[X][I] := 0 else
        begin
          J := (J * Reciprocal + PH) shr PF;
          if J > 255 then DP[X][I] := 255
          else DP[X][I] := J;
        end;
      end;
    end;
    DP[Src.Width - 1] := SP[1][Src.Width - 1];
    PProc(100 * Y div (Src.Height - 2));
  end;
  DP := Dst.ScanLine[Src.Height - 1];
  SP[1] := Src.ScanLine[Src.Height - 1];
  for X := 0 to Src.Width - 1 do DP[X] := SP[1][X];
  Src.Assign(Dst);
  Dst.Free;
end;

procedure LumaFixFilter(Src: TBitmap; Min, Max: Integer; PProc: TProgressProc);
var
  Dst: TBitmap;
  X, Y: Integer;
  L, U, V, LNor: Extended;
  SP, DP: PRGBArray;
  R, G, B: Integer;
begin
  if (Src = nil) or Src.Empty then Exit;
  ConvertToTrueColor(Src);
  if not Assigned(PProc) then PProc := NullProgressProc;

  PProc(0);
  Dst := TBitmap.Create;
  Dst.Assign(Src);
  LNor := (Max - Min) / 255;
  for Y := 0 to Src.Height - 1 do
  begin
    SP := Src.ScanLine[Y];
    DP := Dst.ScanLine[Y];
    for X := 0 to Src.Width - 1 do
    begin
      L := 0.114 * SP[X].B + 0.587 * SP[X].G + 0.299 * SP[X].R;
      U := -0.1686 * SP[X].R - 0.3311 * SP[X].G + 0.4997 * SP[X].B;
      V :=  0.4998 * SP[X].R - 0.4185 * SP[X].G - 0.0813 * SP[X].B;
      L := L * LNor + Min;
      R := Trunc(L + 1.4026 * V + 0.5);
      G := Trunc(L - 0.3444 * U - 0.7114 * V + 0.5);
      B := Trunc(L + 1.7330 * U + 0.5);
      if R > 255 then DP[X].R := 255 else if R < 0 then DP[X].R := 0
      else DP[X].R := R;
      if G > 255 then DP[X].G := 255 else if G < 0 then DP[X].G := 0
      else DP[X].G := G;
      if B > 255 then DP[X].B := 255 else if B < 0 then DP[X].B := 0
      else DP[X].B := B;
    end;
    PProc(100 * Y div (Src.Height - 1));
  end;
  Src.Assign(Dst);
  Dst.Free;
end;

procedure NormalizeFilter(Src: TBitmap; Min, Max: Integer; PProc: TProgressProc);
var
  X, Y: Integer;
  L, LMax, LMin: Integer;
  LNor: Extended;
  SP: PRGBArray;
begin
  if (Src = nil) or Src.Empty then Exit;
  ConvertToTrueColor(Src);
  if not Assigned(PProc) then PProc := NullProgressProc;

  PProc(0);
  Min := Min * 16;
  Max := Max * 16;
  LMax := -1;
  LMin := 256 shl 4;
  for Y := 0 to Src.Height - 1 do
  begin
    SP := Src.ScanLine[Y];
    for X := 0 to Src.Width - 1 do
    begin
      L := (306 * SP[X].R + 601 * SP[X].G + 117 * SP[X].B + 32) shr 6;
      if L > LMax then LMax := L;
      if L < LMin then LMin := L;
    end;
  end;
  if LMax = LMin then Exit;
  LNor := (Max - Min) / (LMax - LMin);
  for X := 0 to 4080 do LumaMap[X] := Trunc((X - LMin) * LNor + Min + 0.5);
  LumaMapFilter(Src, PProc);
end;

procedure GrayscaleFilter(Src: TBitmap; Method: Integer; PProc: TProgressProc);
const
  PF = 16;
  PV = 1 shl PF;
  PH = 1 shl (PF - 1);
  R601: Cardinal = Trunc(0.299 * PV);
  G601: Cardinal = Trunc(0.587 * PV);
  B601: Cardinal = Trunc(0.114 * PV);
  R709: Cardinal = Trunc(0.2125 * PV);
  G709: Cardinal = Trunc(0.7154 * PV);
  B709: Cardinal = Trunc(0.0721 * PV);
var
  Dst: TBitmap;
  X, Y: Integer;
  SP: PRGBArray;
  DP: PByteArray;
  LogPalette: TMaxLogPalette;
begin
  if (Src = nil) or Src.Empty then Exit;
  ConvertToTrueColor(Src);
  if not Assigned(PProc) then PProc := NullProgressProc;

  PProc(0);
  Dst := TBitmap.Create;
  Dst.PixelFormat := pf8bit;
  Dst.Width := Src.Width;
  Dst.Height := Src.Height;
  LogPalette.palVersion := $0300;
  LogPalette.palNumEntries := 256;
  for X := 0 to 255 do
  begin
    LogPalette.palPalEntry[X].peRed   := X;
    LogPalette.palPalEntry[X].peGreen := X;
    LogPalette.palPalEntry[X].peBlue  := X;
    LogPalette.palPalEntry[X].peFlags := 0;
  end;
  Dst.Palette := CreatePalette(PLogPalette(@LogPalette)^);
  for Y := 0 to Src.Height - 1 do
  begin
    SP := Src.ScanLine[Y];
    DP := Dst.ScanLine[Y];
    case Method of
      1:
        for X := 0 to Src.Width - 1 do
        begin
          DP[X] := (B709 * SP[X].B + G709 * SP[X].G + R709 * SP[X].R + PH) shr PF;
        end;
      2:
        for X := 0 to Src.Width - 1 do
        begin
          DP[X] := SP[X].R;
        end;
    else
        for X := 0 to Src.Width - 1 do
        begin
          DP[X] := (B601 * SP[X].B + G601 * SP[X].G + R601 * SP[X].R + PH) shr PF;
        end;
    end;
    PProc(100 * Y div (Src.Height - 1));
  end;
  Src.Assign(Dst);
  Dst.Free;
end;

procedure TrimFilterImpl(Src: TBitmap; R: TRect; FillColor: TPixel; PProc: TProgressProc);
var
  Dst: TBitmap;
  SP, DP: PPixelArray;
  X, Y: Integer;
begin
  if (Src = nil) or Src.Empty then Exit;
  ConvertToTrueColor(Src);
  if not Assigned(PProc) then PProc := NullProgressProc;

  Dst := TBitmap.Create;
  Dst.PixelFormat := PixelBits;

  if R.Right < 0 then R.Right := Src.Width + R.Right;
  if R.Bottom < 0 then R.Bottom := Src.Height + R.Bottom;

  Dst.Width := R.Right - R.Left;
  Dst.Height := R.Bottom - R.Top;

  for Y := R.Top to R.Bottom - 1 do
  begin
    DP := Dst.ScanLine[Y - R.Top];
    if (Y < 0) or (Y > Src.Height - 1) then
    begin
      for X := R.Left to R.Right - 1 do
        DP[X - R.Left] := FillColor;
    end
    else
    begin
      SP := Src.ScanLine[Y];
      for X := R.Left to R.Right - 1 do
      begin
        if (X < 0) or (X > Src.Width - 1) then
        begin
          DP[X - R.Left] := FillColor;
        end
        else DP[X - R.Left] := SP[X];
      end;
    end;

    PProc((100 * Y) div (Dst.Height - 1));
  end;

  Src.Assign(Dst);
  Dst.Free;
end;

procedure TrimFilter(Src: TBitmap; R: TRect; FillColor: string; PProc: TProgressProc);
  function ParseRGB(S: string): TPixel;
  var
    I: Integer;
  begin
    FillChar(Result, SizeOf(Result), 0);
    S := LowerCase(S);
    if Length(S) <> 7 then Exit;
    if S[1] <> '#' then Exit;
    for I := 2 to 7 do
      if not CharInSet(S[I], ['0' .. '9', 'a' .. 'f']) then Exit;
    for I := 0 to 2 do
      Result[I] := StrToInt('$' + Copy(S, (3 - I) * 2, 2))
  end;

begin
  TrimFilterImpl(Src, R, ParseRGB(FillColor), PProc);
end;

type
  TLookupCacheElement = record
    Color: TRGBQuad;
    Index: Byte;
  end;
const
  LookupCacheBits = 6;
  LookupCacheValue = (1 shl LookupCacheBits);
var
  LookupCache: array[0..(1 shl (LookupCacheBits * 3)) - 1] of TLookupCacheElement;

procedure IndexedFilter(Src: TBitmap; var Grayscale: Boolean; PProc: TProgressProc);

  function CreateLogPalette(Src: TBitmap; var LogPalette: TMaxLogPalette): Boolean;
    function MarkBitmap(Src: TBitmap; Map: PByteArray; var Grayscale: Boolean): Boolean;
    var
      ColorCount: Integer;
      X, Y: Integer;
      SP: PRGBArray;
      I, J: Integer;
    begin
      ColorCount := 0;
      Grayscale := True;
      for Y := 0 to Src.Height - 1 do
      begin
        SP := Src.ScanLine[Y];
        for X := 0 to Src.Width - 1 do
        begin
          I := (SP[X].B shl 13) + (SP[X].G shl 5) + (SP[X].R shr 3);
          J := SP[X].R and 7;
          if (Map[I] and (1 shl J)) = 0 then
          begin
            Inc(ColorCount);
            if ColorCount > 256 then
            begin
              Grayscale := False;
              Result := False;
              Exit;
            end;
            Map[I] := Map[I] or (1 shl J);
            Grayscale := Grayscale and (SP[X].B = SP[X].G) and (SP[X].B = SP[X].R) and (SP[X].G = SP[X].R);
          end;
        end;
      end;
      Result := True;
    end;

    procedure InitializePalette(var LogPalette: TMaxLogPalette);
    begin
      LogPalette.palVersion := $0300;
      LogPalette.palNumEntries := 256;
      FillChar(LogPalette.palPalEntry[0], SizeOf(LogPalette.palPalEntry[0]) * 256, 0);
    end;

    procedure CreateGrayscalPalette(var LogPalette: TMaxLogPalette);
    var
      I: Integer;
    begin
        for I := 0 to 255 do
        begin
          LogPalette.palPalEntry[I].peRed := I;
          LogPalette.palPalEntry[I].peGreen := I;
          LogPalette.palPalEntry[I].peBlue := I;
        end;
    end;

    procedure CreateColorPalette(var LogPalette: TMaxLogPalette; Map: PByteArray);
    var
      I, J, X: Integer;
    begin
      J := 0;
      for I := 0 to $200000 - 1 do
      begin
        if Map[I] = 0 then Continue;
        for X := 0 to 7 do
        begin
          if ((Map[I] shr X) and 1) = 1 then
          begin
            LogPalette.palPalEntry[J].peRed := ((I shl 3) or X) and 255;
            LogPalette.palPalEntry[J].peGreen := (I shr 5) and 255;
            LogPalette.palPalEntry[J].peBlue := (I shr 13) and 255;
            Inc(J);
          end;
        end;
      end;
    end;
  var
    Map: PByteArray;
  begin
    Map := AllocMem($200000);
    try
      Result := MarkBitmap(Src, Map, Grayscale);
      if not Result then Exit;

      InitializePalette(LogPalette);
      // グレースケールでは RGB(N, N, N) = N である必要がある
      // (グレースケール PNG にはパレットがない)
      if Grayscale then CreateGrayscalPalette(LogPalette)
      else CreateColorPalette(LogPalette, Map);
    finally
      FreeMem(Map);
    end;
  end;

  procedure Create8bitBitmap(Src: TBitmap; var LogPalette: TMaxLogPalette);
    function GetIndexNC(const C1: TRGB; const LogPalette: TMaxLogPalette): Byte;
    var
      I: Integer;
    begin
      I := 0;
      while (C1.B <> LogPalette.palPalEntry[I].peBlue) or
            (C1.G <> LogPalette.palPalEntry[I].peGreen) or
            (C1.R <> LogPalette.palPalEntry[I].peRed) do Inc(I);
      Result := I;
    end;

    function GetIndex(const C1: TRGB; const LogPalette: TMaxLogPalette): Byte; inline;
    var
      N: Integer;
    begin
      N := (C1.B and (LookupCacheValue - 1)) + (C1.G and (LookupCacheValue - 1)) shl LookupCacheBits + (C1.R and (LookupCacheValue - 1)) shl (LookupCacheBits * 2);
      if (LookupCache[N].Color.A <> $FF) and (LookupCache[N].Color.B = C1.B) and (LookupCache[N].Color.G = C1.G) and (LookupCache[N].Color.R = C1.R) then
      begin
        Result := LookupCache[N].Index;
        Exit;
      end;
      Result := GetIndexNC(C1, LogPalette);
      LookupCache[N].Color.B := C1.B;
      LookupCache[N].Color.G := C1.G;
      LookupCache[N].Color.R := C1.R;
      LookupCache[N].Color.A := 0; // A = $FF is invalid
      LookupCache[N].Index := Result;
    end;
  var
    X, Y: Integer;
    SP: PRGBArray;
    DP: PByteArray;
    Dst: TBitmap;
  begin
    Dst := TBitmap.Create;
    try
      Dst.PixelFormat := pf8bit;
      Dst.Width := Src.Width;
      Dst.Height := Src.Height;
      Dst.Palette := CreatePalette(PLogPalette(@LogPalette)^);
      FillChar(LookupCache, SizeOf(LookupCache), $FF);
      for Y := 0 to Src.Height - 1 do
      begin
        SP := Src.ScanLine[Y];
        DP := Dst.ScanLine[Y];
        for X := 0 to Src.Width - 1 do
        begin
          DP[X] := GetIndex(SP[X], LogPalette);
        end;
      end;
      Src.Assign(Dst);
    finally
      Dst.Free;
    end;
  end;

var
  LogPalette: TMaxLogPalette;
begin
  if (Src = nil) or Src.Empty then Exit;
  ConvertToTrueColor(Src);
  if not Assigned(PProc) then PProc := NullProgressProc;

  PProc(0);
  if not CreateLogPalette(Src, LogPalette) then Exit;
  Create8bitBitmap(Src, LogPalette);
end;

function SplineInterpolate(T: Double; N: Integer; X, Y, Z: PDoubleArray): Double;
var
  I, J, K: Integer;
  D, H: Double;
begin
  I := 0;
  J := N - 1;

  while I < J do
  begin
    K := (I + J) div 2;
    if X[K] < T then I := K + 1 else J := K;
  end;
  if I > 0 then I := I - 1;
  H := X[I +1] - X[I];
  D := T - X[I];

  Result := (((Z[I + 1] - Z[I]) * D / H + Z[i] * 3) * D
            + ((Y[I + 1] - y[I]) / H
            - (Z[I] * 2 + Z[I + 1]) * H)) * D + Y[I];
end;

procedure CalculateSplineTable(N: Integer; X, Y, Z: PDoubleArray);
var
  I: Integer;
  T: Double;
  H, D: PDoubleArray;
begin
  H := AllocMem(SizeOf(Double) * N);
  D := AllocMem(SizeOf(Double) * N);
  Z[0] := 0;
  Z[N - 1] := 0;
  for I := 0 to N - 2 do
  begin
    H[I] := X[I + 1] - X[I];
    D[I + 1] := (Y[I + 1] - Y[I]) / H[I];
  end;
  Z[1] := D[2] - D[1] - H[0] * Z[0];
  D[1] := 2 * (X[2] - X[0]);
  for I := 1 to N - 3 do
  begin
    T := H[I] / D[I];
    Z[I + 1] := D[I + 2] - D[I + 1] - Z[I] * T;
    D[I + 1] := 2 * (X[I + 2] - X[I]) - H[I] * T;
  end;
  Z[N - 2] := Z[N - 2] - H[N - 2] * Z[N - 1];
  for I := N - 2 downto 1 do
  begin
    Z[I] := (Z[I] - H[I] * Z[I + 1]) / D[I];
  end;
  FreeMem(D);
  FreeMem(H);
end;

procedure LMapFilter(Src: TBitmap; VList: string; PProc: TProgressProc);
  procedure LMapCalc(VList: string);
  var
    N, I, J: Integer;
    X, Y, Z: PDoubleArray;
    S: string;
    StringList: TStringList;
  begin
    StringList := TStringList.Create;
    StringList.Text := StringReplace(VList, ',', #13#10, [rfReplaceAll]);

    X := AllocMem(SizeOf(Double) * StringList.Count);
    Y := AllocMem(SizeOf(Double) * StringList.Count);
    Z := AllocMem(SizeOf(Double) * StringList.Count);

    N := 0;
    for I := 0 to 255 do
    begin
      S := StringList.Values[IntToStr(I)];
      if S <> '' then
      begin
        X[N] := I;
        Y[N] := StrToInt(S);
        N := N + 1;
      end;
    end;
    CalculateSplineTable(N, X, Y, Z);

    for I := 0 to 4080 do
    begin
      J := Trunc(SplineInterpolate(I / 16, N, X, Y, Z) * 16 + 0.5);
      if J < 0 then J := 0 else if J > 4080 then J := 4080;
      LumaMap[I] := J;
    end;

    FreeMem(Z);
    FreeMem(Y);
    FreeMem(X);

    StringList.Free;
  end;
begin
  if (Src = nil) or Src.Empty then Exit;
  ConvertToTrueColor(Src);
  if not Assigned(PProc) then PProc := NullProgressProc;

  PProc(0);
  LMapCalc(VList);
  LumaMapFilter(Src, PProc);
end;

procedure WhiteFilter(Src: TBitmap; Threshold: Integer; PProc: TProgressProc);
var
  Dst: TBitmap;
  X, Y: Integer;
  L: Extended;
  SP, DP: PRGBArray;
begin
  if (Src = nil) or Src.Empty then Exit;
  ConvertToTrueColor(Src);
  if not Assigned(PProc) then PProc := NullProgressProc;

  PProc(0);
  Dst := TBitmap.Create;
  Dst.Assign(Src);
  for Y := 0 to Src.Height - 1 do
  begin
    SP := Src.ScanLine[Y];
    DP := Dst.ScanLine[Y];
    for X := 0 to Src.Width - 1 do
    begin
      L := 0.114 * SP[X].B + 0.587 * SP[X].G + 0.299 * SP[X].R;
      if L >= Threshold then
      begin
        DP[X].B := 255;
        DP[X].G := 255;
        DP[X].R := 255;
      end
      else DP[X] := SP[X];
    end;
    PProc(100 * Y div (Src.Height - 1));
  end;
  Src.Assign(Dst);
  Dst.Free;
end;

type
  TFP = Double;
const
  LUT2Size = 4096;
var
  LUT1: array[0..255] of TFP;
  LUT2: array[0..(LUT2Size - 1)] of Byte;

procedure ConvertFromAdobeRGB(Src: TBitmap);
  procedure PrepareAdobeRGBTosRGB();
  var
    I: Integer;
    T: TFP;
  begin
    for I := 0 to 255 do
      LUT1[I] := Power(I / 255, 2.19921875);
    for I := 0 to (LUT2Size - 1) do
    begin
      T := I / (LUT2Size - 1);
      if T <= 0.00304 then LUT2[I] := Trunc(T * 12.92 * 255 + 0.5)
      else LUT2[I] := Trunc((1.055 * Power(T, 1 / 2.4) - 0.055) * 255 + 0.5);
    end;
  end;

  function AdobeRGBTosRGB(C: TPixel): TPixel; inline;
    function Clamp(C: TFP): Integer; inline;
    begin
      if C < 0 then Result := 0
      else if C > 1 then Result := (LUT2Size - 1)
      else Result := Trunc(C * (LUT2Size - 1) + 0.5);
    end;
  var
    I: Integer;
    T1, T2: array[0..2] of TFP;
  begin
    //To Linear AdobeRGB
    for I := 0 to 2 do T1[I] := LUT1[C[I]];

    //To Linear sRGB
    T2[2] :=  1.398379796 * T1[2] - 0.398349338 * T1[1] + 0.000020460 * T1[0];
    T2[1] :=  0.000025724 * T1[2] + 1.000023312 * T1[1] + 0.000051268 * T1[0];
    T2[0] := -0.000023798 * T1[2] - 0.042944974 * T1[1] + 1.042952808 * T1[0];

    //To sRGB
    for I := 0 to 2 do
      Result[I] := LUT2[Clamp(T2[I])];
  end;

var
  P: PPixelArray;
  X, Y: Integer;
begin
  if (Src = nil) or Src.Empty then Exit;
  ConvertToTrueColor(Src);

  PrepareAdobeRGBTosRGB();
  for Y := 0 to Src.Height - 1 do
  begin
    P := Src.ScanLine[Y];
    for X := 0 to Src.Width - 1 do P[X] := AdobeRGBTosRGB(P[X]);
  end;
end;

procedure Convert8BitTo4Bit(Src: TBitmap; PProc: TProgressProc);
var
  Dst: TBitmap;
  X, Y: Integer;
  SP, DP: PByteArray;
begin
  if (Src = nil) or Src.Empty or (Src.PixelFormat <> pf8bit) then Exit;
  if not Assigned(PProc) then PProc := NullProgressProc;

  PProc(0);
  Dst := TBitmap.Create;
  Dst.Assign(Src);
  Dst.PixelFormat := pf4bit;
  Dst.Palette := Src.Palette;
  for Y := 0 to Src.Height - 1 do
  begin
    SP := Src.ScanLine[Y];
    DP := Dst.ScanLine[Y];
    for X := 0 to Src.Width - 1 do
    begin
      if (X mod 2) = 0 then DP[X div 2] := (SP[X] shl 4) + (DP[X div 2] and $F)
      else DP[X div 2] := (DP[X div 2] and $F0) + SP[X];
    end;
    PProc(100 * Y div (Src.Height - 1));
  end;
  Src.Assign(Dst);
  Dst.Free;
end;

end.

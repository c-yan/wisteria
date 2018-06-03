unit pstretchf;

interface

uses
  Winapi.Windows, System.SysUtils, Vcl.Graphics, System.Math, ParallelUtils,
  ImageTypes, ImageFunctions;

  procedure Stretch(Src: TBitmap; Width, Height, Method: Integer; PProc: TProgressProc);
  procedure SetLinearizeOnReduce(Value: Integer);

implementation

type
  TStretchProc = procedure(Src, Dst: TBitmap; PProc: TProgressProc);

const
  SBITS = 21;
  SVAL = 1 shl SBITS;
  SHVAL = 1 shl (SBITS - 1);
  GCLUT_SIZE = 4096;

var
  LinearizeOnResuce: Integer;
  Offset: Integer;

procedure SetLinearizeOnReduce(Value: Integer);
begin
  LinearizeOnResuce := Value;
end;

procedure SetOffset(Value: Integer);
begin
  Offset := Value;
end;

procedure NullProgressProc(Progress: Integer);
begin
end;

function CalcSrcX(DstX: Integer; Src, Dst: TBitmap): Double; inline;
begin
  Result := (DstX + 0.5) * Src.Width / Dst.Width - 0.5;
end;

procedure Transpose(Src, Dst: TBitmap; PProc: TProgressProc);
var
  X, Y: Integer;
  DP: PPixelArray;
  SPA: array of PPixelArray;
begin
  SetLength(SPA, Src.Height);
  for Y := 0 to Src.Height - 1 do SPA[Y] := Src.ScanLine[Y];
  for Y := 0 to Dst.Height - 1 do
  begin
    DP := Dst.ScanLine[Y];
    for X := 0 to Dst.Width - 1 do DP[X] := SPA[X][Y];
  end;
end;

procedure MNP(Src, Dst: TBitmap; PProc: TProgressProc);
var
  X, Y: Integer;
  SP, DP: PPixelArray;
begin
  PProc(Offset);
  for Y := 0 to Dst.Height - 1 do
  begin
    SP := Src.ScanLine[Y];
    DP := Dst.ScanLine[Y];
    for X := 0 to Dst.Width - 1 do DP[X] := SP[Trunc(CalcSrcX(X, Src, Dst) + 0.5)];
    PProc(Trunc(Offset + (100 * Y) / ((Dst.Height - 1) * 2) + 0.5));
  end;
end;

procedure BLI(Src, Dst: TBitmap; PProc: TProgressProc);
var
  X, Y, I: Integer;
  LB, RB: Integer;
  BX, DX: Integer;
  BXT, DXT: array of Integer;
  SP, DP: PPixelArray;
  T: Double;
begin
  PProc(Offset);
  LB := -1;
  for X := -1 to Dst.Width -1 do
  begin
    if CalcSrcX(X, Src, Dst) >= 0 then
    begin
      LB := X;
      Break;
    end;
  end;
  RB := -1;
  for X := -1 to Dst.Width - 1 do
  begin
    if CalcSrcX(X, Src, Dst) >= Src.Width - 1 then
    begin
      RB := X;
      Break;
    end;
  end;
  SetLength(BXT, Dst.Width);
  SetLength(DXT, Dst.Width);
  for X := 0 to Dst.Width - 1 do
  begin
    T := CalcSrcX(X, Src, Dst);
    BXT[X] := Trunc(T);
    DXT[X] := Trunc((T - BXT[X]) * SVAL);
  end;
  for Y := 0 to Dst.Height - 1 do
  begin
    SP := Src.ScanLine[Y];
    DP := Dst.ScanLine[Y];
    for X := 0 to LB -1 do DP[X] := SP[0];
    for X := LB to RB -1 do
    begin
      BX := BXT[X];
      DX := DXT[X];
      for I := 0 to 2 do
      begin
        DP[X][I] := ((SP[BX][I] shl SBITS) + ((SP[BX + 1][I] - SP[BX][I]) * DX + SHVAL)) shr SBITS;
      end;
    end;
    for X := RB to Dst.Width -1 do DP[X] := SP[Src.Width - 1];
    PProc(Trunc(Offset + (100 * Y) / ((Dst.Height - 1) * 2) + 0.5));
  end;
end;

function Linearize(C: Integer): Double; inline;
var
  V: Double;
begin
  V := C / 255.0;
  if V <= 0.04045 then Result := V / 12.92
  else Result := Power((V + 0.055) / 1.055, 2.4);
end;

function GammaCorrect(V: Double): Integer; inline;
begin
  V := Clamp(V, 0, 1);
  if V <= 0.0031308 then Result := Trunc(V * 12.92 * 255.0 + 0.5)
  else Result := Trunc((1.055 * Power(V, 1.0 / 2.4) - 0.055) * 255.0 + 0.5);
end;

procedure PA1(Src, Dst: TBitmap; PProc: TProgressProc);
var
  RVAL: Double;
  TT: array of Integer;
  FT: array of Double;
  X, I: Integer;
  T: Double;
  LinearizeLUT: array[0..255] of Double;
  GammaCorrectLUT: array[0..GCLUT_SIZE - 1] of Integer;
begin
  PProc(Offset);
  RVAL := Dst.Width / Src.Width;
  SetLength(FT, Dst.Width + 1);
  SetLength(TT, Dst.Width + 1);
  for X := 0 to Dst.Width do
  begin
    T := Src.Width * X / Dst.Width;
    TT[X] := Trunc(T);
    FT[X] := T - TT[X];
  end;
  for I := 0 to 255 do LinearizeLUT[I] := Linearize(I);
  for I := 0 to GCLUT_SIZE - 1 do GammaCorrectLUT[I] := GammaCorrect(I / (GCLUT_SIZE - 1));
  ParallelFor(0, Dst.Height - 1,
    procedure (Start, Stop: Integer)
    var
      X, Y, I, J: Integer;
      SP, DP: PPixelArray;
      LT, RT: Integer;
      LF, RF: Double;
      V: Double;
    begin
      for Y := Start to Stop do
      begin
        SP := Src.ScanLine[Y];
        DP := Dst.ScanLine[Y];
        for X := 0 to Dst.Width - 1 do
        begin
          LT := TT[X];
          RT := TT[X + 1];
          LF := 1 - FT[X];
          RF := FT[X + 1];
          for I := 0 to 2 do
          begin
            V := 0;
            for J := LT + 1 to RT - 1 do V := V + LinearizeLUT[SP[J][I]];
            V := V + LinearizeLUT[SP[LT][I]] * LF;
            if RF <> 0 then V := V + LinearizeLUT[SP[RT][I]] * RF;
            DP[X][I] := GammaCorrectLUT[Trunc(V * RVAL * (GCLUT_SIZE - 1) + 0.5)];
          end;
        end;
        PProc(Trunc(Offset + (100 * (Y - Start)) / ((Stop - Start) * 2) + 0.5));
      end;
    end);
end;

procedure PA2(Src, Dst: TBitmap; PProc: TProgressProc);
var
  RVAL: Integer;
  FT, TT: array of Integer;
  X: Integer;
  T: Double;
begin
  PProc(Offset);
  RVAL := Trunc((SVAL * 1.0) * Dst.Width / Src.Width);
  SetLength(FT, Dst.Width + 1);
  SetLength(TT, Dst.Width + 1);
  for X := 0 to Dst.Width do
  begin
    T := Src.Width * X / Dst.Width;
    TT[X] := Trunc(T);
    FT[X] := Trunc((T - TT[X]) * RVAL);
  end;
  ParallelFor(0, Dst.Height - 1,
    procedure (Start, Stop: Integer)
    var
      X, Y, I, J: Integer;
      SP, DP: PPixelArray;
      LT, RT, LF, RF: Integer;
      V: Integer;
    begin
      for Y := Start to Stop do
      begin
        SP := Src.ScanLine[Y];
        DP := Dst.ScanLine[Y];
        for X := 0 to Dst.Width - 1 do
        begin
          LT := TT[X];
          RT := TT[X + 1];
          LF := RVAL - FT[X];
          RF := FT[X + 1];
          for I := 0 to 2 do
          begin
            V := 0;
            for J := LT + 1 to RT - 1 do Inc(V, SP[J][I]);
            V := V * RVAL;
            Inc(V, SP[LT][I] * LF);
            if RF <> 0 then Inc(V, SP[RT][I] * RF);
            DP[x][i] := (V + SHVAL) shr SBITS;
          end;
        end;
        PProc(Trunc(Offset + (100 * (Y - Start)) / ((Stop - Start) * 2) + 0.5));
      end;
    end);
end;

procedure PA(Src, Dst: TBitmap; PProc: TProgressProc);
begin
  if LinearizeOnResuce = 1 then PA1(Src, Dst, PProc)
  else PA2(Src, Dst, PProc)
end;

function Sinc(X: Double): Double; inline;
begin
  Result := Sin(PI * X) / (PI * X);
end;

function Lanczos(X: Double; WSize: Integer): Double; inline;
begin
  if (X <= -WSize) or (X >= WSize) then
    Result := 0.0
  else if X = 0.0 then
    Result := 1.0
  else
    Result := Sinc(X) * Sinc(X / WSize);
end;

procedure LanczosResize1(Src, Dst: TBitmap; PProc: TProgressProc; WSize: Integer);
var
  SPT, DPT: array of PPixelArray;
  I, Y: Integer;
  LinearizeLUT: array[0..255] of Double;
  GammaCorrectLUT: array[0..GCLUT_SIZE - 1] of Integer;
  Size: Integer;
begin
  PProc(Offset);
  SetLength(SPT, Src.Height);
  SetLength(DPT, Dst.Height);
  for Y := 0 to Src.Height - 1 do
  begin
    SPT[Y] := Src.ScanLine[Y];
    DPT[Y] := Dst.ScanLine[Y];
  end;
  for I := 0 to 255 do LinearizeLUT[I] := Linearize(I);
  for I := 0 to GCLUT_SIZE - 1 do GammaCorrectLUT[I] := GammaCorrect(I / (GCLUT_SIZE - 1));
  Size := Ceil(2.0 * WSize * Src.Width / Dst.Width) + 3;

  ParallelFor(0, Dst.Width - 1,
    procedure (Start, Stop: Integer)
    var
      SP, DP: PPixelArray;
      X, Y, I, J: Integer;
      MX: Double;
      L, R: Integer;
      Z: Double;
      T: Double;
      LT: array of Double;
    begin
      SetLength(LT, Size);
      for X := Start to Stop do
      begin
        MX := CalcSrcX(X, Src, Dst);
        L := Ceil(CalcSrcX(X - WSize, Src, Dst));
        R := Floor(CalcSrcX(X + WSize, Src, Dst));
        Z := 0;
        for J := L to R do Z := Z + Lanczos((J - MX) / Src.Width * Dst.Width, WSize);
        Z := 1 / Z;
        for J := L to R do LT[J - L] := Lanczos((J - MX) / Src.Width * Dst.Width, WSize) * Z;

        if (L < 0) or (R > Src.Width - 1) then
        begin
          for Y := 0 to Dst.Height - 1 do
          begin
            SP := SPT[Y];
            DP := DPT[Y];
            for I := 0 to 2 do
            begin
              T := 0;
              for J := L to R do
                if J < 0 then
                  T := T + LinearizeLUT[SP[0][I]] * LT[J - L]
                else if J > Src.Width - 1 then
                  T := T + LinearizeLUT[SP[Src.Width - 1][I]] * LT[J - L]
                else
                  T := T + LinearizeLUT[SP[J][I]] * LT[J - L];
              DP[X][I] := GammaCorrectLUT[Clamp(Trunc(t * (GCLUT_SIZE - 1) + 0.5), 0, GCLUT_SIZE - 1)];
            end;
          end;
        end
        else
        begin
          for Y := 0 to Dst.Height - 1 do
          begin
            SP := SPT[Y];
            DP := DPT[Y];
            for I := 0 to 2 do
            begin
              T := 0;
              for J := L to R do T := T + LinearizeLUT[SP[J][I]] * LT[J - L];
              DP[X][I] := GammaCorrectLUT[Clamp(Trunc(T * (GCLUT_SIZE - 1) + 0.5), 0, GCLUT_SIZE - 1)];
            end;
          end;
        end;
        PProc(Trunc(Offset + (100 * (X - Start)) / ((Stop - Start) * 2) + 0.5));
      end;
    end);
end;

procedure LanczosResize2(Src, Dst: TBitmap; PProc: TProgressProc; WSize: Integer);
var
  SPT, DPT: array of PPixelArray;
  Enlarge: Boolean;
  Y: Integer;
  Size: Integer;
begin
  PProc(Offset);
  Enlarge := Dst.Width > Src.Width;
  SetLength(SPT, Src.Height);
  SetLength(DPT, Dst.Height);
  for Y := 0 to Src.Height - 1 do
  begin
    SPT[Y] := Src.ScanLine[Y];
    DPT[Y] := Dst.ScanLine[Y];
  end;
  if Enlarge then
    Size := WSize * 2 + 3
  else
    Size := Ceil(2.0 * WSize * Src.Width / Dst.Width) + 3;

  ParallelFor(0, Dst.Width - 1,
    procedure (Start, Stop: Integer)
    var
      SP, DP: PPixelArray;
      X, Y, I, J: Integer;
      LT: array of Integer;
      MX: Double;
      L, R: Integer;
      Z: Double;
      T: Integer;
    begin
      SetLength(LT, Size);
      for X := Start to Stop do
      begin
        MX := CalcSrcX(X, Src, Dst);
        if Enlarge then
        begin
          L := Ceil(MX) - Wsize;
          R := Floor(MX) + Wsize;
        end
        else
        begin
          L := Ceil(CalcSrcX(X - WSize, Src, Dst));
          R := Floor(CalcSrcX(X + WSize, Src, Dst));
        end;
        Z := 0;
        if enlarge then
          for J := L to R do Z := Z + Lanczos(J - MX, WSize)
        else
          for J := L to R do Z := Z + Lanczos((J - MX) / Src.Width * Dst.Width, WSize);
        Z := 1 / Z;
        if Enlarge then
          for J := L to R do LT[J - L] := Floor(Lanczos(J - MX, WSize) * Z * SVAL + 0.5)
        else
          for J := L to R do LT[J - L] := Floor(lanczos((J - MX) / Src.Width * Dst.Width, WSize) * Z * SVAL + 0.5);
        if (L < 0) or (R > Src.Width - 1) then
        begin
          for Y := 0 to Dst.Height - 1 do
          begin
            SP := SPT[Y];
            DP := DPT[Y];
            for I := 0 to 2 do
            begin
              T := 0;
              for J := L to R do
                if J < 0 then
                  T := T + SP[0][I] * LT[J - L]
                else if J > Src.Width - 1 then
                  T := T + SP[Src.Width - 1][I] * LT[J - L]
                else
                  T := T + SP[J][I] * LT[J - L];
              DP[X][I] := Clamp(T + SHVAL, 0, SVAL * 255) shr SBITS;
            end;
          end;
        end
        else
        begin
          for Y := 0 to Dst.Height - 1 do
          begin
            SP := SPT[Y];
            DP := DPT[Y];
            for I := 0 to 2 do
            begin
              T := 0;
              for J := L to R do T := T + SP[J][I] * LT[J - L];
              DP[X][I] := Clamp(T + SHVAL, 0, SVAL * 255) shr SBITS;
            end;
          end;
        end;
        PProc(Trunc(Offset + (100 * (X - Start)) / ((Stop - Start) * 2) + 0.5));
      end;
    end);
end;

procedure LanczosResize(Src, Dst: TBitmap; PProc: TProgressProc; WSize: Integer);
begin
  if (Dst.Width < Src.Width) and (LinearizeOnResuce = 1) then
    LanczosResize1(Src, Dst, PProc, WSize)
  else
    LanczosResize2(Src, Dst, PProc, WSize);
end;

procedure Lanczos2(Src, Dst: TBitmap; PProc: TProgressProc);
begin
  LanczosResize(Src, Dst, PProc, 2);
end;

procedure Lanczos3(Src, Dst: TBitmap; PProc: TProgressProc);
begin
  LanczosResize(Src, Dst, PProc, 3);
end;

procedure Lanczos4(Src, Dst: TBitmap; PProc: TProgressProc);
begin
  LanczosResize(Src, Dst, PProc, 4);
end;

procedure Stretch(Src: TBitmap; Width, Height, Method: Integer; PProc: TProgressProc);
var
  Enlarge, Reduce: TStretchProc;

  procedure SetEnlargeProc(Method: Integer);
  begin
    case Method of
      1: Enlarge := MNP;
      2: Enlarge := BLI;
      3: Enlarge := Lanczos2;
      4: Enlarge := Lanczos3;
      5: Enlarge := Lanczos4;
      else Enlarge := Lanczos3;
    end;
  end;

  procedure SetReduceProc(Method: Integer);
  begin
    case Method of
      1: Reduce := MNP;
      2: Reduce := PA;
      3: Reduce := Lanczos2;
      4: Reduce := Lanczos3;
      5: Reduce := Lanczos4;
      else Reduce := Lanczos3;
    end;
  end;
var
  Dst: TBitmap;
begin
  if (Src = nil) or Src.Empty then Exit;
  Src.PixelFormat := PixelBits;
  if Src.Palette <> 0 then DeleteObject(Src.ReleasePalette);
  if not Assigned(PProc) then PProc := NullProgressProc;
  SetEnlargeProc(Method and $F);
  SetReduceProc((Method shr 4) and $F);
  Dst := TBitmap.Create;
  try
    Dst.PixelFormat := PixelBits;
    Dst.Width := Width;
    Dst.Height := Src.Height;
    SetOffset(0);
    if Width > Src.Width then Enlarge(Src, Dst, PProc)
    else Reduce(Src, Dst, PProc);
    Src.Assign(Dst);
    Dst.Free;

    Dst := TBitmap.Create;
    Dst.PixelFormat := PixelBits;
    Dst.Width := Src.Height;
    Dst.Height := Src.Width;
    Transpose(Src, Dst, PProc);
    Src.Assign(Dst);
    Dst.Free;

    Dst := TBitmap.Create;
    Dst.PixelFormat := PixelBits;
    Dst.Width := Height;
    Dst.Height := Width;
    SetOffset(50);
    if Height > Src.Width then Enlarge(Src, Dst, PProc)
    else Reduce(Src, Dst, PProc);
    Src.Assign(Dst);
    Dst.Free;

    Dst := TBitmap.Create;
    Dst.PixelFormat := PixelBits;
    Dst.Width := Width;
    Dst.Height := Height;
    Transpose(Src, Dst, PProc);
    Src.Assign(Dst);
  finally
    Dst.Free;
  end;
end;

initialization
  SetLinearizeOnReduce(1);

end.

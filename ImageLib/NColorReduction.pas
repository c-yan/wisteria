unit NColorReduction;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, Vcl.Forms, Vcl.Graphics,
  System.Math, Winapi.MMSystem, ImageTypes, ImageFunctions;

procedure ReduceColor(const Src: TBitmap; Colors: Integer; Dither: Boolean);

implementation

function CompareInteger(Item1, Item2: Pointer): Integer;
begin
  Result := Integer(Item1) - Integer(Item2);
end;

procedure ReduceColor(const Src: TBitmap; Colors: Integer; Dither: Boolean);
  type
    TWordQuad = packed array[0..3] of Word;

    TColorInfo = record
      Min, Max: Integer;
      Mid, Err: Double;
    end;

    TColorCube = record
      C: array[0..2] of TColorInfo;
      Err: Double;
    end;
    PColorCube = ^TColorCube;

    TColorHistogram = array[0..255, 0..255, 0..255] of Integer;
    PColorHistogram = ^TColorHistogram;

    TIntegerTriple = packed array[0..2] of Integer;
    TIntegerTripleArray = array[0..0] of TIntegerTriple;
    PIntegerTripleArray = ^TIntegerTripleArray;
    TPalette = array of TByteQuad;
    TPaletteIndexList = array of Cardinal;

    THistogramElement = record
      Color: TByteQuad;
      Count: Cardinal;
      Cache: array[0..2] of Double;
    end;

    TLookupCacheElement = record
      Color: TByteQuad;
      Index: Integer;
    end;

  const
    //ErrCoeff: array[0..2] of Double = (0.0722, 0.7152, 0.2126); // YPbPr
    //ErrCoeff: array[0..2] of Double = (0.11448, 0.58661, 0.29891); // YCbCr
    //ErrCoeff: array[0..2] of Double = (1.0, 1.0, 1.0);
    //ErrCoeff: array[0..2] of Double = (0.09157, 0.65733, 0.25110);
    //ErrCoeff: array[0..2] of Integer = (Trunc(0.09157 * 1024), Trunc(0.65733 * 1024), Trunc(0.25110 * 1024));
    //ErrCoeff: array[0..2] of Integer = (Trunc(0.058326 * 1024), Trunc(0.794646 * 1024), Trunc(0.147028 * 1024));
    ErrCoeff: array[0..2] of Integer = (Trunc(0.10529194976417361844239546296359 * 1024), Trunc(0.70389005930975282839063698587813 * 1024), Trunc(0.19081799092607355316696755115828 * 1024));

    BlockSideSizeBits = 4;
    BlockSideSize = 1 shl BlockSideSizeBits;
    BlockSideCount = (256 div BlockSideSize);
    LookupCacheBits = 6;
    LookupCacheValue = (1 shl LookupCacheBits);

  var
    CandidateList: array[0..BlockSideCount - 1, 0..BlockSideCount - 1, 0..BlockSideCount -1] of TPaletteIndexList;
    LookupCache: array[0..(1 shl (LookupCacheBits * 3)) - 1] of TLookupCacheElement;

  function MakeHistogram(const Histogram: PColorHistogram): Integer;
  var
    SP: PByteQuadArray;
    X, Y: Integer;
  begin
    Result := 0;
    for Y := 0 to Src.Height - 1 do
    begin
      SP := Src.Scanline[Y];
      for X := 0 to Src.Width - 1 do
      begin
        if Histogram[SP[X][0], SP[X][1], SP[X][2]] = 0 then Inc(Result);
        Inc(Histogram[SP[X][0], SP[X][1], SP[X][2]]);
      end;
    end;
  end;

  procedure CalcError(const NewCube: PColorCube; const Histogram: PColorHistogram);
    type
      TLocalHistogram = array[0..2, 0..255] of Integer;
    procedure CutVoidCube(const Cube: PColorCube; const LocalHistogram: TLocalHistogram);
    var
      I, X: Integer;
    begin
      for X := 0 to 2 do
      begin
        for I := Cube.C[X].Min to Cube.C[X].Max do
        begin
          if LocalHistogram[X][I] <> 0 then
          begin
            if I > Cube.C[X].Min then Cube.C[X].Min := I;
            Break;
          end;
        end;

        for I := Cube.C[X].Max downto Cube.C[X].Min do
        begin
          if LocalHistogram[X][I] <> 0 then
          begin
            if I < Cube.C[X].Max then Cube.C[X].Max := I;
            Break;
          end;
        end;
      end
    end;
  var
    Mid, Err: Double;
    X, Y, Z, Sum, IErr, I: Integer;
    LocalHistogram: TLocalHistogram;
  begin
    FillChar(LocalHistogram, SizeOf(LocalHistogram), 0);

    for X := NewCube.C[0].Min to NewCube.C[0].Max do
    begin
      for Y := NewCube.C[1].Min to NewCube.C[1].Max do
      begin
        for Z := NewCube.C[2].Min to NewCube.C[2].Max do
        begin
          I := Histogram[X, Y, Z];
          Inc(LocalHistogram[0][X], I);
          Inc(LocalHistogram[1][Y], I);
          Inc(LocalHistogram[2][Z], I);
        end;
      end;
    end;

    CutVoidCube(NewCube, LocalHistogram);

    for X := 0 to 2 do
    begin
      Sum := 0;
      IErr := 0;
      for I := NewCube.C[X].Min to NewCube.C[X].Max do
      begin
        Inc(Sum, LocalHistogram[X][I]);
        Inc(IErr, I * LocalHistogram[X][I]);
      end;
      if IErr <> 0 then Mid := IErr / Sum else Mid := 0;
      Err := 0;
      for I := NewCube.C[X].Min to NewCube.C[X].Max do
      begin
        Err := Err + (I - Mid) * (I - Mid) * LocalHistogram[X][I];
      end;
      NewCube.C[X].Mid := Mid;
      NewCube.C[X].Err := Err * ErrCoeff[X];
    end;
    NewCube.Err := Max(NewCube.C[0].Err, Max(NewCube.C[1].Err, NewCube.C[2].Err));
  end;

  procedure InvalidateCandidate;
  var
    X, Y, Z: Integer;
  begin
    for X := 0 to BlockSideCount - 1 do
      for Y := 0 to BlockSideCount - 1 do
        for Z := 0 to BlockSideCount - 1 do
        begin
          if CandidateList[X, Y, Z] <> nil then
            CandidateList[X, Y, Z] := nil;
        end;
  end;

  procedure ElectCandidates(const Palette: TPalette; X, Y, Z: Integer);
    function MinDiff(Left, Right, X: Integer): Integer; inline;
    begin
      if X < Left then
      begin
        Result := Left - X;
        Exit;
      end
      else if X > Right then
      begin
        Result := X - Right;
        Exit;
      end
      else
      begin
        Result := 0;
        Exit;
      end;
    end;
    function MaxDiff(Left, Right, X: Integer): Integer; inline;
    begin
      if X < Left then
      begin
        Result := Right - X;
        Exit;
      end
      else if X > Right then
      begin
        Result := X - Left;
        Exit;
      end
      else
      begin
        Result := Max(Right - X, X - Left);
        Exit;
      end;
    end;
  var
    C: TByteQuad;
    I, D, T: Integer;
    MinMaxDiff: Integer;
  begin
    MinMaxDiff := MaxInt;

    for I := 0 to Length(Palette) - 1 do
    begin
      C := Palette[I];
      D := MaxDiff(X * BlockSideSize, (X + 1) * BlockSideSize - 1, C[0]);
      T := D * D * ErrCoeff[0];
      if T >= MinMaxDiff then Continue;
      D := MaxDiff(Y * BlockSideSize, (Y + 1) * BlockSideSize - 1, C[1]);
      T := T + D * D * ErrCoeff[1];
      D := MaxDiff(Z * BlockSideSize, (Z + 1) * BlockSideSize - 1, C[2]);
      T := T + D * D * ErrCoeff[2];
      if T < MinMaxDiff then MinMaxDiff := T;
    end;

    for I := 0 to Length(Palette) - 1 do
    begin
      C := Palette[I];
      D := MinDiff(X * BlockSideSize, (X + 1) * BlockSideSize - 1, C[0]);
      T := D * D * ErrCoeff[0];
      if T > MinMaxDiff then Continue;
      D := MinDiff(Y * BlockSideSize, (Y + 1) * BlockSideSize - 1, C[1]);
      T := T + D * D * ErrCoeff[1];
      D := MinDiff(Z * BlockSideSize, (Z + 1) * BlockSideSize - 1, C[2]);
      T := T + D * D * ErrCoeff[2];

      if MinMaxDiff >= T then
      begin
        SetLength(CandidateList[X, Y, Z], Length(CandidateList[X, Y, Z]) + 1);
        CandidateList[X, Y, Z][Length(CandidateList[X, Y, Z]) - 1] := I;
      end;
    end;
  end;

  {//$DEFINE UseMMX}
  {$IFDEF UseMMX}
  function NearestEntryNC(C1: TByteQuad; const Palette: TPalette): Integer;
  var
    I, Index: Integer;
    Best, Diff: Integer;
    Candidates: TPaletteIndexList;
    CD: TWordQuad;
    C2: TByteQuad;
  begin
    Best := MaxInt;
    Index := 0;
    Candidates := CandidateList[C1[0] div BlockSideSize, C1[1] div BlockSideSize, C1[2] div BlockSideSize];
    if Candidates = nil then
    begin
      ElectCandidates(Palette, C1[0] div BlockSideSize, C1[1] div BlockSideSize, C1[2] div BlockSideSize);
      Candidates := CandidateList[C1[0] div BlockSideSize, C1[1] div BlockSideSize, C1[2] div BlockSideSize];
    end;
    asm
      pxor mm0,mm0
      movd mm1,C1
      punpcklbw mm1,mm0
    end;
    for I := 0 to Length(Candidates) - 1 do
    begin
      C2 := Palette[Candidates[I]];
      asm
        movd mm2,C2
        punpcklbw mm2,mm0
        psubw mm2,mm1
        pmullw mm2,mm2
        movq [CD],mm2
      end;
      Diff := CD[0] * ErrCoeff[0] +
              CD[1] * ErrCoeff[1] +
              CD[2] * ErrCoeff[2];
      if Best > Diff then
      begin
        Index := I;
        if Diff = 0 then Break;
        Best := Diff;
      end;
    end;
    asm
      emms
    end;
    Result := Candidates[Index];
  end;
  {$ELSE}
  function NearestEntryNC(C1: TByteQuad; const Palette: TPalette): Integer;
  var
    I, Index: Integer;
    Best, Diff: Integer;
    Candidates: TPaletteIndexList;
    C2: TByteQuad;
  begin
    Best := MaxInt;
    Index := 0;
    Candidates := CandidateList[C1[0] div BlockSideSize, C1[1] div BlockSideSize, C1[2] div BlockSideSize];
    if Candidates = nil then
    begin
      ElectCandidates(Palette, C1[0] div BlockSideSize, C1[1] div BlockSideSize, C1[2] div BlockSideSize);
      Candidates := CandidateList[C1[0] div BlockSideSize, C1[1] div BlockSideSize, C1[2] div BlockSideSize];
    end;
    for I := 0 to Length(Candidates) - 1 do
    begin
      C2 := Palette[Candidates[I]];
      Diff := (C1[0] - C2[0]) * (C1[0] - C2[0]) * ErrCoeff[0];
      if Diff > Best then Continue;
      Diff := Diff +
              (C1[1] - C2[1]) * (C1[1] - C2[1]) * ErrCoeff[1] +
              (C1[2] - C2[2]) * (C1[2] - C2[2]) * ErrCoeff[2];
      if Best > Diff then
      begin
        Index := I;
        if Diff = 0 then Break;
        Best := Diff;
      end;
    end;
    Result := Candidates[Index];
  end;
  {$ENDIF}

  function NearestEntry(C1: TByteQuad; const Palette: TPalette): Integer;
  var
    N, Index: Integer;
  begin
    N := (C1[0] and (LookupCacheValue - 1)) + (C1[1] and (LookupCacheValue - 1)) shl LookupCacheBits + (C1[2] and (LookupCacheValue - 1)) shl (LookupCacheBits * 2);
    if Cardinal(LookupCache[N].Color) = Cardinal(C1) then
    begin
      Result := LookupCache[N].Index;
      Exit;
    end;
    Index := NearestEntryNC(C1, Palette);
    LookupCache[N].Color := C1;
    LookupCache[N].Index := Index;
    Result := Index;
  end;

  procedure MakePalette(const CubeList: TList; const Palette: TPalette);
    procedure SortPalette(const Palette: TPalette);
    var
      List: TList;
      I: Integer;
    begin
      List := TList.Create();
      try
        for I := 0 to Colors - 1 do
          List.Add(Pointer(Cardinal(Palette[I])));
        List.Sort(CompareInteger);
        for I := 0 to Colors - 1 do
          Palette[I] := TByteQuad(Cardinal(List.Items[I]));
      finally
        FreeAndNil(List);
      end;
    end;
  var
    X, I: Integer;
  begin
    for X := 0 to CubeList.Count - 1 do
      for I := 0 to 2 do
        Palette[X][I] := Trunc(PColorCube(CubeList.Items[X]).C[I].Mid + 0.5);
    SortPalette(Palette);
    InvalidateCandidate();
  end;

  procedure OptimizePalette(ColorCount: Cardinal; const Palette: TPalette; const Histogram: PColorHistogram; Count: Integer);
  type
    TErrorElement = record
      Sum: array[0..2] of Double;
      Count: Cardinal;
    end;

    procedure MakeHEA(Colors: Cardinal; const Histogram: PColorHistogram; var HEA: array of THistogramElement);
    var
      I, X, Y, Z, H: Integer;
    begin
      I := 0;
      for X := 0 to 255 do
      begin
        for Y := 0 to 255 do
        begin
          for Z := 0 to 255 do
          begin
            H := Histogram[X, Y, Z];
            if H <> 0 then
            begin
              with HEA[I] do
              begin
                Color[0] := X;
                Color[1] := Y;
                Color[2] := Z;
                Count := H;
                Cache[0] := X * H;
                Cache[1] := Y * H;
                Cache[2] := Z * H;
              end;
              Inc(I);
            end;
          end;
        end;
      end;
    end;

    procedure OptimizePaletteImpl(ColorCount: Cardinal; const Palette: TPalette; const HEA: array of THistogramElement; var EEA: array of TErrorElement);
    var
      I, X: Integer;
      P: PByteQuad;
    begin
      FillChar(EEA[0], SizeOf(EEA[0]) * Colors, 0);

      for I := 0 to ColorCount - 1 do
      begin
        X := NearestEntryNC(HEA[I].Color, Palette);
        with EEA[X], HEA[I] do
        begin
          Sum[0] := Sum[0] + Cache[0];
          Sum[1] := Sum[1] + Cache[1];
          Sum[2] := Sum[2] + Cache[2];
          //EEA[X].Count := EEA[X].Count + HEA[I].Count;
          EEA[X].Count := EEA[X].Count + Count;
        end;
      end;

      InvalidateCandidate();

      for I := 0 to Colors - 1 do
      begin
        with EEA[I] do
        begin
          if Count <> 0 then
          begin
            P := @Palette[I];
            P[0] := Trunc(Sum[0] / Count + 0.5);
            P[1] := Trunc(Sum[1] / Count + 0.5);
            P[2] := Trunc(Sum[2] / Count + 0.5);
          end;
        end;
      end;
    end;
  var
    I: Integer;
    HEA: array of THistogramElement;
    EEA: array of TErrorElement;
  begin
    SetLength(HEA, ColorCount);
    SetLength(EEA, Colors);
    MakeHEA(ColorCount, Histogram, HEA);
    for I := 0 to Count - 1 do
    begin
      OptimizePaletteImpl(ColorCount, Palette, HEA, EEA);
    end;
  end;

  procedure InsertList(const CubeList: TList; const NewCube: PColorCube);
  var
    I: Integer;
  begin
    I := 0;
    while (I < CubeList.Count) and (PColorCube(CubeList.Items[I]).Err >= NewCube.Err) do
    begin
      Inc(I);
    end;
    CubeList.Insert(I, NewCube);
  end;

  procedure MapColorWithFloydSteinberg(const Src, Dst: TBitmap; const Palette: TPalette);
  var
    SP: PByteQuadArray;
    DP: PByteArray;
    C: TByteQuad;
    X, Y, I, N: Integer;
    Diffs: array[0..2] of PIntegerTripleArray;
  begin
    for I := 0 to 1 do
    begin
      Diffs[I] := AllocMem((Src.Width + 2) * SizeOf(TIntegerTriple));
      FillChar(Diffs[I]^, (Src.Width + 2) * SizeOf(TIntegerTriple), 0);
    end;

    for Y := 0 to Src.Height - 1 do
    begin
      SP := Src.Scanline[Y];
      DP := Dst.Scanline[Y];
      for X := 0 to Src.Width - 1 do
      begin
        C := SP[X];
        for I := 0 to 2 do
        begin
          N := Diffs[0][X][I];
          N := N + Diffs[0][X + 1][I] * 5;
          N := N + Diffs[0][X + 2][I] * 3;
          N := N + Diffs[1][X][I] * 7;
          C[I] := Clamp(C[I] + N div 16, 0, 255);
        end;
        N := NearestEntry(C, Palette);
        DP[X] := N;
        C := SP[X];
        for I := 0 to 2 do
        begin
          Diffs[1][X + 1][I] := C[I] - Palette[N][I];
        end
      end;
      Diffs[2] := Diffs[0];
      Diffs[0] := Diffs[1];
      Diffs[1] := Diffs[2];
      Application.ProcessMessages();
    end;
  end;

  procedure MapColor(const Src, Dst: TBitmap; const Palette: TPalette);
  var
    SP: PByteQuadArray;
    DP: PByteArray;
    X, Y: Integer;
  begin
    for Y := 0 to Src.Height - 1 do
    begin
      SP := Src.Scanline[Y];
      DP := Dst.Scanline[Y];
      for X := 0 to Src.Width - 1 do
        DP[X] := NearestEntry(SP[X], Palette);
      Application.ProcessMessages();
    end;
  end;

  function AverageError(const Src, Dst: TBitmap; const Palette: TPalette): Extended;
  var
    SP: PByteQuadArray;
    DP: PByteArray;
    X, Y: Integer;
  begin
    Result := 0;
    for Y := 0 to Src.Height - 1 do
    begin
      SP := Src.Scanline[Y];
      DP := Dst.Scanline[Y];
      for X := 0 to Src.Width - 1 do
      begin
        Result := Result + Sqrt(
          (SP[X][0] - Palette[DP[X]][0]) * (SP[X][0] - Palette[DP[X]][0]) +
          (SP[X][1] - Palette[DP[X]][1]) * (SP[X][1] - Palette[DP[X]][1]) +
          (SP[X][2] - Palette[DP[X]][2]) * (SP[X][2] - Palette[DP[X]][2]));
      end;
    end;
    Result := Result / (Src.Width * Src.Height);
  end;

  function CreateNativePalette(const Palette: TPalette): Cardinal;
  var
    I: Integer;
    P: TMaxLogPalette;
  begin
    FillChar(P, SizeOf(P), 0);
    P.palVersion := $300;
    P.palNumEntries := 256;
    for I := 0 to 255 do
    begin
      P.palPalEntry[I].peBlue := Palette[I][0];
      P.palPalEntry[I].peGreen := Palette[I][1];
      P.palPalEntry[I].peRed := Palette[I][2];
    end;
    Result := CreatePalette(PLogPalette(@P)^)
  end;

var
  I: Integer;
  Err: Double;
  Dst: TBitmap;
  Cube, NewCube: PColorCube;
  ColorCount: Cardinal;
  Palette: TPalette;
  Histogram: PColorHistogram;
  CubeList: TList;
begin
  if Colors > 16 then SetLength(Palette, 256) else SetLength(Palette, 16);
  if Src.PixelFormat <> pf32bit then Src.PixelFormat := pf32bit;
  if Src.Palette <> 0 then DeleteObject(Src.ReleasePalette);

  Histogram := AllocMem($4000000);
  try
    ColorCount := MakeHistogram(Histogram);

    CubeList := TList.Create();
    NewCube := AllocMem(SizeOf(TColorCube));
    for I := 0 to 2 do
    begin
      NewCube.C[I].Min := 0;
      NewCube.C[I].Max := 255;
    end;
    CalcError(NewCube, Histogram);
    CubeList.Add(NewCube);

    while CubeList.Count < Colors do
    begin
      Cube := CubeList.Items[0];
      if Cube.Err = 0 then Break;
      CubeList.Delete(0);

      I := 0;
      Err := Cube.C[0].Err;
      if Cube.C[1].Err > Err then
      begin
        I := 1;
        Err := Cube.C[1].Err;
      end;
      if Cube.C[2].Err > Err then I := 2;

      NewCube := AllocMem(SizeOf(TColorCube));
      NewCube^ := Cube^;
      NewCube.C[I].Max := Floor(Cube.C[I].Mid);
      CalcError(NewCube, Histogram);
      InsertList(CubeList, NewCube);

      Cube.C[I].Min := Ceil(Cube.C[I].Mid);
      CalcError(Cube, Histogram);
      InsertList(CubeList, Cube);

      Application.ProcessMessages();
    end;

    MakePalette(CubeList, Palette);
    for I := 0 to CubeList.Count - 1 do FreeMem(CubeList.Items[I]);
    FreeAndNil(CubeList);

    OptimizePalette(ColorCount, Palette, Histogram, 5);

    FillChar(LookupCache, SizeOf(LookupCache), $FF);
    Dst := TBitmap.Create();
    try
      Dst.PixelFormat := pf8bit;
      Dst.Width := Src.Width;
      Dst.Height := Src.Height;
      Dst.Palette := CreateNativePalette(Palette);
      if Dither then MapColorWithFloydSteinberg(Src, Dst, Palette) else MapColor(Src, Dst, Palette);
      Src.Assign(Dst);
    finally
      FreeAndNil(Dst);
    end;
  finally
    FreeMem(Histogram);
  end;
end;

end.

unit ImageTypes;

interface

uses
  Vcl.Graphics;

const
  PixelBits = pf24bit;

type
  TByteTriple = packed array [0 .. 2] of Byte;
  TPixel = TByteTriple;
  PPixel = ^TPixel;
  TPixelArray = array [0 .. 400000] of TPixel;
  PPixelArray = ^TPixelArray;

  TByteQuad = packed array [0 .. 3] of Byte;
  PByteQuad = ^TByteQuad;
  TByteQuadArray = array [0 .. 0] of TByteQuad;
  PByteQuadArray = ^TByteQuadArray;

  TByteArray = array [0 .. 400000] of Byte;
  PByteArray = ^TByteArray;

  TRGBTriple = packed record
    B, G, R: Byte;
  end;

  TRGB = TRGBTriple;
  PRGB = ^TRGB;
  TRGBArray = array [0 .. 400000] of TRGB;
  PRGBArray = ^TRGBArray;

  TRGBQuad = packed record
    B, G, R, A: Byte;
  end;

  TProgressProc = procedure(Progress: Integer);

implementation

end.

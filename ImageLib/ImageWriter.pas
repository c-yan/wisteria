unit ImageWriter;

interface

uses
  System.Classes, Vcl.Graphics, System.SysUtils;

procedure SaveAsPSD(Src: TBitmap; FileName: string);
procedure SaveAsPPM(Src: TBitmap; FileName: string);

implementation

type
  TByteArray = array[0..400000] of Byte;
  PByteArray = ^TByteArray;
  TPixel = packed array[0..2] of Byte;
  TPixelArray = array[0..400000] of TPixel;
  PPixelArray = ^TPixelArray;

procedure SaveAsPSD(Src: TBitmap; FileName: string);
var
  Stream: TStream;
  Buffer: array of Byte;
  I, X, Y: Integer;
  P1: PPixelArray;
  P2: PByteArray;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SetLength(Buffer, Src.Width - 1);
    //*** File Header ***
    FillChar(Buffer[0], 26, 0);
    Buffer[0] := Ord('8'); //signature
    Buffer[1] := Ord('B');
    Buffer[2] := Ord('P');
    Buffer[3] := Ord('S');
    Buffer[5] := 1; //version
    if Src.PixelFormat = pf24bit then Buffer[13] := 3 else Buffer[13] := 1; //channels
    Buffer[14] := (Src.Height shr 24) and $FF; //rows
    Buffer[15] := (Src.Height shr 16) and $FF;
    Buffer[16] := (Src.Height shr 8) and $FF;
    Buffer[17] := Src.Height and $FF;
    Buffer[18] := (Src.Width shr 24) and $FF; //columns
    Buffer[19] := (Src.Width shr 16) and $FF;
    Buffer[20] := (Src.Width shr 8) and $FF;
    Buffer[21] := Src.Width and $FF;
    Buffer[23] := 8; //depth
    if Src.PixelFormat = pf24bit then Buffer[25] := 3 else Buffer[25] := 1; //mode
    Stream.WriteBuffer(Buffer[0], 26);

    FillChar(Buffer[0], 26, 0);
    Stream.WriteBuffer(Buffer[0], 4); //color Mode Data
    Stream.WriteBuffer(Buffer[0], 4); //image resources
    Stream.WriteBuffer(Buffer[0], 4); //layer and mask information

    //Image Data
    Stream.WriteBuffer(Buffer[0], 2); //Compression
    if Src.PixelFormat = pf24bit then
    begin
      for I := 2 downto 0 do
      begin
        for Y := 0 to Src.Height - 1 do
        begin
          P1 := Src.ScanLine[Y];
          for X := 0 to Src.Width - 1 do
          begin
            Buffer[X] := P1[X][I];
          end;
          Stream.WriteBuffer(Buffer[0], Src.Width);
        end;
      end;
    end
    else
    begin
      for Y := 0 to Src.Height - 1 do
      begin
        P2 := Src.ScanLine[Y];
        for X := 0 to Src.Width - 1 do
        begin
          Buffer[X] := P2[X];
        end;
        Stream.WriteBuffer(Buffer[0], Src.Width);
      end;
    end;
  finally
    Stream.Free;
  end;
end;

procedure SaveAsPPM(Src: TBitmap; FileName: string);
var
  Y, X: Cardinal;
  SP: PPixelArray;
  S: string;
begin
  S := '';
  S := S + 'P3'#10;
  S := S + Format('%d %d'#10, [Src.Width, Src.Height]);
  S := S + '255'#10;
  for Y := 0 to Src.Height - 1 do
  begin
    SP := Src.ScanLine[Y];
    for X := 0 to Src.Width - 1 do
    begin
      S := S + Format('%3d %3d %3d'#10, [SP[X][2], SP[X][1], SP[X][0]]);
    end;
  end;
  with TStringList.Create do
  try
    Text := S;
    SaveToFile(FileName);
  finally
    Free;
  end;
end;

end.

unit ssESCPosPrintBitmap;

interface
uses
  FMX.Types,
  FMX.Controls,
  FMX.Forms3D,
  FMX.Types3D,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Objects,

  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,

  Math;

type
  // *** -------------------------------------------------------------------------
  // *** INTERFACE: IssESCPosPrintBitmap
  // *** -------------------------------------------------------------------------
  IssESCPosPrintBitmap = interface( IInterface )
    ['{3F279585-6D2E-451F-AF97-76F0E07A70DF}']
    function RenderBitmapObj( const ABitmap: TBitmap ): string;
  end;

  function _ESCPosPrintBitmap(): IssESCPosPrintBitmap;

implementation


type
  // *** -------------------------------------------------------------------------
  // *** RECORD:  TBitmapData
  // *** -------------------------------------------------------------------------
  TMeuBitMapData = record
    Dots      : array of Boolean;
    Height    : Integer;
    Width     : Integer;
  end;
  // *** -------------------------------------------------------------------------
  // *** CLASS: TssESCPosPrintBitmap
  // *** -------------------------------------------------------------------------
  TssESCPosPrintBitmap = class( TInterfacedObject, IssESCPosPrintBitmap )
    private
      FLumThreshold : Integer;
      FBitmap       : TBitmap;
      FBitmapData   : TMeuBitMapData;

      procedure LoadBitmapData();
    public
      constructor Create();
      destructor Destroy; override;

      function RenderBitmapObj( const ABitmap: TBitmap ): string;
  end;

const
  C_DEFAULT_THRESHOLD = 127;
  const xLineBreak = #13#10;

function _ESCPosPrintBitmap(): IssESCPosPrintBitmap;
begin
  Result := TssESCPosPrintBitmap.Create();
end;


{ TssESCPosPrintBitmap }

{-------------------------------------------------------------------------------
  Procedure: TssESCPosPrintBitmap.Create
  Author:    bvonfintel
  DateTime:  2015.01.06
  Arguments: None
  Result:    None
-------------------------------------------------------------------------------}
constructor TssESCPosPrintBitmap.Create;
begin
  inherited;
  FBitmap       := TBitmap.Create();
  FLumThreshold := C_DEFAULT_THRESHOLD;
end;

{-------------------------------------------------------------------------------
  Procedure: TssESCPosPrintBitmap.Destroy
  Author:    bvonfintel
  DateTime:  2015.01.06
  Arguments: None
  Result:    None
-------------------------------------------------------------------------------}
destructor TssESCPosPrintBitmap.Destroy;
begin
  FBitmap.Free();
  inherited;
end;

{-------------------------------------------------------------------------------
  Procedure: TssESCPosPrintBitmap.LoadBitmapData
  Author:    bvonfintel
  DateTime:  2015.01.06
  Arguments: None
  Result:    None
-------------------------------------------------------------------------------}

procedure TssESCPosPrintBitmap.LoadBitmapData;
var
  LIndex : Integer;
  LX     : Integer;
  LY     : Integer;
  LLum   : Integer;

  vBitMapData : TBitmapData;
  vPixelColor : TAlphaColor;
begin
  LIndex := 0;

  FBitmapData.Height := FBitmap.Height;
  FBitmapData.Width  := FBitmap.Width;
  SetLength( FBitmapData.Dots, FBitmap.Width * FBitmap.Height );

  if FBitmap.Map(TMapAccess.maRead, vBitMapData) then // lock bitmap and get pixels
  begin
    for LY := 0 to FBitmap.Height - 1 do begin
      for LX := 0 to FBitmap.Width - 1 do begin
        vPixelColor := vBitmapData.GetPixel(LX, LY);  // get the pixel colour

        LLum := Trunc( (TAlphaColorRec(vPixelColor).R * 0.3) +
                       (TAlphaColorRec(vPixelColor).G * 0.59) +
                       (TAlphaColorRec(vPixelColor).B * 0.11) );
        FBitmapData.Dots[LIndex] := ( LLum < FLumThreshold );
        Inc( LIndex );
      end;
    end;

  end;
  FBitmap.Unmap(vBitMapData);      // unlock the bitmap
end;
{-------------------------------------------------------------------------------
  Procedure: TssESCPosPrintBitmap.RenderBitmap
  Author:    bvonfintel
  DateTime:  2015.01.06
  Arguments: const ABitmapFilename: string
  Result:    string
-------------------------------------------------------------------------------}
function TssESCPosPrintBitmap.RenderBitmapObj( const ABitmap: TBitmap ): string;
var
  LOffset     : Integer;
  LX          : Integer;
  LSlice      : Byte;
  LB          : Integer;
  LK          : Integer;
  LY          : Integer;
  LI          : Integer;
  LV          : Boolean;
  LVI         : Integer;
begin
  FBitmap:= ABitmap;

  // *** Convert the bitmap to an array of B/W pixels
  LoadBitmapData();


  // *** Set the line spacing to 24 dots, the height of each "stripe" of the
  // *** image that we're drawing
  Result := #27'@';

  LOffset := 0;
  while ( LOffset < FBitmapData.Height ) do begin
    Result := Result + #29;
    Result := Result + 'E'; // Bit image mode
    Result := Result + #8; //  density
    Result := Result + #29'*';
    Result := Result + Char(Trunc(FBitmapData.Width / 8));
    Result := Result + Char(8);

    for LX := 0 to FBitmapData.Width -1 do begin
      for LK := 0 to 7 do begin
        LSlice := 0;
        for LB := 0 to 7 do begin
          LY := ( ( ( LOffset div 8 ) + LK ) * 8 ) + LB;
          LI := ( LY * FBitmapData.Width ) + LX;

          LV := False;
          if ( LI < Length( FBitmapData.Dots ) ) then
            LV := FBitmapData.Dots[LI];

          LVI := IfThen( LV, 1, 0 );

          LSlice := LSlice or ( LVI shl ( 7 - LB ) );
        end;

        Result := Result + Chr( LSlice );
      end;
    end;

    LOffset := LOffset + 64;
    Result := Result + #29'/'#0;
  end;
end;

end.

unit UntPrincipal;

interface

uses
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.ListBox,
  FMX.Layouts,
  FMX.Controls.Presentation,
  FMX.Objects,
  FMX.Edit,

  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Bluetooth,
  System.Bluetooth.Components;

//UUID para impressoras Bluetooth
const
  UUID = '{00001101-0000-1000-8000-00805F9B34FB}';

type
  TfrmPrincipal = class(TForm)
    ToolBar1: TToolBar;
    Label1: TLabel;
    ListBox1: TListBox;
    lsboxImpressora: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    cbxDevices: TComboBox;
    btnImprimir: TButton;
    BT: TBluetooth;
    imgLogo: TImage;
    imgFoto: TImage;
    imgQrCode: TImage;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    rctLogo: TRectangle;
    rctImage: TRectangle;
    rctQrCode: TRectangle;
    grdLayout: TGridLayout;
    Layout2: TLayout;
    Layout1: TLayout;
    procedure btnImprimirClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbxDevicesChange(Sender: TObject);
  private
    { Private declarations }
    procedure ListarDispositivosPareadosNoCombo;
    function  ObterDevicePeloNome(ANomeDevice: String): TBluetoothDevice;
    function  ConectarImpressora(ANomeDevice: String): Boolean;
    function  MakeScaleScreenshot(const Sender: TControl): TBitmap;
    procedure EnviarImpressao(const Sender: TControl);
  public
    { Public declarations }
    FSocket : TBluetoothSocket;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses
  ssESCPOSPrintBitmap,
  uAguarde;

{$R *.fmx}

{ TfrmPrincipal }

function TfrmPrincipal.MakeScaleScreenshot(const Sender: TControl): TBitmap;
var
  fScreenScale: Single;
begin
  fScreenScale := 1; // Canvas.Scale; //GetScreenScale;
  Result       := TBitmap.Create(Round(Sender.Width * fScreenScale), Round(Sender.Height * fScreenScale));
  Result.Clear(0);
  if Result.Canvas.BeginScene then
  try
    Sender.PaintTo(Result.Canvas, RectF(0, 0, Result.Width, Result.Height));
  finally
    Result.Canvas.EndScene;
  end;
end;

procedure TfrmPrincipal.btnImprimirClick(Sender: TObject);
begin
  //ESC/POS
  if (FSocket <> nil) and (FSocket.Connected) then
  begin
    FSocket.SendData(TEncoding.UTF8.GetBytes(chr(27) + chr(64)));
    FSocket.SendData(TEncoding.UTF8.GetBytes(chr(27) + chr(97) + chr(1)));
    FSocket.SendData(TEncoding.UTF8.GetBytes(chr(27) + chr(33) + chr(8)));
    FSocket.SendData(TEncoding.UTF8.GetBytes(chr(27) + chr(33) + chr(16)));
    FSocket.SendData(TEncoding.UTF8.GetBytes(chr(27) + chr(33) + chr(32)));

    FSocket.SendData(TEncoding.UTF8.GetBytes('S1 Software' + chr(13)));
    FSocket.SendData(TEncoding.UTF8.GetBytes(chr(27) + chr(100) + chr(1)));
    FSocket.SendData(TEncoding.UTF8.GetBytes('Datecs DPP 250' + chr(13)));
    FSocket.SendData(TEncoding.UTF8.GetBytes(chr(27) + chr(100) + chr(1)));
    FSocket.SendData(TEncoding.UTF8.GetBytes(chr(27) + chr(33) + chr(0)));

    FSocket.SendData(TEncoding.UTF8.GetBytes('Imprimindo direto para Bluetooth '));
    FSocket.SendData(TEncoding.UTF8.GetBytes(chr(27) + chr(100) + chr(1)));
    FSocket.SendData(TEncoding.UTF8.GetBytes('Imprimindo direto para Bluetooth '));
    FSocket.SendData(TEncoding.UTF8.GetBytes(chr(27) + chr(100) + chr(1)));

    FSocket.SendData(TEncoding.UTF8.GetBytes(chr(27) + chr(97) + chr(0)));
    FSocket.SendData(TEncoding.UTF8.GetBytes(chr(27) + chr(100) + chr(5)));
    FSocket.SendData(TEncoding.UTF8.GetBytes(chr(29) + chr(107) + chr(2) + '8983847583721' + chr(0)));
    FSocket.SendData(TEncoding.UTF8.GetBytes(chr(27) + chr(100) + chr(5)));
  end;
end;

procedure TfrmPrincipal.Button1Click(Sender: TObject);
begin
  EnviarImpressao(rctLogo);
end;

procedure TfrmPrincipal.Button2Click(Sender: TObject);
begin
  EnviarImpressao(rctImage);
end;

procedure TfrmPrincipal.Button3Click(Sender: TObject);
begin
  EnviarImpressao(rctQrCode);
end;

procedure TfrmPrincipal.EnviarImpressao(const Sender: TControl);
var
  LBuffer  : String;
  Bitmap   : TBitmap;
  I        : Integer;
  viDif    : Integer;
  vbNormal : TBytes;
begin
  Bitmap := MakeScaleScreenshot(Sender);

  LBuffer := #27'3'#30#27'@'  ; //Inicializa a impressora
  LBuffer := LBuffer +  _ESCPosPrintBitmap().RenderBitmapObj(Bitmap) + LBuffer ;

  //Converte a String em Bytes para enviar à impressora...
  SetLength(vbNormal, Length(LBuffer));

  viDif := Abs(Low(LBuffer) - Low(vbNormal));
  for I := Low(LBuffer) to High(LBuffer) do
    vbNormal[I - viDif] := Ord(LBuffer[I]);

  //Imprimir
  if (FSocket <> nil) and (FSocket.Connected) then
  begin
    FSocket.SendData(vbNormal);
  end;
end;
procedure TfrmPrincipal.cbxDevicesChange(Sender: TObject);
begin
  TAguarde.Show(Self, 'Conectando-se ao dispositivo...');
  if (cbxDevices.Selected <> nil) and (cbxDevices.Selected.Text <> EmptyStr) then
  begin
    if ConectarImpressora(cbxDevices.Selected.Text)
    then lsboxImpressora.ItemData.Accessory := TListBoxItemData.TAccessory.aCheckmark
    else lsboxImpressora.ItemData.Accessory := TListBoxItemData.TAccessory.aNone;
  end;
  TAguarde.Hide;
end;

function TfrmPrincipal.ConectarImpressora(ANomeDevice: String): Boolean;
var
  lDevice: TBluetoothDevice;
begin
  Result := False;
  lDevice := ObterDevicePeloNome(ANomeDevice);
  if lDevice <> nil then
  begin
    FSocket := lDevice.CreateClientSocket(StringToGUID(UUID), False);
    if FSocket <> nil then
    begin
      FSocket.Connect;
      Result := FSocket.Connected
    end;
  end;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  ListarDispositivosPareadosNoCombo;
end;

procedure TfrmPrincipal.ListarDispositivosPareadosNoCombo;
var
  lDevice: TBluetoothDevice;
begin
  cbxDevices.Clear;
  for lDevice in BT.PairedDevices do
    cbxDevices.Items.Add(lDevice.DeviceName);
end;

function TfrmPrincipal.ObterDevicePeloNome(ANomeDevice: String): TBluetoothDevice;
var
  lDevice: TBluetoothDevice;
begin
  Result := nil;
  for lDevice in BT.PairedDevices do
    if lDevice.DeviceName = ANomeDevice then
      Result := lDevice;
end;

end.

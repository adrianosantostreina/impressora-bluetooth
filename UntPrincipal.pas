unit UntPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.ListBox, FMX.Layouts, FMX.Controls.Presentation, System.Bluetooth,
  System.Bluetooth.Components;

const
  UUID = '{00001101-0000-1000-8000-00805F9B34FB}';

type
  TfrmPrincipal = class(TForm)
    ToolBar1: TToolBar;
    Label1: TLabel;
    ListBox1: TListBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    cbxDevices: TComboBox;
    btnListar: TButton;
    btnConectar: TButton;
    btnImprimir: TButton;
    lblStatus: TLabel;
    Bluetooth1: TBluetooth;
    procedure btnListarClick(Sender: TObject);
    procedure btnConectarClick(Sender: TObject);
    procedure btnImprimirClick(Sender: TObject);
  private
    { Private declarations }
    procedure ListarDispositivosPareadosNoCombo;
    function ObterDevicePeloNome(ANomeDevice: String): TBluetoothDevice;
    function ConectarImpressora(ANomeDevice: String): Boolean;
  public
    { Public declarations }
    FSocket : TBluetoothSocket;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}

{ TfrmPrincipal }

procedure TfrmPrincipal.btnConectarClick(Sender: TObject);
begin
  if (cbxDevices.Selected <> nil) and (cbxDevices.Selected.Text <> EmptyStr) then
  begin
    if ConectarImpressora(cbxDevices.Selected.Text)
    then lblStatus.Text := 'Conectado'
    else lblStatus.Text := 'Desconectado';
  end
  else
    ShowMessage('Selecione um dispositivo.');
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

    FSocket.SendData(TEncoding.UTF8.GetBytes('TDevRocks' + chr(13)));
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

procedure TfrmPrincipal.btnListarClick(Sender: TObject);
begin
  ListarDispositivosPareadosNoCombo;
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

procedure TfrmPrincipal.ListarDispositivosPareadosNoCombo;
var
  lDevice: TBluetoothDevice;
begin
  cbxDevices.Clear;
  for lDevice in Bluetooth1.PairedDevices do
    cbxDevices.Items.Add(lDevice.DeviceName);
end;

function TfrmPrincipal.ObterDevicePeloNome(ANomeDevice: String): TBluetoothDevice;
var
  lDevice: TBluetoothDevice;
begin
  Result := nil;
  for lDevice in Bluetooth1.PairedDevices do
    if lDevice.DeviceName = ANomeDevice then
      Result := lDevice;
end;

end.

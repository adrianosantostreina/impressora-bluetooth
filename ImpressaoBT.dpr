program ImpressaoBT;

uses
  System.StartUpCopy,
  FMX.Forms,
  UntPrincipal in 'UntPrincipal.pas' {frmPrincipal},
  ssESCPOSPrintBitmap in 'ssESCPOSPrintBitmap.pas',
  uAguarde in 'utils\uAguarde.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.

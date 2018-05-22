unit uAguarde;

interface

uses
  System.UITypes,

  FMX.Types,
  FMX.Controls,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Forms,
  FMX.Effects, FMX.Graphics;

type
  TAguarde = class
  private
    class var PAguarde : TRectangle;
    class var PFundo   : TPanel;

    class procedure TrocaCorPFundo(Sender: TObject);
  public
    class procedure Show(aParent: TFMXObject; Msg: string = '');
    class procedure Hide;
  end;

implementation

class procedure TAguarde.Hide;
begin
  if (Assigned(PAguarde)) then
  begin
    PFundo.AnimateFloat('opacity', 0);
    PAguarde.AnimateFloatWait('opacity', 0);

    PFundo.DisposeOf;
    PAguarde.DisposeOf;

    PFundo := nil;
    PAguarde := nil;
  end;
end;

class procedure TAguarde.Show(aParent: TFMXObject; Msg: String);
begin
  PFundo                    := TPanel.Create(aParent);
  PFundo.Parent             := aParent;
  PFundo.Visible            := False;
  PFundo.Align              := TAlignLayout.Contents;
  PFundo.OnApplyStyleLookup := TrocaCorPFundo;

  PAguarde                  := TRectangle.Create(aParent);
  PAguarde.Parent           := aParent;
  PAguarde.Visible          := False;
  PAguarde.Height           := 73;
  PAguarde.Width            := 273;
  PAguarde.XRadius          := 10;
  PAguarde.YRadius          := 10;
  PAguarde.Anchors          := [];
  PAguarde.Position.X       := (TForm(aParent).ClientWidth - PAguarde.Width) / 2;
  PAguarde.Position.Y       := (TForm(aParent).ClientHeight - PAguarde.Height) / 2;
  //PAguarde.Stroke.Color     := TAlphaColor.White;
  PAguarde.Stroke.Kind      := TBrushKind.None;

  with TLabel.Create(PAguarde) do
  begin
    Parent        := PAguarde;
    Align         := TAlignLayout.alTop;
    Margins.Left  := 10;
    Margins.Top   := 10;
    Margins.Right := 10;
    Height        := 28;
    StyleLookup   := 'embossedlabel';
    Text          := 'Por favor, aguarde!';
    Trimming      := TTextTrimming.ttCharacter;
  end;

  //Erro, testando
  //with TAniIndicator.Create(PAguarde) do
  //begin
  //  Parent   := PAguarde;
  //  Align    := TAlignLayout.alMostLeft;
  //  Width    := 50;
  //  Visible  := True;
  //  Enabled  := True;
  //end;

  with TLabel.Create(PAguarde) do
  begin
    Parent         := PAguarde;
    Align          := TAlignLayout.alClient;
    Margins.Left   := 10;
    Margins.Top    := 10;
    Margins.Right  := 10;
    Font.Size      := 12;
    StyledSettings := [TStyledSetting.ssFamily,
                       TStyledSetting.ssStyle,
                       TStyledSetting.ssFontColor];
    Text           := Msg;
    VertTextAlign  := TTextAlign.taLeading;
    Trimming       := TTextTrimming.ttCharacter;
  end;

  with TShadowEffect.Create(PAguarde) do
  begin
    Parent := PAguarde;
    Enabled := True;
  end;

  PFundo.Opacity     := 0;
  PAguarde.Opacity   := 0;

  PFundo.Visible     := True;
  PAguarde.Visible   := True;

  PFundo.AnimateFloat('opacity', 0.5);
  PAguarde.AnimateFloatWait('opacity', 1);
  PAguarde.BringToFront;
  PAguarde.SetFocus;
end;

class procedure TAguarde.TrocaCorPFundo(Sender: TObject);
var
  Rectangle: TRectangle;
begin
  Rectangle := (Sender as TFmxObject).Children[0] as TRectangle;
  Rectangle.Fill.Color := TAlphaColors.Black;
end;

end.

Há um tempo atrás, fizemos aqui no blog uma Vakinha para a compra de uma mini-impressora bluetooth. O objetivo era estudar as formas de impressão nesses equipamentos utilizando aplicativos criados em Delphi. Pois bem, a promessa era criar um artigo com todas as explicações necessárias para que nossos leitores fossem capazes de fazer uso desses equipamentos. Esse dia chegou. Gravamos uma vídeo-aula exclusiva mostrando o passo a passo e agora você poderá conferir também o detalhamento em texto. Ao final desse artigo você também encontrará o link para o vídeo e o código-fonte que já está disponível em nosso GitHub.



Impressão em Mini-Impressora Bluetooth

Vamos começar iniciando um novo projeto no Delphi 10.1 usando File > New > Multi-Device Application Delphi. Escolha Blank Application e confirme. Nosso formulário se chamará frmPrincipal e podemos chamar sua Unit como UntPrincipal.pas. Na sequência salve também o projeto. Em nosso exemplo, chamamos de ImpressapBT.dproj. Vamos modificar um pouco o aspecto visual do formulário. Sua propriedade Heigth terá o valor de 570 e Width será igual a 385. Dessa forma teremos um formulário com o tamanho mais adequado.

Em seguida insira um ToolBar e dentro dele um Label. Alinhe esse Label usando o alinhamento Contents. Marque sua propriedade HorzAlign em TextSettings como Center. Agora insira um ListBox no form e marque sua propriedade Align como Top. Adicione três itens de ListBox nele. Altere a altura de cada um para 40.

No primeiro item, adicione um ComboBox com o nome de cbxDevices. Adicione também um Button com o nome de btnListar. Alinhe o btnListar usando a opção Right. Altere também suas margens como abaixo:

Bottom: 2px;
Left: 0px;
Right: 4px;
Top: 2px;
Em seguida altere o alinhamento do cbxDevices para Client e suas margens para:

Bottom: 2px;
Left: 4px;
Right: 0px;
Top: 2px;


Esses dois controles serão usados para listar todos os dispositivos previamente pareados com nosso smartphone, ou seja, a premissa principal será que a mini-impressora já tenha sido pareada com o aparelho antes de iniciarmos a impressão.

Agora no segundo item de ListBox adicione um Label com o nome de lblStatus e um novo button que se chamará btnConectar. Repita as configurações de alinhamentos e margens feitas nos controles do primeiro item.

No terceiro item, adicione um novo TButton com o nome de btnImpressao. Alinhe-o ao centro. Se preferir mexa também nas propriedades de alinhamento. Esse botão será um dos mais importantes, ele enviará os textos para impressão na mini-impressora.

A última providência é inserir um componente do tipo TBluetooth ao formulário e ativar sua propriedade Enabled. O nosso formulário se parecerá muito com a figura abaixo:

Impressão em Mini-Impressora Bluetooth

Iniciando a codificação

A primeira e mais importante coisa a se fazer, é declarar o UUID da impressora para que possamos conectar-se a ela. O UUID é como um código único, uma porta. É através dele que abrimos uma conexão com o dispositivo bluetooth. Todo dispositivo BT (Bluetooth) possui um desses códigos. Para nossa felicidade o MVP Alan Glei estudou a fundo essa disciplina e nos enviou o código para uso com essas impressoras. Então nossos votos de gratidão vão a ele.

O UUID que vamos utilizar é único para esse tipo de equipamento e não para cada impressora. Nós do TDevRocks testamos o mesmo código em nossa Datacs DPP-250 e em outras impressoras nacionais e provenientes da China. Todas funcionaram perfeitamente.

Logo após a seção Uses da Interface, adicione uma nova constante com o código que iremos utilizar.



[delphi]
const
  UUID = '{00001101-0000-1000-8000-00805F9B34FB}';
[/delphi]


Em seguida precisaremos criar nossos métodos continuar nossa programação. Acesse a seção Private e adicione os métodos como abaixo:



[delphi]
    procedure ListarDispositivosPareadosNoCombo;
    function ObterDevicePeloNome(ANomeDevice: String): TBluetoothDevice;
    function ConectarImpressora(ANomeDevice: String): Boolean;
[/delphi]


A próxima providência é declarar uma variável do tipo TBluetoothSocket chamada FSocket. Essa variável será usada para usarmos seu método SendData que será responsável por enviar os caracteres e textos para a impressora. Declare a variável em Public.



[delphi]
    FSocket : TBluetoothSocket;
[/delphi]


Criados os métodos, pressione Ctrl + Shift + C para que o Delphi crie para nós os escopos de cada método. Antes de codificarmos, vamos entender o que cada método fará. Iniciando por ListarDispositivosPareadosNoCombo. Esse método fará o trabalho de ler os dispositivos que foram previamente pareados no smartphone e atualizar o ComboBox cbxDevices.

O segundo método, ObterDevicePeloNome será usado para que possamos obter uma referência ao dispositivo selecionado pelo usuário. Também usaremos esse método para conectar-se a impressora. E por fim, o método ConectarImpressora conecta à impressora como o próprio nome sugere.

Vamos então a parte mais interessante, à codificação.

O primeiro método que codificaremos é o método ListarDispositivosPareadosNoCombo.



[delphi]
procedure TfrmPrincipal.ListarDispositivosPareadosNoCombo;
var
  lDevice: TBluetoothDevice;
begin
  cbxDevices.Clear;
  for lDevice in Bluetooth1.PairedDevices do
    cbxDevices.Items.Add(lDevice.DeviceName);
end;
[/delphi]


Perceba que o método é relativamente simples. Criamos uma variável do tipo TBlueToothDevice que será usada no loop For a seguir. Montamos um loop no resultado recebido pelo método PariedDevices do componente TBluetooth1. A cada iteração do For, inserimos o nome do dispositivo encontrado no Items do cbxDevices.

O método ObterDevicePeloNome faz o trabalho obter uma instância, uma referência para a impressora selecionada pelo usuário no ComboBox. A obtenção dessa referência é feita pelo nome da impressora, ou seja, pelo item selecionado no ComboBox. A ideia é simples. Novamente usamos uma variável do tipo TBlueToothDevice que será usada para devolver o Result com a referência à impressora. Montamos novamente um loop em cima do resultado do método PariedDevices do componente TBluetooth1. A diferença é que comparamos o nome do dispositivo passado por parâmetro com o nome do dispositivo encontrado no loop. Se forem iguais, significa que encontramos a impressora selecionada no combo, então devolvemos sua referência.



[delphi]
function TfrmPrincipal.ObterDevicePeloNome(ANomeDevice: String): TBluetoothDevice;
var
  lDevice: TBluetoothDevice;
begin
  Result := nil;
  for lDevice in Bluetooth1.PairedDevices do
    if lDevice.DeviceName = ANomeDevice then
      Result := lDevice;
end;
[/delphi]


O último método é responsável por conectar-se à impressora como mencionamos anteriormente. Acesse o método ConectarImpressora e digite a codificação a seguir:



[delphi]
function TfrmPrincipal.ConectarImpressora(ANomeDevice: String): Boolean;
var
  lDevice: TBluetoothDevice;
begin
  Result := False;
  lDevice := ObterDevicePeloNome(ANomeDevice);
  if lDevice &lt;&gt; nil then
  begin
    FSocket := lDevice.CreateClientSocket(StringToGUID(UUID), False);
    if FSocket &lt;&gt; nil then
    begin
      FSocket.Connect;
      Result := FSocket.Connected
    end;
  end;
end;
[/delphi]


Nesse método estamos recebendo a referência à impressora logo no início para então criar uma instância de FSocket na memória. Perceba que o método CreateClientSocket presente na classe TBlueToothDevice recebe como parâmetro o UUID criado no início do artigo. Usamos a função StringToGUID para transformar o texto da constante em um GUID válido para o método utilizar. O Result do método é um Boolean informando se conseguiu ou não conectar-se e ativar a variável FScoket.

Envio dos comandos para a impressora

A última, mas não menos importante etapa, é o envio propriamente dito de comandos e textos para a impressora. Essa etapa será codificada diretamente no botão btnImpressao. O método consiste em enviar comandos ESC/POS para a impressora. Para quem já mexeu com isso "nos tempos" de impressoras matriciais Epson LX-300 dentre outras, será, literalmente "mamão com açucar". Os comandos ESC/POS foram criados pela Epson, não falha a memória, nos anos 80. Mas se não for seu caso, na internet é possível encontrar várias dicas sobre o assunto.

Outra informação importante a mencionar é que cada impressora possui seus próprios comandos, ou seja, quando você precisa alternar de negrito para itálico, aumentar a fonte em uma determinada linha, aumentar o espaçamento de caracteres, etc, você deverá recorrer ao manual da sua mini-impressora. Cada uma possui suas próprias configurações. A notícia boa é que grande parte dos comandos são genéricos e funcionam com praticamente todas as impressoras. Mesmo assim é importante entender todos os comandos de seu equipamento.

Acesse o evento OnClick do botão btnImpressao e digite o código abaixo:



[delphi]
procedure TfrmPrincipal.btnImprimirClick(Sender: TObject);
begin
  //ESC/POS
  if (FSocket &lt;&gt; nil) and (FSocket.Connected) then
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
[/delphi]


Nossa primeira providência é testar se a variável FSocket está diferente de nil, ou seja, recebeu uma instância da impressora e se está conectado à ela. Em caso positivo, iniciamos nossa impressão. Perceba que antes de cada texto a ser impresso, enviamos uma sequência de caracteres. Essa sequência é particular de nossa impressora Datecs DPP-250, mas em alguns casos pode ser utilizado em qualquer mini-impressora. Estamos usando o método SendData para o envio dos comandos.

Como mencionado anteriormente é altamente recomendável que leia o manual de seu equipamento e faça os devidos ajustes. No vídeo abaixo você pode conferir um trecho do vídeo gravado o disponibilizado em nosso YouTube. Com isso encerramos nossa publicação.

Mais uma vez gostaríamos de agradecer à todos que contribuíram com a Vakinha e esperamos que o conteúdo seja bem consumido.

Obrigado, bons estudos e até a próxima.



Baixe o código-Fonte e eBook com o conteúdo:
https://goo.gl/5VOmxL

Assista a vídeo-aula
Assista Agora

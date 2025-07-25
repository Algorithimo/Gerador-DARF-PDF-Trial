unit uFormDARFViewer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Mask, DateUtils,
  uApiDARF, uPDFViewer;

type
  TfrmDARFViewer = class(TForm)
    pnlPrincipal: TPanel;
    pnlEsquerdo: TPanel;
    pnlDireito: TPanel;
    gbParametros: TGroupBox;
    lblPeriodoApuracao: TLabel;
    lblDataVencimento: TLabel;
    lblCodigoReceita: TLabel;
    lblValorPrincipal: TLabel;
    lblValorMulta: TLabel;
    lblValorJuros: TLabel;
    lblValorTotal: TLabel;
    lblObservacao: TLabel;
    edtPeriodoApuracao: TMaskEdit;
    dtpVencimento: TDateTimePicker;
    edtCodigoReceita: TEdit;
    edtValorPrincipal: TEdit;
    edtValorMulta: TEdit;
    edtValorJuros: TEdit;
    edtValorTotal: TEdit;
    memoObservacao: TMemo;
    btnGerarDARF: TButton;
    btnLimpar: TButton;
    btnAbrirExterno: TButton;
    gbStatus: TGroupBox;
    pnlStatus: TPanel;
    lblStatus: TLabel;
    memoInfo: TMemo;
    gbOpcoes: TGroupBox;
    rbVisualizadorInterno: TRadioButton;
    rbVisualizadorExterno: TRadioButton;
    btnSalvarComo: TButton;
    btnLimparViewer: TButton;
    lblTamanhoPDF: TLabel;
    gbVisualizador: TGroupBox;
    pnlViewer: TPanel;
    lblMensagemViewer: TLabel;
    SaveDialog1: TSaveDialog;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnGerarDARFClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure btnAbrirExternoClick(Sender: TObject);
    procedure btnSalvarComoClick(Sender: TObject);
    procedure btnLimparViewerClick(Sender: TObject);
    procedure edtValorKeyPress(Sender: TObject; var Key: Char);

  private
    FApiDARF: TApiDARF;
    FPDFViewer: TPDFViewer;

    procedure LimparCampos;
    procedure ExibirStatus(const AStatus: string; ACor: TColor);
    procedure AtualizarInfoPDF;
    function ValidarCampos: Boolean;
    function FormatarValor(const AValor: string): string;
    procedure GerarEVisualizarDARF;
    procedure LimparVisualizador;

  public
    { Public declarations }
  end;

var
  frmDARFViewer: TfrmDARFViewer;

implementation

{$R *.dfm}

procedure TfrmDARFViewer.FormCreate(Sender: TObject);
begin
  // Criar instâncias das classes
  FApiDARF := TApiDARF.Create;
  FPDFViewer := TPDFViewer.Create(pnlViewer);

  // Configurações iniciais
  dtpVencimento.Date := Date + 30; // 30 dias a partir de hoje

  // Valores de exemplo para facilitar testes
  edtPeriodoApuracao.Text := FormatDateTime('mm/yyyy', Date);
  edtCodigoReceita.Text := '0220';
  edtValorPrincipal.Text := '1000';
  edtValorMulta.Text := '50';
  edtValorJuros.Text := '25';
  edtValorTotal.Text := '1075';
  memoObservacao.Text := 'DARF gerado via API CONSOLIDARGERARDARF51 com visualizador integrado';

  // Configurar opções padrão
  rbVisualizadorInterno.Checked := True;

  // Status inicial
  ExibirStatus('Pronto para gerar DARF - Preencha os campos e clique em "Gerar DARF"', clGreen);
  AtualizarInfoPDF;

  // Ocultar WebBrowser inicialmente
  FPDFViewer.WebBrowser.Visible := False;
  lblMensagemViewer.Visible := True;
end;

procedure TfrmDARFViewer.FormDestroy(Sender: TObject);
begin
  if Assigned(FPDFViewer) then
    FPDFViewer.Free;

  if Assigned(FApiDARF) then
    FApiDARF.Free;
end;

procedure TfrmDARFViewer.btnGerarDARFClick(Sender: TObject);
begin
  GerarEVisualizarDARF;
end;

procedure TfrmDARFViewer.btnLimparClick(Sender: TObject);
begin
  LimparCampos;
  ExibirStatus('Campos limpos - Pronto para nova geração', clGray);
end;

procedure TfrmDARFViewer.btnAbrirExternoClick(Sender: TObject);
var
  lResultado: TResultadoPDF;
begin
  if FPDFViewer.TamanhoPDF = 0 then
  begin
    ShowMessage('Nenhum PDF carregado! Gere um DARF primeiro.');
    Exit;
  end;

  lResultado := FPDFViewer.AbrirComVisualizadorExterno;

  if lResultado.Sucesso then
    ExibirStatus('PDF aberto com visualizador externo', clGreen)
  else
    ExibirStatus('Erro ao abrir PDF externamente: ' + lResultado.MensagemErro, clRed);
end;

procedure TfrmDARFViewer.btnSalvarComoClick(Sender: TObject);
var
  lResultado: TResultadoPDF;
begin
  if FPDFViewer.TamanhoPDF = 0 then
  begin
    ShowMessage('Nenhum PDF carregado! Gere um DARF primeiro.');
    Exit;
  end;

  SaveDialog1.FileName := 'DARF_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.pdf';

  if SaveDialog1.Execute then
  begin
    lResultado := FPDFViewer.SalvarComo(SaveDialog1.FileName);

    if lResultado.Sucesso then
      ExibirStatus('PDF salvo em: ' + SaveDialog1.FileName, clGreen)
    else
      ExibirStatus('Erro ao salvar PDF: ' + lResultado.MensagemErro, clRed);
  end;
end;

procedure TfrmDARFViewer.btnLimparViewerClick(Sender: TObject);
begin
  LimparVisualizador;
  ExibirStatus('Visualizador limpo', clGray);
end;

procedure TfrmDARFViewer.edtValorKeyPress(Sender: TObject; var Key: Char);
begin
  // Permitir apenas números, vírgula, ponto e teclas de controle
  if not (Key in ['0'..'9', ',', '.', #8, #13]) then
    Key := #0;
end;

procedure TfrmDARFViewer.LimparCampos;
begin
  edtPeriodoApuracao.Text := '';
  edtCodigoReceita.Text := '';
  edtValorPrincipal.Text := '';
  edtValorMulta.Text := '';
  edtValorJuros.Text := '';
  edtValorTotal.Text := '';
  memoObservacao.Text := '';
  memoInfo.Text := '';
end;

procedure TfrmDARFViewer.ExibirStatus(const AStatus: string; ACor: TColor);
begin
  lblStatus.Caption := AStatus;
  lblStatus.Font.Color := clWhite;
  pnlStatus.Color := ACor;
end;

procedure TfrmDARFViewer.AtualizarInfoPDF;
begin
  lblTamanhoPDF.Caption := Format('Tamanho PDF: %d bytes', [FPDFViewer.TamanhoPDF]);

  if FPDFViewer.TamanhoPDF > 0 then
  begin
    btnAbrirExterno.Enabled := True;
    btnSalvarComo.Enabled := True;
    btnLimparViewer.Enabled := True;
  end
  else
  begin
    btnAbrirExterno.Enabled := False;
    btnSalvarComo.Enabled := False;
    btnLimparViewer.Enabled := False;
  end;
end;

function TfrmDARFViewer.ValidarCampos: Boolean;
begin
  Result := False;

  // Validar período de apuração
  if Trim(edtPeriodoApuracao.Text) = '' then
  begin
    ShowMessage('Informe o período de apuração (MM/YYYY)!');
    edtPeriodoApuracao.SetFocus;
    Exit;
  end;

  // Validar código da receita
  if Trim(edtCodigoReceita.Text) = '' then
  begin
    ShowMessage('Informe o código da receita!');
    edtCodigoReceita.SetFocus;
    Exit;
  end;

  // Validar valor principal
  if Trim(edtValorPrincipal.Text) = '' then
  begin
    ShowMessage('Informe o valor principal!');
    edtValorPrincipal.SetFocus;
    Exit;
  end;

  // Validar valor da multa
  if Trim(edtValorMulta.Text) = '' then
  begin
    ShowMessage('Informe o valor da multa!');
    edtValorMulta.SetFocus;
    Exit;
  end;

  // Validar valor dos juros
  if Trim(edtValorJuros.Text) = '' then
  begin
    ShowMessage('Informe o valor dos juros!');
    edtValorJuros.SetFocus;
    Exit;
  end;

  // Validar valor total
  if Trim(edtValorTotal.Text) = '' then
  begin
    ShowMessage('Informe o valor total!');
    edtValorTotal.SetFocus;
    Exit;
  end;

  // Validar se os valores são números válidos
  try
    StrToFloat(StringReplace(StringReplace(edtValorPrincipal.Text, '.', '', [rfReplaceAll]), ',', '.', [rfReplaceAll]));
    StrToFloat(StringReplace(StringReplace(edtValorMulta.Text, '.', '', [rfReplaceAll]), ',', '.', [rfReplaceAll]));
    StrToFloat(StringReplace(StringReplace(edtValorJuros.Text, '.', '', [rfReplaceAll]), ',', '.', [rfReplaceAll]));
    StrToFloat(StringReplace(StringReplace(edtValorTotal.Text, '.', '', [rfReplaceAll]), ',', '.', [rfReplaceAll]));
  except
    ShowMessage('Um ou mais valores monetários são inválidos!' + #13#10 +
                'Use o formato: 1000,00 ou 1000.00');
    Exit;
  end;

  Result := True;
end;

function TfrmDARFViewer.FormatarValor(const AValor: string): string;
begin
  // Remove pontos de milhar e converte vírgula para ponto decimal
  Result := StringReplace(AValor, '.', '', [rfReplaceAll]);
  Result := StringReplace(Result, ',', '.', [rfReplaceAll]);
end;

procedure TfrmDARFViewer.GerarEVisualizarDARF;
var
  lParametrosAPI: TParametrosAPI;
  lResultadoAPI: TResultadoAPI;
  lResultadoPDF: TResultadoPDF;
begin
  // Validar campos antes de prosseguir
  if not ValidarCampos then
    Exit;

  try
    // Mostrar status de processamento
    ExibirStatus('Chamando API SERPRO...', clBlue);
    btnGerarDARF.Enabled := False;
    btnLimpar.Enabled := False;
    Application.ProcessMessages;

    // Preparar parâmetros para a API
    lParametrosAPI.PeriodoApuracao := edtPeriodoApuracao.Text;
    lParametrosAPI.DataVencimento := FormatDateTime('yyyy-mm-dd', dtpVencimento.Date);
    lParametrosAPI.CodigoReceita := edtCodigoReceita.Text;
    lParametrosAPI.ValorPrincipal := FormatarValor(edtValorPrincipal.Text);
    lParametrosAPI.ValorMulta := FormatarValor(edtValorMulta.Text);
    lParametrosAPI.ValorJuros := FormatarValor(edtValorJuros.Text);
    lParametrosAPI.ValorTotal := FormatarValor(edtValorTotal.Text);
    lParametrosAPI.Observacao := memoObservacao.Text;

    // Chamar API para obter PDF em Base64
    lResultadoAPI := FApiDARF.ChamarAPI(lParametrosAPI);

    if lResultadoAPI.Sucesso then
    begin
      // API retornou sucesso - carregar PDF no visualizador
      ExibirStatus('PDF recebido! Carregando visualizador...', clBlue);
      Application.ProcessMessages;

      // Carregar PDF Base64 no visualizador
      lResultadoPDF := FPDFViewer.CarregarPDFBase64(lResultadoAPI.PDFBase64);

      if lResultadoPDF.Sucesso then
      begin
        // PDF carregado com sucesso - escolher modo de visualização
        ExibirStatus('PDF carregado! Exibindo...', clBlue);
        Application.ProcessMessages;

        if rbVisualizadorInterno.Checked then
        begin
          // Visualização interna com WebBrowser
          lResultadoPDF := FPDFViewer.VisualizarNoWebBrowser;

          if lResultadoPDF.Sucesso then
          begin
            // Sucesso - mostrar WebBrowser e ocultar mensagem
            FPDFViewer.WebBrowser.Visible := True;
            lblMensagemViewer.Visible := False;

            ExibirStatus(Format('PDF visualizado com sucesso! (%d bytes)',
                               [lResultadoPDF.TamanhoBinario]), clGreen);

            memoInfo.Text := Format(
              'PDF gerado e visualizado com sucesso!' + #13#10 +
              '• Período: %s' + #13#10 +
              '• Código: %s' + #13#10 +
              '• Valor: R$ %s' + #13#10 +
              '• Tamanho: %d bytes',
              [lParametrosAPI.PeriodoApuracao,
               lParametrosAPI.CodigoReceita,
               lParametrosAPI.ValorTotal,
               lResultadoPDF.TamanhoBinario]);
          end
          else
          begin
            ExibirStatus('Erro ao exibir PDF: ' + lResultadoPDF.MensagemErro, clRed);
          end;
        end
        else
        begin
          // Visualização externa
          lResultadoPDF := FPDFViewer.AbrirComVisualizadorExterno;

          if lResultadoPDF.Sucesso then
          begin
            ExibirStatus(Format('PDF aberto externamente! (%d bytes)',
                               [lResultadoPDF.TamanhoBinario]), clGreen);
          end
          else
          begin
            ExibirStatus('Erro ao abrir PDF externamente: ' + lResultadoPDF.MensagemErro, clRed);
          end;
        end;

        // Atualizar informações do PDF
        AtualizarInfoPDF;
      end
      else
      begin
        // Erro ao carregar PDF
        ExibirStatus('Erro ao processar PDF: ' + lResultadoPDF.MensagemErro, clRed);
        memoInfo.Text := 'Erro ao processar PDF Base64:' + #13#10 + lResultadoPDF.MensagemErro;
      end;
    end
    else
    begin
      // Erro na API
      ExibirStatus('Erro na API: ' + lResultadoAPI.MensagemErro, clRed);
      memoInfo.Text := 'Erro na chamada da API:' + #13#10 +
                      'Mensagem: ' + lResultadoAPI.MensagemErro + #13#10 +
                      'Detalhes: ' + lResultadoAPI.DetalhesErro;
    end;

  except
    on E: Exception do
    begin
      // Erro geral
      ExibirStatus('Erro inesperado: ' + E.Message, clRed);
      memoInfo.Text := 'Exceção capturada:' + #13#10 +
                      'Classe: ' + E.ClassName + #13#10 +
                      'Mensagem: ' + E.Message;
    end;
  end;

  // Reabilitar botões
  btnGerarDARF.Enabled := True;
  btnLimpar.Enabled := True;
end;

procedure TfrmDARFViewer.LimparVisualizador;
begin
  // Ocultar WebBrowser e mostrar mensagem
  FPDFViewer.WebBrowser.Visible := False;
  lblMensagemViewer.Visible := True;

  // Limpar dados do PDF (isso criará um novo viewer)
  FPDFViewer.Free;
  FPDFViewer := TPDFViewer.Create(pnlViewer);
  FPDFViewer.WebBrowser.Visible := False;

  // Atualizar informações
  AtualizarInfoPDF;
  memoInfo.Text := '';
end;

end.

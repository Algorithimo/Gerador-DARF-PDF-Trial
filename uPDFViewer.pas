unit uPDFViewer;

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, Forms, EncdDecd, Windows, ShellAPI,
  ActiveX, OleCtrls, SHDocVw;

type
  // Resultado da operação de PDF
  TResultadoPDF = record
    Sucesso: Boolean;
    MensagemErro: string;
    TamanhoBinario: Integer;
  end;

  // Classe responsável APENAS pela manipulação e visualização de PDF
  TPDFViewer = class
  private
    FWebBrowser: TWebBrowser;
    FContainer: TWinControl;
    FPDFBinario: TBytes;

    function ConverterBase64ParaBinario(const ABase64: string): TBytes;
    function CriarDataURI(const APDFBinario: TBytes): string;
    function SalvarArquivoTemporario(const AConteudo: TBytes): string;
    function GetTamanhoPDF: Integer;

  public
    constructor Create(AContainer: TWinControl);
    destructor Destroy; override;

    // Métodos principais
    function CarregarPDFBase64(const APDFBase64: string): TResultadoPDF;
    function VisualizarNoWebBrowser: TResultadoPDF;
    function AbrirComVisualizadorExterno: TResultadoPDF;
    function SalvarComo(const ACaminhoArquivo: string): TResultadoPDF;

    // Propriedades
    property PDFBinario: TBytes read FPDFBinario;
    property TamanhoPDF: Integer read GetTamanhoPDF;
    property WebBrowser: TWebBrowser read FWebBrowser;
  end;

implementation

uses
  StrUtils;

{ TPDFViewer }

constructor TPDFViewer.Create(AContainer: TWinControl);
begin
  inherited Create;

  FContainer := AContainer;
  SetLength(FPDFBinario, 0);

  // Criar WebBrowser para visualização interna
  FWebBrowser := TWebBrowser.Create(AContainer);
  FWebBrowser.SetParentComponent(FContainer);
  FWebBrowser.Align := alClient;
  FWebBrowser.Visible := True;
end;

destructor TPDFViewer.Destroy;
begin
  if Assigned(FWebBrowser) then
    FWebBrowser.Free;

  SetLength(FPDFBinario, 0);
  inherited;
end;

function TPDFViewer.ConverterBase64ParaBinario(const ABase64: string): TBytes;
var
  lStringStream: TStringStream;
  lMemoryStream: TMemoryStream;
begin
  SetLength(Result, 0);

  if ABase64 = '' then
    Exit;

  try
    lStringStream := TStringStream.Create(ABase64, TEncoding.ASCII);
    lMemoryStream := TMemoryStream.Create;
    try
      // Decodificar Base64
      DecodeStream(lStringStream, lMemoryStream);

      // Converter para TBytes
      lMemoryStream.Position := 0;
      SetLength(Result, lMemoryStream.Size);
      if lMemoryStream.Size > 0 then
        lMemoryStream.ReadBuffer(Result[0], lMemoryStream.Size);

    finally
      lStringStream.Free;
      lMemoryStream.Free;
    end;
  except
    SetLength(Result, 0);
  end;
end;

function TPDFViewer.CarregarPDFBase64(const APDFBase64: string): TResultadoPDF;
begin
  Result.Sucesso := False;
  Result.MensagemErro := '';
  Result.TamanhoBinario := 0;

  try
    // Limpar PDF anterior
    SetLength(FPDFBinario, 0);

    if APDFBase64 = '' then
    begin
      Result.MensagemErro := 'String Base64 está vazia';
      Exit;
    end;

    // Converter Base64 para binário
    FPDFBinario := ConverterBase64ParaBinario(APDFBase64);

    if Length(FPDFBinario) = 0 then
    begin
      Result.MensagemErro := 'Erro ao converter Base64 para binário';
      Exit;
    end;

    // Verificar se é um PDF válido (magic number)
    if (Length(FPDFBinario) < 4) or
       (FPDFBinario[0] <> $25) or  // %
       (FPDFBinario[1] <> $50) or  // P
       (FPDFBinario[2] <> $44) or  // D
       (FPDFBinario[3] <> $46) then // F
    begin
      Result.MensagemErro := 'Conteúdo não parece ser um PDF válido';
      Exit;
    end;

    Result.Sucesso := True;
    Result.TamanhoBinario := Length(FPDFBinario);

  except
    on E: Exception do
    begin
      Result.MensagemErro := 'Erro ao carregar PDF: ' + E.Message;
      SetLength(FPDFBinario, 0);
    end;
  end;
end;

function TPDFViewer.CriarDataURI(const APDFBinario: TBytes): string;
var
  lBase64: string;
  lStringStream: TStringStream;
  lMemoryStream: TMemoryStream;
begin
  Result := '';

  if Length(APDFBinario) = 0 then
    Exit;

  try
    lMemoryStream := TMemoryStream.Create;
    lStringStream := TStringStream.Create('', TEncoding.ASCII);
    try
      // Escrever bytes no stream
      lMemoryStream.WriteBuffer(APDFBinario[0], Length(APDFBinario));
      lMemoryStream.Position := 0;

      // Codificar para Base64
      EncodeStream(lMemoryStream, lStringStream);
      lBase64 := lStringStream.DataString;

      // Criar Data URI
      Result := 'data:application/pdf;base64,' + lBase64;

    finally
      lMemoryStream.Free;
      lStringStream.Free;
    end;
  except
    Result := '';
  end;
end;

function TPDFViewer.VisualizarNoWebBrowser: TResultadoPDF;
var
  lDataURI: string;
  lArquivoTemp: string;
  lHTMLContent: string;
  lArquivoHTML: string;
  lTempPath: array[0..MAX_PATH] of Char;
  lFileStream: TFileStream;
begin
  Result.Sucesso := False;
  Result.MensagemErro := '';
  Result.TamanhoBinario := Length(FPDFBinario);

  if Length(FPDFBinario) = 0 then
  begin
    Result.MensagemErro := 'Nenhum PDF carregado. Use CarregarPDFBase64 primeiro.';
    Exit;
  end;

  try
    // Tentar método 1: Data URI (funciona para PDFs pequenos)
    if Length(FPDFBinario) < 1048576 then // Menor que 1MB
    begin
      lDataURI := CriarDataURI(FPDFBinario);

      if lDataURI <> '' then
      begin
        try
          FWebBrowser.Navigate(lDataURI);
          Result.Sucesso := True;
          Exit;
        except
          // Se falhar, tenta método 2
        end;
      end;
    end;

    // Método 2: Arquivo temporário via file:// (mais compatível)
    lArquivoTemp := SalvarArquivoTemporario(FPDFBinario);

    if lArquivoTemp <> '' then
    begin
      try
        // Navegar para arquivo local
        FWebBrowser.Navigate('file:///' + StringReplace(lArquivoTemp, '\', '/', [rfReplaceAll]));
        Result.Sucesso := True;
        Exit;
      except
        // Se falhar, tenta método 3
      end;
    end;

    // Método 3: HTML com embed/object (fallback) - criar arquivo HTML temporário
    lArquivoTemp := SalvarArquivoTemporario(FPDFBinario);

    if lArquivoTemp <> '' then
    begin
      // Criar conteúdo HTML
      lHTMLContent :=
        '<!DOCTYPE html>' +
        '<html>' +
        '<head>' +
        '  <title>Visualizador PDF</title>' +
        '  <style>' +
        '    body { margin: 0; padding: 0; background: #f0f0f0; font-family: Arial, sans-serif; }' +
        '    .container { width: 100%; height: 100vh; text-align: center; }' +
        '    embed, object { width: 100%; height: 100%; }' +
        '    .fallback { padding: 20px; margin-top: 50px; }' +
        '    .fallback h3 { color: #2c5aa0; }' +
        '    .fallback p { color: #555; margin: 10px 0; }' +
        '  </style>' +
        '</head>' +
        '<body>' +
        '  <div class="container">' +
        '    <embed src="file:///' + StringReplace(lArquivoTemp, '\', '/', [rfReplaceAll]) + '" type="application/pdf" width="100%" height="100%">' +
        '      <object data="file:///' + StringReplace(lArquivoTemp, '\', '/', [rfReplaceAll]) + '" type="application/pdf" width="100%" height="100%">' +
        '        <div class="fallback">' +
        '          <h3>✅ PDF Gerado com Sucesso!</h3>' +
        '          <p><strong>Tamanho:</strong> ' + FormatFloat('#,##0', Length(FPDFBinario)) + ' bytes</p>' +
        '          <p>O visualizador interno não conseguiu exibir o PDF diretamente.</p>' +
        '          <p><strong>Solução:</strong> Use o botão <em>"Abrir Externo"</em> para visualizar com o leitor padrão do Windows.</p>' +
        '          <p style="color: #666; font-size: 12px; margin-top: 30px;">Arquivo salvo em: ' + lArquivoTemp + '</p>' +
        '        </div>' +
        '      </object>' +
        '    </embed>' +
        '  </div>' +
        '</body>' +
        '</html>';

      // Salvar HTML como arquivo temporário
      try
        GetTempPath(MAX_PATH, lTempPath);
        lArquivoHTML := IncludeTrailingPathDelimiter(string(lTempPath)) +
                       'DARF_Viewer_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.html';

        lFileStream := TFileStream.Create(lArquivoHTML, fmCreate);
        try
          lFileStream.WriteBuffer(lHTMLContent[1], Length(lHTMLContent) * SizeOf(Char));
        finally
          lFileStream.Free;
        end;

        // Navegar para o arquivo HTML
        FWebBrowser.Navigate(lArquivoHTML);
        Result.Sucesso := True;

      except
        on E: Exception do
        begin
          Result.MensagemErro := 'Erro ao criar arquivo HTML temporário: ' + E.Message;
        end;
      end;
    end
    else
    begin
      Result.MensagemErro := 'Erro ao criar arquivo temporário para visualização';
    end;

  except
    on E: Exception do
    begin
      Result.MensagemErro := 'Erro ao visualizar PDF no WebBrowser: ' + E.Message;
    end;
  end;
end;

function TPDFViewer.SalvarArquivoTemporario(const AConteudo: TBytes): string;
var
  lArquivoTemp: string;
  lFileStream: TFileStream;
  lTempPath: array[0..MAX_PATH] of Char;
begin
  Result := '';

  try
    // Obter diretório temporário
    GetTempPath(MAX_PATH, lTempPath);

    // Gerar nome de arquivo temporário
    lArquivoTemp := IncludeTrailingPathDelimiter(string(lTempPath)) +
                   'DARF_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.pdf';

    // Salvar arquivo
    lFileStream := TFileStream.Create(lArquivoTemp, fmCreate);
    try
      lFileStream.WriteBuffer(AConteudo[0], Length(AConteudo));
      Result := lArquivoTemp;
    finally
      lFileStream.Free;
    end;

  except
    Result := '';
  end;
end;

function TPDFViewer.AbrirComVisualizadorExterno: TResultadoPDF;
var
  lArquivoTemp: string;
begin
  Result.Sucesso := False;
  Result.MensagemErro := '';
  Result.TamanhoBinario := Length(FPDFBinario);

  if Length(FPDFBinario) = 0 then
  begin
    Result.MensagemErro := 'Nenhum PDF carregado. Use CarregarPDFBase64 primeiro.';
    Exit;
  end;

  try
    // Salvar arquivo temporário
    lArquivoTemp := SalvarArquivoTemporario(FPDFBinario);

    if lArquivoTemp = '' then
    begin
      Result.MensagemErro := 'Erro ao criar arquivo temporário';
      Exit;
    end;

    // Abrir com visualizador padrão
    if ShellExecute(0, 'open', PChar(lArquivoTemp), nil, nil, SW_SHOWNORMAL) <= 32 then
    begin
      Result.MensagemErro := 'Erro ao abrir PDF com visualizador externo';
      Exit;
    end;

    Result.Sucesso := True;

  except
    on E: Exception do
    begin
      Result.MensagemErro := 'Erro ao abrir PDF externamente: ' + E.Message;
    end;
  end;
end;

function TPDFViewer.SalvarComo(const ACaminhoArquivo: string): TResultadoPDF;
var
  lFileStream: TFileStream;
begin
  Result.Sucesso := False;
  Result.MensagemErro := '';
  Result.TamanhoBinario := Length(FPDFBinario);

  if Length(FPDFBinario) = 0 then
  begin
    Result.MensagemErro := 'Nenhum PDF carregado. Use CarregarPDFBase64 primeiro.';
    Exit;
  end;

  if ACaminhoArquivo = '' then
  begin
    Result.MensagemErro := 'Caminho do arquivo não informado';
    Exit;
  end;

  try
    lFileStream := TFileStream.Create(ACaminhoArquivo, fmCreate);
    try
      lFileStream.WriteBuffer(FPDFBinario[0], Length(FPDFBinario));
      Result.Sucesso := True;
    finally
      lFileStream.Free;
    end;

  except
    on E: Exception do
    begin
      Result.MensagemErro := 'Erro ao salvar arquivo: ' + E.Message;
    end;
  end;
end;

function TPDFViewer.GetTamanhoPDF: Integer;
begin
  Result := Length(FPDFBinario);
end;

end.

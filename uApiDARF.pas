unit uApiDARF;

interface

uses
  Classes, SysUtils, JSON, DateUtils, System.Net.HttpClient, System.Net.URLClient;

type
  // Record para parâmetros de entrada da API
  TParametrosAPI = record
    PeriodoApuracao: string;     // MM/YYYY
    DataVencimento: string;      // YYYY-MM-DD
    CodigoReceita: string;       // Código da receita
    ValorPrincipal: string;      // Valor principal
    ValorMulta: string;          // Valor da multa
    ValorJuros: string;          // Valor dos juros
    ValorTotal: string;          // Valor total
    Observacao: string;          // Observações
  end;

  // Record para resultado da API (só Base64)
  TResultadoAPI = record
    Sucesso: Boolean;
    PDFBase64: string;           // PDF em Base64 retornado pela API
    MensagemErro: string;
    DetalhesErro: string;
    ResponseCompleto: string;    // JSON completo para debug
  end;

  // Classe responsável APENAS pela comunicação com a API
  TApiDARF = class
  private
    FHTTPClient: THTTPClient;

    const
      URL_BASE = 'https://gateway.apiserpro.serpro.gov.br/integra-contador-trial/v1/Emitir';
      BEARER_TOKEN = '06aef429-a981-3ec5-a1f8-71d38d86481e';

    function MontarJSONRequest(const AParametros: TParametrosAPI): string;
    function ProcessarResposta(const AResponse: string): TResultadoAPI;

  public
    constructor Create;
    destructor Destroy; override;

    // Método principal - retorna APENAS o PDF em Base64
    function ChamarAPI(const AParametros: TParametrosAPI): TResultadoAPI;
  end;

implementation

uses
  StrUtils;

{ TApiDARF }

constructor TApiDARF.Create;
begin
  inherited;

  // Criar cliente HTTP
  FHTTPClient := THTTPClient.Create;

  // Configurar timeout
  FHTTPClient.ConnectionTimeout := 30000; // 30 segundos
  FHTTPClient.ResponseTimeout := 60000;   // 60 segundos
end;

destructor TApiDARF.Destroy;
begin
  if Assigned(FHTTPClient) then
    FHTTPClient.Free;

  inherited;
end;

function TApiDARF.ChamarAPI(const AParametros: TParametrosAPI): TResultadoAPI;
var
  lJsonRequest: string;
  lResponse: IHTTPResponse;
  lRequestHeaders: TNetHeaders;
  lRequestBody: TStringStream;
begin
  // Inicializar resultado
  Result.Sucesso := False;
  Result.PDFBase64 := '';
  Result.MensagemErro := '';
  Result.DetalhesErro := '';
  Result.ResponseCompleto := '';

  try
    // Montar JSON da requisição
    lJsonRequest := MontarJSONRequest(AParametros);

    // Configurar headers
    SetLength(lRequestHeaders, 3);
    lRequestHeaders[0] := TNetHeader.Create('Authorization', 'Bearer ' + BEARER_TOKEN);
    lRequestHeaders[1] := TNetHeader.Create('Content-Type', 'application/json');
    lRequestHeaders[2] := TNetHeader.Create('Accept', 'application/json');

    // Criar stream com o JSON
    lRequestBody := TStringStream.Create(lJsonRequest, TEncoding.UTF8);
    try
      // Fazer requisição POST
      lResponse := FHTTPClient.Post(URL_BASE, lRequestBody, nil, lRequestHeaders);

      // Armazenar resposta completa para debug
      Result.ResponseCompleto := lResponse.ContentAsString();

      // Verificar status HTTP
      if lResponse.StatusCode <> 200 then
      begin
        Result.MensagemErro := Format('Erro HTTP %d: %s',
          [lResponse.StatusCode, lResponse.StatusText]);
        Result.DetalhesErro := Result.ResponseCompleto;
        Exit;
      end;

      // Processar resposta
      Result := ProcessarResposta(Result.ResponseCompleto);

    finally
      lRequestBody.Free;
    end;

  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.MensagemErro := 'Erro na comunicação com a API: ' + E.Message;
      Result.DetalhesErro := E.ClassName + ': ' + E.Message + #13#10 +
                            'JSON Request: ' + lJsonRequest;
    end;
  end;
end;

function TApiDARF.MontarJSONRequest(const AParametros: TParametrosAPI): string;
var
  lJsonRoot: TJSONObject;
  lContratante: TJSONObject;
  lAutorPedido: TJSONObject;
  lContribuinte: TJSONObject;
  lPedidoDados: TJSONObject;
  lDados: string;
begin
  lJsonRoot := TJSONObject.Create;
  try
    // Contratante
    lContratante := TJSONObject.Create;
    lContratante.AddPair('numero', '99999999999999');
    lContratante.AddPair('tipo', TJSONNumber.Create(2));
    lJsonRoot.AddPair('contratante', lContratante);

    // Autor do pedido
    lAutorPedido := TJSONObject.Create;
    lAutorPedido.AddPair('numero', '99999999999999');
    lAutorPedido.AddPair('tipo', TJSONNumber.Create(2));
    lJsonRoot.AddPair('autorPedidoDados', lAutorPedido);

    // Contribuinte
    lContribuinte := TJSONObject.Create;
    lContribuinte.AddPair('numero', '99999999999999');
    lContribuinte.AddPair('tipo', TJSONNumber.Create(2));
    lJsonRoot.AddPair('contribuinte', lContribuinte);

    // Pedido dados
    lPedidoDados := TJSONObject.Create;
    lPedidoDados.AddPair('idSistema', 'SICALC');
    lPedidoDados.AddPair('idServico', 'CONSOLIDARGERARDARF51');
    lPedidoDados.AddPair('versaoSistema', '2.9');

    // Montar string JSON dos dados
    lDados := Format('{"periodoApuracao": "%s", "dataVencimento": "%s", ' +
                     '"codigoReceita": "%s", "valorPrincipal": "%s", ' +
                     '"valorMulta": "%s", "valorJuros": "%s", ' +
                     '"valorTotal": "%s", "observacao": "%s"}',
                     [AParametros.PeriodoApuracao,
                      AParametros.DataVencimento,
                      AParametros.CodigoReceita,
                      AParametros.ValorPrincipal,
                      AParametros.ValorMulta,
                      AParametros.ValorJuros,
                      AParametros.ValorTotal,
                      StringReplace(StringReplace(AParametros.Observacao, '\', '\\', [rfReplaceAll]), '"', '\"', [rfReplaceAll])]);

    lPedidoDados.AddPair('dados', lDados);
    lJsonRoot.AddPair('pedidoDados', lPedidoDados);

    Result := lJsonRoot.ToString;

  finally
    lJsonRoot.Free;
  end;
end;

function TApiDARF.ProcessarResposta(const AResponse: string): TResultadoAPI;
var
  lJsonResponse: TJSONObject;
  lStatus: Integer;
  lDados: string;
  lJsonDados: TJSONObject;
  lMensagens: TJSONArray;
  lMensagem: TJSONObject;
  i: Integer;
begin
  // Inicializar resultado
  Result.Sucesso := False;
  Result.PDFBase64 := '';
  Result.MensagemErro := '';
  Result.DetalhesErro := AResponse;
  Result.ResponseCompleto := AResponse;

  try
    lJsonResponse := TJSONObject.ParseJSONValue(AResponse) as TJSONObject;
    if not Assigned(lJsonResponse) then
    begin
      Result.MensagemErro := 'Resposta JSON inválida';
      Exit;
    end;

    try
      // Verificar status
      if lJsonResponse.GetValue('status') = nil then
      begin
        Result.MensagemErro := 'Campo "status" não encontrado na resposta';
        Exit;
      end;

      lStatus := lJsonResponse.GetValue('status').Value.ToInteger;

      if lStatus = 200 then
      begin
        // Sucesso - extrair dados
        if lJsonResponse.GetValue('dados') = nil then
        begin
          Result.MensagemErro := 'Campo "dados" não encontrado na resposta';
          Exit;
        end;

        lDados := lJsonResponse.GetValue('dados').Value;

        if lDados <> '' then
        begin
          lJsonDados := TJSONObject.ParseJSONValue(lDados) as TJSONObject;
          if Assigned(lJsonDados) then
          try
            // Extrair campo 'darf' (PDF em Base64)
            if lJsonDados.GetValue('darf') <> nil then
            begin
              Result.PDFBase64 := lJsonDados.GetValue('darf').Value;

              if Result.PDFBase64 <> '' then
                Result.Sucesso := True
              else
                Result.MensagemErro := 'Campo "darf" está vazio na resposta';
            end
            else
            begin
              Result.MensagemErro := 'Campo "darf" não encontrado na resposta';
            end;

          finally
            lJsonDados.Free;
          end;
        end
        else
        begin
          Result.MensagemErro := 'Campo "dados" está vazio na resposta';
        end;
      end
      else
      begin
        // Erro - extrair mensagens
        Result.MensagemErro := Format('Erro HTTP %d', [lStatus]);

        if lJsonResponse.GetValue('mensagens') <> nil then
        begin
          lMensagens := lJsonResponse.GetValue('mensagens') as TJSONArray;
          if Assigned(lMensagens) then
          begin
            for i := 0 to lMensagens.Count - 1 do
            begin
              lMensagem := lMensagens.Items[i] as TJSONObject;
              if Assigned(lMensagem) and Assigned(lMensagem.GetValue('texto')) then
              begin
                if i > 0 then
                  Result.MensagemErro := Result.MensagemErro + '; ';

                Result.MensagemErro := Result.MensagemErro +
                  lMensagem.GetValue('texto').Value;
              end;
            end;
          end;
        end;
      end;

    finally
      lJsonResponse.Free;
    end;

  except
    on E: Exception do
    begin
      Result.MensagemErro := 'Erro ao processar resposta: ' + E.Message;
      Result.DetalhesErro := E.ClassName + ': ' + E.Message + #13#10 + AResponse;
    end;
  end;
end;

end.

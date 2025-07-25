object frmDARFViewer: TfrmDARFViewer
  Left = 0
  Top = 0
  Caption = 'Gerador DARF com Visualizador Integrado - CONSOLIDARGERARDARF51'
  ClientHeight = 700
  ClientWidth = 1200
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object pnlPrincipal: TPanel
    Left = 0
    Top = 0
    Width = 1200
    Height = 700
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 1196
    ExplicitHeight = 699
    object pnlEsquerdo: TPanel
      Left = 1
      Top = 1
      Width = 400
      Height = 698
      Align = alLeft
      TabOrder = 0
      ExplicitHeight = 697
      object gbParametros: TGroupBox
        Left = 8
        Top = 8
        Width = 384
        Height = 400
        Caption = ' Par'#226'metros para Gera'#231#227'o do DARF '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        object lblPeriodoApuracao: TLabel
          Left = 16
          Top = 32
          Width = 95
          Height = 13
          Caption = 'Per'#237'odo Apura'#231#227'o:*'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblDataVencimento: TLabel
          Left = 200
          Top = 32
          Width = 91
          Height = 13
          Caption = 'Data Vencimento:*'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblCodigoReceita: TLabel
          Left = 16
          Top = 80
          Width = 82
          Height = 13
          Caption = 'C'#243'digo Receita:*'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblValorPrincipal: TLabel
          Left = 16
          Top = 128
          Width = 76
          Height = 13
          Caption = 'Valor Principal:*'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblValorMulta: TLabel
          Left = 200
          Top = 128
          Width = 63
          Height = 13
          Caption = 'Valor Multa:*'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblValorJuros: TLabel
          Left = 16
          Top = 176
          Width = 63
          Height = 13
          Caption = 'Valor Juros:*'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblValorTotal: TLabel
          Left = 200
          Top = 176
          Width = 61
          Height = 13
          Caption = 'Valor Total:*'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblObservacao: TLabel
          Left = 16
          Top = 224
          Width = 62
          Height = 13
          Caption = 'Observa'#231#227'o:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object edtPeriodoApuracao: TMaskEdit
          Left = 16
          Top = 48
          Width = 160
          Height = 21
          EditMask = '00/0000;1;_'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 7
          ParentFont = False
          TabOrder = 0
          Text = '  /    '
        end
        object dtpVencimento: TDateTimePicker
          Left = 200
          Top = 48
          Width = 160
          Height = 21
          Date = 45592.000000000000000000
          Time = 0.523784062497725200
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
        object edtCodigoReceita: TEdit
          Left = 16
          Top = 96
          Width = 160
          Height = 21
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 10
          ParentFont = False
          TabOrder = 2
        end
        object edtValorPrincipal: TEdit
          Left = 16
          Top = 144
          Width = 160
          Height = 21
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          OnKeyPress = edtValorKeyPress
        end
        object edtValorMulta: TEdit
          Left = 200
          Top = 144
          Width = 160
          Height = 21
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 4
          OnKeyPress = edtValorKeyPress
        end
        object edtValorJuros: TEdit
          Left = 16
          Top = 192
          Width = 160
          Height = 21
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 5
          OnKeyPress = edtValorKeyPress
        end
        object edtValorTotal: TEdit
          Left = 200
          Top = 192
          Width = 160
          Height = 21
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 6
          OnKeyPress = edtValorKeyPress
        end
        object memoObservacao: TMemo
          Left = 16
          Top = 240
          Width = 344
          Height = 89
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 500
          ParentFont = False
          ScrollBars = ssVertical
          TabOrder = 7
        end
        object btnGerarDARF: TButton
          Left = 16
          Top = 344
          Width = 120
          Height = 40
          Caption = 'Gerar DARF'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 8
          OnClick = btnGerarDARFClick
        end
        object btnLimpar: TButton
          Left = 144
          Top = 344
          Width = 100
          Height = 40
          Caption = 'Limpar'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 9
          OnClick = btnLimparClick
        end
        object btnAbrirExterno: TButton
          Left = 252
          Top = 344
          Width = 108
          Height = 40
          Caption = 'Abrir Externo'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 10
          OnClick = btnAbrirExternoClick
        end
      end
      object gbStatus: TGroupBox
        Left = 8
        Top = 416
        Width = 384
        Height = 120
        Caption = ' Status e Informa'#231#245'es '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        object pnlStatus: TPanel
          Left = 8
          Top = 24
          Width = 368
          Height = 33
          BevelOuter = bvLowered
          Color = clGray
          ParentBackground = False
          TabOrder = 0
          object lblStatus: TLabel
            Left = 8
            Top = 8
            Width = 134
            Height = 13
            Caption = 'Pronto para gerar DARF'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWhite
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
        object memoInfo: TMemo
          Left = 8
          Top = 64
          Width = 368
          Height = 48
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 1
        end
      end
      object gbOpcoes: TGroupBox
        Left = 8
        Top = 544
        Width = 384
        Height = 145
        Caption = ' Op'#231#245'es de Visualiza'#231#227'o '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        object lblTamanhoPDF: TLabel
          Left = 16
          Top = 112
          Width = 109
          Height = 13
          Caption = 'Tamanho PDF: 0 bytes'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object rbVisualizadorInterno: TRadioButton
          Left = 16
          Top = 24
          Width = 200
          Height = 17
          Caption = 'Visualizador Interno (WebBrowser)'
          Checked = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          TabStop = True
        end
        object rbVisualizadorExterno: TRadioButton
          Left = 16
          Top = 48
          Width = 200
          Height = 17
          Caption = 'Visualizador Externo (Padr'#227'o Sistema)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
        object btnSalvarComo: TButton
          Left = 16
          Top = 80
          Width = 120
          Height = 25
          Caption = 'Salvar Como...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = btnSalvarComoClick
        end
        object btnLimparViewer: TButton
          Left = 144
          Top = 80
          Width = 100
          Height = 25
          Caption = 'Limpar Viewer'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          OnClick = btnLimparViewerClick
        end
      end
    end
    object pnlDireito: TPanel
      Left = 401
      Top = 1
      Width = 798
      Height = 698
      Align = alClient
      TabOrder = 1
      ExplicitWidth = 794
      ExplicitHeight = 697
      object gbVisualizador: TGroupBox
        Left = 1
        Top = 1
        Width = 796
        Height = 696
        Align = alClient
        Caption = ' Visualizador de PDF '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        ExplicitWidth = 792
        ExplicitHeight = 695
        object pnlViewer: TPanel
          Left = 2
          Top = 15
          Width = 792
          Height = 679
          Align = alClient
          BevelInner = bvLowered
          TabOrder = 0
          ExplicitWidth = 788
          ExplicitHeight = 678
          object lblMensagemViewer: TLabel
            Left = 2
            Top = 2
            Width = 788
            Height = 675
            Align = alClient
            Alignment = taCenter
            Caption = 
              'Nenhum PDF carregado.'#13#10#13#10'Preencha os campos '#224' esquerda e clique ' +
              'em "Gerar DARF"'#13#10'para visualizar o PDF gerado aqui.'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clGray
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            Layout = tlCenter
            WordWrap = True
            ExplicitWidth = 337
            ExplicitHeight = 64
          end
        end
      end
    end
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'pdf'
    Filter = 'Arquivos PDF|*.pdf|Todos os arquivos|*.*'
    Title = 'Salvar PDF como...'
    Left = 320
    Top = 600
  end
end

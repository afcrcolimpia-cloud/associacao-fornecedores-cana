import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/models.dart';
import 'custo_operacional_service.dart';
import 'dados_custo_operacional.dart';

/// Classe para análise e relatórios de cenários de custo operacional
class CustoOperacionalAnalise {
  static double _calcularReceitaPorHectare(CustoOperacionalCenario cenario) {
    return cenario.produtividade *
        cenario.atr.toDouble() *
        (cenario.precoAtr ?? 0.0);
  }

  /// Calcula o custo anualizado R$/ha considerando amortização da formação.
  /// Derivado do R$/t correto (preço - margem) × produtividade.
  static double _custoAnualizadoRHa(CustoOperacionalCenario cenario) {
    final precoRT = cenario.atr.toDouble() * (cenario.precoAtr ?? 0.0);
    final margemRT = cenario.margemLucroPorTonelada ?? 0.0;
    final custoRT = precoRT - margemRT;
    return custoRT * cenario.produtividade;
  }

  static double _calcularMargemPorTonelada(CustoOperacionalCenario cenario) {
    if (cenario.margemLucroPorTonelada != null) {
      return cenario.margemLucroPorTonelada!;
    }
    final produtividade = cenario.produtividade;
    if (produtividade <= 0) return 0.0;
    final custoAnualizado = _custoAnualizadoRHa(cenario);
    final receitaPorHectare = _calcularReceitaPorHectare(cenario);
    return (receitaPorHectare - custoAnualizado) / produtividade;
  }
  /// Matriz de sensibilidade - Preço vs Produtividade
  static MatrizSensibilidade gerarMatrizSensibilidade(
    CustoOperacionalCenario cenario,
  ) {
    final custoAnualizado = _custoAnualizadoRHa(cenario);
    final precoAtrBase = cenario.precoAtr ?? 0.0;
    final produtividadeBase = cenario.produtividade;
    final atr = cenario.atr.toDouble();

    final variacoes = [-0.20, -0.15, -0.10, -0.05, 0, 0.05, 0.10, 0.15, 0.20];
    final matriz = <List<double>>[];
    final precosVariados = <double>[];
    final produtividadesVariadas = <double>[];

    for (var v1 in variacoes) {
      precosVariados.add(precoAtrBase * (1 + v1));
    }

    for (var v2 in variacoes) {
      produtividadesVariadas.add(produtividadeBase * (1 + v2));
    }

    for (var produtividade in produtividadesVariadas) {
      final linha = <double>[];
      for (var preco in precosVariados) {
        final receita = produtividade * atr * preco;
        final margem = receita > 0 ? (receita - custoAnualizado) / produtividade : 0.0;
        linha.add(margem);
      }
      matriz.add(linha);
    }

    return MatrizSensibilidade(
      matriz: matriz,
      precosVariados: precosVariados,
      produtividadesVariadas: produtividadesVariadas,
      produtividadeBase: produtividadeBase,
      precoBase: precoAtrBase,
    );
  }

  /// Projeção financeira ao longo de múltiplos períodos
  static List<ProjecaoFinanceira> gerarProjecaoFinanceira(
    CustoOperacionalCenario cenario,
    int periodos,
  ) {
    final projecoes = <ProjecaoFinanceira>[];
    final custoAnualizado = _custoAnualizadoRHa(cenario);
    final receita = cenario.produtividade *
        cenario.atr.toDouble() *
        (cenario.precoAtr ?? 0.0);

    for (int i = 1; i <= periodos; i++) {
      final receitaAcumulada = receita * i;
      final custoAcumulado = custoAnualizado * i;
      final margem = receitaAcumulada - custoAcumulado;
      final margemPercentual =
          receita > 0 ? (margem / receitaAcumulada) * 100 : 0.0;

      projecoes.add(
        ProjecaoFinanceira(
          periodo: i,
          receita: receitaAcumulada,
          custo: custoAcumulado,
          margem: margem,
          margemPercentual: margemPercentual,
        ),
      );
    }
    return projecoes;
  }

  /// Dados para gráfico de comparação entre cenários
  static Map<String, dynamic> gerarDadosComparacao(
    List<CustoOperacionalCenario> cenarios,
  ) {
    final nomes = <String>[];
    final margens = <double>[];
    final producoes = <double>[];
    final custos = <double>[];

    for (var cenario in cenarios) {
      nomes.add(cenario.nomeCenario);
      margens.add(_calcularMargemPorTonelada(cenario));
      producoes.add(cenario.produtividade);
      custos.add(_custoAnualizadoRHa(cenario));
    }

    return {
      'nomes': nomes,
      'margens': margens,
      'producoes': producoes,
      'custos': custos,
    };
  }

  /// Análise de viabilidade do cenário
  static AnaliseViabilidade analisarViabilidade(
    CustoOperacionalCenario cenario,
  ) {
    final margemPorTonelada = _calcularMargemPorTonelada(cenario);
    final custoAnualizado = _custoAnualizadoRHa(cenario);
    final precoAtr = cenario.precoAtr ?? 0.0;
    final atr = cenario.atr.toDouble();

    final produtividadeMinima = custoAnualizado / (atr * precoAtr);
    final precoAtrMinimo = custoAnualizado / (atr * cenario.produtividade);

    final ehViavel = margemPorTonelada > 0;

    final margemProducao = cenario.produtividade > 0
        ? ((cenario.produtividade - produtividadeMinima) /
                cenario.produtividade) *
            100
        : 0.0;

    final margemPreco =
        precoAtr > 0 ? ((precoAtr - precoAtrMinimo) / precoAtr) * 100 : 0.0;

    final receita = _calcularReceitaPorHectare(cenario);

    return AnaliseViabilidade(
      ehViavel: ehViavel,
      margemPorTonelada: margemPorTonelada,
      produtividadeMinima: produtividadeMinima,
      precoAtrMinimo: precoAtrMinimo,
      margemProducao: margemProducao,
      margemPreco: margemPreco,
      receita: receita,
      custoTotal: custoAnualizado,
    );
  }

  /// Gerar relatório em PDF com detalhamento por estágio
  static Future<pw.Document> gerarRelatorioPDF(
    CustoOperacionalCenario cenario,
    Propriedade propriedade,
    List<CustoOperacionalCenario> cenarios,
  ) async {
    final pdf = pw.Document();
    final dataBr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final analise = analisarViabilidade(cenario);
    final estagios = DadosCustoOperacional.obterEstagios();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Text(
            'Relatório de Custo Operacional',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Propriedade: ${propriedade.nome}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.Text(
            'Cenário: ${cenario.nomeCenario}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.Text(
            'Emitido em: $dataBr',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Resumo Executivo',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              _buildPdfTableRow('Métrica', 'Valor'),
              _buildPdfTableRow(
                'Produtividade',
                '${cenario.produtividade.toStringAsFixed(2)} t/ha',
              ),
              _buildPdfTableRow('ATR', '${cenario.atr} kg/t'),
              _buildPdfTableRow(
                'Preço ATR',
                'R\$ ${(cenario.precoAtr ?? 0).toStringAsFixed(4)}/kg',
              ),
              _buildPdfTableRow(
                'Custo Anualizado',
                'R\$ ${analise.custoTotal.toStringAsFixed(2)}/ha',
              ),
              _buildPdfTableRow(
                'Receita Total',
                'R\$ ${analise.receita.toStringAsFixed(2)}/ha',
              ),
              _buildPdfTableRow(
                'Margem/Tonelada',
                'R\$ ${analise.margemPorTonelada.toStringAsFixed(2)}/t',
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Análise de Viabilidade',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              _buildPdfTableRow('Indicador', 'Valor'),
              _buildPdfTableRow('Viável', analise.ehViavel ? 'SIM' : 'NÃO'),
              _buildPdfTableRow(
                'Margem de Segurança (Prod.)',
                '${analise.margemProducao.toStringAsFixed(2)}%',
              ),
              _buildPdfTableRow(
                'Margem de Segurança (Preço)',
                '${analise.margemPreco.toStringAsFixed(2)}%',
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Detalhamento por Estágio (AFCRC)',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          ..._buildDetalhamentoEstagios(estagios),
        ],
      ),
    );

    return pdf;
  }

  static List<pw.Widget> _buildDetalhamentoEstagios(
    List<EstagioCustos> estagios,
  ) {
    final widgets = <pw.Widget>[];
    for (final estagio in estagios) {
      widgets.add(_buildEstagioDetalhado(estagio));
      widgets.add(pw.SizedBox(height: 16));
    }
    return widgets;
  }

  static pw.Widget _buildEstagioDetalhado(EstagioCustos estagio) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '${estagio.titulo} - Total R\$ ${estagio.total.toStringAsFixed(2)}/ha',
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        if (estagio.obs.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2, bottom: 6),
            child: pw.Text(
              estagio.obs,
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
            ),
          ),
        pw.Table(
          border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey400),
          columnWidths: {
            0: const pw.FlexColumnWidth(2.2),
            1: const pw.FlexColumnWidth(1.8),
            2: const pw.FlexColumnWidth(1.8),
            3: const pw.FlexColumnWidth(1.0),
            4: const pw.FlexColumnWidth(1.6),
            5: const pw.FlexColumnWidth(1.0),
            6: const pw.FlexColumnWidth(1.0),
          },
          children: [
            _buildEstagioHeaderRow(),
            ...estagio.operacoes.map(_buildEstagioRow),
          ],
        ),
      ],
    );
  }

  static pw.TableRow _buildEstagioHeaderRow() {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: [
        _cell('Operação', bold: true),
        _cell('Máquina', bold: true),
        _cell('Implemento', bold: true),
        _cell('Op R\$/ha', bold: true),
        _cell('Insumo', bold: true),
        _cell('Insumo R\$/ha', bold: true),
        _cell('Total R\$/ha', bold: true),
      ],
    );
  }

  static pw.TableRow _buildEstagioRow(Operacao op) {
    return pw.TableRow(
      children: [
        _cell(op.operacao),
        _cell(op.maquina),
        _cell(op.implemento),
        _cell(_fmt(op.operRHa, dec: 4), alignRight: true),
        _cell(op.insumo ?? '-'),
        _cell(_fmt(op.insumoRHa, dec: 4), alignRight: true),
        _cell(_fmt(op.total, dec: 2), alignRight: true),
      ],
    );
  }

  static pw.Widget _cell(
    String text, {
    bool bold = false,
    bool alignRight = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 7,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
      ),
    );
  }

  static String _fmt(double? value, {int dec = 2}) {
    if (value == null) return '-';
    return value.toStringAsFixed(dec);
  }

  static pw.TableRow _buildPdfTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }
}

/// Classe para representar a matriz de sensibilidade
class MatrizSensibilidade {
  final List<List<double>> matriz;
  final List<double> precosVariados;
  final List<double> produtividadesVariadas;
  final double produtividadeBase;
  final double precoBase;

  MatrizSensibilidade({
    required this.matriz,
    required this.precosVariados,
    required this.produtividadesVariadas,
    required this.produtividadeBase,
    required this.precoBase,
  });
}

/// Classe para representar a projeção financeira
class ProjecaoFinanceira {
  final int periodo;
  final double receita;
  final double custo;
  final double margem;
  final double margemPercentual;

  ProjecaoFinanceira({
    required this.periodo,
    required this.receita,
    required this.custo,
    required this.margem,
    required this.margemPercentual,
  });
}

/// Classe para representar a análise de viabilidade
class AnaliseViabilidade {
  final bool ehViavel;
  final double margemPorTonelada;
  final double produtividadeMinima;
  final double precoAtrMinimo;
  final double margemProducao;
  final double margemPreco;
  final double receita;
  final double custoTotal;

  AnaliseViabilidade({
    required this.ehViavel,
    required this.margemPorTonelada,
    required this.produtividadeMinima,
    required this.precoAtrMinimo,
    required this.margemProducao,
    required this.margemPreco,
    required this.receita,
    required this.custoTotal,
  });
}



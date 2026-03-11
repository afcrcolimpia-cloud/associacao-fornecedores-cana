import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/models.dart';
import '../variedade_service.dart';
import 'pdf_cabecalho.dart';

/// Gerador de PDF para o Censo Varietal
class PdfCensoVarietal {
  static const _verde = PdfColor.fromInt(0xFF2E7D32);

  static Future<Uint8List> gerar({
    required ContextoPropriedade contexto,
    required List<Talhao> talhoes,
    required Map<String, Variedade> variedadeMap,
  }) async {
    final pdf = pw.Document();
    final font = pw.Font.courier();
    final fontBold = pw.Font.courierBold();
    final variedadeService = VariedadeService();
    final anoAtual = DateTime.now().year;
    final areaTotalPropriedade = contexto.propriedade.areaHa ?? 0;

    // Logo
    final logoBytes = await rootBundle.load('assets/logo/logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    // Agrupar talhões por variedade
    final agrupado = <String, List<Talhao>>{};
    for (final t in talhoes) {
      if (t.variedade != null && t.variedade!.isNotEmpty) {
        agrupado.putIfAbsent(t.variedade!, () => []).add(t);
      }
    }

    // Montar lista de resumos
    final resumos = <_ResumoVarietalPdf>[];
    double areaPlantadaTotal = 0;

    for (final entry in agrupado.entries) {
      final variedadeId = entry.key;
      final talhoesVar = entry.value;
      final area = talhoesVar.fold<double>(0, (s, t) => s + (t.areaHa ?? 0));
      areaPlantadaTotal += area;

      final anosPlantio = talhoesVar
          .where((t) => t.anoPlantio != null)
          .map((t) => t.anoPlantio!)
          .toList();
      final anoMaisAntigo = anosPlantio.isNotEmpty
          ? anosPlantio.reduce((a, b) => a < b ? a : b)
          : anoAtual;

      final nomeVariedade = variedadeService.resolverCodigoSync(
        variedadeId,
        variedadeMap,
      );

      resumos.add(_ResumoVarietalPdf(
        nomeVariedade: nomeVariedade,
        areaHa: area,
        anoPlantio: anoMaisAntigo,
        qtdTalhoes: talhoesVar.length,
        percentual: areaTotalPropriedade > 0
            ? (area / areaTotalPropriedade) * 100
            : 0,
        idade: anoAtual - anoMaisAntigo,
      ));
    }

    // Ordenar por área decrescente
    resumos.sort((a, b) => b.areaHa.compareTo(a.areaHa));

    final ocupacao = areaTotalPropriedade > 0
        ? (areaPlantadaTotal / areaTotalPropriedade) * 100
        : 0.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        header: (context) => _cabecalho(contexto, font, fontBold, logoImage),
        footer: (context) => rodapePDF(context.pageNumber, context.pagesCount),
        build: (context) => [
          _cardsResumo(
            font, fontBold,
            totalVariedades: resumos.length,
            areaPlantada: areaPlantadaTotal,
            ocupacao: ocupacao,
          ),
          pw.SizedBox(height: 16),
          _tabelaCenso(resumos, font, fontBold,
            areaPlantadaTotal: areaPlantadaTotal,
            ocupacao: ocupacao,
          ),
          pw.SizedBox(height: 16),
          _detalhamentoTalhoes(
            talhoes, variedadeService, variedadeMap, font, fontBold,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _cabecalho(
    ContextoPropriedade ctx,
    pw.Font font,
    pw.Font bold,
    pw.MemoryImage logo,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          width: 70,
          height: 70,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _verde, width: 1.5),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          alignment: pw.Alignment.center,
          child: pw.Image(logo, width: 70, height: 70, fit: pw.BoxFit.contain),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Associação dos Fornecedores de',
          style: pw.TextStyle(font: bold, fontSize: 9, color: _verde),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'Cana da Região de Catanduva',
          style: pw.TextStyle(font: bold, fontSize: 9, color: _verde),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.8),
          columnWidths: {
            0: const pw.FixedColumnWidth(90),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FixedColumnWidth(80),
            3: const pw.FixedColumnWidth(60),
          },
          children: [
            pw.TableRow(children: [
              _hCell('DATA:', bold),
              _vCell(DateTime.now().toString().substring(0, 10), font),
              _hCell('PROPRIEDADE:', bold),
              _vCell(ctx.nomePropriedade, font),
            ]),
            pw.TableRow(children: [
              _hCell('F.A.:', bold),
              _vCell(ctx.numeroFA, font),
              _hCell('RELATÓRIO:', bold),
              _vCell('Censo Varietal', font),
            ]),
            pw.TableRow(children: [
              _hCell('PROPRIETÁRIO:', bold),
              _vCell(ctx.nomeProprietario, font),
              _hCell('MUNICÍPIO:', bold),
              _vCell(ctx.municipio, font),
            ]),
          ],
        ),
        pw.SizedBox(height: 14),
      ],
    );
  }

  static pw.Widget _hCell(String text, pw.Font bold) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: pw.Text(text, style: pw.TextStyle(font: bold, fontSize: 8)),
      );

  static pw.Widget _vCell(String text, pw.Font font) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 8)),
      );

  static pw.Widget _cardsResumo(
    pw.Font font,
    pw.Font bold, {
    required int totalVariedades,
    required double areaPlantada,
    required double ocupacao,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _verde, width: 1),
        borderRadius: pw.BorderRadius.circular(6),
        color: const PdfColor.fromInt(0xFFF1F8E9),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _kpiItem(bold, font, 'Total de Variedades', '$totalVariedades'),
          _kpiItem(bold, font, 'Área Plantada', '${areaPlantada.toStringAsFixed(1)} ha'),
          _kpiItem(bold, font, 'Ocupação', '${ocupacao.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  static pw.Widget _kpiItem(pw.Font bold, pw.Font font, String label, String valor) {
    return pw.Column(
      children: [
        pw.Text(valor, style: pw.TextStyle(font: bold, fontSize: 14, color: _verde)),
        pw.SizedBox(height: 2),
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: 8)),
      ],
    );
  }

  static pw.Widget _tabelaCenso(
    List<_ResumoVarietalPdf> resumos,
    pw.Font font,
    pw.Font bold, {
    required double areaPlantadaTotal,
    required double ocupacao,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DISTRIBUIÇÃO POR VARIEDADE',
          style: pw.TextStyle(font: bold, fontSize: 11, color: _verde),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.8),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FixedColumnWidth(55),
            2: const pw.FixedColumnWidth(55),
            3: const pw.FixedColumnWidth(65),
            4: const pw.FixedColumnWidth(50),
            5: const pw.FixedColumnWidth(45),
          },
          children: [
            // Cabeçalho
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _th('Variedade', bold),
                _th('Ano Plantio', bold),
                _th('Área (ha)', bold),
                _th('% Propriedade', bold),
                _th('Idade (anos)', bold),
                _th('Talhões', bold),
              ],
            ),
            // Dados
            ...resumos.map((r) => pw.TableRow(
                  children: [
                    _td(r.nomeVariedade, font),
                    _td('${r.anoPlantio}', font, align: pw.TextAlign.center),
                    _td(r.areaHa.toStringAsFixed(1), font, align: pw.TextAlign.right),
                    _td('${r.percentual.toStringAsFixed(1)}%', font, align: pw.TextAlign.right),
                    _td('${r.idade}', font, align: pw.TextAlign.center),
                    _td('${r.qtdTalhoes}', font, align: pw.TextAlign.center),
                  ],
                )),
            // Linha de totais
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _td('TOTAL', bold),
                _td('', font),
                _td(areaPlantadaTotal.toStringAsFixed(1), bold, align: pw.TextAlign.right),
                _td('${ocupacao.toStringAsFixed(1)}%', bold, align: pw.TextAlign.right),
                _td('', font),
                _td('${resumos.fold<int>(0, (s, r) => s + r.qtdTalhoes)}', bold, align: pw.TextAlign.center),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _th(String text, pw.Font bold) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: pw.Text(
          text,
          style: pw.TextStyle(font: bold, fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
      );

  static pw.Widget _td(String text, pw.Font font, {pw.TextAlign align = pw.TextAlign.left}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 8), textAlign: align),
      );

  /// Detalhamento: lista cada talhão com sua variedade (seção complementar)
  static pw.Widget _detalhamentoTalhoes(
    List<Talhao> talhoes,
    VariedadeService variedadeService,
    Map<String, Variedade> variedadeMap,
    pw.Font font,
    pw.Font bold,
  ) {
    // Filtrar apenas talhões com variedade
    final talhoesComVariedade = talhoes
        .where((t) => t.variedade != null && t.variedade!.isNotEmpty)
        .toList();

    if (talhoesComVariedade.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DETALHAMENTO POR TALHÃO',
          style: pw.TextStyle(font: bold, fontSize: 11, color: _verde),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.8),
          columnWidths: {
            0: const pw.FixedColumnWidth(50),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FixedColumnWidth(55),
            3: const pw.FixedColumnWidth(55),
            4: const pw.FixedColumnWidth(45),
            5: const pw.FixedColumnWidth(55),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _th('Talhão', bold),
                _th('Variedade', bold),
                _th('Área (ha)', bold),
                _th('Ano Plantio', bold),
                _th('Corte', bold),
                _th('Tipo', bold),
              ],
            ),
            ...talhoesComVariedade.map((t) => pw.TableRow(
                  children: [
                    _td(t.numeroTalhao, font, align: pw.TextAlign.center),
                    _td(
                      variedadeService.resolverCodigoSync(t.variedade, variedadeMap),
                      font,
                    ),
                    _td(
                      t.areaHa != null ? t.areaHa!.toStringAsFixed(1) : '-',
                      font,
                      align: pw.TextAlign.right,
                    ),
                    _td(
                      t.anoPlantio != null ? '${t.anoPlantio}' : '-',
                      font,
                      align: pw.TextAlign.center,
                    ),
                    _td(
                      t.corte != null ? '${t.corte}º' : '-',
                      font,
                      align: pw.TextAlign.center,
                    ),
                    _td(
                      t.isReforma ? 'Reforma' : 'Produção',
                      font,
                      align: pw.TextAlign.center,
                    ),
                  ],
                )),
          ],
        ),
      ],
    );
  }
}

/// Classe auxiliar interna para o PDF
class _ResumoVarietalPdf {
  final String nomeVariedade;
  final double areaHa;
  final int anoPlantio;
  final int qtdTalhoes;
  final double percentual;
  final int idade;

  const _ResumoVarietalPdf({
    required this.nomeVariedade,
    required this.areaHa,
    required this.anoPlantio,
    required this.qtdTalhoes,
    required this.percentual,
    required this.idade,
  });
}

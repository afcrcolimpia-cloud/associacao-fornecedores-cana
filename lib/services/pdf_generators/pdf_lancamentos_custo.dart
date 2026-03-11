import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../custo_operacional_repository.dart';

class PdfLancamentosCusto {
  static const _verde = PdfColor.fromInt(0xFF2E7D32);

  static Future<Uint8List> gerar({
    required String propriedadeNome,
    required int safra,
    required List<CategoriaModel> categorias,
    required Map<String, List<LancamentoModel>> lancamentos,
    required Map<String, double> totaisPorCategoria,
  }) async {
    final pdf = pw.Document();
    final font = pw.Font.courier();
    final fontBold = pw.Font.courierBold();

    final logoBytes = await rootBundle.load('assets/logo/logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        header: (context) => context.pageNumber == 1
            ? _cabecalho(propriedadeNome, safra, font, fontBold, logoImage)
            : pw.SizedBox(),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount} — AFCRC Catanduva',
            style: pw.TextStyle(font: font, fontSize: 7, color: PdfColors.grey600),
          ),
        ),
        build: (context) {
          final widgets = <pw.Widget>[];
          for (final cat in categorias) {
            final lista = lancamentos[cat.id] ?? [];
            final total = totaisPorCategoria[cat.id] ?? 0.0;
            widgets.add(_secaoCategoria(cat.nome, lista, total, font, fontBold));
            widgets.add(pw.SizedBox(height: 12));
          }
          widgets.add(_resumoGeral(categorias, totaisPorCategoria, font, fontBold));
          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _cabecalho(
      String propriedade, int safra, pw.Font font, pw.Font bold, pw.MemoryImage logo) {
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
            3: const pw.FixedColumnWidth(80),
          },
          children: [
            pw.TableRow(children: [
              _hCell('DATA:', bold),
              _vCell(DateTime.now().toString().substring(0, 10), font),
              _hCell('PROPRIEDADE:', bold),
              _vCell(propriedade, font),
            ]),
            pw.TableRow(children: [
              _hCell('SAFRA:', bold),
              _vCell('$safra', font),
              _hCell('RELATÓRIO:', bold),
              _vCell('Lançamentos de Custo', font),
            ]),
          ],
        ),
        pw.SizedBox(height: 14),
      ],
    );
  }

  static pw.Widget _secaoCategoria(
      String nomeCategoria, List<LancamentoModel> lista, double total, pw.Font font, pw.Font bold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          color: const PdfColor.fromInt(0xFFE8F5E9),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(nomeCategoria, style: pw.TextStyle(font: bold, fontSize: 9, color: _verde)),
              pw.Text('Total: R\$ ${total.toStringAsFixed(2)}/ha',
                  style: pw.TextStyle(font: bold, fontSize: 9, color: _verde)),
            ],
          ),
        ),
        if (lista.isEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text('Nenhum lançamento', style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey)),
          )
        else
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FixedColumnWidth(55),
              4: const pw.FixedColumnWidth(55),
              5: const pw.FixedColumnWidth(55),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _th('Operação', bold),
                  _th('Máquina', bold),
                  _th('Insumo', bold),
                  _th('Oper. R\$/ha', bold),
                  _th('Insumo R\$/ha', bold),
                  _th('Total R\$/ha', bold),
                ],
              ),
              ...lista.map(
                (l) => pw.TableRow(
                  children: [
                    _td(l.operacaoCustom ?? '-', font),
                    _td(l.maquinaCustom ?? '-', font),
                    _td(l.insumoCustom ?? '-', font),
                    _td((l.operacaoRha ?? 0).toStringAsFixed(2), font),
                    _td((l.insumoRha ?? 0).toStringAsFixed(2), font),
                    _td((l.custoTotalRha ?? 0).toStringAsFixed(2), font),
                  ],
                ),
              ),
            ],
          ),
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

  static pw.Widget _th(String text, pw.Font bold) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 3),
        child: pw.Text(text,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: bold, fontSize: 7)),
      );

  static pw.Widget _td(String text, pw.Font font) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 3),
        child: pw.Text(text,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: font, fontSize: 7)),
      );

  static pw.Widget _resumoGeral(
      List<CategoriaModel> categorias, Map<String, double> totais, pw.Font font, pw.Font bold) {
    final totalGeral = totais.values.fold<double>(0, (s, v) => s + v);

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _verde, width: 1),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('TOTAL CATEGORIAS', style: pw.TextStyle(font: bold, fontSize: 9)),
              pw.Text('${categorias.length}',
                  style: pw.TextStyle(font: bold, fontSize: 14, color: _verde)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('CUSTO TOTAL', style: pw.TextStyle(font: bold, fontSize: 9)),
              pw.Text('R\$ ${totalGeral.toStringAsFixed(2)}/ha',
                  style: pw.TextStyle(font: bold, fontSize: 14, color: _verde)),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/models.dart';
import '../variedade_service.dart';

class PdfTalhoes {
  static const _verde = PdfColor.fromInt(0xFF2E7D32);

  static Future<Uint8List> gerar({
    required Propriedade propriedade,
    required List<Talhao> talhoes,
  }) async {
    final pdf = pw.Document();
    final font = pw.Font.courier();
    final fontBold = pw.Font.courierBold();

    final logoBytes = await rootBundle.load('assets/logo/logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    // Resolver UUIDs de variedade para nomes legíveis
    final variedadeService = VariedadeService();
    final variedadeMap = await variedadeService.getVariedadeMap();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _cabecalho(propriedade, font, fontBold, logoImage),
            pw.SizedBox(height: 14),
            _tabela(talhoes, font, fontBold, variedadeService, variedadeMap),
            pw.SizedBox(height: 10),
            _resumo(talhoes, font, fontBold),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _cabecalho(
      Propriedade prop, pw.Font font, pw.Font bold, pw.MemoryImage logo) {
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
              _vCell(prop.nomePropriedade, font),
            ]),
            pw.TableRow(children: [
              _hCell('F.A.:', bold),
              _vCell(prop.numeroFA, font),
              _hCell('RELATÓRIO:', bold),
              _vCell('Talhões', font),
            ]),
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

  static pw.Widget _tabela(List<Talhao> talhoes, pw.Font font, pw.Font bold, VariedadeService variedadeService, Map<String, Variedade> variedadeMap) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.8),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(0.8),
        5: const pw.FlexColumnWidth(1),
        6: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _th('Talhão', bold),
            _th('Área\n(ha)', bold),
            _th('Área\n(alq)', bold),
            _th('Variedade', bold),
            _th('Corte', bold),
            _th('Ano\nPlantio', bold),
            _th('Tipo', bold),
          ],
        ),
        ...talhoes.map(
          (t) => pw.TableRow(
            children: [
              _td(t.numeroTalhao, font),
              _td(t.areaHa?.toStringAsFixed(2) ?? '-', font),
              _td(t.areaAlqueires?.toStringAsFixed(2) ?? '-', font),
              _td(variedadeService.resolverNomeSync(t.variedade, variedadeMap), font),
              _td(t.corte?.toString() ?? '-', font),
              _td(t.anoPlantio?.toString() ?? '-', font),
              _td(t.tipoTalhao == 'reforma' ? 'Reforma' : 'Produção', font),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _th(String text, pw.Font bold) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: pw.Text(text,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: bold, fontSize: 8)),
      );

  static pw.Widget _td(String text, pw.Font font) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: pw.Text(text,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: font, fontSize: 8)),
      );

  static pw.Widget _resumo(List<Talhao> talhoes, pw.Font font, pw.Font bold) {
    final areaTotal = talhoes.fold<double>(0, (s, t) => s + (t.areaHa ?? 0));
    final producao = talhoes.where((t) => t.tipoTalhao != 'reforma').length;
    final reforma = talhoes.where((t) => t.tipoTalhao == 'reforma').length;

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
              pw.Text('TOTAL TALHÕES', style: pw.TextStyle(font: bold, fontSize: 9)),
              pw.Text('${talhoes.length}',
                  style: pw.TextStyle(font: bold, fontSize: 14, color: _verde)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('ÁREA TOTAL', style: pw.TextStyle(font: bold, fontSize: 9)),
              pw.Text('${areaTotal.toStringAsFixed(2)} ha',
                  style: pw.TextStyle(font: bold, fontSize: 14, color: _verde)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('PRODUÇÃO / REFORMA', style: pw.TextStyle(font: bold, fontSize: 9)),
              pw.Text('$producao / $reforma',
                  style: pw.TextStyle(font: bold, fontSize: 14, color: _verde)),
            ],
          ),
        ],
      ),
    );
  }
}

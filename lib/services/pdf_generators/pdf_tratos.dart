import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/models.dart';

class PdfTratosCulturais {
  static const _verde = PdfColor.fromInt(0xFF2E7D32);

  static Future<Uint8List> gerar({
    required Propriedade propriedade,
    required List<TratosCulturais> tratos,
    required int anoSafra,
  }) async {
    final pdf = pw.Document();
    final font = pw.Font.courier();
    final fontBold = pw.Font.courierBold();

    // Carregar logo
    final logoBytes = await rootBundle.load('assets/logo/logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _cabecalho(propriedade, font, fontBold, logoImage, anoSafra),
            pw.SizedBox(height: 14),
            _tabela(tratos, font, fontBold),
            pw.SizedBox(height: 10),
            _resumo(tratos, font, fontBold),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _cabecalho(
      Propriedade prop, pw.Font font, pw.Font bold, pw.MemoryImage logo, int ano) {
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
              _hCell('ANO SAFRA:', bold),
              _vCell(ano.toString(), font),
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

  static pw.Widget _tabela(List<TratosCulturais> tratos, pw.Font font, pw.Font bold) {
    const maxLinhas = 12;
    final todasLinhas = List<TratosCulturais?>.from(tratos);
    while (todasLinhas.length < maxLinhas) {
      todasLinhas.add(null);
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.8),
      columnWidths: {
        0: const pw.FixedColumnWidth(50),
        1: const pw.FixedColumnWidth(50),
        2: const pw.FixedColumnWidth(50),
        3: const pw.FixedColumnWidth(50),
        4: const pw.FixedColumnWidth(50),
        5: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _th('Talhão', bold),
            _th('Adubos', bold),
            _th('Herbicidas', bold),
            _th('Inseticidas', bold),
            _th('Data Aplic.', bold),
            _th('Observações', bold),
          ],
        ),
        ...todasLinhas.map(
          (t) => pw.TableRow(
            children: [
              _td(t?.talhaoId ?? '', font),
              _td('${t?.adubos?.length ?? 0}', font),
              _td('${t?.herbicidas?.length ?? 0}', font),
              _td('${t?.inseticidas?.length ?? 0}', font),
              _td(t?.dataAplicacao?.toString().substring(0, 10) ?? '', font),
              _td(t?.observacoes ?? '', font),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _th(String text, pw.Font bold) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 3),
        child: pw.Text(text,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: bold, fontSize: 8)),
      );

  static pw.Widget _td(String text, pw.Font font) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 3),
        child: pw.Text(text,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: font, fontSize: 9)),
      );

  static pw.Widget _resumo(List<TratosCulturais> tratos, pw.Font font, pw.Font bold) {
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
              pw.Text('TOTAL TRATOS', style: pw.TextStyle(font: bold, fontSize: 9)),
              pw.Text('${tratos.length}',
                  style: pw.TextStyle(font: bold, fontSize: 14, color: _verde)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('COM APLICAÇÃO', style: pw.TextStyle(font: bold, fontSize: 9)),
              pw.Text('${tratos.where((t) => t.dataAplicacao != null).length}',
                  style: pw.TextStyle(font: bold, fontSize: 14, color: _verde)),
            ],
          ),
        ],
      ),
    );
  }
}

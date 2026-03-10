import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// ---------------------------------------------
// MODELO DE DADOS
// ---------------------------------------------

class BrocaLinha {
  final int cana;
  final int? entrenosTotais;
  final int? entrenosBrocados;

  const BrocaLinha({
    required this.cana,
    this.entrenosTotais,
    this.entrenosBrocados,
  });
}

enum NivelInfestacao { aceitavel, baixo, medio, alto, inaceitavel }

extension NivelInfestacaoExt on NivelInfestacao {
  String get label {
    switch (this) {
      case NivelInfestacao.aceitavel:
        return 'ACEITÁVEL';
      case NivelInfestacao.baixo:
        return 'BAIXO';
      case NivelInfestacao.medio:
        return 'MÉDIO';
      case NivelInfestacao.alto:
        return 'ALTO';
      case NivelInfestacao.inaceitavel:
        return 'INACEITÁVEL';
    }
  }

  PdfColor get cor {
    switch (this) {
      case NivelInfestacao.aceitavel:
        return const PdfColor.fromInt(0xFF4CAF50);
      case NivelInfestacao.baixo:
        return const PdfColor.fromInt(0xFFFFEB3B);
      case NivelInfestacao.medio:
        return const PdfColor.fromInt(0xFFFF9800);
      case NivelInfestacao.alto:
        return const PdfColor.fromInt(0xFFF44336);
      case NivelInfestacao.inaceitavel:
        return const PdfColor.fromInt(0xFF212121);
    }
  }

  static NivelInfestacao fromPercentual(double pct) {
    if (pct <= 1.0) return NivelInfestacao.aceitavel;
    if (pct <= 3.0) return NivelInfestacao.baixo;
    if (pct <= 6.0) return NivelInfestacao.medio;
    if (pct <= 9.0) return NivelInfestacao.alto;
    return NivelInfestacao.inaceitavel;
  }
}

class BrocaData {
  final String nome;
  final String propriedade;
  final String fa;
  final String talhao;
  final String bloco;
  final String data;
  final String variedade;
  final String nCorte;
  final String nAvaliacao;
  final String tecnico;
  final bool avaliacaoFinal;
  final List<BrocaLinha> linhas;

  const BrocaData({
    required this.nome,
    required this.propriedade,
    required this.fa,
    required this.talhao,
    required this.bloco,
    required this.data,
    required this.variedade,
    required this.nCorte,
    required this.nAvaliacao,
    required this.tecnico,
    required this.avaliacaoFinal,
    required this.linhas,
  });

  int get totalEntrenosTotais =>
      linhas.fold(0, (s, l) => s + (l.entrenosTotais ?? 0));

  int get totalEntrenosBrocados =>
      linhas.fold(0, (s, l) => s + (l.entrenosBrocados ?? 0));

  double get indiceIntensidade => totalEntrenosTotais == 0
      ? 0
      : (totalEntrenosBrocados / totalEntrenosTotais) * 100;

  NivelInfestacao get nivel =>
      NivelInfestacaoExt.fromPercentual(indiceIntensidade);
}

// ---------------------------------------------
// GERADOR DE PDF
// ---------------------------------------------

class PdfBroca {
  static const _verde = PdfColor.fromInt(0xFF2E7D32);

  static Future<Uint8List> gerar(BrocaData dados) async {
    final pdf = pw.Document();
    final font = pw.Font.courier();
    final fontBold = pw.Font.courierBold();

    // Carregar logo do asset
    final logoBytes = await rootBundle.load('assets/logo/logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _cabecalho(fontBold, logoImage),
            pw.SizedBox(height: 12),
            _infoBox(dados, font, fontBold),
            pw.SizedBox(height: 10),
            _avaliacaoRow(dados, font, fontBold),
            pw.SizedBox(height: 10),
            _tabela(dados, font, fontBold),
            pw.SizedBox(height: 10),
            _nivelInfestacao(dados, font, fontBold),
            pw.SizedBox(height: 8),
            _legenda(font, fontBold),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _cabecalho(pw.Font bold, pw.MemoryImage logo) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // Logo centralizado
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
        // Nome da associação centralizado
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
        // Título centralizado
        pw.Text(
          'ÍNDICE DE INTENSIDADE DE INFESTAÇÃO',
          style: pw.TextStyle(font: bold, fontSize: 14),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  static pw.Widget _infoBox(BrocaData d, pw.Font font, pw.Font bold) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.8),
      children: [
        pw.TableRow(children: [
          _cell('NOME:', d.nome, font, bold),
          _cell('DATA:', d.data, font, bold),
        ]),
        pw.TableRow(children: [
          _cell('PROPRIEDADE:', d.propriedade, font, bold),
          _cell('VARIEDADE:', d.variedade, font, bold),
        ]),
        pw.TableRow(children: [
          _cell('F.A:', d.fa, font, bold),
          _cell('Nº DE CORTE', d.nCorte, font, bold),
        ]),
        pw.TableRow(children: [
          _cell('TALHÃO:', d.talhao, font, bold),
          _cell('Nº AVALIAÇÃO:', d.nAvaliacao, font, bold),
        ]),
        pw.TableRow(children: [
          _cell('BLOCO:', d.bloco, font, bold),
          _cell('TÉCNICO:', d.tecnico, font, bold),
        ]),
      ],
    );
  }

  static pw.Widget _cell(
      String label, String value, pw.Font font, pw.Font bold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: pw.Row(
        children: [
          pw.Text(label, style: pw.TextStyle(font: bold, fontSize: 9)),
          pw.SizedBox(width: 4),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _avaliacaoRow(
      BrocaData d, pw.Font font, pw.Font bold) {
    return pw.Row(
      children: [
        pw.Text('AVALIAÇÃO FINAL',
            style: pw.TextStyle(font: bold, fontSize: 10)),
        pw.SizedBox(width: 8),
        pw.Container(
          width: 24,
          height: 16,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black),
          ),
          alignment: pw.Alignment.center,
          child: d.avaliacaoFinal
              ? pw.Text('X', style: pw.TextStyle(font: bold, fontSize: 10))
              : null,
        ),
        pw.SizedBox(width: 24),
        pw.Text('AVALIAÇÃO PARCIAL',
            style: pw.TextStyle(font: bold, fontSize: 10)),
        pw.SizedBox(width: 8),
        pw.Container(
          width: 24,
          height: 16,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black),
          ),
          alignment: pw.Alignment.center,
          child: !d.avaliacaoFinal
              ? pw.Text('X', style: pw.TextStyle(font: bold, fontSize: 10))
              : null,
        ),
      ],
    );
  }

  static pw.Widget _tabela(BrocaData d, pw.Font font, pw.Font bold) {
    const maxLinhas = 20;
    final todasLinhas = List<BrocaLinha?>.from(d.linhas);
    while (todasLinhas.length < maxLinhas) {
      todasLinhas.add(null);
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.8),
      columnWidths: {
        0: const pw.FixedColumnWidth(40),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _thCell('CANA', bold),
            _thCell('ENTRENÓS TOTAIS', bold),
            _thCell('ENTRENÓS BROCADOS', bold),
          ],
        ),
        ...todasLinhas.map(
          (l) => pw.TableRow(children: [
            _tdCell(l?.cana != null ? '${l!.cana}' : '', font),
            _tdCell(
                l?.entrenosTotais != null ? '${l!.entrenosTotais}' : '', font),
            _tdCell(l?.entrenosBrocados != null ? '${l!.entrenosBrocados}' : '',
                font),
          ]),
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _thCell('TOTAL:', bold),
            _thCell('${d.totalEntrenosTotais}', bold),
            _thCell('${d.totalEntrenosBrocados}', bold),
          ],
        ),
      ],
    );
  }

  static pw.Widget _thCell(String text, pw.Font bold) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        child: pw.Text(text,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: bold, fontSize: 9)),
      );

  static pw.Widget _tdCell(String text, pw.Font font) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        child: pw.Text(text,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: font, fontSize: 9)),
      );

  static pw.Widget _nivelInfestacao(
      BrocaData d, pw.Font font, pw.Font bold) {
    return pw.Row(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey600, width: 0.8),
          ),
          child: pw.Text('NIVEL DE INFESTAÇÃO',
              style: pw.TextStyle(font: bold, fontSize: 9)),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey600, width: 0.8),
          ),
          child: pw.Text(d.indiceIntensidade.toStringAsFixed(2),
              style: pw.TextStyle(font: bold, fontSize: 9)),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: pw.BoxDecoration(
            color: d.nivel.cor,
            border: pw.Border.all(color: PdfColors.grey600, width: 0.8),
          ),
          child: pw.Text(d.nivel.label,
              style: pw.TextStyle(
                  font: bold, fontSize: 9, color: PdfColors.black)),
        ),
      ],
    );
  }

  static pw.Widget _legenda(pw.Font font, pw.Font bold) {
    final itens = [
      ('ACEITÁVEL', '<= 1,0%', const PdfColor.fromInt(0xFF4CAF50)),
      ('BAIXO', '1,1% até 3%', const PdfColor.fromInt(0xFFFFEB3B)),
      ('MÉDIO', '3,1% até 6%', const PdfColor.fromInt(0xFFFF9800)),
      ('ALTO', '6,1% até 9%', const PdfColor.fromInt(0xFFF44336)),
      ('INACEITÁVEL', '>9%', const PdfColor.fromInt(0xFF212121)),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: itens.map((item) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 2),
          child: pw.Row(
            children: [
              pw.Container(
                width: 70,
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                color: item.$3,
                child: pw.Text(item.$1,
                    style: pw.TextStyle(
                        font: bold,
                        fontSize: 8,
                        color: item.$3 == const PdfColor.fromInt(0xFF212121)
                            ? PdfColors.white
                            : PdfColors.black)),
              ),
              pw.Container(
                width: 70,
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                        color: PdfColors.grey400, width: 0.5)),
                child: pw.Text(item.$2,
                    style: pw.TextStyle(font: font, fontSize: 8)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

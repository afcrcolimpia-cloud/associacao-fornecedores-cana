import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// ─────────────────────────────────────────────
// MODELO DE DADOS
// ─────────────────────────────────────────────

class BrocaCigarrinhaLinha {
  final String talhao;

  // Cigarrinha
  final int? cigarrinhaPontos;
  final int? espuma;
  final int? ninfa;
  final double? nm;

  // Broca
  final int? brocaPontos;
  final int? entrenosBrocados;
  final int? dano;
  final int? larvaFora;
  final int? larvaDentro;

  // Observação
  final String observacao;

  const BrocaCigarrinhaLinha({
    required this.talhao,
    this.cigarrinhaPontos,
    this.espuma,
    this.ninfa,
    this.nm,
    this.brocaPontos,
    this.entrenosBrocados,
    this.dano,
    this.larvaFora,
    this.larvaDentro,
    this.observacao = '',
  });
}

class BrocaCigarrinhaData {
  final String nome;
  final String propriedade;
  final String fa;
  final String id;
  final String data;
  final String tecnico;
  final List<BrocaCigarrinhaLinha> linhas;

  const BrocaCigarrinhaData({
    required this.nome,
    required this.propriedade,
    required this.fa,
    required this.id,
    required this.data,
    required this.tecnico,
    required this.linhas,
  });
}

// ─────────────────────────────────────────────
// GERADOR DE PDF
// ─────────────────────────────────────────────

class PdfBrocaCigarrinha {
  static const _verde = PdfColor.fromInt(0xFF2E7D32);

  static Future<Uint8List> gerar(BrocaCigarrinhaData dados) async {
    final pdf = pw.Document();
    final font = pw.Font.courier();
    final fontBold = pw.Font.courierBold();

    // Carregar logo do asset
    final logoBytes = await rootBundle.load('assets/logo/logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _cabecalho(dados, font, fontBold, logoImage),
            pw.SizedBox(height: 14),
            _tabela(dados, font, fontBold),
            pw.SizedBox(height: 10),
            _nivelControle(font, fontBold),
            pw.SizedBox(height: 10),
            _avaliacoes(font, fontBold),
            pw.SizedBox(height: 6),
            _tecnico(dados.tecnico, font, fontBold),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _cabecalho(
      BrocaCigarrinhaData d, pw.Font font, pw.Font bold, pw.MemoryImage logo) {
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
        // Tabela de dados
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.8),
          columnWidths: {
            0: const pw.FixedColumnWidth(90),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FixedColumnWidth(40),
            3: const pw.FixedColumnWidth(60),
          },
          children: [
            pw.TableRow(children: [
              _hCell('DATA :', bold),
              _vCell(d.data, font),
              _hCell('F.A.:', bold),
              _vCell(d.fa, font),
            ]),
            pw.TableRow(children: [
              _hCell('NOME :', bold),
              _vCell(d.nome, font),
              pw.SizedBox(),
              pw.SizedBox(),
            ]),
            pw.TableRow(children: [
              _hCell('PROPRIEDADE:', bold),
              _vCell(d.propriedade, font),
              pw.SizedBox(),
              pw.SizedBox(),
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

  static pw.Widget _tabela(
      BrocaCigarrinhaData d, pw.Font font, pw.Font bold) {
    const maxLinhas = 12;
    final todasLinhas = List<BrocaCigarrinhaLinha?>.from(d.linhas);
    while (todasLinhas.length < maxLinhas) {
      todasLinhas.add(null);
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.8),
      columnWidths: {
        0: const pw.FixedColumnWidth(38),
        1: const pw.FixedColumnWidth(36),
        2: const pw.FixedColumnWidth(36),
        3: const pw.FixedColumnWidth(36),
        4: const pw.FixedColumnWidth(30),
        5: const pw.FixedColumnWidth(36),
        6: const pw.FixedColumnWidth(48),
        7: const pw.FixedColumnWidth(30),
        8: const pw.FixedColumnWidth(38),
        9: const pw.FixedColumnWidth(42),
        10: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _th('', bold),
            pw.Padding(
              padding: const pw.EdgeInsets.all(3),
              child: pw.Center(
                child: pw.Text('Cigarrinha',
                    style: pw.TextStyle(font: bold, fontSize: 8)),
              ),
            ),
            _th('', bold),
            _th('', bold),
            _th('', bold),
            pw.Padding(
              padding: const pw.EdgeInsets.all(3),
              child: pw.Center(
                child: pw.Text('Broca',
                    style: pw.TextStyle(font: bold, fontSize: 8)),
              ),
            ),
            _th('', bold),
            _th('', bold),
            _th('', bold),
            _th('', bold),
            pw.Padding(
              padding: const pw.EdgeInsets.all(3),
              child: pw.Center(
                child: pw.Text('Observações',
                    style: pw.TextStyle(font: bold, fontSize: 8)),
              ),
            ),
          ],
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _th('Talhão', bold),
            _th('Pontos', bold),
            _th('Espuma', bold),
            _th('Ninfa', bold),
            _th('n/m', bold),
            _th('Pontos', bold),
            _th('Entrenós\nbrocados', bold),
            _th('Dano', bold),
            _th('Larva\nfora', bold),
            _th('Larva\ndentro', bold),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              child: pw.Text('ID: ${d.id}',
                  style: pw.TextStyle(
                      font: bold, fontSize: 9, color: const PdfColor.fromInt(0xFF2E7D32))),
            ),
          ],
        ),
        ...todasLinhas.map(
          (l) => pw.TableRow(
            children: [
              _td(l?.talhao ?? '', font),
              _td(l?.cigarrinhaPontos != null ? '${l!.cigarrinhaPontos}' : '',
                  font),
              _td(l?.espuma != null ? '${l!.espuma}' : '', font),
              _td(l?.ninfa != null ? '${l!.ninfa}' : '', font),
              _td(l?.nm != null ? l!.nm!.toStringAsFixed(1) : '', font),
              _td(l?.brocaPontos != null ? '${l!.brocaPontos}' : '', font),
              _td(l?.entrenosBrocados != null ? '${l!.entrenosBrocados}' : '',
                  font),
              _td(l?.dano != null ? '${l!.dano}' : '', font),
              _td(l?.larvaFora != null ? '${l!.larvaFora}' : '', font),
              _td(l?.larvaDentro != null ? '${l!.larvaDentro}' : '', font),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                child: pw.Text(l?.observacao ?? '',
                    style: pw.TextStyle(font: font, fontSize: 8)),
              ),
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

  static pw.Widget _nivelControle(pw.Font font, pw.Font bold) =>
      pw.Container(
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
        ),
        child: pw.Text(
          'NÍVEL DE CONTROLE - 2 NINFAS POR METRO (n/m)',
          style: pw.TextStyle(font: bold, fontSize: 9),
        ),
      );

  static pw.Widget _avaliacoes(pw.Font font, pw.Font bold) =>
      pw.Container(
        width: double.infinity,
        height: 40,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
        ),
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text('AVALIAÇÕES :',
            style: pw.TextStyle(font: bold, fontSize: 9)),
      );

  static pw.Widget _tecnico(String tecnico, pw.Font font, pw.Font bold) =>
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text('TÉCNICO: ',
              style: pw.TextStyle(font: bold, fontSize: 9)),
          pw.Text(tecnico, style: pw.TextStyle(font: font, fontSize: 9)),
        ],
      );
}

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// ---------------------------------------------
// MODELO DE DADOS
// ---------------------------------------------

class SphenophorusLinha {
  final String talhao;
  final int pontos;
  final int larva;
  final int pupa;
  final int adulto;
  final int tocosAtacados;
  final int tocosSadios;

  const SphenophorusLinha({
    required this.talhao,
    required this.pontos,
    required this.larva,
    required this.pupa,
    required this.adulto,
    required this.tocosAtacados,
    required this.tocosSadios,
  });
}

class SphenophorusData {
  final String fornecedor;
  final String id;
  final String propriedade;
  final String fa;
  final String data;
  final String tecnico;
  final List<SphenophorusLinha> linhas;
  final String observacao;

  const SphenophorusData({
    required this.fornecedor,
    required this.id,
    required this.propriedade,
    required this.fa,
    required this.data,
    required this.tecnico,
    required this.linhas,
    this.observacao = '',
  });
}

// ---------------------------------------------
// GERADOR DE PDF
// ---------------------------------------------

class PdfSphenophorus {
  static const _verde = PdfColor.fromInt(0xFF2E7D32);

  static Future<Uint8List> gerar(SphenophorusData dados) async {
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
            _cabecalho(dados, fontBold, font, logoImage),
            pw.SizedBox(height: 10),
            _divisor(),
            pw.SizedBox(height: 16),
            _titulo('SPHENOPHORUS', fontBold),
            pw.SizedBox(height: 10),
            _tabela(dados.linhas, font, fontBold),
            pw.SizedBox(height: 16),
            _observacao(dados.observacao, font, fontBold),
            pw.Spacer(),
            _rodape(fontBold),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _cabecalho(
      SphenophorusData d, pw.Font bold, pw.Font regular, pw.MemoryImage logo) {
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
        // Nome da associação
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
        pw.SizedBox(height: 12),
        // Dados organizados em 3 colunas
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('FORNECEDOR: ${d.fornecedor}',
                    style: pw.TextStyle(font: regular, fontSize: 9)),
                pw.SizedBox(height: 2),
                pw.Text('ID: ${d.id}',
                    style: pw.TextStyle(font: bold, fontSize: 9, color: _verde)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('PROPRIEDADE: ${d.propriedade}',
                    style: pw.TextStyle(font: regular, fontSize: 9)),
                pw.SizedBox(height: 2),
                pw.Text('F.A.: ${d.fa}',
                    style: pw.TextStyle(font: regular, fontSize: 9)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('DATA: ${d.data}',
                    style: pw.TextStyle(font: regular, fontSize: 9)),
                pw.SizedBox(height: 2),
                pw.Text('TÉCNICO: ${d.tecnico}',
                    style: pw.TextStyle(font: regular, fontSize: 9)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _divisor() => pw.Container(
        height: 1,
        color: PdfColors.grey400,
      );

  static pw.Widget _titulo(String texto, pw.Font bold) => pw.Center(
        child: pw.Text(
          texto,
          style: pw.TextStyle(font: bold, fontSize: 14),
        ),
      );

  static pw.Widget _tabela(
      List<SphenophorusLinha> linhas, pw.Font font, pw.Font bold) {
    final headers = [
      'TALHÃO',
      'PONTOS',
      'LARVA',
      'PUPA',
      'ADULTO',
      'TOCOS\nATACADOS',
      'TOCOS\nSADIOS',
    ];

    const maxLinhas = 16;
    final todasLinhas = List<SphenophorusLinha?>.from(linhas);
    while (todasLinhas.length < maxLinhas) {
      todasLinhas.add(null);
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.8),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.2),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(1.3),
        6: const pw.FlexColumnWidth(1.3),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: headers
              .map(
                (h) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      vertical: 6, horizontal: 4),
                  child: pw.Text(h,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(font: bold, fontSize: 9)),
                ),
              )
              .toList(),
        ),
        ...todasLinhas.map((linha) {
          final cells = linha == null
              ? List.generate(7, (_) => '')
              : [
                  linha.talhao,
                  '${linha.pontos}',
                  '${linha.larva}',
                  '${linha.pupa}',
                  '${linha.adulto}',
                  '${linha.tocosAtacados}',
                  '${linha.tocosSadios}',
                ];

          return pw.TableRow(
            children: cells
                .map(
                  (c) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                        vertical: 7, horizontal: 4),
                    child: pw.Text(c,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(font: font, fontSize: 10)),
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }

  static pw.Widget _observacao(
      String obs, pw.Font font, pw.Font bold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('OBSERVAÇÃO :',
            style: pw.TextStyle(font: bold, fontSize: 10)),
        pw.SizedBox(height: 4),
        pw.Container(
          width: double.infinity,
          height: 40,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
          ),
          child: pw.Text(
            obs.isEmpty ? ' ' : obs,
            style: pw.TextStyle(font: font, fontSize: 10),
          ),
        ),
      ],
    );
  }

  static pw.Widget _rodape(pw.Font bold) => pw.Center(
        child: pw.Text(
          'ASSOCIAÇÃO DOS FORNECEDORES DE CANA DA REGIÃO DE CATANDUVA',
          style: pw.TextStyle(font: bold, fontSize: 8),
        ),
      );
}

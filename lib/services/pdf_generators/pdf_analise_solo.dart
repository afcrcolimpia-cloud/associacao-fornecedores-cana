import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/models.dart';

/// Gerador de PDF para Análise de Solo
class PdfAnaliseSolo {
  static const _verde = PdfColor.fromInt(0xFF2E7D32);

  static Future<Uint8List> gerar({
    required Propriedade propriedade,
    required List<AnaliseSolo> analises,
    List<Talhao>? talhoes,
  }) async {
    final pdf = pw.Document();
    final font = pw.Font.courier();
    final fontBold = pw.Font.courierBold();

    final logoBytes = await rootBundle.load('assets/logo/logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    // Mapa de talhões para resolver nomes
    final talhaoMap = <String, String>{};
    if (talhoes != null) {
      for (final t in talhoes) {
        talhaoMap[t.id] = t.nome;
      }
    }

    // Gerar páginas — uma por análise para ter espaço
    for (var i = 0; i < analises.length; i++) {
      final a = analises[i];
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _cabecalho(propriedade, font, fontBold, logoImage),
              pw.SizedBox(height: 10),
              _infoAnalise(a, talhaoMap, font, fontBold),
              pw.SizedBox(height: 10),
              _tabelaMacronutrientes(a, font, fontBold),
              pw.SizedBox(height: 8),
              _tabelaAcidezCTC(a, font, fontBold),
              pw.SizedBox(height: 8),
              _tabelaMicronutrientes(a, font, fontBold),
              pw.SizedBox(height: 8),
              _tabelaTextura(a, font, fontBold),
              if (a.observacoes != null && a.observacoes!.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                _observacoes(a.observacoes!, font, fontBold),
              ],
              pw.Spacer(),
              _rodape(font, i + 1, analises.length),
            ],
          ),
        ),
      );
    }

    // Se houver múltiplas análises, adicionar página resumo comparativo
    if (analises.length > 1) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _cabecalho(propriedade, font, fontBold, logoImage),
              pw.SizedBox(height: 10),
              pw.Text('Comparativo de Análises',
                  style: pw.TextStyle(font: fontBold, fontSize: 12, color: _verde)),
              pw.SizedBox(height: 8),
              _tabelaComparativa(analises, talhaoMap, font, fontBold),
              pw.Spacer(),
              _rodape(font, analises.length + 1, analises.length + 1),
            ],
          ),
        ),
      );
    }

    return pdf.save();
  }

  // ─── Cabeçalho ────────────────────────────────────────────────────────

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
              _vCell('Análise de Solo', font),
            ]),
          ],
        ),
      ],
    );
  }

  // ─── Info da Análise ──────────────────────────────────────────────────

  static pw.Widget _infoAnalise(
      AnaliseSolo a, Map<String, String> talhaoMap, pw.Font font, pw.Font bold) {
    final talhaoNome = a.talhaoId != null
        ? (talhaoMap[a.talhaoId] ?? 'Talhão')
        : 'Geral';

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _verde, width: 1),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Identificação da Amostra',
              style: pw.TextStyle(font: bold, fontSize: 10, color: _verde)),
          pw.SizedBox(height: 6),
          pw.Row(children: [
            pw.Expanded(child: _labelValor('Talhão', talhaoNome, font, bold)),
            pw.Expanded(child: _labelValor('Laboratório', a.laboratorio ?? '-', font, bold)),
            pw.Expanded(child: _labelValor('Nº Amostra', a.numeroAmostra ?? '-', font, bold)),
          ]),
          pw.SizedBox(height: 4),
          pw.Row(children: [
            pw.Expanded(child: _labelValor('Data Coleta', _fmtData(a.dataColeta), font, bold)),
            pw.Expanded(child: _labelValor('Data Resultado', _fmtData(a.dataResultado), font, bold)),
            pw.Expanded(child: _labelValor('Profundidade', '${a.profundidadeCm ?? "-"} cm', font, bold)),
          ]),
          pw.SizedBox(height: 4),
          pw.Row(children: [
            pw.Expanded(child: _labelValor('Cultura', a.cultura ?? '-', font, bold)),
            pw.Expanded(child: _labelValor('PRNT', '${_fmtNum(a.prnt)} %', font, bold)),
            pw.Expanded(child: _labelValor('Prod. Esperada', '${_fmtNum(a.produtividadeEsperada)} t/ha', font, bold)),
          ]),
        ],
      ),
    );
  }

  // ─── Tabela Macronutrientes ───────────────────────────────────────────

  static pw.Widget _tabelaMacronutrientes(AnaliseSolo a, pw.Font font, pw.Font bold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Macronutrientes',
            style: pw.TextStyle(font: bold, fontSize: 10, color: _verde)),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.8),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.5),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
          },
          children: [
            _headerRow(['Parâmetro', 'Valor', 'Unidade'], bold),
            _dataRow(['pH (CaCl₂)', _fmtNum(a.ph), '-'], font),
            _dataRow(['Matéria Orgânica', _fmtNum(a.materiaOrganica), 'g/dm³'], font),
            _dataRow(['Fósforo (P resina)', _fmtNum(a.fosforo), 'mg/dm³'], font),
            _dataRow(['Potássio (K)', _fmtNum(a.potassio), 'mmolc/dm³'], font),
            _dataRow(['Cálcio (Ca)', _fmtNum(a.calcio), 'mmolc/dm³'], font),
            _dataRow(['Magnésio (Mg)', _fmtNum(a.magnesio), 'mmolc/dm³'], font),
            _dataRow(['Enxofre (S-SO₄)', _fmtNum(a.enxofre), 'mg/dm³'], font),
          ],
        ),
      ],
    );
  }

  // ─── Tabela Acidez e CTC ──────────────────────────────────────────────

  static pw.Widget _tabelaAcidezCTC(AnaliseSolo a, pw.Font font, pw.Font bold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Acidez e CTC',
            style: pw.TextStyle(font: bold, fontSize: 10, color: _verde)),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.8),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.5),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
          },
          children: [
            _headerRow(['Parâmetro', 'Valor', 'Unidade'], bold),
            _dataRow(['Acidez Potencial (H+Al)', _fmtNum(a.acidezPotencial), 'mmolc/dm³'], font),
            _dataRow(['Alumínio (Al)', _fmtNum(a.aluminio), 'mmolc/dm³'], font),
            _dataRow(['Soma de Bases (SB)', _fmtNum(a.somasBases), 'mmolc/dm³'], font),
            _dataRow(['CTC', _fmtNum(a.ctc), 'mmolc/dm³'], font),
            _dataRow(['Saturação por Bases (V%)', _fmtNum(a.saturacaoBases), '%'], font),
          ],
        ),
      ],
    );
  }

  // ─── Tabela Micronutrientes ───────────────────────────────────────────

  static pw.Widget _tabelaMicronutrientes(AnaliseSolo a, pw.Font font, pw.Font bold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Micronutrientes',
            style: pw.TextStyle(font: bold, fontSize: 10, color: _verde)),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.8),
          columnWidths: {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(1),
          },
          children: [
            _headerRow(['Boro\n(mg/dm³)', 'Cobre\n(mg/dm³)', 'Ferro\n(mg/dm³)', 'Manganês\n(mg/dm³)', 'Zinco\n(mg/dm³)'], bold),
            pw.TableRow(
              children: [
                _td(_fmtNum(a.boro), font),
                _td(_fmtNum(a.cobre), font),
                _td(_fmtNum(a.ferro), font),
                _td(_fmtNum(a.manganes), font),
                _td(_fmtNum(a.zinco), font),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ─── Tabela Textura ───────────────────────────────────────────────────

  static pw.Widget _tabelaTextura(AnaliseSolo a, pw.Font font, pw.Font bold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Textura do Solo',
            style: pw.TextStyle(font: bold, fontSize: 10, color: _verde)),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.8),
          columnWidths: {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
          },
          children: [
            _headerRow(['Argila (g/kg)', 'Silte (g/kg)', 'Areia (g/kg)'], bold),
            pw.TableRow(
              children: [
                _td(_fmtNum(a.argila), font),
                _td(_fmtNum(a.silte), font),
                _td(_fmtNum(a.areia), font),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ─── Observações ──────────────────────────────────────────────────────

  static pw.Widget _observacoes(String obs, pw.Font font, pw.Font bold) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Observações', style: pw.TextStyle(font: bold, fontSize: 9)),
          pw.SizedBox(height: 4),
          pw.Text(obs, style: pw.TextStyle(font: font, fontSize: 8)),
        ],
      ),
    );
  }

  // ─── Tabela Comparativa (quando há múltiplas análises) ────────────────

  static pw.Widget _tabelaComparativa(
      List<AnaliseSolo> analises, Map<String, String> talhaoMap,
      pw.Font font, pw.Font bold) {
    // Colunas: Parâmetro | Análise 1 | Análise 2 | ...
    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FlexColumnWidth(1.5),
    };
    for (var i = 0; i < analises.length; i++) {
      columnWidths[i + 1] = const pw.FlexColumnWidth(1);
    }

    String label(AnaliseSolo a) {
      final talhao = a.talhaoId != null
          ? (talhaoMap[a.talhaoId] ?? 'Talhão')
          : 'Geral';
      return '$talhao\n${_fmtData(a.dataColeta)}';
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.8),
      columnWidths: columnWidths,
      children: [
        _headerRow(['Parâmetro', ...analises.map(label)], bold),
        _compRow('pH', analises.map((a) => _fmtNum(a.ph)).toList(), font),
        _compRow('M.O. (g/dm³)', analises.map((a) => _fmtNum(a.materiaOrganica)).toList(), font),
        _compRow('P (mg/dm³)', analises.map((a) => _fmtNum(a.fosforo)).toList(), font),
        _compRow('K (mmolc/dm³)', analises.map((a) => _fmtNum(a.potassio)).toList(), font),
        _compRow('Ca (mmolc/dm³)', analises.map((a) => _fmtNum(a.calcio)).toList(), font),
        _compRow('Mg (mmolc/dm³)', analises.map((a) => _fmtNum(a.magnesio)).toList(), font),
        _compRow('V%', analises.map((a) => _fmtNum(a.saturacaoBases)).toList(), font),
        _compRow('CTC', analises.map((a) => _fmtNum(a.ctc)).toList(), font),
        _compRow('SB', analises.map((a) => _fmtNum(a.somasBases)).toList(), font),
        _compRow('H+Al', analises.map((a) => _fmtNum(a.acidezPotencial)).toList(), font),
      ],
    );
  }

  // ─── Rodapé ───────────────────────────────────────────────────────────

  static pw.Widget _rodape(pw.Font font, int pagina, int total) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('AFCRC Catanduva — Sistema de Gestão',
            style: pw.TextStyle(font: font, fontSize: 7, color: PdfColors.grey600)),
        pw.Text('Página $pagina de $total',
            style: pw.TextStyle(font: font, fontSize: 7, color: PdfColors.grey600)),
      ],
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────

  static pw.Widget _hCell(String text, pw.Font bold) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: pw.Text(text, style: pw.TextStyle(font: bold, fontSize: 8)),
      );

  static pw.Widget _vCell(String text, pw.Font font) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 8)),
      );

  static pw.TableRow _headerRow(List<String> labels, pw.Font bold) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: labels.map((l) => _th(l, bold)).toList(),
    );
  }

  static pw.TableRow _dataRow(List<String> values, pw.Font font) {
    return pw.TableRow(
      children: values.map((v) => _td(v, font)).toList(),
    );
  }

  static pw.TableRow _compRow(String label, List<String> values, pw.Font font) {
    return pw.TableRow(
      children: [
        _td(label, font),
        ...values.map((v) => _td(v, font)),
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
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: pw.Text(text,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: font, fontSize: 8)),
      );

  static pw.Widget _labelValor(String label, String valor, pw.Font font, pw.Font bold) {
    return pw.RichText(
      text: pw.TextSpan(children: [
        pw.TextSpan(text: '$label: ',
            style: pw.TextStyle(font: bold, fontSize: 8, color: PdfColors.grey700)),
        pw.TextSpan(text: valor,
            style: pw.TextStyle(font: font, fontSize: 8)),
      ]),
    );
  }

  static String _fmtNum(double? v) {
    if (v == null) return '-';
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  static String _fmtData(DateTime? d) {
    if (d == null) return '-';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/monitoramento_praga.dart';
import '../../models/contexto_propriedade.dart';
import 'pdf_cabecalho.dart';

class PdfMonitoramentoPragas {
  static Future<Uint8List> gerar(
    ContextoPropriedade ctx,
    List<MonitoramentoPraga> monitoramentos,
    Map<String, String> talhoesNumeros, // Map talhaoId -> numeroTalhao
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        build: (context) => [
          cabecalhoPDF(ctx, 'Relatório de Monitoramento de Pragas'),
          pw.SizedBox(height: 12),
          _tabela(monitoramentos, talhoesNumeros),
          if (monitoramentos.length > 1) ...[
            pw.SizedBox(height: 18),
            _comparativo(monitoramentos, talhoesNumeros),
          ],
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}  |  AFCRC Catanduva — Sistema de Gestão',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ),
      ),
    );
    return pdf.save();
  }

  static pw.Widget _tabela(List<MonitoramentoPraga> lista, Map<String, String> talhoesNumeros) {
    return pw.Table.fromTextArray(
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignment: pw.Alignment.centerLeft,
      columnWidths: {
        0: const pw.FixedColumnWidth(40),
        1: const pw.FixedColumnWidth(60),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FixedColumnWidth(40),
        4: const pw.FixedColumnWidth(40),
        5: const pw.FlexColumnWidth(2),
        6: const pw.FlexColumnWidth(2),
      },
      headers: [
        'Talhão',
        'Data',
        'Praga',
        'Nível',
        'Área (ha)',
        'Método',
        'Ação Recomendada',
      ],
      data: lista.map((m) => [
        talhoesNumeros[m.talhaoId] ?? '-',
        _formatarData(m.dataMonitoramento),
        m.praga,
        _nivelFormatado(m.nivelInfestacao),
        m.areaAfetadaHa?.toStringAsFixed(2) ?? '-',
        m.metodoAvaliacao ?? '-',
        m.acaoRecomendada ?? '-',
      ]).toList(),
    );
  }

  static pw.Widget _comparativo(List<MonitoramentoPraga> lista, Map<String, String> talhoesNumeros) {
    // Exemplo: tabela de totais por nível de infestação
    final totais = <String, int>{'baixo': 0, 'medio': 0, 'alto': 0, 'critico': 0};
    for (final m in lista) {
      totais[m.nivelInfestacao] = (totais[m.nivelInfestacao] ?? 0) + 1;
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Resumo por Nível de Infestação', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
        pw.SizedBox(height: 6),
        pw.Table.fromTextArray(
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          headers: ['Baixo', 'Médio', 'Alto', 'Crítico'],
          data: [
            [
              totais['baixo'].toString(),
              totais['medio'].toString(),
              totais['alto'].toString(),
              totais['critico'].toString(),
            ]
          ],
        ),
      ],
    );
  }

  static String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  static String _nivelFormatado(String nivel) {
    switch (nivel) {
      case 'baixo':
        return 'Baixo';
      case 'medio':
        return 'Médio';
      case 'alto':
        return 'Alto';
      case 'critico':
        return 'Crítico';
      default:
        return nivel;
    }
  }
}

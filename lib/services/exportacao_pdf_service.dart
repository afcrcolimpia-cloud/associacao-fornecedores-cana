import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'custo_operacional_analise.dart';
import 'custo_operacional_service.dart';
import '../models/models.dart';

/// Serviço para exportação de relatórios em PDF
class ExportacaoPDFService {
  /// Exportar relatório de um cenário
  static Future<String> exportarRelatoriosCenario(
    CustoOperacionalCenario cenario,
    Propriedade propriedade,
  ) async {
    try {
      final pdf = await CustoOperacionalAnalise.gerarRelatorioPDF(
        cenario,
        propriedade,
        [cenario],
      );

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'relatorio_${propriedade.id}_${cenario.id}_$timestamp.pdf';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(await pdf.save());

      if (kDebugMode) {
        print('Relatório exportado para: ${file.path}');
      }

      return file.path;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao exportar relatório: $e');
      }
      rethrow;
    }
  }

  /// Abrir/imprimir o PDF diretamente
  static Future<void> imprimirRelatorio(
    CustoOperacionalCenario cenario,
    Propriedade propriedade,
  ) async {
    try {
      final pdf = await CustoOperacionalAnalise.gerarRelatorioPDF(
        cenario,
        propriedade,
        [cenario],
      );

      await Printing.layoutPdf(
        onLayout: (format) => pdf.save(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Exportar comparação de cenários
  static Future<String> exportarComparacao(
    List<CustoOperacionalCenario> cenarios,
    Propriedade propriedade,
  ) async {
    try {
      if (cenarios.isEmpty) {
        throw Exception('Nenhum cenário para exportar');
      }

      // Usar o primeiro cenário como referência
      final pdf = await CustoOperacionalAnalise.gerarRelatorioPDF(
        cenarios.first,
        propriedade,
        cenarios,
      );

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'comparacao_${propriedade.id}_$timestamp.pdf';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(await pdf.save());

      if (kDebugMode) {
        print('Comparação exportada para: ${file.path}');
      }

      return file.path;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao exportar comparação: $e');
      }
      rethrow;
    }
  }
}

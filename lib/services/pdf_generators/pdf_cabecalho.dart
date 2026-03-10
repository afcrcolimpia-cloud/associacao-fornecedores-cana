import 'package:pdf/widgets.dart' as pw;
import '../../models/contexto_propriedade.dart';

/// Cabeçalho universal AFCRC para todos os PDFs
/// Nunca duplicar este código — sempre importar desta função
pw.Widget cabecalhoPDF(ContextoPropriedade ctx, String titulo) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'Associação dos Fornecedores de Cana da Região de Catanduva',
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 14,
        ),
      ),
      pw.Text(
        'AFCRC — Catanduva/SP',
        style: const pw.TextStyle(fontSize: 11),
      ),
      pw.Divider(),
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              'Proprietário: ${ctx.nomeProprietario}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              'FA: ${ctx.numeroFA}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              'Propriedade: ${ctx.nomePropriedade}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              'Município: ${ctx.municipio}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              'Área: ${ctx.areaHa}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              'Data: ${DateTime.now().toString().substring(0, 10)}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
      pw.Divider(),
      pw.Text(
        titulo,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 16,
        ),
      ),
      pw.SizedBox(height: 12),
    ],
  );
}

/// Rodapé universal com número de página
pw.Widget rodapePDF(int pageNumber, int totalPages) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        'AFCRC Catanduva — Sistema de Gestão',
        style: const pw.TextStyle(fontSize: 9),
      ),
      pw.Text(
        'Página $pageNumber de $totalPages',
        style: const pw.TextStyle(fontSize: 9),
      ),
    ],
  );
}

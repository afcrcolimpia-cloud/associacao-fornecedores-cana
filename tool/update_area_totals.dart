import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Script para sincronizar `propriedades.area_total_hectares`
/// com a soma das áreas dos talhões, usando a REST API do Supabase.
///
/// Uso:
///   - defina as variáveis de ambiente `SUPABASE_URL` e `SUPABASE_KEY`
///   - rode: `dart run tool/update_area_totals.dart`

Future<void> main(List<String> args) async {
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final supabaseKey = Platform.environment['SUPABASE_KEY'];

  if (supabaseUrl == null || supabaseKey == null) {
    stderr.writeln('ERRO: defina SUPABASE_URL e SUPABASE_KEY como variáveis de ambiente.');
    stderr.writeln('Exemplo (PowerShell):');
    stderr.writeln('  \$env:SUPABASE_URL = "https://<seu-projeto>.supabase.co"; \$env:SUPABASE_KEY = "<SUA_KEY>"; dart run tool/update_area_totals.dart');
    exit(1);
  }

  final headers = {
    'apikey': supabaseKey,
    'Authorization': 'Bearer $supabaseKey',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  stderr.writeln('Buscando propriedades...');
  final propUri = Uri.parse('$supabaseUrl/rest/v1/propriedades?select=id');
  final propRes = await http.get(propUri, headers: headers);
  if (propRes.statusCode != 200) {
    stderr.writeln('Erro ao buscar propriedades: ${propRes.statusCode} ${propRes.body}');
    exit(1);
  }

  final props = List<Map<String, dynamic>>.from(jsonDecode(propRes.body) as List<dynamic>);
  stderr.writeln('Encontradas ${props.length} propriedades.');

  var updatedCount = 0;

  for (final p in props) {
    final propriedadeId = p['id'] as String;

    final talhoesUri = Uri.parse('$supabaseUrl/rest/v1/talhoes?propriedade_id=eq.$propriedadeId&select=area_hectares');
    final talhoesRes = await http.get(talhoesUri, headers: headers);
    if (talhoesRes.statusCode != 200) {
      stderr.writeln('Erro ao buscar talhões da propriedade $propriedadeId: ${talhoesRes.statusCode} ${talhoesRes.body}');
      continue;
    }

    final talhoes = List<Map<String, dynamic>>.from(jsonDecode(talhoesRes.body) as List<dynamic>);
    double total = 0.0;
    for (final t in talhoes) {
      final v = t['area_hectares'];
      if (v == null) continue;
      if (v is num) {
        total += v.toDouble();
      } else {
        total += double.tryParse(v.toString()) ?? 0.0;
      }
    }

    final updateUri = Uri.parse('$supabaseUrl/rest/v1/propriedades?id=eq.$propriedadeId');
    final updRes = await http.patch(
      updateUri,
      headers: {...headers, 'Prefer': 'return=representation'},
      body: jsonEncode({'area_total_hectares': total}),
    );

    if (updRes.statusCode != 200 && updRes.statusCode != 204) {
      stderr.writeln('Erro ao atualizar propriedade $propriedadeId: ${updRes.statusCode} ${updRes.body}');
      continue;
    }

    stderr.writeln('Propriedade $propriedadeId atualizada: ${total.toStringAsFixed(2)} ha');
    updatedCount++;
  }

  stderr.writeln('Concluído. Propriedades atualizadas: $updatedCount/${props.length}');
}

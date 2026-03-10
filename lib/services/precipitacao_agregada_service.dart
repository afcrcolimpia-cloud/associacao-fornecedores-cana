// lib/services/precipitacao_agregada_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/precipitacao.dart';

class PrecipitacaoAgregadaService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _table = 'precipitacoes';

  /// Obtém todas as precipitações
  Future<List<Precipitacao>> getTodas() async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .order('data', ascending: false);

      return (data as List).map((p) => Precipitacao.fromJson(p)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar todas as precipitações: $e');
    }
  }

  /// Obtém stream de todas as precipitações
  Stream<List<Precipitacao>> getTodosStream() {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('data', ascending: false)
        .map((data) => (data as List).map((p) => Precipitacao.fromJson(p)).toList());
  }

  /// Agrupa precipitações por município
  Future<Map<String, List<Precipitacao>>> agruparPorMunicipio() async {
    try {
      final precipitacoes = await getTodas();
      final grupos = <String, List<Precipitacao>>{};

      for (var p in precipitacoes) {
        if (!grupos.containsKey(p.municipio)) {
          grupos[p.municipio] = [];
        }
        grupos[p.municipio]!.add(p);
      }

      return grupos;
    } catch (e) {
      throw Exception('Erro ao agrupar por município: $e');
    }
  }

  /// Agrupa e resume por município e mês
  Future<Map<String, Map<String, double>>> resumoPorMunicipioMes() async {
    try {
      final precipitacoes = await getTodas();
      final resumo = <String, Map<String, double>>{};

      for (var p in precipitacoes) {
        if (!resumo.containsKey(p.municipio)) {
          resumo[p.municipio] = {};
        }

        // Chave: YYYY-MM
        final mesAno = '${p.data.year}-${p.data.month.toString().padLeft(2, '0')}';

        if (!resumo[p.municipio]!.containsKey(mesAno)) {
          resumo[p.municipio]![mesAno] = 0.0;
        }

        // ✅ CORRIGIDO: usar 'milimetros' ao invés de 'volume'
        resumo[p.municipio]![mesAno] = resumo[p.municipio]![mesAno]! + p.milimetros;
      }

      return resumo;
    } catch (e) {
      throw Exception('Erro ao gerar resumo: $e');
    }
  }

  /// Estatísticas por município
  Future<Map<String, dynamic>> estatisticasPorMunicipio(String municipio) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('municipio', municipio)
          .order('data', ascending: false);

      final precipitacoes = (data as List)
          .map((p) => Precipitacao.fromJson(p))
          .toList();

      if (precipitacoes.isEmpty) {
        return {
          'totalDias': 0,
          'totalVolume': 0.0,
          'mediaVolume': 0.0,
          'maiorVolume': 0.0,
          'menorVolume': 0.0,
          'ultimaAtualizacao': null,
        };
      }

      double totalVolume = 0;
      double maiorVolume = 0;
      double menorVolume = double.infinity;

      for (var p in precipitacoes) {
        // ✅ CORRIGIDO: usar 'milimetros'
        totalVolume += p.milimetros;
        if (p.milimetros > maiorVolume) maiorVolume = p.milimetros;
        if (p.milimetros < menorVolume) menorVolume = p.milimetros;
      }

      return {
        'totalDias': precipitacoes.length,
        'totalVolume': totalVolume,
        'mediaVolume': totalVolume / precipitacoes.length,
        'maiorVolume': maiorVolume,
        'menorVolume': menorVolume == double.infinity ? 0 : menorVolume,
        'ultimaAtualizacao': precipitacoes.isNotEmpty ? precipitacoes.first.data : null,
      };
    } catch (e) {
      throw Exception('Erro ao buscar estatísticas: $e');
    }
  }

  /// Obtém lista única de municípios com dados
  Future<List<String>> obterMunicipios() async {
    try {
      final data = await _supabase
          .from(_table)
          .select('municipio');

      final municipios = <String>{};
      for (var item in data as List) {
        final municipio = item['municipio'] as String?;
        if (municipio != null && municipio.isNotEmpty) {
          municipios.add(municipio);
        }
      }

      return municipios.toList()..sort();
    } catch (e) {
      throw Exception('Erro ao obter municípios: $e');
    }
  }

  /// Total de milímetros por mês (de um município ou todos)
  Future<Map<String, double>> totalPorMes({String? municipio}) async {
    try {
      List<dynamic> data;

      if (municipio != null) {
        data = await _supabase
            .from(_table)
            .select()
            .eq('municipio', municipio)
            .order('data', ascending: true);
      } else {
        data = await _supabase
            .from(_table)
            .select()
            .order('data', ascending: true);
      }

      final precipitacoes = (data)
          .map((p) => Precipitacao.fromJson(p as Map<String, dynamic>))
          .toList();

      final totaisPorMes = <String, double>{};

      for (var p in precipitacoes) {
        final mesAno = '${p.data.year}-${p.data.month.toString().padLeft(2, '0')}';
        totaisPorMes.putIfAbsent(mesAno, () => 0.0);
        // ✅ CORRIGIDO: usar 'milimetros'
        totaisPorMes[mesAno] = totaisPorMes[mesAno]! + p.milimetros;
      }

      return totaisPorMes;
    } catch (e) {
      throw Exception('Erro ao calcular totais por mês: $e');
    }
  }

  /// Obtém precipitações agrupadas por ano
  Future<Map<int, double>> totalPorAno({String? municipio}) async {
    try {
      List<dynamic> data;

      if (municipio != null) {
        data = await _supabase
            .from(_table)
            .select()
            .eq('municipio', municipio);
      } else {
        data = await _supabase.from(_table).select();
      }

      final precipitacoes = (data)
          .map((p) => Precipitacao.fromJson(p as Map<String, dynamic>))
          .toList();

      final totaisPorAno = <int, double>{};

      for (var p in precipitacoes) {
        totaisPorAno.putIfAbsent(p.ano, () => 0.0);
        totaisPorAno[p.ano] = totaisPorAno[p.ano]! + p.milimetros;
      }

      return totaisPorAno;
    } catch (e) {
      throw Exception('Erro ao calcular totais por ano: $e');
    }
  }
}
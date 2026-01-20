// lib/services/precipitacao_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/precipitacao.dart';

class PrecipitacaoService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _table = 'precipitacoes';

  Future<List<Precipitacao>> getPrecipitacoesByPropriedade(String propriedadeId) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('propriedade_id', propriedadeId)
          .order('data', ascending: false);

      return (data as List).map((p) => Precipitacao.fromJson(p)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar precipitações: $e');
    }
  }

  Stream<List<Precipitacao>> getPrecipitacoesStream(String propriedadeId) {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('propriedade_id', propriedadeId)
        .order('data', ascending: false)
        .map((data) => (data as List).map((p) => Precipitacao.fromJson(p)).toList());
  }

  Future<void> addPrecipitacao(Precipitacao precipitacao) async {
    try {
      await _supabase.from(_table).insert(precipitacao.toJson());
    } catch (e) {
      throw Exception('Erro ao criar precipitação: $e');
    }
  }

  Future<void> updatePrecipitacao(Precipitacao precipitacao) async {
    try {
      await _supabase
          .from(_table)
          .update(precipitacao.toJson())
          .eq('id', precipitacao.id);
    } catch (e) {
      throw Exception('Erro ao atualizar precipitação: $e');
    }
  }

  Future<void> deletePrecipitacao(String id) async {
    try {
      await _supabase.from(_table).delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar precipitação: $e');
    }
  }

  Future<Map<String, dynamic>> getEstatisticas(String propriedadeId) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('propriedade_id', propriedadeId);

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
        };
      }

      final volumes = precipitacoes.map((p) => p.volume).toList();
      final totalVolume = volumes.fold<double>(0, (a, b) => a + b);

      return {
        'totalDias': precipitacoes.length,
        'totalVolume': totalVolume,
        'mediaVolume': totalVolume / precipitacoes.length,
        'maiorVolume': volumes.reduce((a, b) => a > b ? a : b),
        'menorVolume': volumes.reduce((a, b) => a < b ? a : b),
      };
    } catch (e) {
      throw Exception('Erro ao calcular estatísticas: $e');
    }
  }
}

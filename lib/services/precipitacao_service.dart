// lib/services/precipitacao_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/precipitacao.dart';

class PrecipitacaoService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _table = 'precipitacoes';
  static const Uuid _uuid = Uuid();
  static const String _cols = 'id, propriedade_id, municipio, data, mes, ano, milimetros, observacoes, criado_em, atualizado_em';

  Future<List<Precipitacao>> getPrecipitacoesByPropriedade(String propriedadeId) async {
    try {
      final data = await _supabase
          .from(_table)
          .select(_cols)
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
      // ✅ Validação antes de inserir
      if (precipitacao.propriedadeId.isEmpty) {
        throw Exception('propriedadeId é obrigatório');
      }
      if (precipitacao.municipio.isEmpty) {
        throw Exception('municipio é obrigatório');
      }

      // ✅ Gerar ID se não existir
      final novoId = precipitacao.id.isEmpty ? _uuid.v4() : precipitacao.id;
      
      // ✅ Criar novo objeto com ID e timestamps
      final agora = DateTime.now();
      final precipitacaoParaInserir = precipitacao.copyWith(
        id: novoId,
        criadoEm: agora,
        atualizadoEm: agora,
      );

      final json = precipitacaoParaInserir.toJson();

      await _supabase.from(_table).insert(json);
    } catch (e) {
      throw Exception('Erro ao criar precipitação: $e');
    }
  }

  Future<void> updatePrecipitacao(Precipitacao precipitacao) async {
    try {
      if (precipitacao.id.isEmpty) {
        throw Exception('id é obrigatório para atualizar');
      }

      // ✅ Atualizar timestamp
      final precipitacaoParaAtualizar = precipitacao.copyWith(
        atualizadoEm: DateTime.now(),
      );

      await _supabase
          .from(_table)
          .update(precipitacaoParaAtualizar.toJson())
          .eq('id', precipitacao.id);
    } catch (e) {
      throw Exception('Erro ao atualizar precipitação: $e');
    }
  }

  Future<void> deletePrecipitacao(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('id é obrigatório para deletar');
      }
      
      await _supabase.from(_table).delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar precipitação: $e');
    }
  }

  Future<Map<String, dynamic>> getEstatisticas(String propriedadeId) async {
    try {
      final data = await _supabase
          .from(_table)
          .select(_cols)
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
          'periodicoAnual': 0.0,
        };
      }

      // ✅ CORRIGIDO: usar 'milimetros' ao invés de 'volume'
      final volumes = precipitacoes.map((p) => p.milimetros).toList();
      final totalVolume = volumes.fold<double>(0, (a, b) => a + b);
      final maiorVolume = volumes.reduce((a, b) => a > b ? a : b);
      final menorVolume = volumes.reduce((a, b) => a < b ? a : b);

      return {
        'totalDias': precipitacoes.length,
        'totalVolume': totalVolume,
        'mediaVolume': totalVolume / precipitacoes.length,
        'maiorVolume': maiorVolume,
        'menorVolume': menorVolume,
        'periodicoAnual': (totalVolume / precipitacoes.length) * 365,
      };
    } catch (e) {
      throw Exception('Erro ao calcular estatísticas: $e');
    }
  }

  /// Buscar precipitações por período
  Future<List<Precipitacao>> getPrecipitacoesPorPeriodo({
    required String propriedadeId,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    try {
      final data = await _supabase
          .from(_table)
          .select(_cols)
          .eq('propriedade_id', propriedadeId)
          .gte('data', dataInicio.toIso8601String().split('T')[0])
          .lte('data', dataFim.toIso8601String().split('T')[0])
          .order('data', ascending: false);

      return (data as List).map((p) => Precipitacao.fromJson(p)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar precipitações por período: $e');
    }
  }
}
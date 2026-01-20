import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class OperacaoCultivoService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'operacoes_cultivo';

  // Stream de operações por propriedade
  Stream<List<OperacaoCultivo>> getOperacoesPorPropriedade(String propriedadeId) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('propriedade_id', propriedadeId)
        .order('data_plantio', ascending: false)
        .map((data) => data.map((json) => OperacaoCultivo.fromJson(json)).toList());
  }

  // Stream de operações por talhão
  Stream<List<OperacaoCultivo>> getOperacoesPorTalhao(String talhaoId) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('talhao_id', talhaoId)
        .order('data_plantio', ascending: false)
        .map((data) => data.map((json) => OperacaoCultivo.fromJson(json)).toList());
  }

  // Buscar operação por ID
  Future<OperacaoCultivo?> getOperacaoById(String id) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data != null) {
        return OperacaoCultivo.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Criar nova operação
  Future<void> createOperacao(OperacaoCultivo operacao) async {
    try {
      await _supabase
          .from(_tableName)
          .insert(operacao.toJsonInsert());
    } catch (e) {
      rethrow;
    }
  }

  // Atualizar operação
  Future<void> updateOperacao(OperacaoCultivo operacao) async {
    try {
      await _supabase
          .from(_tableName)
          .update(operacao.toJson())
          .eq('id', operacao.id!);
    } catch (e) {
      rethrow;
    }
  }

  // Deletar operação
  Future<void> deleteOperacao(String id) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // Copiar operação para múltiplos talhões
  Future<void> copiarParaTalhoes(
    OperacaoCultivo operacao,
    List<String> talhoesIds,
  ) async {
    try {
      final operacoes = talhoesIds.map((talhaoId) {
        return {
          'propriedade_id': operacao.propriedadeId,
          'talhao_id': talhaoId,
          'data_plantio': operacao.dataPlantio.toIso8601String().split('T')[0],
          'data_quebra_lombo': operacao.dataQuebraLombo?.toIso8601String().split('T')[0],
          'data_colheita': operacao.dataColheita?.toIso8601String().split('T')[0],
          'data_1a_aplic_herbicida': operacao.data1aAplicHerbicida?.toIso8601String().split('T')[0],
          'data_2a_aplic_herbicida': operacao.data2aAplicHerbicida?.toIso8601String().split('T')[0],
          'observacoes': operacao.observacoes,
        };
      }).toList();

      await _supabase.from(_tableName).insert(operacoes);
    } catch (e) {
      rethrow;
    }
  }

  // Calcular dias entre datas
  int? calcularDias(DateTime? dataInicio, DateTime? dataFim) {
    if (dataInicio == null || dataFim == null) return null;
    return dataFim.difference(dataInicio).inDays;
  }

  // Estatísticas por propriedade
  Future<Map<String, dynamic>> getEstatisticas(String propriedadeId) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select()
          .eq('propriedade_id', propriedadeId);

      final operacoes = data.map((json) => OperacaoCultivo.fromJson(json)).toList();

      int totalOperacoes = operacoes.length;
      int comColheita = operacoes.where((o) => o.dataColheita != null).length;
      int comQuebraLombo = operacoes.where((o) => o.dataQuebraLombo != null).length;

      // Calcular média de dias até colheita
      final diasAteColheita = operacoes
          .where((o) => o.dataColheita != null)
          .map((o) => calcularDias(o.dataPlantio, o.dataColheita))
          .where((dias) => dias != null)
          .map((dias) => dias!)
          .toList();

      double? mediaDiasColheita;
      if (diasAteColheita.isNotEmpty) {
        mediaDiasColheita = diasAteColheita.reduce((a, b) => a + b) / diasAteColheita.length;
      }

      return {
        'totalOperacoes': totalOperacoes,
        'comColheita': comColheita,
        'comQuebraLombo': comQuebraLombo,
        'mediaDiasColheita': mediaDiasColheita?.round(),
        'operacoesEmAndamento': totalOperacoes - comColheita,
      };
    } catch (e) {
      return {};
    }
  }

  // Buscar última operação de um talhão
  Future<OperacaoCultivo?> getUltimaOperacao(String talhaoId) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select()
          .eq('talhao_id', talhaoId)
          .order('data_plantio', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data != null) {
        return OperacaoCultivo.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

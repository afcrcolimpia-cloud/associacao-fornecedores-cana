import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/monitoramento_praga.dart';

class MonitoramentoPragaService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tabela = 'monitoramento_pragas';
  static const String _cols =
      'id, talhao_id, safra_id, praga, nivel_infestacao, data_monitoramento, '
      'area_afetada_ha, metodo_avaliacao, acao_recomendada, acao_realizada, '
      'insumo_utilizado, dose_aplicada, unidade_dose, responsavel, observacoes, '
      'criado_em, atualizado_em';

  Future<List<MonitoramentoPraga>> buscarPorTalhao(String talhaoId) async {
    try {
      final response = await _supabase
          .from(_tabela)
          .select(_cols)
          .eq('talhao_id', talhaoId)
          .order('data_monitoramento', ascending: false);

      return (response as List)
          .map((e) => MonitoramentoPraga.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar monitoramentos por talhão: $e');
    }
  }

  Future<List<MonitoramentoPraga>> buscarPorPropriedade(
      String propriedadeId) async {
    try {
      // Join via talhão para buscar todos os monitoramentos da propriedade
      final response = await _supabase
          .from(_tabela)
          .select('$_cols, talhoes!inner(propriedade_id)')
          .eq('talhoes.propriedade_id', propriedadeId)
          .order('data_monitoramento', ascending: false);

      return (response as List)
          .map((e) => MonitoramentoPraga.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar monitoramentos por propriedade: $e');
    }
  }

  Future<List<MonitoramentoPraga>> buscarPorSafra(String safraId) async {
    try {
      final response = await _supabase
          .from(_tabela)
          .select(_cols)
          .eq('safra_id', safraId)
          .order('data_monitoramento', ascending: false);

      return (response as List)
          .map((e) => MonitoramentoPraga.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar monitoramentos por safra: $e');
    }
  }

  Future<MonitoramentoPraga?> buscarPorId(String id) async {
    try {
      final response = await _supabase
          .from(_tabela)
          .select(_cols)
          .eq('id', id)
          .maybeSingle();

      return response != null
          ? MonitoramentoPraga.fromJson(response)
          : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> salvarMonitoramento(MonitoramentoPraga m) async {
    try {
      final dados = m.toJson();
      await _supabase.from(_tabela).insert(dados);
    } catch (e) {
      throw Exception('Erro ao salvar monitoramento: $e');
    }
  }

  Future<void> atualizarMonitoramento(MonitoramentoPraga m) async {
    try {
      final dados = m.toJson();
      await _supabase.from(_tabela).update(dados).eq('id', m.id);
    } catch (e) {
      throw Exception('Erro ao atualizar monitoramento: $e');
    }
  }

  Future<void> deletarMonitoramento(String id) async {
    try {
      await _supabase.from(_tabela).delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao excluir monitoramento: $e');
    }
  }
}

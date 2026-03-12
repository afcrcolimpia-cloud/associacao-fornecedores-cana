import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tratos_culturais.dart';
import '../models/insumo_com_dose.dart';

class TratosCulturaisService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String tableName = 'tratos_culturais';

  /// Obtém todos os tratos de uma propriedade
  Future<List<TratosCulturais>> getTratosByPropriedade(String propriedadeId) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('id, propriedade_id, talhao_id, ano_safra, adubos, herbicidas, inseticidas, maturadores, calagem, gessagem, oxido_de_calcio, campos_extras, data_aplicacao, observacoes, criado_em, atualizado_em')
          .eq('propriedade_id', propriedadeId);

      return (response as List)
          .map((data) => TratosCulturais.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar tratos: $e');
    }
  }

  /// Obtém tratos de um talhão específico
  Future<List<TratosCulturais>> getTratosByTalhao(String talhaoId) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('id, propriedade_id, talhao_id, ano_safra, adubos, herbicidas, inseticidas, maturadores, calagem, gessagem, oxido_de_calcio, campos_extras, data_aplicacao, observacoes, criado_em, atualizado_em')
          .eq('talhao_id', talhaoId);

      return (response as List)
          .map((data) => TratosCulturais.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar tratos do talhão: $e');
    }
  }

  /// Obtém tratos filtrados por propriedade, talhão e ano safra
  Future<TratosCulturais?> getTratosByCriteria({
    required String propriedadeId,
    required String talhaoId,
    required int anoSafra,
  }) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('id, propriedade_id, talhao_id, ano_safra, adubos, herbicidas, inseticidas, maturadores, calagem, gessagem, oxido_de_calcio, campos_extras, data_aplicacao, observacoes, criado_em, atualizado_em')
          .eq('propriedade_id', propriedadeId)
          .eq('talhao_id', talhaoId)
          .eq('ano_safra', anoSafra);

      if ((response as List).isEmpty) return null;
      return TratosCulturais.fromJson(response.first);
    } catch (e) {
      throw Exception('Erro ao buscar tratos: $e');
    }
  }

  /// Stream em tempo real dos tratos de uma propriedade
  Stream<List<TratosCulturais>> getTratosByPropriedadeStream(String propriedadeId) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: ['id'])
        .eq('propriedade_id', propriedadeId)
        .map((list) => list
            .map((data) => TratosCulturais.fromJson(data))
            .toList());
  }

  /// Adiciona novos tratos
  Future<void> addTratos(TratosCulturais tratos) async {
    try {
      await _supabase.from(tableName).insert(tratos.toJson());
    } catch (e) {
      throw Exception('Erro ao adicionar tratos: $e');
    }
  }

  /// Atualiza tratos existentes
  Future<void> updateTratos(TratosCulturais tratos) async {
    try {
      await _supabase
          .from(tableName)
          .update(tratos.toJson())
          .eq('id', tratos.id);
    } catch (e) {
      throw Exception('Erro ao atualizar tratos: $e');
    }
  }

  /// Deleta tratos
  Future<void> deleteTratos(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar tratos: $e');
    }
  }

  /// Obtém estatísticas de um talhão
  Future<Map<String, dynamic>> getEstatisticas(String talhaoId) async {
    try {
      final list = await getTratosByTalhao(talhaoId);
      
      if (list.isEmpty) {
        return {
          'total': 0,
          'media': 0,
          'anos': [],
        };
      }

      // Calcula totais por ano
      final porAno = <String, List<TratosCulturais>>{};
      for (final trato in list) {
        porAno.putIfAbsent(trato.anoSafra, () => []).add(trato);
      }

      return {
        'total': list.length,
        'media': list.length / porAno.length,
        'anos': porAno.keys.toList()..sort(),
      };
    } catch (e) {
      throw Exception('Erro ao calcular estatísticas: $e');
    }
  }

  /// Buscar tratos agrupados por talhão
  Future<Map<String, List<TratosCulturais>>> buscarTratosPorPropriedadeAgrupado(
      String propriedadeId) async {
    try {
      final tratos = await getTratosByPropriedade(propriedadeId);

      final Map<String, List<TratosCulturais>> agrupado = {};

      for (final trato in tratos) {
        final chave = trato.talhaoId ?? 'desconhecido';
        agrupado.putIfAbsent(chave, () => []).add(trato);
      }

      return agrupado;
    } catch (e) {
      throw Exception('Erro ao agrupar tratos: $e');
    }
  }

  /// Calcular custo total por talhão
  Future<double> custoTotalTalhao(String talhaoId) async {
    try {
      final tratos = await getTratosByTalhao(talhaoId);
      return tratos.fold<double>(0.0, (sum, t) => sum + t.custoTotalCompleto);
    } catch (e) {
      throw Exception('Erro ao calcular custo: $e');
    }
  }

  /// Buscar insumos com doses da tabela de referência
  Future<List<InsumoComDose>> buscarInsumosComDoses({
    String? categoria,
    String? tipo,
  }) async {
    try {
      var query = _supabase
          .from('insumos_com_doses')
          .select('id, categoria, tipo, produto, situacao, dose_minima, dose_maxima, unidade, preco_unitario, observacoes, data_criacao');

      if (categoria != null) query = query.eq('categoria', categoria);
      if (tipo != null) query = query.eq('tipo', tipo);

      final response = await query.order('produto');

      return (response as List)
          .map((json) => InsumoComDose.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar insumos: $e');
    }
  }
}

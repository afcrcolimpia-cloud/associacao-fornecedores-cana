import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/analise_solo.dart';

class AnaliseSoloService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'analises_solo';
  static const String _cols =
      'id, propriedade_id, talhao_id, laboratorio, numero_amostra, '
      'data_coleta, data_resultado, profundidade_cm, '
      'ph, materia_organica, fosforo, potassio, calcio, magnesio, enxofre, '
      'acidez_potencial, aluminio, somas_bases, ctc, saturacao_bases, '
      'boro, cobre, ferro, manganes, zinco, '
      'argila, silte, areia, '
      'observacoes, criado_em, atualizado_em';

  /// Stream de análises por propriedade
  Stream<List<AnaliseSolo>> getAnalisesPorPropriedadeStream(String propriedadeId) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('propriedade_id', propriedadeId)
        .order('data_coleta', ascending: false)
        .map((data) => data.map((json) => AnaliseSolo.fromJson(json)).toList());
  }

  /// Buscar análises por propriedade
  Future<List<AnaliseSolo>> getAnalisesPorPropriedade(String propriedadeId) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select(_cols)
          .eq('propriedade_id', propriedadeId)
          .order('data_coleta', ascending: false);

      return data.map((json) => AnaliseSolo.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar análises de solo: $e');
      return [];
    }
  }

  /// Buscar análises por talhão
  Future<List<AnaliseSolo>> getAnalisesPorTalhao(String talhaoId) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select(_cols)
          .eq('talhao_id', talhaoId)
          .order('data_coleta', ascending: false);

      return data.map((json) => AnaliseSolo.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar análises do talhão: $e');
      return [];
    }
  }

  /// Buscar análise por ID
  Future<AnaliseSolo?> getAnaliseById(String id) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select(_cols)
          .eq('id', id)
          .maybeSingle();

      if (data != null) {
        return AnaliseSolo.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar análise: $e');
      return null;
    }
  }

  /// Criar nova análise
  Future<void> criarAnalise(AnaliseSolo analise) async {
    try {
      await _supabase.from(_tableName).insert({
        'propriedade_id': analise.propriedadeId,
        'talhao_id': analise.talhaoId,
        'laboratorio': analise.laboratorio,
        'numero_amostra': analise.numeroAmostra,
        'data_coleta': analise.dataColeta?.toIso8601String(),
        'data_resultado': analise.dataResultado?.toIso8601String(),
        'profundidade_cm': analise.profundidadeCm,
        'ph': analise.ph,
        'materia_organica': analise.materiaOrganica,
        'fosforo': analise.fosforo,
        'potassio': analise.potassio,
        'calcio': analise.calcio,
        'magnesio': analise.magnesio,
        'enxofre': analise.enxofre,
        'acidez_potencial': analise.acidezPotencial,
        'aluminio': analise.aluminio,
        'somas_bases': analise.somasBases,
        'ctc': analise.ctc,
        'saturacao_bases': analise.saturacaoBases,
        'boro': analise.boro,
        'cobre': analise.cobre,
        'ferro': analise.ferro,
        'manganes': analise.manganes,
        'zinco': analise.zinco,
        'argila': analise.argila,
        'silte': analise.silte,
        'areia': analise.areia,
        'observacoes': analise.observacoes,
      });
    } catch (e) {
      debugPrint('Erro ao criar análise: $e');
      rethrow;
    }
  }

  /// Atualizar análise
  Future<void> atualizarAnalise(AnaliseSolo analise) async {
    try {
      await _supabase.from(_tableName).update({
        'talhao_id': analise.talhaoId,
        'laboratorio': analise.laboratorio,
        'numero_amostra': analise.numeroAmostra,
        'data_coleta': analise.dataColeta?.toIso8601String(),
        'data_resultado': analise.dataResultado?.toIso8601String(),
        'profundidade_cm': analise.profundidadeCm,
        'ph': analise.ph,
        'materia_organica': analise.materiaOrganica,
        'fosforo': analise.fosforo,
        'potassio': analise.potassio,
        'calcio': analise.calcio,
        'magnesio': analise.magnesio,
        'enxofre': analise.enxofre,
        'acidez_potencial': analise.acidezPotencial,
        'aluminio': analise.aluminio,
        'somas_bases': analise.somasBases,
        'ctc': analise.ctc,
        'saturacao_bases': analise.saturacaoBases,
        'boro': analise.boro,
        'cobre': analise.cobre,
        'ferro': analise.ferro,
        'manganes': analise.manganes,
        'zinco': analise.zinco,
        'argila': analise.argila,
        'silte': analise.silte,
        'areia': analise.areia,
        'observacoes': analise.observacoes,
        'atualizado_em': DateTime.now().toIso8601String(),
      }).eq('id', analise.id);
    } catch (e) {
      debugPrint('Erro ao atualizar análise: $e');
      rethrow;
    }
  }

  /// Deletar análise
  Future<void> deletarAnalise(String id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
    } catch (e) {
      debugPrint('Erro ao deletar análise: $e');
      rethrow;
    }
  }
}

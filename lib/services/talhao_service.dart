import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class TalhaoService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'talhoes';
  static const String _cols = 'id, propriedade_id, numero_talhao, area_ha, area_alqueires, variedade, cultura, ano_plantio, corte, data_plantio, tipo_talhao, ativo, observacoes, criado_em, atualizado_em';

  // Stream de talhões por propriedade
  Stream<List<Talhao>> getTalhoesStream(String propriedadeId) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('propriedade_id', propriedadeId)
        .order('numero_talhao', ascending: true)
        .map((data) => data.map((json) => Talhao.fromJson(json)).toList());
  }

  // Buscar talhões por propriedade
  Future<List<Talhao>> getTalhoesPorPropriedade(String propriedadeId) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select(_cols)
          .eq('propriedade_id', propriedadeId)
          .order('numero_talhao', ascending: true);
      
      return data.map((json) => Talhao.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar talhões: $e');
      return [];
    }
  }

  // Buscar talhão por ID
  Future<Talhao?> getTalhaoById(String id) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select(_cols)
          .eq('id', id)
          .maybeSingle();
      
      if (data != null) {
        return Talhao.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar talhão: $e');
      return null;
    }
  }

  // Criar novo talhão
  Future<void> createTalhao(Talhao talhao) async {
    try {
      await _supabase.from(_tableName).insert({
        'propriedade_id': talhao.propriedadeId,
        'numero_talhao': talhao.numeroTalhao,
        'area_ha': talhao.areaHa,
        'area_alqueires': talhao.areaAlqueires,
        'cultura': talhao.cultura,
        'variedade': talhao.variedade,
        'ano_plantio': talhao.anoPlantio,
        'tipo_talhao': talhao.tipoTalhao,
        'ativo': talhao.ativo,
        'observacoes': talhao.observacoes,
      });
    } catch (e) {
      debugPrint('Erro ao criar talhão: $e');
      rethrow;
    }
  }

  // Atualizar talhão
  Future<void> updateTalhao(Talhao talhao) async {
    try {
      await _supabase
          .from(_tableName)
          .update({
            'numero_talhao': talhao.numeroTalhao,
            'area_ha': talhao.areaHa,
            'area_alqueires': talhao.areaAlqueires,
            'cultura': talhao.cultura,
            'variedade': talhao.variedade,
            'ano_plantio': talhao.anoPlantio,
            'tipo_talhao': talhao.tipoTalhao,
            'ativo': talhao.ativo,
            'observacoes': talhao.observacoes,
          })
          .eq('id', talhao.id);
    } catch (e) {
      debugPrint('Erro ao atualizar talhão: $e');
      rethrow;
    }
  }

  // Deletar talhão
  Future<void> deleteTalhao(String id) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      debugPrint('Erro ao deletar talhão: $e');
      rethrow;
    }
  }

  // Ativar/Inativar talhão
  Future<void> toggleAtivo(String id, bool ativo) async {
    try {
      await _supabase
          .from(_tableName)
          .update({'ativo': ativo})
          .eq('id', id);
    } catch (e) {
      debugPrint('Erro ao alterar status: $e');
      rethrow;
    }
  }

  // Estatísticas da propriedade
  Future<Map<String, dynamic>> getEstatisticas(String propriedadeId) async {
    try {
      final talhoes = await getTalhoesPorPropriedade(propriedadeId);
      
      // Filtrar por tipo
      final producao = talhoes.where((t) => t.tipoTalhao == 'producao' && t.ativo).toList();
      final reforma = talhoes.where((t) => t.tipoTalhao == 'reforma' && t.ativo).toList();
      
      // Calcular áreas
      final areaProducaoHa = producao.fold<double>(0, (sum, t) => sum + (t.areaHa ?? 0));
      final areaReformaHa = reforma.fold<double>(0, (sum, t) => sum + (t.areaHa ?? 0));
      final areaTotalHa = areaProducaoHa + areaReformaHa;
      
      final areaProducaoAlq = producao.fold<double>(0, (sum, t) => sum + (t.areaAlqueires ?? 0));
      final areaReformaAlq = reforma.fold<double>(0, (sum, t) => sum + (t.areaAlqueires ?? 0));
      final areaTotalAlq = areaProducaoAlq + areaReformaAlq;
      
      // Contar talhões por variedade
      final variedades = <String, int>{};
      for (var talhao in talhoes.where((t) => t.ativo)) {
        final variedade = talhao.variedade ?? 'Não informada';
        variedades[variedade] = (variedades[variedade] ?? 0) + 1;
      }
      
      return {
        'totalTalhoes': talhoes.where((t) => t.ativo).length,
        'talhoesProducao': producao.length,
        'talhoesReforma': reforma.length,
        'areaProducaoHa': areaProducaoHa,
        'areaReformaHa': areaReformaHa,
        'areaTotalHa': areaTotalHa,
        'areaProducaoAlq': areaProducaoAlq,
        'areaReformaAlq': areaReformaAlq,
        'areaTotalAlq': areaTotalAlq,
        'variedades': variedades,
      };
    } catch (e) {
      debugPrint('Erro ao buscar estatísticas: $e');
      return {};
    }
  }

  // Criar múltiplos talhões de uma vez
  Future<void> createTalhoesEmLote(List<Talhao> talhoes) async {
    try {
      final data = talhoes.map((t) => {
        'propriedade_id': t.propriedadeId,
        'numero_talhao': t.numeroTalhao,
        'area_ha': t.areaHa,
        'area_alqueires': t.areaAlqueires,
        'variedade': t.variedade,
        'ano_plantio': t.anoPlantio,
        'tipo_talhao': t.tipoTalhao,
        'ativo': t.ativo,
        'observacoes': t.observacoes,
      }).toList();
      
      await _supabase.from(_tableName).insert(data);
    } catch (e) {
      debugPrint('Erro ao criar talhões em lote: $e');
      rethrow;
    }
  }

  // Obter área total de uma propriedade (soma de todos os talhões)
  Future<double> getAreaTotalPropriedade(String propriedadeId) async {
    try {
      final talhoes = await getTalhoesPorPropriedade(propriedadeId);
      return talhoes.fold<double>(0, (sum, t) => sum + (t.areaHa ?? 0));
    } catch (e) {
      debugPrint('Erro ao calcular área total: $e');
      return 0.0;
    }
  }

  // Stream de talhões por propriedade (alias para compatibilidade)
  Stream<List<Talhao>> getTalhoesByPropriedadeStream(String propriedadeId) {
    return getTalhoesStream(propriedadeId);
  }
}
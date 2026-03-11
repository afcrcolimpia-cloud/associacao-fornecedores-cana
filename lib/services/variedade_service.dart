// lib/services/variedade_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/variedade.dart';

class VariedadeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _table = 'variedades';
  static const String _cols = 'id, codigo, nome, instituicao, destaque, ambiente_producao, epoca_colheita, ativa, criado_em, atualizado_em';

  // Cache compartilhado: UUID → Variedade
  static Map<String, Variedade>? _cacheMap;

  /// Retorna mapa UUID → Variedade (usa cache em memória)
  Future<Map<String, Variedade>> getVariedadeMap() async {
    if (_cacheMap != null) return _cacheMap!;
    final lista = await getVariedadesAtivas();
    _cacheMap = {for (final v in lista) v.id: v};
    return _cacheMap!;
  }

  /// Resolve UUID da variedade para texto legível "CTC 04 — Rica e Produtiva"
  /// Se o valor já for texto (não-UUID), retorna como está.
  Future<String> resolverNomeVariedade(String? variedadeIdOuTexto) async {
    if (variedadeIdOuTexto == null || variedadeIdOuTexto.isEmpty) return '';
    // Se não parece UUID, retorna como está (texto legado)
    if (!variedadeIdOuTexto.contains('-') || variedadeIdOuTexto.length < 32) {
      return variedadeIdOuTexto;
    }
    final mapa = await getVariedadeMap();
    final v = mapa[variedadeIdOuTexto];
    if (v != null) {
      return '${v.codigo} — ${v.destaque}';
    }
    return variedadeIdOuTexto; // fallback
  }

  /// Resolve UUID da variedade para texto curto (apenas código, ex: "CTC 04")
  String resolverCodigoSync(String? variedadeIdOuTexto, Map<String, Variedade> mapa) {
    if (variedadeIdOuTexto == null || variedadeIdOuTexto.isEmpty) return '';
    if (!variedadeIdOuTexto.contains('-') || variedadeIdOuTexto.length < 32) {
      return variedadeIdOuTexto;
    }
    final v = mapa[variedadeIdOuTexto];
    return v?.codigo ?? variedadeIdOuTexto;
  }

  /// Resolve UUID da variedade para texto completo "CTC 04 — Rica e Produtiva" (síncrono, requer mapa)
  String resolverNomeSync(String? variedadeIdOuTexto, Map<String, Variedade> mapa) {
    if (variedadeIdOuTexto == null || variedadeIdOuTexto.isEmpty) return '';
    if (!variedadeIdOuTexto.contains('-') || variedadeIdOuTexto.length < 32) {
      return variedadeIdOuTexto;
    }
    final v = mapa[variedadeIdOuTexto];
    if (v != null) {
      return '${v.codigo} — ${v.destaque}';
    }
    return variedadeIdOuTexto;
  }

  /// Limpa o cache (chamar quando variedades são alteradas)
  static void limparCache() => _cacheMap = null;

  /// Obtém todas as variedades ativas
  Future<List<Variedade>> getVariedadesAtivas() async {
    try {
      final data = await _supabase
          .from(_table)
          .select(_cols)
          .eq('ativa', true)
          .order('codigo', ascending: true);

      return (data as List).map((v) => Variedade.fromJson(v)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar variedades: $e');
    }
  }

  /// Obtém todas as variedades (incluindo inativas)
  Future<List<Variedade>> getAllVariedades() async {
    try {
      final data = await _supabase
          .from(_table)
          .select(_cols)
          .order('codigo', ascending: true);

      return (data as List).map((v) => Variedade.fromJson(v)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar todas as variedades: $e');
    }
  }

  /// Stream de variedades em tempo real
  Stream<List<Variedade>> getVariedadesStream() {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('ativa', true)
        .order('codigo', ascending: true)
        .map((data) => (data as List).map((v) => Variedade.fromJson(v)).toList());
  }

  /// Buscar variedade por ID
  Future<Variedade?> getVariedadeById(String id) async {
    try {
      final data = await _supabase
          .from(_table)
          .select(_cols)
          .eq('id', id)
          .single();

      return Variedade.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Buscar variedade por código
  Future<Variedade?> getVariedadeByCodigo(String codigo) async {
    try {
      final data = await _supabase
          .from(_table)
          .select(_cols)
          .eq('codigo', codigo)
          .single();

      return Variedade.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Criar nova variedade
  Future<void> createVariedade(Variedade variedade) async {
    try {
      if (variedade.codigo.isEmpty) {
        throw Exception('Código da variedade é obrigatório');
      }

      await _supabase.from(_table).insert(variedade.toJson());
    } catch (e) {
      throw Exception('Erro ao criar variedade: $e');
    }
  }

  /// Atualizar variedade
  Future<void> updateVariedade(Variedade variedade) async {
    try {
      if (variedade.id.isEmpty) {
        throw Exception('ID da variedade é obrigatório');
      }

      await _supabase
          .from(_table)
          .update(variedade.toJson())
          .eq('id', variedade.id);
    } catch (e) {
      throw Exception('Erro ao atualizar variedade: $e');
    }
  }

  /// Deletar variedade
  Future<void> deleteVariedade(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('ID é obrigatório');
      }

      await _supabase.from(_table).delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar variedade: $e');
    }
  }

  /// Desativar variedade (soft delete)
  Future<void> desativarVariedade(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('ID é obrigatório');
      }

      await _supabase
          .from(_table)
          .update({
            'ativa': false,
            'atualizado_em': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao desativar variedade: $e');
    }
  }

  /// Recomendar variedades por ambiente de produção e mês de colheita
  Future<List<Variedade>> recomendar({
    required String ambiente,
    String? mes,
  }) async {
    try {
      final variedades = await getVariedadesAtivas();

      return variedades.where((v) {
        final ambienteOk = v.ambienteProducao.contains(ambiente);
        final mesOk = mes == null || mes.isEmpty || v.epocaColheita.contains(mes);
        return ambienteOk && mesOk;
      }).toList();
    } catch (e) {
      throw Exception('Erro ao recomendar variedades: $e');
    }
  }
}
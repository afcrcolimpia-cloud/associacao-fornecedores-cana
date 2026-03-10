// lib/services/variedade_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/variedade.dart';

class VariedadeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _table = 'variedades';

  /// Obtém todas as variedades ativas
  Future<List<Variedade>> getVariedadesAtivas() async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
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
          .select()
          .order('codigo', ascending: true);

      return (data as List).map((v) => Variedade.fromJson(v)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar variedades: $e');
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
          .select()
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
          .select()
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

      final now = DateTime.now();
      final variedadeParaInserir = variedade.copyWith(
        criadoEm: now,
        atualizadoEm: now,
      );

      await _supabase.from(_table).insert(variedadeParaInserir.toJson());
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

      final variedadeParaAtualizar = variedade.copyWith(
        atualizadoEm: DateTime.now(),
      );

      await _supabase
          .from(_table)
          .update(variedadeParaAtualizar.toJson())
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

  /// Buscar variedades por ambiente de produção
  Future<List<Variedade>> getVariedadesPorAmbiente(String ambiente) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('ambiente_producao', ambiente)
          .eq('ativa', true)
          .order('codigo', ascending: true);

      return (data as List).map((v) => Variedade.fromJson(v)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar variedades por ambiente: $e');
    }
  }
}
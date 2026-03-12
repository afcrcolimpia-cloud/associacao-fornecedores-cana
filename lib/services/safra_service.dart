import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/safra.dart';

class SafraService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String tableName = 'safras';
  static const String _cols =
      'id, proprietario_id, safra, data_inicio, data_fim, status, observacoes, criado_em, atualizado_em';

  // ── Leitura ─────────────────────────────────────────────────

  /// Buscar safra ativa de um proprietário
  Future<Safra?> buscarSafraAtiva(String proprietarioId) async {
    try {
      final data = await _supabase
          .from(tableName)
          .select(_cols)
          .eq('proprietario_id', proprietarioId)
          .eq('status', 'ativa')
          .order('data_inicio', ascending: false)
          .maybeSingle();

      return data != null ? Safra.fromJson(data) : null;
    } catch (e) {
      throw 'Erro ao buscar safra ativa: $e';
    }
  }

  /// Listar todas as safras do proprietário
  Future<List<Safra>> buscarPorProprietario(String proprietarioId) async {
    try {
      final data = await _supabase
          .from(tableName)
          .select(_cols)
          .eq('proprietario_id', proprietarioId)
          .order('data_inicio', ascending: false);

      return (data as List).map((json) => Safra.fromJson(json)).toList();
    } catch (e) {
      throw 'Erro ao buscar safras: $e';
    }
  }

  /// Buscar safra por ID
  Future<Safra?> buscarPorId(String id) async {
    try {
      final data = await _supabase
          .from(tableName)
          .select(_cols)
          .eq('id', id)
          .maybeSingle();

      return data != null ? Safra.fromJson(data) : null;
    } catch (e) {
      throw 'Erro ao buscar safra: $e';
    }
  }

  // ── Escrita ─────────────────────────────────────────────────

  /// Criar nova safra
  Future<String> salvarSafra(Safra safra) async {
    try {
      final json = safra.toJson();
      json.remove('id');
      json.remove('criado_em');
      json.remove('atualizado_em');

      final data = await _supabase
          .from(tableName)
          .insert(json)
          .select('id')
          .single();

      return data['id'] as String;
    } catch (e) {
      throw 'Erro ao criar safra: $e';
    }
  }

  /// Atualizar safra existente
  Future<void> atualizarSafra(Safra safra) async {
    try {
      final json = safra.toJson();
      json.remove('criado_em');
      json['atualizado_em'] = DateTime.now().toUtc().toIso8601String();

      await _supabase.from(tableName).update(json).eq('id', safra.id);
    } catch (e) {
      throw 'Erro ao atualizar safra: $e';
    }
  }

  /// Deletar safra
  Future<void> deletarSafra(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw 'Erro ao deletar safra: $e';
    }
  }

  /// Finalizar safra (muda status para "finalizada")
  Future<void> finalizarSafra(String id) async {
    try {
      await _supabase.from(tableName).update({
        'status': 'finalizada',
        'atualizado_em': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw 'Erro ao finalizar safra: $e';
    }
  }

  /// Reativar safra (muda status para "ativa")
  Future<void> reativarSafra(String id) async {
    try {
      await _supabase.from(tableName).update({
        'status': 'ativa',
        'atualizado_em': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw 'Erro ao reativar safra: $e';
    }
  }
}

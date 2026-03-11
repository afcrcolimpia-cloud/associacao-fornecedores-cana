import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class PropriedadeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'propriedades';
  static const String _cols = 'id, proprietario_id, nome_propriedade, numero_fa, endereco, cidade, estado, cep, area_ha, area_alqueires, ativa, criado_em, atualizado_em';

  // Buscar todas as propriedades
  Future<List<Propriedade>> getPropriedades() async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select(_cols)
          .order('nome_propriedade', ascending: true);
      
      return data.map((json) => Propriedade.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar propriedades: $e');
      return [];
    }
  }

  // Buscar propriedades por proprietário
  Future<List<Propriedade>> getPropriedadesPorProprietario(String proprietarioId) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select(_cols)
          .eq('proprietario_id', proprietarioId)
          .order('nome_propriedade', ascending: true);
      
      return data.map((json) => Propriedade.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar propriedades: $e');
      return [];
    }
  }

  // Buscar propriedade por ID
  Future<Propriedade?> getPropriedadeById(String id) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select(_cols)
          .eq('id', id)
          .maybeSingle();
      
      if (data != null) {
        return Propriedade.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar propriedade: $e');
      return null;
    }
  }

  // Criar nova propriedade
  Future<void> createPropriedade(Propriedade propriedade) async {
    try {
      await _supabase.from(_tableName).insert({
        'proprietario_id': propriedade.proprietarioId,
        'nome_propriedade': propriedade.nomePropriedade,
        'numero_fa': propriedade.numeroFA,
        'endereco': propriedade.endereco,
        'cidade': propriedade.cidade,
        'estado': propriedade.estado,
        'cep': propriedade.cep,
        'area_ha': propriedade.areaHa,
        'area_alqueires': propriedade.areaAlqueires,
        'ativa': propriedade.ativa,
      });
    } catch (e) {
      debugPrint('Erro ao criar propriedade: $e');
      rethrow;
    }
  }

  // Atualizar propriedade
  Future<void> updatePropriedade(Propriedade propriedade) async {
    try {
      await _supabase
          .from(_tableName)
          .update({
            'proprietario_id': propriedade.proprietarioId,
            'nome_propriedade': propriedade.nomePropriedade,
            'numero_fa': propriedade.numeroFA,
            'endereco': propriedade.endereco,
            'cidade': propriedade.cidade,
            'estado': propriedade.estado,
            'cep': propriedade.cep,
            'area_ha': propriedade.areaHa,
            'area_alqueires': propriedade.areaAlqueires,
            'ativa': propriedade.ativa,
          })
          .eq('id', propriedade.id);
    } catch (e) {
      debugPrint('Erro ao atualizar propriedade: $e');
      rethrow;
    }
  }

  // Deletar propriedade
  Future<void> deletePropriedade(String id) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      debugPrint('Erro ao deletar propriedade: $e');
      rethrow;
    }
  }

  // Toggle ativo/inativo
  Future<void> toggleAtivo(String id) async {
    try {
      final propriedade = await getPropriedadeById(id);
      if (propriedade != null) {
        await _supabase
            .from(_tableName)
            .update({'ativa': !propriedade.ativa})
            .eq('id', id);
      }
    } catch (e) {
      debugPrint('Erro ao alternar status: $e');
      rethrow;
    }
  }

  // Stream de todas as propriedades
  Stream<List<Propriedade>> getPropriedadesStream() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('nome_propriedade', ascending: true)
        .map((data) => data.map((json) => Propriedade.fromJson(json)).toList());
  }

  // Stream de propriedades ativas
  Stream<List<Propriedade>> getPropriedadesAtivasStream() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .map((data) => data
            .where((json) => json['ativa'] == true)
            .map((json) => Propriedade.fromJson(json))
            .toList());
  }

  // Stream de propriedades inativas
  Stream<List<Propriedade>> getPropriedadesInativasStream() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .map((data) => data
            .where((json) => json['ativa'] == false)
            .map((json) => Propriedade.fromJson(json))
            .toList());
  }

  // Buscar por número FA
  Future<Propriedade?> getPropriedadePorFA(String numeroFA) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select(_cols)
          .eq('numero_fa', numeroFA)
          .maybeSingle();
      
      if (data != null) {
        return Propriedade.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar propriedade por FA: $e');
      return null;
    }
  }
}
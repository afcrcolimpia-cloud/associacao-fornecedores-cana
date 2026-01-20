// lib/services/propriedade_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class PropriedadeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String collectionPropriedades = 'propriedades';
  final String collectionTalhoes = 'talhoes';

  // --- PROPRIEDADES ---

  Stream<List<Propriedade>> getAllPropriedadesStream() {
    return _supabase
        .from(collectionPropriedades)
        .stream(primaryKey: ['id'])
        .order('nome_propriedade', ascending: true)
        .map((data) => data.map((map) => Propriedade.fromJson(map)).toList());
  }

  Stream<List<Propriedade>> getPropriedadesByProprietarioStream(String proprietarioId) {
    return _supabase
        .from(collectionPropriedades)
        .stream(primaryKey: ['id'])
        .eq('proprietario_id', proprietarioId)
        .order('nome_propriedade', ascending: true)
        .map((data) => data.map((map) => Propriedade.fromJson(map)).toList());
  }

  Future<Propriedade?> getPropriedade(String id) async {
    try {
      final data = await _supabase
          .from(collectionPropriedades)
          .select()
          .eq('id', id)
          .single();

      return Propriedade.fromJson(data);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return null;
      }
      throw 'Erro ao buscar propriedade: ${e.message}';
    } catch (e) {
      throw 'Erro ao buscar propriedade: $e';
    }
  }

  Future<String> addPropriedade(Propriedade propriedade) async {
    try {
      final json = propriedade.toJson();
      json.remove('id');

      final data = await _supabase
          .from(collectionPropriedades)
          .insert(json)
          .select('id')
          .single();

      return data['id'] as String;
    } catch (e) {
      throw 'Erro ao adicionar propriedade: $e';
    }
  }

  Future<void> updatePropriedade(Propriedade propriedade) async {
    try {
      final json = propriedade.toJson();
      json.remove('criado_em');
      
      await _supabase
          .from(collectionPropriedades)
          .update(json)
          .eq('id', propriedade.id);
    } catch (e) {
      throw 'Erro ao atualizar propriedade: $e';
    }
  }

  Future<void> deletePropriedade(String id) async {
    try {
      await _supabase
          .from(collectionPropriedades)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw 'Erro ao deletar propriedade: $e';
    }
  }

  // Atualiza apenas o campo de área total (hectares) da propriedade
  Future<void> setAreaTotalHectares(String propriedadeId, double area) async {
    try {
      await _supabase
          .from(collectionPropriedades)
          .update({'area_total_hectares': area})
          .eq('id', propriedadeId);
    } catch (e) {
      throw 'Erro ao atualizar área total da propriedade: $e';
    }
  }

  // --- TALHÕES ---

  Stream<List<Talhao>> getTalhoesByPropriedadeStream(String propriedadeId) {
    return _supabase
        .from(collectionTalhoes)
        .stream(primaryKey: ['id'])
        .eq('propriedade_id', propriedadeId)
        .order('numero_talhao', ascending: true)
        .map((data) => data.map((map) => Talhao.fromJson(map)).toList());
  }

  Future<Talhao?> getTalhao(String id) async {
    try {
      final data = await _supabase
          .from(collectionTalhoes)
          .select()
          .eq('id', id)
          .single();

      return Talhao.fromJson(data);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return null;
      }
      throw 'Erro ao buscar talhão: ${e.message}';
    } catch (e) {
      throw 'Erro ao buscar talhão: $e';
    }
  }

  Future<String> addTalhao(Talhao talhao) async {
    try {
      final json = talhao.toJson();
      json.remove('id');

      final data = await _supabase
          .from(collectionTalhoes)
          .insert(json)
          .select('id')
          .single();

      return data['id'] as String;
    } catch (e) {
      throw 'Erro ao adicionar talhão: $e';
    }
  }

  Future<void> updateTalhao(Talhao talhao) async {
    try {
      final json = talhao.toJson();
      json.remove('criado_em');
      
      await _supabase
          .from(collectionTalhoes)
          .update(json)
          .eq('id', talhao.id);
    } catch (e) {
      throw 'Erro ao atualizar talhão: $e';
    }
  }

  Future<void> deleteTalhao(String id) async {
    try {
      await _supabase
          .from(collectionTalhoes)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw 'Erro ao deletar talhão: $e';
    }
  }

  // --- MÉTODO AUXILIAR PARA CONTAGEM ---
  
  Future<int> getTalhoesCount(String propriedadeId) async {
    try {
      final response = await _supabase
          .from(collectionTalhoes)
          .select('id')
          .eq('propriedade_id', propriedadeId);

      return response.length;
    } catch (e) {
      return 0;
    }
  }
}
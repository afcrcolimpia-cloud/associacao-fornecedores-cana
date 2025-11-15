import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class PropriedadeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<List<Propriedade>> getPropriedadesByProprietarioStream(String proprietarioId) {
    return _supabase
        .from('propriedades')
        .stream(primaryKey: ['id'])
        .eq('proprietario_id', proprietarioId)
        .order('nome', ascending: true)
        .map((data) => data.map((map) => Propriedade.fromJson(map)).toList());
  }

  Future<Propriedade?> getPropriedade(String id) async {
    try {
      final data = await _supabase
          .from('propriedades')
          .select()
          .eq('id', id)
          .single();

      return Propriedade.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<String> addPropriedade(Propriedade propriedade) async {
    final response = await _supabase
        .from('propriedades')
        .insert(propriedade.toJson())
        .select('id')
        .single();

    return response['id'] as String;
  }

  Future<void> updatePropriedade(Propriedade propriedade) async {
    await _supabase
        .from('propriedades')
        .update(propriedade.toJson())
        .eq('id', propriedade.id);
  }

  Future<void> deletePropriedade(String id) async {
    await _supabase.from('propriedades').delete().eq('id', id);
  }

  Stream<List<Talhao>> getTalhoesByPropriedadeStream(String propriedadeId) {
    return _supabase
        .from('talhoes')
        .stream(primaryKey: ['id'])
        .eq('propriedade_id', propriedadeId)
        .order('numero_talhao', ascending: true)
        .map((data) => data.map((map) => Talhao.fromJson(map)).toList());
  }

  Future<String> addTalhao(Talhao talhao) async {
    final response = await _supabase
        .from('talhoes')
        .insert(talhao.toJson())
        .select('id')
        .single();

    return response['id'] as String;
  }

  Future<void> updateTalhao(Talhao talhao) async {
    await _supabase
        .from('talhoes')
        .update(talhao.toJson())
        .eq('id', talhao.id);
  }

  Future<void> deleteTalhao(String id) async {
    await _supabase.from('talhoes').delete().eq('id', id);
  }
}
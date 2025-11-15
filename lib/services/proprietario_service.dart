import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class ProprietarioService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String tableName = 'proprietarios';

  Stream<List<Proprietario>> getProprietariosStream() {
    return _supabase
        .from(tableName)
        .stream(primaryKey: ['id'])
        .order('nome', ascending: true)
        .map((data) => data.map((map) => Proprietario.fromJson(map)).toList());
  }

  Future<Proprietario?> getProprietario(String id) async {
    try {
      final data = await _supabase
          .from(tableName)
          .select()
          .eq('id', id)
          .single();

      return Proprietario.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<String> addProprietario(Proprietario proprietario) async {
    final response = await _supabase
        .from(tableName)
        .insert(proprietario.toJson())
        .select('id')
        .single();

    return response['id'] as String;
  }

  Future<void> updateProprietario(Proprietario proprietario) async {
    await _supabase
        .from(tableName)
        .update(proprietario.toJson())
        .eq('id', proprietario.id);
  }

  Future<void> deleteProprietario(String id) async {
    await _supabase.from(tableName).delete().eq('id', id);
  }
}
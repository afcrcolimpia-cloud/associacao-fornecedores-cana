// lib/services/proprietario_service.dart
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class ProprietarioService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String tableName = 'proprietarios';

  // --- MÉTODOS DE LEITURA ---

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
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return null;
      }
      throw 'Erro ao buscar proprietário: ${e.message}';
    } catch (e) {
      throw 'Erro ao buscar proprietário: $e';
    }
  }

  Future<Proprietario?> getByCpfCnpj(String cpfCnpj) async {
    try {
      final data = await _supabase
          .from(tableName)
          .select()
          .eq('cpf_cnpj', cpfCnpj) // ✅ CORRIGIDO: cpf_cnpj (snake_case)
          .maybeSingle();

      if (data == null) return null;
      return Proprietario.fromJson(data);
    } catch (e) {
      throw 'Erro ao buscar por CPF/CNPJ: $e';
    }
  }

  Future<List<Proprietario>> getProprietarios() async {
    try {
      final data = await _supabase
          .from(tableName)
          .select()
          .order('nome', ascending: true);

      return data.map((map) => Proprietario.fromJson(map)).toList();
    } catch (e) {
      throw 'Erro ao buscar proprietários: $e';
    }
  }

  // --- MÉTODOS DE ESCRITA ---

  Future<String> addProprietario(Proprietario proprietario) async {
    try {
      // Remove o ID antes de inserir (o banco gera automaticamente)
      final json = proprietario.toJson();
      json.remove('id');

      final data = await _supabase
          .from(tableName)
          .insert(json)
          .select('id')
          .single();

      return data['id'] as String;
    } catch (e) {
      throw 'Erro ao adicionar proprietário: $e';
    }
  }

  Future<void> updateProprietario(Proprietario proprietario) async {
    try {
      // Remove campos que não devem ser atualizados manualmente
      final json = proprietario.toJson();
      json.remove('criado_em'); // Não atualiza data de criação
      
      await _supabase
          .from(tableName)
          .update(json)
          .eq('id', proprietario.id);
    } catch (e) {
      throw 'Erro ao atualizar proprietário: $e';
    }
  }

  Future<void> deleteProprietario(String id) async {
    try {
      await _supabase
          .from(tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw 'Erro ao deletar proprietário: $e';
    }
  }
}
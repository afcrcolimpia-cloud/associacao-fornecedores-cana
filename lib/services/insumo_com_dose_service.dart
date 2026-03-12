import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/insumo_com_dose.dart';

class InsumoComDoseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String tableName = 'insumos_com_doses';
  static const String _columns =
      'id, categoria, tipo, produto, situacao, dose_minima, dose_maxima, unidade, preco_unitario, observacoes, data_criacao';

  Future<List<InsumoComDose>> buscarInsumos() async {
    try {
      final response = await _supabase
          .from(tableName)
          .select(_columns)
          .order('categoria')
          .order('tipo')
          .order('produto');

      return (response as List)
          .map((e) => InsumoComDose.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar insumos: $e');
    }
  }

  Future<List<InsumoComDose>> buscarPorCategoria(String categoria) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select(_columns)
          .eq('categoria', categoria)
          .order('tipo')
          .order('produto');

      return (response as List)
          .map((e) => InsumoComDose.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar insumos por categoria: $e');
    }
  }

  Future<List<InsumoComDose>> buscarPorTipo(String tipo) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select(_columns)
          .eq('tipo', tipo)
          .order('produto');

      return (response as List)
          .map((e) => InsumoComDose.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar insumos por tipo: $e');
    }
  }

  Future<InsumoComDose?> buscarPorProduto(String produto) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select(_columns)
          .eq('produto', produto)
          .maybeSingle();

      return response != null
          ? InsumoComDose.fromJson(response)
          : null;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> buscarCategorias() async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('categoria');

      final cats = (response as List)
          .map((e) => (e as Map<String, dynamic>)['categoria'] as String)
          .toSet()
          .toList();
      cats.sort();
      return cats;
    } catch (e) {
      throw Exception('Erro ao buscar categorias: $e');
    }
  }

  Future<List<String>> buscarTiposPorCategoria(String categoria) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('tipo')
          .eq('categoria', categoria);

      final tipos = (response as List)
          .map((e) => (e as Map<String, dynamic>)['tipo'] as String)
          .toSet()
          .toList();
      tipos.sort();
      return tipos;
    } catch (e) {
      throw Exception('Erro ao buscar tipos: $e');
    }
  }

  Future<List<InsumoComDose>> buscarProdutosPorCategoriaETipo(
      String categoria, String tipo) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select(_columns)
          .eq('categoria', categoria)
          .eq('tipo', tipo)
          .order('produto');

      return (response as List)
          .map((e) => InsumoComDose.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar produtos: $e');
    }
  }

  Future<InsumoComDose?> buscarPorId(String id) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select(_columns)
          .eq('id', id)
          .maybeSingle();

      return response != null ? InsumoComDose.fromJson(response) : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> salvarInsumo(InsumoComDose insumo) async {
    try {
      final dados = insumo.toJson();
      dados.remove('id');
      dados.remove('data_criacao');
      await _supabase.from(tableName).insert(dados);
    } catch (e) {
      throw Exception('Erro ao salvar insumo: $e');
    }
  }

  Future<void> atualizarInsumo(InsumoComDose insumo) async {
    try {
      final dados = insumo.toJson();
      dados.remove('id');
      dados.remove('data_criacao');
      await _supabase.from(tableName).update(dados).eq('id', insumo.id);
    } catch (e) {
      throw Exception('Erro ao atualizar insumo: $e');
    }
  }

  Future<void> deletarInsumo(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao excluir insumo: $e');
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class ProdutividadeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'produtividade';
  static const String _cols = 'id, propriedade_id, talhao_id, ano_safra, variedade, estagio, mes_colheita, peso_liquido_toneladas, media_atr, observacoes, created_at, updated_at';

  // Stream de produtividade por propriedade
  Stream<List<Produtividade>> getProdutividadePorPropriedade(String propriedadeId) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .map((data) => data
            .where((json) => json['propriedade_id'] == propriedadeId)
            .map((json) => Produtividade.fromJson(json))
            .toList());
  }

  // Stream de produtividade por propriedade e ano safra
  Stream<List<Produtividade>> getProdutividadePorPropriedadeEAno(
    String propriedadeId,
    String anoSafra,
  ) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .map((data) => data
            .where((json) =>
                json['propriedade_id'] == propriedadeId &&
                json['ano_safra'] == anoSafra)
            .map((json) => Produtividade.fromJson(json))
            .toList());
  }

  // Stream de produtividade por talhão
  Stream<List<Produtividade>> getProdutividadePorTalhao(String talhaoId) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .map((data) => data
            .where((json) => json['talhao_id'] == talhaoId)
            .map((json) => Produtividade.fromJson(json))
            .toList());
  }

  // Buscar produtividade por ID
  Future<Produtividade?> getProdutividadeById(String id) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select(_cols)
          .eq('id', id)
          .maybeSingle();
      
      if (data != null) {
        return Produtividade.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar produtividade: $e');
      return null;
    }
  }

  // Criar nova produtividade
  Future<void> createProdutividade(Produtividade produtividade) async {
    try {
      await _supabase
          .from(_tableName)
          .insert(produtividade.toJson());
    } catch (e) {
      debugPrint('Erro ao criar produtividade: $e');
      rethrow;
    }
  }

  // Atualizar produtividade
  Future<void> updateProdutividade(Produtividade produtividade) async {
    try {
      await _supabase
          .from(_tableName)
          .update(produtividade.toJson())
          .eq('id', produtividade.id);
    } catch (e) {
      debugPrint('Erro ao atualizar produtividade: $e');
      rethrow;
    }
  }

  // Deletar produtividade
  Future<void> deleteProdutividade(String id) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      debugPrint('Erro ao deletar produtividade: $e');
      rethrow;
    }
  }

  // Copiar produtividade para múltiplos talhões
  Future<void> copiarParaTalhoes(
    Produtividade produtividade,
    List<String> talhoesIds,
  ) async {
    try {
      final produtividades = talhoesIds.map((talhaoId) {
        return {
          'propriedade_id': produtividade.propriedadeId,
          'talhao_id': talhaoId,
          'ano_safra': produtividade.anoSafra,
          'variedade': produtividade.variedade,
          'estagio': produtividade.estagio,
          'mes_colheita': produtividade.mesColheita,
          'peso_liquido_toneladas': produtividade.pesoLiquidoToneladas,
          'media_atr': produtividade.mediaATR,
          'observacoes': produtividade.observacoes,
        };
      }).toList();

      await _supabase.from(_tableName).insert(produtividades);
    } catch (e) {
      debugPrint('Erro ao copiar produtividade: $e');
      rethrow;
    }
  }

  // Comparar produtividade entre dois anos
  Future<Map<String, dynamic>> compararAnos(
    String propriedadeId,
    String anoAtual,
    String anoAnterior,
  ) async {
    try {
      final dadosAtual = await _supabase
          .from(_tableName)
          .select(_cols)
          .eq('propriedade_id', propriedadeId)
          .eq('ano_safra', anoAtual);

      final dadosAnterior = await _supabase
          .from(_tableName)
          .select(_cols)
          .eq('propriedade_id', propriedadeId)
          .eq('ano_safra', anoAnterior);

      final prodAtual = dadosAtual.map((json) => Produtividade.fromJson(json)).toList();
      final prodAnterior = dadosAnterior.map((json) => Produtividade.fromJson(json)).toList();

      double totalPesoAtual = prodAtual.fold(
        0.0,
        (sum, p) => sum + (p.pesoLiquidoToneladas ?? 0),
      );

      double mediaATRAtual = prodAtual.isEmpty
          ? 0.0
          : prodAtual.fold(0.0, (sum, p) => sum + (p.mediaATR ?? 0)) / prodAtual.length;

      double totalPesoAnterior = prodAnterior.fold(
        0.0,
        (sum, p) => sum + (p.pesoLiquidoToneladas ?? 0),
      );

      double mediaATRAnterior = prodAnterior.isEmpty
          ? 0.0
          : prodAnterior.fold(0.0, (sum, p) => sum + (p.mediaATR ?? 0)) / prodAnterior.length;

      double variacaoPeso = totalPesoAnterior > 0
          ? ((totalPesoAtual - totalPesoAnterior) / totalPesoAnterior) * 100
          : 0.0;

      double variacaoATR = mediaATRAnterior > 0
          ? ((mediaATRAtual - mediaATRAnterior) / mediaATRAnterior) * 100
          : 0.0;

      return {
        'anoAtual': anoAtual,
        'anoAnterior': anoAnterior,
        'totalPesoAtual': totalPesoAtual,
        'totalPesoAnterior': totalPesoAnterior,
        'mediaATRAtual': mediaATRAtual,
        'mediaATRAnterior': mediaATRAnterior,
        'variacaoPeso': variacaoPeso,
        'variacaoATR': variacaoATR,
        'quantidadeAtual': prodAtual.length,
        'quantidadeAnterior': prodAnterior.length,
      };
    } catch (e) {
      debugPrint('Erro ao comparar anos: $e');
      return {};
    }
  }

  // Estatísticas por propriedade e ano safra
  Future<Map<String, dynamic>> getEstatisticas(
    String propriedadeId,
    String anoSafra,
  ) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select(_cols)
          .eq('propriedade_id', propriedadeId)
          .eq('ano_safra', anoSafra);

      final produtividades = data.map((json) => Produtividade.fromJson(json)).toList();

      if (produtividades.isEmpty) {
        return {
          'totalRegistros': 0,
          'totalPeso': 0.0,
          'mediaATR': 0.0,
          'maiorPeso': 0.0,
          'menorPeso': 0.0,
        };
      }

      double totalPeso = produtividades.fold(
        0.0,
        (sum, p) => sum + (p.pesoLiquidoToneladas ?? 0),
      );

      double mediaATR = produtividades.fold(
        0.0,
        (sum, p) => sum + (p.mediaATR ?? 0),
      ) / produtividades.length;
      
      List<double> pesos = produtividades
          .where((p) => p.pesoLiquidoToneladas != null)
          .map((p) => p.pesoLiquidoToneladas!)
          .toList();

      double maiorPeso = pesos.isEmpty ? 0.0 : pesos.reduce((a, b) => a > b ? a : b);
      double menorPeso = pesos.isEmpty ? 0.0 : pesos.reduce((a, b) => a < b ? a : b);

      return {
        'totalRegistros': produtividades.length,
        'totalPeso': totalPeso,
        'mediaATR': mediaATR,
        'maiorPeso': maiorPeso,
        'menorPeso': menorPeso,
      };
    } catch (e) {
      debugPrint('Erro ao buscar estatísticas: $e');
      return {};
    }
  }

  // Obter anos safra disponíveis para uma propriedade
  Future<List<String>> getAnosSafraDisponiveis(String propriedadeId) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select('ano_safra')
          .eq('propriedade_id', propriedadeId)
          .order('ano_safra', ascending: false);

      final anos = data
          .map((item) => item['ano_safra'] as String)
          .toSet()
          .toList();
      return anos;
    } catch (e) {
      debugPrint('Erro ao buscar anos safra: $e');
      return [];
    }
  }

  // Dados para gráfico por mês
  Future<List<Map<String, dynamic>>> getDadosGraficoPorMes(
    String propriedadeId,
    String anoSafra,
  ) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select(_cols)
          .eq('propriedade_id', propriedadeId)
          .eq('ano_safra', anoSafra)
          .order('mes_colheita', ascending: true);

      final produtividades = data.map((json) => Produtividade.fromJson(json)).toList();

      Map<int, double> pesosPorMes = {};
      for (var prod in produtividades) {
        if (prod.mesColheita != null && prod.pesoLiquidoToneladas != null) {
          pesosPorMes[prod.mesColheita!] = 
              (pesosPorMes[prod.mesColheita!] ?? 0.0) + prod.pesoLiquidoToneladas!;
        }
      }

      return pesosPorMes.entries.map((entry) {
        const meses = [
          'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
          'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
        ];
        return {
          'mes': meses[entry.key - 1],
          'peso': entry.value,
        };
      }).toList();
    } catch (e) {
      debugPrint('Erro ao buscar dados do gráfico: $e');
      return [];
    }
  }
}
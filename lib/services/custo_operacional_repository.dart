import 'package:supabase_flutter/supabase_flutter.dart';

final _db = Supabase.instance.client;

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────

class CategoriaModel {
  final String id;
  final String nome;
  final int? ordem;

  const CategoriaModel({
    required this.id,
    required this.nome,
    this.ordem,
  });

  factory CategoriaModel.fromMap(Map<String, dynamic> m) => CategoriaModel(
    id: m['id']?.toString() ?? '',
    nome: m['nome']?.toString() ?? '',
    ordem: m['ordem'] as int?,
  );
}

class OperacaoCatalogo {
  final String id;
  final String categoriaId;
  final String nome;

  const OperacaoCatalogo({
    required this.id,
    required this.categoriaId,
    required this.nome,
  });

  factory OperacaoCatalogo.fromMap(Map<String, dynamic> m) => OperacaoCatalogo(
    id: m['id']?.toString() ?? '',
    categoriaId: m['categoria_id']?.toString() ?? '',
    nome: m['nome']?.toString() ?? '',
  );
}

class MaquinaCatalogo {
  final String id;
  final String nome;
  final double? valorUnd;

  const MaquinaCatalogo({
    required this.id,
    required this.nome,
    this.valorUnd,
  });

  factory MaquinaCatalogo.fromMap(Map<String, dynamic> m) => MaquinaCatalogo(
    id: m['id']?.toString() ?? '',
    nome: m['nome']?.toString() ?? '',
    valorUnd: (m['valor_und'] as num?)?.toDouble(),
  );
}

class ImplementoCatalogo {
  final String id;
  final String nome;
  final double? valorUnd;

  const ImplementoCatalogo({
    required this.id,
    required this.nome,
    this.valorUnd,
  });

  factory ImplementoCatalogo.fromMap(Map<String, dynamic> m) => ImplementoCatalogo(
    id: m['id']?.toString() ?? '',
    nome: m['nome']?.toString() ?? '',
    valorUnd: (m['valor_und'] as num?)?.toDouble(),
  );
}

class InsumoCatalogo {
  final String id;
  final String nome;
  final double? valorUnd;
  final String unidade;

  const InsumoCatalogo({
    required this.id,
    required this.nome,
    this.valorUnd,
    this.unidade = 'kg',
  });

  factory InsumoCatalogo.fromMap(Map<String, dynamic> m) => InsumoCatalogo(
    id: m['id']?.toString() ?? '',
    nome: m['nome']?.toString() ?? '',
    valorUnd: (m['valor_und'] as num?)?.toDouble(),
    unidade: m['unidade']?.toString() ?? 'kg',
  );
}

class LancamentoModel {
  final String? id;
  final String propriedadeId;
  final String? talhaoId;
  final String categoriaId;
  final int safra;

  final String? operacaoId;
  final String? operacaoCustom;

  final String? maquinaId;
  final String? maquinaCustom;
  final double? maquinaValor;

  final String? implementoId;
  final String? implementoCustom;
  final double? implementoValor;

  final double? rendimento;
  final double? operacaoRha;

  final String? insumoId;
  final String? insumoCustom;
  final double? insumoPreco;
  final double? insumoDose;
  final double? insumoRha;

  final double? custoTotalRha;
  final String? observacao;

  LancamentoModel({
    this.id,
    required this.propriedadeId,
    this.talhaoId,
    required this.categoriaId,
    required this.safra,
    this.operacaoId,
    this.operacaoCustom,
    this.maquinaId,
    this.maquinaCustom,
    this.maquinaValor,
    this.implementoId,
    this.implementoCustom,
    this.implementoValor,
    this.rendimento,
    this.operacaoRha,
    this.insumoId,
    this.insumoCustom,
    this.insumoPreco,
    this.insumoDose,
    this.insumoRha,
    this.custoTotalRha,
    this.observacao,
  });

  /// Getters para cálculos automáticos
  double get operacaoValorTotal =>
      (maquinaValor ?? 0) + (implementoValor ?? 0);

  double get operacaoRhaCalc =>
      operacaoValorTotal * (rendimento ?? 0);

  double get insumoRhaCalc =>
      (insumoPreco ?? 0) * (insumoDose ?? 0);

  double get custoTotalCalc =>
      operacaoRhaCalc + insumoRhaCalc;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'propriedade_id': propriedadeId,
    if (talhaoId != null) 'talhao_id': talhaoId,
    'categoria_id': categoriaId,
    'safra': safra,
    if (operacaoId != null) 'operacao_id': operacaoId,
    if (operacaoCustom != null) 'operacao_custom': operacaoCustom,
    if (maquinaId != null) 'maquina_id': maquinaId,
    if (maquinaCustom != null) 'maquina_custom': maquinaCustom,
    if (maquinaValor != null) 'maquina_valor': maquinaValor,
    if (implementoId != null) 'implemento_id': implementoId,
    if (implementoCustom != null) 'implemento_custom': implementoCustom,
    if (implementoValor != null) 'implemento_valor': implementoValor,
    if (rendimento != null) 'rendimento': rendimento,
    'operacao_rha': operacaoRhaCalc,
    if (insumoId != null) 'insumo_id': insumoId,
    if (insumoCustom != null) 'insumo_custom': insumoCustom,
    if (insumoPreco != null) 'insumo_preco': insumoPreco,
    if (insumoDose != null) 'insumo_dose': insumoDose,
    'insumo_rha': insumoRhaCalc,
    'custo_total_rha': custoTotalCalc,
    if (observacao != null) 'observacao': observacao,
  };

  factory LancamentoModel.fromMap(Map<String, dynamic> m) => LancamentoModel(
    id: m['id']?.toString(),
    propriedadeId: m['propriedade_id']?.toString() ?? '',
    talhaoId: m['talhao_id']?.toString(),
    categoriaId: m['categoria_id']?.toString() ?? '',
    safra: m['safra'] as int? ?? 0,
    operacaoId: m['operacao_id']?.toString(),
    operacaoCustom: m['operacao_custom']?.toString(),
    maquinaId: m['maquina_id']?.toString(),
    maquinaCustom: m['maquina_custom']?.toString(),
    maquinaValor: (m['maquina_valor'] as num?)?.toDouble(),
    implementoId: m['implemento_id']?.toString(),
    implementoCustom: m['implemento_custom']?.toString(),
    implementoValor: (m['implemento_valor'] as num?)?.toDouble(),
    rendimento: (m['rendimento'] as num?)?.toDouble(),
    operacaoRha: (m['operacao_rha'] as num?)?.toDouble(),
    insumoId: m['insumo_id']?.toString(),
    insumoCustom: m['insumo_custom']?.toString(),
    insumoPreco: (m['insumo_preco'] as num?)?.toDouble(),
    insumoDose: (m['insumo_dose'] as num?)?.toDouble(),
    insumoRha: (m['insumo_rha'] as num?)?.toDouble(),
    custoTotalRha: (m['custo_total_rha'] as num?)?.toDouble(),
    observacao: m['observacao']?.toString(),
  );
}

// ─────────────────────────────────────────────
// REPOSITORY
// ─────────────────────────────────────────────

class CustoOperacionalRepository {
  String? _normalizarCategoria(String? categoriaId, String? categoriaNome) {
    final bruto = '${categoriaId ?? ''} ${categoriaNome ?? ''}'.toLowerCase();
    final normalizado = bruto
        .replaceAll('ã', 'a')
        .replaceAll('á', 'a')
        .replaceAll('â', 'a')
        .replaceAll('à', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');

    if (normalizado.contains('conserv')) return 'conservacao';
    if (normalizado.contains('preparo')) return 'preparo';
    if (normalizado.contains('plantio')) return 'plantio';
    if (normalizado.contains('manut')) return 'manutencao';
    if (normalizado.contains('colheita')) return 'colheita';

    return null;
  }

  /// Carrega todas as categorias
  Future<List<CategoriaModel>> getCategorias() async {
    try {
      final res = await _db
          .from('co_categorias')
          .select()
          .eq('ativo', true)
          .order('ordem');
      return (res as List).map((e) => CategoriaModel.fromMap(e)).toList();
    } catch (e) {
      // print('Erro ao buscar categorias: $e');
      return [];
    }
  }

  /// Busca operações da categoria
  Future<List<OperacaoCatalogo>> getOperacoesByCategoria(String categoriaId) async {
    try {
      final res = await _db
          .from('co_operacoes_catalogo')
          .select()
          .eq('categoria_id', categoriaId)
          .eq('ativo', true)
          .order('nome');
      return (res as List).map((e) => OperacaoCatalogo.fromMap(e)).toList();
    } catch (e) {
      // print('Erro ao buscar operações: $e');
      return [];
    }
  }

  /// Busca operações por texto
  Future<List<OperacaoCatalogo>> searchOperacoes(String query) async {
    try {
      final res = await _db
          .from('co_operacoes_catalogo')
          .select()
          .ilike('nome', '%$query%')
          .eq('ativo', true)
          .limit(20);
      return (res as List).map((e) => OperacaoCatalogo.fromMap(e)).toList();
    } catch (e) {
      // print('Erro na busca de operações: $e');
      return [];
    }
  }

  /// Busca máquinas
  Future<List<MaquinaCatalogo>> getMaquinas({String? query}) async {
    try {
      var req = _db.from('co_maquinas_catalogo').select().eq('ativo', true);
      if (query != null && query.isNotEmpty) {
        req = req.ilike('nome', '%$query%');
      }
      final res = await req.order('nome').limit(30);
      return (res as List).map((e) => MaquinaCatalogo.fromMap(e)).toList();
    } catch (e) {
      // print('Erro ao buscar máquinas: $e');
      return [];
    }
  }

  /// Busca implementos
  Future<List<ImplementoCatalogo>> getImplementos({String? query}) async {
    try {
      var req = _db.from('co_implementos_catalogo').select().eq('ativo', true);
      if (query != null && query.isNotEmpty) {
        req = req.ilike('nome', '%$query%');
      }
      final res = await req.order('nome').limit(30);
      return (res as List).map((e) => ImplementoCatalogo.fromMap(e)).toList();
    } catch (e) {
      // print('Erro ao buscar implementos: $e');
      return [];
    }
  }

  /// Busca insumos
  Future<List<InsumoCatalogo>> getInsumos({String? query}) async {
    try {
      var req = _db.from('co_insumos_catalogo').select().eq('ativo', true);
      if (query != null && query.isNotEmpty) {
        req = req.ilike('nome', '%$query%');
      }
      final res = await req.order('nome').limit(30);
      return (res as List).map((e) => InsumoCatalogo.fromMap(e)).toList();
    } catch (e) {
      // print('Erro ao buscar insumos: $e');
      return [];
    }
  }

  /// Busca lançamentos
  /// Alias para getCategorias (busca todas as categorias ativas)
  Future<List<CategoriaModel>> buscarCategorias() => getCategorias();

  /// Busca lançamentos por categoria
  Future<List<LancamentoModel>> buscarLancamentosPorCategoria(
    String propriedadeId,
    String categoriaId,
    int safra,
  ) {
    return getLancamentos(
      propriedadeId: propriedadeId,
      categoriaId: categoriaId,
      safra: safra,
    );
  }

  Future<List<LancamentoModel>> getLancamentos({
    String? propriedadeId,
    String? categoriaId,
    int? safra,
  }) async {
    try {
      var req = _db.from('co_lancamentos').select();
      if (propriedadeId != null) req = req.eq('propriedade_id', propriedadeId);
      if (categoriaId != null) req = req.eq('categoria_id', categoriaId);
      if (safra != null) req = req.eq('safra', safra);
      final res = await req.order('criado_em');
      return (res as List).map((e) => LancamentoModel.fromMap(e)).toList();
    } catch (e) {
      // print('Erro ao buscar lançamentos: $e');
      return [];
    }
  }

  /// Salva lançamento (insert ou update)
  Future<LancamentoModel?> salvarLancamento(LancamentoModel lancamento) async {
    try {
      if (lancamento.id == null) {
        final res = await _db
            .from('co_lancamentos')
            .insert(lancamento.toMap())
            .select()
            .single();
        return LancamentoModel.fromMap(res);
      } else {
        final res = await _db
            .from('co_lancamentos')
            .update(lancamento.toMap())
            .eq('id', lancamento.id!)
            .select()
            .single();
        return LancamentoModel.fromMap(res);
      }
    } catch (e) {
      // print('Erro ao salvar lançamento: $e');
      return null;
    }
  }

  /// Deleta lançamento
  Future<bool> deletarLancamento(String id) async {
    try {
      await _db.from('co_lancamentos').delete().eq('id', id);
      return true;
    } catch (e) {
      // print('Erro ao deletar lançamento: $e');
      return false;
    }
  }

  /// Calcula totais por categoria
  Future<Map<String, double>> getTotaisPorCategoria({
    required String propriedadeId,
    required int safra,
  }) async {
    try {
      final res = await _db
          .from('co_lancamentos')
          .select('categoria_id, custo_total_rha, co_categorias(nome)')
          .eq('propriedade_id', propriedadeId)
          .eq('safra', safra);

      final Map<String, double> totais = {};
      for (final row in (res as List)) {
        final cat = _normalizarCategoria(
          row['categoria_id']?.toString(),
          row['co_categorias']?['nome']?.toString(),
        );
        if (cat == null) continue;
        final val = (row['custo_total_rha'] as num?)?.toDouble() ?? 0.0;
        totais[cat] = (totais[cat] ?? 0) + val;
      }
      return totais;
    } catch (e) {
      // print('Erro ao calcular totais: $e');
      return {};
    }
  }

  /// Cadastra nova máquina no catálogo
  Future<MaquinaCatalogo?> cadastrarMaquina(String nome, double valorUnd) async {
    try {
      final res = await _db
          .from('co_maquinas_catalogo')
          .insert({'nome': nome, 'valor_und': valorUnd})
          .select()
          .single();
      return MaquinaCatalogo.fromMap(res);
    } catch (e) {
      // print('Erro ao cadastrar máquina: $e');
      return null;
    }
  }

  /// Cadastra novo implemento
  Future<ImplementoCatalogo?> cadastrarImplemento(String nome, double valorUnd) async {
    try {
      final res = await _db
          .from('co_implementos_catalogo')
          .insert({'nome': nome, 'valor_und': valorUnd})
          .select()
          .single();
      return ImplementoCatalogo.fromMap(res);
    } catch (e) {
      // print('Erro ao cadastrar implemento: $e');
      return null;
    }
  }

  /// Cadastra novo insumo
  Future<InsumoCatalogo?> cadastrarInsumo(
      String nome, double valorUnd, String unidade) async {
    try {
      final res = await _db
          .from('co_insumos_catalogo')
          .insert({
            'nome': nome,
            'valor_und': valorUnd,
            'unidade': unidade,
          })
          .select()
          .single();
      return InsumoCatalogo.fromMap(res);
    } catch (e) {
      // print('Erro ao cadastrar insumo: $e');
      return null;
    }
  }
}

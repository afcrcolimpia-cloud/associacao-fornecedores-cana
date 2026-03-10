import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/operacao_custos.dart';
import 'custo_operacional_repository.dart';
import 'dados_custo_operacional.dart';

class CustoOperacionalCenario {
  final String? id;
  final String propriedadeId;
  final String periodoRef;
  final String nomeCenario;

  // ParÃ¢metros TÃ©cnicos
  final double produtividade;
  final int atr;
  final int? longevidade;
  final double? doseMuda;

  // PreÃ§os e Custos
  final double? precoDiesel;
  final double? custoAdministrativo;
  final double? arrendamento;
  final double? atrArrend; // kg/t — aceita decimais (ex: 118.6)
  final double? precoAtr;

  // Totais
  final double? totalOperacional;
  final double? margemLucro;
  final double? margemLucroPorTonelada;

  // Metadados
  final bool ativo;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  CustoOperacionalCenario({
    this.id,
    required this.propriedadeId,
    required this.periodoRef,
    required this.nomeCenario,
    required this.produtividade,
    required this.atr,
    this.longevidade,
    this.doseMuda,
    this.precoDiesel,
    this.custoAdministrativo,
    this.arrendamento,
    this.atrArrend,
    this.precoAtr,
    this.totalOperacional,
    this.margemLucro,
    this.margemLucroPorTonelada,
    this.ativo = true,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory CustoOperacionalCenario.fromJson(Map<String, dynamic> json) {
    return CustoOperacionalCenario(
      id: json['id'],
      propriedadeId: json['propriedade_id'] ?? '',
      periodoRef: json['periodo_ref'] ?? '',
      nomeCenario: json['nome_cenario'] ?? '',
      produtividade: (json['produtividade'] as num?)?.toDouble() ?? 0,
      atr: json['atr'] ?? 138,
      longevidade: json['longevidade'],
      doseMuda: (json['dose_muda'] as num?)?.toDouble(),
      precoDiesel: (json['preco_diesel'] as num?)?.toDouble(),
      custoAdministrativo: (json['custo_administrativo'] as num?)?.toDouble(),
      arrendamento: (json['arrendamento'] as num?)?.toDouble(),
      atrArrend: (json['atr_arrend'] as num?)?.toDouble(),
      precoAtr: (json['preco_atr'] as num?)?.toDouble(),
      totalOperacional: (json['total_operacional'] as num?)?.toDouble(),
      margemLucro: (json['margem_lucro'] as num?)?.toDouble(),
      margemLucroPorTonelada:
          (json['margem_lucro_por_tonelada'] as num?)?.toDouble(),
      ativo: json['ativo'] ?? true,
      criadoEm:
          json['criado_em'] != null ? DateTime.parse(json['criado_em']) : null,
      atualizadoEm: json['atualizado_em'] != null
          ? DateTime.parse(json['atualizado_em'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'propriedade_id': propriedadeId,
      'periodo_ref': periodoRef,
      'nome_cenario': nomeCenario,
      'produtividade': produtividade,
      'atr': atr,
      'longevidade': longevidade,
      'dose_muda': doseMuda,
      'preco_diesel': precoDiesel,
      'custo_administrativo': custoAdministrativo,
      'arrendamento': arrendamento,
      'atr_arrend': atrArrend,
      'preco_atr': precoAtr,
      'total_operacional': totalOperacional,
      'margem_lucro': margemLucro,
      'margem_lucro_por_tonelada': margemLucroPorTonelada,
      'ativo': ativo,
    };
  }
}

class CustoOperacionalService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String tableName = 'custo_operacional_cenarios';
  final String historyTable = 'custo_operacional_historico';
  final CustoOperacionalRepository _repo = CustoOperacionalRepository();

  // ==================== LEITURA ====================

  /// Buscar cenÃ¡rios de uma propriedade
  Future<List<CustoOperacionalCenario>> getCenariosByPropriedade(
    String propriedadeId,
  ) async {
    try {
      final data = await _supabase
          .from(tableName)
          .select()
          .eq('propriedade_id', propriedadeId)
          .eq('ativo', true)
          .order('atualizado_em', ascending: false);

      return (data as List)
          .map((json) => CustoOperacionalCenario.fromJson(json))
          .toList();
    } catch (e) {
      throw 'Erro ao buscar cenÃ¡rios: $e';
    }
  }

  /// Buscar um cenÃ¡rio especÃ­fico
  Future<CustoOperacionalCenario?> getCenario(String cenarioId) async {
    try {
      final data = await _supabase
          .from(tableName)
          .select()
          .eq('id', cenarioId)
          .maybeSingle();

      if (data == null) return null;
      return CustoOperacionalCenario.fromJson(data);
    } catch (e) {
      throw 'Erro ao buscar cenÃ¡rio: $e';
    }
  }

  /// Stream dos cenÃ¡rios (para atualizaÃ§Ã£o em tempo real)
  Stream<List<CustoOperacionalCenario>> getCenariosByPropriedadeStream(
    String propriedadeId,
  ) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: ['id'])
        .map((data) => data
            .where((json) =>
                json['propriedade_id'] == propriedadeId &&
                json['ativo'] == true)
            .toList()
            .map((json) => CustoOperacionalCenario.fromJson(json))
            .toList())
        .asBroadcastStream();
  }

  Future<Map<String, double>> obterTotaisCategorias(
    String propriedadeId,
    String periodoRef,
  ) async {
    final safra = _inferirSafra(periodoRef);
    return _repo.getTotaisPorCategoria(
      propriedadeId: propriedadeId,
      safra: safra,
    );
  }

  Future<Map<String, double>> obterTotaisCategoriasCenario(
    CustoOperacionalCenario cenario,
  ) {
    return obterTotaisCategorias(cenario.propriedadeId, cenario.periodoRef);
  }

  ResumoCustoOperacionalCalculado calcularResumoComTotais({
    required CustoOperacionalCenario cenario,
    Map<String, double> totaisCategorias = const {},
  }) {
    final parametrosBase = DadosCustoOperacional.parametros;
    final produtividade = cenario.produtividade > 0
        ? cenario.produtividade
        : parametrosBase.produtividade;
    final atr = cenario.atr > 0 ? cenario.atr.toDouble() : parametrosBase.atr.toDouble();
    final longevidade = (cenario.longevidade ?? parametrosBase.longevidade) > 0
        ? (cenario.longevidade ?? parametrosBase.longevidade)
        : parametrosBase.longevidade;
    final precoAtr = cenario.precoAtr ?? parametrosBase.precoATR;
    final custoAdministrativoPercentual =
        cenario.custoAdministrativo ?? parametrosBase.custoAdmin;
    final arrendamento = cenario.arrendamento ?? parametrosBase.arrendamento;
    final atrArrend = cenario.atrArrend ?? parametrosBase.atrArrend;

    final conservacaoHa =
        totaisCategorias['conservacao'] ?? DadosCustoOperacional.conservacaoSolo.total;
    final preparoHa =
        totaisCategorias['preparo'] ?? DadosCustoOperacional.preparoSolo.total;
    final plantioHa =
        totaisCategorias['plantio'] ?? DadosCustoOperacional.plantio.total;
    final manutencaoHa = totaisCategorias['manutencao'] ??
        DadosCustoOperacional.manutencaoSoqueira.total;
    final colheitaHa =
        totaisCategorias['colheita'] ?? DadosCustoOperacional.colheita.total;
    final subtotalOperacionalHa =
        conservacaoHa + preparoHa + plantioHa + manutencaoHa + colheitaHa;
    final administrativoHa = _calcularAdministrativoHa(
      subtotalOperacionalHa: subtotalOperacionalHa,
      custoAdministrativoInformado: custoAdministrativoPercentual,
    );
    final arrendamentoHa = arrendamento * atrArrend * precoAtr;

    final totalRHa = _calcularTotalOperacional(
      conservacaoHa: conservacaoHa,
      preparoHa: preparoHa,
      plantioHa: plantioHa,
      manutencaoHa: manutencaoHa,
      colheitaHa: colheitaHa,
      administrativoHa: administrativoHa,
      arrendamentoHa: arrendamentoHa,
    );

    ResumoEstagio resumoLinha({
      required String estagio,
      required double rHa,
      required bool amortizar,
    }) {
      final rTBase = produtividade > 0 ? rHa / produtividade : 0.0;
      final rT = amortizar ? rTBase / longevidade : rTBase;
      final rKgAtr = atr > 0 ? rT / atr : 0.0;
      final participacao = totalRHa > 0 ? (rHa / totalRHa) * 100 : 0.0;

      return ResumoEstagio(
        estagio: estagio,
        rHa: rHa,
        rT: rT,
        rKgATR: rKgAtr,
        pct: '${participacao.toStringAsFixed(1)}%',
      );
    }

    final linhasResumo = [
      resumoLinha(
        estagio: 'Conservação de solo',
        rHa: conservacaoHa,
        amortizar: true,
      ),
      resumoLinha(
        estagio: 'Preparo de solo',
        rHa: preparoHa,
        amortizar: true,
      ),
      resumoLinha(
        estagio: 'Plantio',
        rHa: plantioHa,
        amortizar: true,
      ),
      resumoLinha(
        estagio: 'Manutenção de soqueira',
        rHa: manutencaoHa,
        amortizar: false,
      ),
      resumoLinha(
        estagio: 'Sistema de colheita',
        rHa: colheitaHa,
        amortizar: false,
      ),
      resumoLinha(
        estagio: 'Administrativo',
        rHa: administrativoHa,
        amortizar: false,
      ),
      resumoLinha(
        estagio: 'Arrendamento',
        rHa: arrendamentoHa,
        amortizar: false,
      ),
    ];

    final totalRT = linhasResumo.fold<double>(
      0.0,
      (soma, linha) => soma + linha.rT,
    );
    final totalRKgAtr = atr > 0 ? totalRT / atr : 0.0;
    final precoRecebidoRT = atr * precoAtr;
    final precoRecebidoRKgAtr = precoAtr;
    final margemRT = precoRecebidoRT - totalRT;
    final margemRHa = margemRT * produtividade;
    final margemRKgAtr = atr > 0 ? margemRT / atr : 0.0;
    final margemPercentual = precoRecebidoRT > 0
        ? (margemRT / precoRecebidoRT) * 100
        : 0.0;

    return ResumoCustoOperacionalCalculado(
      linhasResumo: linhasResumo,
      totalOperacional: TotalOperacional(
        rHa: totalRHa,
        rT: totalRT,
        rKgATR: totalRKgAtr,
      ),
      precoRecebido: TotalOperacional(
        rHa: 0.0,
        rT: precoRecebidoRT,
        rKgATR: precoRecebidoRKgAtr,
      ),
      margemLucro: TotalOperacional(
        rHa: margemRHa,
        rT: margemRT,
        rKgATR: margemRKgAtr,
      ),
      margemPercentual: margemPercentual,
    );
  }

  Future<ResumoCustoOperacionalCalculado> montarResumoCenario(
    CustoOperacionalCenario cenario,
  ) async {
    final totaisCategorias = await obterTotaisCategoriasCenario(cenario);
    if (totaisCategorias.isEmpty &&
        cenario.totalOperacional != null &&
        cenario.margemLucro != null &&
        cenario.margemLucroPorTonelada != null) {
      final resumoBase = calcularResumoComTotais(cenario: cenario);
      final produtividade = cenario.produtividade > 0
          ? cenario.produtividade
          : DadosCustoOperacional.parametros.produtividade;
      final atr = cenario.atr > 0
          ? cenario.atr.toDouble()
          : DadosCustoOperacional.parametros.atr.toDouble();
      final totalRT = produtividade > 0 ? cenario.totalOperacional! / produtividade : 0.0;
      final totalRKgAtr = atr > 0 ? totalRT / atr : 0.0;
      final margemRHa = cenario.margemLucroPorTonelada! * produtividade;
      final margemRKgAtr =
          atr > 0 ? cenario.margemLucroPorTonelada! / atr : 0.0;

      return ResumoCustoOperacionalCalculado(
        linhasResumo: resumoBase.linhasResumo,
        totalOperacional: TotalOperacional(
          rHa: cenario.totalOperacional!,
          rT: totalRT,
          rKgATR: totalRKgAtr,
        ),
        precoRecebido: resumoBase.precoRecebido,
        margemLucro: TotalOperacional(
          rHa: margemRHa,
          rT: cenario.margemLucroPorTonelada!,
          rKgATR: margemRKgAtr,
        ),
        margemPercentual: cenario.margemLucro!,
      );
    }

    return calcularResumoComTotais(
      cenario: cenario,
      totaisCategorias: totaisCategorias,
    );
  }

  // ==================== CRIAR ====================

  /// Criar novo cenÃ¡rio
  Future<String> criarCenario(CustoOperacionalCenario cenario) async {
    try {
      final user = _supabase.auth.currentUser;

      final resumo = await montarResumoCenario(cenario);

      final data = await _supabase
          .from(tableName)
          .insert({
            ...cenario.toJson(),
            'total_operacional': resumo.totalOperacional.rHa,
            'margem_lucro': resumo.margemPercentual,
            'margem_lucro_por_tonelada': resumo.margemLucro.rT,
            'criado_por': user?.id,
          })
          .select('id')
          .single();

      return data['id'] as String;
    } catch (e) {
      throw 'Erro ao criar cenÃ¡rio: $e';
    }
  }

  // ==================== ATUALIZAR ====================

  /// Atualizar cenÃ¡rio (com histÃ³rico de alteraÃ§Ãµes)
  Future<void> atualizarCenario(
    String cenarioId,
    CustoOperacionalCenario cenarioAtualizado,
  ) async {
    try {
      final user = _supabase.auth.currentUser;

      // Buscar cenÃ¡rio atual para comparaÃ§Ã£o
      final cenarioAtual = await getCenario(cenarioId);
      if (cenarioAtual == null) throw 'CenÃ¡rio nÃ£o encontrado';

      final resumo = await montarResumoCenario(cenarioAtualizado);

      final cenarioComTotais = CustoOperacionalCenario(
        id: cenarioAtualizado.id,
        propriedadeId: cenarioAtualizado.propriedadeId,
        periodoRef: cenarioAtualizado.periodoRef,
        nomeCenario: cenarioAtualizado.nomeCenario,
        produtividade: cenarioAtualizado.produtividade,
        atr: cenarioAtualizado.atr,
        longevidade: cenarioAtualizado.longevidade,
        doseMuda: cenarioAtualizado.doseMuda,
        precoDiesel: cenarioAtualizado.precoDiesel,
        custoAdministrativo: cenarioAtualizado.custoAdministrativo,
        arrendamento: cenarioAtualizado.arrendamento,
        atrArrend: cenarioAtualizado.atrArrend,
        precoAtr: cenarioAtualizado.precoAtr,
        totalOperacional: resumo.totalOperacional.rHa,
        margemLucro: resumo.margemPercentual,
        margemLucroPorTonelada: resumo.margemLucro.rT,
        ativo: cenarioAtualizado.ativo,
        criadoEm: cenarioAtualizado.criadoEm,
        atualizadoEm: cenarioAtualizado.atualizadoEm,
      );

      // Atualizar cenÃ¡rio
      await _supabase
          .from(tableName)
          .update(cenarioComTotais.toJson())
          .eq('id', cenarioId);

      // Registrar alteraÃ§Ãµes no histÃ³rico
      await _registrarHistorico(
        cenarioId,
        cenarioAtual,
        cenarioComTotais,
        user?.id,
      );
    } catch (e) {
      throw 'Erro ao atualizar cenÃ¡rio: $e';
    }
  }

  // ==================== DELETAR ====================

  /// Deletar (soft delete - marca como inativo)
  Future<void> deletarCenario(String cenarioId) async {
    try {
      await _supabase
          .from(tableName)
          .update({'ativo': false}).eq('id', cenarioId);
    } catch (e) {
      throw 'Erro ao deletar cenÃ¡rio: $e';
    }
  }

  // ==================== HISTÃ“RICO ====================

  /// Registrar alteraÃ§Ãµes no histÃ³rico
  Future<void> _registrarHistorico(
    String cenarioId,
    CustoOperacionalCenario cenarioAtual,
    CustoOperacionalCenario cenarioNovo,
    String? usuarioId,
  ) async {
    try {
      final historico = <Map<String, dynamic>>[];

      // Comparar cada campo
      if (cenarioAtual.nomeCenario != cenarioNovo.nomeCenario) {
        historico.add(_criarRegistroHistorico(
          cenarioId,
          cenarioNovo.propriedadeId,
          'nome_cenario',
          cenarioAtual.nomeCenario,
          cenarioNovo.nomeCenario,
          usuarioId,
        ));
      }

      if (cenarioAtual.produtividade != cenarioNovo.produtividade) {
        historico.add(_criarRegistroHistorico(
          cenarioId,
          cenarioNovo.propriedadeId,
          'produtividade',
          cenarioAtual.produtividade.toString(),
          cenarioNovo.produtividade.toString(),
          usuarioId,
        ));
      }

      if (cenarioAtual.atr != cenarioNovo.atr) {
        historico.add(_criarRegistroHistorico(
          cenarioId,
          cenarioNovo.propriedadeId,
          'atr',
          cenarioAtual.atr.toString(),
          cenarioNovo.atr.toString(),
          usuarioId,
        ));
      }

      if (cenarioAtual.precoAtr != cenarioNovo.precoAtr) {
        historico.add(_criarRegistroHistorico(
          cenarioId,
          cenarioNovo.propriedadeId,
          'preco_atr',
          cenarioAtual.precoAtr?.toString() ?? 'null',
          cenarioNovo.precoAtr?.toString() ?? 'null',
          usuarioId,
        ));
      }

      if (cenarioAtual.arrendamento != cenarioNovo.arrendamento) {
        historico.add(_criarRegistroHistorico(
          cenarioId,
          cenarioNovo.propriedadeId,
          'arrendamento',
          cenarioAtual.arrendamento?.toString() ?? 'null',
          cenarioNovo.arrendamento?.toString() ?? 'null',
          usuarioId,
        ));
      }

      if (cenarioAtual.periodoRef != cenarioNovo.periodoRef) {
        historico.add(_criarRegistroHistorico(
          cenarioId,
          cenarioNovo.propriedadeId,
          'periodo_ref',
          cenarioAtual.periodoRef,
          cenarioNovo.periodoRef,
          usuarioId,
        ));
      }

      if (cenarioAtual.longevidade != cenarioNovo.longevidade) {
        historico.add(_criarRegistroHistorico(
          cenarioId,
          cenarioNovo.propriedadeId,
          'longevidade',
          cenarioAtual.longevidade?.toString() ?? 'null',
          cenarioNovo.longevidade?.toString() ?? 'null',
          usuarioId,
        ));
      }

      if (cenarioAtual.doseMuda != cenarioNovo.doseMuda) {
        historico.add(_criarRegistroHistorico(
          cenarioId,
          cenarioNovo.propriedadeId,
          'dose_muda',
          cenarioAtual.doseMuda?.toString() ?? 'null',
          cenarioNovo.doseMuda?.toString() ?? 'null',
          usuarioId,
        ));
      }

      if (cenarioAtual.precoDiesel != cenarioNovo.precoDiesel) {
        historico.add(_criarRegistroHistorico(
          cenarioId,
          cenarioNovo.propriedadeId,
          'preco_diesel',
          cenarioAtual.precoDiesel?.toString() ?? 'null',
          cenarioNovo.precoDiesel?.toString() ?? 'null',
          usuarioId,
        ));
      }

      if (cenarioAtual.custoAdministrativo != cenarioNovo.custoAdministrativo) {
        historico.add(_criarRegistroHistorico(
          cenarioId,
          cenarioNovo.propriedadeId,
          'custo_administrativo',
          cenarioAtual.custoAdministrativo?.toString() ?? 'null',
          cenarioNovo.custoAdministrativo?.toString() ?? 'null',
          usuarioId,
        ));
      }

      if (cenarioAtual.atrArrend != cenarioNovo.atrArrend) {
        historico.add(_criarRegistroHistorico(
          cenarioId,
          cenarioNovo.propriedadeId,
          'atr_arrend',
          cenarioAtual.atrArrend?.toString() ?? 'null',
          cenarioNovo.atrArrend?.toString() ?? 'null',
          usuarioId,
        ));
      }

      if (cenarioAtual.totalOperacional != cenarioNovo.totalOperacional) {
        historico.add(_criarRegistroHistorico(
          cenarioId,
          cenarioNovo.propriedadeId,
          'total_operacional',
          cenarioAtual.totalOperacional?.toString() ?? 'null',
          cenarioNovo.totalOperacional?.toString() ?? 'null',
          usuarioId,
        ));
      }

      if (cenarioAtual.margemLucro != cenarioNovo.margemLucro) {
        historico.add(_criarRegistroHistorico(
          cenarioId,
          cenarioNovo.propriedadeId,
          'margem_lucro',
          cenarioAtual.margemLucro?.toString() ?? 'null',
          cenarioNovo.margemLucro?.toString() ?? 'null',
          usuarioId,
        ));
      }

      if (cenarioAtual.margemLucroPorTonelada !=
          cenarioNovo.margemLucroPorTonelada) {
        historico.add(_criarRegistroHistorico(
          cenarioId,
          cenarioNovo.propriedadeId,
          'margem_lucro_por_tonelada',
          cenarioAtual.margemLucroPorTonelada?.toString() ?? 'null',
          cenarioNovo.margemLucroPorTonelada?.toString() ?? 'null',
          usuarioId,
        ));
      }

      if (historico.isNotEmpty) {
        await _supabase.from(historyTable).insert(historico);
      }
    } catch (e) {
      debugPrint('Erro ao registrar histÃ³rico: $e');
      // NÃ£o lanÃ§ar erro, apenas registrar
    }
  }

  Map<String, dynamic> _criarRegistroHistorico(
    String cenarioId,
    String propriedadeId,
    String campoAlterado,
    String valorAnterior,
    String valorNovo,
    String? alteradoPor,
  ) {
    return {
      'cenario_id': cenarioId,
      'propriedade_id': propriedadeId,
      'campo_alterado': campoAlterado,
      'valor_anterior': valorAnterior,
      'valor_novo': valorNovo,
      'alterado_por': alteradoPor,
    };
  }

  // ==================== HISTÃ“RICO (LEITURA) ====================

  /// Buscar histÃ³rico de um cenÃ¡rio
  Future<List<Map<String, dynamic>>> getHistoricoCenario(
    String cenarioId,
  ) async {
    try {
      final data = await _supabase
          .from(historyTable)
          .select()
          .eq('cenario_id', cenarioId)
          .order('alterado_em', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw 'Erro ao buscar histÃ³rico: $e';
    }
  }

  // ==================== CÃLCULOS ECONÃ”MICOS ====================

  /// Calcular margem R$/t
  /// Fórmula: Preço R$/t − Total R$/t
  ///   Preço R$/t = ATR (kg/t) × Preço ATR (R$/kg)
  ///   Total R$/t = totalOperacional (R$/ha) ÷ produtividade
  /// Margem R$/ha = margemPorTonelada × produtividade
  double calcularMargemPorTonelada(
    double totalOperacional,
    double precoAtr,
    int atr,
    double produtividade,
  ) {
    if (produtividade <= 0) return 0.0;
    final precoRpt = atr * precoAtr;          // R$/t recebido
    final totalRpt = totalOperacional / produtividade; // R$/t gasto
    return precoRpt - totalRpt;               // margem R$/t
  }

  /// Calcular ponto de equilÃ­brio (produtividade mÃ­nima)
  double calcularProdutividadeMinima(
    double totalOperacional,
    int atr,
    double precoAtr,
  ) {
    if (atr == 0 || precoAtr == 0) return 0;
    return totalOperacional / (atr * precoAtr);
  }

  /// Calcular preÃ§o mÃ­nimo do ATR para viabilidade
  double calcularPrecoAtrMinimo(
    double totalOperacional,
    int atr,
    double produtividade,
  ) {
    if (atr == 0 || produtividade == 0) return 0;
    return totalOperacional / (atr * produtividade);
  }

  Future<void> recalcularTotaisCenario(String cenarioId) async {
    final cenarioAtual = await getCenario(cenarioId);
    if (cenarioAtual == null) return;

    final resumo = await montarResumoCenario(cenarioAtual);

    await _supabase.from(tableName).update({
      'total_operacional': resumo.totalOperacional.rHa,
      'margem_lucro': resumo.margemPercentual,
      'margem_lucro_por_tonelada': resumo.margemLucro.rT,
    }).eq('id', cenarioId);
  }

  Future<void> recalcularTotaisPorPropriedadeSafra(
    String propriedadeId,
    int safra,
  ) async {
    final cenarios = await getCenariosByPropriedade(propriedadeId);
    for (final cenario in cenarios) {
      if (cenario.id == null) continue;
      if (_inferirSafra(cenario.periodoRef) != safra) continue;
      await recalcularTotaisCenario(cenario.id!);
    }
  }

  int _inferirSafra(String periodoRef) {
    final matches = RegExp(r'(20\d{2})').allMatches(periodoRef);
    if (matches.isNotEmpty) {
      return int.parse(matches.last.group(1)!);
    }
    return DateTime.now().year;
  }

  double _calcularTotalOperacional({
    required double conservacaoHa,
    required double preparoHa,
    required double plantioHa,
    required double manutencaoHa,
    required double colheitaHa,
    required double administrativoHa,
    required double arrendamentoHa,
  }) {

    // Busca os valores de cada categoria (R$/ha das tabelas operacionais)
    // Se o produtor não tiver lançamentos, usa os dados de referência AFCRC 2026
    return conservacaoHa +
        preparoHa +
        plantioHa +
        manutencaoHa +
        colheitaHa +

    // Formação do canavial = Conservação + Preparo + Plantio
    // (custos que ocorrem apenas 1 vez no ciclo de vida)
        administrativoHa +

    // Custo Administrativo: valor fixo em R$/ha — NÃO é calculado como %
    // O campo custoAdmin do model armazena R$/ha (padrão AFCRC 2026: R$ 168,00)
        arrendamentoHa;

    // Arrendamento = arrendamento (t/ha) × ATR arrend. (kg/t) × Preço ATR (R$/kg)

    // ── TOTAL R$/ha ──────────────────────────────────────────────────────────
    // = Formação + Manutenção + Colheita + Administrativo + Arrendamento
    // ATENÇÃO: NÃO somar Conservação/Preparo/Plantio individualmente —
    // eles já estão dentro de Formação (dupla contagem).
  }

  double _calcularAdministrativoHa({
    required double subtotalOperacionalHa,
    required double custoAdministrativoInformado,
  }) {
    if (subtotalOperacionalHa <= 0 || custoAdministrativoInformado <= 0) {
      return 0.0;
    }

    // Compatibilidade com cenÃ¡rios antigos salvos quando o campo ainda era R$/ha.
    if (custoAdministrativoInformado > 100) {
      return custoAdministrativoInformado;
    }

    return subtotalOperacionalHa * (custoAdministrativoInformado / 100);
  }
}

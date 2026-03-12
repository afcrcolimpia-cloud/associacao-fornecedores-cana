class MonitoramentoPraga {
  final String id;
  final String talhaoId;
  final String? safraId;
  final String praga;
  final String nivelInfestacao;
  final DateTime dataMonitoramento;
  final double? areaAfetadaHa;
  final String? metodoAvaliacao;
  final String? acaoRecomendada;
  final String? acaoRealizada;
  final String? insumoUtilizado;
  final double? doseAplicada;
  final String? unidadeDose;
  final String? responsavel;
  final String? observacoes;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  MonitoramentoPraga({
    required this.id,
    required this.talhaoId,
    this.safraId,
    required this.praga,
    required this.nivelInfestacao,
    required this.dataMonitoramento,
    this.areaAfetadaHa,
    this.metodoAvaliacao,
    this.acaoRecomendada,
    this.acaoRealizada,
    this.insumoUtilizado,
    this.doseAplicada,
    this.unidadeDose,
    this.responsavel,
    this.observacoes,
    this.criadoEm,
    this.atualizadoEm,
  });

  // ── Pragas disponíveis ──────────────────────────────
  static const List<String> pragasDisponiveis = [
    'Broca-da-cana (Diatraea saccharalis)',
    'Cigarrinha-das-raízes (Mahanarva fimbriolata)',
    'Sphenophorus levis',
    'Migdolus fryanus',
    'Cupins',
    'Formigas cortadeiras',
    'Lagarta-do-cartucho (Spodoptera frugiperda)',
    'Percevejo-castanho',
    'Bicudo-da-cana (Sphenophorus)',
    'Mosca-do-broto',
    'Nematoides',
    'Outra',
  ];

  static const List<String> niveisInfestacao = [
    'baixo',
    'medio',
    'alto',
    'critico',
  ];

  static const List<String> metodosAvaliacao = [
    'Levantamento visual',
    'Armadilha',
    'Contagem por metro linear',
    'Índice de infestação (%)',
    'Amostragem aleatória',
    'Outro',
  ];

  // ── Getters computados ──────────────────────────────

  String get nivelFormatado {
    switch (nivelInfestacao) {
      case 'baixo':
        return 'Baixo';
      case 'medio':
        return 'Médio';
      case 'alto':
        return 'Alto';
      case 'critico':
        return 'Crítico';
      default:
        return nivelInfestacao;
    }
  }

  String get pragaCurta {
    // Retorna apenas o nome comum (antes do parêntese)
    final idx = praga.indexOf('(');
    if (idx > 0) return praga.substring(0, idx).trim();
    return praga;
  }

  bool get isCritico => nivelInfestacao == 'critico';
  bool get isAlto => nivelInfestacao == 'alto';

  // ── Serialização ───────────────────────────────────

  factory MonitoramentoPraga.fromJson(Map<String, dynamic> json) {
    return MonitoramentoPraga(
      id: json['id'] as String,
      talhaoId: json['talhao_id'] as String,
      safraId: json['safra_id'] as String?,
      praga: json['praga'] as String,
      nivelInfestacao: json['nivel_infestacao'] as String,
      dataMonitoramento: DateTime.parse(json['data_monitoramento'] as String),
      areaAfetadaHa: (json['area_afetada_ha'] as num?)?.toDouble(),
      metodoAvaliacao: json['metodo_avaliacao'] as String?,
      acaoRecomendada: json['acao_recomendada'] as String?,
      acaoRealizada: json['acao_realizada'] as String?,
      insumoUtilizado: json['insumo_utilizado'] as String?,
      doseAplicada: (json['dose_aplicada'] as num?)?.toDouble(),
      unidadeDose: json['unidade_dose'] as String?,
      responsavel: json['responsavel'] as String?,
      observacoes: json['observacoes'] as String?,
      criadoEm: json['criado_em'] != null
          ? DateTime.tryParse(json['criado_em'].toString())
          : null,
      atualizadoEm: json['atualizado_em'] != null
          ? DateTime.tryParse(json['atualizado_em'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'talhao_id': talhaoId,
      'safra_id': safraId,
      'praga': praga,
      'nivel_infestacao': nivelInfestacao,
      'data_monitoramento':
          dataMonitoramento.toIso8601String().substring(0, 10),
      'area_afetada_ha': areaAfetadaHa,
      'metodo_avaliacao': metodoAvaliacao,
      'acao_recomendada': acaoRecomendada,
      'acao_realizada': acaoRealizada,
      'insumo_utilizado': insumoUtilizado,
      'dose_aplicada': doseAplicada,
      'unidade_dose': unidadeDose,
      'responsavel': responsavel,
      'observacoes': observacoes,
    };
  }

  MonitoramentoPraga copyWith({
    String? id,
    String? talhaoId,
    String? safraId,
    String? praga,
    String? nivelInfestacao,
    DateTime? dataMonitoramento,
    double? areaAfetadaHa,
    String? metodoAvaliacao,
    String? acaoRecomendada,
    String? acaoRealizada,
    String? insumoUtilizado,
    double? doseAplicada,
    String? unidadeDose,
    String? responsavel,
    String? observacoes,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return MonitoramentoPraga(
      id: id ?? this.id,
      talhaoId: talhaoId ?? this.talhaoId,
      safraId: safraId ?? this.safraId,
      praga: praga ?? this.praga,
      nivelInfestacao: nivelInfestacao ?? this.nivelInfestacao,
      dataMonitoramento: dataMonitoramento ?? this.dataMonitoramento,
      areaAfetadaHa: areaAfetadaHa ?? this.areaAfetadaHa,
      metodoAvaliacao: metodoAvaliacao ?? this.metodoAvaliacao,
      acaoRecomendada: acaoRecomendada ?? this.acaoRecomendada,
      acaoRealizada: acaoRealizada ?? this.acaoRealizada,
      insumoUtilizado: insumoUtilizado ?? this.insumoUtilizado,
      doseAplicada: doseAplicada ?? this.doseAplicada,
      unidadeDose: unidadeDose ?? this.unidadeDose,
      responsavel: responsavel ?? this.responsavel,
      observacoes: observacoes ?? this.observacoes,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}

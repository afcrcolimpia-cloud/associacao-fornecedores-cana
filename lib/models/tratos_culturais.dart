class TratosCulturais {
  final String id;
  final String propriedadeId;
  final String? talhaoId;
  final String anoSafra;
  
  // Insumos (kg/ha ou L/ha)
  final List<Insumo>? adubos;
  final List<Insumo>? herbicidas;
  final List<Insumo>? inseticidas;
  final List<Insumo>? maturadores;
  final double? calagem; // kg/ha
  final double? gessagem; // kg/ha
  final double? oxidoDeCilcio; // kg/ha - CORRIGIDO: sem acento
  
  // Campos extras editáveis (até 3)
  final Map<String, double>? camposExtras;
  
  final DateTime? dataAplicacao;
  final String? observacoes;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  TratosCulturais({
    required this.id,
    required this.propriedadeId,
    this.talhaoId,
    required this.anoSafra,
    this.adubos,
    this.herbicidas,
    this.inseticidas,
    this.maturadores,
    this.calagem,
    this.gessagem,
    this.oxidoDeCilcio, // CORRIGIDO: sem acento
    this.camposExtras,
    this.dataAplicacao,
    this.observacoes,
    this.criadoEm,
    this.atualizadoEm,
  });

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propriedade_id': propriedadeId,
      'talhao_id': talhaoId,
      'ano_safra': anoSafra,
      'adubos': adubos?.map((a) => a.toJson()).toList(),
      'herbicidas': herbicidas?.map((h) => h.toJson()).toList(),
      'inseticidas': inseticidas?.map((i) => i.toJson()).toList(),
      'maturadores': maturadores?.map((m) => m.toJson()).toList(),
      'calagem': calagem,
      'gessagem': gessagem,
      'oxido_de_calcio': oxidoDeCilcio, // CORRIGIDO: sem acento
      'campos_extras': camposExtras,
      'data_aplicacao': dataAplicacao?.toIso8601String(),
      'observacoes': observacoes,
      'criado_em': criadoEm?.toIso8601String(),
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  // Criar do JSON
  factory TratosCulturais.fromJson(Map<String, dynamic> json) {
    return TratosCulturais(
      id: json['id']?.toString() ?? '',
      propriedadeId: json['propriedade_id']?.toString() ?? '',
      talhaoId: json['talhao_id']?.toString(),
      anoSafra: json['ano_safra']?.toString() ?? '',
      adubos: json['adubos'] != null
          ? (json['adubos'] as List).map((a) => Insumo.fromJson(a)).toList()
          : null,
      herbicidas: json['herbicidas'] != null
          ? (json['herbicidas'] as List).map((h) => Insumo.fromJson(h)).toList()
          : null,
      inseticidas: json['inseticidas'] != null
          ? (json['inseticidas'] as List).map((i) => Insumo.fromJson(i)).toList()
          : null,
      maturadores: json['maturadores'] != null
          ? (json['maturadores'] as List).map((m) => Insumo.fromJson(m)).toList()
          : null,
      calagem: json['calagem'] != null
          ? (json['calagem'] as num).toDouble()
          : null,
      gessagem: json['gessagem'] != null
          ? (json['gessagem'] as num).toDouble()
          : null,
      oxidoDeCilcio: json['oxido_de_calcio'] != null // CORRIGIDO: sem acento
          ? (json['oxido_de_calcio'] as num).toDouble()
          : null,
      camposExtras: json['campos_extras'] != null
          ? Map<String, double>.from(json['campos_extras'])
          : null,
      dataAplicacao: json['data_aplicacao'] != null
          ? DateTime.tryParse(json['data_aplicacao'].toString())
          : null,
      observacoes: json['observacoes']?.toString(),
      criadoEm: json['criado_em'] != null
          ? DateTime.tryParse(json['criado_em'].toString())
          : null,
      atualizadoEm: json['atualizado_em'] != null
          ? DateTime.tryParse(json['atualizado_em'].toString())
          : null,
    );
  }

  // Cópia com alterações
  TratosCulturais copyWith({
    String? id,
    String? propriedadeId,
    String? talhaoId,
    String? anoSafra,
    List<Insumo>? adubos,
    List<Insumo>? herbicidas,
    List<Insumo>? inseticidas,
    List<Insumo>? maturadores,
    double? calagem,
    double? gessagem,
    double? oxidoDeCilcio, // CORRIGIDO: sem acento
    Map<String, double>? camposExtras,
    DateTime? dataAplicacao,
    String? observacoes,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return TratosCulturais(
      id: id ?? this.id,
      propriedadeId: propriedadeId ?? this.propriedadeId,
      talhaoId: talhaoId ?? this.talhaoId,
      anoSafra: anoSafra ?? this.anoSafra,
      adubos: adubos ?? this.adubos,
      herbicidas: herbicidas ?? this.herbicidas,
      inseticidas: inseticidas ?? this.inseticidas,
      maturadores: maturadores ?? this.maturadores,
      calagem: calagem ?? this.calagem,
      gessagem: gessagem ?? this.gessagem,
      oxidoDeCilcio: oxidoDeCilcio ?? this.oxidoDeCilcio, // CORRIGIDO: sem acento
      camposExtras: camposExtras ?? this.camposExtras,
      dataAplicacao: dataAplicacao ?? this.dataAplicacao,
      observacoes: observacoes ?? this.observacoes,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return 'TratosCulturais(id: $id, propriedade: $propriedadeId, ano: $anoSafra)';
  }
}

// Classe auxiliar para Insumo
class Insumo {
  final String nome;
  final double quantidade;
  final String unidade; // 'kg/ha' ou 'L/ha'
  final DateTime? dataAplicacao;

  Insumo({
    required this.nome,
    required this.quantidade,
    required this.unidade,
    this.dataAplicacao,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'quantidade': quantidade,
      'unidade': unidade,
      'data_aplicacao': dataAplicacao?.toIso8601String(),
    };
  }

  factory Insumo.fromJson(Map<String, dynamic> json) {
    return Insumo(
      nome: json['nome']?.toString() ?? '',
      quantidade: (json['quantidade'] as num?)?.toDouble() ?? 0.0,
      unidade: json['unidade']?.toString() ?? 'kg/ha',
      dataAplicacao: json['data_aplicacao'] != null
          ? DateTime.tryParse(json['data_aplicacao'].toString())
          : null,
    );
  }

  Insumo copyWith({
    String? nome,
    double? quantidade,
    String? unidade,
    DateTime? dataAplicacao,
  }) {
    return Insumo(
      nome: nome ?? this.nome,
      quantidade: quantidade ?? this.quantidade,
      unidade: unidade ?? this.unidade,
      dataAplicacao: dataAplicacao ?? this.dataAplicacao,
    );
  }

  @override
  String toString() {
    return 'Insumo(nome: $nome, quantidade: $quantidade $unidade)';
  }
}
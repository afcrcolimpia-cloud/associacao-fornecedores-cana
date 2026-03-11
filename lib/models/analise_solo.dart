class AnaliseSolo {
  final String id;
  final String propriedadeId;
  final String? talhaoId;
  final String? laboratorio;
  final String? numeroAmostra;
  final DateTime? dataColeta;
  final DateTime? dataResultado;
  final int? profundidadeCm;

  // Macronutrientes
  final double? ph;
  final double? materiaOrganica; // g/dm³
  final double? fosforo;         // mg/dm³ (P resina)
  final double? potassio;        // mmolc/dm³
  final double? calcio;          // mmolc/dm³
  final double? magnesio;        // mmolc/dm³
  final double? enxofre;         // mg/dm³ (S-SO4)

  // Acidez e CTC
  final double? acidezPotencial; // H+Al mmolc/dm³
  final double? aluminio;        // mmolc/dm³
  final double? somasBases;      // SB mmolc/dm³
  final double? ctc;             // CTC mmolc/dm³
  final double? saturacaoBases;  // V%

  // Micronutrientes
  final double? boro;            // mg/dm³
  final double? cobre;           // mg/dm³
  final double? ferro;           // mg/dm³
  final double? manganes;        // mg/dm³
  final double? zinco;           // mg/dm³

  // Textura
  final double? argila;          // g/kg
  final double? silte;           // g/kg
  final double? areia;           // g/kg

  final String? observacoes;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  AnaliseSolo({
    required this.id,
    required this.propriedadeId,
    this.talhaoId,
    this.laboratorio,
    this.numeroAmostra,
    this.dataColeta,
    this.dataResultado,
    this.profundidadeCm,
    this.ph,
    this.materiaOrganica,
    this.fosforo,
    this.potassio,
    this.calcio,
    this.magnesio,
    this.enxofre,
    this.acidezPotencial,
    this.aluminio,
    this.somasBases,
    this.ctc,
    this.saturacaoBases,
    this.boro,
    this.cobre,
    this.ferro,
    this.manganes,
    this.zinco,
    this.argila,
    this.silte,
    this.areia,
    this.observacoes,
    this.criadoEm,
    this.atualizadoEm,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propriedade_id': propriedadeId,
      'talhao_id': talhaoId,
      'laboratorio': laboratorio,
      'numero_amostra': numeroAmostra,
      'data_coleta': dataColeta?.toIso8601String(),
      'data_resultado': dataResultado?.toIso8601String(),
      'profundidade_cm': profundidadeCm,
      'ph': ph,
      'materia_organica': materiaOrganica,
      'fosforo': fosforo,
      'potassio': potassio,
      'calcio': calcio,
      'magnesio': magnesio,
      'enxofre': enxofre,
      'acidez_potencial': acidezPotencial,
      'aluminio': aluminio,
      'somas_bases': somasBases,
      'ctc': ctc,
      'saturacao_bases': saturacaoBases,
      'boro': boro,
      'cobre': cobre,
      'ferro': ferro,
      'manganes': manganes,
      'zinco': zinco,
      'argila': argila,
      'silte': silte,
      'areia': areia,
      'observacoes': observacoes,
      'criado_em': criadoEm?.toIso8601String(),
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  factory AnaliseSolo.fromJson(Map<String, dynamic> json) {
    return AnaliseSolo(
      id: json['id']?.toString() ?? '',
      propriedadeId: json['propriedade_id']?.toString() ?? '',
      talhaoId: json['talhao_id']?.toString(),
      laboratorio: json['laboratorio']?.toString(),
      numeroAmostra: json['numero_amostra']?.toString(),
      dataColeta: json['data_coleta'] != null
          ? DateTime.tryParse(json['data_coleta'].toString())
          : null,
      dataResultado: json['data_resultado'] != null
          ? DateTime.tryParse(json['data_resultado'].toString())
          : null,
      profundidadeCm: json['profundidade_cm'] != null
          ? (json['profundidade_cm'] is int
              ? json['profundidade_cm'] as int
              : int.tryParse(json['profundidade_cm'].toString()))
          : null,
      ph: _parseDouble(json['ph']),
      materiaOrganica: _parseDouble(json['materia_organica']),
      fosforo: _parseDouble(json['fosforo']),
      potassio: _parseDouble(json['potassio']),
      calcio: _parseDouble(json['calcio']),
      magnesio: _parseDouble(json['magnesio']),
      enxofre: _parseDouble(json['enxofre']),
      acidezPotencial: _parseDouble(json['acidez_potencial']),
      aluminio: _parseDouble(json['aluminio']),
      somasBases: _parseDouble(json['somas_bases']),
      ctc: _parseDouble(json['ctc']),
      saturacaoBases: _parseDouble(json['saturacao_bases']),
      boro: _parseDouble(json['boro']),
      cobre: _parseDouble(json['cobre']),
      ferro: _parseDouble(json['ferro']),
      manganes: _parseDouble(json['manganes']),
      zinco: _parseDouble(json['zinco']),
      argila: _parseDouble(json['argila']),
      silte: _parseDouble(json['silte']),
      areia: _parseDouble(json['areia']),
      observacoes: json['observacoes']?.toString(),
      criadoEm: json['criado_em'] != null
          ? DateTime.tryParse(json['criado_em'].toString())
          : null,
      atualizadoEm: json['atualizado_em'] != null
          ? DateTime.tryParse(json['atualizado_em'].toString())
          : null,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  AnaliseSolo copyWith({
    String? id,
    String? propriedadeId,
    String? talhaoId,
    String? laboratorio,
    String? numeroAmostra,
    DateTime? dataColeta,
    DateTime? dataResultado,
    int? profundidadeCm,
    double? ph,
    double? materiaOrganica,
    double? fosforo,
    double? potassio,
    double? calcio,
    double? magnesio,
    double? enxofre,
    double? acidezPotencial,
    double? aluminio,
    double? somasBases,
    double? ctc,
    double? saturacaoBases,
    double? boro,
    double? cobre,
    double? ferro,
    double? manganes,
    double? zinco,
    double? argila,
    double? silte,
    double? areia,
    String? observacoes,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return AnaliseSolo(
      id: id ?? this.id,
      propriedadeId: propriedadeId ?? this.propriedadeId,
      talhaoId: talhaoId ?? this.talhaoId,
      laboratorio: laboratorio ?? this.laboratorio,
      numeroAmostra: numeroAmostra ?? this.numeroAmostra,
      dataColeta: dataColeta ?? this.dataColeta,
      dataResultado: dataResultado ?? this.dataResultado,
      profundidadeCm: profundidadeCm ?? this.profundidadeCm,
      ph: ph ?? this.ph,
      materiaOrganica: materiaOrganica ?? this.materiaOrganica,
      fosforo: fosforo ?? this.fosforo,
      potassio: potassio ?? this.potassio,
      calcio: calcio ?? this.calcio,
      magnesio: magnesio ?? this.magnesio,
      enxofre: enxofre ?? this.enxofre,
      acidezPotencial: acidezPotencial ?? this.acidezPotencial,
      aluminio: aluminio ?? this.aluminio,
      somasBases: somasBases ?? this.somasBases,
      ctc: ctc ?? this.ctc,
      saturacaoBases: saturacaoBases ?? this.saturacaoBases,
      boro: boro ?? this.boro,
      cobre: cobre ?? this.cobre,
      ferro: ferro ?? this.ferro,
      manganes: manganes ?? this.manganes,
      zinco: zinco ?? this.zinco,
      argila: argila ?? this.argila,
      silte: silte ?? this.silte,
      areia: areia ?? this.areia,
      observacoes: observacoes ?? this.observacoes,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return 'AnaliseSolo(id: $id, talhao: $talhaoId, pH: $ph, V%: $saturacaoBases)';
  }
}

/// Faixas de interpretação conforme Boletim 100 do IAC
/// para cultura da cana-de-açúcar
enum FaixaInterpretacao { muitoBaixo, baixo, medio, alto, muitoAlto }

class InterpretacaoBoletim100 {
  /// Interpreta pH (CaCl2) conforme Boletim 100
  static FaixaInterpretacao interpretarPH(double valor) {
    if (valor <= 4.3) return FaixaInterpretacao.muitoBaixo;
    if (valor <= 5.0) return FaixaInterpretacao.baixo;
    if (valor <= 5.5) return FaixaInterpretacao.medio;
    if (valor <= 6.0) return FaixaInterpretacao.alto;
    return FaixaInterpretacao.muitoAlto;
  }

  /// Interpreta Matéria Orgânica (g/dm³) conforme Boletim 100
  static FaixaInterpretacao interpretarMateriaOrganica(double valor) {
    if (valor <= 6) return FaixaInterpretacao.muitoBaixo;
    if (valor <= 15) return FaixaInterpretacao.baixo;
    if (valor <= 25) return FaixaInterpretacao.medio;
    if (valor <= 40) return FaixaInterpretacao.alto;
    return FaixaInterpretacao.muitoAlto;
  }

  /// Interpreta Fósforo (mg/dm³ - P resina) conforme Boletim 100
  static FaixaInterpretacao interpretarFosforo(double valor) {
    if (valor <= 6) return FaixaInterpretacao.muitoBaixo;
    if (valor <= 12) return FaixaInterpretacao.baixo;
    if (valor <= 30) return FaixaInterpretacao.medio;
    if (valor <= 60) return FaixaInterpretacao.alto;
    return FaixaInterpretacao.muitoAlto;
  }

  /// Interpreta Potássio (mmolc/dm³) conforme Boletim 100
  static FaixaInterpretacao interpretarPotassio(double valor) {
    if (valor <= 0.7) return FaixaInterpretacao.muitoBaixo;
    if (valor <= 1.5) return FaixaInterpretacao.baixo;
    if (valor <= 3.0) return FaixaInterpretacao.medio;
    if (valor <= 6.0) return FaixaInterpretacao.alto;
    return FaixaInterpretacao.muitoAlto;
  }

  /// Interpreta Cálcio (mmolc/dm³) conforme Boletim 100
  static FaixaInterpretacao interpretarCalcio(double valor) {
    if (valor <= 3) return FaixaInterpretacao.muitoBaixo;
    if (valor <= 7) return FaixaInterpretacao.baixo;
    if (valor <= 15) return FaixaInterpretacao.medio;
    if (valor <= 30) return FaixaInterpretacao.alto;
    return FaixaInterpretacao.muitoAlto;
  }

  /// Interpreta Magnésio (mmolc/dm³) conforme Boletim 100
  static FaixaInterpretacao interpretarMagnesio(double valor) {
    if (valor <= 1) return FaixaInterpretacao.muitoBaixo;
    if (valor <= 4) return FaixaInterpretacao.baixo;
    if (valor <= 8) return FaixaInterpretacao.medio;
    if (valor <= 15) return FaixaInterpretacao.alto;
    return FaixaInterpretacao.muitoAlto;
  }

  /// Interpreta Saturação por Bases (V%) conforme Boletim 100
  static FaixaInterpretacao interpretarSaturacaoBases(double valor) {
    if (valor <= 25) return FaixaInterpretacao.muitoBaixo;
    if (valor <= 50) return FaixaInterpretacao.baixo;
    if (valor <= 70) return FaixaInterpretacao.medio;
    if (valor <= 90) return FaixaInterpretacao.alto;
    return FaixaInterpretacao.muitoAlto;
  }

  /// Interpreta CTC (mmolc/dm³) conforme Boletim 100
  static FaixaInterpretacao interpretarCTC(double valor) {
    if (valor <= 25) return FaixaInterpretacao.muitoBaixo;
    if (valor <= 50) return FaixaInterpretacao.baixo;
    if (valor <= 80) return FaixaInterpretacao.medio;
    if (valor <= 120) return FaixaInterpretacao.alto;
    return FaixaInterpretacao.muitoAlto;
  }

  /// Interpreta Boro (mg/dm³) conforme Boletim 100
  static FaixaInterpretacao interpretarBoro(double valor) {
    if (valor <= 0.1) return FaixaInterpretacao.muitoBaixo;
    if (valor <= 0.2) return FaixaInterpretacao.baixo;
    if (valor <= 0.6) return FaixaInterpretacao.medio;
    if (valor <= 1.0) return FaixaInterpretacao.alto;
    return FaixaInterpretacao.muitoAlto;
  }

  /// Interpreta Cobre (mg/dm³) conforme Boletim 100
  static FaixaInterpretacao interpretarCobre(double valor) {
    if (valor <= 0.2) return FaixaInterpretacao.muitoBaixo;
    if (valor <= 0.3) return FaixaInterpretacao.baixo;
    if (valor <= 0.8) return FaixaInterpretacao.medio;
    if (valor <= 1.2) return FaixaInterpretacao.alto;
    return FaixaInterpretacao.muitoAlto;
  }

  /// Interpreta Ferro (mg/dm³) conforme Boletim 100
  static FaixaInterpretacao interpretarFerro(double valor) {
    if (valor <= 4) return FaixaInterpretacao.muitoBaixo;
    if (valor <= 12) return FaixaInterpretacao.baixo;
    if (valor <= 30) return FaixaInterpretacao.medio;
    if (valor <= 60) return FaixaInterpretacao.alto;
    return FaixaInterpretacao.muitoAlto;
  }

  /// Interpreta Manganês (mg/dm³) conforme Boletim 100
  static FaixaInterpretacao interpretarManganes(double valor) {
    if (valor <= 1.2) return FaixaInterpretacao.muitoBaixo;
    if (valor <= 1.9) return FaixaInterpretacao.baixo;
    if (valor <= 5.0) return FaixaInterpretacao.medio;
    if (valor <= 10.0) return FaixaInterpretacao.alto;
    return FaixaInterpretacao.muitoAlto;
  }

  /// Interpreta Zinco (mg/dm³) conforme Boletim 100
  static FaixaInterpretacao interpretarZinco(double valor) {
    if (valor <= 0.5) return FaixaInterpretacao.muitoBaixo;
    if (valor <= 0.9) return FaixaInterpretacao.baixo;
    if (valor <= 1.5) return FaixaInterpretacao.medio;
    if (valor <= 3.0) return FaixaInterpretacao.alto;
    return FaixaInterpretacao.muitoAlto;
  }

  /// Interpreta Enxofre (mg/dm³) conforme Boletim 100
  static FaixaInterpretacao interpretarEnxofre(double valor) {
    if (valor <= 4) return FaixaInterpretacao.muitoBaixo;
    if (valor <= 6) return FaixaInterpretacao.baixo;
    if (valor <= 10) return FaixaInterpretacao.medio;
    if (valor <= 15) return FaixaInterpretacao.alto;
    return FaixaInterpretacao.muitoAlto;
  }

  /// Retorna texto descritivo da faixa
  static String textoFaixa(FaixaInterpretacao faixa) {
    switch (faixa) {
      case FaixaInterpretacao.muitoBaixo:
        return 'Muito Baixo';
      case FaixaInterpretacao.baixo:
        return 'Baixo';
      case FaixaInterpretacao.medio:
        return 'Médio';
      case FaixaInterpretacao.alto:
        return 'Alto';
      case FaixaInterpretacao.muitoAlto:
        return 'Muito Alto';
    }
  }
}

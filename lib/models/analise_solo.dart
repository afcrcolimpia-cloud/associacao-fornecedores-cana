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
  final String? cultura;
  final double? prnt;
  final double? produtividadeEsperada;
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
    this.cultura,
    this.prnt,
    this.produtividadeEsperada,
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
      'cultura': cultura,
      'prnt': prnt,
      'produtividade_esperada': produtividadeEsperada,
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
      cultura: json['cultura']?.toString(),
      prnt: _parseDouble(json['prnt']),
      produtividadeEsperada: _parseDouble(json['produtividade_esperada']),
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
    String? cultura,
    double? prnt,
    double? produtividadeEsperada,
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
      cultura: cultura ?? this.cultura,
      prnt: prnt ?? this.prnt,
      produtividadeEsperada: produtividadeEsperada ?? this.produtividadeEsperada,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return 'AnaliseSolo(id: $id, talhao: $talhaoId, pH: $ph, V%: $saturacaoBases)';
  }
}

// ═══════════════════════════════════════════════════════════════
// INTERPRETAÇÃO — Boletim 100 (IAC, 5ª Aproximação)
// Sistema Semáforo: 🟢 Verde  🟡 Amarelo  🔴 Vermelho
// ═══════════════════════════════════════════════════════════════

/// Semáforo de interpretação — 3 níveis conforme Tutorial AFCRC
enum SemaforoSolo {
  vermelho, // 🔴 Baixo / Muito Baixo / Tóxico — ação urgente
  amarelo,  // 🟡 Médio / Regular — atenção
  verde,    // 🟢 Bom / Alto / Adequado — ok
}

/// Classe textural do solo baseada na % de argila
enum ClasseTextural {
  arenoso,       // < 15%
  texturMedia,   // 15 a 35%
  argiloso,      // 35 a 60%
  muitoArgiloso, // ≥ 60%
}

/// Cultura do Quadro 3 — Boletim 100 (IAC, 5ª Aproximação)
class CulturaBoletim100 {
  final String nome;
  final double mtMaxPercent; // Saturação por Al tolerada (%)
  final double xCmolc;       // Teor ideal Ca+Mg (cmolc/dm³)
  final double vePercent;    // Saturação por bases desejada (%)

  const CulturaBoletim100({
    required this.nome,
    required this.mtMaxPercent,
    required this.xCmolc,
    required this.vePercent,
  });

  static const List<CulturaBoletim100> todas = [
    CulturaBoletim100(nome: 'ALGODÃO', mtMaxPercent: 10, xCmolc: 2.5, vePercent: 60),
    CulturaBoletim100(nome: 'AMENDOIM', mtMaxPercent: 5, xCmolc: 3.0, vePercent: 70),
    CulturaBoletim100(nome: 'ARROZ IRRIGADO', mtMaxPercent: 25, xCmolc: 2.0, vePercent: 50),
    CulturaBoletim100(nome: 'CACAU', mtMaxPercent: 15, xCmolc: 2.0, vePercent: 50),
    CulturaBoletim100(nome: 'CAFÉ', mtMaxPercent: 25, xCmolc: 3.5, vePercent: 60),
    CulturaBoletim100(nome: 'CANA-DE-AÇÚCAR', mtMaxPercent: 30, xCmolc: 3.5, vePercent: 70),
    CulturaBoletim100(nome: 'CITROS', mtMaxPercent: 5, xCmolc: 3.0, vePercent: 70),
    CulturaBoletim100(nome: 'CROTALÁRIA-JUNCEA', mtMaxPercent: 5, xCmolc: 3.0, vePercent: 70),
    CulturaBoletim100(nome: 'LEUCENA', mtMaxPercent: 15, xCmolc: 2.5, vePercent: 60),
    CulturaBoletim100(nome: 'MANDIOCA', mtMaxPercent: 30, xCmolc: 1.0, vePercent: 40),
    CulturaBoletim100(nome: 'MILHO', mtMaxPercent: 15, xCmolc: 2.0, vePercent: 50),
    CulturaBoletim100(nome: 'MILHO VERDE', mtMaxPercent: 10, xCmolc: 2.5, vePercent: 60),
    CulturaBoletim100(nome: 'SERINGUEIRA', mtMaxPercent: 25, xCmolc: 1.0, vePercent: 50),
    CulturaBoletim100(nome: 'SORGO', mtMaxPercent: 15, xCmolc: 2.0, vePercent: 50),
    CulturaBoletim100(nome: 'TRIGO', mtMaxPercent: 15, xCmolc: 2.0, vePercent: 50),
  ];

  static CulturaBoletim100? buscarPorNome(String? nome) {
    if (nome == null) return null;
    for (final c in todas) {
      if (c.nome == nome) return c;
    }
    return null;
  }
}

/// Item interpretado pelo sistema semáforo
class ItemInterpretado {
  final String nome;
  final double valor;
  final String unidade;
  final SemaforoSolo semaforo;
  final String textoSemaforo;
  final bool inversao; // true para Al e H+Al (menor = melhor)
  final double? limiteIdeal; // para gráficos de barra

  const ItemInterpretado({
    required this.nome,
    required this.valor,
    required this.unidade,
    required this.semaforo,
    required this.textoSemaforo,
    this.inversao = false,
    this.limiteIdeal,
  });
}

/// Resultado completo da interpretação de análise de solo
class ResultadoInterpretacao {
  final double somasBases;
  final double ctc;
  final double saturacaoBases;
  final double? saturacaoAluminio;
  final ClasseTextural? classeTextural;
  final List<ItemInterpretado> macronutrientes;
  final List<ItemInterpretado> micronutrientes;
  final double calagemMetodo1;
  final double calagemMetodo2;
  final double calagemFinal;
  final SemaforoSolo semaforoCalagem;
  final bool gessagemNecessaria;
  final double gessagemDose;
  final SemaforoSolo semaforoGessagem;
  final bool fonteS;                      // Recomenda gesso como fonte de S (1 t/ha)
  final double doseFonteS;                // 0.0 ou 1.0 t/ha
  final bool doseMinimaCalagemAplicada;   // Dose mínima 1,5 t/ha (B-100 2022, cana)
  final double? relacaoCaMg;
  final double? relacaoCaK;
  final double? relacaoMgK;
  final SemaforoSolo? semaforoCaMg;
  final SemaforoSolo? semaforoCaK;
  final SemaforoSolo? semaforoMgK;

  const ResultadoInterpretacao({
    required this.somasBases,
    required this.ctc,
    required this.saturacaoBases,
    this.saturacaoAluminio,
    this.classeTextural,
    required this.macronutrientes,
    required this.micronutrientes,
    required this.calagemMetodo1,
    required this.calagemMetodo2,
    required this.calagemFinal,
    required this.semaforoCalagem,
    required this.gessagemNecessaria,
    required this.gessagemDose,
    required this.semaforoGessagem,
    this.fonteS = false,
    this.doseFonteS = 0.0,
    this.doseMinimaCalagemAplicada = false,
    this.relacaoCaMg,
    this.relacaoCaK,
    this.relacaoMgK,
    this.semaforoCaMg,
    this.semaforoCaK,
    this.semaforoMgK,
  });
}

/// Motor de interpretação baseado no Boletim 100 (IAC, 5ª Aproximação)
/// Faixas conforme Tabela 11 do Tutorial AFCRC
class InterpretacaoBoletim100 {

  // ═══ Classe textural ═══
  static ClasseTextural determinarClasseTextural(double argilaPercent) {
    if (argilaPercent < 15) return ClasseTextural.arenoso;
    if (argilaPercent < 35) return ClasseTextural.texturMedia;
    if (argilaPercent < 60) return ClasseTextural.argiloso;
    return ClasseTextural.muitoArgiloso;
  }

  static String textoClasseTextural(ClasseTextural classe) {
    switch (classe) {
      case ClasseTextural.arenoso: return 'Arenoso';
      case ClasseTextural.texturMedia: return 'Textura Média';
      case ClasseTextural.argiloso: return 'Argiloso';
      case ClasseTextural.muitoArgiloso: return 'Muito Argiloso';
    }
  }

  // ═══ Semáforos individuais — Tabela 11 Tutorial ═══

  static SemaforoSolo semaforoPH(double v) {
    if (v < 4.5) return SemaforoSolo.vermelho;
    if (v <= 6.0) return SemaforoSolo.amarelo;
    return SemaforoSolo.verde;
  }

  /// M.O. em g/dm³ — faixas: 🔴<16, 🟡16-25, 🟢≥25
  static SemaforoSolo semaforoMO(double v) {
    if (v < 16) return SemaforoSolo.vermelho;
    if (v < 25) return SemaforoSolo.amarelo;
    return SemaforoSolo.verde;
  }

  /// P resina (mg/dm³) — depende da textura
  static SemaforoSolo semaforoP(double v, ClasseTextural? textura) {
    switch (textura ?? ClasseTextural.texturMedia) {
      case ClasseTextural.arenoso:
        if (v < 10) return SemaforoSolo.vermelho;
        if (v < 30) return SemaforoSolo.amarelo;
        return SemaforoSolo.verde;
      case ClasseTextural.texturMedia:
        if (v < 7) return SemaforoSolo.vermelho;
        if (v < 20) return SemaforoSolo.amarelo;
        return SemaforoSolo.verde;
      case ClasseTextural.argiloso:
        if (v < 4) return SemaforoSolo.vermelho;
        if (v < 12) return SemaforoSolo.amarelo;
        return SemaforoSolo.verde;
      case ClasseTextural.muitoArgiloso:
        if (v < 4) return SemaforoSolo.vermelho;
        if (v < 8) return SemaforoSolo.amarelo;
        return SemaforoSolo.verde;
    }
  }

  /// Limite ideal de P por textura (mg/dm³) — para gráficos
  static double limitePIdeal(ClasseTextural? textura) {
    switch (textura ?? ClasseTextural.texturMedia) {
      case ClasseTextural.arenoso: return 30;
      case ClasseTextural.texturMedia: return 20;
      case ClasseTextural.argiloso: return 12;
      case ClasseTextural.muitoArgiloso: return 8;
    }
  }

  static SemaforoSolo semaforoK(double v) {
    if (v < 0.8) return SemaforoSolo.vermelho;
    if (v <= 3.0) return SemaforoSolo.amarelo;
    return SemaforoSolo.verde;
  }

  static SemaforoSolo semaforoCa(double v) {
    if (v < 3.0) return SemaforoSolo.vermelho;
    if (v <= 7.0) return SemaforoSolo.amarelo;
    return SemaforoSolo.verde;
  }

  static SemaforoSolo semaforoMg(double v) {
    if (v < 4.0) return SemaforoSolo.vermelho;
    if (v <= 8.0) return SemaforoSolo.amarelo;
    return SemaforoSolo.verde;
  }

  /// Al — lógica INVERSA: menor = melhor
  static SemaforoSolo semaforoAl(double v) {
    if (v < 0.2) return SemaforoSolo.verde;
    if (v <= 1.0) return SemaforoSolo.amarelo;
    return SemaforoSolo.vermelho;
  }

  /// H+Al — lógica INVERSA: menor = melhor (mmolc/dm³)
  static SemaforoSolo semaforoHAl(double v) {
    if (v < 25) return SemaforoSolo.verde;
    if (v <= 50) return SemaforoSolo.amarelo;
    return SemaforoSolo.vermelho;
  }

  static SemaforoSolo semaforoS(double v) {
    if (v < 5) return SemaforoSolo.vermelho;
    if (v <= 10) return SemaforoSolo.amarelo;
    return SemaforoSolo.verde;
  }

  static SemaforoSolo semaforoV(double v) {
    if (v < 40) return SemaforoSolo.vermelho;
    if (v <= 60) return SemaforoSolo.amarelo;
    return SemaforoSolo.verde;
  }

  static SemaforoSolo semaforoCu(double v) {
    if (v < 0.3) return SemaforoSolo.vermelho;
    if (v < 0.8) return SemaforoSolo.amarelo;
    return SemaforoSolo.verde;
  }

  static SemaforoSolo semaforoFe(double v) {
    if (v < 5) return SemaforoSolo.vermelho;
    if (v < 12) return SemaforoSolo.amarelo;
    return SemaforoSolo.verde;
  }

  static SemaforoSolo semaforoMn(double v) {
    if (v < 1.2) return SemaforoSolo.vermelho;
    if (v < 5.0) return SemaforoSolo.amarelo;
    return SemaforoSolo.verde;
  }

  static SemaforoSolo semaforoZn(double v) {
    if (v < 0.6) return SemaforoSolo.vermelho;
    if (v < 1.2) return SemaforoSolo.amarelo;
    return SemaforoSolo.verde;
  }

  static SemaforoSolo semaforoB(double v) {
    if (v < 0.2) return SemaforoSolo.vermelho;
    if (v < 0.6) return SemaforoSolo.amarelo;
    return SemaforoSolo.verde;
  }

  // ═══ Cálculos derivados ═══

  /// SB = K + Ca + Mg (mmolc/dm³)
  static double calcularSB(double k, double ca, double mg) => k + ca + mg;

  /// CTC = SB + H+Al (mmolc/dm³)
  static double calcularCTC(double sb, double hAl) => sb + hAl;

  /// V% = (SB / CTC) × 100
  static double calcularV(double sb, double ctc) =>
      ctc > 0 ? (sb / ctc) * 100 : 0;

  /// mt% = [Al / (Al + SB)] × 100

  static double calcularMt(double al, double sb) =>
      (al + sb) > 0 ? (al / (al + sb)) * 100 : 0;

  // ═══ Calagem — 2 métodos (Tutorial seção 8) ═══

  /// Método 1 — Saturação por Bases
  /// NC = (Ve − V%) × CTC × 10 ÷ (PRNT × 100)
  static double calagemMetodo1({
    required double ve,
    required double vAtual,
    required double ctc,
    required double prnt,
  }) {
    if (ve <= vAtual || prnt <= 0) return 0;
    return (ve - vAtual) * ctc * 10 / (prnt * 100);
  }

  /// Método 2 — Neutralização Al + Elevação Ca+Mg
  /// NC = [mt × Al − mt² × H+Al + (X × 10 − Ca − Mg)] × 10 ÷ PRNT
  static double calagemMetodo2({
    required double mtDecimal, // mt/100
    required double al,
    required double hAl,
    required double xCmolc,
    required double ca,
    required double mg,
    required double prnt,
  }) {
    if (prnt <= 0) return 0;
    final nc = (mtDecimal * al - mtDecimal * mtDecimal * hAl +
            (xCmolc * 10 - ca - mg)) *
        10 /
        prnt;
    return nc < 0 ? 0 : nc;
  }

  /// Semáforo da calagem
  static SemaforoSolo semaforoCalagem(double ncFinal) {
    if (ncFinal <= 0) return SemaforoSolo.verde;
    if (ncFinal <= 2) return SemaforoSolo.amarelo;
    return SemaforoSolo.vermelho;
  }

  // ═══ Gessagem — B-100 2022 (Cana-de-açúcar, p.180) ═══

  /// B-100 2022: V% < 40% OU saturação por Al (m%) > 30%
  /// Nota: O B-100 recomenda avaliar na camada 25-50 cm
  static bool gessagemNecessaria(double vPercent, double mtPercent) =>
      vPercent < 40 || mtPercent > 30;

  /// B-100 2022: Argila (g/kg) × 6 = kg/ha de gesso
  /// [argilaPercent]: valor em % (ex: 35 para 35%)
  static double gessagemDose(double? argilaPercent) {
    if (argilaPercent == null || argilaPercent <= 0) return 0;
    return argilaPercent * 10 * 6 / 1000; // % → g/kg × 6 → kg/ha → t/ha
  }

  /// B-100 2022: Se gessagem não necessária mas S-SO₄²⁻ < 15 mg/dm³
  /// na camada 25-50 cm → aplicar 1 t/ha de gesso como fonte de S
  static bool gessagemFonteS(bool gessNecessaria, double? enxofre) =>
      !gessNecessaria && enxofre != null && enxofre < 15;

  static SemaforoSolo semaforoGessagem(bool necessaria, bool fonteS) {
    if (necessaria) return SemaforoSolo.vermelho;
    if (fonteS) return SemaforoSolo.amarelo;
    return SemaforoSolo.verde;
  }

  // ═══ Relações iônicas (Tutorial seção 9) ═══

  static SemaforoSolo semaforoRelacao(double valor, double min, double max) {
    if (valor < min || valor > max) return SemaforoSolo.vermelho;
    // Dentro de 80% do range ideal = verde, borda = amarelo
    final range = max - min;
    if (valor >= min + range * 0.1 && valor <= max - range * 0.1) {
      return SemaforoSolo.verde;
    }
    return SemaforoSolo.amarelo;
  }

  /// Ca/Mg ideal: 1,0 a 4,0
  static SemaforoSolo semaforoCaMg(double ca, double mg) =>
      mg > 0 ? semaforoRelacao(ca / mg, 1.0, 4.0) : SemaforoSolo.amarelo;

  /// Ca/K ideal: 8,0 a 20,0
  static SemaforoSolo semaforoCaK(double ca, double k) =>
      k > 0 ? semaforoRelacao(ca / k, 8.0, 20.0) : SemaforoSolo.amarelo;

  /// Mg/K ideal: 1,5 a 6,0
  static SemaforoSolo semaforoMgK(double mg, double k) =>
      k > 0 ? semaforoRelacao(mg / k, 1.5, 6.0) : SemaforoSolo.amarelo;

  // ═══ Texto de semáforo ═══

  static String textoSemaforo(SemaforoSolo s) {
    switch (s) {
      case SemaforoSolo.vermelho: return 'Baixo';
      case SemaforoSolo.amarelo: return 'Médio';
      case SemaforoSolo.verde: return 'Bom';
    }
  }

  // ═══ Cálculo completo ═══

  static ResultadoInterpretacao calcularCompleto({
    required double ph,
    required double mo,
    required double p,
    required double k,
    required double ca,
    required double mg,
    required double al,
    required double hAl,
    double? s,
    double? cu,
    double? fe,
    double? mn,
    double? zn,
    double? b,
    double? argilaPercent,
    required double prnt,
    required CulturaBoletim100 cultura,
  }) {
    // Valores calculados
    final sb = calcularSB(k, ca, mg);
    final ctc = calcularCTC(sb, hAl);
    final vPercent = calcularV(sb, ctc);
    final mtPercent = calcularMt(al, sb);

    // Classe textural
    final ClasseTextural? textura = argilaPercent != null
        ? determinarClasseTextural(argilaPercent)
        : null;

    // Macronutrientes
    final macros = <ItemInterpretado>[
      ItemInterpretado(
        nome: 'pH (CaCl₂)', valor: ph, unidade: '',
        semaforo: semaforoPH(ph),
        textoSemaforo: textoSemaforo(semaforoPH(ph)),
        limiteIdeal: 6.0,
      ),
      ItemInterpretado(
        nome: 'M.O.', valor: mo, unidade: 'g/dm³',
        semaforo: semaforoMO(mo),
        textoSemaforo: textoSemaforo(semaforoMO(mo)),
        limiteIdeal: 25,
      ),
      ItemInterpretado(
        nome: 'P resina', valor: p, unidade: 'mg/dm³',
        semaforo: semaforoP(p, textura),
        textoSemaforo: textoSemaforo(semaforoP(p, textura)),
        limiteIdeal: limitePIdeal(textura),
      ),
      ItemInterpretado(
        nome: 'K⁺', valor: k, unidade: 'mmolc/dm³',
        semaforo: semaforoK(k),
        textoSemaforo: textoSemaforo(semaforoK(k)),
        limiteIdeal: 3.0,
      ),
      ItemInterpretado(
        nome: 'Ca²⁺', valor: ca, unidade: 'mmolc/dm³',
        semaforo: semaforoCa(ca),
        textoSemaforo: textoSemaforo(semaforoCa(ca)),
        limiteIdeal: 7.0,
      ),
      ItemInterpretado(
        nome: 'Mg²⁺', valor: mg, unidade: 'mmolc/dm³',
        semaforo: semaforoMg(mg),
        textoSemaforo: textoSemaforo(semaforoMg(mg)),
        limiteIdeal: 8.0,
      ),
      ItemInterpretado(
        nome: 'Al³⁺', valor: al, unidade: 'mmolc/dm³',
        semaforo: semaforoAl(al),
        textoSemaforo: textoSemaforo(semaforoAl(al)),
        inversao: true,
        limiteIdeal: 0.2,
      ),
      ItemInterpretado(
        nome: 'H+Al', valor: hAl, unidade: 'mmolc/dm³',
        semaforo: semaforoHAl(hAl),
        textoSemaforo: textoSemaforo(semaforoHAl(hAl)),
        inversao: true,
        limiteIdeal: 25,
      ),
      if (s != null)
        ItemInterpretado(
          nome: 'S (Enxofre)', valor: s, unidade: 'mg/dm³',
          semaforo: semaforoS(s),
          textoSemaforo: textoSemaforo(semaforoS(s)),
          limiteIdeal: 10,
        ),
      // Valores calculados no final
      ItemInterpretado(
        nome: 'V%', valor: vPercent, unidade: '%',
        semaforo: semaforoV(vPercent),
        textoSemaforo: textoSemaforo(semaforoV(vPercent)),
        limiteIdeal: 60,
      ),
    ];

    // Micronutrientes
    final micros = <ItemInterpretado>[
      if (cu != null)
        ItemInterpretado(
          nome: 'Cu (Cobre)', valor: cu, unidade: 'mg/dm³',
          semaforo: semaforoCu(cu),
          textoSemaforo: textoSemaforo(semaforoCu(cu)),
          limiteIdeal: 0.8,
        ),
      if (fe != null)
        ItemInterpretado(
          nome: 'Fe (Ferro)', valor: fe, unidade: 'mg/dm³',
          semaforo: semaforoFe(fe),
          textoSemaforo: textoSemaforo(semaforoFe(fe)),
          limiteIdeal: 12,
        ),
      if (mn != null)
        ItemInterpretado(
          nome: 'Mn (Manganês)', valor: mn, unidade: 'mg/dm³',
          semaforo: semaforoMn(mn),
          textoSemaforo: textoSemaforo(semaforoMn(mn)),
          limiteIdeal: 5.0,
        ),
      if (zn != null)
        ItemInterpretado(
          nome: 'Zn (Zinco)', valor: zn, unidade: 'mg/dm³',
          semaforo: semaforoZn(zn),
          textoSemaforo: textoSemaforo(semaforoZn(zn)),
          limiteIdeal: 1.2,
        ),
      if (b != null)
        ItemInterpretado(
          nome: 'B (Boro)', valor: b, unidade: 'mg/dm³',
          semaforo: semaforoB(b),
          textoSemaforo: textoSemaforo(semaforoB(b)),
          limiteIdeal: 0.6,
        ),
    ];

    // Calagem
    final nc1 = calagemMetodo1(
      ve: cultura.vePercent, vAtual: vPercent, ctc: ctc, prnt: prnt,
    );
    final nc2 = calagemMetodo2(
      mtDecimal: cultura.mtMaxPercent / 100,
      al: al, hAl: hAl, xCmolc: cultura.xCmolc,
      ca: ca, mg: mg, prnt: prnt,
    );
    var ncFinal = nc1 > nc2 ? nc1 : nc2;

    // B-100 2022 (Cana): dose mínima 1,5 t/ha (PRNT=100%)
    bool minimoAplicado = false;
    if (cultura.nome == 'CANA-DE-AÇÚCAR' && ncFinal > 0 && prnt > 0) {
      final minimo = 150 / prnt; // 1,5 t/ha ajustado para PRNT
      if (ncFinal < minimo) {
        ncFinal = minimo;
        minimoAplicado = true;
      }
    }

    // Gessagem — B-100 2022: V% < 40% OU m% > 30%
    final gessNec = gessagemNecessaria(vPercent, mtPercent);
    final gessDose = gessNec ? gessagemDose(argilaPercent) : 0.0;

    // Fonte de S — B-100 2022: se S < 15 mg/dm³ e gessagem não necessária → 1 t/ha
    final fonteS = InterpretacaoBoletim100.gessagemFonteS(gessNec, s);
    final doseFonteS = fonteS ? 1.0 : 0.0;

    // Relações iônicas
    final rCaMg = mg > 0 ? ca / mg : null;
    final rCaK = k > 0 ? ca / k : null;
    final rMgK = k > 0 ? mg / k : null;

    return ResultadoInterpretacao(
      somasBases: sb,
      ctc: ctc,
      saturacaoBases: vPercent,
      saturacaoAluminio: mtPercent,
      classeTextural: textura,
      macronutrientes: macros,
      micronutrientes: micros,
      calagemMetodo1: nc1,
      calagemMetodo2: nc2,
      calagemFinal: ncFinal,
      semaforoCalagem: semaforoCalagem(ncFinal),
      gessagemNecessaria: gessNec,
      gessagemDose: gessDose,
      semaforoGessagem: semaforoGessagem(gessNec, fonteS),
      fonteS: fonteS,
      doseFonteS: doseFonteS,
      doseMinimaCalagemAplicada: minimoAplicado,
      relacaoCaMg: rCaMg,
      relacaoCaK: rCaK,
      relacaoMgK: rMgK,
      semaforoCaMg: mg > 0 ? InterpretacaoBoletim100.semaforoCaMg(ca, mg) : null,
      semaforoCaK: k > 0 ? InterpretacaoBoletim100.semaforoCaK(ca, k) : null,
      semaforoMgK: k > 0 ? InterpretacaoBoletim100.semaforoMgK(mg, k) : null,
    );
  }
}

/// Modelo para operação individual de custo operacional
class Operacao {
  final String operacao;
  final String maquina;
  final double maquinaVal;
  final String implemento;
  final double implVal;
  final double operacaoVal;
  final double rend;
  final double operRHa;
  final String? insumo;
  final double? dose;
  final double? insumoRHa;
  final double total;

  Operacao({
    required this.operacao,
    required this.maquina,
    required this.maquinaVal,
    required this.implemento,
    required this.implVal,
    required this.operacaoVal,
    required this.rend,
    required this.operRHa,
    this.insumo,
    this.dose,
    this.insumoRHa,
    required this.total,
  });

  factory Operacao.fromJson(Map<String, dynamic> json) {
    return Operacao(
      operacao: json['operacao'] ?? '',
      maquina: json['maquina'] ?? '',
      maquinaVal: (json['maquinaVal'] as num?)?.toDouble() ?? 0.0,
      implemento: json['implemento'] ?? '-',
      implVal: (json['implVal'] as num?)?.toDouble() ?? 0.0,
      operacaoVal: (json['operacaoVal'] as num?)?.toDouble() ?? 0.0,
      rend: (json['rend'] as num?)?.toDouble() ?? 0.0,
      operRHa: (json['operRHa'] as num?)?.toDouble() ?? 0.0,
      insumo: json['insumo'],
      dose: (json['dose'] as num?)?.toDouble(),
      insumoRHa: (json['insumoRHa'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operacao': operacao,
      'maquina': maquina,
      'maquinaVal': maquinaVal,
      'implemento': implemento,
      'implVal': implVal,
      'operacaoVal': operacaoVal,
      'rend': rend,
      'operRHa': operRHa,
      'insumo': insumo,
      'dose': dose,
      'insumoRHa': insumoRHa,
      'total': total,
    };
  }
}

/// Modelo para estágio de custos (grupo de operações)
class EstagioCustos {
  final String titulo;
  final List<Operacao> operacoes;
  final double total;
  final String obs;

  EstagioCustos({
    required this.titulo,
    required this.operacoes,
    required this.total,
    required this.obs,
  });

  factory EstagioCustos.fromJson(Map<String, dynamic> json) {
    final operacoesList = (json['operacoes'] as List?)
        ?.map((op) => Operacao.fromJson(op as Map<String, dynamic>))
        .toList() ??
        [];

    return EstagioCustos(
      titulo: json['titulo'] ?? '',
      operacoes: operacoesList,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      obs: json['obs'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'operacoes': operacoes.map((op) => op.toJson()).toList(),
      'total': total,
      'obs': obs,
    };
  }
}

/// Modelo para resumo de estágio
class ResumoEstagio {
  final String estagio;
  final double rHa;         // R$/ha anualizado (amortizado para formação)
  final double rHaBruto;    // R$/ha bruto (valor real da operação, sem amortização)
  final double rT;
  final double rKgATR;
  final String pct;
  final bool ehFormacao;    // true para Conservação, Preparo, Plantio

  ResumoEstagio({
    required this.estagio,
    required this.rHa,
    this.rHaBruto = 0,
    required this.rT,
    required this.rKgATR,
    required this.pct,
    this.ehFormacao = false,
  });

  factory ResumoEstagio.fromJson(Map<String, dynamic> json) {
    return ResumoEstagio(
      estagio: json['estagio'] ?? '',
      rHa: (json['rHa'] as num?)?.toDouble() ?? 0.0,
      rHaBruto: (json['rHaBruto'] as num?)?.toDouble() ?? 0.0,
      rT: (json['rT'] as num?)?.toDouble() ?? 0.0,
      rKgATR: (json['rKgATR'] as num?)?.toDouble() ?? 0.0,
      pct: json['pct'] ?? '0%',
      ehFormacao: json['ehFormacao'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estagio': estagio,
      'rHa': rHa,
      'rHaBruto': rHaBruto,
      'rT': rT,
      'rKgATR': rKgATR,
      'pct': pct,
      'ehFormacao': ehFormacao,
    };
  }
}

/// Modelo para parâmetros técnicos
class ParametrosCustoOperacional {
  final double produtividade;
  final int atr;
  final int longevidade;
  final double doseMuda;
  final double precoDiesel;
  final double custoAdmin;
  final double arrendamento;
  final double atrArrend; // kg/t — aceita decimais (ex: 118.6)
  final double precoATR;
  final String periodoRef;

  ParametrosCustoOperacional({
    required this.produtividade,
    required this.atr,
    required this.longevidade,
    required this.doseMuda,
    required this.precoDiesel,
    required this.custoAdmin,
    required this.arrendamento,
    required this.atrArrend,
    required this.precoATR,
    required this.periodoRef,
  });

  factory ParametrosCustoOperacional.fromJson(Map<String, dynamic> json) {
    return ParametrosCustoOperacional(
      produtividade: (json['produtividade'] as num?)?.toDouble() ?? 0.0,
      atr: json['atr'] ?? 138,
      longevidade: json['longevidade'] ?? 5,
      doseMuda: (json['doseMuda'] as num?)?.toDouble() ?? 16.0,
      precoDiesel: (json['precoDiesel'] as num?)?.toDouble() ?? 5.899,
      custoAdmin: (json['custoAdmin'] as num?)?.toDouble() ?? 10.0, // % sobre o subtotal operacional
      arrendamento: (json['arrendamento'] as num?)?.toDouble() ?? 16.5,
      atrArrend: (json['atrArrend'] as num?)?.toDouble() ?? 118.6,
      precoATR: (json['precoATR'] as num?)?.toDouble() ?? 1.1945,
      periodoRef: json['periodoRef'] ?? 'Jan-Fev/2026',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'produtividade': produtividade,
      'atr': atr,
      'longevidade': longevidade,
      'doseMuda': doseMuda,
      'precoDiesel': precoDiesel,
      'custoAdmin': custoAdmin,
      'arrendamento': arrendamento,
      'atrArrend': atrArrend,
      'precoATR': precoATR,
      'periodoRef': periodoRef,
    };
  }
}

/// Modelo para total operacional e margens
class TotalOperacional {
  final double rHa;
  final double rT;
  final double rKgATR;

  TotalOperacional({
    required this.rHa,
    required this.rT,
    required this.rKgATR,
  });

  factory TotalOperacional.fromJson(Map<String, dynamic> json) {
    return TotalOperacional(
      rHa: (json['rHa'] as num?)?.toDouble() ?? 0.0,
      rT: (json['rT'] as num?)?.toDouble() ?? 0.0,
      rKgATR: (json['rKgATR'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rHa': rHa,
      'rT': rT,
      'rKgATR': rKgATR,
    };
  }
}

/// Resultado consolidado do custo operacional para um cenário
class ResumoCustoOperacionalCalculado {
  final List<ResumoEstagio> linhasResumo;
  final TotalOperacional totalOperacional;
  final TotalOperacional precoRecebido;
  final TotalOperacional margemLucro;
  final double margemPercentual;

  const ResumoCustoOperacionalCalculado({
    required this.linhasResumo,
    required this.totalOperacional,
    required this.precoRecebido,
    required this.margemLucro,
    required this.margemPercentual,
  });
}

class Talhao {
  final String id;
  final String propriedadeId;
  final String numeroTalhao;
  final double? areaHa;
  final double? areaAlqueires;
  final String? variedade;
  final String? cultura;
  final int? anoPlantio;
  final int? corte;
  final DateTime? dataPlantio;
  final String? tipoTalhao; // 'producao' ou 'reforma'
  final bool ativo;
  final String? observacoes;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  Talhao({
    required this.id,
    required this.propriedadeId,
    required this.numeroTalhao,
    this.areaHa,
    this.areaAlqueires,
    this.variedade,
    this.cultura,
    this.anoPlantio,
    this.corte,
    this.dataPlantio,
    this.tipoTalhao = 'producao',
    this.ativo = true,
    this.observacoes,
    this.criadoEm,
    this.atualizadoEm,
  });

  // Getters auxiliares
  String get nome => 'Talhão $numeroTalhao';
  bool get isReforma => tipoTalhao == 'reforma';
  bool get isProducao => tipoTalhao == 'producao';
  double get area => areaHa ?? 0;
  double? get areaHectares => areaHa;

  // Converter para JSON (ENVIAR PARA O SUPABASE)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propriedade_id': propriedadeId,
      'numero_talhao': numeroTalhao,
      'area_ha': areaHa,
      'area_alqueires': areaAlqueires,
      'variedade': variedade,
      'cultura': cultura,
      'ano_plantio': anoPlantio,
      'corte': corte,
      'data_plantio': dataPlantio?.toIso8601String(),
      'tipo_talhao': tipoTalhao,
      'ativo': ativo,
      'observacoes': observacoes,
      'criado_em': criadoEm?.toIso8601String(),
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  // Criar objeto A PARTIR DO SUPABASE
  factory Talhao.fromJson(Map<String, dynamic> json) {
    return Talhao(
      id: json['id']?.toString() ?? '',
      propriedadeId: json['propriedade_id']?.toString() ?? '',
      numeroTalhao: json['numero_talhao']?.toString() ?? '',
      areaHa: json['area_ha'] != null
          ? (json['area_ha'] as num).toDouble()
          : null,
      areaAlqueires: json['area_alqueires'] != null
          ? (json['area_alqueires'] as num).toDouble()
          : null,
      variedade: json['variedade']?.toString(),
      cultura: json['cultura']?.toString(),
      anoPlantio: json['ano_plantio'] != null
          ? (json['ano_plantio'] is int
              ? json['ano_plantio'] as int
              : int.tryParse(json['ano_plantio'].toString()))
          : null,
      corte: json['corte'] != null
          ? (json['corte'] is int
              ? json['corte'] as int
              : int.tryParse(json['corte'].toString()))
          : null,
      dataPlantio: json['data_plantio'] != null
          ? DateTime.tryParse(json['data_plantio'].toString())
          : null,
      tipoTalhao: json['tipo_talhao']?.toString() ?? 'producao',
      ativo: json['ativo'] as bool? ?? true,
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
  Talhao copyWith({
    String? id,
    String? propriedadeId,
    String? numeroTalhao,
    double? areaHa,
    double? areaAlqueires,
    String? variedade,
    String? cultura,
    int? anoPlantio,
    int? corte,
    DateTime? dataPlantio,
    String? tipoTalhao,
    bool? ativo,
    String? observacoes,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Talhao(
      id: id ?? this.id,
      propriedadeId: propriedadeId ?? this.propriedadeId,
      numeroTalhao: numeroTalhao ?? this.numeroTalhao,
      areaHa: areaHa ?? this.areaHa,
      areaAlqueires: areaAlqueires ?? this.areaAlqueires,
      variedade: variedade ?? this.variedade,
      cultura: cultura ?? this.cultura,
      anoPlantio: anoPlantio ?? this.anoPlantio,
      corte: corte ?? this.corte,
      dataPlantio: dataPlantio ?? this.dataPlantio,
      tipoTalhao: tipoTalhao ?? this.tipoTalhao,
      ativo: ativo ?? this.ativo,
      observacoes: observacoes ?? this.observacoes,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  @override
  String toString() {
    return 'Talhão $numeroTalhao — ${areaHa != null ? areaHa!.toStringAsFixed(1) : "?"} ha';
  }
}

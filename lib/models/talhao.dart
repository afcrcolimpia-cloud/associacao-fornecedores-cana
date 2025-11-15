class Talhao {
  final String id;
  final String propriedadeId;
  final String numeroTalhao;
  final String cultura;
  final double areaHectares;
  final double areaAlqueires;
  final String variedade;
  final DateTime dataPlantio;
  final int anoPlantio;
  final int corte;
  final String? observacoes;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  Talhao({
    required this.id,
    required this.propriedadeId,
    required this.numeroTalhao,
    required this.cultura,
    required this.areaHectares,
    required this.areaAlqueires,
    required this.variedade,
    required this.dataPlantio,
    required this.anoPlantio,
    required this.corte,
    this.observacoes,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  factory Talhao.fromJson(Map<String, dynamic> json) {
    return Talhao(
      id: json['id'] as String,
      propriedadeId: json['propriedade_id'] as String,
      numeroTalhao: json['numero_talhao'] as String,
      cultura: json['variedade'] as String? ?? 'Cana',
      areaHectares: (json['area_hectares'] as num).toDouble(),
      areaAlqueires: (json['area_alqueires'] as num).toDouble(),
      variedade: json['variedade'] as String,
      dataPlantio: DateTime.parse(json['data_plantio']),
      anoPlantio: json['ano_plantio'] as int,
      corte: json['corte_atual'] as int? ?? 1,
      observacoes: json['observacoes'] as String?,
      dataCriacao: DateTime.parse(json['created_at']),
      dataAtualizacao: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'propriedade_id': propriedadeId,
      'numero_talhao': numeroTalhao,
      'variedade': variedade,
      'area_hectares': areaHectares,
      'area_alqueires': areaAlqueires,
      'data_plantio': dataPlantio.toIso8601String().split('T').first,
      'ano_plantio': anoPlantio,
      'corte_atual': corte,
      if (observacoes != null && observacoes!.isNotEmpty) 'observacoes': observacoes,
      'created_at': dataCriacao.toUtc().toIso8601String(),
      'updated_at': dataAtualizacao.toUtc().toIso8601String(),
    };
  }

  // Getters para compatibilidade
  DateTime get criadoEm => dataCriacao;
  DateTime get atualizadoEm => dataAtualizacao;
}
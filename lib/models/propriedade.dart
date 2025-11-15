class Propriedade {
  final String id;
  final String proprietarioId;
  final String nomePropriedade;
  final String? municipio;
  final String? estado;
  final double areaTotalHectares;
  final String? numeroFA;
  final String? inscricaoEstadual;
  final String? coordenadasGPS;
  final bool ativa;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  Propriedade({
    required this.id,
    required this.proprietarioId,
    required this.nomePropriedade,
    this.municipio,
    this.estado,
    required this.areaTotalHectares,
    this.numeroFA,
    this.inscricaoEstadual,
    this.coordenadasGPS,
    this.ativa = true,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  factory Propriedade.fromJson(Map<String, dynamic> json) {
    return Propriedade(
      id: json['id'] as String,
      proprietarioId: json['proprietario_id'] as String,
      nomePropriedade: json['nome'] as String,
      municipio: json['municipio'] as String?,
      estado: json['estado'] as String?,
      areaTotalHectares: (json['area_total'] as num).toDouble(),
      numeroFA: json['numero_fa'] as String?,
      inscricaoEstadual: json['inscricao_estadual'] as String?,
      coordenadasGPS: json['coordenadas_gps'] as String?,
      ativa: json['ativa'] as bool? ?? true,
      dataCriacao: DateTime.parse(json['created_at']),
      dataAtualizacao: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'proprietario_id': proprietarioId,
      'nome': nomePropriedade,
      if (municipio != null && municipio!.isNotEmpty) 'municipio': municipio,
      if (estado != null && estado!.isNotEmpty) 'estado': estado,
      'area_total': areaTotalHectares,
      if (numeroFA != null && numeroFA!.isNotEmpty) 'numero_fa': numeroFA,
      if (inscricaoEstadual != null && inscricaoEstadual!.isNotEmpty) 'inscricao_estadual': inscricaoEstadual,
      if (coordenadasGPS != null && coordenadasGPS!.isNotEmpty) 'coordenadas_gps': coordenadasGPS,
      'ativa': ativa,
      'created_at': dataCriacao.toUtc().toIso8601String(),
      'updated_at': dataAtualizacao.toUtc().toIso8601String(),
    };
  }

  // Getters para compatibilidade
  DateTime get criadoEm => dataCriacao;
  DateTime get atualizadoEm => dataAtualizacao;
}
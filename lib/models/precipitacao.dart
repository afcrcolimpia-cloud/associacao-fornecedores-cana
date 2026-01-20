// lib/models/precipitacao.dart

class Precipitacao {
  final String id;
  final String propriedadeId;
  final DateTime data;
  final double volume; // em milímetros
  final String municipio; // município de SP
  final String? observacoes;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Precipitacao({
    required this.id,
    required this.propriedadeId,
    required this.data,
    required this.volume,
    required this.municipio,
    this.observacoes,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory Precipitacao.fromJson(Map<String, dynamic> json) {
    return Precipitacao(
      id: json['id'] ?? '',
      propriedadeId: json['propriedade_id'] ?? '',
      data: json['data'] != null ? DateTime.parse(json['data']) : DateTime.now(),
      volume: (json['volume'] ?? 0).toDouble(),
      municipio: json['municipio'] ?? 'São Paulo',
      observacoes: json['observacoes'],
      criadoEm: json['criado_em'] != null ? DateTime.parse(json['criado_em']) : DateTime.now(),
      atualizadoEm: json['atualizado_em'] != null ? DateTime.parse(json['atualizado_em']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propriedade_id': propriedadeId,
      'data': data.toIso8601String(),
      'volume': volume,
      'municipio': municipio,
      'observacoes': observacoes,
      'criado_em': criadoEm.toIso8601String(),
      'atualizado_em': atualizadoEm.toIso8601String(),
    };
  }

  Precipitacao copyWith({
    String? id,
    String? propriedadeId,
    DateTime? data,
    double? volume,
    String? municipio,
    String? observacoes,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Precipitacao(
      id: id ?? this.id,
      propriedadeId: propriedadeId ?? this.propriedadeId,
      data: data ?? this.data,
      volume: volume ?? this.volume,
      municipio: municipio ?? this.municipio,
      observacoes: observacoes ?? this.observacoes,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}

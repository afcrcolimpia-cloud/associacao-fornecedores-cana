// lib/models/precipitacao.dart

class Precipitacao {
  final String id;
  final String propriedadeId;
  final String municipio;
  final DateTime data;
  final int mes; // 1-12
  final int ano;
  final double milimetros; // ✅ MUDADO DE 'volume' para 'milimetros'
  final String? observacoes;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Precipitacao({
    required this.id,
    required this.propriedadeId,
    required this.municipio,
    required this.data,
    required this.mes,
    required this.ano,
    required this.milimetros,
    this.observacoes,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory Precipitacao.fromJson(Map<String, dynamic> json) {
    final dataObj = json['data'] != null ? DateTime.parse(json['data']) : DateTime.now();
    
    return Precipitacao(
      id: json['id'] ?? '',
      propriedadeId: json['propriedade_id'] ?? '',
      municipio: json['municipio'] ?? 'São Paulo',
      data: dataObj,
      mes: json['mes'] ?? dataObj.month,
      ano: json['ano'] ?? dataObj.year,
      milimetros: (json['milimetros'] ?? 0).toDouble(), // ✅ CORRIGIDO
      observacoes: json['observacoes'],
      criadoEm: json['criado_em'] != null 
          ? DateTime.parse(json['criado_em']) 
          : DateTime.now(),
      atualizadoEm: json['atualizado_em'] != null 
          ? DateTime.parse(json['atualizado_em']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propriedade_id': propriedadeId,
      'municipio': municipio,
      'data': data.toIso8601String().split('T')[0], // Enviar apenas a data (YYYY-MM-DD)
      'mes': mes,
      'ano': ano,
      'milimetros': milimetros, // ✅ CORRIGIDO
      'observacoes': observacoes,
      'criado_em': criadoEm.toIso8601String(),
      'atualizado_em': atualizadoEm.toIso8601String(),
    };
  }

  Precipitacao copyWith({
    String? id,
    String? propriedadeId,
    String? municipio,
    DateTime? data,
    int? mes,
    int? ano,
    double? milimetros,
    String? observacoes,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Precipitacao(
      id: id ?? this.id,
      propriedadeId: propriedadeId ?? this.propriedadeId,
      municipio: municipio ?? this.municipio,
      data: data ?? this.data,
      mes: mes ?? this.mes,
      ano: ano ?? this.ano,
      milimetros: milimetros ?? this.milimetros,
      observacoes: observacoes ?? this.observacoes,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}
class Produtividade {
  final String id;
  final String propriedadeId;
  final String? talhaoId;
  final String anoSafra;
  final String? variedade;
  final String? estagio;
  final int? mesColheita;
  final double? pesoLiquidoToneladas;
  final double? mediaATR;
  final String? observacoes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Produtividade({
    required this.id,
    required this.propriedadeId,
    this.talhaoId,
    required this.anoSafra,
    this.variedade,
    this.estagio,
    this.mesColheita,
    this.pesoLiquidoToneladas,
    this.mediaATR,
    this.observacoes,
    this.createdAt,
    this.updatedAt,
  });

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propriedade_id': propriedadeId,
      'talhao_id': talhaoId,
      'ano_safra': anoSafra,
      'variedade': variedade,
      'estagio': estagio,
      'mes_colheita': mesColheita,
      'peso_liquido_toneladas': pesoLiquidoToneladas,
      'media_atr': mediaATR,
      'observacoes': observacoes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Criar do JSON
  factory Produtividade.fromJson(Map<String, dynamic> json) {
    return Produtividade(
      id: json['id']?.toString() ?? '',
      propriedadeId: json['propriedade_id']?.toString() ?? '',
      talhaoId: json['talhao_id']?.toString(),
      anoSafra: json['ano_safra']?.toString() ?? '',
      variedade: json['variedade']?.toString(),
      estagio: json['estagio']?.toString(),
      mesColheita: json['mes_colheita'] != null
          ? (json['mes_colheita'] is int
              ? json['mes_colheita'] as int
              : int.tryParse(json['mes_colheita'].toString()))
          : null,
      pesoLiquidoToneladas: json['peso_liquido_toneladas'] != null
          ? (json['peso_liquido_toneladas'] as num).toDouble()
          : null,
      mediaATR: json['media_atr'] != null
          ? (json['media_atr'] as num).toDouble()
          : null,
      observacoes: json['observacoes']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  // Cópia com alterações
  Produtividade copyWith({
    String? id,
    String? propriedadeId,
    String? talhaoId,
    String? anoSafra,
    String? variedade,
    String? estagio,
    int? mesColheita,
    double? pesoLiquidoToneladas,
    double? mediaATR,
    String? observacoes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Produtividade(
      id: id ?? this.id,
      propriedadeId: propriedadeId ?? this.propriedadeId,
      talhaoId: talhaoId ?? this.talhaoId,
      anoSafra: anoSafra ?? this.anoSafra,
      variedade: variedade ?? this.variedade,
      estagio: estagio ?? this.estagio,
      mesColheita: mesColheita ?? this.mesColheita,
      pesoLiquidoToneladas: pesoLiquidoToneladas ?? this.pesoLiquidoToneladas,
      mediaATR: mediaATR ?? this.mediaATR,
      observacoes: observacoes ?? this.observacoes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Produtividade(id: $id, propriedadeId: $propriedadeId, anoSafra: $anoSafra, variedade: $variedade)';
  }
}
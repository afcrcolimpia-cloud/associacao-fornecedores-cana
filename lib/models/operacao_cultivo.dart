// ============================================
// MODELO: OperacaoCultivo
// ============================================

class OperacaoCultivo {
  final String? id;
  final String propriedadeId;
  final String talhaoId;
  final DateTime dataPlantio;
  final DateTime? dataQuebraLombo;
  final DateTime? dataColheita;
  final DateTime? data1aAplicHerbicida;
  final DateTime? data2aAplicHerbicida;
  final String? observacoes;
  final DateTime createdAt;
  final DateTime updatedAt;

  OperacaoCultivo({
    this.id,
    required this.propriedadeId,
    required this.talhaoId,
    required this.dataPlantio,
    this.dataQuebraLombo,
    this.dataColheita,
    this.data1aAplicHerbicida,
    this.data2aAplicHerbicida,
    this.observacoes,
    required this.createdAt,
    required this.updatedAt,
  });

  // From Supabase JSON
  factory OperacaoCultivo.fromJson(Map<String, dynamic> json) {
    return OperacaoCultivo(
      id: json['id'] as String?,
      propriedadeId: json['propriedade_id'] as String,
      talhaoId: json['talhao_id'] as String,
      dataPlantio: DateTime.parse(json['data_plantio'] as String),
      dataQuebraLombo: json['data_quebra_lombo'] != null
          ? DateTime.parse(json['data_quebra_lombo'] as String)
          : null,
      dataColheita: json['data_colheita'] != null
          ? DateTime.parse(json['data_colheita'] as String)
          : null,
      data1aAplicHerbicida: json['data_1a_aplic_herbicida'] != null
          ? DateTime.parse(json['data_1a_aplic_herbicida'] as String)
          : null,
      data2aAplicHerbicida: json['data_2a_aplic_herbicida'] != null
          ? DateTime.parse(json['data_2a_aplic_herbicida'] as String)
          : null,
      observacoes: json['observacoes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // To Supabase JSON (para UPDATE)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'propriedade_id': propriedadeId,
      'talhao_id': talhaoId,
      'data_plantio': dataPlantio.toIso8601String().split('T')[0],
      'data_quebra_lombo': dataQuebraLombo?.toIso8601String().split('T')[0],
      'data_colheita': dataColheita?.toIso8601String().split('T')[0],
      'data_1a_aplic_herbicida': data1aAplicHerbicida?.toIso8601String().split('T')[0],
      'data_2a_aplic_herbicida': data2aAplicHerbicida?.toIso8601String().split('T')[0],
      'observacoes': observacoes,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Para inserção (sem id, created_at, updated_at)
  Map<String, dynamic> toJsonInsert() {
    return {
      'propriedade_id': propriedadeId,
      'talhao_id': talhaoId,
      'data_plantio': dataPlantio.toIso8601String().split('T')[0],
      'data_quebra_lombo': dataQuebraLombo?.toIso8601String().split('T')[0],
      'data_colheita': dataColheita?.toIso8601String().split('T')[0],
      'data_1a_aplic_herbicida': data1aAplicHerbicida?.toIso8601String().split('T')[0],
      'data_2a_aplic_herbicida': data2aAplicHerbicida?.toIso8601String().split('T')[0],
      'observacoes': observacoes,
    };
  }

  OperacaoCultivo copyWith({
    String? id,
    String? propriedadeId,
    String? talhaoId,
    DateTime? dataPlantio,
    DateTime? dataQuebraLombo,
    DateTime? dataColheita,
    DateTime? data1aAplicHerbicida,
    DateTime? data2aAplicHerbicida,
    String? observacoes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OperacaoCultivo(
      id: id ?? this.id,
      propriedadeId: propriedadeId ?? this.propriedadeId,
      talhaoId: talhaoId ?? this.talhaoId,
      dataPlantio: dataPlantio ?? this.dataPlantio,
      dataQuebraLombo: dataQuebraLombo ?? this.dataQuebraLombo,
      dataColheita: dataColheita ?? this.dataColheita,
      data1aAplicHerbicida: data1aAplicHerbicida ?? this.data1aAplicHerbicida,
      data2aAplicHerbicida: data2aAplicHerbicida ?? this.data2aAplicHerbicida,
      observacoes: observacoes ?? this.observacoes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

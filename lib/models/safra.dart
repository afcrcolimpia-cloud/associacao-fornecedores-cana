class Safra {
  final String id;
  final String proprietarioId;
  final String safra; // "2025/26"
  final DateTime dataInicio;
  final DateTime dataFim;
  final String status; // "ativa", "finalizada", "planejada"
  final String? observacoes;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Safra({
    required this.id,
    required this.proprietarioId,
    required this.safra,
    required this.dataInicio,
    required this.dataFim,
    this.status = 'ativa',
    this.observacoes,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  // ── Getters computados ──────────────────────────────────────

  bool get estaAtiva {
    final agora = DateTime.now();
    return agora.isAfter(dataInicio) && agora.isBefore(dataFim);
  }

  int get diasDesdeInicio =>
      DateTime.now().difference(dataInicio).inDays.clamp(0, duracao);

  int get duracao => dataFim.difference(dataInicio).inDays;

  double get percentualCiclo {
    if (duracao <= 0) return 0;
    final diasPassados = DateTime.now().difference(dataInicio).inDays;
    return (diasPassados / duracao * 100).clamp(0, 100);
  }

  int get diasRestantes {
    final restantes = dataFim.difference(DateTime.now()).inDays;
    return restantes.clamp(0, duracao);
  }

  String get statusFormatado {
    switch (status) {
      case 'ativa':
        return 'Ativa';
      case 'finalizada':
        return 'Finalizada';
      case 'planejada':
        return 'Planejada';
      default:
        return status;
    }
  }

  // ── Serialização ────────────────────────────────────────────

  static DateTime _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.parse(value).toLocal();
    }
    return DateTime.now();
  }

  factory Safra.fromJson(Map<String, dynamic> json) {
    return Safra(
      id: json['id'] as String,
      proprietarioId: json['proprietario_id'] as String,
      safra: json['safra'] as String,
      dataInicio: _parseDate(json['data_inicio']),
      dataFim: _parseDate(json['data_fim']),
      status: json['status'] as String? ?? 'ativa',
      observacoes: json['observacoes'] as String?,
      criadoEm: _parseDate(json['criado_em']),
      atualizadoEm: _parseDate(json['atualizado_em']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'proprietario_id': proprietarioId,
      'safra': safra,
      'data_inicio': dataInicio.toIso8601String().substring(0, 10),
      'data_fim': dataFim.toIso8601String().substring(0, 10),
      'status': status,
      'observacoes': observacoes,
      'criado_em': criadoEm.toUtc().toIso8601String(),
      'atualizado_em': atualizadoEm.toUtc().toIso8601String(),
    };
  }

  Safra copyWith({
    String? id,
    String? proprietarioId,
    String? safra,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? status,
    String? observacoes,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Safra(
      id: id ?? this.id,
      proprietarioId: proprietarioId ?? this.proprietarioId,
      safra: safra ?? this.safra,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      status: status ?? this.status,
      observacoes: observacoes ?? this.observacoes,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  String toString() =>
      'Safra(safra: $safra, status: $status, ciclo: ${percentualCiclo.toStringAsFixed(1)}%)';
}

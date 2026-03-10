// lib/models/variedade.dart

class Variedade {
  final String id;
  final String codigo; // SP 80-1842, RB 92-579, etc
  final String nome; // Nome da variedade
  final String caracteristicas; // Descrição das características
  final String ambienteProducao; // A, B, C, D, E
  final int mesesColheita; // Quantos meses de colheita
  final bool ativa;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Variedade({
    required this.id,
    required this.codigo,
    required this.nome,
    required this.caracteristicas,
    required this.ambienteProducao,
    required this.mesesColheita,
    required this.ativa,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory Variedade.fromJson(Map<String, dynamic> json) {
    return Variedade(
      id: json['id'] ?? '',
      codigo: json['codigo'] ?? '',
      nome: json['nome'] ?? '',
      caracteristicas: json['caracteristicas'] ?? '',
      ambienteProducao: json['ambiente_producao'] ?? 'A',
      mesesColheita: json['meses_colheita'] ?? 0,
      ativa: json['ativa'] ?? true,
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
      'codigo': codigo,
      'nome': nome,
      'caracteristicas': caracteristicas,
      'ambiente_producao': ambienteProducao,
      'meses_colheita': mesesColheita,
      'ativa': ativa,
      'criado_em': criadoEm.toIso8601String(),
      'atualizado_em': atualizadoEm.toIso8601String(),
    };
  }

  Variedade copyWith({
    String? id,
    String? codigo,
    String? nome,
    String? caracteristicas,
    String? ambienteProducao,
    int? mesesColheita,
    bool? ativa,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Variedade(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nome: nome ?? this.nome,
      caracteristicas: caracteristicas ?? this.caracteristicas,
      ambienteProducao: ambienteProducao ?? this.ambienteProducao,
      mesesColheita: mesesColheita ?? this.mesesColheita,
      ativa: ativa ?? this.ativa,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  String toString() => '$codigo - $nome';
}
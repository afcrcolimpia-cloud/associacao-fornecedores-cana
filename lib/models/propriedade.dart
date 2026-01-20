class Propriedade {
  final String id;
  final String proprietarioId;
  final String nomePropriedade;
  final String numeroFA;

  // Aliases (uso em UI / compatibilidade)
  final String? nome; // Alias para nomePropriedade
  final String? fa;   // Alias para numeroFA

  final String? endereco;
  final String? cidade;
  final String? estado;
  final String? cep;
  final double? areaHa;
  final double? areaAlqueires;
  final bool? ativa;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Propriedade({
    required this.id,
    required this.proprietarioId,
    required this.nomePropriedade,
    required this.numeroFA,
    this.endereco,
    this.cidade,
    this.estado,
    this.cep,
    this.areaHa,
    this.areaAlqueires,
    this.ativa,
    required this.criadoEm,
    required this.atualizadoEm,
  })  : nome = nomePropriedade,
        fa = numeroFA;

  // Converter para JSON (ENVIAR PARA O SUPABASE)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'proprietario_id': proprietarioId,
      'nome_propriedade': nomePropriedade,
      'numero_fa': numeroFA,
      'endereco': endereco,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'area_ha': areaHa,
      'area_alqueires': areaAlqueires,
      'ativa': ativa ?? true,
      'criado_em': criadoEm.toIso8601String(),
      'atualizado_em': atualizadoEm.toIso8601String(),
    };
  }

  // Criar objeto A PARTIR DO SUPABASE
  factory Propriedade.fromJson(Map<String, dynamic> json) {
    return Propriedade(
      id: json['id']?.toString() ?? '',
      proprietarioId: json['proprietario_id']?.toString() ?? '',
      nomePropriedade: json['nome_propriedade']?.toString() ?? '',
      numeroFA: json['numero_fa']?.toString() ?? '',
      endereco: json['endereco']?.toString(),
      cidade: json['cidade']?.toString(),
      estado: json['estado']?.toString(),
      cep: json['cep']?.toString(),
      areaHa: json['area_ha'] != null
          ? (json['area_ha'] as num).toDouble()
          : null,
      areaAlqueires: json['area_alqueires'] != null
          ? (json['area_alqueires'] as num).toDouble()
          : null,
      ativa: json['ativa'] as bool? ?? true,
      criadoEm: json['criado_em'] != null
          ? DateTime.parse(json['criado_em'])
          : DateTime.now(),
      atualizadoEm: json['atualizado_em'] != null
          ? DateTime.parse(json['atualizado_em'])
          : DateTime.now(),
    );
  }

  // Cópia com alterações
  Propriedade copyWith({
    String? id,
    String? proprietarioId,
    String? nomePropriedade,
    String? numeroFA,
    String? endereco,
    String? cidade,
    String? estado,
    String? cep,
    double? areaHa,
    double? areaAlqueires,
    bool? ativa,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Propriedade(
      id: id ?? this.id,
      proprietarioId: proprietarioId ?? this.proprietarioId,
      nomePropriedade: nomePropriedade ?? this.nomePropriedade,
      numeroFA: numeroFA ?? this.numeroFA,
      endereco: endereco ?? this.endereco,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      cep: cep ?? this.cep,
      areaHa: areaHa ?? this.areaHa,
      areaAlqueires: areaAlqueires ?? this.areaAlqueires,
      ativa: ativa ?? this.ativa,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return 'Propriedade(id: $id, nome: $nomePropriedade, FA: $numeroFA)';
  }
}

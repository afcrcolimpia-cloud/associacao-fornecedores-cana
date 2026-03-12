class InsumoComDose {
  final String id;
  final String categoria;
  final String tipo;
  final String produto;
  final String? situacao;
  final double doseMinima;
  final double doseMaxima;
  final String unidade;
  final double precoUnitario;
  final String? observacoes;
  final DateTime dataCriacao;

  InsumoComDose({
    required this.id,
    required this.categoria,
    required this.tipo,
    required this.produto,
    this.situacao,
    required this.doseMinima,
    required this.doseMaxima,
    required this.unidade,
    required this.precoUnitario,
    this.observacoes,
    required this.dataCriacao,
  });

  factory InsumoComDose.fromJson(Map<String, dynamic> json) {
    return InsumoComDose(
      id: json['id']?.toString() ?? '',
      categoria: json['categoria']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      produto: json['produto']?.toString() ?? '',
      situacao: json['situacao']?.toString(),
      doseMinima: (json['dose_minima'] as num?)?.toDouble() ?? 0.0,
      doseMaxima: (json['dose_maxima'] as num?)?.toDouble() ?? 0.0,
      unidade: json['unidade']?.toString() ?? '',
      precoUnitario: (json['preco_unitario'] as num?)?.toDouble() ?? 0.0,
      observacoes: json['observacoes']?.toString(),
      dataCriacao: json['data_criacao'] != null
          ? DateTime.tryParse(json['data_criacao'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoria': categoria,
      'tipo': tipo,
      'produto': produto,
      'situacao': situacao,
      'dose_minima': doseMinima,
      'dose_maxima': doseMaxima,
      'unidade': unidade,
      'preco_unitario': precoUnitario,
      'observacoes': observacoes,
      'data_criacao': dataCriacao.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'InsumoComDose(produto: $produto, dose: $doseMinima-$doseMaxima $unidade, preço: R\$ $precoUnitario)';
  }
}

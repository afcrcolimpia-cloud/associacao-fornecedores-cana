class Proprietario {
  final String id;
  final String nome;
  final String documento;
  final String? telefone;
  final String? email;
  final String? endereco;
  final String? cidade;
  final String? estado;
  final String? cep;
  final bool ativo;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  Proprietario({
    required this.id,
    required this.nome,
    required this.documento,
    this.telefone,
    this.email,
    this.endereco,
    this.cidade,
    this.estado,
    this.cep,
    this.ativo = true,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  factory Proprietario.fromJson(Map<String, dynamic> json) {
    return Proprietario(
      id: json['id'] as String,
      nome: json['nome'] as String,
      documento: json['documento'] as String,
      telefone: json['telefone'] as String?,
      email: json['email'] as String?,
      endereco: json['endereco'] as String?,
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,
      cep: json['cep'] as String?,
      ativo: json['ativo'] as bool? ?? true,
      dataCriacao: DateTime.parse(json['data_criacao']),
      dataAtualizacao: DateTime.parse(json['data_atualizacao']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'nome': nome,
      'documento': documento,
      if (telefone != null && telefone!.isNotEmpty) 'telefone': telefone,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (endereco != null && endereco!.isNotEmpty) 'endereco': endereco,
      if (cidade != null && cidade!.isNotEmpty) 'cidade': cidade,
      if (estado != null && estado!.isNotEmpty) 'estado': estado,
      if (cep != null && cep!.isNotEmpty) 'cep': cep,
      'ativo': ativo,
      'data_criacao': dataCriacao.toUtc().toIso8601String(),
      'data_atualizacao': dataAtualizacao.toUtc().toIso8601String(),
    };
  }

  // Getters para compatibilidade com código antigo
  String get cpfCnpj => documento;
  DateTime get criadoEm => dataCriacao;
  DateTime get atualizadoEm => dataAtualizacao;
}
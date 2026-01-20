// lib/models/proprietario.dart
class Proprietario {
  final String id;
  final String nome;
  final String cpfCnpj;
  final String? telefone;
  final String? email;
  final String? endereco;
  final String? cidade;
  final String? estado;
  final String? cep;
  final bool ativo;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Proprietario({
    required this.id,
    required this.nome,
    required this.cpfCnpj,
    this.telefone,
    this.email,
    this.endereco,
    this.cidade,
    this.estado,
    this.cep,
    this.ativo = true,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  static DateTime _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.parse(value).toLocal();
    }
    return DateTime.now();
  }

  factory Proprietario.fromJson(Map<String, dynamic> json) {
    return Proprietario(
      id: json['id'] as String,
      nome: json['nome'] as String,
      cpfCnpj: json['cpf_cnpj'] as String,
      telefone: json['telefone'] as String?,
      email: json['email'] as String?,
      endereco: json['endereco'] as String?,
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,
      cep: json['cep'] as String?,
      ativo: json['ativo'] ?? true,
      criadoEm: _parseDate(json['criado_em'] ?? json['data_criacao']),
      atualizadoEm: _parseDate(json['atualizado_em'] ?? json['data_atualizacao']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'nome': nome,
      'cpf_cnpj': cpfCnpj,
      'telefone': telefone,
      'email': email,
      'endereco': endereco,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'ativo': ativo,
      'criado_em': criadoEm.toUtc().toIso8601String(),
      'atualizado_em': atualizadoEm.toUtc().toIso8601String(),
    };
  }

  Proprietario copyWith({
    String? id,
    String? nome,
    String? cpfCnpj,
    String? telefone,
    String? email,
    String? endereco,
    String? cidade,
    String? estado,
    String? cep,
    bool? ativo,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Proprietario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      endereco: endereco ?? this.endereco,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      cep: cep ?? this.cep,
      ativo: ativo ?? this.ativo,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}
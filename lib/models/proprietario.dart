import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Proprietario.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Proprietario(
      id: doc.id,
      nome: data['nome'] ?? '',
      cpfCnpj: data['cpfCnpj'] ?? '',
      telefone: data['telefone'],
      email: data['email'],
      endereco: data['endereco'],
      cidade: data['cidade'],
      estado: data['estado'],
      cep: data['cep'],
      ativo: data['ativo'] ?? true,
      criadoEm: (data['criadoEm'] as Timestamp).toDate(),
      atualizadoEm: (data['atualizadoEm'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'cpfCnpj': cpfCnpj,
      'telefone': telefone,
      'email': email,
      'endereco': endereco,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'ativo': ativo,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'atualizadoEm': Timestamp.fromDate(atualizadoEm),
    };
  }
}
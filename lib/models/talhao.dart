import 'package:cloud_firestore/cloud_firestore.dart';

class Talhao {
  final String id;
  final String propriedadeId;
  final String numeroTalhao;
  final double areaHectares;
  final double areaAlqueires;
  final String variedade;
  final int anoPlantio;
  final int corte;
  final String? observacoes;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Talhao({
    required this.id,
    required this.propriedadeId,
    required this.numeroTalhao,
    required this.areaHectares,
    required this.areaAlqueires,
    required this.variedade,
    required this.anoPlantio,
    this.corte = 1,
    this.observacoes,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory Talhao.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Talhao(
      id: doc.id,
      propriedadeId: data['propriedadeId'] ?? '',
      numeroTalhao: data['numeroTalhao'] ?? '',
      areaHectares: (data['areaHectares'] ?? 0).toDouble(),
      areaAlqueires: (data['areaAlqueires'] ?? 0).toDouble(),
      variedade: data['variedade'] ?? '',
      anoPlantio: data['anoPlantio'] ?? DateTime.now().year,
      corte: data['corte'] ?? 1,
      observacoes: data['observacoes'],
      criadoEm: (data['criadoEm'] as Timestamp).toDate(),
      atualizadoEm: (data['atualizadoEm'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'propriedadeId': propriedadeId,
      'numeroTalhao': numeroTalhao,
      'areaHectares': areaHectares,
      'areaAlqueires': areaAlqueires,
      'variedade': variedade,
      'anoPlantio': anoPlantio,
      'corte': corte,
      'observacoes': observacoes,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'atualizadoEm': Timestamp.fromDate(atualizadoEm),
    };
  }
}
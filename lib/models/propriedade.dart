import 'package:cloud_firestore/cloud_firestore.dart';

class Propriedade {
  final String id;
  final String proprietarioId;
  final String nomePropriedade;
  final String numeroFA;
  final String? inscricaoEstadual;
  final String? municipio;
  final String? coordenadasGPS;
  final bool ativa;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Propriedade({
    required this.id,
    required this.proprietarioId,
    required this.nomePropriedade,
    required this.numeroFA,
    this.inscricaoEstadual,
    this.municipio,
    this.coordenadasGPS,
    this.ativa = true,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory Propriedade.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Propriedade(
      id: doc.id,
      proprietarioId: data['proprietarioId'] ?? '',
      nomePropriedade: data['nomePropriedade'] ?? '',
      numeroFA: data['numeroFA'] ?? '',
      inscricaoEstadual: data['inscricaoEstadual'],
      municipio: data['municipio'],
      coordenadasGPS: data['coordenadasGPS'],
      ativa: data['ativa'] ?? true,
      criadoEm: (data['criadoEm'] as Timestamp).toDate(),
      atualizadoEm: (data['atualizadoEm'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'proprietarioId': proprietarioId,
      'nomePropriedade': nomePropriedade,
      'numeroFA': numeroFA,
      'inscricaoEstadual': inscricaoEstadual,
      'municipio': municipio,
      'coordenadasGPS': coordenadasGPS,
      'ativa': ativa,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'atualizadoEm': Timestamp.fromDate(atualizadoEm),
    };
  }
}
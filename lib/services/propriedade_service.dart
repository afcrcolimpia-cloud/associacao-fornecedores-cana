import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class PropriedadeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPropriedades = 'propriedades';
  final String collectionTalhoes = 'talhoes';

  Stream<List<Propriedade>> getPropriedadesByProprietarioStream(String proprietarioId) {
    return _firestore
        .collection(collectionPropriedades)
        .where('proprietarioId', isEqualTo: proprietarioId)
        .orderBy('nomePropriedade')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Propriedade.fromFirestore(doc))
            .toList());
  }

  Future<Propriedade?> getPropriedade(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(collectionPropriedades).doc(id).get();
      if (doc.exists) {
        return Propriedade.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Erro ao buscar propriedade: $e';
    }
  }

  Future<String> addPropriedade(Propriedade propriedade) async {
    try {
      DocumentReference doc = await _firestore
          .collection(collectionPropriedades)
          .add(propriedade.toFirestore());
      return doc.id;
    } catch (e) {
      throw 'Erro ao adicionar propriedade: $e';
    }
  }

  Future<void> updatePropriedade(Propriedade propriedade) async {
    try {
      await _firestore
          .collection(collectionPropriedades)
          .doc(propriedade.id)
          .update(propriedade.toFirestore());
    } catch (e) {
      throw 'Erro ao atualizar propriedade: $e';
    }
  }

  Future<void> deletePropriedade(String id) async {
    try {
      await _firestore.collection(collectionPropriedades).doc(id).delete();
    } catch (e) {
      throw 'Erro ao deletar propriedade: $e';
    }
  }

  // TALHÕES
  Stream<List<Talhao>> getTalhoesByPropriedadeStream(String propriedadeId) {
    return _firestore
        .collection(collectionTalhoes)
        .where('propriedadeId', isEqualTo: propriedadeId)
        .orderBy('numeroTalhao')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Talhao.fromFirestore(doc))
            .toList());
  }

  Future<String> addTalhao(Talhao talhao) async {
    try {
      DocumentReference doc = await _firestore
          .collection(collectionTalhoes)
          .add(talhao.toFirestore());
      return doc.id;
    } catch (e) {
      throw 'Erro ao adicionar talhão: $e';
    }
  }

  Future<void> updateTalhao(Talhao talhao) async {
    try {
      await _firestore
          .collection(collectionTalhoes)
          .doc(talhao.id)
          .update(talhao.toFirestore());
    } catch (e) {
      throw 'Erro ao atualizar talhão: $e';
    }
  }

  Future<void> deleteTalhao(String id) async {
    try {
      await _firestore.collection(collectionTalhoes).doc(id).delete();
    } catch (e) {
      throw 'Erro ao deletar talhão: $e';
    }
  }
}
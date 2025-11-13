import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class ProprietarioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'proprietarios';

  Stream<List<Proprietario>> getProprietariosStream() {
    return _firestore
        .collection(collection)
        .orderBy('nome')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Proprietario.fromFirestore(doc))
            .toList());
  }

  Future<Proprietario?> getProprietario(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(collection).doc(id).get();
      if (doc.exists) {
        return Proprietario.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Erro ao buscar proprietário: $e';
    }
  }

  Future<String> addProprietario(Proprietario proprietario) async {
    try {
      DocumentReference doc = await _firestore.collection(collection).add(
            proprietario.toFirestore(),
          );
      return doc.id;
    } catch (e) {
      throw 'Erro ao adicionar proprietário: $e';
    }
  }

  Future<void> updateProprietario(Proprietario proprietario) async {
    try {
      await _firestore
          .collection(collection)
          .doc(proprietario.id)
          .update(proprietario.toFirestore());
    } catch (e) {
      throw 'Erro ao atualizar proprietário: $e';
    }
  }

  Future<void> deleteProprietario(String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
    } catch (e) {
      throw 'Erro ao deletar proprietário: $e';
    }
  }

  Future<Proprietario?> getByCpfCnpj(String cpfCnpj) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(collection)
          .where('cpfCnpj', isEqualTo: cpfCnpj)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Proprietario.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw 'Erro ao buscar por CPF/CNPJ: $e';
    }
  }
}
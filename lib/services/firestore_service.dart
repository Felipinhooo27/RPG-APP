import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/character.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Coleção de personagens
  final String _charactersCollection = 'characters';

  // CRUD - Create
  Future<void> createCharacter(Character character) async {
    try {
      final newId = character.id.isEmpty ? _uuid.v4() : character.id;
      final characterWithId = character.copyWith(id: newId);

      await _firestore
          .collection(_charactersCollection)
          .doc(newId)
          .set(characterWithId.toMap());
    } catch (e) {
      throw Exception('Erro ao criar personagem: $e');
    }
  }

  // CRUD - Read (Todos os personagens)
  Stream<List<Character>> getAllCharacters() {
    return _firestore
        .collection(_charactersCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Character.fromMap(doc.data());
      }).toList();
    });
  }

  // CRUD - Read (Personagens do usuário - Modo Jogador)
  Stream<List<Character>> getCharactersByUser(String userId) {
    return _firestore
        .collection(_charactersCollection)
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Character.fromMap(doc.data());
      }).toList();
    });
  }

  // CRUD - Read (Um personagem específico)
  Future<Character?> getCharacter(String id) async {
    try {
      final doc = await _firestore
          .collection(_charactersCollection)
          .doc(id)
          .get();

      if (doc.exists) {
        return Character.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar personagem: $e');
    }
  }

  // CRUD - Update
  Future<void> updateCharacter(Character character) async {
    try {
      await _firestore
          .collection(_charactersCollection)
          .doc(character.id)
          .update(character.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar personagem: $e');
    }
  }

  // CRUD - Delete
  Future<void> deleteCharacter(String id) async {
    try {
      await _firestore
          .collection(_charactersCollection)
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Erro ao excluir personagem: $e');
    }
  }

  // Atualizar apenas os status (PV, PE, PS, Créditos)
  Future<void> updateCharacterStatus({
    required String characterId,
    int? pvAtual,
    int? peAtual,
    int? psAtual,
    int? creditos,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (pvAtual != null) updates['status.pv_atual'] = pvAtual;
      if (peAtual != null) updates['status.pe_atual'] = peAtual;
      if (psAtual != null) updates['status.ps_atual'] = psAtual;
      if (creditos != null) updates['status.creditos'] = creditos;

      if (updates.isNotEmpty) {
        await _firestore
            .collection(_charactersCollection)
            .doc(characterId)
            .update(updates);
      }
    } catch (e) {
      throw Exception('Erro ao atualizar status do personagem: $e');
    }
  }

  // Importar múltiplos personagens (para função de importação)
  Future<void> importCharacters(List<Character> characters, String userId) async {
    try {
      final batch = _firestore.batch();

      for (var character in characters) {
        final newId = _uuid.v4();
        final characterWithNewId = character.copyWith(
          id: newId,
          createdBy: userId, // Atribui ao usuário que está importando
        );

        final docRef = _firestore
            .collection(_charactersCollection)
            .doc(newId);

        batch.set(docRef, characterWithNewId.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao importar personagens: $e');
    }
  }
}

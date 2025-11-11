import 'package:uuid/uuid.dart';
import '../../models/character.dart';
import 'local_storage.dart';

/// Repository para gerenciar operações CRUD de personagens
class CharacterRepository {
  final LocalStorage _storage = LocalStorage();
  final _uuid = const Uuid();

  /// Carrega todos os personagens
  Future<List<Character>> getAll() async {
    final data = await _storage.loadCharacters();
    return data.map((json) => Character.fromJson(json)).toList();
  }

  /// Carrega personagens de um usuário específico
  Future<List<Character>> getByUserId(String userId) async {
    final all = await getAll();
    return all.where((char) => char.userId == userId).toList();
  }

  /// Carrega um personagem por ID
  Future<Character?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((char) => char.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Cria um novo personagem
  Future<Character> create(Character character) async {
    final all = await getAll();

    // Garante ID único
    final newChar = character.copyWith(
      id: character.id.isEmpty ? _uuid.v4() : character.id,
      criadoEm: DateTime.now(),
      atualizadoEm: DateTime.now(),
    );

    all.add(newChar);
    await _save(all);
    return newChar;
  }

  /// Atualiza um personagem existente
  Future<Character> update(Character character) async {
    final all = await getAll();
    final index = all.indexWhere((char) => char.id == character.id);

    if (index == -1) {
      throw Exception('Personagem não encontrado: ${character.id}');
    }

    final updated = character.copyWith(atualizadoEm: DateTime.now());
    all[index] = updated;
    await _save(all);
    return updated;
  }

  /// Deleta um personagem
  Future<bool> delete(String id) async {
    final all = await getAll();
    final initialLength = all.length;
    all.removeWhere((char) => char.id == id);

    if (all.length == initialLength) {
      return false; // Não encontrou
    }

    await _save(all);
    return true;
  }

  /// Deleta todos os personagens de um usuário
  Future<int> deleteByUserId(String userId) async {
    final all = await getAll();
    final initialLength = all.length;
    all.removeWhere((char) => char.userId == userId);

    final deletedCount = initialLength - all.length;
    if (deletedCount > 0) {
      await _save(all);
    }

    return deletedCount;
  }

  /// Importa uma lista de personagens (adiciona ou atualiza)
  Future<List<Character>> importCharacters(List<Character> characters, {bool replace = false}) async {
    List<Character> all;

    if (replace) {
      all = [];
    } else {
      all = await getAll();
    }

    final imported = <Character>[];

    for (final char in characters) {
      final index = all.indexWhere((c) => c.id == char.id);

      if (index == -1) {
        // Novo personagem
        final newChar = char.copyWith(
          criadoEm: DateTime.now(),
          atualizadoEm: DateTime.now(),
        );
        all.add(newChar);
        imported.add(newChar);
      } else {
        // Atualiza existente
        final updated = char.copyWith(atualizadoEm: DateTime.now());
        all[index] = updated;
        imported.add(updated);
      }
    }

    await _save(all);
    return imported;
  }

  /// Exporta personagens (retorna JSON)
  Future<List<Map<String, dynamic>>> exportCharacters(List<String> ids) async {
    final all = await getAll();
    final toExport = all.where((char) => ids.contains(char.id)).toList();
    return toExport.map((char) => char.toJson()).toList();
  }

  /// Exporta todos os personagens de um usuário
  Future<List<Map<String, dynamic>>> exportByUserId(String userId) async {
    final characters = await getByUserId(userId);
    return characters.map((char) => char.toJson()).toList();
  }

  /// Atualiza recursos (PV, PE, SAN, Créditos) de um personagem
  Future<Character> updateResources({
    required String id,
    int? pvAtual,
    int? peAtual,
    int? sanAtual,
    int? creditos,
  }) async {
    final character = await getById(id);
    if (character == null) {
      throw Exception('Personagem não encontrado: $id');
    }

    final updated = character.copyWith(
      pvAtual: pvAtual ?? character.pvAtual,
      peAtual: peAtual ?? character.peAtual,
      sanAtual: sanAtual ?? character.sanAtual,
      creditos: creditos ?? character.creditos,
      atualizadoEm: DateTime.now(),
    );

    return await update(updated);
  }

  /// Adiciona créditos a um personagem
  Future<Character> addCredits(String id, int amount) async {
    final character = await getById(id);
    if (character == null) {
      throw Exception('Personagem não encontrado: $id');
    }

    return await updateResources(
      id: id,
      creditos: character.creditos + amount,
    );
  }

  /// Remove créditos de um personagem
  Future<Character> removeCredits(String id, int amount) async {
    final character = await getById(id);
    if (character == null) {
      throw Exception('Personagem não encontrado: $id');
    }

    final newCredits = (character.creditos - amount).clamp(0, 999999);
    return await updateResources(
      id: id,
      creditos: newCredits,
    );
  }

  /// Cura PV de um personagem
  Future<Character> healPV(String id, int amount) async {
    final character = await getById(id);
    if (character == null) {
      throw Exception('Personagem não encontrado: $id');
    }

    final newPV = (character.pvAtual + amount).clamp(0, character.pvMax);
    return await updateResources(
      id: id,
      pvAtual: newPV,
    );
  }

  /// Causa dano em um personagem
  Future<Character> damagePV(String id, int amount) async {
    final character = await getById(id);
    if (character == null) {
      throw Exception('Personagem não encontrado: $id');
    }

    final newPV = (character.pvAtual - amount).clamp(0, character.pvMax);
    return await updateResources(
      id: id,
      pvAtual: newPV,
    );
  }

  /// Recupera PE de um personagem
  Future<Character> restorePE(String id, int amount) async {
    final character = await getById(id);
    if (character == null) {
      throw Exception('Personagem não encontrado: $id');
    }

    final newPE = (character.peAtual + amount).clamp(0, character.peMax);
    return await updateResources(
      id: id,
      peAtual: newPE,
    );
  }

  /// Gasta PE de um personagem
  Future<Character> spendPE(String id, int amount) async {
    final character = await getById(id);
    if (character == null) {
      throw Exception('Personagem não encontrado: $id');
    }

    if (character.peAtual < amount) {
      throw Exception('PE insuficiente');
    }

    return await updateResources(
      id: id,
      peAtual: character.peAtual - amount,
    );
  }

  /// Restaura SAN de um personagem
  Future<Character> restoreSAN(String id, int amount) async {
    final character = await getById(id);
    if (character == null) {
      throw Exception('Personagem não encontrado: $id');
    }

    final newSAN = (character.sanAtual + amount).clamp(0, character.sanMax);
    return await updateResources(
      id: id,
      sanAtual: newSAN,
    );
  }

  /// Perde SAN de um personagem
  Future<Character> loseSAN(String id, int amount) async {
    final character = await getById(id);
    if (character == null) {
      throw Exception('Personagem não encontrado: $id');
    }

    final newSAN = (character.sanAtual - amount).clamp(0, character.sanMax);
    return await updateResources(
      id: id,
      sanAtual: newSAN,
    );
  }

  /// Salva a lista completa
  Future<void> _save(List<Character> characters) async {
    final jsonList = characters.map((char) => char.toJson()).toList();
    await _storage.saveCharacters(jsonList);
  }

  /// Limpa todos os personagens
  Future<bool> clearAll() async {
    await _storage.saveCharacters([]);
    return true;
  }

  /// Conta total de personagens
  Future<int> count() async {
    final all = await getAll();
    return all.length;
  }

  /// Conta personagens por usuário
  Future<int> countByUserId(String userId) async {
    final characters = await getByUserId(userId);
    return characters.length;
  }
}

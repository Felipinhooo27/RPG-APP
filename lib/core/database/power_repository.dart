import 'package:uuid/uuid.dart';
import '../../models/power.dart';
import 'local_storage.dart';

/// Repository para gerenciar operações CRUD de poderes e rituais
class PowerRepository {
  final LocalStorage _storage = LocalStorage();
  final _uuid = const Uuid();

  /// Carrega todos os poderes
  Future<List<Power>> getAll() async {
    final data = await _storage.loadPowers();
    return data.map((json) => Power.fromJson(json)).toList();
  }

  /// Carrega poderes de um personagem específico
  Future<List<Power>> getByCharacterId(String characterId) async {
    final all = await getAll();
    return all.where((power) => power.characterId == characterId).toList();
  }

  /// Carrega um poder por ID
  Future<Power?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((power) => power.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Cria um novo poder
  Future<Power> create(Power power) async {
    final all = await getAll();

    // Garante ID único
    final newPower = power.copyWith(
      id: power.id.isEmpty ? _uuid.v4() : power.id,
      criadoEm: DateTime.now(),
      atualizadoEm: DateTime.now(),
    );

    all.add(newPower);
    await _save(all);
    return newPower;
  }

  /// Atualiza um poder existente
  Future<Power> update(Power power) async {
    final all = await getAll();
    final index = all.indexWhere((p) => p.id == power.id);

    if (index == -1) {
      throw Exception('Poder não encontrado: ${power.id}');
    }

    final updated = power.copyWith(atualizadoEm: DateTime.now());
    all[index] = updated;
    await _save(all);
    return updated;
  }

  /// Deleta um poder
  Future<bool> delete(String id) async {
    final all = await getAll();
    final initialLength = all.length;
    all.removeWhere((power) => power.id == id);

    if (all.length == initialLength) {
      return false; // Não encontrou
    }

    await _save(all);
    return true;
  }

  /// Deleta todos os poderes de um personagem
  Future<int> deleteByCharacterId(String characterId) async {
    final all = await getAll();
    final initialLength = all.length;
    all.removeWhere((power) => power.characterId == characterId);

    final deletedCount = initialLength - all.length;
    if (deletedCount > 0) {
      await _save(all);
    }

    return deletedCount;
  }

  /// Importa uma lista de poderes (adiciona ou atualiza)
  Future<List<Power>> importPowers(List<Power> powers, {bool replace = false, String? characterId}) async {
    List<Power> all;

    if (replace) {
      all = [];
    } else {
      all = await getAll();
    }

    final imported = <Power>[];

    for (final power in powers) {
      // Sempre gera um novo ID ao importar para evitar conflitos
      final newPower = power.copyWith(
        id: _uuid.v4(), // Novo ID único
        characterId: characterId ?? power.characterId, // Usa characterId fornecido ou mantém o original
        criadoEm: DateTime.now(),
        atualizadoEm: DateTime.now(),
      );
      all.add(newPower);
      imported.add(newPower);
    }

    await _save(all);
    return imported;
  }

  /// Exporta poderes (retorna JSON)
  Future<List<Map<String, dynamic>>> exportPowers(List<String> ids) async {
    final all = await getAll();
    final toExport = all.where((power) => ids.contains(power.id)).toList();
    return toExport.map((power) => power.toJson()).toList();
  }

  /// Exporta todos os poderes de um personagem
  Future<List<Map<String, dynamic>>> exportByCharacterId(String characterId) async {
    final powers = await getByCharacterId(characterId);
    return powers.map((power) => power.toJson()).toList();
  }

  /// Busca poderes por nome (case insensitive)
  Future<List<Power>> searchByName(String characterId, String query) async {
    final powers = await getByCharacterId(characterId);
    final lowerQuery = query.toLowerCase();
    return powers.where((power) => power.nome.toLowerCase().contains(lowerQuery)).toList();
  }

  /// Filtra poderes por elemento
  Future<List<Power>> filterByElemento(String characterId, ElementoOutroLado elemento) async {
    final powers = await getByCharacterId(characterId);
    return powers.where((power) => power.elemento == elemento).toList();
  }

  /// Filtra apenas rituais
  Future<List<Power>> filterRituaisOnly(String characterId) async {
    final powers = await getByCharacterId(characterId);
    return powers.where((power) => power.isRitual).toList();
  }

  /// Filtra apenas poderes (não-rituais)
  Future<List<Power>> filterPowersBonly(String characterId) async {
    final powers = await getByCharacterId(characterId);
    return powers.where((power) => !power.isRitual).toList();
  }

  /// Filtra por círculo de ritual
  Future<List<Power>> filterByCirculo(String characterId, int circulo) async {
    final powers = await getByCharacterId(characterId);
    return powers.where((power) => power.circulo == circulo).toList();
  }

  /// Calcula custo total de PE dos poderes
  Future<int> getTotalPECost(String characterId) async {
    final powers = await getByCharacterId(characterId);
    return powers.fold<int>(0, (total, power) => total + power.custoPE);
  }

  /// Salva a lista completa
  Future<void> _save(List<Power> powers) async {
    final jsonList = powers.map((power) => power.toJson()).toList();
    await _storage.savePowers(jsonList);
  }

  /// Limpa todos os poderes
  Future<bool> clearAll() async {
    await _storage.savePowers([]);
    return true;
  }

  /// Conta total de poderes
  Future<int> count() async {
    final all = await getAll();
    return all.length;
  }

  /// Conta poderes por personagem
  Future<int> countByCharacterId(String characterId) async {
    final powers = await getByCharacterId(characterId);
    return powers.length;
  }
}

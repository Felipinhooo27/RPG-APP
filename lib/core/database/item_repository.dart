import 'package:uuid/uuid.dart';
import '../../models/item.dart';
import 'local_storage.dart';

/// Repository para gerenciar operações CRUD de itens do inventário
class ItemRepository {
  final LocalStorage _storage = LocalStorage();
  final _uuid = const Uuid();

  /// Carrega todos os itens
  Future<List<Item>> getAll() async {
    final data = await _storage.loadItems();
    return data.map((json) => Item.fromJson(json)).toList();
  }

  /// Carrega itens de um personagem específico
  Future<List<Item>> getByCharacterId(String characterId) async {
    final all = await getAll();
    return all.where((item) => item.characterId == characterId).toList();
  }

  /// Carrega um item por ID
  Future<Item?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Cria um novo item
  Future<Item> create(Item item) async {
    final all = await getAll();

    // Garante ID único
    final newItem = item.copyWith(
      id: item.id.isEmpty ? _uuid.v4() : item.id,
      criadoEm: DateTime.now(),
      atualizadoEm: DateTime.now(),
    );

    all.add(newItem);
    await _save(all);
    return newItem;
  }

  /// Atualiza um item existente
  Future<Item> update(Item item) async {
    final all = await getAll();
    final index = all.indexWhere((i) => i.id == item.id);

    if (index == -1) {
      throw Exception('Item não encontrado: ${item.id}');
    }

    final updated = item.copyWith(atualizadoEm: DateTime.now());
    all[index] = updated;
    await _save(all);
    return updated;
  }

  /// Deleta um item
  Future<bool> delete(String id) async {
    final all = await getAll();
    final initialLength = all.length;
    all.removeWhere((item) => item.id == id);

    if (all.length == initialLength) {
      return false; // Não encontrou
    }

    await _save(all);
    return true;
  }

  /// Deleta todos os itens de um personagem
  Future<int> deleteByCharacterId(String characterId) async {
    final all = await getAll();
    final initialLength = all.length;
    all.removeWhere((item) => item.characterId == characterId);

    final deletedCount = initialLength - all.length;
    if (deletedCount > 0) {
      await _save(all);
    }

    return deletedCount;
  }

  /// Importa uma lista de itens (adiciona ou atualiza)
  Future<List<Item>> importItems(List<Item> items, {bool replace = false, String? characterId}) async {
    List<Item> all;

    if (replace) {
      all = [];
    } else {
      all = await getAll();
    }

    final imported = <Item>[];

    for (final item in items) {
      // Sempre gera um novo ID ao importar para evitar conflitos
      final newItem = item.copyWith(
        id: _uuid.v4(), // Novo ID único
        characterId: characterId ?? item.characterId, // Usa characterId fornecido ou mantém o original
        criadoEm: DateTime.now(),
        atualizadoEm: DateTime.now(),
      );
      all.add(newItem);
      imported.add(newItem);
    }

    await _save(all);
    return imported;
  }

  /// Exporta itens (retorna JSON)
  Future<List<Map<String, dynamic>>> exportItems(List<String> ids) async {
    final all = await getAll();
    final toExport = all.where((item) => ids.contains(item.id)).toList();
    return toExport.map((item) => item.toJson()).toList();
  }

  /// Exporta todos os itens de um personagem
  Future<List<Map<String, dynamic>>> exportByCharacterId(String characterId) async {
    final items = await getByCharacterId(characterId);
    return items.map((item) => item.toJson()).toList();
  }

  /// Atualiza a quantidade de um item
  Future<Item> updateQuantity(String id, int newQuantity) async {
    final item = await getById(id);
    if (item == null) {
      throw Exception('Item não encontrado: $id');
    }

    final updated = item.copyWith(
      quantidade: newQuantity.clamp(0, 999),
      atualizadoEm: DateTime.now(),
    );

    return await update(updated);
  }

  /// Adiciona quantidade a um item
  Future<Item> addQuantity(String id, int amount) async {
    final item = await getById(id);
    if (item == null) {
      throw Exception('Item não encontrado: $id');
    }

    return await updateQuantity(id, item.quantidade + amount);
  }

  /// Remove quantidade de um item
  Future<Item> removeQuantity(String id, int amount) async {
    final item = await getById(id);
    if (item == null) {
      throw Exception('Item não encontrado: $id');
    }

    final newQuantity = (item.quantidade - amount).clamp(0, 999);
    return await updateQuantity(id, newQuantity);
  }

  /// Calcula o peso total do inventário de um personagem
  Future<int> getTotalWeight(String characterId) async {
    final items = await getByCharacterId(characterId);
    return items.fold<int>(0, (total, item) => total + item.espacoTotal);
  }

  /// Busca itens por nome (case insensitive)
  Future<List<Item>> searchByName(String characterId, String query) async {
    final items = await getByCharacterId(characterId);
    final lowerQuery = query.toLowerCase();
    return items.where((item) => item.nome.toLowerCase().contains(lowerQuery)).toList();
  }

  /// Filtra itens por tipo
  Future<List<Item>> filterByType(String characterId, ItemType tipo) async {
    final items = await getByCharacterId(characterId);
    return items.where((item) => item.tipo == tipo).toList();
  }

  /// Filtra itens por categoria customizada
  Future<List<Item>> filterByCategoria(String characterId, String categoria) async {
    final items = await getByCharacterId(characterId);
    return items.where((item) => item.categoria?.toLowerCase() == categoria.toLowerCase()).toList();
  }

  /// Calcula bônus total de defesa de armaduras equipadas
  Future<int> getTotalDefenseBonus(String characterId) async {
    final items = await getByCharacterId(characterId);
    return items
        .where((item) => item.defesaBonus != null && item.defesaBonus! > 0)
        .fold<int>(0, (total, item) => total + (item.defesaBonus ?? 0));
  }

  /// Salva a lista completa
  Future<void> _save(List<Item> items) async {
    final jsonList = items.map((item) => item.toJson()).toList();
    await _storage.saveItems(jsonList);
  }

  /// Limpa todos os itens
  Future<bool> clearAll() async {
    await _storage.saveItems([]);
    return true;
  }

  /// Conta total de itens
  Future<int> count() async {
    final all = await getAll();
    return all.length;
  }

  /// Conta itens por personagem
  Future<int> countByCharacterId(String characterId) async {
    final items = await getByCharacterId(characterId);
    return items.length;
  }
}

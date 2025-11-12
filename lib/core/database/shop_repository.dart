import 'package:uuid/uuid.dart';
import '../../models/shop.dart';
import 'local_storage.dart';

/// Repository para gerenciar operações CRUD de lojas
class ShopRepository {
  final LocalStorage _storage = LocalStorage();
  final _uuid = const Uuid();

  /// Carrega todas as lojas
  Future<List<Shop>> getAll() async {
    final data = await _storage.loadShops();
    return data.map((json) => Shop.fromJson(json)).toList();
  }

  /// Carrega uma loja por ID
  Future<Shop?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((shop) => shop.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Filtra lojas por tipo
  Future<List<Shop>> getByType(ShopType tipo) async {
    final all = await getAll();
    return all.where((shop) => shop.tipo == tipo).toList();
  }

  /// Cria uma nova loja
  Future<Shop> create(Shop shop) async {
    final all = await getAll();

    // Garante ID único
    final newShop = shop.copyWith(
      id: shop.id.isEmpty ? _uuid.v4() : shop.id,
      criadoEm: DateTime.now(),
      atualizadoEm: DateTime.now(),
    );

    all.add(newShop);
    await _save(all);
    return newShop;
  }

  /// Atualiza uma loja existente
  Future<Shop> update(Shop shop) async {
    final all = await getAll();
    final index = all.indexWhere((s) => s.id == shop.id);

    if (index == -1) {
      throw Exception('Loja não encontrada: ${shop.id}');
    }

    final updated = shop.copyWith(atualizadoEm: DateTime.now());
    all[index] = updated;
    await _save(all);
    return updated;
  }

  /// Deleta uma loja
  Future<bool> delete(String id) async {
    final all = await getAll();
    final initialLength = all.length;
    all.removeWhere((shop) => shop.id == id);

    if (all.length == initialLength) {
      return false; // Não encontrou
    }

    await _save(all);
    return true;
  }

  /// Importa lista de lojas (adiciona ou atualiza)
  Future<List<Shop>> importShops(List<Shop> shops, {bool replace = false}) async {
    List<Shop> all;

    if (replace) {
      all = [];
    } else {
      all = await getAll();
    }

    final imported = <Shop>[];

    for (final shop in shops) {
      final index = all.indexWhere((s) => s.id == shop.id);

      if (index == -1) {
        // Nova loja
        final newShop = shop.copyWith(
          criadoEm: DateTime.now(),
          atualizadoEm: DateTime.now(),
        );
        all.add(newShop);
        imported.add(newShop);
      } else {
        // Atualiza existente
        final updated = shop.copyWith(atualizadoEm: DateTime.now());
        all[index] = updated;
        imported.add(updated);
      }
    }

    await _save(all);
    return imported;
  }

  /// Exporta lojas (retorna JSON)
  Future<List<Map<String, dynamic>>> exportShops(List<String> ids) async {
    final all = await getAll();
    final toExport = all.where((shop) => ids.contains(shop.id)).toList();
    return toExport.map((shop) => shop.toJson()).toList();
  }

  /// Adiciona item a uma loja
  Future<Shop> addItem(String shopId, ShopItem item) async {
    final shop = await getById(shopId);
    if (shop == null) {
      throw Exception('Loja não encontrada: $shopId');
    }

    final updatedItems = List<ShopItem>.from(shop.itens);
    updatedItems.add(item);

    final updated = shop.copyWith(
      itens: updatedItems,
      atualizadoEm: DateTime.now(),
    );

    return await update(updated);
  }

  /// Remove item de uma loja
  Future<Shop> removeItem(String shopId, String itemId) async {
    final shop = await getById(shopId);
    if (shop == null) {
      throw Exception('Loja não encontrada: $shopId');
    }

    final updatedItems = shop.itens.where((item) => item.id != itemId).toList();

    final updated = shop.copyWith(
      itens: updatedItems,
      atualizadoEm: DateTime.now(),
    );

    return await update(updated);
  }

  /// Atualiza item de uma loja
  Future<Shop> updateItem(String shopId, ShopItem updatedItem) async {
    final shop = await getById(shopId);
    if (shop == null) {
      throw Exception('Loja não encontrada: $shopId');
    }

    final updatedItems = shop.itens.map((item) {
      if (item.id == updatedItem.id) {
        return updatedItem;
      }
      return item;
    }).toList();

    final updated = shop.copyWith(
      itens: updatedItems,
      atualizadoEm: DateTime.now(),
    );

    return await update(updated);
  }

  /// Duplica uma loja (útil para criar variações)
  Future<Shop> duplicate(String shopId, {String? newName}) async {
    final shop = await getById(shopId);
    if (shop == null) {
      throw Exception('Loja não encontrada: $shopId');
    }

    // Gera novos IDs para os itens também
    final duplicatedItems = shop.itens.map((item) {
      return ShopItem(
        id: _uuid.v4(),
        nome: item.nome,
        descricao: item.descricao,
        tipo: item.tipo,
        preco: item.preco,
        espacoUnitario: item.espacoUnitario,
        patenteMinima: item.patenteMinima,
        formulaDano: item.formulaDano,
        multiplicadorCritico: item.multiplicadorCritico,
        efeitoCritico: item.efeitoCritico,
        isAmaldicoado: item.isAmaldicoado,
        efeitoMaldicao: item.efeitoMaldicao,
        formulaCura: item.formulaCura,
        efeitoAdicional: item.efeitoAdicional,
      );
    }).toList();

    final duplicated = Shop(
      id: _uuid.v4(),
      nome: newName ?? '${shop.nome} (Cópia)',
      descricao: shop.descricao,
      tipo: shop.tipo,
      itens: duplicatedItems,
      criadoEm: DateTime.now(),
      atualizadoEm: DateTime.now(),
    );

    return await create(duplicated);
  }

  /// Conta total de itens em uma loja
  Future<int> countItems(String shopId) async {
    final shop = await getById(shopId);
    return shop?.itens.length ?? 0;
  }

  /// Busca lojas por nome (case insensitive)
  Future<List<Shop>> searchByName(String query) async {
    final all = await getAll();
    final lowerQuery = query.toLowerCase();
    return all.where((shop) => shop.nome.toLowerCase().contains(lowerQuery)).toList();
  }

  /// Salva a lista completa
  Future<void> _save(List<Shop> shops) async {
    final jsonList = shops.map((shop) => shop.toJson()).toList();
    final success = await _storage.saveShops(jsonList);
    if (!success) {
      throw Exception('Falha ao salvar lojas no armazenamento');
    }
  }

  /// Limpa todas as lojas
  Future<bool> clearAll() async {
    await _storage.saveShops([]);
    return true;
  }

  /// Conta total de lojas
  Future<int> count() async {
    final all = await getAll();
    return all.length;
  }
}

import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/shop_item.dart';
import '../models/character.dart';
import '../models/item.dart';
import 'local_database_service.dart';

/// Serviço de gerenciamento de lojas - Armazenamento em JSON
class ShopService {
  static final ShopService _instance = ShopService._internal();
  factory ShopService() => _instance;
  ShopService._internal();

  final LocalDatabaseService _dbService = LocalDatabaseService();
  final Uuid _uuid = const Uuid();

  // ==================== HELPER: Carregar/Salvar JSON ====================

  Future<List<Shop>> _loadShops() async {
    final jsonString = await _dbService.getShopsJson();

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Shop.fromMap(json)).toList();
    } catch (e) {
      print('Erro ao carregar lojas: $e');
      return [];
    }
  }

  Future<void> _saveShops(List<Shop> shops) async {
    final jsonList = shops.map((s) => s.toMap()).toList();
    final jsonString = jsonEncode(jsonList);
    await _dbService.setShopsJson(jsonString);
  }

  // ==================== CRUD de Lojas ====================

  /// Criar nova loja
  Future<void> createShop(Shop shop) async {
    final shops = await _loadShops();
    shops.add(shop);
    await _saveShops(shops);
  }

  /// Buscar loja por ID
  Future<Shop?> getShop(String id) async {
    final shops = await _loadShops();
    try {
      return shops.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Listar todas as lojas (ordenadas por data de criação, mais recentes primeiro)
  Future<List<Shop>> getAllShops() async {
    final shops = await _loadShops();

    // Ordenar por createdAt em ordem decrescente (mais recentes primeiro)
    shops.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return shops;
  }

  /// Listar lojas de um mestre específico (ordenadas por data de criação)
  Future<List<Shop>> getShopsByMaster(String masterId) async {
    final shops = await _loadShops();

    // Filtrar por masterId
    final filtered = shops.where((s) => s.createdBy == masterId).toList();

    // Ordenar por createdAt em ordem decrescente
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  /// Atualizar loja
  Future<void> updateShop(Shop shop) async {
    final shops = await _loadShops();

    final index = shops.indexWhere((s) => s.id == shop.id);
    if (index != -1) {
      shops[index] = shop;
      await _saveShops(shops);
    }
  }

  /// Deletar loja
  Future<void> deleteShop(String id) async {
    final shops = await _loadShops();
    shops.removeWhere((s) => s.id == id);
    await _saveShops(shops);
  }

  // ==================== Operações de Compra ====================

  /// Processar compra de itens
  Future<PurchaseResult> processPurchase({
    required Character character,
    required List<CartItem> cartItems,
    required Shop shop,
  }) async {
    // Calcular totais
    final totalPrice = cartItems.fold<int>(
      0,
      (sum, item) => sum + item.precoTotal,
    );

    final totalSpace = cartItems.fold<int>(
      0,
      (sum, item) => sum + item.espacoTotal,
    );

    final currentInventorySpace = character.inventario.fold<int>(
      0,
      (sum, item) => sum + (item.espaco * item.quantidade),
    );

    // Validações
    if (character.creditos < totalPrice) {
      return PurchaseResult(
        success: false,
        message: 'Créditos insuficientes! Necessário: $totalPrice, Disponível: ${character.creditos}',
      );
    }

    // Verificar patente mínima
    for (final cartItem in cartItems) {
      final patenteValue = _getPatenteValue(character.patente);
      if (patenteValue < cartItem.item.patenteMinima) {
        return PurchaseResult(
          success: false,
          message: 'Patente insuficiente para "${cartItem.item.nome}". Necessário: ${cartItem.item.patenteMinima}',
        );
      }
    }

    // Verificar espaço no inventário (assumindo limite de 100)
    const maxInventorySpace = 100;
    if (currentInventorySpace + totalSpace > maxInventorySpace) {
      return PurchaseResult(
        success: false,
        message: 'Espaço insuficiente no inventário! Necessário: $totalSpace, Disponível: ${maxInventorySpace - currentInventorySpace}',
      );
    }

    // Processar compra - adicionar itens ao inventário
    final newInventory = List<Item>.from(character.inventario);

    for (final cartItem in cartItems) {
      final shopItem = cartItem.item;

      // Converter ShopItem para Item
      final item = Item(
        id: shopItem.id,
        nome: shopItem.nome,
        descricao: shopItem.descricao,
        quantidade: cartItem.quantidade,
        tipo: shopItem.tipo,
        espaco: shopItem.espaco,
        iconCode: shopItem.iconCode,
        isAmaldicoado: shopItem.isAmaldicoado,
        formulaDano: shopItem.formulaDano,
        formulaCura: shopItem.formulaCura,
        efeitoEspecial: shopItem.efeitoEspecial,
      );

      // Verificar se já existe item igual no inventário
      final existingIndex = newInventory.indexWhere((i) => i.nome == item.nome);

      if (existingIndex != -1) {
        // Incrementar quantidade
        final existing = newInventory[existingIndex];
        newInventory[existingIndex] = existing.copyWith(
          quantidade: existing.quantidade + item.quantidade,
        );
      } else {
        // Adicionar novo item
        newInventory.add(item);
      }
    }

    // Deduzir créditos e atualizar histórico
    final newCredits = character.creditos - totalPrice;
    final newPurchaseHistory = List<String>.from(character.purchaseHistory);

    final purchaseRecord = '${DateTime.now().toIso8601String()}|${shop.nome}|$totalPrice';
    newPurchaseHistory.add(purchaseRecord);

    return PurchaseResult(
      success: true,
      message: 'Compra realizada com sucesso!',
      newCredits: newCredits,
      newInventory: newInventory,
      newPurchaseHistory: newPurchaseHistory,
    );
  }

  /// Obter valor numérico da patente
  int _getPatenteValue(String patente) {
    // Extrair número da patente (ex: "Recruta 5" -> 5)
    final numbers = RegExp(r'\d+').allMatches(patente);
    if (numbers.isEmpty) return 0;

    return int.parse(numbers.first.group(0) ?? '0');
  }

  // ==================== Import/Export ====================

  /// Exportar loja para JSON
  Future<String> exportShop(String shopId) async {
    final shop = await getShop(shopId);
    if (shop == null) throw Exception('Loja não encontrada');

    final exportData = {
      'version': '1.0',
      'shop': shop.toMap(),
      'exportDate': DateTime.now().toIso8601String(),
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Importar loja de JSON
  Future<Shop> importShop(String jsonString, String newCreatedBy) async {
    final data = jsonDecode(jsonString);

    final shopData = data['shop'] as Map<String, dynamic>;
    final shop = Shop.fromMap(shopData);

    // Criar nova loja com novo ID, createdBy e createdAt
    final newShop = shop.copyWith(
      id: _uuid.v4(), // Gerar novo ID para evitar conflitos
      createdBy: newCreatedBy,
      createdAt: DateTime.now(),
    );

    await createShop(newShop);

    return newShop;
  }
}

/// Resultado de uma operação de compra
class PurchaseResult {
  final bool success;
  final String message;
  final int? newCredits;
  final List<Item>? newInventory;
  final List<String>? newPurchaseHistory;

  PurchaseResult({
    required this.success,
    required this.message,
    this.newCredits,
    this.newInventory,
    this.newPurchaseHistory,
  });
}

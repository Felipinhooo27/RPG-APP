import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/character.dart';
import '../../models/shop.dart';
import '../../models/item.dart';
import '../../core/database/character_repository.dart';
import '../../core/database/shop_repository.dart';
import '../../core/database/item_repository.dart';

/// Tela de Loja para Jogadores
/// Compra de itens, validação de créditos e espaço
/// Com sistema de filtros, pesquisa, importação e exclusão
class ShopScreen extends StatefulWidget {
  final Character character;
  final VoidCallback? onCharacterChanged;

  const ShopScreen({
    super.key,
    required this.character,
    this.onCharacterChanged,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final CharacterRepository _charRepo = CharacterRepository();
  final ShopRepository _shopRepo = ShopRepository();
  final ItemRepository _itemRepo = ItemRepository();
  final TextEditingController _searchController = TextEditingController();

  late Character _character;
  Shop? _currentShop;
  List<ShopItem> _cart = [];
  List<ShopItem> _filteredItems = [];
  bool _isLoading = true;

  // Filtros
  ItemType? _selectedType;
  int? _selectedPatente;
  double _maxPrice = 10000;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _character = widget.character;
    _loadShop();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadShop() async {
    setState(() => _isLoading = true);
    try {
      final shops = await _shopRepo.getAll();
      setState(() {
        _currentShop = shops.isNotEmpty ? shops.first : _createDefaultShop();
        _filteredItems = _currentShop?.itens ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentShop = _createDefaultShop();
        _filteredItems = _currentShop?.itens ?? [];
        _isLoading = false;
      });
    }
  }

  Shop _createDefaultShop() {
    return Shop(
      id: 'shop_unified',
      nome: 'Mercado da Ordem',
      tipo: ShopType.mercador,
      descricao: 'Equipamentos, armas e suprimentos',
      itens: [
        ShopItem(
          id: 'item_001',
          nome: 'Pistola 9mm',
          tipo: ItemType.arma,
          preco: 500,
          espacoUnitario: 2,
          patenteMinima: 0,
          descricao: 'Arma de fogo básica',
          formulaDano: '1d10',
        ),
        ShopItem(
          id: 'item_002',
          nome: 'Faca de Combate',
          tipo: ItemType.arma,
          preco: 150,
          espacoUnitario: 1,
          patenteMinima: 0,
          descricao: 'Arma branca confiável',
          formulaDano: '1d6',
        ),
        ShopItem(
          id: 'item_003',
          nome: 'Colete Balístico Leve',
          tipo: ItemType.equipamento,
          preco: 800,
          espacoUnitario: 3,
          patenteMinima: 0,
          descricao: 'Proteção básica (+2 defesa)',
        ),
        ShopItem(
          id: 'item_004',
          nome: 'Munição 9mm (50 balas)',
          tipo: ItemType.municao,
          preco: 50,
          espacoUnitario: 1,
          patenteMinima: 0,
          descricao: 'Munição padrão',
        ),
        ShopItem(
          id: 'item_005',
          nome: 'Kit Médico',
          tipo: ItemType.cura,
          preco: 200,
          espacoUnitario: 2,
          patenteMinima: 0,
          descricao: 'Restaura 2d6 PV',
          formulaCura: '2d6',
        ),
        ShopItem(
          id: 'item_006',
          nome: 'Analgésicos',
          tipo: ItemType.consumivel,
          preco: 50,
          espacoUnitario: 1,
          patenteMinima: 0,
          descricao: 'Remove penalidades de ferimentos',
        ),
        ShopItem(
          id: 'item_007',
          nome: 'Adrenalina',
          tipo: ItemType.consumivel,
          preco: 300,
          espacoUnitario: 1,
          patenteMinima: 1,
          descricao: '+2 ações por 2 turnos',
        ),
        ShopItem(
          id: 'item_008',
          nome: 'Mochila Tática',
          tipo: ItemType.equipamento,
          preco: 100,
          espacoUnitario: 0,
          patenteMinima: 0,
          descricao: '+5 espaços de inventário',
        ),
        ShopItem(
          id: 'item_009',
          nome: 'Lanterna Tática',
          tipo: ItemType.equipamento,
          preco: 80,
          espacoUnitario: 1,
          patenteMinima: 0,
          descricao: 'Ilumina ambientes escuros',
        ),
        ShopItem(
          id: 'item_010',
          nome: 'Corda (15m)',
          tipo: ItemType.equipamento,
          preco: 50,
          espacoUnitario: 2,
          patenteMinima: 0,
          descricao: 'Escaladas e amarrações',
        ),
      ],
    );
  }

  void _applyFilters() {
    if (_currentShop == null) return;

    setState(() {
      _filteredItems = _currentShop!.itens.where((item) {
        // Filtro de pesquisa
        final searchQuery = _searchController.text.toLowerCase();
        if (searchQuery.isNotEmpty) {
          final matchesSearch = item.nome.toLowerCase().contains(searchQuery) ||
                                 item.descricao.toLowerCase().contains(searchQuery);
          if (!matchesSearch) return false;
        }

        // Filtro de tipo
        if (_selectedType != null && item.tipo != _selectedType) {
          return false;
        }

        // Filtro de patente
        if (_selectedPatente != null && item.patenteMinima > _selectedPatente!) {
          return false;
        }

        // Filtro de preço
        if (item.preco > _maxPrice) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedType = null;
      _selectedPatente = null;
      _maxPrice = 10000;
      _searchController.clear();
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.conhecimentoGreen),
      );
    }

    if (_currentShop == null) {
      return _buildEmptyState();
    }

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchAndFilters(),
          if (_showFilters) _buildFilterPanel(),
          Expanded(
            child: _filteredItems.isEmpty
                ? _buildNoResultsState()
                : _buildShopInventory(),
          ),
          if (_cart.isNotEmpty) _buildCartSummary(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 64, color: AppColors.silver.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Nenhuma loja disponível',
            style: AppTextStyles.body.copyWith(color: AppColors.silver),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _importShop,
            icon: const Icon(Icons.file_download),
            label: const Text('IMPORTAR LOJA'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.conhecimentoGreen,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.silver.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Nenhum item encontrado',
            style: AppTextStyles.body.copyWith(color: AppColors.silver),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _resetFilters,
            child: const Text('LIMPAR FILTROS'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border(
          bottom: BorderSide(color: AppColors.conhecimentoGreen.withOpacity(0.3), width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.store, color: AppColors.conhecimentoGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  (_currentShop?.nome ?? 'LOJA').toUpperCase(),
                  style: AppTextStyles.uppercase.copyWith(
                    fontSize: 14,
                    color: AppColors.conhecimentoGreen,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.silver),
                color: AppColors.darkGray,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                onSelected: (value) {
                  if (value == 'import') {
                    _importShop();
                  } else if (value == 'delete') {
                    _deleteShop();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'import',
                    child: Row(
                      children: [
                        const Icon(Icons.file_download, color: AppColors.conhecimentoGreen, size: 18),
                        const SizedBox(width: 8),
                        Text('Importar Loja', style: TextStyle(color: AppColors.lightGray)),
                      ],
                    ),
                  ),
                  if (_currentShop != null)
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: AppColors.neonRed, size: 18),
                          const SizedBox(width: 8),
                          Text('Excluir Loja', style: TextStyle(color: AppColors.neonRed)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatChip('CRÉDITOS', '\$${_character.creditos}', AppColors.conhecimentoGreen),
              const SizedBox(width: 12),
              _buildStatChip('CARRINHO', '${_cart.length}', AppColors.magenta),
              const SizedBox(width: 12),
              _buildStatChip('ITENS', '${_filteredItems.length}', AppColors.energiaYellow),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.deepBlack,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.darkGray,
                border: Border.all(color: AppColors.silver.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: AppColors.lightGray, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Pesquisar itens...',
                  hintStyle: TextStyle(color: AppColors.silver.withOpacity(0.5), fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: AppColors.silver, size: 18),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: AppColors.silver, size: 18),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: _showFilters ? AppColors.magenta : AppColors.darkGray,
              border: Border.all(
                color: _showFilters ? AppColors.magenta : AppColors.silver.withOpacity(0.3),
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color: _showFilters ? AppColors.deepBlack : AppColors.silver,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border(
          bottom: BorderSide(color: AppColors.silver.withOpacity(0.2)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FILTROS',
                style: AppTextStyles.uppercase.copyWith(
                  fontSize: 11,
                  color: AppColors.magenta,
                ),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: Text(
                  'LIMPAR',
                  style: TextStyle(fontSize: 10, color: AppColors.neonRed),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filtro de Tipo
          Text(
            'TIPO DE ITEM',
            style: TextStyle(
              fontSize: 9,
              color: AppColors.silver.withOpacity(0.7),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ItemType.values.map((type) {
              final isSelected = _selectedType == type;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedType = isSelected ? null : type;
                    _applyFilters();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.magenta.withOpacity(0.3) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.magenta : AppColors.silver.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getItemTypeName(type),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? AppColors.magenta : AppColors.silver,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Filtro de Patente
          Text(
            'PATENTE MÁXIMA',
            style: TextStyle(
              fontSize: 9,
              color: AppColors.silver.withOpacity(0.7),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(6, (index) {
              final isSelected = _selectedPatente == index;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedPatente = isSelected ? null : index;
                    _applyFilters();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.conhecimentoGreen.withOpacity(0.3) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.conhecimentoGreen : AppColors.silver.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getPatenteLabel(index),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? AppColors.conhecimentoGreen : AppColors.silver,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Filtro de Preço
          Row(
            children: [
              Text(
                'PREÇO MÁXIMO: ',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.silver.withOpacity(0.7),
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '\$${_maxPrice.toInt()}',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.energiaYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: _maxPrice,
            min: 0,
            max: 10000,
            divisions: 100,
            activeColor: AppColors.energiaYellow,
            inactiveColor: AppColors.darkGray,
            onChanged: (value) {
              setState(() {
                _maxPrice = value;
                _applyFilters();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShopInventory() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        final inCart = _cart.any((i) => i.id == item.id);
        return _buildItemCard(item, inCart);
      },
    );
  }

  Widget _buildItemCard(ShopItem item, bool inCart) {
    final canAfford = _character.creditos >= item.preco;
    final color = _getItemTypeColor(item.tipo);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: inCart ? color.withOpacity(0.1) : AppColors.darkGray,
        border: Border.all(
          color: inCart ? color : AppColors.silver.withOpacity(0.3),
          width: inCart ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge de tipo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  border: Border.all(color: color, width: 1),
                ),
                child: Text(
                  _getItemTypeName(item.tipo).toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome.toUpperCase(),
                      style: AppTextStyles.uppercase.copyWith(
                        fontSize: 13,
                        color: canAfford ? AppColors.lightGray : AppColors.silver.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.descricao,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.silver.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${item.preco}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: canAfford ? AppColors.conhecimentoGreen : AppColors.neonRed,
                    ),
                  ),
                  Text(
                    '${item.espacoUnitario} esp.',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.silver.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Patente mínima: ${_getPatenteLabel(item.patenteMinima)}',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.silver.withOpacity(0.5),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: canAfford ? () => _toggleCart(item) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: inCart ? AppColors.neonRed : color,
                    disabledBackgroundColor: AppColors.darkGray,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    inCart ? 'REMOVER' : 'ADICIONAR',
                    style: const TextStyle(fontSize: 11, letterSpacing: 1.0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleCart(ShopItem item) async {
    // Se já está no carrinho, remove
    if (_cart.any((i) => i.id == item.id)) {
      setState(() {
        _cart.removeWhere((i) => i.id == item.id);
      });
      return;
    }

    // Valida espaço antes de adicionar
    final pesoAtual = await _calcularPesoAtualInventario();
    final pesoCarrinho = _cart.fold<int>(0, (sum, i) => sum + i.espacoUnitario);
    final pesoTotal = pesoAtual + pesoCarrinho + item.espacoUnitario;
    final pesoMaximo = _character.pesoMaximo;

    if (pesoTotal > pesoMaximo) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Espaço insuficiente! Peso: $pesoTotal/$pesoMaximo kg',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.neonRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      _cart.add(item);
    });
  }

  /// Calcula o peso atual do inventário do personagem
  Future<int> _calcularPesoAtualInventario() async {
    final items = await _itemRepo.getByCharacterId(_character.id);
    return items.fold<int>(0, (sum, item) => sum + item.espacoTotal);
  }

  Widget _buildCartSummary() {
    final totalPreco = _cart.fold<int>(0, (sum, item) => sum + item.preco);
    final totalEspaco = _cart.fold<int>(0, (sum, item) => sum + item.espacoUnitario);
    final canPurchase = totalPreco <= _character.creditos;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border(
          top: BorderSide(color: AppColors.magenta.withOpacity(0.3), width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL',
                    style: AppTextStyles.uppercase.copyWith(
                      fontSize: 12,
                      color: AppColors.silver,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$$totalPreco',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: canPurchase ? AppColors.conhecimentoGreen : AppColors.neonRed,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ESPAÇO',
                    style: AppTextStyles.uppercase.copyWith(
                      fontSize: 10,
                      color: AppColors.silver.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '$totalEspaco slots',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.silver.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _cart.clear()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonRed,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text('LIMPAR'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: canPurchase ? _completePurchase : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.conhecimentoGreen,
                    disabledBackgroundColor: AppColors.darkGray,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text('FINALIZAR COMPRA'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _completePurchase() async {
    final totalPreco = _cart.fold<int>(0, (sum, item) => sum + item.preco);

    try {
      final updatedChar = _character.copyWith(
        creditos: _character.creditos - totalPreco,
      );

      await _charRepo.update(updatedChar);

      // Cria os itens no inventário
      final uuid = Uuid();
      for (final shopItem in _cart) {
        final item = Item(
          id: uuid.v4(),
          characterId: _character.id,
          nome: shopItem.nome,
          descricao: shopItem.descricao,
          tipo: shopItem.tipo,
          espaco: shopItem.espacoUnitario,
          quantidade: 1, // Cada item comprado tem quantidade 1
          formulaDano: shopItem.formulaDano,
          multiplicadorCritico: shopItem.multiplicadorCritico,
          efeitoCritico: shopItem.efeitoCritico,
          isAmaldicoado: shopItem.isAmaldicoado,
          efeitoMaldicao: shopItem.efeitoMaldicao,
          formulaCura: shopItem.formulaCura,
          efeitoAdicional: shopItem.efeitoAdicional,
          criadoEm: DateTime.now(),
          atualizadoEm: DateTime.now(),
        );
        await _itemRepo.create(item);
      }

      setState(() {
        _character = updatedChar;
        _cart.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Compra realizada! Saldo: \$${updatedChar.creditos}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.conhecimentoGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Notifica o pai para recarregar o personagem
        widget.onCharacterChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao finalizar compra: $e'),
            backgroundColor: AppColors.neonRed,
          ),
        );
      }
    }
  }

  Future<void> _importShop() async {
    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Row(
          children: [
            const Icon(Icons.file_download, color: AppColors.conhecimentoGreen, size: 20),
            const SizedBox(width: 8),
            Text(
              'IMPORTAR LOJA',
              style: AppTextStyles.uppercase.copyWith(
                color: AppColors.conhecimentoGreen,
                fontSize: 14,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cole o JSON da loja enviado pelo mestre:',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.silver),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.deepBlack,
                border: Border.all(color: AppColors.silver.withOpacity(0.3)),
              ),
              child: TextField(
                controller: controller,
                maxLines: null,
                style: TextStyle(
                  color: AppColors.lightGray,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  hintText: '{"version":"1.0","type":"shop"...}',
                  hintStyle: TextStyle(
                    color: AppColors.silver.withOpacity(0.3),
                    fontSize: 11,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.conhecimentoGreen,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('IMPORTAR'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.isNotEmpty) {
      try {
        final jsonData = jsonDecode(controller.text);
        final shopExport = ShopExport.fromJson(jsonData);

        await _shopRepo.clearAll();
        await _shopRepo.create(shopExport.shop);

        _loadShop();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loja "${shopExport.shop.nome}" importada com sucesso!'),
              backgroundColor: AppColors.conhecimentoGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao importar: JSON inválido'),
              backgroundColor: AppColors.neonRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteShop() async {
    if (_currentShop == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.neonRed, size: 20),
            const SizedBox(width: 8),
            Text(
              'CONFIRMAR EXCLUSÃO',
              style: AppTextStyles.uppercase.copyWith(
                color: AppColors.neonRed,
                fontSize: 14,
              ),
            ),
          ],
        ),
        content: Text(
          'Deseja realmente excluir a loja "${_currentShop!.nome}"?\n\nEsta ação não pode ser desfeita.',
          style: TextStyle(color: AppColors.silver),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonRed,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _shopRepo.delete(_currentShop!.id);
        _loadShop();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loja excluída com sucesso'),
              backgroundColor: AppColors.conhecimentoGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir loja: $e'),
              backgroundColor: AppColors.neonRed,
            ),
          );
        }
      }
    }
  }

  Color _getItemTypeColor(ItemType tipo) {
    switch (tipo) {
      case ItemType.arma:
        return AppColors.neonRed;
      case ItemType.cura:
        return AppColors.conhecimentoGreen;
      case ItemType.municao:
        return AppColors.energiaYellow;
      case ItemType.equipamento:
        return AppColors.vigBlue;
      case ItemType.consumivel:
        return AppColors.magenta;
    }
  }

  String _getItemTypeName(ItemType tipo) {
    switch (tipo) {
      case ItemType.arma:
        return 'Arma';
      case ItemType.cura:
        return 'Cura';
      case ItemType.municao:
        return 'Munição';
      case ItemType.equipamento:
        return 'Equipamento';
      case ItemType.consumivel:
        return 'Consumível';
    }
  }

  String _getPatenteLabel(int patente) {
    switch (patente) {
      case 0:
        return 'Recruta';
      case 1:
        return 'Operador';
      case 2:
        return 'Agente Especial';
      case 3:
        return 'Agente de Operações';
      case 4:
        return 'Agente de Elite';
      case 5:
        return 'Agente Paranormal';
      default:
        return 'Recruta';
    }
  }
}

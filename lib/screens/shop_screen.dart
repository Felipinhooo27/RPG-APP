import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/character.dart';
import '../models/shop_item.dart';
import '../services/shop_service.dart';
import '../services/local_database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class ShopScreen extends StatefulWidget {
  final Character character;

  const ShopScreen({
    super.key,
    required this.character,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ShopService _shopService = ShopService();
  final LocalDatabaseService _dbService = LocalDatabaseService();
  final TextEditingController _searchController = TextEditingController();

  Shop? _currentShop;
  bool _isLoading = true;
  String _selectedFilter = 'Todos';
  String _searchQuery = '';
  final List<CartItem> _cart = [];

  @override
  void initState() {
    super.initState();
    _loadShop();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadShop({String? shopId}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final targetShopId = shopId ?? widget.character.activeShopId;

      if (targetShopId != null) {
        final shop = await _shopService.getShop(targetShopId);
        setState(() {
          _currentShop = shop;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Erro ao carregar loja: $e');
    }
  }

  List<ShopItem> get _filteredItems {
    if (_currentShop == null) return [];

    return _currentShop!.items.where((item) {
      // Filtro por categoria
      if (_selectedFilter != 'Todos' && item.tipo != _selectedFilter) {
        return false;
      }

      // Filtro por busca
      if (_searchQuery.isNotEmpty) {
        return item.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.descricao.toLowerCase().contains(_searchQuery.toLowerCase());
      }

      return true;
    }).toList();
  }

  int get _totalCartPrice {
    return _cart.fold(0, (sum, item) => sum + item.precoTotal);
  }

  int get _totalCartSpace {
    return _cart.fold(0, (sum, item) => sum + item.espacoTotal);
  }

  int get _currentInventorySpace {
    return widget.character.inventario.fold(
      0,
      (sum, item) => sum + (item.espaco * item.quantidade),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HexatombeBackground(
      showParticles: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: _isLoading
            ? const Center(child: HexLoading.large(message: 'Carregando loja...'))
            : _currentShop == null
                ? _buildNoShopState()
                : Column(
                    children: [
                      _buildStatsBar(),
                      _buildSearchBar(),
                      _buildFilterChips(),
                      Expanded(
                        child: _filteredItems.isEmpty
                            ? _buildEmptyState()
                            : _buildItemsGrid(),
                      ),
                    ],
                  ),
        floatingActionButton: _cart.isNotEmpty ? _buildCartButton() : null,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.abyssalBlack.withOpacity(0.9),
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentShop?.nome.toUpperCase() ?? 'LOJA',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'BebasNeue',
              letterSpacing: 2,
              color: AppTheme.alertYellow,
            ),
          ),
          Text(
            widget.character.nome,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.coldGray,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.upload, color: AppTheme.alertYellow),
          onPressed: _importShop,
          tooltip: 'Importar Loja',
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    const maxInventorySpace = 100;
    final availableSpace = maxInventorySpace - _currentInventorySpace;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: RitualCard(
        glowEffect: false,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildStatItem(
              icon: Icons.attach_money,
              label: 'CRÉDITOS',
              value: '${widget.character.creditos}',
              color: AppTheme.alertYellow,
            ),
            Container(
              width: 1,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: AppTheme.industrialGray,
            ),
            _buildStatItem(
              icon: Icons.military_tech,
              label: 'PATENTE',
              value: widget.character.patente.split(' ').first,
              color: AppTheme.etherealPurple,
            ),
            Container(
              width: 1,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: AppTheme.industrialGray,
            ),
            _buildStatItem(
              icon: Icons.inventory_2,
              label: 'ESPAÇO',
              value: '$availableSpace',
              color: AppTheme.mutagenGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'SpaceMono',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: AppTheme.coldGray,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: const TextStyle(
          color: AppTheme.paleWhite,
          fontFamily: 'Montserrat',
        ),
        decoration: InputDecoration(
          hintText: 'Buscar itens...',
          hintStyle: const TextStyle(color: AppTheme.coldGray),
          prefixIcon: const Icon(Icons.search, color: AppTheme.alertYellow),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.coldGray),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: AppTheme.obscureGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppTheme.alertYellow, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppTheme.industrialGray, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppTheme.alertYellow, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Todos', 'Arma', 'Cura', 'Munição', 'Material', 'Equipamento'];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          Color chipColor = AppTheme.alertYellow;
          IconData chipIcon = Icons.apps;

          if (filter == 'Arma') {
            chipColor = AppTheme.ritualRed;
            chipIcon = Icons.gavel;
          } else if (filter == 'Cura') {
            chipColor = AppTheme.mutagenGreen;
            chipIcon = Icons.healing;
          } else if (filter == 'Munição') {
            chipColor = AppTheme.alertYellow;
            chipIcon = Icons.settings_input_component;
          } else if (filter == 'Material') {
            chipColor = AppTheme.etherealPurple;
            chipIcon = Icons.build;
          } else if (filter == 'Equipamento') {
            chipColor = AppTheme.coldGray;
            chipIcon = Icons.backpack;
          }

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? chipColor.withOpacity(0.15)
                    : AppTheme.obscureGray,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? chipColor : AppTheme.industrialGray,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: chipColor.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    chipIcon,
                    color: isSelected ? chipColor : AppTheme.coldGray,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    filter.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? chipColor : AppTheme.coldGray,
                      fontFamily: 'BebasNeue',
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoShopState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 64,
            color: AppTheme.silver.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma loja ativa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.silver,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aguarde o mestre configurar uma loja para realizar compras',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.coldGray,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 24),
          GlowingButton(
            label: 'Importar Loja',
            icon: Icons.upload,
            onPressed: _importShop,
            style: GlowingButtonStyle.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.silver.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum item encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.silver,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tente ajustar os filtros de busca ou categoria',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.coldGray,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return _buildItemCard(item, index);
      },
    );
  }

  Widget _buildItemCard(ShopItem item, int index) {
    final patenteValue = _getPatenteValue(widget.character.patente);
    final canAfford = widget.character.creditos >= item.preco;
    final hasPatente = patenteValue >= item.patenteMinima;
    final canBuy = canAfford && hasPatente;

    Color itemColor = _getItemColor(item.tipo);
    IconData itemIcon = _getItemIcon(item.tipo);

    return GestureDetector(
      onTap: () => _showItemDetails(item),
      child: RitualCard(
        glowEffect: canBuy && !item.isAmaldicoado,
        glowColor: item.isAmaldicoado ? AppTheme.ritualRed : itemColor,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabeçalho
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: itemColor.withOpacity(0.2),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    border: Border(
                      bottom: BorderSide(color: itemColor, width: 2),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(itemIcon, color: itemColor, size: 48),
                      ),
                      if (item.isAmaldicoado)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.ritualRed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.warning,
                              color: AppTheme.paleWhite,
                              size: 16,
                            ),
                          ),
                        ),
                      if (!canBuy)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.lock,
                                color: AppTheme.ritualRed,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nome.toUpperCase(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: canBuy
                                ? AppTheme.paleWhite
                                : AppTheme.coldGray,
                            fontFamily: 'Montserrat',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            _buildSmallBadge(
                              '${item.preco}¢',
                              canAfford
                                  ? AppTheme.alertYellow
                                  : AppTheme.ritualRed,
                            ),
                            _buildSmallBadge(
                              'P${item.patenteMinima}',
                              hasPatente
                                  ? AppTheme.etherealPurple
                                  : AppTheme.ritualRed,
                            ),
                            _buildSmallBadge(
                              '${item.espaco}E',
                              AppTheme.mutagenGreen,
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (item.descricao.isNotEmpty)
                          Text(
                            item.descricao,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.coldGray,
                              fontFamily: 'Montserrat',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Botão adicionar ao carrinho
            if (canBuy)
              Positioned(
                bottom: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  color: AppTheme.mutagenGreen,
                  onPressed: () => _addToCart(item, 1),
                ),
              ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 50).ms, duration: 300.ms).scale(
            begin: const Offset(0.9, 0.9),
          ),
    );
  }

  Widget _buildSmallBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }

  Widget _buildCartButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.obscureGray,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.alertYellow.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'CARRINHO',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.alertYellow,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_cart.length} itens',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.coldGray,
                  fontFamily: 'Montserrat',
                ),
              ),
              Text(
                '$_totalCartPrice¢',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.alertYellow,
                  fontFamily: 'BebasNeue',
                ),
              ),
            ],
          ),
        ),
        GlowingButton(
          label: 'Finalizar',
          icon: Icons.shopping_cart_checkout,
          onPressed: _showCheckout,
          style: GlowingButtonStyle.primary,
          pulsateGlow: true,
        ),
      ],
    );
  }

  void _showItemDetails(ShopItem item) {
    showDialog(
      context: context,
      builder: (context) => _ItemDetailsDialog(
        item: item,
        character: widget.character,
        onAddToCart: (quantity) {
          Navigator.pop(context);
          _addToCart(item, quantity);
        },
      ),
    );
  }

  void _addToCart(ShopItem item, int quantity) {
    setState(() {
      final existingIndex = _cart.indexWhere((ci) => ci.item.id == item.id);

      if (existingIndex != -1) {
        // Incrementar quantidade
        final existing = _cart[existingIndex];
        _cart[existingIndex] = CartItem(
          item: existing.item,
          quantidade: existing.quantidade + quantity,
        );
      } else {
        // Adicionar novo
        _cart.add(CartItem(item: item, quantidade: quantity));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.nome} (x$quantity) adicionado ao carrinho'),
        backgroundColor: AppTheme.mutagenGreen,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showCheckout() {
    showDialog(
      context: context,
      builder: (context) => _CheckoutDialog(
        cart: _cart,
        character: widget.character,
        shop: _currentShop!,
        onPurchaseComplete: _handlePurchaseComplete,
        onEditCart: () {
          Navigator.pop(context);
          _showCartEditor();
        },
      ),
    );
  }

  void _showCartEditor() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RitualCard(
          glowEffect: true,
          glowColor: AppTheme.alertYellow,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'EDITAR CARRINHO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.alertYellow,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              ..._cart.map((cartItem) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.obscureGray.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cartItem.item.nome,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.paleWhite,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            Text(
                              '${cartItem.precoTotal}¢',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.alertYellow,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            color: AppTheme.ritualRed,
                            onPressed: () {
                              setState(() {
                                if (cartItem.quantidade > 1) {
                                  final index = _cart.indexOf(cartItem);
                                  _cart[index] = CartItem(
                                    item: cartItem.item,
                                    quantidade: cartItem.quantidade - 1,
                                  );
                                } else {
                                  _cart.remove(cartItem);
                                }
                              });
                              Navigator.pop(context);
                              if (_cart.isNotEmpty) {
                                _showCartEditor();
                              }
                            },
                          ),
                          Text(
                            '${cartItem.quantidade}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.paleWhite,
                              fontFamily: 'BebasNeue',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            color: AppTheme.mutagenGreen,
                            onPressed: () {
                              setState(() {
                                final index = _cart.indexOf(cartItem);
                                _cart[index] = CartItem(
                                  item: cartItem.item,
                                  quantidade: cartItem.quantidade + 1,
                                );
                              });
                              Navigator.pop(context);
                              _showCartEditor();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              GlowingButton(
                label: 'Fechar',
                onPressed: () => Navigator.pop(context),
                style: GlowingButtonStyle.secondary,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 200.ms).scale(
              begin: const Offset(0.9, 0.9),
            ),
      ),
    );
  }

  Future<void> _handlePurchaseComplete(PurchaseResult result) async {
    if (result.success) {
      // Atualizar personagem
      final updatedCharacter = widget.character.copyWith(
        creditos: result.newCredits!,
        inventario: result.newInventory!,
        purchaseHistory: result.newPurchaseHistory!,
      );

      await _dbService.updateCharacter(updatedCharacter);

      setState(() {
        _cart.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppTheme.mutagenGreen,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppTheme.ritualRed,
          ),
        );
      }
    }
  }

  int _getPatenteValue(String patente) {
    final numbers = RegExp(r'\d+').allMatches(patente);
    if (numbers.isEmpty) return 0;
    return int.parse(numbers.first.group(0) ?? '0');
  }

  Color _getItemColor(String tipo) {
    switch (tipo) {
      case 'Arma':
        return AppTheme.ritualRed;
      case 'Cura':
        return AppTheme.mutagenGreen;
      case 'Munição':
        return AppTheme.alertYellow;
      case 'Material':
        return AppTheme.etherealPurple;
      default:
        return AppTheme.coldGray;
    }
  }

  IconData _getItemIcon(String tipo) {
    switch (tipo) {
      case 'Arma':
        return Icons.gavel;
      case 'Cura':
        return Icons.healing;
      case 'Munição':
        return Icons.settings_input_component;
      case 'Material':
        return Icons.build;
      default:
        return Icons.shopping_bag;
    }
  }

  Future<void> _importShop() async {
    final controller = TextEditingController();

    // Try to get clipboard data
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null) {
        controller.text = data!.text!;
      }
    } catch (e) {
      // Clipboard access failed, user can still paste manually
    }

    if (!mounted) return;

    final jsonString = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RitualCard(
          glowEffect: true,
          glowColor: AppTheme.alertYellow,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.store, color: AppTheme.alertYellow, size: 40),
              const SizedBox(height: 12),
              const Text(
                'IMPORTAR LOJA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.alertYellow,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Cole o JSON da loja:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.paleWhite,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 8,
                style: const TextStyle(
                  color: AppTheme.paleWhite,
                  fontFamily: 'SpaceMono',
                  fontSize: 11,
                ),
                decoration: InputDecoration(
                  hintText: 'Cole o JSON aqui...',
                  hintStyle: const TextStyle(color: AppTheme.coldGray),
                  filled: true,
                  fillColor: AppTheme.obscureGray,
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.alertYellow, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.coldGray, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.alertYellow, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GlowingButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.pop(context),
                      style: GlowingButtonStyle.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GlowingButton(
                      label: 'Importar',
                      icon: Icons.upload,
                      onPressed: () => Navigator.pop(context, controller.text.trim()),
                      style: GlowingButtonStyle.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (jsonString == null || jsonString.isEmpty) return;

    try {
      final shop = await _shopService.importShop(jsonString, 'player_001');

      // Update character's activeShopId
      final updatedCharacter = widget.character.copyWith(
        activeShopId: shop.id,
      );
      await _dbService.updateCharacter(updatedCharacter);

      // Load shop directly using the new shop ID
      await _loadShop(shopId: shop.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loja "${shop.nome}" importada com sucesso!'),
            backgroundColor: AppTheme.mutagenGreen,
          ),
        );
      }
    } catch (e) {
      _showError('Erro ao importar: JSON inválido');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.ritualRed,
        ),
      );
    }
  }
}

// Item Details Dialog
class _ItemDetailsDialog extends StatefulWidget {
  final ShopItem item;
  final Character character;
  final Function(int quantity) onAddToCart;

  const _ItemDetailsDialog({
    required this.item,
    required this.character,
    required this.onAddToCart,
  });

  @override
  State<_ItemDetailsDialog> createState() => _ItemDetailsDialogState();
}

class _ItemDetailsDialogState extends State<_ItemDetailsDialog> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final patenteValue = _getPatenteValue(widget.character.patente);
    final totalPrice = widget.item.preco * _quantity;
    final canAfford = widget.character.creditos >= totalPrice;
    final hasPatente = patenteValue >= widget.item.patenteMinima;

    Color itemColor = _getItemColor(widget.item.tipo);
    IconData itemIcon = _getItemIcon(widget.item.tipo);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: RitualCard(
        glowEffect: true,
        glowColor: widget.item.isAmaldicoado ? AppTheme.ritualRed : itemColor,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: itemColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: itemColor.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(itemIcon, color: itemColor, size: 35),
              ),
              const SizedBox(height: 12),
              Text(
                widget.item.nome.toUpperCase(),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.paleWhite,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildBadge(widget.item.tipo, itemColor),
                  _buildBadge('${widget.item.preco}¢/un', AppTheme.alertYellow),
                  _buildBadge('Patente ${widget.item.patenteMinima}', AppTheme.etherealPurple),
                  _buildBadge('${widget.item.espaco} Espaço', AppTheme.mutagenGreen),
                  if (widget.item.isAmaldicoado)
                    _buildBadge('AMALDIÇOADO', AppTheme.ritualRed),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.obscureGray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.item.descricao,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.coldGray,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              // Quantity selector
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.obscureGray,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: itemColor.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Quantidade:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.paleWhite,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppTheme.ritualRed,
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: itemColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: itemColor.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        '$_quantity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: itemColor,
                          fontFamily: 'SpaceMono',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppTheme.mutagenGreen,
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Total price
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.alertYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.alertYellow.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Total: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.paleWhite,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Text(
                      '$totalPrice¢',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.alertYellow,
                        fontFamily: 'SpaceMono',
                      ),
                    ),
                    Text(
                      ' (${widget.item.espaco * _quantity} espaço)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.coldGray,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              if (!canAfford) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.alertYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.alertYellow.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.alertYellow, size: 18),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Créditos insuficientes (será validado no checkout)',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.alertYellow,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (!hasPatente) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.alertYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.alertYellow.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.alertYellow, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Patente ${widget.item.patenteMinima} necessária (será validado no checkout)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.alertYellow,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GlowingButton(
                      label: 'Fechar',
                      onPressed: () => Navigator.pop(context),
                      style: GlowingButtonStyle.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GlowingButton(
                      label: 'Adicionar',
                      icon: Icons.add_shopping_cart,
                      onPressed: () => widget.onAddToCart(_quantity),
                      style: GlowingButtonStyle.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }

  int _getPatenteValue(String patente) {
    final numbers = RegExp(r'\d+').allMatches(patente);
    if (numbers.isEmpty) return 0;
    return int.parse(numbers.first.group(0) ?? '0');
  }

  Color _getItemColor(String tipo) {
    switch (tipo) {
      case 'Arma':
        return AppTheme.ritualRed;
      case 'Cura':
        return AppTheme.mutagenGreen;
      case 'Munição':
        return AppTheme.alertYellow;
      case 'Material':
        return AppTheme.etherealPurple;
      default:
        return AppTheme.coldGray;
    }
  }

  IconData _getItemIcon(String tipo) {
    switch (tipo) {
      case 'Arma':
        return Icons.gavel;
      case 'Cura':
        return Icons.healing;
      case 'Munição':
        return Icons.settings_input_component;
      case 'Material':
        return Icons.build;
      default:
        return Icons.shopping_bag;
    }
  }
}

// Checkout Dialog
class _CheckoutDialog extends StatelessWidget {
  final List<CartItem> cart;
  final Character character;
  final Shop shop;
  final Function(PurchaseResult) onPurchaseComplete;
  final VoidCallback onEditCart;

  const _CheckoutDialog({
    required this.cart,
    required this.character,
    required this.shop,
    required this.onPurchaseComplete,
    required this.onEditCart,
  });

  @override
  Widget build(BuildContext context) {
    final totalPrice = cart.fold<int>(0, (sum, item) => sum + item.precoTotal);
    final totalSpace = cart.fold<int>(0, (sum, item) => sum + item.espacoTotal);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: RitualCard(
        glowEffect: true,
        glowColor: AppTheme.alertYellow,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shopping_cart_checkout,
                color: AppTheme.alertYellow,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'FINALIZAR COMPRA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.alertYellow,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.obscureGray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Itens', '${cart.length}', AppTheme.coldGray),
                    const Divider(color: AppTheme.obscureGray),
                    _buildSummaryRow('Total', '$totalPrice¢', AppTheme.alertYellow),
                    _buildSummaryRow('Espaço', '$totalSpace', AppTheme.mutagenGreen),
                    const Divider(color: AppTheme.obscureGray),
                    _buildSummaryRow(
                      'Créditos Atuais',
                      '${character.creditos}¢',
                      AppTheme.paleWhite,
                    ),
                    _buildSummaryRow(
                      'Após Compra',
                      '${character.creditos - totalPrice}¢',
                      character.creditos >= totalPrice
                          ? AppTheme.mutagenGreen
                          : AppTheme.ritualRed,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlowingButton(
                      label: 'Editar',
                      icon: Icons.edit,
                      onPressed: onEditCart,
                      style: GlowingButtonStyle.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlowingButton(
                      label: 'Confirmar',
                      icon: Icons.check,
                      onPressed: () => _processPurchase(context),
                      style: GlowingButtonStyle.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.coldGray,
              fontFamily: 'Montserrat',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'BebasNeue',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPurchase(BuildContext context) async {
    final shopService = ShopService();

    try {
      final result = await shopService.processPurchase(
        character: character,
        cartItems: cart,
        shop: shop,
      );

      Navigator.pop(context);
      await onPurchaseComplete(result);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao processar compra: $e'),
          backgroundColor: AppTheme.ritualRed,
        ),
      );
    }
  }
}

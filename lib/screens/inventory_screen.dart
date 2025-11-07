import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../models/character.dart';
import '../models/item.dart';
import '../services/local_database_service.dart';
import '../theme/app_theme.dart';
import '../utils/dice_roller.dart';
import '../widgets/widgets.dart';

class InventoryScreen extends StatefulWidget {
  final Character character;
  final bool isMasterMode;

  const InventoryScreen({
    super.key,
    required this.character,
    required this.isMasterMode,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final LocalDatabaseService _databaseService = LocalDatabaseService();
  final DiceRoller _diceRoller = DiceRoller();
  final _uuid = const Uuid();
  final TextEditingController _searchController = TextEditingController();

  late List<Item> _items;
  String _selectedFilter = 'Todos';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.character.inventario);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Item> get _filteredItems {
    return _items.where((item) {
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

  int get _totalEspaco {
    return _items.fold(0, (sum, item) => sum + (item.espaco * item.quantidade));
  }

  @override
  Widget build(BuildContext context) {
    return HexatombeBackground(
      showParticles: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: Column(
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
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlowingButton(
              label: 'Import',
              icon: Icons.upload_file,
              onPressed: _importInventory,
              style: GlowingButtonStyle.secondary,
              width: 100,
              height: 44,
            ),
            const SizedBox(width: 6),
            GlowingButton(
              label: 'Export',
              icon: Icons.download,
              onPressed: _exportInventory,
              style: GlowingButtonStyle.occult,
              width: 100,
              height: 44,
            ),
            const SizedBox(width: 6),
            GlowingButton(
              label: 'Add',
              icon: Icons.add,
              onPressed: _addItem,
              style: GlowingButtonStyle.primary,
              width: 80,
              height: 44,
              pulsateGlow: true,
            ),
          ],
        ),
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
          const Text(
            'INVENTÁRIO',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'BebasNeue',
              letterSpacing: 2,
              color: AppTheme.mutagenGreen,
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
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.obscureGray.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(color: AppTheme.mutagenGreen.withOpacity(0.3), width: 2),
        ),
      ),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.inventory_2,
            label: 'ITENS',
            value: '${_items.length}',
            color: AppTheme.mutagenGreen,
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            icon: Icons.storage,
            label: 'ESPAÇO',
            value: '$_totalEspaco',
            color: AppTheme.etherealPurple,
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            icon: Icons.attach_money,
            label: 'CRÉDITOS',
            value: '${widget.character.creditos}',
            color: AppTheme.alertYellow,
          ),
        ],
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
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: color,
                    fontFamily: 'BebasNeue',
                    letterSpacing: 1,
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
          ],
        ),
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
        style: const TextStyle(color: AppTheme.paleWhite, fontFamily: 'Montserrat'),
        decoration: InputDecoration(
          hintText: 'Buscar itens...',
          hintStyle: const TextStyle(color: AppTheme.coldGray),
          prefixIcon: const Icon(Icons.search, color: AppTheme.mutagenGreen),
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
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.mutagenGreen, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.coldGray, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.mutagenGreen, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Todos', 'Arma', 'Cura', 'Munição', 'Equipamento', 'Consumível'];

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

          Color chipColor = AppTheme.mutagenGreen;
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
          } else if (filter == 'Equipamento') {
            chipColor = AppTheme.etherealPurple;
            chipIcon = Icons.build;
          } else if (filter == 'Consumível') {
            chipColor = AppTheme.etherealPurple;
            chipIcon = Icons.local_drink;
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
                    ? chipColor.withOpacity(0.2)
                    : AppTheme.obscureGray,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? chipColor.withOpacity(0.4) : AppTheme.coldGray.withOpacity(0.3),
                    blurRadius: isSelected ? 6 : 4,
                    spreadRadius: 0,
                  ),
                ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.obscureGray,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.mutagenGreen.withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.backpack_outlined,
              size: 60,
              color: AppTheme.mutagenGreen,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'Todos'
                ? 'NENHUM ITEM ENCONTRADO'
                : 'INVENTÁRIO VAZIO',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.coldGray,
              fontFamily: 'BebasNeue',
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'Todos'
                ? 'Tente ajustar os filtros'
                : 'Adicione itens ao inventário',
            style: const TextStyle(
              fontSize: 13,
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
        childAspectRatio: 0.75,
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

  Widget _buildItemCard(Item item, int index) {
    IconData itemIcon = Icons.shopping_bag;
    Color itemColor = AppTheme.mutagenGreen;

    if (item.tipo == 'Arma') {
      itemIcon = Icons.gavel;
      itemColor = item.isAmaldicoado ? AppTheme.ritualRed : AppTheme.ritualRed;
    } else if (item.tipo == 'Cura') {
      itemIcon = Icons.healing;
      itemColor = AppTheme.mutagenGreen;
    } else if (item.tipo == 'Munição') {
      itemIcon = Icons.settings_input_component;
      itemColor = AppTheme.alertYellow;
    } else if (item.tipo == 'Consumível') {
      itemIcon = Icons.local_drink;
      itemColor = AppTheme.etherealPurple;
    } else if (item.tipo == 'Equipamento') {
      itemIcon = Icons.build;
      itemColor = AppTheme.etherealPurple;
    }

    return GestureDetector(
      onTap: () => _showItemDetails(item),
      child: RitualCard(
        glowEffect: item.isWeapon || item.isHeal || item.isAmaldicoado,
        glowColor: item.isAmaldicoado ? AppTheme.ritualRed : itemColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho com ícone
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: itemColor.withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                border: Border(
                  bottom: BorderSide(color: itemColor, width: 2),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      itemIcon,
                      color: itemColor,
                      size: 48,
                    ),
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
                ],
              ),
            ),

            // Informações
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.paleWhite,
                        fontFamily: 'Montserrat',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildSmallBadge('${item.quantidade}x', AppTheme.coldGray),
                        const SizedBox(width: 4),
                        _buildSmallBadge('${item.espaco}E', AppTheme.etherealPurple),
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
      ).animate().fadeIn(delay: (index * 50).ms, duration: 300.ms).scale(begin: const Offset(0.9, 0.9)),
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

  void _showItemDetails(Item item) {
    showDialog(
      context: context,
      builder: (context) => _ItemDetailsDialog(
        item: item,
        onEdit: () {
          Navigator.pop(context);
          _editItem(item);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteItem(item.id);
        },
        onRollDamage: (isCritical) {
          Navigator.pop(context);
          _rollDamage(item, isCritical);
        },
        onRollHeal: () {
          Navigator.pop(context);
          _rollHeal(item);
        },
      ),
    );
  }

  void _rollDamage(Item item, bool isCritical) {
    if (item.formulaDano == null) return;

    try {
      final result = isCritical && item.multiplicadorCritico != null
          ? _diceRoller.rollCritical(item.formulaDano!, item.multiplicadorCritico!)
          : _diceRoller.roll(item.formulaDano!);

      _showRollResult(
        title: isCritical ? 'ACERTO CRÍTICO!' : 'DANO ROLADO',
        subtitle: item.nome.toUpperCase(),
        result: result.total.toString(),
        details: result.detailedResult,
        color: isCritical ? AppTheme.alertYellow : AppTheme.ritualRed,
        icon: isCritical ? Icons.star : Icons.casino,
        extraInfo: isCritical && item.efeitoCritico != null
            ? item.efeitoCritico!
            : null,
      );
    } catch (e) {
      _showError('Erro ao rolar dados: $e');
    }
  }

  void _rollHeal(Item item) {
    if (item.formulaCura == null) return;

    try {
      final result = _diceRoller.roll(item.formulaCura!);

      _showRollResult(
        title: 'CURA ROLADA',
        subtitle: item.nome.toUpperCase(),
        result: result.total.toString(),
        details: result.detailedResult,
        color: AppTheme.mutagenGreen,
        icon: Icons.healing,
        extraInfo: item.efeitoEspecial,
      );
    } catch (e) {
      _showError('Erro ao rolar cura: $e');
    }
  }

  void _showRollResult({
    required String title,
    required String subtitle,
    required String result,
    required String details,
    required Color color,
    required IconData icon,
    String? extraInfo,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RitualCard(
          glowEffect: true,
          glowColor: color,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.paleWhite,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.obscureGray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  details,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.coldGray,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                        fontFamily: 'BebasNeue',
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      result,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: color,
                        fontFamily: 'BebasNeue',
                      ),
                    ),
                  ],
                ),
              ),
              if (extraInfo != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: color, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          extraInfo,
                          style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              GlowingButton(
                label: 'Fechar',
                onPressed: () => Navigator.pop(context),
                style: GlowingButtonStyle.secondary,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9)),
      ),
    );
  }

  Future<void> _addItem() async {
    final newItem = await showDialog<Item>(
      context: context,
      builder: (context) => const _ItemFormDialog(item: null),
    );

    if (newItem != null) {
      setState(() {
        _items.add(newItem.copyWith(id: _uuid.v4()));
      });
      await _saveInventory();
    }
  }

  Future<void> _editItem(Item item) async {
    final updatedItem = await showDialog<Item>(
      context: context,
      builder: (context) => _ItemFormDialog(item: item),
    );

    if (updatedItem != null) {
      setState(() {
        final index = _items.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          _items[index] = updatedItem;
        }
      });
      await _saveInventory();
    }
  }

  Future<void> _deleteItem(String itemId) async {
    final item = _items.firstWhere((i) => i.id == itemId);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RitualCard(
          glowEffect: true,
          glowColor: AppTheme.ritualRed,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, color: AppTheme.ritualRed, size: 40),
              const SizedBox(height: 12),
              const Text(
                'EXCLUIR ITEM',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ritualRed,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Deseja excluir "${item.nome}"?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.paleWhite,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GlowingButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.pop(context, false),
                      style: GlowingButtonStyle.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GlowingButton(
                      label: 'Excluir',
                      icon: Icons.delete,
                      onPressed: () => Navigator.pop(context, true),
                      style: GlowingButtonStyle.danger,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9)),
      ),
    );

    if (confirm == true) {
      setState(() {
        _items.removeWhere((item) => item.id == itemId);
      });
      await _saveInventory();
    }
  }

  Future<void> _saveInventory() async {
    try {
      final updatedCharacter = widget.character.copyWith(inventario: _items);
      await _databaseService.updateCharacter(updatedCharacter);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inventário atualizado!'),
            backgroundColor: AppTheme.mutagenGreen,
          ),
        );
      }
    } catch (e) {
      _showError('Erro ao salvar: $e');
    }
  }

  Future<void> _exportInventory() async {
    try {
      final inventoryData = {
        'version': '1.0',
        'character': widget.character.nome,
        'items': _items.map((item) => item.toMap()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(inventoryData);

      await Clipboard.setData(ClipboardData(text: jsonString));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inventário copiado para área de transferência!'),
            backgroundColor: AppTheme.mutagenGreen,
          ),
        );
      }
    } catch (e) {
      _showError('Erro ao exportar: $e');
    }
  }

  Future<void> _importInventory() async {
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
          glowColor: AppTheme.etherealPurple,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.upload_file, color: AppTheme.etherealPurple, size: 40),
              const SizedBox(height: 12),
              const Text(
                'IMPORTAR INVENTÁRIO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.etherealPurple,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Cole o JSON do inventário:',
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
                    borderSide: const BorderSide(color: AppTheme.etherealPurple, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.coldGray, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.etherealPurple, width: 2),
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
      final data = json.decode(jsonString);

      final List<Item> importedItems = [];
      for (var itemMap in data['items']) {
        importedItems.add(Item.fromMap(itemMap));
      }

      if (!mounted) return;

      final shouldReplace = await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: RitualCard(
            glowEffect: true,
            glowColor: AppTheme.mutagenGreen,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: AppTheme.mutagenGreen, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'CONFIRMAR IMPORTAÇÃO',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.mutagenGreen,
                    fontFamily: 'BebasNeue',
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Encontrados ${importedItems.length} itens. Substituir ou adicionar?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.paleWhite,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GlowingButton(
                        label: 'Adicionar',
                        onPressed: () => Navigator.pop(context, false),
                        style: GlowingButtonStyle.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GlowingButton(
                        label: 'Substituir',
                        icon: Icons.swap_horiz,
                        onPressed: () => Navigator.pop(context, true),
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

      if (shouldReplace != null) {
        setState(() {
          if (shouldReplace) {
            _items = importedItems;
          } else {
            _items.addAll(importedItems);
          }
        });
        await _saveInventory();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${importedItems.length} itens importados com sucesso!'),
              backgroundColor: AppTheme.mutagenGreen,
            ),
          );
        }
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
class _ItemDetailsDialog extends StatelessWidget {
  final Item item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(bool isCritical) onRollDamage;
  final VoidCallback onRollHeal;

  const _ItemDetailsDialog({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onRollDamage,
    required this.onRollHeal,
  });

  @override
  Widget build(BuildContext context) {
    IconData itemIcon = Icons.shopping_bag;
    Color itemColor = AppTheme.mutagenGreen;

    if (item.tipo == 'Arma') {
      itemIcon = Icons.gavel;
      itemColor = item.isAmaldicoado ? AppTheme.ritualRed : AppTheme.ritualRed;
    } else if (item.tipo == 'Cura') {
      itemIcon = Icons.healing;
      itemColor = AppTheme.mutagenGreen;
    } else if (item.tipo == 'Munição') {
      itemIcon = Icons.settings_input_component;
      itemColor = AppTheme.alertYellow;
    } else if (item.tipo == 'Consumível') {
      itemIcon = Icons.local_drink;
      itemColor = AppTheme.etherealPurple;
    } else if (item.tipo == 'Equipamento') {
      itemIcon = Icons.build;
      itemColor = AppTheme.etherealPurple;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: RitualCard(
        glowEffect: true,
        glowColor: itemColor,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone e nome
              Container(
                width: 80,
                height: 80,
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
                child: Icon(itemIcon, color: itemColor, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                item.nome.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.paleWhite,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBadge(item.tipo, itemColor),
                  const SizedBox(width: 8),
                  _buildBadge('${item.quantidade}x', AppTheme.coldGray),
                  const SizedBox(width: 8),
                  _buildBadge('${item.espaco}E', AppTheme.etherealPurple),
                  if (item.isAmaldicoado) ...[
                    const SizedBox(width: 8),
                    _buildBadge('AMALDIÇOADO', AppTheme.ritualRed),
                  ],
                ],
              ),

              // Descrição
              if (item.descricao.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.obscureGray.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.descricao,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.coldGray,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              // Informações de arma
              if (item.isWeapon) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.ritualRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.ritualRed.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.casino, color: AppTheme.ritualRed, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Dano: ${item.formulaDano}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.ritualRed,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          if (item.multiplicadorCritico != null) ...[
                            const SizedBox(width: 12),
                            const Icon(Icons.star, color: AppTheme.alertYellow, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'x${item.multiplicadorCritico}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.alertYellow,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (item.efeitoCritico != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.efeitoCritico!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.alertYellow,
                            fontFamily: 'Montserrat',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GlowingButton(
                        label: 'Rolar Dano',
                        icon: Icons.casino,
                        onPressed: () => onRollDamage(false),
                        style: GlowingButtonStyle.danger,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlowingButton(
                        label: 'Crítico',
                        icon: Icons.star,
                        onPressed: () => onRollDamage(true),
                        style: GlowingButtonStyle.occult,
                      ),
                    ),
                  ],
                ),
              ],

              // Informações de cura
              if (item.isHeal) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.mutagenGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.mutagenGreen.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.healing, color: AppTheme.mutagenGreen, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Cura: ${item.formulaCura}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.mutagenGreen,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                      if (item.efeitoEspecial != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.efeitoEspecial!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.mutagenGreen,
                            fontFamily: 'Montserrat',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GlowingButton(
                  label: 'Rolar Cura',
                  icon: Icons.healing,
                  onPressed: onRollHeal,
                  style: GlowingButtonStyle.primary,
                ),
              ],

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GlowingButton(
                      label: 'Editar',
                      icon: Icons.edit,
                      onPressed: onEdit,
                      style: GlowingButtonStyle.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GlowingButton(
                      label: 'Excluir',
                      icon: Icons.delete,
                      onPressed: onDelete,
                      style: GlowingButtonStyle.danger,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GlowingButton(
                label: 'Fechar',
                onPressed: () => Navigator.pop(context),
                style: GlowingButtonStyle.secondary,
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
}

// Item Form Dialog - Continua no próximo arquivo devido ao tamanho
class _ItemFormDialog extends StatefulWidget {
  final Item? item;

  const _ItemFormDialog({this.item});

  @override
  State<_ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<_ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _quantidadeController;
  late TextEditingController _espacoController;
  late TextEditingController _formulaDanoController;
  late TextEditingController _formulaCuraController;
  late TextEditingController _multiplicadorCriticoController;
  late TextEditingController _efeitoCriticoController;
  late TextEditingController _efeitoEspecialController;

  String _selectedTipo = 'Equipamento';
  bool _isAmaldicoado = false;
  final List<String> _tipos = ['Arma', 'Cura', 'Munição', 'Equipamento', 'Consumível'];

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    _nomeController = TextEditingController(text: item?.nome ?? '');
    _descricaoController = TextEditingController(text: item?.descricao ?? '');
    _quantidadeController = TextEditingController(text: item?.quantidade.toString() ?? '1');
    _espacoController = TextEditingController(text: item?.espaco.toString() ?? '1');
    _formulaDanoController = TextEditingController(text: item?.formulaDano ?? '');
    _formulaCuraController = TextEditingController(text: item?.formulaCura ?? '');
    _multiplicadorCriticoController =
        TextEditingController(text: item?.multiplicadorCritico?.toString() ?? '');
    _efeitoCriticoController = TextEditingController(text: item?.efeitoCritico ?? '');
    _efeitoEspecialController = TextEditingController(text: item?.efeitoEspecial ?? '');

    if (item != null) {
      _selectedTipo = item.tipo;
      _isAmaldicoado = item.isAmaldicoado;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _quantidadeController.dispose();
    _espacoController.dispose();
    _formulaDanoController.dispose();
    _formulaCuraController.dispose();
    _multiplicadorCriticoController.dispose();
    _efeitoCriticoController.dispose();
    _efeitoEspecialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: RitualCard(
        glowEffect: true,
        glowColor: AppTheme.mutagenGreen,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item == null ? 'ADICIONAR ITEM' : 'EDITAR ITEM',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.mutagenGreen,
                    fontFamily: 'BebasNeue',
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nomeController,
                  label: 'Nome',
                  validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descricaoController,
                  label: 'Descrição',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedTipo,
                  decoration: InputDecoration(
                    labelText: 'Tipo',
                    labelStyle: const TextStyle(color: AppTheme.coldGray),
                    filled: true,
                    fillColor: AppTheme.obscureGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.mutagenGreen, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.coldGray, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.mutagenGreen, width: 2),
                    ),
                  ),
                  dropdownColor: AppTheme.obscureGray,
                  style: const TextStyle(
                    color: AppTheme.paleWhite,
                    fontFamily: 'Montserrat',
                  ),
                  items: _tipos
                      .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTipo = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _quantidadeController,
                        label: 'Quantidade',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty == true || int.tryParse(value!) == null) {
                            return 'Inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _espacoController,
                        label: 'Espaço',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty == true || int.tryParse(value!) == null) {
                            return 'Inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                // Campos específicos por tipo
                if (_selectedTipo == 'Arma') ...[
                  const SizedBox(height: 24),
                  const Text(
                    'PROPRIEDADES DE ARMA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ritualRed,
                      fontFamily: 'BebasNeue',
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text(
                      'Arma Amaldiçoada',
                      style: TextStyle(color: AppTheme.ritualRed, fontFamily: 'Montserrat'),
                    ),
                    value: _isAmaldicoado,
                    onChanged: (value) {
                      setState(() {
                        _isAmaldicoado = value ?? false;
                      });
                    },
                    checkColor: AppTheme.abyssalBlack,
                    activeColor: AppTheme.ritualRed,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _formulaDanoController,
                    label: 'Fórmula de Dano',
                    hint: 'ex: 1d8+2',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _multiplicadorCriticoController,
                    label: 'Multiplicador Crítico',
                    hint: 'ex: 2 para x2',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _efeitoCriticoController,
                    label: 'Efeito Crítico',
                    hint: 'Descrição do efeito',
                    maxLines: 2,
                  ),
                  if (_isAmaldicoado) ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _efeitoEspecialController,
                      label: 'Efeito da Maldição',
                      hint: 'ex: Perde sanidade ao errar',
                      maxLines: 2,
                    ),
                  ],
                ],

                if (_selectedTipo == 'Cura') ...[
                  const SizedBox(height: 24),
                  const Text(
                    'PROPRIEDADES DE CURA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.mutagenGreen,
                      fontFamily: 'BebasNeue',
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _formulaCuraController,
                    label: 'Fórmula de Cura',
                    hint: 'ex: 2d4+2',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _efeitoEspecialController,
                    label: 'Efeito Adicional',
                    hint: 'Descrição de efeitos extras',
                    maxLines: 2,
                  ),
                ],

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
                        label: 'Salvar',
                        icon: Icons.check,
                        onPressed: _saveItem,
                        style: GlowingButtonStyle.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        color: AppTheme.paleWhite,
        fontFamily: 'Montserrat',
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppTheme.coldGray),
        hintStyle: const TextStyle(color: AppTheme.coldGray),
        filled: true,
        fillColor: AppTheme.obscureGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.mutagenGreen, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.coldGray, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.mutagenGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.ritualRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.ritualRed, width: 2),
        ),
      ),
    );
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final item = Item(
      id: widget.item?.id ?? '',
      nome: _nomeController.text,
      descricao: _descricaoController.text,
      quantidade: int.parse(_quantidadeController.text),
      tipo: _selectedTipo,
      espaco: int.parse(_espacoController.text),
      isAmaldicoado: _isAmaldicoado,
      formulaDano: _selectedTipo == 'Arma' && _formulaDanoController.text.isNotEmpty
          ? _formulaDanoController.text
          : null,
      formulaCura: _selectedTipo == 'Cura' && _formulaCuraController.text.isNotEmpty
          ? _formulaCuraController.text
          : null,
      multiplicadorCritico: _multiplicadorCriticoController.text.isNotEmpty
          ? int.tryParse(_multiplicadorCriticoController.text)
          : null,
      efeitoCritico:
          _efeitoCriticoController.text.isNotEmpty ? _efeitoCriticoController.text : null,
      efeitoEspecial:
          _efeitoEspecialController.text.isNotEmpty ? _efeitoEspecialController.text : null,
    );

    Navigator.pop(context, item);
  }
}

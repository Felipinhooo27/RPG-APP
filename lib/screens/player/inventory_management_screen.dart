import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/character.dart';
import '../../models/item.dart';
import '../../core/database/item_repository.dart';
import '../../core/database/character_repository.dart';
import '../../core/utils/item_export_helper.dart';
import 'item_form_screen.dart';

/// Tela completa de gerenciamento de inventário
/// Funcionalidades: Pesquisa, Filtros, CRUD, Export/Import, Gestão de Créditos
class InventoryManagementScreen extends StatefulWidget {
  final Character character;

  const InventoryManagementScreen({
    super.key,
    required this.character,
  });

  @override
  State<InventoryManagementScreen> createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  final _itemRepo = ItemRepository();
  final _characterRepo = CharacterRepository();
  final _searchController = TextEditingController();

  List<Item> _allItems = [];
  List<Item> _filteredItems = [];
  String _searchQuery = '';
  ItemType? _filterTipo;
  String? _filterCategoria;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await _itemRepo.getByCharacterId(widget.character.id);
      setState(() {
        _allItems = items;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar itens: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    _filteredItems = _allItems.where((item) {
      // Filtro de pesquisa
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!item.nome.toLowerCase().contains(query) &&
            !item.descricao.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filtro de tipo
      if (_filterTipo != null && item.tipo != _filterTipo) {
        return false;
      }

      // Filtro de categoria
      if (_filterCategoria != null &&
          item.categoria?.toLowerCase() != _filterCategoria!.toLowerCase()) {
        return false;
      }

      return true;
    }).toList();

    // Ordena por nome
    _filteredItems.sort((a, b) => a.nome.compareTo(b.nome));
  }

  @override
  Widget build(BuildContext context) {
    final pesoTotal = _allItems.fold<int>(0, (sum, item) => sum + item.espacoTotal);
    final pesoMax = widget.character.pesoMaximo;

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColors.darkGray,
        elevation: 0,
        title: Text('INVENTÁRIO', style: AppTextStyles.title),
        actions: [
          // Menu de opções
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.silver),
            color: AppColors.darkGray,
            onSelected: (value) {
              switch (value) {
                case 'export_all':
                  _exportInventory();
                  break;
                case 'import':
                  _importItems();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_all',
                child: Text('Exportar Inventário', style: TextStyle(color: AppColors.lightGray)),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Text('Importar Itens', style: TextStyle(color: AppColors.lightGray)),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        backgroundColor: AppColors.magenta,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: const Icon(Icons.add, color: AppColors.deepBlack),
      ),
      body: Column(
        children: [
          // Header: Créditos e Peso
          _buildHeader(pesoTotal, pesoMax),

          // Pesquisa e Filtros
          _buildSearchAndFilters(),

          // Lista de Itens
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.magenta),
                  )
                : _filteredItems.isEmpty
                    ? _buildEmptyState()
                    : _buildItemList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int pesoAtual, int pesoMax) {
    final percentual = pesoMax > 0 ? (pesoAtual / pesoMax) : 0.0;
    Color weightColor;
    if (percentual >= 1.0) {
      weightColor = AppColors.neonRed;
    } else if (percentual >= 0.75) {
      weightColor = AppColors.sanYellow;
    } else {
      weightColor = AppColors.conhecimentoGreen;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.darkGray,
      child: Column(
        children: [
          // Créditos
          Row(
            children: [
              const Icon(Icons.monetization_on, color: AppColors.conhecimentoGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'CRÉDITOS:',
                style: AppTextStyles.uppercase.copyWith(
                  fontSize: 11,
                  color: AppColors.silver.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${widget.character.creditos}',
                style: AppTextStyles.title.copyWith(
                  fontSize: 20,
                  color: AppColors.conhecimentoGreen,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: _addCredits,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.conhecimentoGreen),
                  ),
                  child: const Icon(Icons.add, color: AppColors.conhecimentoGreen, size: 16),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Peso
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PESO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: weightColor,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '$pesoAtual / $pesoMax kg',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: weightColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.deepBlack,
              border: Border.all(color: weightColor.withOpacity(0.3)),
            ),
            child: FractionallySizedBox(
              widthFactor: percentual.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(color: weightColor),
            ),
          ),
          if (percentual >= 1.0) ...[
            const SizedBox(height: 8),
            Text(
              '⚠ SOBRECARGA',
              style: TextStyle(
                fontSize: 9,
                color: AppColors.neonRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.deepBlack,
      child: Column(
        children: [
          // Campo de pesquisa
          TextField(
            controller: _searchController,
            style: AppTextStyles.body.copyWith(color: AppColors.lightGray),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _applyFilters();
              });
            },
            decoration: InputDecoration(
              hintText: 'Pesquisar itens...',
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.silver.withOpacity(0.3),
              ),
              prefixIcon: const Icon(Icons.search, color: AppColors.silver),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.silver),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _applyFilters();
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.darkGray,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: AppColors.silver),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: AppColors.silver.withOpacity(0.3)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: AppColors.magenta, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),

          const SizedBox(height: 12),

          // Filtros
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(),
              ),
              const SizedBox(width: 12),
              if (_filterTipo != null || _filterCategoria != null)
                InkWell(
                  onTap: () {
                    setState(() {
                      _filterTipo = null;
                      _filterCategoria = null;
                      _applyFilters();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.neonRed),
                    ),
                    child: const Icon(Icons.clear, color: AppColors.neonRed, size: 20),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border.all(color: AppColors.silver.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filterTipo != null ? 'tipo_${_filterTipo!.name}' : null,
          isExpanded: true,
          hint: Text(
            'Filtrar por tipo',
            style: AppTextStyles.body.copyWith(
              color: AppColors.silver.withOpacity(0.5),
            ),
          ),
          dropdownColor: AppColors.darkGray,
          style: AppTextStyles.body.copyWith(color: AppColors.lightGray),
          onChanged: (String? newValue) {
            setState(() {
              if (newValue != null && newValue.startsWith('tipo_')) {
                final tipoName = newValue.substring(5);
                _filterTipo = ItemType.values.firstWhere((t) => t.name == tipoName);
              } else {
                _filterTipo = null;
              }
              _applyFilters();
            });
          },
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Todos os tipos'),
            ),
            ...ItemType.values.map((ItemType tipo) {
              return DropdownMenuItem<String>(
                value: 'tipo_${tipo.name}',
                child: Text(_getTipoNome(tipo)),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _getTipoNome(ItemType tipo) {
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.silver.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _filterTipo != null
                ? 'Nenhum item encontrado'
                : 'Inventário vazio',
            style: AppTextStyles.body.copyWith(color: AppColors.silver),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em + para adicionar itens',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.silver.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(Item item) {
    final tipoColor = _getItemTypeColor(item.tipo);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border(
          left: BorderSide(color: tipoColor, width: 4),
          top: BorderSide(color: AppColors.silver.withOpacity(0.3)),
          right: BorderSide(color: AppColors.silver.withOpacity(0.3)),
          bottom: BorderSide(color: AppColors.silver.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Nome e Tipo
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome.toUpperCase(),
                      style: AppTextStyles.uppercase.copyWith(
                        fontSize: 13,
                        color: AppColors.lightGray,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.categoria != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.categoria!,
                        style: TextStyle(
                          fontSize: 10,
                          color: tipoColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tipoColor.withOpacity(0.2),
                  border: Border.all(color: tipoColor),
                ),
                child: Text(
                  _getTipoNome(item.tipo).toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: tipoColor,
                  ),
                ),
              ),
            ],
          ),

          if (item.descricao.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.descricao,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.silver.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 8),

          // Info: Quantidade, Peso, Propriedades
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _buildInfoBadge('QTD', '${item.quantidade}', AppColors.silver),
              _buildInfoBadge('PESO', '${item.espacoTotal}kg', AppColors.silver),
              if (item.formulaDano != null)
                _buildInfoBadge('DANO', item.formulaDano!, AppColors.neonRed),
              if (item.formulaCura != null)
                _buildInfoBadge('CURA', item.formulaCura!, AppColors.conhecimentoGreen),
              if (item.defesaBonus != null && item.defesaBonus! > 0)
                _buildInfoBadge('DEF', '+${item.defesaBonus}', AppColors.vigBlue),
            ],
          ),

          const SizedBox(height: 12),

          // Ações
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'EDITAR',
                  Icons.edit,
                  AppColors.conhecimentoGreen,
                  () => _editItem(item),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  'EXCLUIR',
                  Icons.delete,
                  AppColors.neonRed,
                  () => _deleteItem(item),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _exportItem(item),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.magenta),
                  ),
                  child: const Icon(Icons.share, color: AppColors.magenta, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 9,
            color: color.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getItemTypeColor(ItemType tipo) {
    switch (tipo) {
      case ItemType.arma:
        return AppColors.neonRed;
      case ItemType.cura:
        return AppColors.conhecimentoGreen;
      case ItemType.municao:
        return AppColors.sanYellow;
      case ItemType.equipamento:
        return AppColors.vigBlue;
      case ItemType.consumivel:
        return AppColors.magenta;
    }
  }

  Future<void> _addItem() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ItemFormScreen(characterId: widget.character.id),
      ),
    );

    if (result == true) {
      _loadItems();
    }
  }

  Future<void> _editItem(Item item) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ItemFormScreen(
          characterId: widget.character.id,
          itemToEdit: item,
        ),
      ),
    );

    if (result == true) {
      _loadItems();
    }
  }

  Future<void> _deleteItem(Item item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text('CONFIRMAR EXCLUSÃO', style: TextStyle(color: AppColors.lightGray)),
        content: Text(
          'Deseja realmente excluir ${item.nome}?',
          style: const TextStyle(color: AppColors.silver),
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
        await _itemRepo.delete(item.id);
        _loadItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.nome} excluído'),
              backgroundColor: AppColors.conhecimentoGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }

  Future<void> _exportItem(Item item) async {
    await ItemExportHelper.exportAndCopyItem(item, asJson: true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item exportado para a área de transferência!'),
          backgroundColor: AppColors.conhecimentoGreen,
        ),
      );
    }
  }

  Future<void> _exportInventory() async {
    await ItemExportHelper.exportAndCopyInventory(
      _allItems,
      characterName: widget.character.nome,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inventário completo exportado!'),
          backgroundColor: AppColors.conhecimentoGreen,
        ),
      );
    }
  }

  Future<void> _importItems() async {
    final result = await ItemExportHelper.importFromClipboard();

    if (!result.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Erro ao importar'),
            backgroundColor: AppColors.neonRed,
          ),
        );
      }
      return;
    }

    // Ajustar characterId dos itens importados
    final itemsToImport = result.items!.map((item) {
      return item.copyWith(characterId: widget.character.id);
    }).toList();

    try {
      await _itemRepo.importItems(itemsToImport);
      _loadItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${itemsToImport.length} itens importados!'),
            backgroundColor: AppColors.conhecimentoGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao importar: $e'),
            backgroundColor: AppColors.neonRed,
          ),
        );
      }
    }
  }

  Future<void> _addCredits() async {
    final controller = TextEditingController();

    final amount = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text('ADICIONAR CRÉDITOS', style: TextStyle(color: AppColors.lightGray)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.lightGray),
          decoration: const InputDecoration(
            hintText: 'Valor',
            hintStyle: TextStyle(color: AppColors.silver),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.conhecimentoGreen,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('ADICIONAR'),
          ),
        ],
      ),
    );

    if (amount != null && amount > 0) {
      try {
        await _characterRepo.addCredits(widget.character.id, amount);
        setState(() {
          widget.character.creditos += amount;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('+\$$amount créditos'),
              backgroundColor: AppColors.conhecimentoGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')),
          );
        }
      }
    }
  }
}

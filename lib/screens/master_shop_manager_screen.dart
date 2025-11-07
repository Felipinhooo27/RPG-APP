import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/shop_item.dart';
import '../services/shop_service.dart';
import '../theme/app_theme.dart';
import '../utils/shop_generator.dart';
import '../widgets/widgets.dart';

class MasterShopManagerScreen extends StatefulWidget {
  final String masterId;

  const MasterShopManagerScreen({
    super.key,
    required this.masterId,
  });

  @override
  State<MasterShopManagerScreen> createState() => _MasterShopManagerScreenState();
}

class _MasterShopManagerScreenState extends State<MasterShopManagerScreen> {
  final ShopService _shopService = ShopService();
  final ShopGenerator _shopGenerator = ShopGenerator();
  final Uuid _uuid = const Uuid();

  List<Shop> _shops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  Future<void> _loadShops() async {
    setState(() => _isLoading = true);

    try {
      final shops = await _shopService.getShopsByMaster(widget.masterId);
      setState(() {
        _shops = shops;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Erro ao carregar lojas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return HexatombeBackground(
      showParticles: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppTheme.abyssalBlack.withOpacity(0.9),
          elevation: 0,
          title: const Text(
            'GERENCIAR LOJAS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'BebasNeue',
              letterSpacing: 2,
              color: AppTheme.alertYellow,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_business, color: AppTheme.mutagenGreen),
              onPressed: _showGenerateShopDialog,
              tooltip: 'Gerar Loja',
            ),
            IconButton(
              icon: const Icon(Icons.upload_file, color: AppTheme.etherealPurple),
              onPressed: _importShop,
              tooltip: 'Importar Loja',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _shops.isEmpty
                ? _buildEmptyState()
                : _buildShopsList(),
        floatingActionButton: GlowingButton(
          label: 'Nova Loja',
          icon: Icons.add,
          onPressed: _createCustomShop,
          style: GlowingButtonStyle.primary,
          pulsateGlow: true,
        ),
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
                  color: AppTheme.alertYellow.withOpacity(0.35),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.store,
              size: 60,
              color: AppTheme.alertYellow,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'NENHUMA LOJA',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.coldGray,
              fontFamily: 'BebasNeue',
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crie ou gere uma loja para começar',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.coldGray,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _shops.length,
      itemBuilder: (context, index) {
        final shop = _shops[index];
        return _buildShopCard(shop, index);
      },
    );
  }

  Widget _buildShopCard(Shop shop, int index) {
    Color typeColor = _getShopTypeColor(shop.tipo);

    return GestureDetector(
      onTap: () => _editShop(shop),
      child: RitualCard(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        glowEffect: true,
        glowColor: typeColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: typeColor.withOpacity(0.35),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.store,
                    color: AppTheme.alertYellow,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.nome.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.paleWhite,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildBadge(shop.tipo, typeColor),
                          const SizedBox(width: 8),
                          _buildBadge('${shop.items.length} itens', AppTheme.coldGray),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: AppTheme.coldGray),
                  color: AppTheme.obscureGray,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: AppTheme.etherealPurple, size: 20),
                          SizedBox(width: 12),
                          Text('Editar', style: TextStyle(color: AppTheme.paleWhite)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.download, color: AppTheme.mutagenGreen, size: 20),
                          SizedBox(width: 12),
                          Text('Exportar', style: TextStyle(color: AppTheme.paleWhite)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AppTheme.ritualRed, size: 20),
                          SizedBox(width: 12),
                          Text('Excluir', style: TextStyle(color: AppTheme.paleWhite)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editShop(shop);
                    } else if (value == 'export') {
                      _exportShop(shop);
                    } else if (value == 'delete') {
                      _deleteShop(shop);
                    }
                  },
                ),
              ],
            ),
            if (shop.descricao.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                shop.descricao,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.coldGray,
                  fontFamily: 'Montserrat',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ).animate().fadeIn(delay: (index * 50).ms, duration: 300.ms).slideX(begin: -0.1, end: 0),
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
            color: color.withOpacity(0.35),
            blurRadius: 6,
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

  void _showGenerateShopDialog() {
    String selectedType = 'Armeiro';
    int itemCount = 20;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: RitualCard(
            glowEffect: true,
            glowColor: AppTheme.mutagenGreen,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: AppTheme.mutagenGreen, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'GERAR LOJA AUTOMÁTICA',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.mutagenGreen,
                    fontFamily: 'BebasNeue',
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Loja',
                    labelStyle: const TextStyle(color: AppTheme.coldGray),
                    filled: true,
                    fillColor: AppTheme.obscureGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.mutagenGreen, width: 2),
                    ),
                  ),
                  dropdownColor: AppTheme.obscureGray,
                  style: const TextStyle(color: AppTheme.paleWhite),
                  items: ['Armeiro', 'Curas', 'Materiais', 'Munições', 'Geral']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantidade de Itens: $itemCount',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.paleWhite,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Slider(
                      value: itemCount.toDouble(),
                      min: 5,
                      max: 50,
                      divisions: 9,
                      activeColor: AppTheme.mutagenGreen,
                      inactiveColor: AppTheme.obscureGray,
                      onChanged: (value) {
                        setDialogState(() {
                          itemCount = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GlowingButton(
                        label: 'Cancelar',
                        onPressed: () => Navigator.pop(context),
                        style: GlowingButtonStyle.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlowingButton(
                        label: 'Gerar',
                        icon: Icons.auto_awesome,
                        onPressed: () {
                          Navigator.pop(context);
                          _generateShop(selectedType, itemCount);
                        },
                        style: GlowingButtonStyle.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9)),
        ),
      ),
    );
  }

  Future<void> _generateShop(String type, int itemCount) async {
    try {
      final shop = _shopGenerator.generateShop(
        tipo: type,
        createdBy: widget.masterId,
        itemCount: itemCount,
      );

      await _shopService.createShop(shop);
      await _loadShops();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loja gerada com sucesso!'),
            backgroundColor: AppTheme.mutagenGreen,
          ),
        );
      }
    } catch (e) {
      _showError('Erro ao gerar loja: $e');
    }
  }

  Future<void> _createCustomShop() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ShopFormDialog(shop: null),
    );

    if (result != null) {
      try {
        final shop = Shop(
          id: _uuid.v4(),
          nome: result['nome'],
          tipo: result['tipo'],
          descricao: result['descricao'],
          items: [],
          createdAt: DateTime.now(),
          createdBy: widget.masterId,
        );

        await _shopService.createShop(shop);
        await _loadShops();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loja criada com sucesso!'),
              backgroundColor: AppTheme.mutagenGreen,
            ),
          );
        }
      } catch (e) {
        _showError('Erro ao criar loja: $e');
      }
    }
  }

  Future<void> _editShop(Shop shop) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopEditorScreen(shop: shop),
      ),
    ).then((_) => _loadShops());
  }

  Future<void> _exportShop(Shop shop) async {
    try {
      final jsonString = await _shopService.exportShop(shop.id);
      await Clipboard.setData(ClipboardData(text: jsonString));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loja exportada para área de transferência!'),
            backgroundColor: AppTheme.mutagenGreen,
          ),
        );
      }
    } catch (e) {
      _showError('Erro ao exportar: $e');
    }
  }

  Future<void> _importShop() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.bytes != null) {
        final jsonString = String.fromCharCodes(result.files.single.bytes!);
        await _shopService.importShop(jsonString, widget.masterId);
        await _loadShops();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loja importada com sucesso!'),
              backgroundColor: AppTheme.mutagenGreen,
            ),
          );
        }
      }
    } catch (e) {
      _showError('Erro ao importar: $e');
    }
  }

  Future<void> _deleteShop(Shop shop) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RitualCard(
          glowEffect: true,
          glowColor: AppTheme.ritualRed,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, color: AppTheme.ritualRed, size: 48),
              const SizedBox(height: 16),
              const Text(
                'EXCLUIR LOJA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ritualRed,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Deseja excluir "${shop.nome}"?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.paleWhite,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlowingButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.pop(context, false),
                      style: GlowingButtonStyle.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
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
      try {
        await _shopService.deleteShop(shop.id);
        await _loadShops();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loja excluída!'),
              backgroundColor: AppTheme.ritualRed,
            ),
          );
        }
      } catch (e) {
        _showError('Erro ao excluir: $e');
      }
    }
  }

  Color _getShopTypeColor(String tipo) {
    switch (tipo) {
      case 'Armeiro':
        return AppTheme.ritualRed;
      case 'Curas':
        return AppTheme.mutagenGreen;
      case 'Materiais':
        return AppTheme.etherealPurple;
      case 'Munições':
        return AppTheme.alertYellow;
      default:
        return AppTheme.coldGray;
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

// Shop Form Dialog
class _ShopFormDialog extends StatefulWidget {
  final Shop? shop;

  const _ShopFormDialog({this.shop});

  @override
  State<_ShopFormDialog> createState() => _ShopFormDialogState();
}

class _ShopFormDialogState extends State<_ShopFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  String _selectedTipo = 'Geral';

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.shop?.nome ?? '');
    _descricaoController = TextEditingController(text: widget.shop?.descricao ?? '');
    if (widget.shop != null) {
      _selectedTipo = widget.shop!.tipo;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: RitualCard(
        glowEffect: true,
        glowColor: AppTheme.alertYellow,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'CRIAR LOJA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.alertYellow,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomeController,
                style: const TextStyle(color: AppTheme.paleWhite),
                decoration: InputDecoration(
                  labelText: 'Nome da Loja',
                  labelStyle: const TextStyle(color: AppTheme.coldGray),
                  filled: true,
                  fillColor: AppTheme.obscureGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.alertYellow, width: 2),
                  ),
                ),
                validator: (value) => value?.isEmpty == true ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                style: const TextStyle(color: AppTheme.paleWhite),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  labelStyle: const TextStyle(color: AppTheme.coldGray),
                  filled: true,
                  fillColor: AppTheme.obscureGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTipo,
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  filled: true,
                  fillColor: AppTheme.obscureGray,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                dropdownColor: AppTheme.obscureGray,
                style: const TextStyle(color: AppTheme.paleWhite),
                items: ['Armeiro', 'Curas', 'Materiais', 'Munições', 'Geral', 'Personalizada']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedTipo = value!),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlowingButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.pop(context),
                      style: GlowingButtonStyle.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlowingButton(
                      label: 'Criar',
                      icon: Icons.check,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context, {
                            'nome': _nomeController.text,
                            'descricao': _descricaoController.text,
                            'tipo': _selectedTipo,
                          });
                        }
                      },
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
}

// Shop Editor Screen (simplified)
class ShopEditorScreen extends StatefulWidget {
  final Shop shop;

  const ShopEditorScreen({super.key, required this.shop});

  @override
  State<ShopEditorScreen> createState() => _ShopEditorScreenState();
}

class _ShopEditorScreenState extends State<ShopEditorScreen> {
  final ShopService _shopService = ShopService();
  late List<ShopItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.shop.items);
  }

  @override
  Widget build(BuildContext context) {
    return HexatombeBackground(
      showParticles: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppTheme.abyssalBlack.withOpacity(0.9),
          title: Text(
            widget.shop.nome.toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'BebasNeue',
              letterSpacing: 2,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save, color: AppTheme.mutagenGreen),
              onPressed: _saveShop,
            ),
          ],
        ),
        body: _items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2, size: 80, color: AppTheme.coldGray),
                    const SizedBox(height: 16),
                    const Text(
                      'NENHUM ITEM',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.coldGray,
                        fontFamily: 'BebasNeue',
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return RitualCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.nome,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.paleWhite,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.preco}¢ • P${item.patenteMinima} • ${item.espaco} espaço',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.coldGray,
                                ),
                              ),
                              if (item.descricao.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.descricao,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.coldGray,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppTheme.etherealPurple),
                          onPressed: () => _editItem(index),
                          tooltip: 'Editar Item',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppTheme.ritualRed),
                          onPressed: () {
                            setState(() => _items.removeAt(index));
                          },
                          tooltip: 'Excluir Item',
                        ),
                      ],
                    ),
                  );
                },
              ),
        floatingActionButton: GlowingButton(
          label: 'Adicionar Item',
          icon: Icons.add,
          onPressed: _addItem,
          style: GlowingButtonStyle.primary,
          pulsateGlow: true,
        ),
      ),
    );
  }

  Future<void> _addItem() async {
    final result = await showDialog<ShopItem>(
      context: context,
      builder: (context) => _ItemFormDialog(),
    );

    if (result != null) {
      setState(() {
        _items.add(result);
      });
    }
  }

  Future<void> _editItem(int index) async {
    final result = await showDialog<ShopItem>(
      context: context,
      builder: (context) => _ItemFormDialog(item: _items[index]),
    );

    if (result != null) {
      setState(() {
        _items[index] = result;
      });
    }
  }

  Future<void> _saveShop() async {
    try {
      final updatedShop = widget.shop.copyWith(items: _items);
      await _shopService.updateShop(updatedShop);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loja salva com sucesso!'),
            backgroundColor: AppTheme.mutagenGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: AppTheme.ritualRed,
          ),
        );
      }
    }
  }
}

// Item Form Dialog
class _ItemFormDialog extends StatefulWidget {
  final ShopItem? item;

  const _ItemFormDialog({this.item});

  @override
  State<_ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<_ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _precoController;
  late TextEditingController _espacoController;
  late TextEditingController _patenteController;
  String _selectedTipo = 'Arma';

  final List<String> _tipos = [
    'Arma',
    'Armadura',
    'Munição',
    'Equipamento',
    'Consumível',
    'Médico',
    'Tecnologia',
    'Paranormal',
    'Diversos',
  ];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.item?.nome ?? '');
    _descricaoController = TextEditingController(text: widget.item?.descricao ?? '');
    _precoController = TextEditingController(text: widget.item?.preco.toString() ?? '100');
    _espacoController = TextEditingController(text: widget.item?.espaco.toString() ?? '1');
    _patenteController = TextEditingController(text: widget.item?.patenteMinima.toString() ?? '0');
    if (widget.item != null) {
      _selectedTipo = widget.item!.tipo;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _espacoController.dispose();
    _patenteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: RitualCard(
        glowEffect: true,
        glowColor: AppTheme.etherealPurple,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      isEditing ? Icons.edit : Icons.add_shopping_cart,
                      color: AppTheme.etherealPurple,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? 'EDITAR ITEM' : 'ADICIONAR ITEM',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.etherealPurple,
                        fontFamily: 'BebasNeue',
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Nome
                TextFormField(
                  controller: _nomeController,
                  style: const TextStyle(color: AppTheme.paleWhite),
                  decoration: _buildInputDecoration('Nome do Item', Icons.label),
                  validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 16),

                // Tipo
                DropdownButtonFormField<String>(
                  value: _selectedTipo,
                  decoration: _buildInputDecoration('Tipo', Icons.category),
                  dropdownColor: AppTheme.obscureGray,
                  style: const TextStyle(color: AppTheme.paleWhite),
                  items: _tipos.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (value) => setState(() => _selectedTipo = value!),
                ),
                const SizedBox(height: 16),

                // Descrição
                TextFormField(
                  controller: _descricaoController,
                  style: const TextStyle(color: AppTheme.paleWhite),
                  maxLines: 3,
                  decoration: _buildInputDecoration('Descrição', Icons.description),
                ),
                const SizedBox(height: 16),

                // Preço e Patente
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _precoController,
                        style: const TextStyle(color: AppTheme.paleWhite),
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration('Preço (¢)', Icons.attach_money),
                        validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _patenteController,
                        style: const TextStyle(color: AppTheme.paleWhite),
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration('Patente', Icons.military_tech),
                        validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Espaço
                TextFormField(
                  controller: _espacoController,
                  style: const TextStyle(color: AppTheme.paleWhite),
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration('Espaço', Icons.inventory_2),
                  validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 24),

                // Botões
                Row(
                  children: [
                    Expanded(
                      child: GlowingButton(
                        label: 'Cancelar',
                        onPressed: () => Navigator.pop(context),
                        style: GlowingButtonStyle.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlowingButton(
                        label: isEditing ? 'Salvar' : 'Adicionar',
                        icon: isEditing ? Icons.check : Icons.add,
                        onPressed: _submitForm,
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

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.coldGray),
      prefixIcon: Icon(icon, color: AppTheme.etherealPurple, size: 20),
      filled: true,
      fillColor: AppTheme.obscureGray,
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
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final item = ShopItem(
        id: widget.item?.id ?? const Uuid().v4(),
        nome: _nomeController.text,
        tipo: _selectedTipo,
        descricao: _descricaoController.text,
        preco: int.tryParse(_precoController.text) ?? 100,
        espaco: int.tryParse(_espacoController.text) ?? 1,
        patenteMinima: int.tryParse(_patenteController.text) ?? 0,
        iconCode: widget.item?.iconCode ?? '0xe567',
      );

      Navigator.pop(context, item);
    }
  }
}

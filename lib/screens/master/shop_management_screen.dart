import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/shop.dart';
import '../../core/database/shop_repository.dart';
import '../../core/utils/clipboard_helper.dart';
import 'shop_edit_screen.dart';

/// Tela de gerenciamento de lojas para mestres
/// Lista todas as lojas criadas com opções de CRUD
class ShopManagementScreen extends StatefulWidget {
  const ShopManagementScreen({super.key});

  @override
  State<ShopManagementScreen> createState() => _ShopManagementScreenState();
}

class _ShopManagementScreenState extends State<ShopManagementScreen> {
  final _shopRepo = ShopRepository();
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
      final shops = await _shopRepo.getAll();
      setState(() {
        _shops = shops;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar lojas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.magenta),
            )
          : _shops.isEmpty
              ? _buildEmptyState()
              : _buildShopList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createShop,
        backgroundColor: AppColors.magenta,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: const Icon(Icons.add, color: AppColors.deepBlack),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store, size: 64, color: AppColors.silver.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Nenhuma loja criada',
            style: AppTextStyles.body.copyWith(color: AppColors.silver),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em + para criar sua primeira loja',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.silver.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _shops.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final shop = _shops[index];
        return _buildShopCard(shop);
      },
    );
  }

  Widget _buildShopCard(Shop shop) {
    final typeColor = _getShopTypeColor(shop.tipo);
    final typeIcon = _getShopTypeIcon(shop.tipo);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border(
          left: BorderSide(color: typeColor, width: 4),
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
              Icon(typeIcon, color: typeColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.nome.toUpperCase(),
                      style: AppTextStyles.uppercase.copyWith(
                        fontSize: 14,
                        color: AppColors.lightGray,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getShopTypeName(shop.tipo),
                      style: TextStyle(
                        fontSize: 11,
                        color: typeColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.2),
                  border: Border.all(color: typeColor),
                ),
                child: Text(
                  '${shop.itens.length} ITENS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: typeColor,
                  ),
                ),
              ),
            ],
          ),

          if (shop.descricao.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              shop.descricao,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.silver.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 16),

          // Ações
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'EDITAR',
                  Icons.edit,
                  AppColors.conhecimentoGreen,
                  () => _editShop(shop),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  'EXPORTAR',
                  Icons.share,
                  AppColors.magenta,
                  () => _exportShop(shop),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  'DUPLICAR',
                  Icons.content_copy,
                  AppColors.energiaYellow,
                  () => _duplicateShop(shop),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  'EXCLUIR',
                  Icons.delete,
                  AppColors.neonRed,
                  () => _deleteShop(shop),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getShopTypeColor(ShopType tipo) {
    switch (tipo) {
      case ShopType.taberna:
        return AppColors.sanYellow;
      case ShopType.armaria:
        return AppColors.neonRed;
      case ShopType.farmacia:
        return AppColors.conhecimentoGreen;
      case ShopType.mercador:
        return AppColors.magenta;
      case ShopType.forjaria:
        return AppColors.vigBlue;
    }
  }

  IconData _getShopTypeIcon(ShopType tipo) {
    switch (tipo) {
      case ShopType.taberna:
        return Icons.local_bar;
      case ShopType.armaria:
        return Icons.sports_martial_arts;
      case ShopType.farmacia:
        return Icons.local_hospital;
      case ShopType.mercador:
        return Icons.shopping_bag;
      case ShopType.forjaria:
        return Icons.build;
    }
  }

  String _getShopTypeName(ShopType tipo) {
    switch (tipo) {
      case ShopType.taberna:
        return 'Taberna';
      case ShopType.armaria:
        return 'Armaria';
      case ShopType.farmacia:
        return 'Farmácia';
      case ShopType.mercador:
        return 'Mercador';
      case ShopType.forjaria:
        return 'Forjaria';
    }
  }

  Future<void> _createShop() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const ShopEditScreen(),
      ),
    );

    if (result == true) {
      _loadShops();
    }
  }

  Future<void> _editShop(Shop shop) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ShopEditScreen(shopToEdit: shop),
      ),
    );

    if (result == true) {
      _loadShops();
    }
  }

  Future<void> _duplicateShop(Shop shop) async {
    try {
      await _shopRepo.duplicate(shop.id);
      _loadShops();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${shop.nome} duplicada!'),
            backgroundColor: AppColors.conhecimentoGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao duplicar: $e')),
        );
      }
    }
  }

  Future<void> _deleteShop(Shop shop) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text('CONFIRMAR EXCLUSÃO', style: TextStyle(color: AppColors.lightGray)),
        content: Text(
          'Deseja realmente excluir ${shop.nome}?',
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
        final deleted = await _shopRepo.delete(shop.id);
        if (deleted) {
          _loadShops();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${shop.nome} excluída'),
                backgroundColor: AppColors.conhecimentoGreen,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Loja não encontrada'),
                backgroundColor: AppColors.neonRed,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: AppColors.neonRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _exportShop(Shop shop) async {
    try {
      final json = ClipboardHelper.exportShopJson(shop);
      final jsonController = TextEditingController(text: json);

      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.darkGray,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            title: Row(
              children: [
                const Icon(Icons.share, color: AppColors.magenta, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'EXPORTAR LOJA',
                    style: AppTextStyles.uppercase.copyWith(
                      fontSize: 14,
                      color: AppColors.magenta,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loja: ${shop.nome}',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.lightGray,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tipo: ${_getShopTypeName(shop.tipo)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.silver.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Itens: ${shop.itens.length}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.silver.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Copie o JSON abaixo e compartilhe:',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.silver,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: AppColors.deepBlack,
                      border: Border.all(color: AppColors.silver.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: jsonController,
                      maxLines: null,
                      readOnly: true,
                      style: TextStyle(
                        color: AppColors.lightGray,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('FECHAR'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await ClipboardHelper.copyToClipboard(json);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${shop.nome} copiada para área de transferência!'),
                        backgroundColor: AppColors.conhecimentoGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.copy),
                label: const Text('COPIAR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.magenta,
                  foregroundColor: AppColors.deepBlack,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
            ],
          ),
        );
      }

      jsonController.dispose();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar: $e'),
            backgroundColor: AppColors.neonRed,
          ),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/character.dart';
import '../../models/shop.dart';
import '../../models/item.dart';
import '../../core/database/character_repository.dart';

/// Tela de Loja para Jogadores
/// Compra de itens, validação de créditos e espaço
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
  final CharacterRepository _repo = CharacterRepository();
  late Character _character;
  List<ShopItem> _cart = [];

  // Loja unificada para jogadores (todos os itens em uma única loja)
  final Shop _unifiedShop = Shop(
    id: 'shop_unified',
    nome: 'Mercado da Ordem',
    tipo: ShopType.mercador,
    descricao: 'Equipamentos, armas e suprimentos',
    itens: [
      // Armas e combate
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
      // Medicina e cura
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
      // Equipamentos gerais
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

  @override
  void initState() {
    super.initState();
    _character = widget.character;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildShopInventory(),
          ),
          if (_cart.isNotEmpty) _buildCartSummary(),
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
              Text(
                _unifiedShop.nome.toUpperCase(),
                style: AppTextStyles.uppercase.copyWith(
                  fontSize: 14,
                  color: AppColors.conhecimentoGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatChip('CRÉDITOS', '\$${_character.creditos}', AppColors.conhecimentoGreen),
              const SizedBox(width: 12),
              _buildStatChip('CARRINHO', '${_cart.length}', AppColors.magenta),
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

  // ==========================================================================
  // LISTA DE LOJAS
  // ==========================================================================

  Color _getShopColor(ShopType tipo) {
    switch (tipo) {
      case ShopType.armaria:
        return AppColors.neonRed;
      case ShopType.farmacia:
        return AppColors.conhecimentoGreen;
      case ShopType.mercador:
        return AppColors.energiaYellow;
      case ShopType.taberna:
        return AppColors.sangueRed;
      case ShopType.forjaria:
        return AppColors.medoPurple;
    }
  }

  IconData _getShopIcon(ShopType tipo) {
    switch (tipo) {
      case ShopType.armaria:
        return Icons.shield;
      case ShopType.farmacia:
        return Icons.medical_services;
      case ShopType.mercador:
        return Icons.shopping_bag;
      case ShopType.taberna:
        return Icons.local_bar;
      case ShopType.forjaria:
        return Icons.build;
    }
  }

  // ==========================================================================
  // INVENTÁRIO DA LOJA
  // ==========================================================================
  Widget _buildShopInventory() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _unifiedShop.itens.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _unifiedShop.itens[index];
        final inCart = _cart.any((i) => i.id == item.id);
        return _buildItemCard(item, inCart);
      },
    );
  }

  Widget _buildItemCard(ShopItem item, bool inCart) {
    final canAfford = _character.creditos >= item.preco;
    final color = _getShopColor(_unifiedShop.tipo);

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
            children: [
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
                  onPressed: canAfford
                      ? () => _toggleCart(item)
                      : null,
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

  void _toggleCart(ShopItem item) {
    setState(() {
      if (_cart.any((i) => i.id == item.id)) {
        _cart.removeWhere((i) => i.id == item.id);
      } else {
        _cart.add(item);
      }
    });
  }

  // ==========================================================================
  // RESUMO DO CARRINHO
  // ==========================================================================
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
      // Atualiza apenas os créditos do personagem
      final updatedChar = _character.copyWith(
        creditos: _character.creditos - totalPreco,
      );

      await _repo.update(updatedChar);

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

  String _getPatenteString(int patente) {
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

import 'package:flutter/material.dart';
import '../models/dice_pool.dart';
import '../core/theme/app_colors.dart';
import 'dice_widget.dart';

/// Widget que representa um dado na mesa (antes de ser rolado)
class DicePoolItemWidget extends StatelessWidget {
  final DicePoolItem diceItem;
  final VoidCallback onRemove;
  final bool isAnimating;

  const DicePoolItemWidget({
    super.key,
    required this.diceItem,
    required this.onRemove,
    this.isAnimating = false,
  });

  /// Retorna a cor do dado baseada no tipo
  Color _getDiceColor(DiceType type) {
    switch (type) {
      case DiceType.d4:
        return Colors.green;
      case DiceType.d6:
        return Colors.cyan;
      case DiceType.d8:
        return Colors.purple;
      case DiceType.d10:
        return Colors.pink;
      case DiceType.d12:
        return AppColors.neonRed;
      case DiceType.d20:
        return Colors.orange;
      case DiceType.d100:
        return Colors.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getDiceColor(diceItem.type);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Container do dado
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone do dado
                DiceWidget(
                  diceType: diceItem.type,
                  size: 32,
                  color: color,
                ),
                const SizedBox(height: 4),
                // Tipo do dado
                Text(
                  diceItem.type.displayName.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Botão X para remover
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.neonRed,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonRed.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

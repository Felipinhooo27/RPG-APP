import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../models/dice_pool.dart';
import 'dice_shape_painters.dart';

/// Widget que mostra os dados acumulados no pool ANTES de rolar
class DicePoolDisplay extends StatelessWidget {
  final DicePool pool;
  final Function(String diceId) onRemoveDice;

  const DicePoolDisplay({
    super.key,
    required this.pool,
    required this.onRemoveDice,
  });

  /// Retorna cor vibrante do Google Dice Roller para cada tipo de dado
  Color _getDiceColor(DiceType type) {
    switch (type) {
      case DiceType.d4:
        return const Color(0xFF00BCD4); // Azul-piscina (Cyan)
      case DiceType.d6:
        return const Color(0xFF9C27B0); // Roxo
      case DiceType.d8:
        return const Color(0xFF673AB7); // Roxo/Violeta
      case DiceType.d10:
        return const Color(0xFFE91E63); // Rosa/Magenta
      case DiceType.d12:
        return const Color(0xFFF44336); // Vermelho
      case DiceType.d20:
        return const Color(0xFFFF9800); // Laranja
      case DiceType.d100:
        return const Color(0xFFFFEB3B); // Amarelo
    }
  }

  @override
  Widget build(BuildContext context) {
    if (pool.dice.isEmpty) {
      return const SizedBox.shrink();
    }

    // Grid simples e limpo
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16, // Espaço horizontal entre dados
      runSpacing: 16, // Espaço vertical entre linhas
      children: pool.dice.map((diceItem) {
        return _buildPoolDiceItem(diceItem);
      }).toList(),
    );
  }

  Widget _buildPoolDiceItem(DicePoolItem diceItem) {
    final color = _getDiceColor(diceItem.type);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Forma geométrica específica do dado
        DiceShapeWidget(
          faces: diceItem.type.sides,
          color: color,
          size: 56,
          hasGlow: true,
          strokeWidth: 2,
          child: Text(
            'd${diceItem.type.sides}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),

        // Botão X para remover (canto superior direito)
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: () => onRemoveDice(diceItem.id),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.neonRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

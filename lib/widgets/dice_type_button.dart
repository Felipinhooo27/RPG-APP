import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/dice_pool.dart';
import '../core/theme/app_colors.dart';

/// Botão para adicionar um tipo de dado ao pool
class DiceTypeButton extends StatelessWidget {
  final DiceType type;
  final VoidCallback onPressed;

  const DiceTypeButton({
    super.key,
    required this.type,
    required this.onPressed,
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
    }
  }

  /// Retorna o caminho do asset SVG do dado
  String _getDiceAssetPath(DiceType type) {
    return 'assets/images/dice/${type.name}.svg';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getDiceColor(type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone do dado
              SizedBox(
                width: 24,
                height: 24,
                child: SvgPicture.asset(
                  _getDiceAssetPath(type),
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),
              const SizedBox(height: 2),
              // Número de faces
              Text(
                '${type.sides}',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

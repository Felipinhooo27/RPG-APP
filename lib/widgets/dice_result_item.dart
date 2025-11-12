import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/dice_result.dart';
import '../models/dice_pool.dart';
import '../core/theme/app_colors.dart';
import 'dart:math' as math;

/// Widget que representa o resultado de um dado após ser rolado
class DiceResultItemWidget extends StatefulWidget {
  final DiceResult result;
  final bool animate;

  const DiceResultItemWidget({
    super.key,
    required this.result,
    this.animate = true,
  });

  @override
  State<DiceResultItemWidget> createState() => _DiceResultItemWidgetState();
}

class _DiceResultItemWidgetState extends State<DiceResultItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi, // 360 graus em radianos
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    final color = _getDiceColor(widget.result.type);
    final isCritical = widget.result.isCritical;
    final isFumble = widget.result.isFumble;

    // Cor especial para críticos e falhas
    Color borderColor = color;
    if (isCritical) {
      borderColor = Colors.yellow;
    } else if (isFumble) {
      borderColor = Colors.red.shade900;
    }

    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              border: Border.all(
                color: borderColor,
                width: isCritical || isFumble ? 3 : 2,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isCritical || isFumble
                  ? [
                      BoxShadow(
                        color: borderColor.withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone do dado
                SizedBox(
                  width: 28,
                  height: 28,
                  child: SvgPicture.asset(
                    _getDiceAssetPath(widget.result.type),
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  ),
                ),
                const SizedBox(height: 4),
                // Valor rolado
                Text(
                  '${widget.result.value}',
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

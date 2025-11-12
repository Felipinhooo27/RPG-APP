import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Divisória horizontal com efeito "arranhado" temático Hexatombe
class ScratchedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double thickness;

  const ScratchedDivider({
    super.key,
    this.height = 1.0,
    this.color = AppColors.neonRed,
    this.thickness = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: color,
            width: thickness,
          ),
        ),
      ),
    );
  }
}

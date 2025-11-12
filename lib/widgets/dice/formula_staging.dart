import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/dice_pool.dart';

/// Área de staging que mostra a fórmula preparada
class FormulaStaging extends StatelessWidget {
  final DicePool pool;

  const FormulaStaging({
    super.key,
    required this.pool,
  });

  @override
  Widget build(BuildContext context) {
    final formula = pool.formula;

    // Não mostra nada se pool está vazio
    if (pool.dice.isEmpty && pool.modifier == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        children: [
          // Linha decorativa superior
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.scarletRed.withOpacity(0.5),
                  AppColors.scarletRed,
                  AppColors.scarletRed.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Fórmula
          Text(
            formula,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: Color(0xFFe0e0e0),
              fontFamily: 'monospace',
            ),
          ),

          const SizedBox(height: 12),

          // Linha decorativa inferior
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.scarletRed.withOpacity(0.5),
                  AppColors.scarletRed,
                  AppColors.scarletRed.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

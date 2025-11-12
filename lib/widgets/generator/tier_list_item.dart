import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../common/scratched_divider.dart';

/// Item de lista para seleção de Nível de Poder (Tier)
/// Estética "Hexatombe" - sem caixas, hierarquia por tipografia e cor
class TierListItem extends StatelessWidget {
  final String title;
  final String description;
  final String nexPercentage;
  final int points;
  final String pvRange;
  final String peRange;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showDivider;

  const TierListItem({
    super.key,
    required this.title,
    required this.description,
    required this.nexPercentage,
    required this.points,
    required this.pvRange,
    required this.peRange,
    required this.isSelected,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            color: Colors.transparent, // Para área de toque
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Linha 1: Título + NEX
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.neonRed
                              : AppColors.lightGray,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    // NEX Badge
                    Text(
                      'NEX $nexPercentage',
                      style: AppTextStyles.uppercase.copyWith(
                        fontSize: 11,
                        color: AppColors.neonRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Linha 2: Descrição
                Text(
                  description,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 13,
                    color: AppColors.silver.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                // Linha 3: Stats (texto único sem caixas coloridas)
                Text(
                  '($points pts | PV $pvRange | PE $peRange)',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: AppColors.silver.withValues(alpha: 0.6),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Divisória arranhada
        if (showDivider) ...[
          const SizedBox(height: 8),
          const ScratchedDivider(),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

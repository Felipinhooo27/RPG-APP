import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../common/scratched_divider.dart';

/// Item de lista para geradores do Modo Mestre
/// Estética "Hexatombe" - sem caixas, apenas tipografia e cor
class GeneratorListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<String> features;
  final VoidCallback onTap;
  final bool showDivider;

  const GeneratorListItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.features,
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
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Ícone + Título
                Row(
                  children: [
                    Icon(
                      icon,
                      color: AppColors.neonRed,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.uppercase.copyWith(
                          fontSize: 16,
                          color: AppColors.lightGray,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Descrição
                Text(
                  description,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    color: AppColors.silver.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // Features como texto simples (sem caixas)
                Text(
                  '(${features.join(' | ')})',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: AppColors.silver.withValues(alpha: 0.6),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Link de ação (sem botão sólido)
                Text(
                  '[ ABRIR ${title.toUpperCase()} ]',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    color: AppColors.neonRed,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Divisória arranhada
        if (showDivider) ...[
          const SizedBox(height: 20),
          const ScratchedDivider(),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

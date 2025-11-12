import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Seletor de texto horizontal sem chips/caixas
/// Estética "Hexatombe" - apenas texto com linha arranhada para item selecionado
class SegmentedTextSelector<T> extends StatelessWidget {
  final List<SegmentedOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T?> onChanged;

  const SegmentedTextSelector({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 16,
      children: options.map((option) {
        final isSelected = selectedValue == option.value;

        return GestureDetector(
          onTap: () => onChanged(option.value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Texto da opção
              Text(
                option.label,
                style: AppTextStyles.body.copyWith(
                  color: isSelected
                      ? AppColors.neonRed
                      : AppColors.silver.withValues(alpha: 0.6),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              // Linha arranhada abaixo (apenas se selecionado)
              if (isSelected)
                Container(
                  height: 2,
                  width: option.label.length * 8.0, // Aproximação da largura do texto
                  color: AppColors.neonRed,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Classe para definir opções do seletor
class SegmentedOption<T> {
  final String label;
  final T? value;

  const SegmentedOption({
    required this.label,
    required this.value,
  });
}

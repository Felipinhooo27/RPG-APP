import 'package:flutter/material.dart';
import '../../models/character.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../common/segmented_text_selector.dart';

/// Seletor de Sexo para o gerador de personagens
/// Estética "Hexatombe" - texto horizontal sem chips
class SexoSelector extends StatelessWidget {
  final Sexo? selectedSexo;
  final ValueChanged<Sexo?> onChanged;

  const SexoSelector({
    super.key,
    required this.selectedSexo,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label "SEXO"
        Text(
          'SEXO',
          style: AppTextStyles.uppercase.copyWith(
            color: AppColors.lightGray,
          ),
        ),
        const SizedBox(height: 12),
        // Seletor horizontal
        SegmentedTextSelector<Sexo?>(
          options: const [
            SegmentedOption(label: 'ALEATÓRIO', value: null),
            SegmentedOption(label: 'HOMEM', value: Sexo.masculino),
            SegmentedOption(label: 'MULHER', value: Sexo.feminino),
            SegmentedOption(label: 'NÃO-BINÁRIO', value: Sexo.naoBinario),
          ],
          selectedValue: selectedSexo,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

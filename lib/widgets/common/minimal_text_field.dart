import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// TextField minimalista com apenas linha inferior (border-bottom)
/// Estética "Hexatombe" - sem caixas, apenas linha arranhada
class MinimalTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const MinimalTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: AppTextStyles.uppercase.copyWith(
            color: AppColors.lightGray,
          ),
        ),
        const SizedBox(height: 8),
        // Input Field
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          style: AppTextStyles.body.copyWith(
            color: AppColors.lightGray,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.silver.withValues(alpha: 0.4),
            ),
            // Sem caixas - apenas linha inferior
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.neonRed,
                width: 1.0,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.neonRed.withValues(alpha: 0.5),
                width: 1.0,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.neonRed,
                width: 2.0,
              ),
            ),
            // Remove padding interno extra
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            // Remove contador de caracteres padrão
            counterText: '',
            // Sem background
            filled: false,
          ),
        ),
      ],
    );
  }
}

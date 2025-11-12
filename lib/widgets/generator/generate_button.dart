import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Botão principal para gerar personagem
/// Estética "Hexatombe" - vermelho sólido, sem elevation, sem cantos arredondados
class GenerateButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GenerateButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonRed,
          disabledBackgroundColor: AppColors.darkGray,
          foregroundColor: AppColors.lightGray,
          // IMPORTANTE: Zero elevation (regra de design Hexatombe)
          elevation: 0,
          shadowColor: Colors.transparent,
          // Sem cantos arredondados
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          // Tamanho mínimo para prevenir overflow
          minimumSize: const Size(double.infinity, 56),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightGray),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flash_on, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'GERAR PERSONAGEM',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    softWrap: false, // Previne quebra de linha
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
      ),
    );
  }
}

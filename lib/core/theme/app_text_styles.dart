import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Estilos de texto para o app Hexatombe
/// Características: UPPERCASE, letter-spacing amplo, bold
class AppTextStyles {
  // Títulos
  static const TextStyle title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
    color: AppColors.lightGray,
    height: 1.2,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 3.0,
    color: AppColors.lightGray,
    height: 1.2,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    color: AppColors.lightGray,
    height: 1.2,
  );

  // Labels (pequenos, uppercase)
  static const TextStyle label = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    color: AppColors.silver,
    height: 1.0,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    color: AppColors.silver,
    height: 1.0,
  );

  // Texto uppercase padrão
  static const TextStyle uppercase = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppColors.lightGray,
    height: 1.3,
  );

  static const TextStyle uppercaseLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: AppColors.lightGray,
    height: 1.3,
  );

  // Corpo de texto
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    color: AppColors.lightGray,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.3,
    color: AppColors.silver,
    height: 1.4,
  );

  // Números grandes (stats, valores)
  static const TextStyle numberLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    color: AppColors.lightGray,
    height: 1.0,
  );

  static const TextStyle numberMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    color: AppColors.lightGray,
    height: 1.0,
  );

  static const TextStyle numberSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    color: AppColors.lightGray,
    height: 1.0,
  );

  // Botões
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    color: AppColors.lightGray,
    height: 1.0,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
    color: AppColors.lightGray,
    height: 1.0,
  );

  // Erro/Aviso
  static const TextStyle error = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.neonRed,
    height: 1.3,
  );

  // Helper method para adicionar cor customizada
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
}

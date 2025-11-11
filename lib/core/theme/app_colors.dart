import 'package:flutter/material.dart';

/// Paleta de cores inspirada em Hexatombe (Ordem Paranormal)
/// Design: vermelho escarlate + preto + prata
class AppColors {
  // Cores primárias
  static const Color scarletRed = Color(0xFFB50D0D);
  static const Color deepBlack = Color(0xFF0D0D0D);
  static const Color darkGray = Color(0xFF1A1A1A);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color neonRed = Color(0xFFFF1744);
  static const Color magenta = Color(0xFFD500F9);

  // Cores de atributos (Ordem Paranormal)
  static const Color forRed = Color(0xFFFF1744);      // Força
  static const Color agiGreen = Color(0xFF00E676);    // Agilidade
  static const Color vigBlue = Color(0xFF2979FF);     // Vigor
  static const Color intMagenta = Color(0xFFD500F9);  // Intelecto
  static const Color preGold = Color(0xFFFFD700);     // Presença

  // Cores de status
  static const Color pvRed = Color(0xFFFF1744);
  static const Color pePurple = Color(0xFFD500F9);
  static const Color sanYellow = Color(0xFFFFD700);

  // Cores de classes
  static const Color combatenteRed = Color(0xFFFF1744);
  static const Color especialistaGreen = Color(0xFF00E676);
  static const Color ocultistamagenta = Color(0xFFD500F9);

  // Gradientes
  static const LinearGradient redMagentaGradient = LinearGradient(
    colors: [scarletRed, magenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [deepBlack, darkGray],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Cores de elementos paranormais
  static const Color conhecimentoGreen = Color(0xFF00E676);
  static const Color energiaYellow = Color(0xFFFFD700);
  static const Color morteGray = Color(0xFF9E9E9E);
  static const Color sangueRed = Color(0xFFFF1744);
  static const Color medoPurple = Color(0xFFD500F9);
}

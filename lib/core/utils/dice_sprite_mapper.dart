import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/dice_pool.dart';

/// Classe responsável por mapear as coordenadas de cada dado na sprite sheet
class DiceSpriteMapper {
  // Dimensões da sprite sheet completa (1200x680 aproximadamente)
  static const double spriteSheetWidth = 1200.0;
  static const double spriteSheetHeight = 680.0;

  // Dimensões dos dados grandes (header) - primeira linha, ~160px cada
  static const double headerDiceSize = 160.0;

  // Dimensões dos dados pequenos (faces) - ~80px cada
  static const double faceDiceSize = 80.0;

  /// Retorna o Rect (coordenadas) do dado principal/tipo na sprite sheet
  /// Header na primeira linha: D20 | D12 | D10 | D100 | D8 | D6 | D4
  static Rect getDiceTypeRect(DiceType type) {
    switch (type) {
      case DiceType.d20:
        return const Rect.fromLTWH(0, 0, headerDiceSize, headerDiceSize);
      case DiceType.d12:
        return const Rect.fromLTWH(160, 0, headerDiceSize, headerDiceSize);
      case DiceType.d10:
        return const Rect.fromLTWH(320, 0, headerDiceSize, headerDiceSize);
      case DiceType.d100:
        return const Rect.fromLTWH(480, 0, headerDiceSize, headerDiceSize);
      case DiceType.d8:
        return const Rect.fromLTWH(640, 0, headerDiceSize, headerDiceSize);
      case DiceType.d6:
        return const Rect.fromLTWH(800, 0, headerDiceSize, headerDiceSize);
      case DiceType.d4:
        return const Rect.fromLTWH(960, 0, headerDiceSize, headerDiceSize);
    }
  }

  /// Retorna o Rect (coordenadas) de uma face específica do dado
  static Rect getDiceFaceRect(DiceType type, int value) {
    switch (type) {
      case DiceType.d20:
        return _getD20FaceRect(value);
      case DiceType.d12:
        return _getD12FaceRect(value);
      case DiceType.d10:
        return _getD10FaceRect(value);
      case DiceType.d100:
        return _getD100FaceRect(value);
      case DiceType.d8:
        return _getD8FaceRect(value);
      case DiceType.d6:
        return _getD6FaceRect(value);
      case DiceType.d4:
        return _getD4FaceRect(value);
    }
  }

  // ========== MAPEAMENTOS INDIVIDUAIS ==========

  /// D20: 4 linhas x 5 colunas (faces 1-20)
  /// Localização: Colunas 0-4, abaixo do header
  /// Layout: 1-5, 6-10, 11-15, 16-20
  static Rect _getD20FaceRect(int value) {
    if (value < 1 || value > 20) {
      throw ArgumentError('D20 value must be between 1 and 20');
    }

    final int index = value - 1; // 0-19
    final int row = index ~/ 5; // linha (0-3)
    final int col = index % 5; // coluna (0-4)

    final double x = col * faceDiceSize;
    final double y = headerDiceSize + (row * faceDiceSize);

    return Rect.fromLTWH(x, y, faceDiceSize, faceDiceSize);
  }

  /// D12: 3 linhas x 4 colunas (faces 1-12)
  /// Localização: Colunas 5-8 (x = 400+), abaixo do header D12/D10
  /// Layout: 1-4, 5-8, 9-12
  static Rect _getD12FaceRect(int value) {
    if (value < 1 || value > 12) {
      throw ArgumentError('D12 value must be between 1 and 12');
    }

    final int index = value - 1; // 0-11
    final int row = index ~/ 4; // linha (0-2)
    final int col = index % 4; // coluna (0-3)

    final double x = 400 + (col * faceDiceSize);
    final double y = headerDiceSize + (row * faceDiceSize);

    return Rect.fromLTWH(x, y, faceDiceSize, faceDiceSize);
  }

  /// D10: 2 linhas x 5 colunas (faces 0-9, onde 0 representa 10)
  /// Localização: Colunas 8-12 (x = 720+), linhas 2-3
  /// Layout linha 2: 0, 1, 2, 3, 4
  /// Layout linha 3: 5, 6, 7, 8, 9
  static Rect _getD10FaceRect(int value) {
    if (value < 1 || value > 10) {
      throw ArgumentError('D10 value must be between 1 and 10');
    }

    // Converter: valor 10 = face 0 (índice 0), valores 1-9 = índices 1-9
    int index;
    if (value == 10) {
      index = 0; // face "0"
    } else {
      index = value; // faces "1-9"
    }

    final int row = index ~/ 5; // linha (0-1)
    final int col = index % 5; // coluna (0-4)

    final double x = 720 + (col * faceDiceSize);
    final double y = headerDiceSize + (row * faceDiceSize);

    return Rect.fromLTWH(x, y, faceDiceSize, faceDiceSize);
  }

  /// D8: 2 linhas x 4 colunas (faces 1-8)
  /// Localização: Colunas 5-8 (x = 400+), linhas 5-6 (abaixo do D12)
  /// Layout linha 5: 1, 2, 3, 4
  /// Layout linha 6: 5, 6, 7, 8
  static Rect _getD8FaceRect(int value) {
    if (value < 1 || value > 8) {
      throw ArgumentError('D8 value must be between 1 and 8');
    }

    final int index = value - 1; // 0-7
    final int row = index ~/ 4; // linha (0-1)
    final int col = index % 4; // coluna (0-3)

    final double x = 400 + (col * faceDiceSize);
    final double y = headerDiceSize + (3 * faceDiceSize) + (row * faceDiceSize);

    return Rect.fromLTWH(x, y, faceDiceSize, faceDiceSize);
  }

  /// D100: 2 linhas x 5 colunas (dezenas: 00, 10, 20, 30, 40, 50, 60, 70, 80, 90)
  /// Localização: Colunas 8-12 (x = 720+), linhas 4-5 (abaixo do D10)
  /// Layout linha 4: 00, 10, 20, 30, 40
  /// Layout linha 5: 50, 60, 70, 80, 90
  static Rect _getD100FaceRect(int value) {
    if (value < 1 || value > 100) {
      throw ArgumentError('D100 value must be between 1 and 100');
    }

    // D100 mostra dezenas (00, 10, 20, ..., 90)
    // Para valor 1-100, pegamos a dezena
    // Ex: 1-10 = 00, 11-20 = 10, 21-30 = 20, etc.
    final int tens = ((value - 1) ~/ 10) % 10; // 0-9

    final int row = tens ~/ 5; // linha (0-1)
    final int col = tens % 5; // coluna (0-4)

    final double x = 720 + (col * faceDiceSize);
    final double y = headerDiceSize + (2 * faceDiceSize) + (row * faceDiceSize);

    return Rect.fromLTWH(x, y, faceDiceSize, faceDiceSize);
  }

  /// D6: 1 linha x 6 colunas (faces 1-6)
  /// Localização: Colunas 8-13 (x = 720+), linha 6 (última linha)
  static Rect _getD6FaceRect(int value) {
    if (value < 1 || value > 6) {
      throw ArgumentError('D6 value must be between 1 and 6');
    }

    final int index = value - 1; // 0-5
    final double x = 720 + (index * faceDiceSize);
    final double y = headerDiceSize + (4 * faceDiceSize);

    return Rect.fromLTWH(x, y, faceDiceSize, faceDiceSize);
  }

  /// D4: 1 linha x 4 colunas (faces 1-4)
  /// Localização: Colunas 0-3 (x = 0+), linha 6 (última linha, abaixo do D20)
  static Rect _getD4FaceRect(int value) {
    if (value < 1 || value > 4) {
      throw ArgumentError('D4 value must be between 1 and 4');
    }

    final int index = value - 1; // 0-3
    final double x = index * faceDiceSize;
    final double y = headerDiceSize + (4 * faceDiceSize);

    return Rect.fromLTWH(x, y, faceDiceSize, faceDiceSize);
  }
}

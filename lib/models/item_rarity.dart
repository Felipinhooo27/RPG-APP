import 'package:flutter/material.dart';

/// Raridade de um item (afeta preço e disponibilidade)
enum ItemRarity {
  comum(1.0, 'Comum', Colors.grey),
  incomum(1.5, 'Incomum', Colors.green),
  raro(3.0, 'Raro', Colors.blue),
  lendario(10.0, 'Lendário', Colors.orange);

  final double precoMultiplicador;
  final String displayName;
  final Color cor;

  const ItemRarity(this.precoMultiplicador, this.displayName, this.cor);

  /// Retorna a raridade a partir do nome (para serialização)
  static ItemRarity fromString(String valor) {
    return ItemRarity.values.firstWhere(
      (r) => r.name == valor,
      orElse: () => ItemRarity.comum,
    );
  }

  /// Retorna emoji representativo da raridade
  String get emoji {
    switch (this) {
      case ItemRarity.comum:
        return '⚪';
      case ItemRarity.incomum:
        return '🟢';
      case ItemRarity.raro:
        return '🔵';
      case ItemRarity.lendario:
        return '🟠';
    }
  }
}

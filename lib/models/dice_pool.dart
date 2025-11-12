import 'package:uuid/uuid.dart';

/// Representa um tipo de dado disponível
enum DiceType {
  d4(4),
  d6(6),
  d8(8),
  d10(10),
  d12(12),
  d20(20),
  d100(100);

  final int sides;
  const DiceType(this.sides);

  String get displayName => 'd$sides';
}

/// Representa um dado individual no pool (antes de ser rolado)
class DicePoolItem {
  final String id;
  final DiceType type;

  DicePoolItem({
    String? id,
    required this.type,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
      };

  factory DicePoolItem.fromJson(Map<String, dynamic> json) => DicePoolItem(
        id: json['id'] as String,
        type: DiceType.values.byName(json['type'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DicePoolItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Representa a "mesa" de dados que será rolada
class DicePool {
  final List<DicePoolItem> dice;
  final int modifier;

  DicePool({
    List<DicePoolItem>? dice,
    this.modifier = 0,
  }) : dice = dice ?? [];

  DicePool copyWith({
    List<DicePoolItem>? dice,
    int? modifier,
  }) =>
      DicePool(
        dice: dice ?? List<DicePoolItem>.from(this.dice),
        modifier: modifier ?? this.modifier,
      );

  /// Adiciona um dado ao pool
  DicePool addDice(DiceType type) {
    final newDice = List<DicePoolItem>.from(dice)
      ..add(DicePoolItem(type: type));
    return copyWith(dice: newDice);
  }

  /// Remove um dado específico do pool
  DicePool removeDice(String diceId) {
    final newDice = dice.where((d) => d.id != diceId).toList();
    return copyWith(dice: newDice);
  }

  /// Limpa todos os dados do pool
  DicePool clear() => DicePool(modifier: modifier);

  /// Limpa tudo (dados e modificador)
  DicePool clearAll() => DicePool();

  /// Atualiza o modificador
  DicePool updateModifier(int newModifier) =>
      copyWith(modifier: newModifier);

  /// Verifica se o pool está vazio
  bool get isEmpty => dice.isEmpty && modifier == 0;

  /// Retorna a fórmula da rolagem (ex: "2d20 + 1d6 + 5")
  String get formula {
    if (isEmpty) return '0';

    final diceGroups = <DiceType, int>{};
    for (final die in dice) {
      diceGroups[die.type] = (diceGroups[die.type] ?? 0) + 1;
    }

    final parts = <String>[];
    for (final entry in diceGroups.entries) {
      final count = entry.value;
      final type = entry.key;
      parts.add('${count}d${type.sides}');
    }

    if (modifier > 0) {
      parts.add('+$modifier');
    } else if (modifier < 0) {
      parts.add('$modifier');
    }

    return parts.join(' ');
  }

  Map<String, dynamic> toJson() => {
        'dice': dice.map((d) => d.toJson()).toList(),
        'modifier': modifier,
      };

  factory DicePool.fromJson(Map<String, dynamic> json) => DicePool(
        dice: (json['dice'] as List<dynamic>)
            .map((e) => DicePoolItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        modifier: json['modifier'] as int? ?? 0,
      );
}

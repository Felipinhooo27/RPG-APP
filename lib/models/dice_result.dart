import 'package:uuid/uuid.dart';
import 'dice_pool.dart';

/// Representa o resultado de um dado individual após ser rolado
class DiceResult {
  final String id;
  final DiceType type;
  final int value;

  DiceResult({
    String? id,
    required this.type,
    required this.value,
  }) : id = id ?? const Uuid().v4();

  /// Verifica se é um acerto crítico (valor máximo)
  bool get isCritical => value == type.sides;

  /// Verifica se é uma falha crítica (valor 1)
  bool get isFumble => value == 1;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'value': value,
      };

  factory DiceResult.fromJson(Map<String, dynamic> json) => DiceResult(
        id: json['id'] as String,
        type: DiceType.values.byName(json['type'] as String),
        value: json['value'] as int,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiceResult &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

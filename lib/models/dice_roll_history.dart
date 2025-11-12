import 'package:uuid/uuid.dart';
import 'dice_result.dart';

/// Representa uma entrada no histórico de rolagens
class DiceRollHistory {
  final String id;
  final DateTime timestamp;
  final String formula;
  final List<DiceResult> results;
  final int modifier;
  final int total;

  DiceRollHistory({
    String? id,
    DateTime? timestamp,
    required this.formula,
    required this.results,
    required this.modifier,
    required this.total,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  /// Calcula o total dos dados (sem modificador)
  int get diceTotal => results.fold(0, (sum, result) => sum + result.value);

  /// Verifica se contém algum acerto crítico
  bool get hasCritical => results.any((r) => r.isCritical);

  /// Verifica se contém alguma falha crítica
  bool get hasFumble => results.any((r) => r.isFumble);

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'formula': formula,
        'results': results.map((r) => r.toJson()).toList(),
        'modifier': modifier,
        'total': total,
      };

  factory DiceRollHistory.fromJson(Map<String, dynamic> json) =>
      DiceRollHistory(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        formula: json['formula'] as String,
        results: (json['results'] as List<dynamic>)
            .map((e) => DiceResult.fromJson(e as Map<String, dynamic>))
            .toList(),
        modifier: json['modifier'] as int,
        total: json['total'] as int,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiceRollHistory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

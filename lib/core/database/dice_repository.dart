import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/dice_roll_history.dart';

/// Repository para persistir o histórico de rolagens de dados
class DiceRepository {
  static const String _historyKey = 'dice_roll_history';
  static const int _maxHistorySize = 100;

  /// Salva o histórico de rolagens
  Future<void> saveHistory(List<DiceRollHistory> history) async {
    final prefs = await SharedPreferences.getInstance();

    // Limita o tamanho do histórico
    final limitedHistory = history.length > _maxHistorySize
        ? history.sublist(0, _maxHistorySize)
        : history;

    final jsonList = limitedHistory.map((h) => h.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    await prefs.setString(_historyKey, jsonString);
  }

  /// Carrega o histórico de rolagens
  Future<List<DiceRollHistory>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_historyKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => DiceRollHistory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Se houver erro ao carregar, retorna lista vazia
      return [];
    }
  }

  /// Adiciona uma nova rolagem ao histórico
  Future<void> addRoll(DiceRollHistory roll) async {
    final history = await loadHistory();
    history.insert(0, roll); // Adiciona no início (mais recente primeiro)
    await saveHistory(history);
  }

  /// Limpa todo o histórico
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  /// Remove uma rolagem específica do histórico
  Future<void> removeRoll(String rollId) async {
    final history = await loadHistory();
    history.removeWhere((roll) => roll.id == rollId);
    await saveHistory(history);
  }
}

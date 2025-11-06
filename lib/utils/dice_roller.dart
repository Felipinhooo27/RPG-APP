import 'dart:math';

class DiceRollResult {
  final List<DiceRoll> rolls;
  final int total;

  DiceRollResult({
    required this.rolls,
    required this.total,
  });

  String get detailedResult {
    final rollsStr = rolls.map((r) => r.toString()).join(' + ');
    return '$rollsStr = $total';
  }
}

class DiceRoll {
  final int numberOfDice;
  final int sides;
  final List<int> results;
  final int modifier;

  DiceRoll({
    required this.numberOfDice,
    required this.sides,
    required this.results,
    this.modifier = 0,
  });

  int get total {
    final diceSum = results.fold<int>(0, (sum, value) => sum + value);
    return diceSum + modifier;
  }

  @override
  String toString() {
    if (numberOfDice == 0 && modifier != 0) {
      return '$modifier';
    }

    final resultsStr = results.join(', ');
    String result = '${numberOfDice}d$sides ($resultsStr)';

    if (modifier > 0) {
      result += ' +$modifier';
    } else if (modifier < 0) {
      result += ' $modifier';
    }

    return result;
  }
}

class DiceRoller {
  final Random _random = Random();

  /// Rola dados baseado em uma fórmula (ex: "1d20+5", "2d6+1d8", "3d10")
  DiceRollResult roll(String formula) {
    try {
      // Remove espaços
      formula = formula.replaceAll(' ', '');

      // Divide a fórmula em termos (ex: "1d20+5+2d6" -> ["1d20", "5", "2d6"])
      final terms = _parseFormula(formula);

      final List<DiceRoll> rolls = [];
      int totalSum = 0;

      for (final term in terms) {
        final roll = _rollTerm(term);
        rolls.add(roll);
        totalSum += roll.total;
      }

      return DiceRollResult(
        rolls: rolls,
        total: totalSum,
      );
    } catch (e) {
      throw Exception('Fórmula inválida: $formula. Erro: $e');
    }
  }

  /// Rola dano crítico (multiplica o resultado)
  DiceRollResult rollCritical(String formula, int multiplier) {
    final normalRoll = roll(formula);
    final criticalTotal = normalRoll.total * multiplier;

    return DiceRollResult(
      rolls: normalRoll.rolls,
      total: criticalTotal,
    );
  }

  /// Divide a fórmula em termos individuais
  List<String> _parseFormula(String formula) {
    final List<String> terms = [];
    String currentTerm = '';
    bool isNegative = false;

    for (int i = 0; i < formula.length; i++) {
      final char = formula[i];

      if (char == '+' || (char == '-' && i > 0)) {
        if (currentTerm.isNotEmpty) {
          if (isNegative) {
            currentTerm = '-$currentTerm';
          }
          terms.add(currentTerm);
          currentTerm = '';
        }
        isNegative = char == '-';
      } else {
        currentTerm += char;
      }
    }

    if (currentTerm.isNotEmpty) {
      if (isNegative) {
        currentTerm = '-$currentTerm';
      }
      terms.add(currentTerm);
    }

    return terms;
  }

  /// Rola um termo individual (ex: "1d20", "5", "2d6")
  DiceRoll _rollTerm(String term) {
    // Se for apenas um número (modificador)
    if (!term.contains('d')) {
      final modifier = int.parse(term);
      return DiceRoll(
        numberOfDice: 0,
        sides: 0,
        results: [],
        modifier: modifier,
      );
    }

    // Parse da notação XdY (ex: 2d6)
    final parts = term.split('d');
    final numberOfDice = int.parse(parts[0]);
    final sides = int.parse(parts[1]);

    // Rola os dados
    final results = List.generate(
      numberOfDice,
      (_) => _random.nextInt(sides) + 1,
    );

    return DiceRoll(
      numberOfDice: numberOfDice,
      sides: sides,
      results: results,
    );
  }

  /// Verifica se uma fórmula é válida
  bool isValidFormula(String formula) {
    try {
      formula = formula.replaceAll(' ', '');

      // Regex para validar fórmulas de dados
      final dicePattern = RegExp(r'^\d+d\d+([+-]\d+d\d+)*([+-]\d+)?$');
      return dicePattern.hasMatch(formula);
    } catch (e) {
      return false;
    }
  }
}

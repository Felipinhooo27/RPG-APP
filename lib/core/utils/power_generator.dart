import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../models/character.dart';
import '../../models/power.dart';
import 'power_templates.dart';
import 'nex_progression.dart';

/// Gerador de poderes iniciais para personagens
///
/// Gera poderes paranormais baseados em:
/// - Classe (Combatente, Especialista, Ocultista)
/// - NEX (quantidade e poder dos poderes)
/// - Elemento (opcional - foca em um elemento específico)
class PowerGenerator {
  final Random _random = Random();
  final Uuid _uuid = const Uuid();

  /// Gera poderes iniciais para um personagem
  ///
  /// [characterId] - ID do personagem
  /// [classe] - Classe do personagem
  /// [nex] - NEX do personagem (5-99)
  /// [elementoPreferido] - Elemento preferido (opcional). Se null, distribui entre elementos.
  /// [useRandom] - Se true, adiciona variedade aleatória. Se false, usa poderes padrão.
  /// [includeRituals] - Se true, inclui rituais no kit (padrão: true)
  List<Power> generateStartingPowers({
    required String characterId,
    required CharacterClass classe,
    required int nex,
    ElementoOutroLado? elementoPreferido,
    bool useRandom = true,
    bool includeRituals = true,
  }) {
    final powers = <Power>[];
    final powerCount = NexProgression.getRecommendedPowerCount(nex, classe);
    final maxCirculo = NexProgression.getMaxCirculo(nex);

    // Se NEX muito baixo ou Combatente tier 1-2, pode não ter poderes
    if (powerCount == 0) {
      return powers;
    }

    // Filtra templates disponíveis para o NEX e classe
    final availablePowers = PowerTemplateDatabase.getPowersForClass(
      classe,
      nex,
      elemento: elementoPreferido,
    );

    final availableRituals = includeRituals && maxCirculo > 0
        ? PowerTemplateDatabase.getRitualsForClass(
            classe,
            nex,
            elemento: elementoPreferido,
          )
        : <PowerTemplate>[];

    // Calcula distribuição entre poderes e rituais
    final ritualCount = _calculateRitualCount(powerCount, maxCirculo);
    final regularPowerCount = powerCount - ritualCount;

    // Gera poderes regulares
    if (elementoPreferido != null) {
      // Foca em um elemento
      powers.addAll(_generatePowersForElemento(
        characterId,
        elementoPreferido,
        regularPowerCount,
        availablePowers,
        useRandom,
      ));
    } else {
      // Distribui entre elementos
      powers.addAll(_generateDistributedPowers(
        characterId,
        regularPowerCount,
        availablePowers,
        useRandom,
      ));
    }

    // Gera rituais
    if (ritualCount > 0 && availableRituals.isNotEmpty) {
      powers.addAll(_generateRituals(
        characterId,
        ritualCount,
        maxCirculo,
        availableRituals,
        elementoPreferido,
        useRandom,
      ));
    }

    return powers;
  }

  /// Calcula quantos rituais devem ser incluídos
  int _calculateRitualCount(int totalPowerCount, int maxCirculo) {
    if (maxCirculo == 0) return 0;

    // Rituais são ~25-40% dos poderes
    final ritualRatio = 0.25 + (_random.nextDouble() * 0.15); // 25-40%
    return (totalPowerCount * ritualRatio).ceil().clamp(0, totalPowerCount);
  }

  /// Gera poderes focados em um elemento específico
  List<Power> _generatePowersForElemento(
    String characterId,
    ElementoOutroLado elemento,
    int count,
    List<PowerTemplate> availablePowers,
    bool useRandom,
  ) {
    final powers = <Power>[];
    final elementoPowers = availablePowers
        .where((p) => p.elemento == elemento && !p.isRitual)
        .toList();

    if (elementoPowers.isEmpty) return powers;

    // Seleciona poderes (evita duplicatas)
    final selectedTemplates = <PowerTemplate>[];
    for (int i = 0; i < count && elementoPowers.isNotEmpty; i++) {
      PowerTemplate template;

      if (useRandom) {
        // Remove templates já selecionados
        final available = elementoPowers
            .where((p) => !selectedTemplates.contains(p))
            .toList();
        if (available.isEmpty) break;

        template = available[_random.nextInt(available.length)];
      } else {
        // Seleciona em ordem de NEX mínimo (mais fracos primeiro)
        final available = elementoPowers
            .where((p) => !selectedTemplates.contains(p))
            .toList();
        if (available.isEmpty) break;

        available.sort((a, b) => a.nivelMinimo.compareTo(b.nivelMinimo));
        template = available.first;
      }

      selectedTemplates.add(template);
      powers.add(_createPowerFromTemplate(template, characterId));
    }

    return powers;
  }

  /// Gera poderes distribuídos entre múltiplos elementos
  List<Power> _generateDistributedPowers(
    String characterId,
    int count,
    List<PowerTemplate> availablePowers,
    bool useRandom,
  ) {
    final powers = <Power>[];
    final regularPowers = availablePowers.where((p) => !p.isRitual).toList();

    if (regularPowers.isEmpty) return powers;

    // Distribui entre elementos
    final elementos = ElementoOutroLado.values;
    final selectedTemplates = <PowerTemplate>[];

    for (int i = 0; i < count; i++) {
      PowerTemplate? template;

      if (useRandom) {
        // Tenta balancear elementos
        final currentElementoCounts = _countElementos(selectedTemplates);
        final leastUsedElemento = _getLeastUsedElemento(currentElementoCounts);

        // 70% chance de usar elemento menos usado, 30% qualquer um
        if (_random.nextDouble() < 0.7) {
          final elementoPowers = regularPowers
              .where((p) =>
                  p.elemento == leastUsedElemento &&
                  !selectedTemplates.contains(p))
              .toList();

          if (elementoPowers.isNotEmpty) {
            template = elementoPowers[_random.nextInt(elementoPowers.length)];
          }
        }

        // Fallback: qualquer poder disponível
        if (template == null) {
          final available = regularPowers
              .where((p) => !selectedTemplates.contains(p))
              .toList();
          if (available.isEmpty) break;

          template = available[_random.nextInt(available.length)];
        }
      } else {
        // Modo determinístico: um poder de cada elemento em ordem
        final elemento = elementos[i % elementos.length];
        final elementoPowers = regularPowers
            .where((p) =>
                p.elemento == elemento && !selectedTemplates.contains(p))
            .toList();

        if (elementoPowers.isEmpty) {
          // Fallback para qualquer poder disponível
          final available = regularPowers
              .where((p) => !selectedTemplates.contains(p))
              .toList();
          if (available.isEmpty) break;

          elementoPowers.sort((a, b) => a.nivelMinimo.compareTo(b.nivelMinimo));
          template = available.first;
        } else {
          elementoPowers.sort((a, b) => a.nivelMinimo.compareTo(b.nivelMinimo));
          template = elementoPowers.first;
        }
      }

      if (template != null) {
        selectedTemplates.add(template);
        powers.add(_createPowerFromTemplate(template, characterId));
      }
    }

    return powers;
  }

  /// Gera rituais baseados nos círculos disponíveis
  List<Power> _generateRituals(
    String characterId,
    int count,
    int maxCirculo,
    List<PowerTemplate> availableRituals,
    ElementoOutroLado? elementoPreferido,
    bool useRandom,
  ) {
    final powers = <Power>[];
    final selectedTemplates = <PowerTemplate>[];

    // Filtra rituais por círculos disponíveis
    final validRituals = availableRituals
        .where((r) => r.circulo != null && r.circulo! <= maxCirculo)
        .toList();

    if (validRituals.isEmpty) return powers;

    for (int i = 0; i < count; i++) {
      PowerTemplate? template;

      if (useRandom) {
        // Prefere círculos mais baixos (mais acessíveis)
        final circleWeights = _calculateCircleWeights(maxCirculo);
        final targetCircle = _selectWeightedCircle(circleWeights);

        var circleRituals = validRituals
            .where((r) =>
                r.circulo == targetCircle && !selectedTemplates.contains(r))
            .toList();

        // Fallback: qualquer círculo disponível
        if (circleRituals.isEmpty) {
          circleRituals = validRituals
              .where((r) => !selectedTemplates.contains(r))
              .toList();
        }

        if (circleRituals.isEmpty) break;

        template = circleRituals[_random.nextInt(circleRituals.length)];
      } else {
        // Modo determinístico: círculos em ordem crescente
        final available = validRituals
            .where((r) => !selectedTemplates.contains(r))
            .toList();

        if (available.isEmpty) break;

        // Ordena por círculo e NEX
        available.sort((a, b) {
          final circleCompare = (a.circulo ?? 0).compareTo(b.circulo ?? 0);
          if (circleCompare != 0) return circleCompare;
          return a.nivelMinimo.compareTo(b.nivelMinimo);
        });

        template = available.first;
      }

      if (template != null) {
        selectedTemplates.add(template);
        powers.add(_createPowerFromTemplate(template, characterId));
      }
    }

    return powers;
  }

  // ========== HELPERS ==========

  /// Conta quantos poderes de cada elemento foram selecionados
  Map<ElementoOutroLado, int> _countElementos(List<PowerTemplate> templates) {
    final counts = <ElementoOutroLado, int>{};

    for (final elemento in ElementoOutroLado.values) {
      counts[elemento] = templates.where((t) => t.elemento == elemento).length;
    }

    return counts;
  }

  /// Retorna o elemento menos usado
  ElementoOutroLado _getLeastUsedElemento(
      Map<ElementoOutroLado, int> counts) {
    var minCount = double.infinity.toInt();
    var leastUsed = ElementoOutroLado.conhecimento;

    counts.forEach((elemento, count) {
      if (count < minCount) {
        minCount = count;
        leastUsed = elemento;
      }
    });

    return leastUsed;
  }

  /// Calcula pesos para seleção de círculos (círculos baixos têm mais peso)
  Map<int, double> _calculateCircleWeights(int maxCirculo) {
    final weights = <int, double>{};
    double totalWeight = 0;

    for (int circle = 1; circle <= maxCirculo; circle++) {
      // Círculos mais baixos têm peso maior
      final weight = 1.0 / circle;
      weights[circle] = weight;
      totalWeight += weight;
    }

    // Normaliza para somar 1.0
    weights.forEach((circle, weight) {
      weights[circle] = weight / totalWeight;
    });

    return weights;
  }

  /// Seleciona um círculo baseado em pesos
  int _selectWeightedCircle(Map<int, double> weights) {
    final rand = _random.nextDouble();
    double cumulative = 0;

    for (final entry in weights.entries) {
      cumulative += entry.value;
      if (rand <= cumulative) {
        return entry.key;
      }
    }

    return weights.keys.first; // Fallback
  }

  /// Cria um Power a partir de um PowerTemplate
  Power _createPowerFromTemplate(PowerTemplate template, String characterId) {
    return Power(
      id: _uuid.v4(),
      characterId: characterId,
      nome: template.nome,
      descricao: template.descricao,
      elemento: template.elemento,
      custoPE: template.custoPE,
      nivelMinimo: template.nivelMinimo,
      efeitos: template.efeitos,
      duracao: template.duracao,
      alcance: template.alcance,
      circulo: template.circulo,
    );
  }

  /// Gera um poder aleatório para uma classe e NEX
  Power? generateRandomPower({
    required String characterId,
    required CharacterClass classe,
    required int nex,
    ElementoOutroLado? elemento,
    bool includeRituals = true,
  }) {
    final powers = generateStartingPowers(
      characterId: characterId,
      classe: classe,
      nex: nex,
      elementoPreferido: elemento,
      useRandom: true,
      includeRituals: includeRituals,
    );

    return powers.isNotEmpty ? powers.first : null;
  }

  /// Gera um ritual específico de um círculo
  Power? generateRitualByCirculo({
    required String characterId,
    required int circulo,
    required int nex,
    ElementoOutroLado? elemento,
  }) {
    final maxCirculo = NexProgression.getMaxCirculo(nex);

    if (circulo > maxCirculo) {
      return null; // NEX insuficiente para este círculo
    }

    final rituals = PowerTemplateDatabase.getByCirculo(circulo)
        .where((r) => r.nivelMinimo <= nex)
        .toList();

    if (elemento != null) {
      final elementRituals = rituals.where((r) => r.elemento == elemento).toList();
      if (elementRituals.isNotEmpty) {
        final template = elementRituals[_random.nextInt(elementRituals.length)];
        return _createPowerFromTemplate(template, characterId);
      }
    }

    if (rituals.isEmpty) return null;

    final template = rituals[_random.nextInt(rituals.length)];
    return _createPowerFromTemplate(template, characterId);
  }
}

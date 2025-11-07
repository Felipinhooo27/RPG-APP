import 'dart:math';

/// Sistema de geração inteligente de perícias baseado na categoria do personagem
class SkillGenerator {
  static final Random _random = Random();

  // Lista de todas as perícias disponíveis no sistema
  static const List<String> _allSkills = [
    'Acrobacia',
    'Adestramento',
    'Artes',
    'Atletismo',
    'Atualidades',
    'Ciências',
    'Crime',
    'Diplomacia',
    'Enganação',
    'Fortitude',
    'Furtividade',
    'Iniciativa',
    'Intimidação',
    'Intuição',
    'Investigação',
    'Luta',
    'Medicina',
    'Ocultismo',
    'Percepção',
    'Pilotagem',
    'Pontaria',
    'Profissão',
    'Reflexos',
    'Religião',
    'Sobrevivência',
    'Táti ca',
    'Tecnologia',
    'Vontade',
  ];

  // Perícias recomendadas por categoria de personagem
  static const Map<String, List<String>> _categorySkills = {
    'Civil': [
      'Diplomacia',
      'Profissão',
      'Atualidades',
      'Tecnologia',
      'Artes',
    ],
    'Mercenário': [
      'Luta',
      'Pontaria',
      'Atletismo',
      'Intimidação',
      'Furtividade',
      'Fortitude',
      'Reflexos',
    ],
    'Soldado': [
      'Pontaria',
      'Luta',
      'Atletismo',
      'Fortitude',
      'Tática',
      'Iniciativa',
      'Percepção',
    ],
    'Chefe': [
      'Intimidação',
      'Luta',
      'Diplomacia',
      'Profissão',
      'Percepção',
      'Intuição',
    ],
    'Líder': [
      'Diplomacia',
      'Tática',
      'Intuição',
      'Liderança',
      'Persuasão',
      'Intimidação',
      'Percepção',
    ],
    'Profissional': [
      'Investigação',
      'Ocultismo',
      'Ciências',
      'Medicina',
      'Tecnologia',
      'Percepção',
      'Intuição',
      'Pontaria',
      'Vontade',
    ],
    'Deus': [
      'Ocultismo',
      'Vontade',
      'Intuição',
      'Percepção',
      'Investigação',
      'Medicina',
      'Luta',
      'Pontaria',
      'Diplomacia',
      'Intimidação',
      'Fortitude',
      'Reflexos',
      'Iniciativa',
      'Tática',
    ],
  };

  /// Estrutura de retorno com perícias treinadas em cada nível
  static Map<String, String> generateSkills(String category) {
    final trainedSkills = <String, String>{};

    // Define quantas perícias cada categoria tem baseado no "nível de poder"
    int trainedCount = 0;
    int veteranCount = 0;
    int expertCount = 0;

    switch (category) {
      case 'Civil':
        // Civis: 1-2 perícias treinadas em sua profissão
        trainedCount = 1 + _random.nextInt(2); // 1-2
        break;

      case 'Mercenário':
        // Mercenários: 2-3 treinadas, foco em combate
        trainedCount = 2 + _random.nextInt(2); // 2-3
        break;

      case 'Soldado':
        // Soldados: 2-4 treinadas, pode ter 1 veterano
        trainedCount = 2 + _random.nextInt(3); // 2-4
        if (_random.nextDouble() < 0.3) {
          veteranCount = 1;
        }
        break;

      case 'Chefe':
        // Chefes: 3-4 treinadas, 1 veterano
        trainedCount = 3 + _random.nextInt(2); // 3-4
        veteranCount = 1;
        break;

      case 'Líder':
        // Líderes: 4-6 treinadas, 1-2 veterano, 20% chance de 1 expert
        trainedCount = 4 + _random.nextInt(3); // 4-6
        veteranCount = 1 + _random.nextInt(2); // 1-2
        if (_random.nextDouble() < 0.2) {
          expertCount = 1;
        }
        break;

      case 'Profissional':
        // Profissionais: 5-8 treinadas, 2-3 veterano, 1 expert
        trainedCount = 5 + _random.nextInt(4); // 5-8
        veteranCount = 2 + _random.nextInt(2); // 2-3
        expertCount = 1;
        break;

      case 'Deus':
        // Deuses: 10-15 treinadas, 5-8 veterano, 3-5 expert
        trainedCount = 10 + _random.nextInt(6); // 10-15
        veteranCount = 5 + _random.nextInt(4); // 5-8
        expertCount = 3 + _random.nextInt(3); // 3-5
        break;
    }

    // Obter lista de perícias recomendadas para esta categoria
    final recommendedSkills = _categorySkills[category] ?? [];
    final availableSkills = List<String>.from(recommendedSkills);

    // Se não houver perícias recomendadas suficientes, adicionar aleatórias
    final otherSkills = _allSkills.where((s) => !recommendedSkills.contains(s)).toList();
    availableSkills.addAll(otherSkills);

    // Embaralhar para aleatoriedade
    availableSkills.shuffle(_random);

    // Primeiro, atribuir perícias de expert (mais raras)
    int index = 0;
    for (int i = 0; i < expertCount && index < availableSkills.length; i++) {
      trainedSkills[availableSkills[index]] = 'expert';
      index++;
    }

    // Depois, atribuir perícias veterano
    for (int i = 0; i < veteranCount && index < availableSkills.length; i++) {
      trainedSkills[availableSkills[index]] = 'veterano';
      index++;
    }

    // Por último, atribuir perícias treinadas
    for (int i = 0; i < trainedCount && index < availableSkills.length; i++) {
      trainedSkills[availableSkills[index]] = 'treinado';
      index++;
    }

    return trainedSkills;
  }

  /// Retorna lista de perícias com níveis de treinamento formatados
  static String getSkillsSummary(Map<String, String> skills) {
    if (skills.isEmpty) return 'Nenhuma perícia treinada';

    final experts = skills.entries.where((e) => e.value == 'expert').map((e) => e.key).toList();
    final veterans = skills.entries.where((e) => e.value == 'veterano').map((e) => e.key).toList();
    final trained = skills.entries.where((e) => e.value == 'treinado').map((e) => e.key).toList();

    final summary = <String>[];

    if (experts.isNotEmpty) {
      summary.add('Expert: ${experts.join(", ")}');
    }
    if (veterans.isNotEmpty) {
      summary.add('Veterano: ${veterans.join(", ")}');
    }
    if (trained.isNotEmpty) {
      summary.add('Treinado: ${trained.join(", ")}');
    }

    return summary.join('\n');
  }

  /// Retorna o bônus numérico de uma perícia
  static int getSkillBonus(String level) {
    switch (level) {
      case 'expert':
        return 15;
      case 'veterano':
        return 10;
      case 'treinado':
        return 5;
      default:
        return 0; // Não treinado
    }
  }

  /// Gera uma perícia aleatória com nível aleatório
  static Map<String, String> getRandomSkill() {
    final skill = _allSkills[_random.nextInt(_allSkills.length)];
    final levels = ['treinado', 'veterano', 'expert'];
    final level = levels[_random.nextInt(levels.length)];

    return {skill: level};
  }

  /// Retorna descrição do sistema de perícias
  static String getSystemDescription() {
    return '''
Sistema de Perícias - Ordem Paranormal

Níveis de Treinamento:
• Não Treinado: +0
• Treinado: +5
• Veterano: +10
• Expert: +15

Distribuição por Categoria:
• Civil: 1-2 treinadas (profissão)
• Mercenário: 2-3 treinadas (combate)
• Soldado: 2-4 treinadas, 30% 1 veterano
• Chefe: 3-4 treinadas, 1 veterano
• Líder: 4-6 treinadas, 1-2 veterano, 20% 1 expert
• Profissional: 5-8 treinadas, 2-3 veterano, 1 expert
• Deus: 10-15 treinadas, 5-8 veterano, 3-5 expert
    ''';
  }

  /// Retorna contagem de perícias por categoria
  static Map<String, int> getSkillCountByCategory(String category) {
    switch (category) {
      case 'Civil':
        return {'treinado': 2, 'veterano': 0, 'expert': 0};
      case 'Mercenário':
        return {'treinado': 3, 'veterano': 0, 'expert': 0};
      case 'Soldado':
        return {'treinado': 3, 'veterano': 1, 'expert': 0};
      case 'Chefe':
        return {'treinado': 4, 'veterano': 1, 'expert': 0};
      case 'Líder':
        return {'treinado': 5, 'veterano': 2, 'expert': 1};
      case 'Profissional':
        return {'treinado': 6, 'veterano': 3, 'expert': 1};
      case 'Deus':
        return {'treinado': 12, 'veterano': 6, 'expert': 4};
      default:
        return {'treinado': 0, 'veterano': 0, 'expert': 0};
    }
  }
}

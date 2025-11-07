/// Modelo de Perícia (Skill) - Sistema Ordem Paranormal
class Skill {
  final String name;
  final SkillCategory category;
  final SkillLevel level;
  final String? attribute; // FOR, AGI, INT, PRE, VIG

  const Skill({
    required this.name,
    required this.category,
    this.level = SkillLevel.untrained,
    this.attribute,
  });

  /// Calcula o bônus total da perícia (atributo + treinamento)
  int getBonus(int attributeModifier) {
    int bonus = attributeModifier;

    switch (level) {
      case SkillLevel.untrained:
        bonus += 0;
        break;
      case SkillLevel.trained:
        bonus += 5;
        break;
      case SkillLevel.veteran:
        bonus += 10;
        break;
      case SkillLevel.expert:
        bonus += 15;
        break;
    }

    return bonus;
  }

  /// Retorna APENAS o bônus de treinamento (sem modificador de atributo)
  /// Usado para exibição no grimório
  int getTrainingBonusOnly() {
    switch (level) {
      case SkillLevel.untrained:
        return 0;
      case SkillLevel.trained:
        return 5;
      case SkillLevel.veteran:
        return 10;
      case SkillLevel.expert:
        return 15;
    }
  }

  /// Serialização
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category.toString().split('.').last,
      'level': level.toString().split('.').last,
      'attribute': attribute,
    };
  }

  /// Desserialização
  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      name: map['name'] ?? '',
      category: SkillCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => SkillCategory.combat,
      ),
      level: SkillLevel.values.firstWhere(
        (e) => e.toString().split('.').last == map['level'],
        orElse: () => SkillLevel.untrained,
      ),
      attribute: map['attribute'],
    );
  }

  Skill copyWith({
    String? name,
    SkillCategory? category,
    SkillLevel? level,
    String? attribute,
  }) {
    return Skill(
      name: name ?? this.name,
      category: category ?? this.category,
      level: level ?? this.level,
      attribute: attribute ?? this.attribute,
    );
  }
}

/// Categorias de Perícias
enum SkillCategory {
  combat,       // Combate
  investigation, // Investigação
  social,       // Social
  occult,       // Ocultismo
  survival,     // Sobrevivência
}

/// Níveis de Treinamento
enum SkillLevel {
  untrained, // Destreinado
  trained,   // Treinado (+5)
  veteran,   // Veterano (+10)
  expert,    // Expert (+15)
}

/// Perícias do Sistema Ordem Paranormal
class OrdemSkills {
  // Combate
  static const String fighting = 'Luta';
  static const String aim = 'Pontaria';
  static const String reflexes = 'Reflexos';

  // Investigação
  static const String investigation = 'Investigação';
  static const String perception = 'Percepção';
  static const String medicine = 'Medicina';
  static const String occultism = 'Ocultismo';
  static const String professionalism = 'Profissão';
  static const String technology = 'Tecnologia';

  // Social
  static const String diplomacy = 'Diplomacia';
  static const String deception = 'Enganação';
  static const String intimidation = 'Intimidação';
  static const String initiative = 'Iniciativa';
  static const String intuition = 'Intuição';
  static const String performance = 'Atuação';

  // Sobrevivência
  static const String athletics = 'Atletismo';
  static const String stealth = 'Furtividade';
  static const String piloting = 'Pilotagem';
  static const String survival = 'Sobrevivência';
  static const String animalHandling = 'Adestramento';

  /// Lista completa de perícias com suas categorias e atributos
  static final Map<String, Map<String, String>> allSkills = {
    // Combate
    fighting: {'category': 'combat', 'attribute': 'FOR'},
    aim: {'category': 'combat', 'attribute': 'AGI'},
    reflexes: {'category': 'combat', 'attribute': 'AGI'},

    // Investigação
    investigation: {'category': 'investigation', 'attribute': 'INT'},
    perception: {'category': 'investigation', 'attribute': 'PRE'},
    medicine: {'category': 'investigation', 'attribute': 'INT'},
    occultism: {'category': 'investigation', 'attribute': 'INT'},
    professionalism: {'category': 'investigation', 'attribute': 'INT'},
    technology: {'category': 'investigation', 'attribute': 'INT'},

    // Social
    diplomacy: {'category': 'social', 'attribute': 'PRE'},
    deception: {'category': 'social', 'attribute': 'PRE'},
    intimidation: {'category': 'social', 'attribute': 'PRE'},
    initiative: {'category': 'social', 'attribute': 'PRE'},
    intuition: {'category': 'social', 'attribute': 'PRE'},
    performance: {'category': 'social', 'attribute': 'PRE'},

    // Sobrevivência
    athletics: {'category': 'survival', 'attribute': 'FOR'},
    stealth: {'category': 'survival', 'attribute': 'AGI'},
    piloting: {'category': 'survival', 'attribute': 'AGI'},
    survival: {'category': 'survival', 'attribute': 'INT'},
    animalHandling: {'category': 'survival', 'attribute': 'PRE'},
  };

  /// Retorna todas as perícias de uma categoria
  static List<String> getSkillsByCategory(SkillCategory category) {
    final categoryName = category.toString().split('.').last;
    return allSkills.entries
        .where((e) => e.value['category'] == categoryName)
        .map((e) => e.key)
        .toList();
  }

  /// Retorna o atributo principal de uma perícia
  static String getSkillAttribute(String skillName) {
    return allSkills[skillName]?['attribute'] ?? 'INT';
  }
}

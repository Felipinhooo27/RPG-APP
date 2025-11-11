/// Model de Conquista (Achievement)
/// Sistema de gamificação para engajar jogadores
class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final int requiredValue;
  final String iconCode; // Unicode ou asset path
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.requiredValue,
    required this.iconCode,
    this.xpReward = 100,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: AchievementCategoryExtension.fromString(map['category'] ?? 'geral'),
      requiredValue: map['requiredValue'] ?? 1,
      iconCode: map['iconCode'] ?? '🏆',
      xpReward: map['xpReward'] ?? 100,
      isUnlocked: map['isUnlocked'] ?? false,
      unlockedAt: map['unlockedAt'] != null
          ? DateTime.parse(map['unlockedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.value,
      'requiredValue': requiredValue,
      'iconCode': iconCode,
      'xpReward': xpReward,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      category: category,
      requiredValue: requiredValue,
      iconCode: iconCode,
      xpReward: xpReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

enum AchievementCategory {
  combate,
  exploracao,
  social,
  progressao,
  colecao,
  geral,
}

extension AchievementCategoryExtension on AchievementCategory {
  String get value {
    switch (this) {
      case AchievementCategory.combate:
        return 'combate';
      case AchievementCategory.exploracao:
        return 'exploracao';
      case AchievementCategory.social:
        return 'social';
      case AchievementCategory.progressao:
        return 'progressao';
      case AchievementCategory.colecao:
        return 'colecao';
      case AchievementCategory.geral:
        return 'geral';
    }
  }

  String get label {
    switch (this) {
      case AchievementCategory.combate:
        return 'Combate';
      case AchievementCategory.exploracao:
        return 'Exploração';
      case AchievementCategory.social:
        return 'Social';
      case AchievementCategory.progressao:
        return 'Progressão';
      case AchievementCategory.colecao:
        return 'Coleção';
      case AchievementCategory.geral:
        return 'Geral';
    }
  }

  static AchievementCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'combate':
        return AchievementCategory.combate;
      case 'exploracao':
        return AchievementCategory.exploracao;
      case 'social':
        return AchievementCategory.social;
      case 'progressao':
        return AchievementCategory.progressao;
      case 'colecao':
        return AchievementCategory.colecao;
      default:
        return AchievementCategory.geral;
    }
  }
}

/// Conquistas pré-definidas do jogo
class DefaultAchievements {
  static List<Achievement> get all => [
        // PROGRESSÃO
        Achievement(
          id: 'first_character',
          title: 'Primeiro Agente',
          description: 'Crie seu primeiro personagem',
          category: AchievementCategory.progressao,
          requiredValue: 1,
          iconCode: '👤',
          xpReward: 50,
        ),
        Achievement(
          id: 'nex_10',
          title: 'Operador',
          description: 'Alcance NEX 10%',
          category: AchievementCategory.progressao,
          requiredValue: 10,
          iconCode: '⭐',
          xpReward: 100,
        ),
        Achievement(
          id: 'nex_50',
          title: 'Agente Especial',
          description: 'Alcance NEX 50%',
          category: AchievementCategory.progressao,
          requiredValue: 50,
          iconCode: '💫',
          xpReward: 200,
        ),
        Achievement(
          id: 'nex_99',
          title: 'Lenda Paranormal',
          description: 'Alcance NEX 99%',
          category: AchievementCategory.progressao,
          requiredValue: 99,
          iconCode: '👑',
          xpReward: 500,
        ),

        // COMBATE
        Achievement(
          id: 'first_combat',
          title: 'Batismo de Fogo',
          description: 'Participe de seu primeiro combate',
          category: AchievementCategory.combate,
          requiredValue: 1,
          iconCode: '⚔️',
          xpReward: 75,
        ),
        Achievement(
          id: 'survivor',
          title: 'Sobrevivente',
          description: 'Sobreviva a 10 combates',
          category: AchievementCategory.combate,
          requiredValue: 10,
          iconCode: '🛡️',
          xpReward: 150,
        ),
        Achievement(
          id: 'near_death',
          title: 'Quase Lá',
          description: 'Fique com 1 PV e sobreviva',
          category: AchievementCategory.combate,
          requiredValue: 1,
          iconCode: '💀',
          xpReward: 100,
        ),

        // COLEÇÃO
        Achievement(
          id: 'first_purchase',
          title: 'Primeira Compra',
          description: 'Compre seu primeiro item na loja',
          category: AchievementCategory.colecao,
          requiredValue: 1,
          iconCode: '🛒',
          xpReward: 50,
        ),
        Achievement(
          id: 'collector',
          title: 'Colecionador',
          description: 'Possua 20 itens no inventário',
          category: AchievementCategory.colecao,
          requiredValue: 20,
          iconCode: '📦',
          xpReward: 150,
        ),
        Achievement(
          id: 'rich',
          title: 'Magnata',
          description: 'Acumule 10.000 créditos',
          category: AchievementCategory.colecao,
          requiredValue: 10000,
          iconCode: '💰',
          xpReward: 200,
        ),

        // EXPLORAÇÃO
        Achievement(
          id: 'all_classes',
          title: 'Mestre de Todas',
          description: 'Crie personagens de todas as 3 classes',
          category: AchievementCategory.exploracao,
          requiredValue: 3,
          iconCode: '🎓',
          xpReward: 250,
        ),
        Achievement(
          id: 'all_origins',
          title: 'Diversidade',
          description: 'Crie personagens de 10 origens diferentes',
          category: AchievementCategory.exploracao,
          requiredValue: 10,
          iconCode: '🌍',
          xpReward: 300,
        ),

        // SOCIAL
        Achievement(
          id: 'first_session',
          title: 'Primeira Sessão',
          description: 'Complete sua primeira sessão',
          category: AchievementCategory.social,
          requiredValue: 1,
          iconCode: '🎭',
          xpReward: 100,
        ),
        Achievement(
          id: 'veteran_player',
          title: 'Veterano',
          description: 'Participe de 50 sessões',
          category: AchievementCategory.social,
          requiredValue: 50,
          iconCode: '🏅',
          xpReward: 500,
        ),

        // GERAL
        Achievement(
          id: 'full_stats',
          title: 'Perfeição',
          description: 'Tenha todos os atributos no máximo (5)',
          category: AchievementCategory.geral,
          requiredValue: 25, // 5 atributos x 5
          iconCode: '✨',
          xpReward: 300,
        ),
        Achievement(
          id: 'max_hp',
          title: 'Tanque',
          description: 'Alcance 100 PV máximo',
          category: AchievementCategory.geral,
          requiredValue: 100,
          iconCode: '❤️',
          xpReward: 150,
        ),
        Achievement(
          id: 'paranormal',
          title: 'Ocultista Supremo',
          description: 'Aprenda 10 rituais paranormais',
          category: AchievementCategory.geral,
          requiredValue: 10,
          iconCode: '🔮',
          xpReward: 250,
        ),
      ];
}

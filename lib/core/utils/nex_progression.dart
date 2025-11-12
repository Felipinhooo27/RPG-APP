import '../../models/character.dart';

/// Utilitário para gerenciar a progressão de NEX
///
/// Define os marcos de progressão do sistema Ordem Paranormal:
/// - Círculos de rituais desbloqueados
/// - Créditos iniciais
/// - Pontos de atributo
/// - PV/PE/SAN base
class NexProgression {
  /// NEX levels válidos no sistema Ordem Paranormal
  static const List<int> validNexLevels = [
    5, 10, 20, 25, 35, 40, 50, 65, 70, 80, 95, 99
  ];

  /// Retorna o círculo máximo de ritual disponível para um NEX
  /// - NEX 5%: Sem rituais
  /// - NEX 10-24%: 1º Círculo
  /// - NEX 25-49%: 2º Círculo
  /// - NEX 50-69%: 3º Círculo
  /// - NEX 70%+: 4º Círculo
  static int getMaxCirculo(int nex) {
    if (nex < 10) return 0; // Sem rituais
    if (nex < 25) return 1; // 1º Círculo
    if (nex < 50) return 2; // 2º Círculo
    if (nex < 70) return 3; // 3º Círculo
    return 4; // 4º Círculo
  }

  /// Verifica se um personagem pode usar um ritual de determinado círculo
  static bool canUseCirculo(int nex, int circulo) {
    return circulo <= getMaxCirculo(nex);
  }

  /// Retorna créditos iniciais baseados no NEX
  /// Quanto maior o NEX, mais recursos o personagem tem
  static int getStartingCredits(int nex) {
    if (nex >= 99) return 50000; // Divino
    if (nex >= 95) return 35000; // Lendário
    if (nex >= 80) return 25000; // Veterano experiente
    if (nex >= 70) return 18000; // Veterano
    if (nex >= 65) return 12000; // Avançado superior
    if (nex >= 50) return 8000; // Avançado
    if (nex >= 40) return 5000; // Intermediário superior
    if (nex >= 35) return 3500; // Intermediário
    if (nex >= 25) return 2000; // Experiente
    if (nex >= 20) return 1200; // Iniciado
    if (nex >= 10) return 600; // Novato
    return 300; // Civil (NEX 5%)
  }

  /// Retorna a tier (nível de poder) baseada no NEX
  /// Usado para o sistema de 10 tiers do gerador unificado
  static int getTierFromNex(int nex) {
    if (nex >= 99) return 10; // Tier 10: Entidade Maior (Deus)
    if (nex >= 95) return 9; // Tier 9: Entidade Menor
    if (nex >= 80) return 8; // Tier 8: Lendário
    if (nex >= 70) return 7; // Tier 7: Veterano Experiente
    if (nex >= 65) return 6; // Tier 6: Veterano
    if (nex >= 50) return 5; // Tier 5: Avançado
    if (nex >= 35) return 4; // Tier 4: Intermediário
    if (nex >= 20) return 3; // Tier 3: Experiente
    if (nex >= 10) return 2; // Tier 2: Iniciado
    return 1; // Tier 1: Civil Iniciante
  }

  /// Retorna o NEX recomendado para uma tier
  static int getNexFromTier(int tier) {
    switch (tier) {
      case 1:
        return 5; // Civil Iniciante
      case 2:
        return 10; // Iniciado
      case 3:
        return 20; // Experiente
      case 4:
        return 35; // Intermediário
      case 5:
        return 50; // Avançado
      case 6:
        return 65; // Veterano
      case 7:
        return 70; // Veterano Experiente
      case 8:
        return 80; // Lendário
      case 9:
        return 95; // Entidade Menor
      case 10:
        return 99; // Entidade Maior (Deus)
      default:
        return 5;
    }
  }

  /// Retorna pontos de atributo disponíveis baseado na tier
  static int getAttributePoints(int tier) {
    switch (tier) {
      case 1:
        return 2; // Tier 1: 2 pontos
      case 2:
        return 3; // Tier 2: 3 pontos
      case 3:
        return 4; // Tier 3: 4 pontos
      case 4:
        return 5; // Tier 4: 5 pontos
      case 5:
        return 6; // Tier 5: 6 pontos
      case 6:
        return 7; // Tier 6: 7 pontos
      case 7:
        return 8; // Tier 7: 8 pontos
      case 8:
        return 9; // Tier 8: 9 pontos
      case 9:
        return 10; // Tier 9: 10 pontos
      case 10:
        return 12; // Tier 10: 12 pontos (divino)
      default:
        return 2;
    }
  }

  /// Retorna range de PV baseado na tier
  static PvRange getPvRange(int tier) {
    switch (tier) {
      case 1:
        return PvRange(min: 8, max: 12); // Civil
      case 2:
        return PvRange(min: 12, max: 18); // Iniciado
      case 3:
        return PvRange(min: 18, max: 25); // Experiente
      case 4:
        return PvRange(min: 25, max: 35); // Intermediário
      case 5:
        return PvRange(min: 35, max: 45); // Avançado
      case 6:
        return PvRange(min: 40, max: 55); // Veterano
      case 7:
        return PvRange(min: 50, max: 65); // Veterano Exp
      case 8:
        return PvRange(min: 60, max: 75); // Lendário
      case 9:
        return PvRange(min: 70, max: 85); // Entidade Menor
      case 10:
        return PvRange(min: 80, max: 100); // Deus
      default:
        return PvRange(min: 8, max: 12);
    }
  }

  /// Retorna range de PE baseado na tier
  static PeRange getPeRange(int tier) {
    switch (tier) {
      case 1:
        return PeRange(min: 1, max: 3); // Civil
      case 2:
        return PeRange(min: 3, max: 6); // Iniciado
      case 3:
        return PeRange(min: 6, max: 10); // Experiente
      case 4:
        return PeRange(min: 10, max: 15); // Intermediário
      case 5:
        return PeRange(min: 15, max: 22); // Avançado
      case 6:
        return PeRange(min: 20, max: 28); // Veterano
      case 7:
        return PeRange(min: 25, max: 35); // Veterano Exp
      case 8:
        return PeRange(min: 30, max: 42); // Lendário
      case 9:
        return PeRange(min: 35, max: 50); // Entidade Menor
      case 10:
        return PeRange(min: 40, max: 60); // Deus
      default:
        return PeRange(min: 1, max: 3);
    }
  }

  /// Retorna range de SAN baseado na tier
  static SanRange getSanRange(int tier) {
    switch (tier) {
      case 1:
        return SanRange(min: 12, max: 16); // Civil
      case 2:
        return SanRange(min: 16, max: 20); // Iniciado
      case 3:
        return SanRange(min: 18, max: 24); // Experiente
      case 4:
        return SanRange(min: 20, max: 28); // Intermediário
      case 5:
        return SanRange(min: 22, max: 32); // Avançado
      case 6:
        return SanRange(min: 24, max: 36); // Veterano
      case 7:
        return SanRange(min: 26, max: 40); // Veterano Exp
      case 8:
        return SanRange(min: 28, max: 44); // Lendário
      case 9:
        return SanRange(min: 30, max: 48); // Entidade Menor
      case 10:
        return SanRange(min: 32, max: 52); // Deus
      default:
        return SanRange(min: 12, max: 16);
    }
  }

  /// Retorna nome descritivo da tier
  static String getTierName(int tier) {
    switch (tier) {
      case 1:
        return 'Civil Iniciante';
      case 2:
        return 'Agente Recruta';
      case 3:
        return 'Agente Experiente';
      case 4:
        return 'Operador';
      case 5:
        return 'Especialista';
      case 6:
        return 'Veterano';
      case 7:
        return 'Elite';
      case 8:
        return 'Lendário';
      case 9:
        return 'Paranormal';
      case 10:
        return 'Entidade Maior';
      default:
        return 'Desconhecido';
    }
  }

  /// Retorna descrição da tier
  static String getTierDescription(int tier) {
    switch (tier) {
      case 1:
        return 'Pessoa comum exposta ao paranormal pela primeira vez';
      case 2:
        return 'Novato da Ordem, treinamento básico';
      case 3:
        return 'Agente com algumas missões completadas';
      case 4:
        return 'Operador de campo experiente';
      case 5:
        return 'Especialista em combate paranormal';
      case 6:
        return 'Veterano com anos de experiência';
      case 7:
        return 'Elite da Ordem, poucos chegam aqui';
      case 8:
        return 'Lenda viva, poder comparável a criaturas paranormais';
      case 9:
        return 'Mais paranormal que humano';
      case 10:
        return 'Poder divino, transcendeu a humanidade';
      default:
        return '';
    }
  }

  /// Calcula PV base para uma classe (antes de adicionar Vigor)
  static int getBasePvForClass(CharacterClass classe) {
    switch (classe) {
      case CharacterClass.combatente:
        return 20;
      case CharacterClass.especialista:
        return 16;
      case CharacterClass.ocultista:
        return 12;
    }
  }

  /// Calcula PE base para uma classe (antes de adicionar Presença)
  static int getBasePeForClass(CharacterClass classe) {
    switch (classe) {
      case CharacterClass.combatente:
        return 2;
      case CharacterClass.especialista:
        return 3;
      case CharacterClass.ocultista:
        return 5;
    }
  }

  /// Calcula SAN base para uma classe
  static int getBaseSanForClass(CharacterClass classe) {
    switch (classe) {
      case CharacterClass.combatente:
        return 12;
      case CharacterClass.especialista:
        return 16;
      case CharacterClass.ocultista:
        return 20;
    }
  }

  /// Retorna número recomendado de itens iniciais baseado no NEX
  static int getRecommendedItemCount(int nex) {
    final tier = getTierFromNex(nex);
    if (tier <= 2) return 3; // Tier 1-2: 3 itens
    if (tier <= 4) return 5; // Tier 3-4: 5 itens
    if (tier <= 6) return 7; // Tier 5-6: 7 itens
    if (tier <= 8) return 10; // Tier 7-8: 10 itens
    return 15; // Tier 9-10: 15 itens
  }

  /// Retorna número recomendado de poderes iniciais baseado no NEX e classe
  static int getRecommendedPowerCount(int nex, CharacterClass classe) {
    final tier = getTierFromNex(nex);

    // Combatente tem menos poderes
    if (classe == CharacterClass.combatente) {
      if (tier <= 2) return 0; // Tier 1-2: nenhum poder
      if (tier <= 4) return 1; // Tier 3-4: 1 poder
      if (tier <= 6) return 2; // Tier 5-6: 2 poderes
      if (tier <= 8) return 3; // Tier 7-8: 3 poderes
      return 4; // Tier 9-10: 4 poderes
    }

    // Especialista tem quantidade média
    if (classe == CharacterClass.especialista) {
      if (tier <= 2) return 1; // Tier 1-2: 1 poder
      if (tier <= 4) return 2; // Tier 3-4: 2 poderes
      if (tier <= 6) return 3; // Tier 5-6: 3 poderes
      if (tier <= 8) return 5; // Tier 7-8: 5 poderes
      return 7; // Tier 9-10: 7 poderes
    }

    // Ocultista tem mais poderes
    if (tier <= 2) return 2; // Tier 1-2: 2 poderes
    if (tier <= 4) return 4; // Tier 3-4: 4 poderes
    if (tier <= 6) return 6; // Tier 5-6: 6 poderes
    if (tier <= 8) return 8; // Tier 7-8: 8 poderes
    return 12; // Tier 9-10: 12 poderes
  }

  /// Verifica se um NEX é válido
  static bool isValidNex(int nex) {
    return nex >= 5 && nex <= 99;
  }

  /// Retorna o próximo NEX válido mais próximo
  static int getClosestValidNex(int nex) {
    if (nex <= 5) return 5;
    if (nex >= 99) return 99;

    // Encontra o NEX válido mais próximo
    int closest = validNexLevels[0];
    int minDiff = (nex - closest).abs();

    for (final validNex in validNexLevels) {
      final diff = (nex - validNex).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = validNex;
      }
    }

    return closest;
  }
}

/// Range de PV para uma tier
class PvRange {
  final int min;
  final int max;

  const PvRange({required this.min, required this.max});

  int get average => ((min + max) / 2).round();
}

/// Range de PE para uma tier
class PeRange {
  final int min;
  final int max;

  const PeRange({required this.min, required this.max});

  int get average => ((min + max) / 2).round();
}

/// Range de SAN para uma tier
class SanRange {
  final int min;
  final int max;

  const SanRange({required this.min, required this.max});

  int get average => ((min + max) / 2).round();
}

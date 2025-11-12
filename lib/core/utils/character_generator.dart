import 'package:uuid/uuid.dart';
import '../../models/character.dart';

/// Gerador de Personagens seguindo as regras de Ordem Paranormal
///
/// REGRAS OFICIAIS:
/// - Atributos começam em 0
/// - 4 pontos para distribuir
/// - Máximo inicial: +3
/// - Mínimo: -1 (ganha +1 ponto extra se usar)
/// - NUNCA acima de 5 (mesmo com NEX)
///
/// PV/PE/SAN por classe:
/// - Combatente: 20 PV base, 2 PE base, 12 SAN base
/// - Especialista: 16 PV base, 3 PE base, 16 SAN base
/// - Ocultista: 12 PV base, 4 PE base, 20 SAN base
///
/// Fórmulas:
/// - PV = PV_base + Vigor
/// - PE = PE_base + Presença
/// - SAN = SAN_base
/// - Defesa = 10 + Agilidade
/// - Bloqueio = 10 (padrão)
/// - Deslocamento = 9m
/// - Iniciativa = 0 (base)
class CharacterGenerator {
  static const _uuid = Uuid();

  /// Bases por classe (Ordem Paranormal oficial)
  static const Map<CharacterClass, int> pvBase = {
    CharacterClass.combatente: 20,
    CharacterClass.especialista: 16,
    CharacterClass.ocultista: 12,
  };

  static const Map<CharacterClass, int> peBase = {
    CharacterClass.combatente: 2,
    CharacterClass.especialista: 3,
    CharacterClass.ocultista: 4,
  };

  static const Map<CharacterClass, int> sanBase = {
    CharacterClass.combatente: 12,
    CharacterClass.especialista: 16,
    CharacterClass.ocultista: 20,
  };

  /// Gera um personagem balanceado
  static Character generate({
    required String userId,
    required String nome,
    required CharacterClass classe,
    required Origem origem,
    String? trilha,
    String? patente,
    required int forca,
    required int agilidade,
    required int vigor,
    required int intelecto,
    required int presenca,
    int nex = 5,
  }) {
    // Valida distribuição de atributos
    if (!isValidAttributeDistribution(forca, agilidade, vigor, intelecto, presenca)) {
      throw Exception('Distribuição de atributos inválida!');
    }

    // Calcula recursos
    final pvMaxValue = pvBase[classe]! + vigor;
    final peMaxValue = peBase[classe]! + presenca;
    final sanMaxValue = sanBase[classe]!;

    // Calcula defesa (10 + Agilidade)
    final defesaValue = 10 + agilidade;

    return Character(
      id: _uuid.v4(),
      userId: userId,
      nome: nome,
      classe: classe,
      origem: origem,
      trilha: trilha,
      patente: patente,
      nex: nex,
      forca: forca,
      agilidade: agilidade,
      vigor: vigor,
      intelecto: intelecto,
      presenca: presenca,
      pvMax: pvMaxValue,
      pvAtual: pvMaxValue,
      peMax: peMaxValue,
      peAtual: peMaxValue,
      sanMax: sanMaxValue,
      sanAtual: sanMaxValue,
      defesa: defesaValue,
      bloqueio: 10, // Padrão
      deslocamento: 9, // 9 metros padrão
      iniciativaBase: 0,
      creditos: 0,
      periciasTreinadas: [],
      inventarioIds: [],
      poderesIds: [],
    );
  }

  /// Valida distribuição de atributos (Ordem Paranormal)
  ///
  /// Regras:
  /// - Todos começam em 0
  /// - Você tem 4 pontos para distribuir
  /// - Máximo +3 inicial
  /// - Pode reduzir 1 atributo para -1 e ganhar +1 ponto extra (total 5 pontos)
  /// - Apenas 1 atributo pode ser -1
  static bool isValidAttributeDistribution(
    int forca,
    int agilidade,
    int vigor,
    int intelecto,
    int presenca,
  ) {
    // Verifica limites
    final attributes = [forca, agilidade, vigor, intelecto, presenca];

    // Conta quantos são -1
    final negativeCount = attributes.where((a) => a == -1).length;

    // Só pode ter no máximo 1 atributo em -1
    if (negativeCount > 1) return false;

    // Nenhum pode ser menor que -1
    if (attributes.any((a) => a < -1)) return false;

    // Nenhum pode ser maior que 3 inicialmente
    if (attributes.any((a) => a > 3)) return false;

    // Calcula pontos gastos
    int pontosGastos = 0;
    for (final attr in attributes) {
      if (attr > 0) {
        pontosGastos += attr;
      }
    }

    // Se tem 1 atributo em -1, ganha +1 ponto (total 5)
    // Se não tem nenhum em -1, tem 4 pontos
    final pontosDisponiveis = negativeCount == 1 ? 5 : 4;

    return pontosGastos == pontosDisponiveis;
  }

  /// Gera uma distribuição de atributos COMPLETAMENTE ALEATÓRIA e válida
  ///
  /// Usa um algoritmo que:
  /// 1. Decide aleatoriamente se vai usar um atributo negativo (-1) ou não
  /// 2. Distribui os pontos de forma aleatória respeitando as regras
  /// 3. Garante que todos os builds sejam válidos mas MUITO variados
  static Map<String, int> generateRandomDistribution() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final attributes = ['forca', 'agilidade', 'vigor', 'intelecto', 'presenca'];

    // 30% de chance de usar um atributo negativo para ter 5 pontos
    final useNegative = (random % 100) < 30;
    final pontosDisponiveis = useNegative ? 5 : 4;

    // Inicializa todos em 0
    final distribution = <String, int>{
      'forca': 0,
      'agilidade': 0,
      'vigor': 0,
      'intelecto': 0,
      'presenca': 0,
    };

    // Se usar negativo, escolhe um atributo aleatório para ser -1
    if (useNegative) {
      final negativeIndex = (random ~/ 7) % attributes.length;
      distribution[attributes[negativeIndex]] = -1;
    }

    // Distribui os pontos de forma aleatória
    var pontosRestantes = pontosDisponiveis;
    var tentativas = 0;

    while (pontosRestantes > 0 && tentativas < 100) {
      // Escolhe um atributo aleatório que não seja negativo
      final attrIndex = (random + tentativas * 13) % attributes.length;
      final attr = attributes[attrIndex];

      if (distribution[attr]! < 3 && distribution[attr]! >= 0) {
        // Decide quantos pontos colocar (1 a 3, mas não pode exceder restantes)
        final pontosAColocar = ((random + tentativas * 7) % 3) + 1;
        final pontos = pontosAColocar.clamp(1, pontosRestantes);

        // Garante que não ultrapasse 3
        final novoValor = (distribution[attr]! + pontos).clamp(0, 3);
        final pontosUsados = novoValor - distribution[attr]!;

        distribution[attr] = novoValor;
        pontosRestantes -= pontosUsados;
      }

      tentativas++;
    }

    return distribution;
  }

  /// Retorna distribuições balanceadas sugeridas com MUITO mais variedade
  static List<Map<String, int>> getSuggestedDistributions() {
    return [
      // === Builds Especializadas (Foco em 1 atributo) ===
      {'forca': 3, 'agilidade': 1, 'vigor': 0, 'intelecto': 0, 'presenca': 0},
      {'forca': 3, 'agilidade': 0, 'vigor': 1, 'intelecto': 0, 'presenca': 0},
      {'forca': 0, 'agilidade': 3, 'vigor': 1, 'intelecto': 0, 'presenca': 0},
      {'forca': 0, 'agilidade': 3, 'vigor': 0, 'intelecto': 1, 'presenca': 0},
      {'forca': 1, 'agilidade': 0, 'vigor': 3, 'intelecto': 0, 'presenca': 0},
      {'forca': 0, 'agilidade': 0, 'vigor': 3, 'intelecto': 1, 'presenca': 0},
      {'forca': 0, 'agilidade': 1, 'vigor': 0, 'intelecto': 3, 'presenca': 0},
      {'forca': 0, 'agilidade': 0, 'vigor': 1, 'intelecto': 3, 'presenca': 0},
      {'forca': 0, 'agilidade': 0, 'vigor': 1, 'intelecto': 0, 'presenca': 3},
      {'forca': 0, 'agilidade': 1, 'vigor': 0, 'intelecto': 0, 'presenca': 3},

      // === Builds Híbridas (Foco em 2 atributos) ===
      {'forca': 2, 'agilidade': 2, 'vigor': 0, 'intelecto': 0, 'presenca': 0},
      {'forca': 2, 'agilidade': 0, 'vigor': 2, 'intelecto': 0, 'presenca': 0},
      {'forca': 2, 'agilidade': 0, 'vigor': 0, 'intelecto': 2, 'presenca': 0},
      {'forca': 0, 'agilidade': 2, 'vigor': 2, 'intelecto': 0, 'presenca': 0},
      {'forca': 0, 'agilidade': 2, 'vigor': 0, 'intelecto': 2, 'presenca': 0},
      {'forca': 0, 'agilidade': 2, 'vigor': 0, 'intelecto': 0, 'presenca': 2},
      {'forca': 0, 'agilidade': 0, 'vigor': 2, 'intelecto': 2, 'presenca': 0},
      {'forca': 0, 'agilidade': 0, 'vigor': 2, 'intelecto': 0, 'presenca': 2},
      {'forca': 0, 'agilidade': 0, 'vigor': 0, 'intelecto': 2, 'presenca': 2},

      // === Builds Balanceadas (3-4 atributos) ===
      {'forca': 1, 'agilidade': 1, 'vigor': 1, 'intelecto': 1, 'presenca': 0},
      {'forca': 1, 'agilidade': 1, 'vigor': 1, 'intelecto': 0, 'presenca': 1},
      {'forca': 1, 'agilidade': 1, 'vigor': 0, 'intelecto': 1, 'presenca': 1},
      {'forca': 1, 'agilidade': 0, 'vigor': 1, 'intelecto': 1, 'presenca': 1},
      {'forca': 0, 'agilidade': 1, 'vigor': 1, 'intelecto': 1, 'presenca': 1},
      {'forca': 2, 'agilidade': 1, 'vigor': 1, 'intelecto': 0, 'presenca': 0},
      {'forca': 2, 'agilidade': 0, 'vigor': 1, 'intelecto': 1, 'presenca': 0},
      {'forca': 0, 'agilidade': 2, 'vigor': 1, 'intelecto': 1, 'presenca': 0},

      // === Builds com Sacrifício (-1 para ter 5 pontos) ===
      {'forca': -1, 'agilidade': 3, 'vigor': 2, 'intelecto': 0, 'presenca': 0},
      {'forca': -1, 'agilidade': 2, 'vigor': 2, 'intelecto': 1, 'presenca': 0},
      {'forca': -1, 'agilidade': 2, 'vigor': 1, 'intelecto': 2, 'presenca': 0},
      {'forca': -1, 'agilidade': 2, 'vigor': 1, 'intelecto': 1, 'presenca': 1},
      {'forca': -1, 'agilidade': 1, 'vigor': 2, 'intelecto': 2, 'presenca': 0},
      {'forca': -1, 'agilidade': 1, 'vigor': 1, 'intelecto': 2, 'presenca': 1},
      {'forca': -1, 'agilidade': 0, 'vigor': 2, 'intelecto': 3, 'presenca': 0},
      {'forca': -1, 'agilidade': 0, 'vigor': 2, 'intelecto': 2, 'presenca': 1},
      {'forca': -1, 'agilidade': 0, 'vigor': 1, 'intelecto': 3, 'presenca': 1},
      {'forca': 0, 'agilidade': -1, 'vigor': 3, 'intelecto': 2, 'presenca': 0},
      {'forca': 0, 'agilidade': -1, 'vigor': 2, 'intelecto': 3, 'presenca': 0},
      {'forca': 0, 'agilidade': -1, 'vigor': 2, 'intelecto': 2, 'presenca': 1},
    ];
  }

  /// Calcula pontos usados em uma distribuição
  static int calculateUsedPoints(Map<String, int> distribution) {
    int total = 0;
    for (final value in distribution.values) {
      if (value > 0) {
        total += value;
      }
    }
    return total;
  }

  /// Calcula pontos disponíveis baseado em atributos negativos
  static int calculateAvailablePoints(Map<String, int> distribution) {
    final hasNegative = distribution.values.any((v) => v == -1);
    return hasNegative ? 5 : 4;
  }

  /// Gera nome aleatório sugerido
  static String generateRandomName() {
    final firstNames = [
      'Enzo',
      'Lucas',
      'Miguel',
      'Arthur',
      'Gabriel',
      'Ana',
      'Maria',
      'Julia',
      'Sofia',
      'Laura',
      'Pedro',
      'João',
      'Rafael',
      'Felipe',
      'Mateus',
    ];

    final lastNames = [
      'Silva',
      'Santos',
      'Oliveira',
      'Souza',
      'Rodrigues',
      'Ferreira',
      'Alves',
      'Pereira',
      'Lima',
      'Gomes',
      'Costa',
      'Ribeiro',
      'Martins',
      'Carvalho',
      'Rocha',
    ];

    final random = DateTime.now().millisecondsSinceEpoch;
    final firstName = firstNames[random % firstNames.length];
    final lastName = lastNames[(random ~/ 1000) % lastNames.length];

    return '$firstName $lastName';
  }

  /// Retorna descrição de uma origem
  static String getOrigemDescription(Origem origem) {
    switch (origem) {
      case Origem.academico:
        return 'Você estudou em uma instituição de ensino superior';
      case Origem.agente:
        return 'Você foi treinado para missões especiais';
      case Origem.atleta:
        return 'Você é um esportista profissional';
      case Origem.investigador:
        return 'Você dedica sua vida a desvendar mistérios';
      case Origem.militar:
        return 'Você serviu nas forças armadas';
      case Origem.policial:
        return 'Você trabalha mantendo a ordem e a lei';
      default:
        return 'Uma origem misteriosa';
    }
  }

  /// Retorna descrição de uma classe
  static String getClasseDescription(CharacterClass classe) {
    switch (classe) {
      case CharacterClass.combatente:
        return 'Especialista em combate corpo a corpo e armas';
      case CharacterClass.especialista:
        return 'Versátil em múltiplas habilidades e perícias';
      case CharacterClass.ocultista:
        return 'Domina rituais e o poder do Outro Lado';
    }
  }

  /// Retorna estatísticas calculadas para preview
  static Map<String, int> calculateStats({
    required CharacterClass classe,
    required int vigor,
    required int presenca,
    required int agilidade,
  }) {
    return {
      'pvMax': pvBase[classe]! + vigor,
      'peMax': peBase[classe]! + presenca,
      'sanMax': sanBase[classe]!,
      'defesa': 10 + agilidade,
    };
  }
}

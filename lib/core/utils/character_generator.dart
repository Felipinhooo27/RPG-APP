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

  /// Retorna distribuições balanceadas sugeridas (4 pontos)
  static List<Map<String, int>> getSuggestedDistributions() {
    return [
      // Balanceado
      {'forca': 1, 'agilidade': 1, 'vigor': 1, 'intelecto': 1, 'presenca': 0},

      // Combatente físico
      {'forca': 3, 'agilidade': 0, 'vigor': 1, 'intelecto': 0, 'presenca': 0},

      // Combatente ágil
      {'forca': 0, 'agilidade': 3, 'vigor': 1, 'intelecto': 0, 'presenca': 0},

      // Tanque
      {'forca': 1, 'agilidade': 0, 'vigor': 3, 'intelecto': 0, 'presenca': 0},

      // Especialista investigador
      {'forca': 0, 'agilidade': 1, 'vigor': 0, 'intelecto': 3, 'presenca': 0},

      // Ocultista carismático
      {'forca': 0, 'agilidade': 0, 'vigor': 1, 'intelecto': 1, 'presenca': 2},

      // Ocultista inteligente
      {'forca': 0, 'agilidade': 0, 'vigor': 1, 'intelecto': 2, 'presenca': 1},

      // Com sacrifício (-1 em Força para ter 5 pontos)
      {'forca': -1, 'agilidade': 2, 'vigor': 1, 'intelecto': 1, 'presenca': 1},
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

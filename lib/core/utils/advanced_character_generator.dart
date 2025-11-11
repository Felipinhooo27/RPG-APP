import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../models/character.dart';

/// Categorias de personagem (PROMPT SUPREMO)
enum CharacterTier {
  civilIniciante, // 2 pts, PV 8-12
  mercenario, // 3 pts, PV 12-16
  soldado, // 4 pts, PV 14-18
  profissional, // 5 pts, PV 16-20
  lider, // 6 pts, PV 20-26
  chefe, // 7 pts, PV 26-32
  elite, // 8 pts, PV 30-38
  entidadeMenor, // 9 pts, PV 36-48
  deus, // 10 pts, PV 50-80
}

/// Gerador Avançado de Personagens (PROMPT SUPREMO)
///
/// Gera NPCs balanceados por categoria seguindo regras rígidas
class AdvancedCharacterGenerator {
  static final _random = Random();
  static const _uuid = Uuid();

  /// Configuração por tier
  static const Map<CharacterTier, Map<String, dynamic>> tierConfig = {
    CharacterTier.civilIniciante: {
      'pontos': 2,
      'pvMin': 8,
      'pvMax': 12,
      'peMin': 0,
      'peMax': 1,
      'sanMin': 10,
      'sanMax': 14,
      'pericias': 1,
      'poderes': 0,
      'itensMax': 4,
    },
    CharacterTier.mercenario: {
      'pontos': 3,
      'pvMin': 12,
      'pvMax': 16,
      'peMin': 0,
      'peMax': 2,
      'sanMin': 12,
      'sanMax': 16,
      'pericias': 2,
      'poderes': 0,
      'itensMax': 6,
    },
    CharacterTier.soldado: {
      'pontos': 4,
      'pvMin': 14,
      'pvMax': 18,
      'peMin': 1,
      'peMax': 3,
      'sanMin': 14,
      'sanMax': 18,
      'pericias': 3,
      'poderes': 0,
      'itensMax': 8,
    },
    CharacterTier.profissional: {
      'pontos': 5,
      'pvMin': 16,
      'pvMax': 20,
      'peMin': 2,
      'peMax': 4,
      'sanMin': 16,
      'sanMax': 20,
      'pericias': 5,
      'poderes': 1,
      'itensMax': 10,
    },
    CharacterTier.lider: {
      'pontos': 6,
      'pvMin': 20,
      'pvMax': 26,
      'peMin': 3,
      'peMax': 5,
      'sanMin': 18,
      'sanMax': 22,
      'pericias': 6,
      'poderes': 1,
      'itensMax': 13,
    },
    CharacterTier.chefe: {
      'pontos': 7,
      'pvMin': 26,
      'pvMax': 32,
      'peMin': 4,
      'peMax': 7,
      'sanMin': 20,
      'sanMax': 26,
      'pericias': 7,
      'poderes': 2,
      'itensMax': 15,
    },
    CharacterTier.elite: {
      'pontos': 8,
      'pvMin': 30,
      'pvMax': 38,
      'peMin': 6,
      'peMax': 10,
      'sanMin': 24,
      'sanMax': 30,
      'pericias': 8,
      'poderes': 3,
      'itensMax': 18,
    },
    CharacterTier.entidadeMenor: {
      'pontos': 9,
      'pvMin': 36,
      'pvMax': 48,
      'peMin': 8,
      'peMax': 14,
      'sanMin': 30,
      'sanMax': 40,
      'pericias': 10,
      'poderes': 4,
      'itensMax': 20,
    },
    CharacterTier.deus: {
      'pontos': 10,
      'pvMin': 50,
      'pvMax': 80,
      'peMin': 12,
      'peMax': 20,
      'sanMin': 40,
      'sanMax': 60,
      'pericias': 10,
      'poderes': 6,
      'itensMax': 25,
    },
  };

  /// Gera um personagem randomico por tier
  static Character generateRandom({
    required String userId,
    required CharacterTier tier,
    String? forcedName,
    CharacterClass? forcedClass,
  }) {
    final config = tierConfig[tier]!;
    final pontosAtributo = config['pontos'] as int;

    // Nome
    final nome = forcedName ?? _generateRandomName();

    // Classe (se não forçada, escolhe aleatória)
    final classe = forcedClass ?? _randomClass();

    // Origem aleatória
    final origem = _randomOrigem();

    // Distribui atributos
    final atributos = _distributeAttributes(pontosAtributo);

    // Calcula recursos (PV/PE/SAN)
    final pvMin = config['pvMin'] as int;
    final pvMaxValue = config['pvMax'] as int;
    final peMin = config['peMin'] as int;
    final peMaxValue = config['peMax'] as int;
    final sanMin = config['sanMin'] as int;
    final sanMaxValue = config['sanMax'] as int;

    final pvMax = _random.nextInt(pvMaxValue - pvMin + 1) + pvMin;
    final peMax = _random.nextInt(peMaxValue - peMin + 1) + peMin;
    final sanMax = _random.nextInt(sanMaxValue - sanMin + 1) + sanMin;

    // NEX baseado em tier
    final nex = _calculateNEX(tier);

    // Defesa
    final defesa = 10 + atributos['agilidade']!;

    return Character(
      id: _uuid.v4(),
      userId: userId,
      nome: nome,
      classe: classe,
      origem: origem,
      nex: nex,
      forca: atributos['forca']!,
      agilidade: atributos['agilidade']!,
      vigor: atributos['vigor']!,
      intelecto: atributos['intelecto']!,
      presenca: atributos['presenca']!,
      pvMax: pvMax,
      pvAtual: pvMax,
      peMax: peMax,
      peAtual: peMax,
      sanMax: sanMax,
      sanAtual: sanMax,
      defesa: defesa,
      bloqueio: 10,
      deslocamento: 9,
      iniciativaBase: 0,
      creditos: _generateCredits(tier),
      periciasTreinadas: [],
      inventarioIds: [],
      poderesIds: [],
    );
  }

  /// Distribui atributos de forma balanceada
  static Map<String, int> _distributeAttributes(int pontosDisponiveis) {
    // Todos começam em 0
    final attrs = {
      'forca': 0,
      'agilidade': 0,
      'vigor': 0,
      'intelecto': 0,
      'presenca': 0,
    };

    // Distribui pontos aleatoriamente, respeitando max 5
    var pontosRestantes = pontosDisponiveis;
    final keys = attrs.keys.toList()..shuffle(_random);

    while (pontosRestantes > 0) {
      for (final key in keys) {
        if (pontosRestantes <= 0) break;

        // Máximo 5 (ou 6 para deuses em casos raros)
        final maxValue = pontosDisponiveis >= 10 && _random.nextDouble() < 0.1 ? 6 : 5;

        if (attrs[key]! < maxValue) {
          final addAmount = min(pontosRestantes, maxValue - attrs[key]!);
          attrs[key] = attrs[key]! + min(1, addAmount);
          pontosRestantes--;
        }
      }
    }

    return attrs;
  }

  /// Calcula NEX baseado em tier
  static int _calculateNEX(CharacterTier tier) {
    switch (tier) {
      case CharacterTier.civilIniciante:
      case CharacterTier.mercenario:
        return 5;
      case CharacterTier.soldado:
        return 10;
      case CharacterTier.profissional:
        return 20;
      case CharacterTier.lider:
        return 35;
      case CharacterTier.chefe:
        return 50;
      case CharacterTier.elite:
        return 65;
      case CharacterTier.entidadeMenor:
        return 80;
      case CharacterTier.deus:
        return 99;
    }
  }

  /// Gera créditos baseado em tier
  static int _generateCredits(CharacterTier tier) {
    switch (tier) {
      case CharacterTier.civilIniciante:
        return _random.nextInt(50) + 10;
      case CharacterTier.mercenario:
        return _random.nextInt(100) + 50;
      case CharacterTier.soldado:
        return _random.nextInt(200) + 100;
      case CharacterTier.profissional:
        return _random.nextInt(500) + 200;
      case CharacterTier.lider:
        return _random.nextInt(1000) + 500;
      case CharacterTier.chefe:
        return _random.nextInt(2000) + 1000;
      case CharacterTier.elite:
        return _random.nextInt(5000) + 2000;
      case CharacterTier.entidadeMenor:
        return _random.nextInt(10000) + 5000;
      case CharacterTier.deus:
        return _random.nextInt(50000) + 10000;
    }
  }

  /// Gera nome aleatório
  static String _generateRandomName() {
    final firstNames = [
      'Alex',
      'Bruno',
      'Carlos',
      'Diana',
      'Eduardo',
      'Fernanda',
      'Gabriel',
      'Helena',
      'Igor',
      'Julia',
      'Lucas',
      'Maria',
      'Nicolas',
      'Olivia',
      'Pedro',
      'Rafael',
      'Sofia',
      'Thiago',
      'Valentina',
      'William',
      'Enzo',
      'Arthur',
      'Miguel',
      'Alice',
      'Laura',
    ];

    final lastNames = [
      'Silva',
      'Santos',
      'Oliveira',
      'Souza',
      'Costa',
      'Ferreira',
      'Rodrigues',
      'Alves',
      'Pereira',
      'Lima',
      'Gomes',
      'Martins',
      'Carvalho',
      'Ribeiro',
      'Rocha',
      'Nunes',
      'Dias',
      'Castro',
      'Moreira',
      'Barbosa',
    ];

    final firstName = firstNames[_random.nextInt(firstNames.length)];
    final lastName = lastNames[_random.nextInt(lastNames.length)];

    return '$firstName $lastName';
  }

  /// Classe aleatória
  static CharacterClass _randomClass() {
    final classes = CharacterClass.values;
    return classes[_random.nextInt(classes.length)];
  }

  /// Origem aleatória
  static Origem _randomOrigem() {
    final origens = Origem.values;
    return origens[_random.nextInt(origens.length)];
  }

  /// Retorna descrição de tier
  static String getTierDescription(CharacterTier tier) {
    switch (tier) {
      case CharacterTier.civilIniciante:
        return 'Civil sem treinamento, fraco e inexperiente';
      case CharacterTier.mercenario:
        return 'Civil com treinamento básico em combate';
      case CharacterTier.soldado:
        return 'Treinamento militar padrão, preparado para combate';
      case CharacterTier.profissional:
        return 'Especialista com equipamento e habilidades avançadas';
      case CharacterTier.lider:
        return 'Líder de operações, comando tático e experiência';
      case CharacterTier.chefe:
        return 'Boss com arsenal tático e habilidades especiais';
      case CharacterTier.elite:
        return 'Elite paranormal com múltiplos poderes';
      case CharacterTier.entidadeMenor:
        return 'Entidade sobrenatural com poderes paranormais';
      case CharacterTier.deus:
        return 'Entidade maior com poder divino e rituais raros';
    }
  }

  /// Retorna nome amigável de tier
  static String getTierName(CharacterTier tier) {
    switch (tier) {
      case CharacterTier.civilIniciante:
        return 'Civil Iniciante';
      case CharacterTier.mercenario:
        return 'Mercenário';
      case CharacterTier.soldado:
        return 'Soldado / Agente';
      case CharacterTier.profissional:
        return 'Profissional Especializado';
      case CharacterTier.lider:
        return 'Líder de Operação';
      case CharacterTier.chefe:
        return 'Chefe (Boss)';
      case CharacterTier.elite:
        return 'Elite Paranormal';
      case CharacterTier.entidadeMenor:
        return 'Entidade Menor';
      case CharacterTier.deus:
        return 'Deus / Entidade Maior';
    }
  }

  /// Retorna cor por tier
  static String getTierColor(CharacterTier tier) {
    switch (tier) {
      case CharacterTier.civilIniciante:
        return '#9E9E9E'; // Cinza
      case CharacterTier.mercenario:
        return '#8BC34A'; // Verde claro
      case CharacterTier.soldado:
        return '#4CAF50'; // Verde
      case CharacterTier.profissional:
        return '#2196F3'; // Azul
      case CharacterTier.lider:
        return '#9C27B0'; // Roxo
      case CharacterTier.chefe:
        return '#FF5722'; // Laranja
      case CharacterTier.elite:
        return '#FF1744'; // Vermelho
      case CharacterTier.entidadeMenor:
        return '#D500F9'; // Magenta
      case CharacterTier.deus:
        return '#FFD700'; // Dourado
    }
  }
}

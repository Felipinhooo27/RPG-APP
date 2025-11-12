import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../models/character.dart';
import '../../models/item.dart';
import '../../models/power.dart';
import 'item_generator.dart';
import 'power_generator.dart';

/// Categorias de personagem (10 Tiers)
enum CharacterTier {
  civilIniciante,    // Tier 1: 2 pts, PV 8-12, NEX 5%
  mercenario,        // Tier 2: 3 pts, PV 12-16, NEX 10%
  soldado,           // Tier 3: 4 pts, PV 14-18, NEX 20%
  profissional,      // Tier 4: 5 pts, PV 16-20, NEX 35%
  lider,             // Tier 5: 6 pts, PV 20-26, NEX 50%
  chefe,             // Tier 6: 7 pts, PV 26-32, NEX 65%
  elite,             // Tier 7: 8 pts, PV 30-38, NEX 80%
  entidadeMenor,     // Tier 8: 9 pts, PV 36-48, NEX 90%
  entidadeMaior,     // Tier 9: 10 pts, PV 50-80, NEX 95%
}

extension CharacterTierExtension on CharacterTier {
  String get displayName {
    switch (this) {
      case CharacterTier.civilIniciante:
        return 'Civil Iniciante';
      case CharacterTier.mercenario:
        return 'Mercenário';
      case CharacterTier.soldado:
        return 'Soldado/Agente';
      case CharacterTier.profissional:
        return 'Profissional Especializado';
      case CharacterTier.lider:
        return 'Líder de Operação';
      case CharacterTier.chefe:
        return 'Chefe/Boss';
      case CharacterTier.elite:
        return 'Elite Paranormal';
      case CharacterTier.entidadeMenor:
        return 'Entidade Menor';
      case CharacterTier.entidadeMaior:
        return 'Entidade Maior/Deus';
    }
  }

  String get description {
    switch (this) {
      case CharacterTier.civilIniciante:
        return 'Civis comuns, pessoas sem treinamento';
      case CharacterTier.mercenario:
        return 'Mercenários, seguranças, capangas';
      case CharacterTier.soldado:
        return 'Soldados treinados, agentes iniciantes';
      case CharacterTier.profissional:
        return 'Profissionais experientes, agentes veteranos';
      case CharacterTier.lider:
        return 'Líderes táticos, comandantes de missão';
      case CharacterTier.chefe:
        return 'Chefes de operação, bosses importantes';
      case CharacterTier.elite:
        return 'Elite paranormal, agentes de alto nível';
      case CharacterTier.entidadeMenor:
        return 'Entidades paranormais menores';
      case CharacterTier.entidadeMaior:
        return 'Deuses, entidades cósmicas, seres supremos';
    }
  }
}

/// Gerador Unificado de Personagens
/// Combina o melhor do Gerador Rápido e Avançado
class UnifiedCharacterGenerator {
  static final _random = Random();
  static const _uuid = Uuid();

  /// Configuração completa por tier
  static const Map<CharacterTier, Map<String, dynamic>> tierConfig = {
    CharacterTier.civilIniciante: {
      'pontos': 2,
      'pvMin': 8,
      'pvMax': 12,
      'peMin': 0,
      'peMax': 1,
      'sanMin': 10,
      'sanMax': 14,
      'nex': 5,
      'creditosMin': 100,
      'creditosMax': 500,
    },
    CharacterTier.mercenario: {
      'pontos': 3,
      'pvMin': 12,
      'pvMax': 16,
      'peMin': 0,
      'peMax': 2,
      'sanMin': 12,
      'sanMax': 16,
      'nex': 10,
      'creditosMin': 500,
      'creditosMax': 1000,
    },
    CharacterTier.soldado: {
      'pontos': 4,
      'pvMin': 14,
      'pvMax': 18,
      'peMin': 1,
      'peMax': 3,
      'sanMin': 14,
      'sanMax': 18,
      'nex': 20,
      'creditosMin': 1000,
      'creditosMax': 2000,
    },
    CharacterTier.profissional: {
      'pontos': 5,
      'pvMin': 16,
      'pvMax': 20,
      'peMin': 2,
      'peMax': 4,
      'sanMin': 16,
      'sanMax': 20,
      'nex': 35,
      'creditosMin': 2000,
      'creditosMax': 4000,
    },
    CharacterTier.lider: {
      'pontos': 6,
      'pvMin': 20,
      'pvMax': 26,
      'peMin': 3,
      'peMax': 5,
      'sanMin': 18,
      'sanMax': 22,
      'nex': 50,
      'creditosMin': 4000,
      'creditosMax': 8000,
    },
    CharacterTier.chefe: {
      'pontos': 7,
      'pvMin': 26,
      'pvMax': 32,
      'peMin': 4,
      'peMax': 7,
      'sanMin': 20,
      'sanMax': 26,
      'nex': 65,
      'creditosMin': 8000,
      'creditosMax': 15000,
    },
    CharacterTier.elite: {
      'pontos': 8,
      'pvMin': 30,
      'pvMax': 38,
      'peMin': 6,
      'peMax': 10,
      'sanMin': 24,
      'sanMax': 30,
      'nex': 80,
      'creditosMin': 15000,
      'creditosMax': 30000,
    },
    CharacterTier.entidadeMenor: {
      'pontos': 9,
      'pvMin': 36,
      'pvMax': 48,
      'peMin': 8,
      'peMax': 14,
      'sanMin': 30,
      'sanMax': 40,
      'nex': 90,
      'creditosMin': 30000,
      'creditosMax': 50000,
    },
    CharacterTier.entidadeMaior: {
      'pontos': 10,
      'pvMin': 50,
      'pvMax': 80,
      'peMin': 12,
      'peMax': 20,
      'sanMin': 40,
      'sanMax': 60,
      'nex': 95,
      'creditosMin': 50000,
      'creditosMax': 100000,
    },
  };

  /// Gera um personagem completo
  static CharacterGenerationResult generate({
    required String userId,
    required CharacterTier tier,
    String? customName,
    Sexo? sexo,
    int? customIniciativa,
    // Modo avançado (se fornecidos, usa valores customizados)
    int? forcaCustom,
    int? agilidadeCustom,
    int? vigorCustom,
    int? intelectoCustom,
    int? presencaCustom,
    CharacterClass? classeCustom,
    Origem? origemCustom,
    // Geração automática de itens e poderes
    bool generateItems = true,
    bool generatePowers = true,
    bool useRandomItems = true,
    bool useRandomPowers = true,
    ElementoOutroLado? elementoPreferido,
  }) {
    final config = tierConfig[tier]!;

    // Gera ou usa sexo fornecido (null = aleatório)
    final sexoFinal = sexo ?? _randomSexo();

    // Gera ou usa nome fornecido
    final nome = customName?.isEmpty == true || customName == null
        ? _generateName(sexoFinal)
        : customName;

    // Gera ou usa classe fornecida
    final classe = classeCustom ?? _randomClass();

    // Gera ou usa origem fornecida
    final origem = origemCustom ?? _randomOrigem();

    // Distribui atributos (customizados ou automáticos)
    Map<String, int> atributos;
    if (forcaCustom != null &&
        agilidadeCustom != null &&
        vigorCustom != null &&
        intelectoCustom != null &&
        presencaCustom != null) {
      atributos = {
        'forca': forcaCustom,
        'agilidade': agilidadeCustom,
        'vigor': vigorCustom,
        'intelecto': intelectoCustom,
        'presenca': presencaCustom,
      };
    } else {
      atributos = _distributeAttributes(config['pontos'] as int, tier);
    }

    // Gera trilha baseada na classe
    final trilha = _getTrilhaForClass(classe);

    // Calcula recursos (PV/PE/SAN) com variação
    final pvMax = _randomInRange(config['pvMin'] as int, config['pvMax'] as int);
    final peMax = _randomInRange(config['peMin'] as int, config['peMax'] as int);
    final sanMax = _randomInRange(config['sanMin'] as int, config['sanMax'] as int);

    // NEX fixo por tier
    final nex = config['nex'] as int;

    // Créditos aleatórios no range
    final creditos =
        _randomInRange(config['creditosMin'] as int, config['creditosMax'] as int);

    // Defesa = 10 + Agilidade
    final defesa = 10 + atributos['agilidade']!;

    // Iniciativa
    final iniciativaBase = customIniciativa ?? 0;

    // Cria o personagem (sem itens/poderes ainda)
    final characterId = _uuid.v4();
    final character = Character(
      id: characterId,
      userId: userId,
      nome: nome,
      classe: classe,
      origem: origem,
      trilha: trilha,
      nex: nex,
      sexo: sexoFinal,
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
      iniciativaBase: iniciativaBase,
      creditos: creditos,
      periciasTreinadas: [],
      inventarioIds: [],
      poderesIds: [],
    );

    // Gera itens iniciais (se habilitado)
    List<Item> items = [];
    if (generateItems) {
      final itemGenerator = ItemGenerator();
      items = itemGenerator.generateStartingKit(
        characterId: characterId,
        classe: classe,
        origem: origem,
        nex: nex,
        useRandom: useRandomItems,
      );
    }

    // Gera poderes iniciais (se habilitado)
    List<Power> powers = [];
    if (generatePowers) {
      final powerGenerator = PowerGenerator();
      powers = powerGenerator.generateStartingPowers(
        characterId: characterId,
        classe: classe,
        nex: nex,
        elementoPreferido: elementoPreferido,
        useRandom: useRandomPowers,
        includeRituals: true,
      );
    }

    // Atualiza o personagem com os IDs dos itens e poderes gerados
    final updatedCharacter = character.copyWith(
      inventarioIds: items.map((item) => item.id).toList(),
      poderesIds: powers.map((power) => power.id).toList(),
    );

    return CharacterGenerationResult(
      character: updatedCharacter,
      items: items,
      powers: powers,
    );
  }

  /// Distribui atributos de forma balanceada
  static Map<String, int> _distributeAttributes(int pontosDisponiveis, CharacterTier tier) {
    // Todos começam em 0
    final attrs = {
      'forca': 0,
      'agilidade': 0,
      'vigor': 0,
      'intelecto': 0,
      'presenca': 0,
    };

    // Define máximo (5 padrão, raramente 6 para entidades superiores)
    final maxValue = (tier == CharacterTier.entidadeMaior && _random.nextDouble() < 0.1)
        ? 6
        : 5;

    // Distribui pontos aleatoriamente
    var pontosRestantes = pontosDisponiveis;
    final keys = attrs.keys.toList()..shuffle(_random);

    while (pontosRestantes > 0) {
      for (final key in keys) {
        if (pontosRestantes <= 0) break;

        if (attrs[key]! < maxValue) {
          attrs[key] = attrs[key]! + 1;
          pontosRestantes--;
        }
      }
    }

    return attrs;
  }

  /// Gera nome baseado no sexo
  static String _generateName(Sexo sexo) {
    final sobrenome = _sobrenomes[_random.nextInt(_sobrenomes.length)];

    switch (sexo) {
      case Sexo.masculino:
        final nome = _nomesMasculinos[_random.nextInt(_nomesMasculinos.length)];
        return '$nome $sobrenome';
      case Sexo.feminino:
        final nome = _nomesFemininos[_random.nextInt(_nomesFemininos.length)];
        return '$nome $sobrenome';
      case Sexo.naoBinario:
        final nome = _nomesNeutros[_random.nextInt(_nomesNeutros.length)];
        return '$nome $sobrenome';
    }
  }

  /// Sexo aleatório
  static Sexo _randomSexo() {
    return Sexo.values[_random.nextInt(Sexo.values.length)];
  }

  /// Classe aleatória
  static CharacterClass _randomClass() {
    return CharacterClass.values[_random.nextInt(CharacterClass.values.length)];
  }

  /// Origem aleatória
  static Origem _randomOrigem() {
    return Origem.values[_random.nextInt(Origem.values.length)];
  }

  /// Obtém trilha para classe
  static String _getTrilhaForClass(CharacterClass classe) {
    switch (classe) {
      case CharacterClass.combatente:
        final trilhas = ['Aniquilador', 'Comandante de Campo', 'Guerreiro'];
        return trilhas[_random.nextInt(trilhas.length)];
      case CharacterClass.especialista:
        final trilhas = ['Atirador de Elite', 'Infiltrador', 'Médico de Campo'];
        return trilhas[_random.nextInt(trilhas.length)];
      case CharacterClass.ocultista:
        final trilhas = ['Conduíte', 'Flagelador', 'Intuitivo'];
        return trilhas[_random.nextInt(trilhas.length)];
    }
  }

  /// Gera número aleatório no range
  static int _randomInRange(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }

  // ============================================================================
  // LISTAS DE NOMES
  // ============================================================================

  static const List<String> _nomesMasculinos = [
    'André', 'Bruno', 'Carlos', 'Diego', 'Eduardo', 'Felipe', 'Gabriel',
    'Henrique', 'Igor', 'João', 'Lucas', 'Marcos', 'Pedro', 'Rafael',
    'Rodrigo', 'Thiago', 'Victor', 'William', 'Alexandre', 'Daniel',
  ];

  static const List<String> _nomesFemininos = [
    'Ana', 'Beatriz', 'Carla', 'Daniela', 'Eduarda', 'Fernanda', 'Gabriela',
    'Helena', 'Isabela', 'Juliana', 'Larissa', 'Maria', 'Natália', 'Patricia',
    'Rafaela', 'Sophia', 'Tatiana', 'Vanessa', 'Amanda', 'Camila',
  ];

  static const List<String> _nomesNeutros = [
    'Alex', 'Ariel', 'Casey', 'Dakota', 'Eden', 'Jordan', 'Morgan',
    'Parker', 'Quinn', 'Riley', 'Sage', 'Taylor', 'Sam', 'Roni',
    'Kim', 'Pat', 'Jess', 'Chris', 'Ash', 'Blair',
  ];

  static const List<String> _sobrenomes = [
    'Silva', 'Santos', 'Oliveira', 'Souza', 'Ferreira', 'Pereira', 'Costa',
    'Rodrigues', 'Almeida', 'Nascimento', 'Lima', 'Araújo', 'Fernandes',
    'Carvalho', 'Gomes', 'Martins', 'Rocha', 'Ribeiro', 'Alves', 'Monteiro',
  ];
}

/// Resultado da geração de personagem
/// Inclui o personagem e todos os itens/poderes gerados
class CharacterGenerationResult {
  final Character character;
  final List<Item> items;
  final List<Power> powers;

  const CharacterGenerationResult({
    required this.character,
    required this.items,
    required this.powers,
  });

  /// Total de itens gerados
  int get itemCount => items.length;

  /// Total de poderes gerados
  int get powerCount => powers.length;

  /// Verifica se itens foram gerados
  bool get hasItems => items.isNotEmpty;

  /// Verifica se poderes foram gerados
  bool get hasPowers => powers.isNotEmpty;
}

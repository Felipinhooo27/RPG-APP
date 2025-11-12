import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../models/character.dart';
import '../../models/item.dart';
import '../../models/power.dart';
import '../../models/skill.dart';
import 'item_generator.dart';
import 'power_generator.dart';
import 'character_generator.dart';

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

    // Gera perícias automaticamente baseado no tier
    final pericias = _generateSkills(tier, classe, origem);

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
      periciasTreinadas: pericias,
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

  /// Distribui atributos de forma TOTALMENTE aleatória e variada
  static Map<String, int> _distributeAttributes(int pontosDisponiveis, CharacterTier tier) {
    // Para tiers baixos (1-3), usa distribuição simples
    if (pontosDisponiveis <= 3) {
      return CharacterGenerator.generateRandomDistribution();
    }

    // Para tiers altos, usa lógica avançada com máximo maior
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

    // Distribui pontos de forma aleatória e variada
    var pontosRestantes = pontosDisponiveis;
    final keys = attrs.keys.toList()..shuffle(_random);

    // Estratégia: chance de criar builds especializadas vs balanceadas
    final isSpecialized = _random.nextDouble() < 0.5; // 50% de chance

    if (isSpecialized && pontosRestantes >= 4) {
      // Build especializada: foca 60% dos pontos em 1-2 atributos
      final focusCount = _random.nextDouble() < 0.7 ? 1 : 2;
      final focusAttributes = keys.take(focusCount).toList();
      final focusPoints = (pontosRestantes * 0.6).floor();

      for (final attr in focusAttributes) {
        final pontos = (focusPoints / focusCount).floor();
        attrs[attr] = pontos.clamp(0, maxValue);
        pontosRestantes -= attrs[attr]!;
      }
    }

    // Distribui pontos restantes aleatoriamente
    while (pontosRestantes > 0) {
      for (final key in keys) {
        if (pontosRestantes <= 0) break;

        if (attrs[key]! < maxValue && _random.nextDouble() < 0.6) {
          attrs[key] = attrs[key]! + 1;
          pontosRestantes--;
        }
      }
    }

    return attrs;
  }

  /// Gera perícias automaticamente baseado no tier
  static List<String> _generateSkills(CharacterTier tier, CharacterClass classe, Origem origem) {
    // Define quantas perícias gerar baseado no tier
    final skillCount = _getSkillCountForTier(tier);
    if (skillCount == 0) return [];

    final availableSkills = Skill.getPadrao();
    final selectedSkills = <String>[];

    // Perícias prioritárias por classe
    final classPriority = _getClassPrioritySkills(classe);

    // Perícias prioritárias por origem
    final origemPriority = _getOrigemPrioritySkills(origem);

    // Combina prioridades (remove duplicatas)
    final prioritySkills = {...classPriority, ...origemPriority}.toList();

    // Seleciona perícias prioritárias primeiro
    for (final skill in prioritySkills) {
      if (selectedSkills.length >= skillCount) break;
      if (availableSkills.contains(skill)) {
        selectedSkills.add(skill);
      }
    }

    // Preenche restante aleatoriamente
    final remainingSkills = availableSkills.where((s) => !selectedSkills.contains(s)).toList();
    while (selectedSkills.length < skillCount && remainingSkills.isNotEmpty) {
      final skill = remainingSkills[_random.nextInt(remainingSkills.length)];
      selectedSkills.add(skill);
      remainingSkills.remove(skill);
    }

    return selectedSkills;
  }

  /// Retorna quantidade de perícias por tier
  static int _getSkillCountForTier(CharacterTier tier) {
    switch (tier) {
      case CharacterTier.civilIniciante:
        return 2;
      case CharacterTier.mercenario:
        return 3;
      case CharacterTier.soldado:
        return 4;
      case CharacterTier.profissional:
        return 5;
      case CharacterTier.lider:
        return 6;
      case CharacterTier.chefe:
        return 7;
      case CharacterTier.elite:
        return 8;
      case CharacterTier.entidadeMenor:
        return 9;
      case CharacterTier.entidadeMaior:
        return 10;
    }
  }

  /// Perícias prioritárias por classe
  static List<String> _getClassPrioritySkills(CharacterClass classe) {
    switch (classe) {
      case CharacterClass.combatente:
        return ['Luta', 'Pontaria', 'Atletismo', 'Fortitude', 'Tática', 'Intimidação'];
      case CharacterClass.especialista:
        return ['Furtividade', 'Percepção', 'Investigação', 'Reflexos', 'Tecnologia', 'Crime'];
      case CharacterClass.ocultista:
        return ['Ocultismo', 'Vontade', 'Intuição', 'Medicina', 'Ciências', 'Religião'];
    }
  }

  /// Perícias prioritárias por origem
  static List<String> _getOrigemPrioritySkills(Origem origem) {
    switch (origem) {
      case Origem.academico:
        return ['Ciências', 'Tecnologia', 'Investigação'];
      case Origem.agente:
        return ['Pontaria', 'Tática', 'Percepção'];
      case Origem.artista:
        return ['Artes', 'Enganação', 'Diplomacia'];
      case Origem.atleta:
        return ['Atletismo', 'Acrobacia', 'Fortitude'];
      case Origem.investigador:
        return ['Investigação', 'Intuição', 'Percepção'];
      case Origem.lutador:
        return ['Luta', 'Atletismo', 'Intimidação'];
      case Origem.mercenario:
        return ['Pontaria', 'Tática', 'Sobrevivência'];
      case Origem.militar:
        return ['Pontaria', 'Tática', 'Fortitude'];
      case Origem.policial:
        return ['Pontaria', 'Investigação', 'Intimidação'];
      default:
        return ['Percepção', 'Iniciativa', 'Reflexos'];
    }
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
  // LISTAS DE NOMES (EXPANDIDAS PARA 100+ CADA)
  // ============================================================================

  static const List<String> _nomesMasculinos = [
    // Brasileiros populares
    'André', 'Bruno', 'Carlos', 'Diego', 'Eduardo', 'Felipe', 'Gabriel',
    'Henrique', 'Igor', 'João', 'Lucas', 'Marcos', 'Pedro', 'Rafael',
    'Rodrigo', 'Thiago', 'Victor', 'William', 'Alexandre', 'Daniel',
    'Gustavo', 'Matheus', 'Leonardo', 'Fernando', 'Ricardo', 'Renato',
    'Marcelo', 'Paulo', 'Vinicius', 'Fábio', 'Márcio', 'Júlio', 'César',
    'Leandro', 'Anderson', 'Roberto', 'José', 'Antônio', 'Francisco',
    // Modernos e internacionais
    'Enzo', 'Noah', 'Liam', 'Oliver', 'Benjamin', 'Lucas', 'Henry',
    'Arthur', 'Miguel', 'Samuel', 'Nathan', 'Isaac', 'Ryan', 'Dylan',
    'Kevin', 'Eric', 'Anthony', 'Thomas', 'Joshua', 'Christopher',
    'Nicholas', 'Jonathan', 'Matthew', 'Andrew', 'Jason', 'Justin',
    'David', 'James', 'Robert', 'Michael', 'George', 'Edward', 'Richard',
    // Nomes únicos/distintos
    'Atlas', 'Axel', 'Dante', 'Felix', 'Hugo', 'Ivan', 'Kai', 'Leon',
    'Max', 'Otto', 'Raul', 'Seth', 'Tobias', 'Ugo', 'Vitor', 'Yuri',
    'Adrian', 'Brennan', 'Caleb', 'Damian', 'Elias', 'Finn', 'Griffin',
    'Harrison', 'Jasper', 'Klaus', 'Lorenzo', 'Miles', 'Nico', 'Oscar',
    'Phoenix', 'Quentin', 'Sebastian', 'Tristan', 'Vincent', 'Wesley', 'Xander', 'Zane',
    'Ciro', 'Ravi', 'Davi', 'Pietro', 'Kaio', 'Breno', 'Caio', 'Erick',
  ];

  static const List<String> _nomesFemininos = [
    // Brasileiras populares
    'Ana', 'Beatriz', 'Carla', 'Daniela', 'Eduarda', 'Fernanda', 'Gabriela',
    'Helena', 'Isabela', 'Juliana', 'Larissa', 'Maria', 'Natália', 'Patricia',
    'Rafaela', 'Sophia', 'Tatiana', 'Vanessa', 'Amanda', 'Camila',
    'Débora', 'Elisa', 'Flávia', 'Giovana', 'Heloísa', 'Ingrid', 'Jéssica',
    'Karen', 'Letícia', 'Marina', 'Nicole', 'Olivia', 'Paula', 'Renata',
    'Sabrina', 'Teresa', 'Valentina', 'Yasmin', 'Bianca', 'Carolina',
    // Modernas e internacionais
    'Alice', 'Emma', 'Mia', 'Luna', 'Ella', 'Grace', 'Lily', 'Emily',
    'Ava', 'Chloe', 'Sophie', 'Hannah', 'Zoe', 'Scarlett', 'Victoria',
    'Aurora', 'Stella', 'Maya', 'Ruby', 'Violet', 'Hazel', 'Ivy',
    'Willow', 'Rose', 'Jade', 'Eleanor', 'Penelope', 'Aria', 'Layla',
    'Naomi', 'Ellie', 'Madeline', 'Sarah', 'Rachel', 'Rebecca', 'Laura',
    // Nomes únicos/distintos
    'Athena', 'Iris', 'Nova', 'Luna', 'Celeste', 'Diana', 'Freya',
    'Gaia', 'Kira', 'Lyra', 'Mila', 'Nina', 'Orla', 'Piper', 'Quinn',
    'Raquel', 'Serena', 'Thalia', 'Uma', 'Vera', 'Wanda', 'Yara', 'Zara',
    'Cecília', 'Luana', 'Melissa', 'Bruna', 'Vitória', 'Clara', 'Lorena',
    'Alana', 'Mariana', 'Aline', 'Silvia', 'Lívia', 'Priscila', 'Mônica',
  ];

  static const List<String> _nomesNeutros = [
    'Alex', 'Ariel', 'Casey', 'Dakota', 'Eden', 'Jordan', 'Morgan',
    'Parker', 'Quinn', 'Riley', 'Sage', 'Taylor', 'Sam', 'Roni',
    'Kim', 'Pat', 'Jess', 'Chris', 'Ash', 'Blair', 'Drew', 'Emerson',
    'Finley', 'Hayden', 'Indigo', 'Justice', 'Kai', 'Logan', 'Marley',
    'Noah', 'Ocean', 'Phoenix', 'Raven', 'Skyler', 'River', 'Rowan',
    'Charlie', 'Jamie', 'Avery', 'Peyton', 'Reese', 'Cameron', 'Dylan',
    'Angel', 'Sage', 'Micah', 'Sasha', 'Harper', 'Jessie', 'Robin',
    'Stevie', 'Frankie', 'Bailey', 'Addison', 'Reed', 'Jules', 'Blake',
    'Kai', 'Ellis', 'Arden', 'Kendall', 'Lennon', 'Sawyer', 'Shiloh',
    'Sterling', 'Tatum', 'Val', 'Winter', 'Wren', 'Nevada', 'Adrian',
    'Alexis', 'Amari', 'Brooklyn', 'Campbell', 'Carson', 'Dakota', 'Denver',
    'Elliott', 'Finley', 'Gray', 'Haven', 'Hollis', 'Ivory', 'Jaden',
    'Kennedy', 'Lake', 'Lane', 'London', 'Memphis', 'Milan', 'Nova',
  ];

  static const List<String> _sobrenomes = [
    // Brasileiros comuns
    'Silva', 'Santos', 'Oliveira', 'Souza', 'Ferreira', 'Pereira', 'Costa',
    'Rodrigues', 'Almeida', 'Nascimento', 'Lima', 'Araújo', 'Fernandes',
    'Carvalho', 'Gomes', 'Martins', 'Rocha', 'Ribeiro', 'Alves', 'Monteiro',
    'Mendes', 'Barros', 'Freitas', 'Barbosa', 'Pinto', 'Moura', 'Cavalcanti',
    'Dias', 'Castro', 'Campos', 'Cardoso', 'Correia', 'Teixeira', 'Vieira',
    'Azevedo', 'Borges', 'Soares', 'Machado', 'Melo', 'Reis', 'Nunes',
    // Internacionais variados
    'Anderson', 'Baker', 'Brown', 'Clark', 'Davis', 'Evans', 'Garcia',
    'Harris', 'Jackson', 'Johnson', 'Jones', 'King', 'Lee', 'Lewis',
    'Martin', 'Martinez', 'Miller', 'Moore', 'Nelson', 'Parker', 'Robinson',
    'Rodriguez', 'Smith', 'Taylor', 'Thomas', 'Thompson', 'Walker', 'White',
    'Williams', 'Wilson', 'Wright', 'Young', 'Allen', 'Hall', 'Hill',
    // Sobrenomes únicos/distintos
    'Blackwood', 'Cross', 'Fox', 'Gray', 'Hunter', 'Knight', 'Rivers',
    'Sterling', 'Stone', 'Storm', 'West', 'Winter', 'Wolf', 'Woods',
    'Drake', 'Frost', 'Harper', 'Hayes', 'Kane', 'Mercer', 'Noble',
    'Porter', 'Quinn', 'Reeves', 'Shepherd', 'Sinclair', 'Torres', 'Vale',
    'Vega', 'Ward', 'Webb', 'York', 'Archer', 'Blake', 'Crane', 'Ellis',
    'Flynn', 'Grant', 'Hudson', 'Knox', 'Lane', 'Nash', 'Pierce', 'Reed',
    'Santos', 'Vaughn', 'Wells', 'Chambers', 'Cohen', 'Dixon', 'Duncan',
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

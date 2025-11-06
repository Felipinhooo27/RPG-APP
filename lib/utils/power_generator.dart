import 'dart:math';

class PowerData {
  final String nome;
  final String descricao;
  final String tipo; // Combate, Defesa, Utilidade, Movimento, Percepção, Mental

  PowerData({
    required this.nome,
    required this.descricao,
    required this.tipo,
  });
}

class PowerGenerator {
  static final Random _random = Random();

  static final List<PowerData> _allPowers = [
    // Poderes de Combate
    PowerData(
      nome: 'Rajada de Energia',
      descricao: 'Dispara um raio de energia paranormal (3d6 dano)',
      tipo: 'Combate',
    ),
    PowerData(
      nome: 'Golpe Vital',
      descricao: 'Acerto crítico causa dano dobrado',
      tipo: 'Combate',
    ),
    PowerData(
      nome: 'Ataque Múltiplo',
      descricao: 'Pode atacar 2 vezes por turno',
      tipo: 'Combate',
    ),
    PowerData(
      nome: 'Lâmina Sombria',
      descricao: 'Arma causa +2d8 de dano necrótico',
      tipo: 'Combate',
    ),
    PowerData(
      nome: 'Explosão Mental',
      descricao: 'Ataque psíquico em área (4d6 dano, 3m raio)',
      tipo: 'Combate',
    ),

    // Poderes de Defesa
    PowerData(
      nome: 'Escudo Paranormal',
      descricao: 'Ganha +5 de defesa por 3 rodadas',
      tipo: 'Defesa',
    ),
    PowerData(
      nome: 'Regeneração',
      descricao: 'Recupera 1d6 PV por rodada',
      tipo: 'Defesa',
    ),
    PowerData(
      nome: 'Pele de Ferro',
      descricao: 'Reduz todo dano recebido em 5',
      tipo: 'Defesa',
    ),
    PowerData(
      nome: 'Barreira de Energia',
      descricao: 'Bloqueia o próximo ataque completamente',
      tipo: 'Defesa',
    ),
    PowerData(
      nome: 'Forma Etérea',
      descricao: 'Ataques físicos tem 50% de chance de errar',
      tipo: 'Defesa',
    ),

    // Poderes de Movimento
    PowerData(
      nome: 'Teleporte Curto',
      descricao: 'Teleporta até 15m instantaneamente',
      tipo: 'Movimento',
    ),
    PowerData(
      nome: 'Velocidade Sobrenatural',
      descricao: 'Movimento dobrado por 5 rodadas',
      tipo: 'Movimento',
    ),
    PowerData(
      nome: 'Levitação',
      descricao: 'Flutua a 3m do chão, ignora terreno difícil',
      tipo: 'Movimento',
    ),
    PowerData(
      nome: 'Passo das Sombras',
      descricao: 'Move-se através de sombras sem ser visto',
      tipo: 'Movimento',
    ),
    PowerData(
      nome: 'Salto Fantasma',
      descricao: 'Pula até 20m de distância',
      tipo: 'Movimento',
    ),

    // Poderes de Percepção
    PowerData(
      nome: 'Visão no Escuro',
      descricao: 'Enxerga perfeitamente no escuro total',
      tipo: 'Percepção',
    ),
    PowerData(
      nome: 'Sentir Vida',
      descricao: 'Detecta criaturas vivas em 30m',
      tipo: 'Percepção',
    ),
    PowerData(
      nome: 'Visão de Raio-X',
      descricao: 'Enxerga através de paredes (3m)',
      tipo: 'Percepção',
    ),
    PowerData(
      nome: 'Ler Mentes',
      descricao: 'Lê pensamentos superficiais de um alvo',
      tipo: 'Percepção',
    ),
    PowerData(
      nome: 'Presciência',
      descricao: 'Vê 3 segundos no futuro (+3 iniciativa)',
      tipo: 'Percepção',
    ),

    // Poderes Mentais
    PowerData(
      nome: 'Controle Mental',
      descricao: 'Controla um alvo por 1 rodada',
      tipo: 'Mental',
    ),
    PowerData(
      nome: 'Ilusão',
      descricao: 'Cria uma ilusão convincente',
      tipo: 'Mental',
    ),
    PowerData(
      nome: 'Medo Paranormal',
      descricao: 'Causa terror, alvo foge por 2 rodadas',
      tipo: 'Mental',
    ),
    PowerData(
      nome: 'Sugestão',
      descricao: 'Implanta uma sugestão simples na mente',
      tipo: 'Mental',
    ),
    PowerData(
      nome: 'Amnésia',
      descricao: 'Apaga memórias recentes (últimos 10min)',
      tipo: 'Mental',
    ),

    // Poderes de Utilidade
    PowerData(
      nome: 'Cura Paranormal',
      descricao: 'Cura 3d8 PV de um alvo',
      tipo: 'Utilidade',
    ),
    PowerData(
      nome: 'Detectar Paranormal',
      descricao: 'Sente presença paranormal em 50m',
      tipo: 'Utilidade',
    ),
    PowerData(
      nome: 'Invisibilidade',
      descricao: 'Fica invisível por 1 minuto',
      tipo: 'Utilidade',
    ),
    PowerData(
      nome: 'Telecinese',
      descricao: 'Move objetos com a mente (até 50kg)',
      tipo: 'Utilidade',
    ),
    PowerData(
      nome: 'Transformação',
      descricao: 'Muda de aparência por 1 hora',
      tipo: 'Utilidade',
    ),

    // Poderes Divinos (para Deuses)
    PowerData(
      nome: 'Destruição Total',
      descricao: 'Causa 10d10 de dano em 10m de raio',
      tipo: 'Combate',
    ),
    PowerData(
      nome: 'Imortalidade',
      descricao: 'Não pode morrer, regenera completamente',
      tipo: 'Defesa',
    ),
    PowerData(
      nome: 'Onipresença',
      descricao: 'Pode estar em múltiplos lugares simultaneamente',
      tipo: 'Movimento',
    ),
    PowerData(
      nome: 'Onisciência Local',
      descricao: 'Sabe tudo que acontece em 1km',
      tipo: 'Percepção',
    ),
    PowerData(
      nome: 'Controle da Realidade',
      descricao: 'Pode alterar a realidade ao redor (limitado)',
      tipo: 'Mental',
    ),
  ];

  /// Gera poderes aleatórios baseado na categoria
  static List<String> generatePowers(String category) {
    switch (category) {
      case 'Deus':
        // Deus tem 5-8 poderes, incluindo divinos
        return _getRandomPowers(5 + _random.nextInt(4), includeGodPowers: true);

      case 'Profissional':
        // Profissional sempre tem 2-3 poderes
        return _getRandomPowers(2 + _random.nextInt(2));

      case 'Líder':
        // Líder tem 20% de chance de ter 1-2 poderes
        if (_random.nextDouble() < 0.2) {
          return _getRandomPowers(1 + _random.nextInt(2));
        }
        return [];

      case 'Chefe':
        // Chefe tem 10% de chance de ter 1 poder
        if (_random.nextDouble() < 0.1) {
          return _getRandomPowers(1);
        }
        return [];

      default:
        // Civil, Soldado, Mercenário não têm poderes
        return [];
    }
  }

  static List<String> _getRandomPowers(int count, {bool includeGodPowers = false}) {
    final powers = <String>[];
    final availablePowers = includeGodPowers
        ? List<PowerData>.from(_allPowers)
        : _allPowers.where((p) =>
            p.nome != 'Destruição Total' &&
            p.nome != 'Imortalidade' &&
            p.nome != 'Onipresença' &&
            p.nome != 'Onisciência Local' &&
            p.nome != 'Controle da Realidade'
          ).toList();

    // Embaralhar e pegar os primeiros N
    availablePowers.shuffle(_random);

    for (int i = 0; i < count && i < availablePowers.length; i++) {
      final power = availablePowers[i];
      powers.add('${power.nome} (${power.tipo}): ${power.descricao}');
    }

    return powers;
  }

  /// Retorna um poder aleatório formatado
  static String getRandomPowerString() {
    final power = _allPowers[_random.nextInt(_allPowers.length)];
    return '${power.nome} (${power.tipo}): ${power.descricao}';
  }
}

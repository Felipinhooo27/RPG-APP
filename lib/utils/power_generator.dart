import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/power.dart';

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
  static const Uuid _uuid = Uuid();

  static final List<PowerData> _allPowers = [
    // ==================== PODERES DE COMBATE (15) ====================
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
    // Novos poderes de combate
    PowerData(
      nome: 'Fúria Berserker',
      descricao: '+5 de dano corpo a corpo, mas -2 defesa por 5 rodadas',
      tipo: 'Combate',
    ),
    PowerData(
      nome: 'Perfurar Armadura',
      descricao: 'Ignora 10 pontos de defesa do alvo',
      tipo: 'Combate',
    ),
    PowerData(
      nome: 'Golpe Atordoante',
      descricao: 'Alvo fica atordoado por 1 rodada (CD 15)',
      tipo: 'Combate',
    ),
    PowerData(
      nome: 'Drenagem Vital',
      descricao: 'Causa 2d8 dano e cura metade do dano causado',
      tipo: 'Combate',
    ),
    PowerData(
      nome: 'Rajada Arcana',
      descricao: 'Dispara 3 mísseis mágicos (1d6+2 cada)',
      tipo: 'Combate',
    ),
    PowerData(
      nome: 'Contra-Ataque',
      descricao: 'Revida automaticamente quando recebe ataque corpo a corpo',
      tipo: 'Combate',
    ),
    PowerData(
      nome: 'Execução',
      descricao: 'Mata instantaneamente alvos com menos de 20% HP',
      tipo: 'Combate',
    ),
    PowerData(
      nome: 'Corrente de Relâmpagos',
      descricao: 'Ataca até 3 alvos próximos (2d8 dano cada)',
      tipo: 'Combate',
    ),
    PowerData(
      nome: 'Investida Brutal',
      descricao: 'Corre e ataca causando 3d10 de dano',
      tipo: 'Combate',
    ),
    PowerData(
      nome: 'Toque Vampírico',
      descricao: 'Drena 3d6 PV e ganha PV temporários iguais',
      tipo: 'Combate',
    ),

    // ==================== PODERES DE DEFESA (15) ====================
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
    // Novos poderes de defesa
    PowerData(
      nome: 'Cura Acelerada',
      descricao: 'Recupera 3d8 PV instantaneamente',
      tipo: 'Defesa',
    ),
    PowerData(
      nome: 'Pele de Pedra',
      descricao: 'Reduz todo dano físico pela metade',
      tipo: 'Defesa',
    ),
    PowerData(
      nome: 'Aura Protetora',
      descricao: 'Aliados em 5m ganham +3 de defesa',
      tipo: 'Defesa',
    ),
    PowerData(
      nome: 'Ressurreição Menor',
      descricao: 'Revive com 1 PV quando morrer (1x/dia)',
      tipo: 'Defesa',
    ),
    PowerData(
      nome: 'Reflexão de Dano',
      descricao: 'Reflete 50% do dano recebido ao atacante',
      tipo: 'Defesa',
    ),
    PowerData(
      nome: 'Corpo Adaptável',
      descricao: 'Ganha resistência ao tipo do último dano recebido',
      tipo: 'Defesa',
    ),
    PowerData(
      nome: 'Escudo Mental',
      descricao: 'Imune a efeitos mentais e psíquicos',
      tipo: 'Defesa',
    ),
    PowerData(
      nome: 'Fortitude Inabalável',
      descricao: '+10 HP máximo e vantagem em testes de resistência',
      tipo: 'Defesa',
    ),
    PowerData(
      nome: 'Evasão Sobrenatural',
      descricao: 'Esquiva automaticamente o primeiro ataque por turno',
      tipo: 'Defesa',
    ),
    PowerData(
      nome: 'Absorção de Energia',
      descricao: 'Absorve energia de ataques mágicos para recuperar PV',
      tipo: 'Defesa',
    ),

    // ==================== PODERES DE MOVIMENTO (10) ====================
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
    // Novos poderes de movimento
    PowerData(
      nome: 'Atravessar Paredes',
      descricao: 'Pode passar através de objetos sólidos por 1 turno',
      tipo: 'Movimento',
    ),
    PowerData(
      nome: 'Voo',
      descricao: 'Ganha velocidade de voo igual ao movimento',
      tipo: 'Movimento',
    ),
    PowerData(
      nome: 'Dash Espectral',
      descricao: 'Move-se 30m instantaneamente, deixa rastro de sombras',
      tipo: 'Movimento',
    ),
    PowerData(
      nome: 'Caminhar nas Paredes',
      descricao: 'Anda em qualquer superfície, incluindo tetos',
      tipo: 'Movimento',
    ),
    PowerData(
      nome: 'Teleporte de Troca',
      descricao: 'Troca de posição com um alvo a até 20m',
      tipo: 'Movimento',
    ),

    // ==================== PODERES DE PERCEPÇÃO (10) ====================
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
    // Novos poderes de percepção
    PowerData(
      nome: 'Visão Verdadeira',
      descricao: 'Vê através de ilusões e disfarces',
      tipo: 'Percepção',
    ),
    PowerData(
      nome: 'Audição Aguçada',
      descricao: 'Ouve sons a 100m como se estivessem ao lado',
      tipo: 'Percepção',
    ),
    PowerData(
      nome: 'Sentir Perigo',
      descricao: 'Detecta armadilhas e emboscadas automaticamente',
      tipo: 'Percepção',
    ),
    PowerData(
      nome: 'Aura de Leitura',
      descricao: 'Vê a aura de criaturas, revelando emoções e intenções',
      tipo: 'Percepção',
    ),
    PowerData(
      nome: 'Visão do Passado',
      descricao: 'Vê eventos que ocorreram em um local nas últimas 24h',
      tipo: 'Percepção',
    ),

    // ==================== PODERES MENTAIS (15) ====================
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
    // Novos poderes mentais
    PowerData(
      nome: 'Dominar Vontade',
      descricao: 'Controla alvo por 1 minuto (CD 18)',
      tipo: 'Mental',
    ),
    PowerData(
      nome: 'Ilusão Maior',
      descricao: 'Cria ilusões com sons, cheiros e sensações táteis',
      tipo: 'Mental',
    ),
    PowerData(
      nome: 'Paralisia Mental',
      descricao: 'Alvo fica paralisado por 3 rodadas',
      tipo: 'Mental',
    ),
    PowerData(
      nome: 'Confusão',
      descricao: 'Alvos em 6m atacam aliados aleatoriamente',
      tipo: 'Mental',
    ),
    PowerData(
      nome: 'Criar Duplicata',
      descricao: 'Cria 1d4 cópias ilusórias de si mesmo',
      tipo: 'Mental',
    ),
    PowerData(
      nome: 'Telepatia',
      descricao: 'Comunica-se mentalmente a até 100m',
      tipo: 'Mental',
    ),
    PowerData(
      nome: 'Desmaio Mental',
      descricao: 'Alvo desmaia por 1 minuto (CD 16)',
      tipo: 'Mental',
    ),
    PowerData(
      nome: 'Fúria Induzida',
      descricao: 'Faz alvos atacarem uns aos outros',
      tipo: 'Mental',
    ),
    PowerData(
      nome: 'Manipular Emoções',
      descricao: 'Muda emoções de alvos em 6m de raio',
      tipo: 'Mental',
    ),
    PowerData(
      nome: 'Quebrar Mente',
      descricao: 'Causa 5d8 dano psíquico, alvo fica confuso',
      tipo: 'Mental',
    ),

    // ==================== PODERES DE UTILIDADE (10) ====================
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
    // Novos poderes de utilidade
    PowerData(
      nome: 'Criar Comida e Água',
      descricao: 'Cria alimento e bebida para 5 pessoas',
      tipo: 'Utilidade',
    ),
    PowerData(
      nome: 'Reparação',
      descricao: 'Conserta objetos quebrados instantaneamente',
      tipo: 'Utilidade',
    ),
    PowerData(
      nome: 'Falar com Mortos',
      descricao: 'Conversa com espíritos de falecidos',
      tipo: 'Utilidade',
    ),
    PowerData(
      nome: 'Detectar Mentiras',
      descricao: 'Sabe quando alguém mente',
      tipo: 'Utilidade',
    ),
    PowerData(
      nome: 'Compreender Idiomas',
      descricao: 'Entende e fala qualquer idioma',
      tipo: 'Utilidade',
    ),

    // ==================== PODERES ELEMENTAIS (15) ====================
    // Fogo
    PowerData(
      nome: 'Bola de Fogo',
      descricao: 'Lança uma esfera de chamas (4d6 dano, 6m raio)',
      tipo: 'Elemental',
    ),
    PowerData(
      nome: 'Mãos Flamejantes',
      descricao: 'Armas corpo a corpo causam +2d6 dano de fogo',
      tipo: 'Elemental',
    ),
    PowerData(
      nome: 'Imunidade ao Fogo',
      descricao: 'Imune a dano de fogo e calor',
      tipo: 'Elemental',
    ),
    // Gelo
    PowerData(
      nome: 'Raio Congelante',
      descricao: 'Dispara raio de gelo (3d8 dano, reduz movimento)',
      tipo: 'Elemental',
    ),
    PowerData(
      nome: 'Congelar',
      descricao: 'Congela alvo por 2 rodadas (CD 15)',
      tipo: 'Elemental',
    ),
    PowerData(
      nome: 'Nevasca',
      descricao: 'Cria tempestade de gelo em 10m (2d6/rodada)',
      tipo: 'Elemental',
    ),
    // Raio/Eletricidade
    PowerData(
      nome: 'Relâmpago',
      descricao: 'Atinge linha de 30m (6d6 dano elétrico)',
      tipo: 'Elemental',
    ),
    PowerData(
      nome: 'Pulso Elétrico',
      descricao: 'Atordoa todos em 3m de raio',
      tipo: 'Elemental',
    ),
    PowerData(
      nome: 'Forma Elétrica',
      descricao: 'Transforma-se em eletricidade por 1 turno',
      tipo: 'Elemental',
    ),
    // Vento/Ar
    PowerData(
      nome: 'Lâminas de Vento',
      descricao: 'Cortes de ar em cone (3d8 dano, 9m)',
      tipo: 'Elemental',
    ),
    PowerData(
      nome: 'Tornado',
      descricao: 'Cria tornado que arrasta inimigos (4d6 dano)',
      tipo: 'Elemental',
    ),
    PowerData(
      nome: 'Voo Elemental',
      descricao: 'Voa usando correntes de ar',
      tipo: 'Elemental',
    ),
    // Terra
    PowerData(
      nome: 'Tremor de Terra',
      descricao: 'Causa terremoto em 6m (3d8 dano, derruba alvos)',
      tipo: 'Elemental',
    ),
    PowerData(
      nome: 'Muralha de Pedra',
      descricao: 'Cria parede de rocha (10m x 3m, 50 HP)',
      tipo: 'Elemental',
    ),
    PowerData(
      nome: 'Pele de Rocha',
      descricao: 'Ganha +8 de defesa, mas -2 movimento',
      tipo: 'Elemental',
    ),

    // ==================== PODERES NECROMÂNTICOS (10) ====================
    PowerData(
      nome: 'Reanimar Mortos',
      descricao: 'Levanta 2d4 zumbis por 1 hora',
      tipo: 'Necromancia',
    ),
    PowerData(
      nome: 'Drenar Vida',
      descricao: 'Drena 4d8 PV, cura metade do dano',
      tipo: 'Necromancia',
    ),
    PowerData(
      nome: 'Toque da Morte',
      descricao: 'Toque causa 6d10 de dano necrótico',
      tipo: 'Necromancia',
    ),
    PowerData(
      nome: 'Aura da Morte',
      descricao: 'Criaturas em 3m perdem 2d6 PV/rodada',
      tipo: 'Necromancia',
    ),
    PowerData(
      nome: 'Controlar Mortos-Vivos',
      descricao: 'Comanda mortos-vivos em 30m',
      tipo: 'Necromancia',
    ),
    PowerData(
      nome: 'Raio Sombrio',
      descricao: 'Dispara energia necrótica (5d8 dano)',
      tipo: 'Necromancia',
    ),
    PowerData(
      nome: 'Forma Morta-Viva',
      descricao: 'Transforma-se em morto-vivo por 10 minutos',
      tipo: 'Necromancia',
    ),
    PowerData(
      nome: 'Apodrecer',
      descricao: 'Deteriora matéria orgânica instantaneamente',
      tipo: 'Necromancia',
    ),
    PowerData(
      nome: 'Dor Fantasma',
      descricao: 'Causa dor insuportável (3d8 dano, paralisado)',
      tipo: 'Necromancia',
    ),
    PowerData(
      nome: 'Projeção Astral',
      descricao: 'Separa espírito do corpo por 1 hora',
      tipo: 'Necromancia',
    ),

    // ==================== PODERES DE REALIDADE (5) ====================
    PowerData(
      nome: 'Distorcer Realidade',
      descricao: 'Altera leis físicas em 3m de raio',
      tipo: 'Realidade',
    ),
    PowerData(
      nome: 'Criar Matéria',
      descricao: 'Materializa objetos do nada (até 50kg)',
      tipo: 'Realidade',
    ),
    PowerData(
      nome: 'Apagar Existência',
      descricao: 'Remove objeto/criatura da realidade (CD 20)',
      tipo: 'Realidade',
    ),
    PowerData(
      nome: 'Parar o Tempo',
      descricao: 'Congela o tempo por 1 rodada em 6m',
      tipo: 'Realidade',
    ),
    PowerData(
      nome: 'Reverter Causa',
      descricao: 'Desfaz último evento ocorrido (6 segundos)',
      tipo: 'Realidade',
    ),

    // ==================== PODERES DIVINOS (5) ====================
    PowerData(
      nome: 'Destruição Total',
      descricao: 'Causa 10d10 de dano em 10m de raio',
      tipo: 'Divino',
    ),
    PowerData(
      nome: 'Imortalidade',
      descricao: 'Não pode morrer, regenera completamente',
      tipo: 'Divino',
    ),
    PowerData(
      nome: 'Onipresença',
      descricao: 'Pode estar em múltiplos lugares simultaneamente',
      tipo: 'Divino',
    ),
    PowerData(
      nome: 'Onisciência Local',
      descricao: 'Sabe tudo que acontece em 1km',
      tipo: 'Divino',
    ),
    PowerData(
      nome: 'Controle da Realidade',
      descricao: 'Pode alterar a realidade ao redor (limitado)',
      tipo: 'Divino',
    ),
  ];

  /// Gera poderes aleatórios baseado na categoria
  static List<Power> generatePowers(String category) {
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

  static List<Power> _getRandomPowers(int count, {bool includeGodPowers = false}) {
    final powers = <Power>[];

    // Filtrar poderes divinos se não for um deus
    final availablePowers = includeGodPowers
        ? List<PowerData>.from(_allPowers)
        : _allPowers.where((p) => p.tipo != 'Divino').toList();

    // Embaralhar e pegar os primeiros N
    availablePowers.shuffle(_random);

    for (int i = 0; i < count && i < availablePowers.length; i++) {
      final powerData = availablePowers[i];
      powers.add(Power(
        id: _uuid.v4(),
        nome: powerData.nome,
        descricao: powerData.descricao,
        elemento: _getElementoFromTipo(powerData.tipo),
        habilidades: [],
      ));
    }

    return powers;
  }

  static String _getElementoFromTipo(String tipo) {
    switch (tipo) {
      case 'Combate':
        return 'Energia';
      case 'Defesa':
        return 'Sangue';
      case 'Movimento':
        return 'Energia';
      case 'Percepção':
        return 'Conhecimento';
      case 'Mental':
        return 'Medo';
      case 'Utilidade':
        return 'Conhecimento';
      case 'Elemental':
        return 'Energia';
      case 'Necromancia':
        return 'Morte';
      case 'Realidade':
        return 'Conhecimento';
      case 'Divino':
        return 'Energia';
      default:
        return 'Conhecimento';
    }
  }

  /// Retorna um poder aleatório formatado
  static String getRandomPowerString() {
    final power = _allPowers[_random.nextInt(_allPowers.length)];
    return '${power.nome} (${power.tipo}): ${power.descricao}';
  }
}

import '../../models/power.dart';
import '../../models/character.dart';

/// Template de poder/ritual para geração automática
class PowerTemplate {
  final String nome;
  final String descricao;
  final ElementoOutroLado elemento;
  final int custoPE;
  final int nivelMinimo; // NEX mínimo

  // Detalhes do poder
  final String? efeitos;
  final String? duracao;
  final String? alcance;
  final int? circulo; // Para rituais (1º, 2º, 3º, 4º círculo)

  // Recomendações de classe
  final List<CharacterClass>? classesRecomendadas;

  const PowerTemplate({
    required this.nome,
    required this.descricao,
    required this.elemento,
    required this.custoPE,
    required this.nivelMinimo,
    this.efeitos,
    this.duracao,
    this.alcance,
    this.circulo,
    this.classesRecomendadas,
  });

  /// Verifica se este poder é ritual
  bool get isRitual => circulo != null;

  /// Verifica se o poder é adequado para uma classe
  bool isSuitableForClass(CharacterClass classe) {
    if (classesRecomendadas == null) return true;
    return classesRecomendadas!.contains(classe);
  }

  /// Verifica se o poder está disponível para um NEX
  bool isAvailableForNex(int nex) {
    return nex >= nivelMinimo;
  }
}

/// Banco de dados de templates de poderes
class PowerTemplateDatabase {
  // ========== CONHECIMENTO - PODERES ==========

  static const List<PowerTemplate> conhecimentoPowers = [
    // NEX 5% - Iniciante
    PowerTemplate(
      nome: 'Sentir Ameaça',
      descricao: 'Você sente quando está sendo observado ou quando perigos se aproximam.',
      elemento: ElementoOutroLado.conhecimento,
      custoPE: 1,
      nivelMinimo: 5,
      duracao: '1 cena',
      alcance: 'Pessoal',
      efeitos: '+2 em testes de Percepção para detectar emboscadas ou ameaças ocultas.',
      classesRecomendadas: [CharacterClass.ocultista, CharacterClass.especialista],
    ),
    PowerTemplate(
      nome: 'Detectar Ameaça',
      descricao: 'Você identifica criaturas paranormais próximas.',
      elemento: ElementoOutroLado.conhecimento,
      custoPE: 2,
      nivelMinimo: 5,
      duracao: 'Instantâneo',
      alcance: '9m',
      efeitos: 'Revela presença de entidades paranormais em 9m. Não revela localização exata.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // NEX 10-20% - Intermediário
    PowerTemplate(
      nome: 'Visão do Oculto',
      descricao: 'Você enxerga além do véu da realidade, revelando o paranormal.',
      elemento: ElementoOutroLado.conhecimento,
      custoPE: 3,
      nivelMinimo: 10,
      duracao: '1 cena',
      alcance: 'Pessoal',
      efeitos: 'Enxerga criaturas invisíveis e ocultas. +5 em testes de Ocultismo.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
    PowerTemplate(
      nome: 'Terceiro Olho',
      descricao: 'Você abre um olho mental que revela verdades ocultas.',
      elemento: ElementoOutroLado.conhecimento,
      custoPE: 4,
      nivelMinimo: 20,
      duracao: '1 cena',
      alcance: 'Pessoal',
      efeitos: 'Detecta mentiras automaticamente. Vê através de ilusões.',
      classesRecomendadas: [CharacterClass.ocultista, CharacterClass.especialista],
    ),

    // NEX 35-50% - Avançado
    PowerTemplate(
      nome: 'Precognição',
      descricao: 'Você vislumbra fragmentos do futuro imediato.',
      elemento: ElementoOutroLado.conhecimento,
      custoPE: 5,
      nivelMinimo: 35,
      duracao: '1 turno',
      alcance: 'Pessoal',
      efeitos: 'Role 2 dados em qualquer teste e escolha o melhor resultado.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
    PowerTemplate(
      nome: 'Mente Expandida',
      descricao: 'Sua mente se expande além dos limites normais.',
      elemento: ElementoOutroLado.conhecimento,
      custoPE: 6,
      nivelMinimo: 50,
      duracao: '1 cena',
      alcance: 'Pessoal',
      efeitos: '+10 em testes de Intelecto. Pode usar Intelecto no lugar de outro atributo.',
      classesRecomendadas: [CharacterClass.ocultista, CharacterClass.especialista],
    ),

    // NEX 65-80% - Poderoso
    PowerTemplate(
      nome: 'Omnisciência Momentânea',
      descricao: 'Por um breve momento, você sabe tudo sobre um assunto.',
      elemento: ElementoOutroLado.conhecimento,
      custoPE: 8,
      nivelMinimo: 65,
      duracao: 'Instantâneo',
      alcance: 'Pessoal',
      efeitos: 'Sucesso automático em um teste de conhecimento (Ocultismo, Ciências, etc.).',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
    PowerTemplate(
      nome: 'Visão Total',
      descricao: 'Você enxerga tudo em todas as direções simultaneamente.',
      elemento: ElementoOutroLado.conhecimento,
      custoPE: 10,
      nivelMinimo: 80,
      duracao: '1 cena',
      alcance: '30m',
      efeitos: 'Impossível ser flanqueado ou surpreendido. +10 em Percepção.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // NEX 95%+ - Mestre
    PowerTemplate(
      nome: 'Conhecimento Absoluto',
      descricao: 'Você acessa o conhecimento ilimitado do Outro Lado.',
      elemento: ElementoOutroLado.conhecimento,
      custoPE: 15,
      nivelMinimo: 95,
      duracao: '1 cena',
      alcance: 'Pessoal',
      efeitos: 'Você sabe tudo sobre um local, criatura ou objeto. Acesso a todos os segredos.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
  ];

  // ========== CONHECIMENTO - RITUAIS ==========

  static const List<PowerTemplate> conhecimentoRituals = [
    // 1º Círculo (NEX 10%)
    PowerTemplate(
      nome: 'Amaldiçoar Tecnologia',
      descricao: 'Você amaldiçoa dispositivos eletrônicos, fazendo-os falhar.',
      elemento: ElementoOutroLado.conhecimento,
      custoPE: 2,
      nivelMinimo: 10,
      circulo: 1,
      duracao: '1 cena',
      alcance: 'Toque',
      efeitos: 'Dispositivo eletrônico falha completamente por 1 cena.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // 2º Círculo (NEX 25%)
    PowerTemplate(
      nome: 'Conhecer Itinerário',
      descricao: 'Você descobre o caminho mais seguro para um destino.',
      elemento: ElementoOutroLado.conhecimento,
      custoPE: 4,
      nivelMinimo: 25,
      circulo: 2,
      duracao: '1 dia',
      alcance: 'Pessoal',
      efeitos: 'Revela o caminho mais seguro. Evita armadilhas e perigos no trajeto.',
      classesRecomendadas: [CharacterClass.ocultista, CharacterClass.especialista],
    ),

    // 3º Círculo (NEX 50%)
    PowerTemplate(
      nome: 'Contato Interdimensional',
      descricao: 'Você contata entidades do Outro Lado para obter respostas.',
      elemento: ElementoOutroLado.conhecimento,
      custoPE: 8,
      nivelMinimo: 50,
      circulo: 3,
      duracao: '1 hora',
      alcance: 'Pessoal',
      efeitos: 'Faz 3 perguntas a uma entidade. Respostas são sempre verdadeiras, mas enigmáticas.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // 4º Círculo (NEX 70%)
    PowerTemplate(
      nome: 'Parar o Tempo',
      descricao: 'Você congela o tempo por um breve momento.',
      elemento: ElementoOutroLado.conhecimento,
      custoPE: 12,
      nivelMinimo: 70,
      circulo: 4,
      duracao: '1 turno',
      alcance: '30m',
      efeitos: 'Todas as criaturas (exceto você) ficam paralisadas por 1 turno. Custo: -10 SAN.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
  ];

  // ========== ENERGIA - PODERES ==========

  static const List<PowerTemplate> energiaPowers = [
    // NEX 5% - Iniciante
    PowerTemplate(
      nome: 'Rajada Mental',
      descricao: 'Você dispara uma rajada de energia psíquica contra um inimigo.',
      elemento: ElementoOutroLado.energia,
      custoPE: 2,
      nivelMinimo: 5,
      duracao: 'Instantâneo',
      alcance: '9m',
      efeitos: 'Causa 1d6+Presença de dano mental. Alvo faz teste de Vontade (DT 12) ou fica atordoado.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
    PowerTemplate(
      nome: 'Amplificar Sentidos',
      descricao: 'Você amplifica seus sentidos com energia paranormal.',
      elemento: ElementoOutroLado.energia,
      custoPE: 1,
      nivelMinimo: 5,
      duracao: '1 cena',
      alcance: 'Pessoal',
      efeitos: '+5 em testes de Percepção. Enxerga no escuro.',
      classesRecomendadas: [CharacterClass.especialista, CharacterClass.ocultista],
    ),

    // NEX 10-20% - Intermediário
    PowerTemplate(
      nome: 'Velocidade Sobrenatural',
      descricao: 'Você acelera seus movimentos com energia paranormal.',
      elemento: ElementoOutroLado.energia,
      custoPE: 3,
      nivelMinimo: 10,
      duracao: '1 cena',
      alcance: 'Pessoal',
      efeitos: '+3m deslocamento. +2 em Iniciativa. Ação adicional por turno.',
      classesRecomendadas: [CharacterClass.combatente, CharacterClass.especialista],
    ),
    PowerTemplate(
      nome: 'Escudo de Energia',
      descricao: 'Você cria um escudo de energia pura que absorve danos.',
      elemento: ElementoOutroLado.energia,
      custoPE: 4,
      nivelMinimo: 20,
      duracao: '1 cena',
      alcance: 'Pessoal',
      efeitos: '+5 Defesa. Resistência 5 contra todos os danos.',
      classesRecomendadas: [CharacterClass.ocultista, CharacterClass.combatente],
    ),

    // NEX 35-50% - Avançado
    PowerTemplate(
      nome: 'Sobrecarga',
      descricao: 'Você canaliza energia explosiva através do seu corpo.',
      elemento: ElementoOutroLado.energia,
      custoPE: 6,
      nivelMinimo: 35,
      duracao: '1 cena',
      alcance: 'Pessoal',
      efeitos: '+10 em ataques e dano. Ao fim, sofre 2d6 de dano (ignora resistências).',
      classesRecomendadas: [CharacterClass.combatente, CharacterClass.ocultista],
    ),
    PowerTemplate(
      nome: 'Telecinésia',
      descricao: 'Você move objetos com o poder da mente.',
      elemento: ElementoOutroLado.energia,
      custoPE: 5,
      nivelMinimo: 40,
      duracao: 'Concentração (até 1 cena)',
      alcance: '18m',
      efeitos: 'Move objeto de até 50kg. Pode usar como ataque (1d10+Presença de dano).',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // NEX 65-80% - Poderoso
    PowerTemplate(
      nome: 'Explosão Psíquica',
      descricao: 'Você libera uma explosão devastadora de energia mental.',
      elemento: ElementoOutroLado.energia,
      custoPE: 8,
      nivelMinimo: 65,
      duracao: 'Instantâneo',
      alcance: '15m de raio',
      efeitos: '4d10+Presença de dano mental em área. Alvos fazem Vontade (DT 20) ou ficam atordoados.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
    PowerTemplate(
      nome: 'Forma Energética',
      descricao: 'Você se transforma em energia pura temporariamente.',
      elemento: ElementoOutroLado.energia,
      custoPE: 10,
      nivelMinimo: 80,
      duracao: '1 cena',
      alcance: 'Pessoal',
      efeitos: 'Imune a dano físico. Atravessa paredes. Deslocamento 18m. Ataques causam dano de energia.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // NEX 95%+ - Mestre
    PowerTemplate(
      nome: 'Singularidade',
      descricao: 'Você cria um ponto de energia que colapsa a realidade.',
      elemento: ElementoOutroLado.energia,
      custoPE: 15,
      nivelMinimo: 95,
      duracao: '3 turnos',
      alcance: '30m',
      efeitos: 'Cria singularidade (raio 6m). Tudo é puxado para o centro. 6d10 dano/turno. Destrói terreno.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
  ];

  // ========== ENERGIA - RITUAIS ==========

  static const List<PowerTemplate> energiaRituals = [
    // 1º Círculo (NEX 10%)
    PowerTemplate(
      nome: 'Arma Energizada',
      descricao: 'Você imbuí uma arma com energia paranormal.',
      elemento: ElementoOutroLado.energia,
      custoPE: 2,
      nivelMinimo: 10,
      circulo: 1,
      duracao: '1 cena',
      alcance: 'Toque',
      efeitos: 'Arma causa +1d6 de dano de energia. Ignora armadura normal.',
      classesRecomendadas: [CharacterClass.combatente, CharacterClass.ocultista],
    ),

    // 2º Círculo (NEX 25%)
    PowerTemplate(
      nome: 'Campo de Força',
      descricao: 'Você cria uma barreira impenetrável de energia.',
      elemento: ElementoOutroLado.energia,
      custoPE: 5,
      nivelMinimo: 25,
      circulo: 2,
      duracao: '1 cena',
      alcance: '9m',
      efeitos: 'Barreira (3m x 3m) com 50 PV. Bloqueia ataques físicos e paranormais.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // 3º Círculo (NEX 50%)
    PowerTemplate(
      nome: 'Teletransporte',
      descricao: 'Você se desmaterializa e reaparece em outro local.',
      elemento: ElementoOutroLado.energia,
      custoPE: 8,
      nivelMinimo: 50,
      circulo: 3,
      duracao: 'Instantâneo',
      alcance: '100m',
      efeitos: 'Teleporta para local visível ou conhecido. Pode levar até 3 pessoas tocando você.',
      classesRecomendadas: [CharacterClass.ocultista, CharacterClass.especialista],
    ),

    // 4º Círculo (NEX 70%)
    PowerTemplate(
      nome: 'Desintegração',
      descricao: 'Você desintegra matéria em nível molecular.',
      elemento: ElementoOutroLado.energia,
      custoPE: 12,
      nivelMinimo: 70,
      circulo: 4,
      duracao: 'Instantâneo',
      alcance: '18m',
      efeitos: 'Alvo faz Fortitude (DT 25) ou é desintegrado. Sucesso: sofre 10d10 de dano.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
  ];

  // ========== MORTE - PODERES ==========

  static const List<PowerTemplate> mortePowers = [
    // NEX 5% - Iniciante
    PowerTemplate(
      nome: 'Toque Gélido',
      descricao: 'Seu toque drena a vitalidade de criaturas vivas.',
      elemento: ElementoOutroLado.morte,
      custoPE: 2,
      nivelMinimo: 5,
      duracao: 'Instantâneo',
      alcance: 'Toque',
      efeitos: 'Causa 1d8+Presença de dano necrótico. Você recupera metade dos PV causados.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
    PowerTemplate(
      nome: 'Ver os Mortos',
      descricao: 'Você enxerga espíritos e fantasmas.',
      elemento: ElementoOutroLado.morte,
      custoPE: 1,
      nivelMinimo: 5,
      duracao: '1 cena',
      alcance: 'Pessoal',
      efeitos: 'Enxerga e pode se comunicar com espíritos. Espíritos podem fornecer informações.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // NEX 10-20% - Intermediário
    PowerTemplate(
      nome: 'Drenar Vida',
      descricao: 'Você suga a força vital de um alvo.',
      elemento: ElementoOutroLado.morte,
      custoPE: 3,
      nivelMinimo: 10,
      duracao: 'Instantâneo',
      alcance: '9m',
      efeitos: 'Causa 2d6+Presença necrótico. Você recupera PV igual ao dano causado.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
    PowerTemplate(
      nome: 'Aura de Decadência',
      descricao: 'Uma aura de morte envolve você, enfraquecendo inimigos.',
      elemento: ElementoOutroLado.morte,
      custoPE: 4,
      nivelMinimo: 20,
      duracao: '1 cena',
      alcance: '6m de raio',
      efeitos: 'Inimigos em 6m sofrem -2 em testes. No início do turno, sofrem 1d6 necrótico.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // NEX 35-50% - Avançado
    PowerTemplate(
      nome: 'Animar Morto',
      descricao: 'Você levanta um cadáver como servo zumbi.',
      elemento: ElementoOutroLado.morte,
      custoPE: 5,
      nivelMinimo: 35,
      duracao: '1 dia',
      alcance: '9m',
      efeitos: 'Levanta 1 zumbi com 30 PV que obedece comandos simples. Dura 1 dia.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
    PowerTemplate(
      nome: 'Forma Espectral',
      descricao: 'Você se torna etéreo como um fantasma.',
      elemento: ElementoOutroLado.morte,
      custoPE: 6,
      nivelMinimo: 50,
      duracao: '1 cena',
      alcance: 'Pessoal',
      efeitos: 'Incorpóreo (50% chance de ignorar ataques físicos). Atravessa paredes. Voa 9m.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // NEX 65-80% - Poderoso
    PowerTemplate(
      nome: 'Palavra da Morte',
      descricao: 'Você pronuncia uma palavra que mata instantaneamente.',
      elemento: ElementoOutroLado.morte,
      custoPE: 10,
      nivelMinimo: 65,
      duracao: 'Instantâneo',
      alcance: '18m',
      efeitos: 'Alvo com menos de 50 PV morre instantaneamente. Acima: sofre 8d10 necrótico.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
    PowerTemplate(
      nome: 'Senhor dos Mortos-Vivos',
      descricao: 'Você comanda hordas de mortos-vivos.',
      elemento: ElementoOutroLado.morte,
      custoPE: 8,
      nivelMinimo: 80,
      duracao: '1 cena',
      alcance: '30m',
      efeitos: 'Controla até 10 mortos-vivos. Eles seguem comandos complexos. Cria 3 zumbis poderosos.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // NEX 95%+ - Mestre
    PowerTemplate(
      nome: 'Eclipse da Vida',
      descricao: 'Você extingue toda vida em uma área.',
      elemento: ElementoOutroLado.morte,
      custoPE: 15,
      nivelMinimo: 95,
      duracao: 'Instantâneo',
      alcance: '30m de raio',
      efeitos: 'Todos seres vivos em 30m fazem Fortitude (DT 30) ou morrem. Sucesso: 12d10 necrótico. Custo: -20 SAN.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
  ];

  // ========== MORTE - RITUAIS ==========

  static const List<PowerTemplate> morteRituals = [
    // 1º Círculo (NEX 10%)
    PowerTemplate(
      nome: 'Falar com os Mortos',
      descricao: 'Você conversa com o espírito de um cadáver.',
      elemento: ElementoOutroLado.morte,
      custoPE: 2,
      nivelMinimo: 10,
      circulo: 1,
      duracao: '10 minutos',
      alcance: 'Toque',
      efeitos: 'Faz até 5 perguntas ao cadáver. Respostas são breves mas verdadeiras.',
      classesRecomendadas: [CharacterClass.ocultista, CharacterClass.especialista],
    ),

    // 2º Círculo (NEX 25%)
    PowerTemplate(
      nome: 'Círculo da Morte',
      descricao: 'Você cria um círculo de energia necrótica.',
      elemento: ElementoOutroLado.morte,
      custoPE: 5,
      nivelMinimo: 25,
      circulo: 2,
      duracao: '1 cena',
      alcance: '9m de raio',
      efeitos: 'Cria círculo 9m. Criaturas vivas dentro sofrem 2d6 necrótico por turno. Mortos-vivos são curados.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // 3º Círculo (NEX 50%)
    PowerTemplate(
      nome: 'Reviver os Mortos',
      descricao: 'Você traz alguém de volta da morte.',
      elemento: ElementoOutroLado.morte,
      custoPE: 10,
      nivelMinimo: 50,
      circulo: 3,
      duracao: 'Permanente',
      alcance: 'Toque',
      efeitos: 'Revive criatura morta há até 1 dia. Revivido volta com 1 PV. Custo: -5 SAN permanente.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // 4º Círculo (NEX 70%)
    PowerTemplate(
      nome: 'Praga Necrótica',
      descricao: 'Você espalha uma praga de morte por uma área.',
      elemento: ElementoOutroLado.morte,
      custoPE: 12,
      nivelMinimo: 70,
      circulo: 4,
      duracao: '1 semana',
      alcance: '1km de raio',
      efeitos: 'Área fica necrótica. Criaturas vivas sofrem 3d6 necrótico/dia. Plantas morrem. Água fica contaminada.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
  ];

  // ========== SANGUE - PODERES ==========

  static const List<PowerTemplate> sanguePowers = [
    // NEX 5% - Iniciante
    PowerTemplate(
      nome: 'Lâmina de Sangue',
      descricao: 'Você cria uma lâmina afiada de sangue solidificado.',
      elemento: ElementoOutroLado.sangue,
      custoPE: 2,
      nivelMinimo: 5,
      duracao: '1 cena',
      alcance: 'Pessoal',
      efeitos: 'Cria lâmina (1d8+FOR). Crítico em 19-20. Causa sangramento (1d4/turno por 3 turnos).',
      classesRecomendadas: [CharacterClass.combatente, CharacterClass.ocultista],
    ),
    PowerTemplate(
      nome: 'Sentir Sangue',
      descricao: 'Você sente a presença de sangue próximo.',
      elemento: ElementoOutroLado.sangue,
      custoPE: 1,
      nivelMinimo: 5,
      duracao: '1 cena',
      alcance: '30m',
      efeitos: 'Detecta criaturas vivas em 30m. Sabe quantidade e localização aproximada.',
      classesRecomendadas: [CharacterClass.ocultista, CharacterClass.especialista],
    ),

    // NEX 10-20% - Intermediário
    PowerTemplate(
      nome: 'Armadura de Sangue',
      descricao: 'Seu sangue forma uma armadura protetora ao redor do corpo.',
      elemento: ElementoOutroLado.sangue,
      custoPE: 3,
      nivelMinimo: 10,
      duracao: '1 cena',
      alcance: 'Pessoal',
      efeitos: '+5 Defesa. Resistência 5 a físico. Inimigos em corpo-a-corpo sofrem 1d6 perfurante.',
      classesRecomendadas: [CharacterClass.combatente, CharacterClass.ocultista],
    ),
    PowerTemplate(
      nome: 'Controlar Sangue',
      descricao: 'Você manipula o sangue de uma criatura.',
      elemento: ElementoOutroLado.sangue,
      custoPE: 4,
      nivelMinimo: 20,
      duracao: 'Concentração',
      alcance: '18m',
      efeitos: 'Alvo faz Fortitude (DT 15) ou fica paralisado. Sofre 2d6 necrótico por turno de concentração.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // NEX 35-50% - Avançado
    PowerTemplate(
      nome: 'Fúria Sanguinária',
      descricao: 'Você entra em um transe de violência sobrenatural.',
      elemento: ElementoOutroLado.sangue,
      custoPE: 5,
      nivelMinimo: 35,
      duracao: '1 cena',
      alcance: 'Pessoal',
      efeitos: '+5 FOR e AGI. Ataques corpo-a-corpo causam +2d6 dano. Resistência 10 a dano. Perde controle parcial.',
      classesRecomendadas: [CharacterClass.combatente],
    ),
    PowerTemplate(
      nome: 'Regeneração',
      descricao: 'Seu sangue paranormal regenera ferimentos rapidamente.',
      elemento: ElementoOutroLado.sangue,
      custoPE: 6,
      nivelMinimo: 50,
      duracao: '1 cena',
      alcance: 'Pessoal',
      efeitos: 'Recupera 3d6 PV por turno. Membros decepados se regeneram em 1d4 turnos.',
      classesRecomendadas: [CharacterClass.combatente, CharacterClass.ocultista],
    ),

    // NEX 65-80% - Poderoso
    PowerTemplate(
      nome: 'Tsunami de Sangue',
      descricao: 'Você cria uma onda devastadora de sangue.',
      elemento: ElementoOutroLado.sangue,
      custoPE: 8,
      nivelMinimo: 65,
      duracao: 'Instantâneo',
      alcance: 'Cone 15m',
      efeitos: '5d10 de dano. Alvos fazem Fortitude (DT 22) ou são derrubados e ficam sangrando (2d6/turno).',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
    PowerTemplate(
      nome: 'Forma de Sangue',
      descricao: 'Você se transforma em sangue líquido.',
      elemento: ElementoOutroLado.sangue,
      custoPE: 10,
      nivelMinimo: 80,
      duracao: '1 cena',
      alcance: 'Pessoal',
      efeitos: 'Forma líquida. Imune a dano físico não-mágico. Atravessa frestas. Pode dividir-se.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // NEX 95%+ - Mestre
    PowerTemplate(
      nome: 'Oceano Carmesim',
      descricao: 'Você transforma uma área inteira em um mar de sangue.',
      elemento: ElementoOutroLado.sangue,
      custoPE: 15,
      nivelMinimo: 95,
      duracao: '1 cena',
      alcance: '50m de raio',
      efeitos: 'Área vira oceano de sangue. Inimigos se afogam (4d6/turno). Você controla o sangue como telecinésia massiva. Custo: -15 SAN.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
  ];

  // ========== SANGUE - RITUAIS ==========

  static const List<PowerTemplate> sangueRituals = [
    // 1º Círculo (NEX 10%)
    PowerTemplate(
      nome: 'Pacto de Sangue',
      descricao: 'Você cria um vínculo de sangue com um aliado.',
      elemento: ElementoOutroLado.sangue,
      custoPE: 2,
      nivelMinimo: 10,
      circulo: 1,
      duracao: '1 dia',
      alcance: 'Toque',
      efeitos: 'Você e aliado compartilham PV. Sentem emoções um do outro. +2 em testes quando próximos.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // 2º Círculo (NEX 25%)
    PowerTemplate(
      nome: 'Arma Viva',
      descricao: 'Você transforma uma arma em uma extensão viva de si mesmo.',
      elemento: ElementoOutroLado.sangue,
      custoPE: 5,
      nivelMinimo: 25,
      circulo: 2,
      duracao: '1 cena',
      alcance: 'Toque',
      efeitos: 'Arma ganha +3d6 dano e crítico 18-20. Cura você em 1d6 PV por inimigo abatido.',
      classesRecomendadas: [CharacterClass.combatente, CharacterClass.ocultista],
    ),

    // 3º Círculo (NEX 50%)
    PowerTemplate(
      nome: 'Marca da Caçada',
      descricao: 'Você marca um alvo com sangue, podendo rastreá-lo eternamente.',
      elemento: ElementoOutroLado.sangue,
      custoPE: 8,
      nivelMinimo: 50,
      circulo: 3,
      duracao: 'Permanente até ser cancelado',
      alcance: 'Toque ou 18m',
      efeitos: 'Marca alvo com sangue. Você sempre sabe localização exata. +5 em ataques contra o alvo.',
      classesRecomendadas: [CharacterClass.combatente, CharacterClass.especialista],
    ),

    // 4º Círculo (NEX 70%)
    PowerTemplate(
      nome: 'Explosão Hemorrágica',
      descricao: 'Você faz o sangue de todas as criaturas próximas explodir.',
      elemento: ElementoOutroLado.sangue,
      custoPE: 12,
      nivelMinimo: 70,
      circulo: 4,
      duracao: 'Instantâneo',
      alcance: '30m de raio',
      efeitos: 'Todos seres vivos fazem Fortitude (DT 28) ou sofrem 10d10 de dano interno. Sucesso: metade.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
  ];

  // ========== MEDO - PODERES ==========

  static const List<PowerTemplate> medoPowers = [
    // NEX 5% - Iniciante
    PowerTemplate(
      nome: 'Sussurros Macabros',
      descricao: 'Você sussurra palavras que aterrorizam um alvo.',
      elemento: ElementoOutroLado.medo,
      custoPE: 2,
      nivelMinimo: 5,
      duracao: '1 turno',
      alcance: '9m',
      efeitos: 'Alvo faz Vontade (DT 12) ou fica abalado (-2 em testes). Perde próxima ação.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
    PowerTemplate(
      nome: 'Presença Sinistra',
      descricao: 'Sua presença causa desconforto e medo.',
      elemento: ElementoOutroLado.medo,
      custoPE: 1,
      nivelMinimo: 5,
      duracao: '1 cena',
      alcance: '6m de raio',
      efeitos: 'Inimigos em 6m sofrem -2 em testes de ataque. NPCs comuns fogem.',
      classesRecomendadas: [CharacterClass.ocultista, CharacterClass.especialista],
    ),

    // NEX 10-20% - Intermediário
    PowerTemplate(
      nome: 'Ilusão Aterrorizante',
      descricao: 'Você cria uma ilusão do maior medo do alvo.',
      elemento: ElementoOutroLado.medo,
      custoPE: 3,
      nivelMinimo: 10,
      duracao: '1 cena',
      alcance: '18m',
      efeitos: 'Alvo vê seu maior medo. Vontade (DT 15) ou fica apavorado (foge por 1d4 turnos).',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
    PowerTemplate(
      nome: 'Grito do Terror',
      descricao: 'Você solta um grito sobrenatural que paralisa de medo.',
      elemento: ElementoOutroLado.medo,
      custoPE: 4,
      nivelMinimo: 20,
      duracao: 'Instantâneo',
      alcance: '15m de cone',
      efeitos: 'Alvos fazem Vontade (DT 18) ou ficam paralisados por 1d4 turnos. Sucesso: abalados.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // NEX 35-50% - Avançado
    PowerTemplate(
      nome: 'Pesadelo Vivo',
      descricao: 'Você materializa os piores pesadelos de um alvo.',
      elemento: ElementoOutroLado.medo,
      custoPE: 5,
      nivelMinimo: 35,
      duracao: '1 cena',
      alcance: '18m',
      efeitos: 'Cria criatura de pesadelo (30 PV, +8 ataque, 2d8 dano). Apenas alvo pode vê-la.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
    PowerTemplate(
      nome: 'Invisibilidade',
      descricao: 'Você se torna invisível ao mergulhar nas sombras.',
      elemento: ElementoOutroLado.medo,
      custoPE: 6,
      nivelMinimo: 40,
      duracao: '1 cena ou até atacar',
      alcance: 'Pessoal',
      efeitos: 'Invisível. Ataques com vantagem (+5). Inimigos não podem atacá-lo diretamente.',
      classesRecomendadas: [CharacterClass.especialista, CharacterClass.ocultista],
    ),

    // NEX 65-80% - Poderoso
    PowerTemplate(
      nome: 'Poço do Desespero',
      descricao: 'Você cria uma zona de desespero absoluto.',
      elemento: ElementoOutroLado.medo,
      custoPE: 8,
      nivelMinimo: 65,
      duracao: '1 cena',
      alcance: '12m de raio',
      efeitos: 'Área 12m. Inimigos sofrem -5 em testes. Início do turno: Vontade (DT 25) ou ficam paralisados.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
    PowerTemplate(
      nome: 'Forma das Sombras',
      descricao: 'Você se funde completamente com as sombras.',
      elemento: ElementoOutroLado.medo,
      custoPE: 10,
      nivelMinimo: 80,
      duracao: '1 cena',
      alcance: 'Pessoal',
      efeitos: 'Forma de sombra. Imune a dano físico. Teleporta entre sombras. Causa medo (raio 9m).',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // NEX 95%+ - Mestre
    PowerTemplate(
      nome: 'Apocalipse Mental',
      descricao: 'Você projeta terror absoluto na mente de todos ao redor.',
      elemento: ElementoOutroLado.medo,
      custoPE: 15,
      nivelMinimo: 95,
      duracao: '1 turno',
      alcance: '50m de raio',
      efeitos: 'Todos fazem Vontade (DT 30) ou enlouquecem (Custo: -30 SAN permanente). Sucesso: paralisados 1d4 turnos.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
  ];

  // ========== MEDO - RITUAIS ==========

  static const List<PowerTemplate> medoRituals = [
    // 1º Círculo (NEX 10%)
    PowerTemplate(
      nome: 'Véu de Sombras',
      descricao: 'Você envolve uma área em sombras sobrenaturais.',
      elemento: ElementoOutroLado.medo,
      custoPE: 2,
      nivelMinimo: 10,
      circulo: 1,
      duracao: '1 cena',
      alcance: '9m de raio',
      efeitos: 'Área fica em escuridão sobrenatural. Visão normal não funciona. Inimigos -5 em Percepção.',
      classesRecomendadas: [CharacterClass.ocultista, CharacterClass.especialista],
    ),

    // 2º Círculo (NEX 25%)
    PowerTemplate(
      nome: 'Maldição do Pavor',
      descricao: 'Você amaldiçoa um alvo com medo constante.',
      elemento: ElementoOutroLado.medo,
      custoPE: 5,
      nivelMinimo: 25,
      circulo: 2,
      duracao: '1 semana',
      alcance: '18m',
      efeitos: 'Alvo sofre -3 em todos os testes. Pesadelos constantes (não descansa). Vontade (DT 20) diário para quebrar.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // 3º Círculo (NEX 50%)
    PowerTemplate(
      nome: 'Invocar Pesadelo',
      descricao: 'Você invoca uma criatura de pesadelos do Outro Lado.',
      elemento: ElementoOutroLado.medo,
      custoPE: 8,
      nivelMinimo: 50,
      circulo: 3,
      duracao: '1 cena',
      alcance: '9m',
      efeitos: 'Invoca Criatura de Pesadelo (60 PV, +12 ataque, 3d8 dano). Causa medo em 9m. Obedece comandos.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),

    // 4º Círculo (NEX 70%)
    PowerTemplate(
      nome: 'Reino das Sombras',
      descricao: 'Você transforma uma área no Reino das Sombras.',
      elemento: ElementoOutroLado.medo,
      custoPE: 12,
      nivelMinimo: 70,
      circulo: 4,
      duracao: '1 dia',
      alcance: '100m de raio',
      efeitos: 'Área vira dimensão de sombras. Sempre escuro. Criaturas de pesadelo aparecem. Impossível sair sem ritual. Custo: -10 SAN.',
      classesRecomendadas: [CharacterClass.ocultista],
    ),
  ];

  // ========== MÉTODOS DE ACESSO ==========

  /// Retorna TODOS os templates de poderes (não-rituais)
  static List<PowerTemplate> getAllPowers() {
    return [
      ...conhecimentoPowers,
      ...energiaPowers,
      ...mortePowers,
      ...sanguePowers,
      ...medoPowers,
    ];
  }

  /// Retorna TODOS os templates de rituais
  static List<PowerTemplate> getAllRituals() {
    return [
      ...conhecimentoRituals,
      ...energiaRituals,
      ...morteRituals,
      ...sangueRituals,
      ...medoRituals,
    ];
  }

  /// Retorna TODOS os templates (poderes + rituais)
  static List<PowerTemplate> getAllTemplates() {
    return [...getAllPowers(), ...getAllRituals()];
  }

  /// Filtra templates por elemento
  static List<PowerTemplate> getByElemento(ElementoOutroLado elemento) {
    return getAllTemplates().where((t) => t.elemento == elemento).toList();
  }

  /// Filtra templates por NEX mínimo (retorna todos disponíveis para aquele NEX)
  static List<PowerTemplate> getByNexLevel(int nex) {
    return getAllTemplates().where((t) => t.nivelMinimo <= nex).toList();
  }

  /// Filtra templates por círculo de ritual
  static List<PowerTemplate> getByCirculo(int circulo) {
    return getAllRituals().where((t) => t.circulo == circulo).toList();
  }

  /// Filtra poderes (não-rituais) adequados para uma classe e NEX
  static List<PowerTemplate> getPowersForClass(
    CharacterClass classe,
    int nex, {
    ElementoOutroLado? elemento,
  }) {
    var templates = getAllPowers()
        .where((t) => t.nivelMinimo <= nex && t.isSuitableForClass(classe));

    if (elemento != null) {
      templates = templates.where((t) => t.elemento == elemento);
    }

    return templates.toList();
  }

  /// Filtra rituais adequados para uma classe e NEX
  static List<PowerTemplate> getRitualsForClass(
    CharacterClass classe,
    int nex, {
    ElementoOutroLado? elemento,
  }) {
    var templates = getAllRituals()
        .where((t) => t.nivelMinimo <= nex && t.isSuitableForClass(classe));

    if (elemento != null) {
      templates = templates.where((t) => t.elemento == elemento);
    }

    return templates.toList();
  }

  /// Retorna templates iniciais recomendados (NEX 5%)
  static List<PowerTemplate> getStarterPowers({
    ElementoOutroLado? elemento,
    CharacterClass? classe,
  }) {
    var templates = getAllPowers().where((t) => t.nivelMinimo == 5);

    if (elemento != null) {
      templates = templates.where((t) => t.elemento == elemento);
    }

    if (classe != null) {
      templates = templates.where((t) => t.isSuitableForClass(classe));
    }

    return templates.toList();
  }
}

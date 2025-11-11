import 'dart:math';

/// Gerador de Personalidades para NPCs
/// Sistema procedural que cria backgrounds, personalidades e motivações únicas
class NPCPersonalityGenerator {
  final Random _random = Random();

  /// Gera personalidade completa para um NPC
  NPCPersonality generate({String? nome, String? origem}) {
    return NPCPersonality(
      nome: nome ?? _generateName(),
      personalidade: _generatePersonalityTrait(),
      motivacao: _generateMotivation(),
      segredo: _generateSecret(),
      medo: _generateFear(),
      objetivo: _generateGoal(),
      background: _generateBackground(origem),
      quirk: _generateQuirk(),
      relacionamento: _generateRelationship(),
    );
  }

  String _generateName() {
    final firstNames = [
      'Ana', 'Bruno', 'Carlos', 'Diana', 'Eduardo', 'Fernanda',
      'Gabriel', 'Helena', 'Igor', 'Júlia', 'Lucas', 'Marina',
      'Nicolas', 'Olívia', 'Pedro', 'Raquel', 'Sofia', 'Thiago',
      'Valentina', 'William', 'Alexandre', 'Beatriz', 'Daniel',
      'Elisa', 'Felipe', 'Giovana', 'Henrique', 'Isabela',
    ];

    final lastNames = [
      'Silva', 'Santos', 'Oliveira', 'Souza', 'Costa', 'Pereira',
      'Rodrigues', 'Almeida', 'Nascimento', 'Lima', 'Araújo',
      'Fernandes', 'Carvalho', 'Gomes', 'Martins', 'Rocha',
      'Ribeiro', 'Alves', 'Monteiro', 'Mendes', 'Barros',
    ];

    return '${firstNames[_random.nextInt(firstNames.length)]} ${lastNames[_random.nextInt(lastNames.length)]}';
  }

  String _generatePersonalityTrait() {
    final traits = [
      'Cauteloso e desconfiado',
      'Extrovertido e carismático',
      'Introvertido e observador',
      'Impulsivo e corajoso',
      'Calculista e estratégico',
      'Empático e protetor',
      'Cínico e sarcástico',
      'Otimista e esperançoso',
      'Paranoico e vigilante',
      'Calmo e centrado',
      'Nervoso e ansioso',
      'Arrogante e confiante',
      'Humilde e modesto',
      'Curioso e investigativo',
      'Recluso e solitário',
      'Leal e dedicado',
      'Manipulador e astuto',
      'Honesto e direto',
      'Misterioso e enigmático',
      'Amigável e acolhedor',
    ];

    return traits[_random.nextInt(traits.length)];
  }

  String _generateMotivation() {
    final motivations = [
      'Busca por vingança contra quem matou sua família',
      'Desejo de descobrir a verdade sobre seu passado',
      'Proteção de entes queridos a qualquer custo',
      'Ambição de poder e influência',
      'Busca por redenção de pecados passados',
      'Curiosidade científica sobre o paranormal',
      'Sede de conhecimento proibido',
      'Sobrevivência em um mundo hostil',
      'Lealdade a uma organização ou causa',
      'Medo de perder tudo que conquistou',
      'Esperança de um futuro melhor',
      'Necessidade de provar seu valor',
      'Desejo de escapar do passado',
      'Busca por riqueza e status',
      'Proteção da humanidade contra o oculto',
      'Fascínio pelo poder paranormal',
      'Luta por justiça e ordem',
      'Desejo de caos e destruição',
      'Busca por amor e aceitação',
      'Vontade de desvendar mistérios antigos',
    ];

    return motivations[_random.nextInt(motivations.length)];
  }

  String _generateSecret() {
    final secrets = [
      'Testemunhou um ritual paranormal na infância',
      'Tem contato secreto com uma entidade do Outro Lado',
      'Foi responsável pela morte acidental de alguém',
      'Está sendo caçado por uma organização obscura',
      'Possui sangue de uma linhagem amaldiçoada',
      'Sabe a localização de um artefato poderoso',
      'Trabalha secretamente para dois lados opostos',
      'Teve memórias apagadas e não sabe por quê',
      'É portador de uma marca paranormal',
      'Está sendo possuído lentamente por algo',
      'Traiu alguém importante no passado',
      'Conhece a identidade de um cultista infiltrado',
      'Esconde uma habilidade paranormal',
      'Tem um familiar desaparecido que pode estar vivo',
      'Foi criado por uma ordem secreta',
      'Possui informações que podem destruir a Ordem',
      'Fez um pacto paranormal que cobra seu preço',
      'É descendente de um ocultista famoso',
      'Sabe de uma conspiração dentro da Ordem',
      'Tem uma identidade falsa',
    ];

    return secrets[_random.nextInt(secrets.length)];
  }

  String _generateFear() {
    final fears = [
      'Perder o controle e machucar pessoas amadas',
      'Ser esquecido e não deixar legado',
      'Tornar-se como aqueles que caça',
      'Escuridão total e isolamento',
      'Revelação de seus segredos',
      'Morte de quem ama por sua causa',
      'Perder a sanidade para o paranormal',
      'Ser abandonado e ficar sozinho',
      'Fracassar em sua missão',
      'Repetir os erros do passado',
      'Tornar-se uma marionete do Outro Lado',
      'Espaços fechados e claustrofobia',
      'Alturas e queda livre',
      'Água profunda e afogamento',
      'Ser perseguido por algo invisível',
      'Perder a identidade e memórias',
      'Confiar na pessoa errada novamente',
      'Não ser forte o suficiente quando importar',
      'Ver o fim do mundo que conhece',
      'Transformar-se em um monstro',
    ];

    return fears[_random.nextInt(fears.length)];
  }

  String _generateGoal() {
    final goals = [
      'Reunir provas concretas da existência paranormal',
      'Encontrar e proteger outros como ele',
      'Destruir todos os artefatos amaldiçoados',
      'Subir na hierarquia da Ordem',
      'Descobrir quem é realmente',
      'Vingar a morte de alguém importante',
      'Fechar definitivamente uma brecha',
      'Salvar alguém do Outro Lado',
      'Completar a pesquisa de um mentor falecido',
      'Expor a verdade para o mundo',
      'Encontrar uma cura para maldição',
      'Treinar a próxima geração de agentes',
      'Catalogar todas as entidades conhecidas',
      'Impedir um ritual apocalíptico',
      'Recuperar memórias perdidas',
      'Proteger uma cidade específica',
      'Criar um refúgio seguro do paranormal',
      'Desmantelar um culto perigoso',
      'Encontrar um artefato específico',
      'Provar que não está louco',
    ];

    return goals[_random.nextInt(goals.length)];
  }

  String _generateBackground(String? origem) {
    final backgrounds = {
      'academico': 'Professor universitário que descobriu textos ocultos em arquivos antigos',
      'agente': 'Ex-militar recrutado após testemunhar evento paranormal em missão',
      'artista': 'Pintor que começou a ver visões do Outro Lado através da arte',
      'criminoso': 'Ex-criminoso que teve encontro sobrenatural na prisão',
      'investigador': 'Detetive particular que investigou caso paranormal demais',
      'policial': 'Policial que descobriu conspiração paranormal durante patrulha',
      'militar': 'Soldado veterano de operação classificada envolvendo o oculto',
      'medico': 'Médico que tratou de vítimas de ataques paranormais',
      'jornalista': 'Repórter investigativo que descobriu segredos que não deveria',
    };

    if (origem != null && backgrounds.containsKey(origem.toLowerCase())) {
      return backgrounds[origem.toLowerCase()]!;
    }

    final generic = [
      'Pessoa comum que sobreviveu a um evento paranormal traumático',
      'Filho de agente da Ordem que seguiu os passos da família',
      'Testemunha de fenômeno inexplicável que mudou sua vida',
      'Sobrevivente de ataque de criatura do Outro Lado',
      'Descobriu habilidades paranormais após acidente misterioso',
      'Recrutado pela Ordem após demonstrar resistência ao oculto',
      'Cresceu em cidade marcada por atividade paranormal constante',
      'Encontrou diário de ocultista que revelou verdades terríveis',
      'Salvou por agente da Ordem e decidiu se juntar à causa',
      'Único sobrevivente de ritual que deu errado',
    ];

    return generic[_random.nextInt(generic.length)];
  }

  String _generateQuirk() {
    final quirks = [
      'Sempre carrega um amuleto de proteção',
      'Fala sozinho quando nervoso',
      'Nunca dorme sem luz acesa',
      'Conta ritualisticamente até 3 antes de agir',
      'Anota tudo obsessivamente em caderno',
      'Coleciona objetos paranormais menores',
      'Recita mantra em momentos de stress',
      'Evita espelhos sempre que possível',
      'Verifica portas e janelas múltiplas vezes',
      'Desenha símbolos de proteção em locais novos',
      'Nunca remove um anel/colar específico',
      'Tem pesadelos recorrentes com mesmo símbolo',
      'Vê vultos no canto dos olhos constantemente',
      'Ouve sussurros que outros não percebem',
      'Sente presenças antes delas aparecerem',
      'Treme levemente sem motivo aparente',
      'Evita mencionar certas palavras ou nomes',
      'Faz sinal da cruz mesmo sem ser religioso',
      'Carrega sal em todos os bolsos',
      'Nunca vira as costas para porta aberta',
    ];

    return quirks[_random.nextInt(quirks.length)];
  }

  String _generateRelationship() {
    final relationships = [
      'Mentor: Agente veterano que o treinou',
      'Rival: Outro agente competindo pela mesma promoção',
      'Amor: Pessoa civil que não sabe da verdade',
      'Aliado: Contato em outra organização',
      'Inimigo: Cultista que escapou de missão passada',
      'Família: Irmão/irmã também na Ordem',
      'Contato: Informante no submundo paranormal',
      'Protetor: Alguém que salvou no passado e acompanha',
      'Desconfiança: Superior que não confia completamente',
      'Dívida: Deve favor a alguém poderoso',
      'Estudante: Treina novo recruta promissor',
      'Complexo: Relação amor-ódio com parceiro',
      'Dependência: Precisa de ajuda de especialista',
      'Mistério: Contato anônimo que fornece informações',
      'Obsessão: Caça entidade específica',
      'Memória: Assombrado por perda de parceiro',
      'Lealdade: Segue ordens de líder carismático',
      'Traição: Foi traído por alguém próximo',
      'Conexão: Ligação paranormal com outro agente',
      'Herança: Herdou missão de agente falecido',
    ];

    return relationships[_random.nextInt(relationships.length)];
  }
}

/// Classe que representa a personalidade completa de um NPC
class NPCPersonality {
  final String nome;
  final String personalidade;
  final String motivacao;
  final String segredo;
  final String medo;
  final String objetivo;
  final String background;
  final String quirk;
  final String relacionamento;

  NPCPersonality({
    required this.nome,
    required this.personalidade,
    required this.motivacao,
    required this.segredo,
    required this.medo,
    required this.objetivo,
    required this.background,
    required this.quirk,
    required this.relacionamento,
  });

  /// Exportar para texto formatado
  String toFormattedText() {
    return '''
═══════════════════════════════════
🎭 PERFIL DE PERSONAGEM - NPC
═══════════════════════════════════

📌 NOME: $nome

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎪 PERSONALIDADE:
$personalidade

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 MOTIVAÇÃO:
$motivacao

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔒 SEGREDO:
$segredo

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

😱 MEDO:
$medo

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 OBJETIVO:
$objetivo

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📖 BACKGROUND:
$background

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✨ PECULIARIDADE:
$quirk

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💫 RELACIONAMENTO CHAVE:
$relacionamento

═══════════════════════════════════
🎲 Gerado por Hexatombe RPG
═══════════════════════════════════
''';
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'personalidade': personalidade,
      'motivacao': motivacao,
      'segredo': segredo,
      'medo': medo,
      'objetivo': objetivo,
      'background': background,
      'quirk': quirk,
      'relacionamento': relacionamento,
    };
  }
}

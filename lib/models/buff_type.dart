/// Tipos de buffs que podem ser aplicados por itens
enum BuffType {
  // Buffs de Combate
  aumentarDefesa('Aumentar Defesa', '+{valor} Defesa', '🛡️'),
  aumentarAtaque('Aumentar Ataque', '+{valor} Ataque', '⚔️'),
  aumentarCritico('Aumentar Chance Crítica', '+{valor}% Crítico', '💥'),
  aumentarPrecisao('Aumentar Precisão', '+{valor} Precisão', '🎯'),

  // Buffs de Movimento
  aumentarVelocidade('Aumentar Velocidade', '+{valor} m de movimento', '💨'),
  dobrarMovimento('Dobrar Movimento', 'Movimento x2', '⚡'),
  vooTemporario('Voo Temporário', 'Permite voar', '🦅'),

  // Buffs de Resistência
  resistenciaElemental('Resistência Elemental', 'Resistência a elemento', '🔥'),
  resistenciaParanormal('Resistência Paranormal', '+{valor} contra paranormal', '👻'),
  imunidadeVeneno('Imunidade a Veneno', 'Imune a venenos', '🧪'),
  imunidadeDoenca('Imunidade a Doenças', 'Imune a doenças', '💊'),

  // Buffs de Recuperação
  regeneracao('Regeneração', 'Cura {valor} HP/turno', '💚'),
  estancarSangramento('Estancar Sangramento', 'Para sangramento', '🩸'),
  removerDoenca('Remover Doença', 'Remove doenças', '✨'),
  removerVeneno('Remover Veneno', 'Remove venenos', '🧴'),

  // Buffs Especiais
  reviver('Reviver', 'Revive personagem', '💗'),
  invisibilidade('Invisibilidade', 'Fica invisível', '👁️'),
  visaoNoturna('Visão Noturna', 'Vê no escuro', '🌙'),
  deteccaoParanormal('Detecção Paranormal', 'Detecta entidades', '🔮'),

  // Buffs de Habilidade
  aumentarForca('Aumentar Força', '+{valor} Força', '💪'),
  aumentarAgilidade('Aumentar Agilidade', '+{valor} Agilidade', '🤸'),
  aumentarInteligencia('Aumentar Inteligência', '+{valor} Inteligência', '🧠'),
  aumentarPresenca('Aumentar Presença', '+{valor} Presença', '✨'),
  aumentarVigor('Aumentar Vigor', '+{valor} Vigor', '❤️'),

  // Buffs Negativos (para curas amaldiçoadas)
  envelhecer('Envelhecimento', 'Envelhece {valor} anos', '👴'),
  exaustao('Exaustão', 'Fica exausto', '😵'),
  confusao('Confusão Mental', 'Fica confuso', '😵‍💫'),
  fraqueza('Fraqueza', '-{valor} em testes físicos', '😰'),
  paranoia('Paranoia', 'Ataques de paranoia', '😨');

  final String nome;
  final String descricao;
  final String icone;

  const BuffType(this.nome, this.descricao, this.icone);

  /// Retorna o tipo de buff a partir do nome (para serialização)
  static BuffType fromString(String valor) {
    return BuffType.values.firstWhere(
      (b) => b.name == valor,
      orElse: () => BuffType.aumentarDefesa,
    );
  }

  /// Retorna a descrição formatada com o valor
  String getDescricaoFormatada(int? valor) {
    if (valor == null || !descricao.contains('{valor}')) {
      return descricao;
    }
    return descricao.replaceAll('{valor}', valor.toString());
  }

  /// Verifica se é um buff negativo (para curas amaldiçoadas)
  bool get isNegativo {
    return [
      BuffType.envelhecer,
      BuffType.exaustao,
      BuffType.confusao,
      BuffType.fraqueza,
      BuffType.paranoia,
    ].contains(this);
  }
}

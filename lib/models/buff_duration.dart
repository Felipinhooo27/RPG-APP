/// Duração de um buff aplicado por item
enum BuffDuration {
  instantaneo('Instantâneo', 'Efeito imediato e pontual'),
  turnos('Por Turnos', 'Dura X turnos/rodadas'),
  combate('Até Fim do Combate', 'Dura até o combate acabar'),
  permanente('Permanente', 'Efeito permanente ou até ser removido');

  final String nome;
  final String descricao;

  const BuffDuration(this.nome, this.descricao);

  /// Retorna a duração a partir do nome (para serialização)
  static BuffDuration fromString(String valor) {
    return BuffDuration.values.firstWhere(
      (d) => d.name == valor,
      orElse: () => BuffDuration.instantaneo,
    );
  }

  /// Retorna a descrição formatada com o número de turnos (se aplicável)
  String getDescricaoFormatada(int? turnos) {
    if (this == BuffDuration.turnos && turnos != null) {
      return '$turnos ${turnos == 1 ? "turno" : "turnos"}';
    }
    return nome;
  }

  /// Verifica se requer número de turnos
  bool get requereQuantidade => this == BuffDuration.turnos;
}

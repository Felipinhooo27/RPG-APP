import 'character.dart';

/// Rastreador de combatente individual
/// Mantém estado de combate separado do personagem persistido
class CombatantTracker {
  final Character character;
  final int iniciativaTotal;
  final bool autoUpdatePV; // Se deve salvar mudanças de PV no banco
  int pvAtualCombate; // PV atual durante o combate
  final List<int> dadosRolados; // Dados individuais rolados na iniciativa

  CombatantTracker({
    required this.character,
    required this.iniciativaTotal,
    required this.autoUpdatePV,
    required this.dadosRolados,
  }) : pvAtualCombate = character.pvAtual;

  /// Aplicar dano ao combatente
  void aplicarDano(int dano) {
    pvAtualCombate = (pvAtualCombate - dano).clamp(0, character.pvMax);
  }

  /// Curar o combatente
  void curar(int cura) {
    pvAtualCombate = (pvAtualCombate + cura).clamp(0, character.pvMax);
  }

  /// Verificar se está vivo
  bool get estaVivo => pvAtualCombate > 0;

  /// Verificar se está inconsciente
  bool get estaInconsciente => pvAtualCombate == 0;

  /// Calcular percentual de vida
  double get percentualVida => character.pvMax > 0
      ? (pvAtualCombate / character.pvMax)
      : 0.0;

  CombatantTracker copyWith({
    Character? character,
    int? iniciativaTotal,
    bool? autoUpdatePV,
    int? pvAtualCombate,
    List<int>? dadosRolados,
  }) {
    return CombatantTracker(
      character: character ?? this.character,
      iniciativaTotal: iniciativaTotal ?? this.iniciativaTotal,
      autoUpdatePV: autoUpdatePV ?? this.autoUpdatePV,
      dadosRolados: dadosRolados ?? this.dadosRolados,
    )..pvAtualCombate = pvAtualCombate ?? this.pvAtualCombate;
  }
}

/// Sessão de combate completa
/// Gerencia ordem de turnos, rodadas e estado geral do combate
class CombatSession {
  final List<CombatantTracker> combatentes;
  int rodadaAtual;
  int? turnoAtualIndex; // Index do combatente com o turno atual

  CombatSession({
    required this.combatentes,
    this.rodadaAtual = 1,
    this.turnoAtualIndex,
  });

  /// Ordenar por iniciativa (maior primeiro)
  void ordenarPorIniciativa() {
    combatentes.sort((a, b) => b.iniciativaTotal.compareTo(a.iniciativaTotal));
  }

  /// Próximo turno
  void proximoTurno() {
    if (combatentes.isEmpty) return;

    if (turnoAtualIndex == null) {
      turnoAtualIndex = 0;
    } else {
      turnoAtualIndex = (turnoAtualIndex! + 1) % combatentes.length;
      // Se voltou para o primeiro, incrementa rodada
      if (turnoAtualIndex == 0) {
        rodadaAtual++;
      }
    }
  }

  /// Turno anterior
  void turnoAnterior() {
    if (combatentes.isEmpty) return;

    if (turnoAtualIndex == null) {
      turnoAtualIndex = combatentes.length - 1;
    } else {
      if (turnoAtualIndex == 0) {
        rodadaAtual = (rodadaAtual - 1).clamp(1, 999);
      }
      turnoAtualIndex = (turnoAtualIndex! - 1) % combatentes.length;
      if (turnoAtualIndex! < 0) {
        turnoAtualIndex = combatentes.length - 1;
      }
    }
  }

  /// Combatente do turno atual
  CombatantTracker? get combatenteAtual {
    if (turnoAtualIndex == null || combatentes.isEmpty) return null;
    return combatentes[turnoAtualIndex!];
  }

  /// Resetar combate
  void resetar() {
    rodadaAtual = 1;
    turnoAtualIndex = null;
  }

  /// Remover combatente
  void removerCombatente(int index) {
    if (turnoAtualIndex != null && index < turnoAtualIndex!) {
      turnoAtualIndex = turnoAtualIndex! - 1;
    }
    combatentes.removeAt(index);
    if (combatentes.isEmpty) {
      turnoAtualIndex = null;
    }
  }

  /// Combatentes vivos
  List<CombatantTracker> get combatentesVivos =>
      combatentes.where((c) => c.estaVivo).toList();

  /// Combatentes mortos
  List<CombatantTracker> get combatentesMortos =>
      combatentes.where((c) => !c.estaVivo).toList();

  /// Verificar se o combate acabou (apenas um lado vivo)
  bool get combateEncerrado {
    if (combatentes.isEmpty) return true;
    final vivos = combatentesVivos;
    return vivos.isEmpty || vivos.length == 1;
  }
}

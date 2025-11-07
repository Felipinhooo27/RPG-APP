import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/character.dart';
import '../models/combat_tracker.dart';
import '../services/local_database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class IniciativaScreen extends StatefulWidget {
  const IniciativaScreen({super.key});

  @override
  State<IniciativaScreen> createState() => _IniciativaScreenState();
}

class _IniciativaScreenState extends State<IniciativaScreen> {
  final LocalDatabaseService _databaseService = LocalDatabaseService();
  final Map<String, bool> _selectedCharacters = {};
  final Map<String, bool> _autoUpdatePV = {};
  CombatSession? _combatSession;
  bool _isLoadingCharacters = true;
  List<Character> _allCharacters = [];

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    try {
      final stream = _databaseService.getAllCharacters();
      await for (final characters in stream) {
        if (mounted) {
          setState(() {
            _allCharacters = characters;
            _isLoadingCharacters = false;
          });
        }
        break;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCharacters = false;
        });
      }
    }
  }

  int _rolarIniciativa(Character character, List<int> dadosRolados) {
    final agi = character.agilidade;
    final iniciativaBase = character.iniciativaBase;
    final random = Random();

    if (agi >= 2) {
      for (int i = 0; i < agi; i++) {
        dadosRolados.add(random.nextInt(20) + 1);
      }
      final maiorDado = dadosRolados.reduce((a, b) => a > b ? a : b);
      return iniciativaBase + maiorDado;
    } else if (agi == 1) {
      final dado = random.nextInt(20) + 1;
      dadosRolados.add(dado);
      return iniciativaBase + dado;
    } else if (agi == 0) {
      final dado1 = random.nextInt(20) + 1;
      final dado2 = random.nextInt(20) + 1;
      dadosRolados.add(dado1);
      dadosRolados.add(dado2);
      final menorDado = dado1 < dado2 ? dado1 : dado2;
      return iniciativaBase + menorDado;
    } else {
      final dado = random.nextInt(20) + 1;
      dadosRolados.add(dado);
      return iniciativaBase + dado;
    }
  }

  void _iniciarCombate() {
    final selectedIds = _selectedCharacters.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um combatente'),
          backgroundColor: AppTheme.alertYellow,
        ),
      );
      return;
    }

    final combatentes = <CombatantTracker>[];

    for (final id in selectedIds) {
      final character = _allCharacters.firstWhere((c) => c.id == id);
      final dadosRolados = <int>[];
      final iniciativaTotal = _rolarIniciativa(character, dadosRolados);

      combatentes.add(CombatantTracker(
        character: character,
        iniciativaTotal: iniciativaTotal,
        autoUpdatePV: _autoUpdatePV[id] ?? false,
        dadosRolados: dadosRolados,
      ));
    }

    final session = CombatSession(combatentes: combatentes);
    session.ordenarPorIniciativa();

    setState(() {
      _combatSession = session;
    });
  }

  void _finalizarCombate() {
    setState(() {
      _combatSession = null;
      _selectedCharacters.clear();
      _autoUpdatePV.clear();
    });
  }

  Future<void> _salvarPVNoBanco(CombatantTracker combatente) async {
    if (combatente.autoUpdatePV) {
      await _databaseService.updateCharacterStatus(
        characterId: combatente.character.id,
        pvAtual: combatente.pvAtualCombate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_combatSession != null) {
      return _buildCombatTracker();
    } else {
      return _buildCharacterSelection();
    }
  }

  Widget _buildCharacterSelection() {
    return HexatombeBackground(
      showParticles: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppTheme.abyssalBlack.withOpacity(0.9),
          elevation: 0,
          title: const Text(
            'SISTEMA DE INICIATIVA',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'BebasNeue',
              letterSpacing: 2,
              color: AppTheme.ritualRed,
            ),
          ),
          actions: [
            if (_selectedCharacters.values.any((selected) => selected))
              IconButton(
                icon: const Icon(Icons.play_arrow, color: AppTheme.mutagenGreen),
                tooltip: 'Iniciar Combate',
                onPressed: _iniciarCombate,
              ),
          ],
        ),
        body: _isLoadingCharacters
            ? const Center(child: HexLoading.large())
            : _allCharacters.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.obscureGray,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.ritualRed.withOpacity(0.35),
                                blurRadius: 6,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.group,
                            size: 60,
                            color: AppTheme.ritualRed,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'NENHUM PERSONAGEM',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.coldGray,
                            fontFamily: 'BebasNeue',
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Crie personagens primeiro',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.coldGray,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      RitualCard(
                        glowEffect: true,
                        glowColor: AppTheme.ritualRed,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: AppTheme.ritualRed,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'SELEÇÃO DE COMBATENTES',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.ritualRed,
                                      fontFamily: 'BebasNeue',
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Selecione os personagens que participarão do combate.\n'
                              'Ative "Auto-Salvar PV" para que mudanças sejam salvas na ficha.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.coldGray,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms),
                      const SizedBox(height: 16),
                      ..._allCharacters.asMap().entries.map((entry) {
                        final index = entry.key;
                        final character = entry.value;
                        final isSelected = _selectedCharacters[character.id] ?? false;
                        final autoUpdate = _autoUpdatePV[character.id] ?? false;

                        return RitualCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          glowEffect: isSelected,
                          glowColor: AppTheme.ritualRed,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Checkbox estilizado
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedCharacters[character.id] = !isSelected;
                                        if (!isSelected) {
                                          _autoUpdatePV[character.id] = false;
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.ritualRed.withOpacity(0.2)
                                            : AppTheme.obscureGray,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (isSelected
                                                    ? AppTheme.ritualRed
                                                    : AppTheme.coldGray)
                                                .withOpacity(0.35),
                                            blurRadius: 6,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              color: AppTheme.ritualRed,
                                              size: 28,
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Info do personagem
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          character.nome.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.paleWhite,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${character.classe} • AGI ${character.agilidade} • Init ${character.iniciativaBase}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.coldGray,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Auto-salvar toggle
                              if (isSelected) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.obscureGray.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (autoUpdate
                                                ? AppTheme.mutagenGreen
                                                : AppTheme.coldGray)
                                            .withOpacity(0.3),
                                        blurRadius: 4,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.save,
                                        size: 16,
                                        color: autoUpdate
                                            ? AppTheme.mutagenGreen
                                            : AppTheme.coldGray,
                                      ),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text(
                                          'Auto-Salvar PV na Ficha',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.paleWhite,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ),
                                      Switch(
                                        value: autoUpdate,
                                        onChanged: (value) {
                                          setState(() {
                                            _autoUpdatePV[character.id] = value;
                                          });
                                        },
                                        activeColor: AppTheme.mutagenGreen,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: (index * 50).ms, duration: 300.ms)
                            .slideX(begin: -0.1, end: 0);
                      }),
                    ],
                  ),
      ),
    );
  }

  Widget _buildCombatTracker() {
    final session = _combatSession!;

    return HexatombeBackground(
      showParticles: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppTheme.abyssalBlack.withOpacity(0.9),
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'COMBATE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                  color: AppTheme.ritualRed,
                ),
              ),
              Text(
                'Rodada ${session.rodadaAtual}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.coldGray,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.etherealPurple),
              tooltip: 'Re-rolar Iniciativas',
              onPressed: () {
                setState(() {
                  for (var combatente in session.combatentes) {
                    final dadosRolados = <int>[];
                    final novaIniciativa =
                        _rolarIniciativa(combatente.character, dadosRolados);
                    final novoCombatente = combatente.copyWith(
                      iniciativaTotal: novaIniciativa,
                      dadosRolados: dadosRolados,
                    );
                    final index = session.combatentes.indexOf(combatente);
                    session.combatentes[index] = novoCombatente;
                  }
                  session.ordenarPorIniciativa();
                  session.resetar();
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppTheme.alertYellow),
              tooltip: 'Finalizar Combate',
              onPressed: _finalizarCombate,
            ),
          ],
        ),
        body: Column(
          children: [
            // Controles de Turno
            RitualCard(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              glowEffect: true,
              glowColor: AppTheme.ritualRed,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RODADA ${session.rodadaAtual}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ritualRed,
                          fontFamily: 'BebasNeue',
                          letterSpacing: 1.5,
                        ),
                      ),
                      if (session.combatenteAtual != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.ritualRed.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.ritualRed.withOpacity(0.35),
                                blurRadius: 6,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            session.combatenteAtual!.character.nome.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.paleWhite,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GlowingButton(
                          label: 'Anterior',
                          icon: Icons.arrow_back,
                          onPressed: () {
                            setState(() {
                              session.turnoAnterior();
                            });
                          },
                          style: GlowingButtonStyle.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlowingButton(
                          label: 'Próximo',
                          icon: Icons.arrow_forward,
                          onPressed: () {
                            setState(() {
                              session.proximoTurno();
                            });
                          },
                          style: GlowingButtonStyle.danger,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            // Lista de Combatentes
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: session.combatentes.length,
                itemBuilder: (context, index) {
                  final combatente = session.combatentes[index];
                  final isTurnoAtual = session.turnoAtualIndex == index;

                  return _buildCombatantCard(
                    combatente,
                    index,
                    isTurnoAtual,
                    session,
                  ).animate().fadeIn(delay: (index * 50).ms, duration: 300.ms);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCombatantCard(
    CombatantTracker combatente,
    int index,
    bool isTurnoAtual,
    CombatSession session,
  ) {
    final pvPercent = combatente.percentualVida;
    Color pvColor = AppTheme.mutagenGreen;
    if (pvPercent <= 0.25) {
      pvColor = AppTheme.ritualRed;
    } else if (pvPercent <= 0.5) {
      pvColor = AppTheme.alertYellow;
    }

    return RitualCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      glowEffect: isTurnoAtual,
      glowColor: AppTheme.ritualRed,
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isTurnoAtual
                ? AppTheme.ritualRed.withOpacity(0.2)
                : AppTheme.obscureGray,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: (isTurnoAtual ? AppTheme.ritualRed : AppTheme.coldGray)
                    .withOpacity(0.35),
                blurRadius: 6,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isTurnoAtual ? AppTheme.ritualRed : AppTheme.coldGray,
                fontFamily: 'BebasNeue',
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                combatente.character.nome.toUpperCase(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.paleWhite,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.etherealPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.etherealPurple.withOpacity(0.35),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Text(
                'INIT ${combatente.iniciativaTotal}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.etherealPurple,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Barra de PV
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pvPercent,
                minHeight: 6,
                backgroundColor: AppTheme.obscureGray,
                valueColor: AlwaysStoppedAnimation<Color>(pvColor),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'PV: ${combatente.pvAtualCombate}/${combatente.character.pvMax}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.coldGray,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AGI ${combatente.character.agilidade}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.coldGray,
                    fontFamily: 'Montserrat',
                  ),
                ),
                if (combatente.autoUpdatePV) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.sync,
                    size: 12,
                    color: AppTheme.mutagenGreen,
                  ),
                ],
              ],
            ),
          ],
        ),
        children: [
          // Detalhes da rolagem
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.obscureGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ROLAGEM DE INICIATIVA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.etherealPurple,
                    fontFamily: 'BebasNeue',
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Base: ${combatente.character.iniciativaBase} + Dados: ${combatente.dadosRolados.join(", ")} = ${combatente.iniciativaTotal}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.coldGray,
                    fontFamily: 'Courier',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Controles de PV
          const Text(
            'AJUSTAR PV',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.ritualRed,
              fontFamily: 'BebasNeue',
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPVButton(
                  label: '-5',
                  color: AppTheme.ritualRed,
                  onPressed: () async {
                    setState(() {
                      combatente.aplicarDano(5);
                    });
                    await _salvarPVNoBanco(combatente);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildPVButton(
                  label: '-1',
                  color: AppTheme.ritualRed,
                  onPressed: () async {
                    setState(() {
                      combatente.aplicarDano(1);
                    });
                    await _salvarPVNoBanco(combatente);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 2,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.obscureGray,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: pvColor.withOpacity(0.35),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${combatente.pvAtualCombate}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: pvColor,
                        fontFamily: 'BebasNeue',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildPVButton(
                  label: '+1',
                  color: AppTheme.mutagenGreen,
                  onPressed: () async {
                    setState(() {
                      combatente.curar(1);
                    });
                    await _salvarPVNoBanco(combatente);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildPVButton(
                  label: '+5',
                  color: AppTheme.mutagenGreen,
                  onPressed: () async {
                    setState(() {
                      combatente.curar(5);
                    });
                    await _salvarPVNoBanco(combatente);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Remover do combate
          GlowingButton(
            label: 'Remover do Combate',
            icon: Icons.remove_circle_outline,
            onPressed: () {
              setState(() {
                session.removerCombatente(index);
              });
            },
            style: GlowingButtonStyle.danger,
          ),
        ],
      ),
    );
  }

  Widget _buildPVButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.2),
          foregroundColor: color,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: color, width: 2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
            fontFamily: 'BebasNeue',
          ),
        ),
      ),
    );
  }
}

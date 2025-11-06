import 'dart:math';
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/combat_tracker.dart';
import '../services/local_database_service.dart';
import '../utils/dice_roller.dart';

class IniciativaScreen extends StatefulWidget {
  const IniciativaScreen({super.key});

  @override
  State<IniciativaScreen> createState() => _IniciativaScreenState();
}

class _IniciativaScreenState extends State<IniciativaScreen> {
  final LocalDatabaseService _databaseService = LocalDatabaseService();
  final Map<String, bool> _selectedCharacters = {}; // ID -> selecionado
  final Map<String, bool> _autoUpdatePV = {}; // ID -> auto-update
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
        break; // Pegar apenas o primeiro resultado
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCharacters = false;
        });
      }
    }
  }

  // Rolar iniciativa segundo as regras de AGI
  int _rolarIniciativa(Character character, List<int> dadosRolados) {
    final agi = character.agilidade;
    final iniciativaBase = character.iniciativaBase;
    final random = Random();

    if (agi >= 2) {
      // Rola AGI d20s, pega o maior
      for (int i = 0; i < agi; i++) {
        dadosRolados.add(random.nextInt(20) + 1);
      }
      final maiorDado = dadosRolados.reduce((a, b) => a > b ? a : b);
      return iniciativaBase + maiorDado;
    } else if (agi == 1) {
      // Rola 1 d20
      final dado = random.nextInt(20) + 1;
      dadosRolados.add(dado);
      return iniciativaBase + dado;
    } else if (agi == 0) {
      // Rola 2 d20s, pega o menor
      final dado1 = random.nextInt(20) + 1;
      final dado2 = random.nextInt(20) + 1;
      dadosRolados.add(dado1);
      dadosRolados.add(dado2);
      final menorDado = dado1 < dado2 ? dado1 : dado2;
      return iniciativaBase + menorDado;
    } else {
      // AGI <= -1: Rola 1 d20 (pode ter modificador negativo na base)
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
        const SnackBar(content: Text('Selecione pelo menos um combatente')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Iniciativa'),
        actions: [
          if (_selectedCharacters.values.any((selected) => selected))
            IconButton(
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Iniciar Combate',
              onPressed: _iniciarCombate,
            ),
        ],
      ),
      body: _isLoadingCharacters
          ? const Center(child: CircularProgressIndicator())
          : _allCharacters.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum personagem disponível.\nCrie personagens primeiro.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'SELEÇÃO DE COMBATENTES',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Selecione os personagens que participarão do combate.\n'
                              'Ative "Auto-Salvar PV" para que mudanças sejam salvas na ficha.',
                              style: TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._allCharacters.map((character) {
                      final isSelected = _selectedCharacters[character.id] ?? false;
                      final autoUpdate = _autoUpdatePV[character.id] ?? false;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          children: [
                            CheckboxListTile(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCharacters[character.id] = value ?? false;
                                  if (!value!) {
                                    _autoUpdatePV[character.id] = false;
                                  }
                                });
                              },
                              title: Text(
                                character.nome,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${character.classe} • AGI ${character.agilidade} • '
                                'Iniciativa Base: ${character.iniciativaBase}',
                              ),
                              secondary: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: Text(
                                  character.nome.isNotEmpty
                                      ? character.nome[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 8,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.save, size: 16),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Auto-Salvar PV na Ficha',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    const Spacer(),
                                    Switch(
                                      value: autoUpdate,
                                      onChanged: (value) {
                                        setState(() {
                                          _autoUpdatePV[character.id] = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
    );
  }

  Widget _buildCombatTracker() {
    final session = _combatSession!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Combate - Rodada ${session.rodadaAtual}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
            icon: const Icon(Icons.close),
            tooltip: 'Finalizar Combate',
            onPressed: _finalizarCombate,
          ),
        ],
      ),
      body: Column(
        children: [
          // Controles de Turno
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        session.turnoAnterior();
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Anterior'),
                  ),
                  Column(
                    children: [
                      Text(
                        'Rodada ${session.rodadaAtual}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (session.combatenteAtual != null)
                        Text(
                          'Turno: ${session.combatenteAtual!.character.nome}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        session.proximoTurno();
                      });
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Próximo'),
                  ),
                ],
              ),
            ),
          ),

          // Lista de Combatentes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: session.combatentes.length,
              itemBuilder: (context, index) {
                final combatente = session.combatentes[index];
                final isTurnoAtual = session.turnoAtualIndex == index;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isTurnoAtual
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                      : null,
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: isTurnoAtual
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            combatente.character.nome,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'INIT ${combatente.iniciativaTotal}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        // Barra de PV
                        LinearProgressIndicator(
                          value: combatente.percentualVida,
                          backgroundColor: Colors.red.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            combatente.percentualVida > 0.5
                                ? Colors.green
                                : combatente.percentualVida > 0.25
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PV: ${combatente.pvAtualCombate}/${combatente.character.pvMax} • '
                          'AGI ${combatente.character.agilidade} ${combatente.autoUpdatePV ? "🔄" : ""}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Detalhes da rolagem
                            Text(
                              'Rolagem de Iniciativa:',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Base: ${combatente.character.iniciativaBase} + '
                              'Dados: ${combatente.dadosRolados.join(", ")} = '
                              '${combatente.iniciativaTotal}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const Divider(height: 24),

                            // Controles de PV
                            Text(
                              'Ajustar PV:',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    setState(() {
                                      combatente.aplicarDano(5);
                                    });
                                    await _salvarPVNoBanco(combatente);
                                  },
                                  icon: const Text('-5'),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red.withOpacity(0.2),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    setState(() {
                                      combatente.aplicarDano(1);
                                    });
                                    await _salvarPVNoBanco(combatente);
                                  },
                                  icon: const Text('-1'),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red.withOpacity(0.2),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      '${combatente.pvAtualCombate}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    setState(() {
                                      combatente.curar(1);
                                    });
                                    await _salvarPVNoBanco(combatente);
                                  },
                                  icon: const Text('+1'),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.green.withOpacity(0.2),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    setState(() {
                                      combatente.curar(5);
                                    });
                                    await _salvarPVNoBanco(combatente);
                                  },
                                  icon: const Text('+5'),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.green.withOpacity(0.2),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Campo de dano customizado
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Dano Customizado',
                                      hintText: 'Ex: 15',
                                      isDense: true,
                                    ),
                                    keyboardType: TextInputType.number,
                                    onSubmitted: (value) async {
                                      final dano = int.tryParse(value);
                                      if (dano != null && dano > 0) {
                                        setState(() {
                                          combatente.aplicarDano(dano);
                                        });
                                        await _salvarPVNoBanco(combatente);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    // O dano é aplicado no onSubmitted do TextField
                                  },
                                  child: const Text('Aplicar'),
                                ),
                              ],
                            ),

                            // Botão de remover
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  session.removerCombatente(index);
                                });
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                              label: const Text('Remover do Combate'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

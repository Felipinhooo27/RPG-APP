import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/dice_pool.dart';
import '../../models/dice_result.dart';
import '../../models/dice_roll_history.dart';
import '../../core/database/dice_repository.dart';
import '../../widgets/dice/hexagon_dice_button.dart';
import '../../widgets/dice/hexagon_result_badge.dart';
import '../../widgets/dice/results_splash_area.dart';
import '../../widgets/dice/formula_staging.dart';
import '../../widgets/hexatombe_ui_components.dart';
import 'dice_history_screen.dart';

/// Tela de rolagem de dados estilo Google
class GoogleDiceRollerScreen extends StatefulWidget {
  const GoogleDiceRollerScreen({super.key});

  @override
  State<GoogleDiceRollerScreen> createState() => _GoogleDiceRollerScreenState();
}

class _GoogleDiceRollerScreenState extends State<GoogleDiceRollerScreen> {
  final DiceRepository _repository = DiceRepository();
  final math.Random _random = math.Random();

  DicePool _currentPool = DicePool();
  List<DiceResult> _lastResults = [];
  List<DiceRollHistory> _history = [];
  bool _isRolling = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _repository.loadHistory();
    setState(() {
      _history = history;
    });
  }

  /// Adiciona um dado ao pool
  void _addDice(DiceType type) {
    setState(() {
      _currentPool = _currentPool.addDice(type);
    });
  }

  /// Retorna quantos dados de um tipo específico estão no pool
  int _getDiceCount(DiceType type) {
    return _currentPool.dice.where((d) => d.type == type).length;
  }

  /// Remove um dado do pool
  void _removeDice(String diceId) {
    setState(() {
      _currentPool = _currentPool.removeDice(diceId);
    });
  }

  /// Limpa todos os dados do pool
  void _clearPool() {
    setState(() {
      _currentPool = _currentPool.clear();
    });
  }

  /// Mostra dialog para adicionar modificador
  void _showModifierDialog() {
    final controller = TextEditingController(
      text: _currentPool.modifier != 0 ? _currentPool.modifier.toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.deepBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.magenta, width: 2),
        ),
        title: const Text(
          'MODIFICADOR',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: AppColors.scarletRed,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Ex: +5 ou -3',
            hintStyle: TextStyle(color: Colors.grey),
            prefixText: '+',
            prefixStyle: TextStyle(color: AppColors.magenta),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.magenta),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.magenta, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text) ?? 0;
              setState(() {
                _currentPool = _currentPool.updateModifier(value);
              });
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: AppColors.magenta)),
          ),
        ],
      ),
    );
  }

  /// Rola todos os dados do pool
  Future<void> _rollDice() async {
    if (_currentPool.dice.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Adicione dados ao pool primeiro!'),
          backgroundColor: AppColors.neonRed,
        ),
      );
      return;
    }

    setState(() {
      _isRolling = true;
      _lastResults = [];
    });

    // Pequeno delay para a animação
    await Future.delayed(const Duration(milliseconds: 100));

    // Rola cada dado
    final results = <DiceResult>[];
    for (final diceItem in _currentPool.dice) {
      final value = _random.nextInt(diceItem.type.sides) + 1;
      results.add(DiceResult(
        type: diceItem.type,
        value: value,
      ));
    }

    // Calcula o total
    final diceTotal = results.fold(0, (sum, r) => sum + r.value);
    final total = diceTotal + _currentPool.modifier;

    // Cria entrada no histórico
    final historyEntry = DiceRollHistory(
      formula: _currentPool.formula,
      results: results,
      modifier: _currentPool.modifier,
      total: total,
    );

    // Salva no histórico
    await _repository.addRoll(historyEntry);

    setState(() {
      _lastResults = results;
      _isRolling = false;
      _history.insert(0, historyEntry);
    });
  }

  /// Volta para o pool (limpa resultados mas mantém o pool)
  void _returnToPool() {
    setState(() {
      _lastResults = [];
    });
  }

  /// Limpa tudo (pool, modificador e resultados)
  void _clearAll() {
    setState(() {
      _currentPool = _currentPool.clear();
      _currentPool = _currentPool.updateModifier(0);
      _lastResults = [];
    });
  }

  /// Calcula o total dos últimos resultados
  int get _total {
    if (_lastResults.isEmpty) return 0;
    final diceTotal = _lastResults.fold(0, (sum, r) => sum + r.value);
    return diceTotal + _currentPool.modifier;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: SafeArea(
        child: Column(
          children: [
            // Área de resultados e histórico
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Título
                    Text(
                      'Jogar os dados',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3.0,
                        color: Color(0xFFe0e0e0),
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Fórmula de Preparação
                    FormulaStaging(pool: _currentPool),

                    // Área de Invocação
                    ResultsSplashArea(
                      pool: _currentPool,
                      results: _lastResults,
                      total: _lastResults.isNotEmpty ? _total : null,
                      isRolling: _isRolling,
                      onRemoveDice: _removeDice,
                    ),

                    const SizedBox(height: 32),

                    // Log de Ritual (Histórico Refatorado)
                    if (_history.isNotEmpty) ...[
                      // Divisor
                      const GrungeDivider(heavy: true),
                      const SizedBox(height: 24),

                      // Cabeçalho (sem caixas)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'HISTÓRICO',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.5,
                              color: AppColors.scarletRed,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Row(
                            children: [
                              // Botão Ver Tudo (apenas texto)
                              InkWell(
                                onTap: _navigateToFullHistory,
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'VER TUDO',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      color: Color(0xFFe0e0e0),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Botão Limpar (apenas texto vermelho)
                              InkWell(
                                onTap: _confirmClearHistory,
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'LIMPAR',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      color: AppColors.scarletRed,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._history.take(2).map((entry) => _buildHistoryItem(entry)),
                    ],
                  ],
                ),
              ),
            ),

            // Barra do Arsenal (fixo na parte inferior)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF0d0d0d),
              ),
              child: Column(
                children: [
                  // Linha de hexágonos (sem modificador)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        HexagonDiceButton(
                          faces: 4,
                          count: _getDiceCount(DiceType.d4),
                          onTap: () => _addDice(DiceType.d4),
                        ),
                        const SizedBox(width: 8),
                        HexagonDiceButton(
                          faces: 6,
                          count: _getDiceCount(DiceType.d6),
                          onTap: () => _addDice(DiceType.d6),
                        ),
                        const SizedBox(width: 8),
                        HexagonDiceButton(
                          faces: 8,
                          count: _getDiceCount(DiceType.d8),
                          onTap: () => _addDice(DiceType.d8),
                        ),
                        const SizedBox(width: 8),
                        HexagonDiceButton(
                          faces: 10,
                          count: _getDiceCount(DiceType.d10),
                          onTap: () => _addDice(DiceType.d10),
                        ),
                        const SizedBox(width: 8),
                        HexagonDiceButton(
                          faces: 12,
                          count: _getDiceCount(DiceType.d12),
                          onTap: () => _addDice(DiceType.d12),
                        ),
                        const SizedBox(width: 8),
                        HexagonDiceButton(
                          faces: 20,
                          count: _getDiceCount(DiceType.d20),
                          onTap: () => _addDice(DiceType.d20),
                        ),
                        const SizedBox(width: 8),
                        HexagonDiceButton(
                          faces: 100,
                          count: _getDiceCount(DiceType.d100),
                          onTap: () => _addDice(DiceType.d100),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Linha de botões: ± | ROLAR/VOLTAR | X
                  Row(
                    children: [
                      // Botão ± (modificador)
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _showModifierDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentPool.modifier != 0
                                ? const Color(0xFF673AB7).withOpacity(0.3)
                                : const Color(0xFF2a2a2a),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentPool.modifier == 0
                                ? '±'
                                : (_currentPool.modifier > 0
                                    ? '+${_currentPool.modifier}'
                                    : '${_currentPool.modifier}'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Botão ROLAR/VOLTAR (central - ocupa espaço restante)
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isRolling
                                ? null
                                : (_lastResults.isNotEmpty
                                    ? _returnToPool
                                    : (_currentPool.dice.isEmpty ? null : _rollDice)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.scarletRed,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFF2a2a2a),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              elevation: 0,
                              shadowColor: AppColors.scarletRed.withOpacity(0.5),
                            ),
                            child: Text(
                              _isRolling
                                  ? 'INVOCANDO...'
                                  : (_lastResults.isNotEmpty ? 'V O L T A R' : 'R O L A R'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4.0,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Botão X (limpar tudo)
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: (_currentPool.dice.isEmpty &&
                                  _currentPool.modifier == 0 &&
                                  _lastResults.isEmpty)
                              ? null
                              : _clearAll,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2a2a2a),
                            foregroundColor: AppColors.neonRed,
                            disabledBackgroundColor: const Color(0xFF1a1a1a),
                            disabledForegroundColor: const Color(0xFF444444),
                            padding: EdgeInsets.zero,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            elevation: 0,
                          ),
                          child: const Icon(Icons.close, size: 28),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(DiceRollHistory entry) {
    final dateFormat = DateFormat('HH:mm:ss');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF2a2a2a),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Timestamp
          Text(
            dateFormat.format(entry.timestamp),
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 16),
          // Fórmula
          Expanded(
            child: Text(
              entry.formula,
              style: const TextStyle(
                color: Color(0xFFe0e0e0),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Total em hexágono (Glifo de Resultado)
          HexagonResultBadge(
            value: entry.total,
            isSmall: true,
          ),
        ],
      ),
    );
  }

  /// Navega para a tela de histórico completo
  Future<void> _navigateToFullHistory() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DiceHistoryScreen(initialHistory: _history),
      ),
    );

    // Se o histórico foi limpo na outra tela, recarrega
    if (result == true) {
      _loadHistory();
    }
  }

  /// Mostra dialog de confirmação para limpar histórico
  Future<void> _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text(
          'LIMPAR HISTÓRICO?',
          style: TextStyle(color: AppColors.lightGray),
        ),
        content: const Text(
          'Esta ação irá excluir todas as rolagens do histórico. Esta ação não pode ser desfeita.',
          style: TextStyle(color: AppColors.silver),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonRed,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('LIMPAR TUDO'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.clearHistory();
        setState(() => _history.clear());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Histórico limpo com sucesso!'),
              backgroundColor: AppColors.conhecimentoGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao limpar histórico: $e'),
              backgroundColor: AppColors.neonRed,
            ),
          );
        }
      }
    }
  }
}

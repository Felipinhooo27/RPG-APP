import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/dice_pool.dart';
import '../../models/dice_result.dart';
import '../../models/dice_roll_history.dart';
import '../../core/database/dice_repository.dart';
import '../../widgets/dice_pool_item.dart';
import '../../widgets/dice_result_item.dart';
import '../../widgets/dice_type_button.dart';
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
        title: Text(
          'Modificador',
          style: AppTextStyles.titleSmall.copyWith(color: AppColors.magenta),
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

  /// Calcula o total dos últimos resultados
  int get _total {
    if (_lastResults.isEmpty) return 0;
    final diceTotal = _lastResults.fold(0, (sum, r) => sum + r.value);
    return diceTotal + _currentPool.modifier;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Área de resultados e pool
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Título
                    Text(
                      'Jogar os dados',
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.magenta,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Mesa de Dados unificada (SEMPRE VISÍVEL)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.deepBlack,
                        border: Border.all(
                          color: AppColors.magenta.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mesa de Dados',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.magenta,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  // Badge de total (quando há resultados)
                                  if (_lastResults.isNotEmpty) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.orange,
                                          width: 2,
                                        ),
                                      ),
                                      child: Text(
                                        'Total $_total',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  // Botão Limpar (só aparece quando há dados)
                                  if (_currentPool.dice.isNotEmpty || _lastResults.isNotEmpty)
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _lastResults = [];
                                          _currentPool = _currentPool.clear();
                                        });
                                      },
                                      icon: Icon(
                                        Icons.clear_all,
                                        color: AppColors.neonRed,
                                        size: 18,
                                      ),
                                      label: Text(
                                        'Limpar',
                                        style: TextStyle(
                                          color: AppColors.neonRed,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Área de dados - mostra pool, resultados OU mensagem vazia
                          if (_currentPool.dice.isEmpty && _lastResults.isEmpty)
                            // Mesa vazia
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Adicione dados para começar',
                                  style: TextStyle(
                                    color: AppColors.silver.withValues(alpha: 0.5),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          else if (_lastResults.isEmpty)
                            // Mostra pool (antes de rolar)
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _currentPool.dice
                                  .map((diceItem) => DicePoolItemWidget(
                                        diceItem: diceItem,
                                        onRemove: () => _removeDice(diceItem.id),
                                      ))
                                  .toList(),
                            )
                          else
                            // Mostra resultados (depois de rolar)
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _lastResults
                                  .map((result) => DiceResultItemWidget(
                                        result: result,
                                        animate: true,
                                      ))
                                  .toList(),
                            ),

                          const SizedBox(height: 12),

                          // Fórmula (apenas quando há dados no pool e não há resultados)
                          if (_currentPool.dice.isNotEmpty && _lastResults.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.magenta.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _currentPool.formula,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.magenta,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Histórico
                    if (_history.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Histórico',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.magenta,
                            ),
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: _navigateToFullHistory,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.magenta),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.history, color: AppColors.magenta, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'VER TUDO',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.magenta,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: _confirmClearHistory,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.neonRed),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.delete_outline, color: AppColors.neonRed, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'LIMPAR',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.neonRed,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._history.take(2).map((entry) => _buildHistoryItem(entry)),
                    ],
                  ],
                ),
              ),
            ),

            // Botões de controle (fixos na parte inferior)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.deepBlack,
                border: Border(
                  top: BorderSide(
                    color: AppColors.magenta.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Botões de tipos de dados
                  Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      DiceTypeButton(
                        type: DiceType.d4,
                        onPressed: () => _addDice(DiceType.d4),
                      ),
                      DiceTypeButton(
                        type: DiceType.d6,
                        onPressed: () => _addDice(DiceType.d6),
                      ),
                      DiceTypeButton(
                        type: DiceType.d8,
                        onPressed: () => _addDice(DiceType.d8),
                      ),
                      DiceTypeButton(
                        type: DiceType.d10,
                        onPressed: () => _addDice(DiceType.d10),
                      ),
                      DiceTypeButton(
                        type: DiceType.d12,
                        onPressed: () => _addDice(DiceType.d12),
                      ),
                      DiceTypeButton(
                        type: DiceType.d20,
                        onPressed: () => _addDice(DiceType.d20),
                      ),
                      DiceTypeButton(
                        type: DiceType.d100,
                        onPressed: () => _addDice(DiceType.d100),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Botão modificador e rolar
                  Row(
                    children: [
                      // Botão modificador
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: _showModifierDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.magenta.withValues(alpha: 0.2),
                            foregroundColor: AppColors.magenta,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: AppColors.magenta, width: 2),
                            ),
                          ),
                          child: Text(
                            _currentPool.modifier == 0
                                ? '±'
                                : '${_currentPool.modifier > 0 ? '+' : ''}${_currentPool.modifier}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botão rolar
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: _isRolling ? null : _rollDice,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                          ),
                          child: Text(
                            _isRolling ? 'Rolando...' : 'Rolar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deepBlack,
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Timestamp
          Text(
            dateFormat.format(entry.timestamp),
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
          // Fórmula
          Expanded(
            child: Text(
              entry.formula,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          // Total
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${entry.total}',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
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

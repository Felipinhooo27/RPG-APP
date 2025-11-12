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

                    // Pool de dados (mesa)
                    if (_currentPool.dice.isNotEmpty) ...[
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
                                TextButton.icon(
                                  onPressed: _clearPool,
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
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _currentPool.dice
                                  .map((diceItem) => DicePoolItemWidget(
                                        diceItem: diceItem,
                                        onRemove: () => _removeDice(diceItem.id),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 12),
                            // Fórmula
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
                    ],

                    // Resultados
                    if (_lastResults.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.deepBlack,
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Resultados',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                              ],
                            ),
                            const SizedBox(height: 12),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Histórico
                    if (_history.isNotEmpty) ...[
                      Text(
                        'Histórico',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.magenta,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._history.take(10).map((entry) => _buildHistoryItem(entry)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
}

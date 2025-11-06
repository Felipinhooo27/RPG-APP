import 'package:flutter/material.dart';
import '../utils/dice_roller.dart';

class DiceRollerScreen extends StatefulWidget {
  const DiceRollerScreen({super.key});

  @override
  State<DiceRollerScreen> createState() => _DiceRollerScreenState();
}

class _DiceRollerScreenState extends State<DiceRollerScreen> {
  final DiceRoller _diceRoller = DiceRoller();
  final TextEditingController _formulaController = TextEditingController();
  final List<DiceRollHistory> _history = [];

  @override
  void dispose() {
    _formulaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rolador de Dados'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                setState(() {
                  _history.clear();
                });
              },
              tooltip: 'Limpar histórico',
            ),
        ],
      ),
      body: Column(
        children: [
          // Input e botões de rolagem
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Digite a fórmula de dados',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _formulaController,
                  decoration: InputDecoration(
                    hintText: 'ex: 1d20+5, 2d6+1d8, 3d10',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _formulaController.clear(),
                    ),
                  ),
                  textCapitalization: TextCapitalization.none,
                  onSubmitted: (_) => _rollDice(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _rollDice,
                    icon: const Icon(Icons.casino),
                    label: const Text('Rolar Dados'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Atalhos rápidos:',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickDiceButton(
                      label: '1d20',
                      onPressed: () => _quickRoll('1d20'),
                    ),
                    _QuickDiceButton(
                      label: '1d12',
                      onPressed: () => _quickRoll('1d12'),
                    ),
                    _QuickDiceButton(
                      label: '1d10',
                      onPressed: () => _quickRoll('1d10'),
                    ),
                    _QuickDiceButton(
                      label: '1d8',
                      onPressed: () => _quickRoll('1d8'),
                    ),
                    _QuickDiceButton(
                      label: '1d6',
                      onPressed: () => _quickRoll('1d6'),
                    ),
                    _QuickDiceButton(
                      label: '1d4',
                      onPressed: () => _quickRoll('1d4'),
                    ),
                    _QuickDiceButton(
                      label: '2d6',
                      onPressed: () => _quickRoll('2d6'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Histórico de rolagens
          Expanded(
            child: _history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.casino_outlined,
                          size: 80,
                          color: Colors.white38,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma rolagem ainda',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Digite uma fórmula e role os dados!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white54,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _history.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final history = _history[_history.length - 1 - index];
                      return _HistoryCard(history: history);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _quickRoll(String formula) {
    _formulaController.text = formula;
    _rollDice();
  }

  void _rollDice() {
    final formula = _formulaController.text.trim();

    if (formula.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite uma fórmula de dados')),
      );
      return;
    }

    try {
      final result = _diceRoller.roll(formula);
      setState(() {
        _history.add(DiceRollHistory(
          formula: formula,
          result: result,
          timestamp: DateTime.now(),
        ));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fórmula inválida: $e')),
      );
    }
  }
}

class _QuickDiceButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _QuickDiceButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final DiceRollHistory history;

  const _HistoryCard({required this.history});

  @override
  Widget build(BuildContext context) {
    final timeStr = '${history.timestamp.hour.toString().padLeft(2, '0')}:'
        '${history.timestamp.minute.toString().padLeft(2, '0')}:'
        '${history.timestamp.second.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    history.formula,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Text(
                  timeStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            // Detalhes de cada dado rolado
            for (final roll in history.result.rolls) ...[
              if (roll.numberOfDice > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${roll.numberOfDice}d${roll.sides}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '[${roll.results.join(', ')}]',
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                      Text(
                        '= ${roll.total}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              else if (roll.modifier != 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Mod',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          roll.modifier > 0 ? '+${roll.modifier}' : '${roll.modifier}',
                        ),
                      ),
                      Text(
                        '= ${roll.modifier}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            // Resultado final
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'TOTAL: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    history.result.total.toString(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiceRollHistory {
  final String formula;
  final DiceRollResult result;
  final DateTime timestamp;

  DiceRollHistory({
    required this.formula,
    required this.result,
    required this.timestamp,
  });
}

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/dice_roller.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

/// Minimalist dice roller screen with SVG dice - Hexatombe Design
class DiceRollerScreen extends StatefulWidget {
  const DiceRollerScreen({super.key});

  @override
  State<DiceRollerScreen> createState() => _DiceRollerScreenState();
}

class _DiceRollerScreenState extends State<DiceRollerScreen> {
  final DiceRoller _diceRoller = DiceRoller();
  final List<DiceRollResult> _history = [];

  DiceType _selectedDiceType = DiceType.d20;
  int _quantity = 1;
  int _modifier = 0;
  bool _isRolling = false;
  int? _lastResult;
  String? _lastFormula;

  final Map<DiceType, int> _diceSides = {
    DiceType.d4: 4,
    DiceType.d6: 6,
    DiceType.d8: 8,
    DiceType.d10: 10,
    DiceType.d12: 12,
    DiceType.d20: 20,
    DiceType.d100: 100,
  };

  void _rollDice() async {
    if (_isRolling) return;

    setState(() {
      _isRolling = true;
      _lastResult = null;
    });

    // Simulate rolling animation
    await Future.delayed(const Duration(milliseconds: 1000));

    final sides = _diceSides[_selectedDiceType]!;
    String formula = '$_quantity' + 'd$sides';
    if (_modifier > 0) {
      formula += '+$_modifier';
    } else if (_modifier < 0) {
      formula += '$_modifier'; // negative sign already included
    }

    final result = _diceRoller.roll(formula);

    setState(() {
      _isRolling = false;
      _lastResult = result.total;
      _lastFormula = formula;
      _history.insert(0, result);

      // Keep only last 50 rolls
      if (_history.length > 50) {
        _history.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return HexatombeBackground(
      showParticles: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppTheme.deepBlack.withOpacity(0.95),
          elevation: 0,
          title: const Text(
            'ROLADOR DE DADOS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'BebasNeue',
              letterSpacing: 2,
              color: AppTheme.pureWhite,
            ),
          ),
          actions: [
            if (_history.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.history, color: AppTheme.scarletRed, size: 22),
                onPressed: _showHistoryModal,
                tooltip: 'Histórico',
              ),
            if (_history.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.iron, size: 22),
                onPressed: () {
                  setState(() {
                    _history.clear();
                    _lastResult = null;
                  });
                },
                tooltip: 'Limpar',
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Main dice display
                    _buildMainDiceDisplay(),

                    const SizedBox(height: 32),

                    // Dice type selector
                    _buildDiceTypeSelector(),

                    const SizedBox(height: 24),

                    // Quantity and modifier controls
                    _buildControlsRow(),

                    const SizedBox(height: 24),

                    // Roll button
                    _buildRollButton(),

                    const SizedBox(height: 24),

                    // Last result
                    if (_lastResult != null) _buildResultDisplay(),

                    const SizedBox(height: 16),

                    // Quick history
                    if (_history.isNotEmpty) _buildQuickHistory(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainDiceDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.deepBlack,
        border: Border.all(
          color: AppTheme.scarletRed.withOpacity(_isRolling ? 1.0 : 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Dice SVG
          AnimatedDice(
            type: _selectedDiceType,
            result: _lastResult,
            isRolling: _isRolling,
            size: 140,
            color: AppTheme.scarletRed,
          ),

          const SizedBox(height: 16),

          // Current formula
          Text(
            _buildFormulaString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'SpaceMono',
              color: AppTheme.silver,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _buildFormulaString() {
    final sides = _diceSides[_selectedDiceType]!;
    String formula = '$_quantity' + 'd$sides';
    if (_modifier > 0) {
      formula += ' + $_modifier';
    } else if (_modifier < 0) {
      formula += ' - ${_modifier.abs()}';
    }
    return formula;
  }

  Widget _buildDiceTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TIPO DE DADO',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
            color: AppTheme.lightGray,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: DiceType.values.map((type) {
              final isSelected = type == _selectedDiceType;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDiceType = type;
                    });
                  },
                  child: Container(
                    width: 70,
                    height: 90,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.scarletRed.withOpacity(0.1) : AppTheme.darkGray,
                      border: Border.all(
                        color: isSelected ? AppTheme.scarletRed : AppTheme.steel.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DiceSvg(
                          type: type,
                          size: 40,
                          color: isSelected ? AppTheme.scarletRed : AppTheme.silver,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'd${_diceSides[type]}'.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'SpaceMono',
                            color: isSelected ? AppTheme.scarletRed : AppTheme.silver,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildControlsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildCounter(
            label: 'QUANTIDADE',
            value: _quantity,
            onDecrease: () {
              if (_quantity > 1) {
                setState(() => _quantity--);
              }
            },
            onIncrease: () {
              if (_quantity < 10) {
                setState(() => _quantity++);
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCounter(
            label: 'MODIFICADOR',
            value: _modifier,
            onDecrease: () {
              if (_modifier > -20) {
                setState(() => _modifier--);
              }
            },
            onIncrease: () {
              if (_modifier < 20) {
                setState(() => _modifier++);
              }
            },
            showSign: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCounter({
    required String label,
    required int value,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
    bool showSign = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
            color: AppTheme.lightGray,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.darkGray,
            border: Border.all(
              color: AppTheme.steel.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _buildCounterButton(
                icon: Icons.remove,
                onPressed: onDecrease,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    showSign && value >= 0 ? '+$value' : value.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'BebasNeue',
                      color: AppTheme.pureWhite,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              _buildCounterButton(
                icon: Icons.add,
                onPressed: onIncrease,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.steel.withOpacity(0.2),
          border: Border(
            right: BorderSide(
              color: AppTheme.steel.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Icon(
          icon,
          color: AppTheme.silver,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildRollButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isRolling ? null : _rollDice,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.scarletRed,
          foregroundColor: AppTheme.pureWhite,
          disabledBackgroundColor: AppTheme.steel,
          disabledForegroundColor: AppTheme.iron,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: Text(
          _isRolling ? 'ROLANDO...' : 'ROLAR DADOS',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildResultDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkGray,
        border: Border.all(
          color: AppTheme.scarletRed,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'RESULTADO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              color: AppTheme.lightGray,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _lastResult.toString(),
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w700,
              fontFamily: 'BebasNeue',
              color: AppTheme.scarletRed,
              letterSpacing: 2,
            ),
          ),
          if (_lastFormula != null)
            Text(
              _lastFormula!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'SpaceMono',
                color: AppTheme.iron,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'HISTÓRICO RECENTE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                color: AppTheme.lightGray,
                letterSpacing: 1.5,
              ),
            ),
            TextButton(
              onPressed: _showHistoryModal,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.scarletRed,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'VER TUDO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._history.take(5).map((roll) => Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.darkGray,
                border: Border.all(
                  color: AppTheme.steel.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      roll.detailedResult,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'SpaceMono',
                        color: AppTheme.silver,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    roll.total.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'BebasNeue',
                      color: AppTheme.pureWhite,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  void _showHistoryModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.deepBlack,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'HISTÓRICO COMPLETO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: AppTheme.pureWhite,
                    letterSpacing: 1.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.iron),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final roll = _history[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.darkGray,
                      border: Border.all(
                        color: AppTheme.steel.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                roll.detailedResult,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'SpaceMono',
                                  color: AppTheme.silver,
                                ),
                              ),
                              if (roll.rolls.isNotEmpty && roll.rolls.first.results.length > 1)
                                Text(
                                  'Resultados: ${roll.rolls.first.results.join(', ')}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'SpaceMono',
                                    color: AppTheme.iron,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          roll.total.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'BebasNeue',
                            color: AppTheme.scarletRed,
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
      ),
    );
  }
}

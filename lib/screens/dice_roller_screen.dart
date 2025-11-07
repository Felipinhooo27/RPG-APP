import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../utils/dice_roller.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

/// Rolador de dados completamente redesenhado com tema Hexatombe
class DiceRollerScreen extends StatefulWidget {
  const DiceRollerScreen({super.key});

  @override
  State<DiceRollerScreen> createState() => _DiceRollerScreenState();
}

class _DiceRollerScreenState extends State<DiceRollerScreen> {
  final DiceRoller _diceRoller = DiceRoller();
  final List<DiceRollHistory> _history = [];
  String? _selectedDiceType;
  int _quantity = 1;
  int _modifier = 0;

  final List<String> _diceTypes = ['d4', 'd6', 'd8', 'd10', 'd12', 'd20', 'd100'];

  @override
  Widget build(BuildContext context) {
    return HexatombeBackground(
      showParticles: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppTheme.abyssalBlack.withOpacity(0.9),
          elevation: 0,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ROLADOR DE DADOS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                  color: AppTheme.ritualRed,
                ),
              ),
              Text(
                'Selecione o dado e role',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.coldGray,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          actions: [
            if (_history.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.history, color: AppTheme.chaoticMagenta),
                onPressed: _showHistoryModal,
                tooltip: 'Ver histórico',
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                // Seletor de dados (circular buttons)
                _buildDiceSelector(),

                const SizedBox(height: 16),

                // Controles de quantidade e modificador
                _buildControls(),

                const SizedBox(height: 16),

                // Botão de rolar
                _buildRollButton(),

                const SizedBox(height: 16),

                // Último resultado (se houver)
                if (_history.isNotEmpty) _buildLastResult(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiceSelector() {
    return RitualCard(
      glowEffect: true,
      glowColor: AppTheme.chaoticMagenta,
      ritualCorners: true,
      child: Column(
        children: [
          const Text(
            'ESCOLHA SEU DADO',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.coldGray,
              fontFamily: 'Montserrat',
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: _diceTypes.map((diceType) {
              final isSelected = _selectedDiceType == diceType;
              return DiceButton(
                diceType: diceType,
                selected: isSelected,
                onPressed: () {
                  setState(() {
                    _selectedDiceType = diceType;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildControls() {
    return Row(
      children: [
        // Quantidade
        Expanded(
          child: RitualCard(
            padding: const EdgeInsets.all(12),
            ritualCorners: false,
            child: Column(
              children: [
                const Text(
                  'QUANTIDADE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.coldGray,
                    fontFamily: 'Montserrat',
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCircularButton(
                      icon: Icons.remove,
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.ritualRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.ritualRed.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ritualRed,
                            fontFamily: 'BebasNeue',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildCircularButton(
                      icon: Icons.add,
                      onPressed: _quantity < 20
                          ? () => setState(() => _quantity++)
                          : null,
                      size: 32,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Modificador
        Expanded(
          child: RitualCard(
            padding: const EdgeInsets.all(12),
            ritualCorners: false,
            child: Column(
              children: [
                const Text(
                  'MODIFICADOR',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.coldGray,
                    fontFamily: 'Montserrat',
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCircularButton(
                      icon: Icons.remove,
                      onPressed: _modifier > -10
                          ? () => setState(() => _modifier--)
                          : null,
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.mutagenGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.mutagenGreen.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _modifier >= 0 ? '+$_modifier' : '$_modifier',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.mutagenGreen,
                            fontFamily: 'SpaceMono',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildCircularButton(
                      icon: Icons.add,
                      onPressed: _modifier < 20
                          ? () => setState(() => _modifier++)
                          : null,
                      size: 32,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback? onPressed,
    double size = 36,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onPressed != null
              ? AppTheme.obscureGray
              : AppTheme.obscureGray.withOpacity(0.3),
          boxShadow: [
            BoxShadow(
              color: onPressed != null
                  ? AppTheme.coldGray.withOpacity(0.4)
                  : AppTheme.coldGray.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: onPressed != null ? AppTheme.paleWhite : AppTheme.coldGray,
          size: size * 0.5,
        ),
      ),
    );
  }

  Widget _buildRollButton() {
    final canRoll = _selectedDiceType != null;

    return GlowingButton(
      label: 'ROLAR DADOS',
      icon: Icons.casino,
      onPressed: canRoll ? _rollDice : null,
      fullWidth: true,
      pulsateGlow: canRoll,
      style: GlowingButtonStyle.primary,
      height: 56,
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildLastResult() {
    final lastRoll = _history.last;
    return RitualCard(
      glowEffect: true,
      glowColor: AppTheme.ritualRed,
      pulsate: true,
      ritualCorners: true,
      child: Column(
        children: [
          const Text(
            'ÚLTIMO RESULTADO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.coldGray,
              fontFamily: 'Montserrat',
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lastRoll.formula,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.ritualRed,
              fontFamily: 'SpaceMono',
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.coldGray, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'TOTAL: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.coldGray,
                  fontFamily: 'Montserrat',
                  letterSpacing: 1,
                ),
              ),
              Text(
                '${lastRoll.result.total}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ritualRed,
                  fontFamily: 'BebasNeue',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: _showHistoryModal,
            icon: const Icon(Icons.history, color: AppTheme.chaoticMagenta),
            label: const Text(
              'VER HISTÓRICO COMPLETO',
              style: TextStyle(
                color: AppTheme.chaoticMagenta,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }

  void _showHistoryModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.obscureGray,
                AppTheme.abyssalBlack,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.chaoticMagenta.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.coldGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'HISTÓRICO DE ROLAGENS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'BebasNeue',
                        color: AppTheme.chaoticMagenta,
                        letterSpacing: 2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep, color: AppTheme.ritualRed),
                      onPressed: () {
                        setState(() => _history.clear());
                        Navigator.pop(context);
                      },
                      tooltip: 'Limpar histórico',
                    ),
                  ],
                ),
              ),
              const Divider(color: AppTheme.coldGray, height: 1),
              // List
              Expanded(
                child: _history.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhuma rolagem no histórico',
                          style: TextStyle(
                            color: AppTheme.coldGray,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _history.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          final history = _history[_history.length - 1 - index];
                          return _HistoryCardRedesigned(history: history)
                              .animate()
                              .fadeIn(duration: 200.ms);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _rollDice() async {
    if (_selectedDiceType == null) return;

    final sides = int.parse(_selectedDiceType!.substring(1));
    final formula = '${_quantity}d$sides${_modifier >= 0 ? '+' : ''}${_modifier != 0 ? _modifier : ''}';

    try {
      // Mostrar modal de animação
      final result = await _showRollingAnimation(formula, sides);

      if (result != null && mounted) {
        setState(() {
          _history.add(DiceRollHistory(
            formula: formula,
            result: result,
            timestamp: DateTime.now(),
          ));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao rolar dados: $e'),
            backgroundColor: AppTheme.ritualRed,
          ),
        );
      }
    }
  }

  Future<DiceRollResult?> _showRollingAnimation(String formula, int sides) async {
    return showDialog<DiceRollResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _RollingAnimationDialog(
        formula: formula,
        sides: sides,
        diceRoller: _diceRoller,
      ),
    );
  }
}

/// Modal animado que simula dados rolando (estilo Baldur's Gate)
class _RollingAnimationDialog extends StatefulWidget {
  final String formula;
  final int sides;
  final DiceRoller diceRoller;

  const _RollingAnimationDialog({
    required this.formula,
    required this.sides,
    required this.diceRoller,
  });

  @override
  State<_RollingAnimationDialog> createState() => _RollingAnimationDialogState();
}

class _RollingAnimationDialogState extends State<_RollingAnimationDialog>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  DiceRollResult? _result;
  bool _isRolling = true;
  final math.Random _random = math.Random();
  int _currentValue = 1;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _startRolling();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _startRolling() async {
    // Simular valores aleatórios durante a rolagem
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          _currentValue = _random.nextInt(widget.sides) + 1;
        });
      }
    }

    // Rolar dados de verdade
    await Future.delayed(const Duration(milliseconds: 500));
    final result = widget.diceRoller.roll(widget.formula);

    if (mounted) {
      _rotationController.stop();
      _scaleController.forward();

      setState(() {
        _result = result;
        _isRolling = false;
      });

      // Fechar automaticamente após 2 segundos
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) {
        Navigator.of(context).pop(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: RitualCard(
        glowEffect: true,
        glowColor: AppTheme.chaoticMagenta,
        pulsate: _isRolling,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animação do dado girando
            RotationTransition(
              turns: _rotationController,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.ritualRed,
                      AppTheme.chaoticMagenta,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.paleWhite.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: AppTheme.chaoticMagenta.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _isRolling ? '$_currentValue' : '${_result?.total ?? 0}',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.paleWhite,
                      fontFamily: 'BebasNeue',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (_isRolling) ...[
              const Text(
                'ROLANDO...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.chaoticMagenta,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(AppTheme.chaoticMagenta),
                ),
              ),
            ] else if (_result != null) ...[
              const Text(
                'RESULTADO',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.coldGray,
                  fontFamily: 'Montserrat',
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.formula,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ritualRed,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                ),
              ),
            ],
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 200.ms)
          .scale(begin: const Offset(0.8, 0.8)),
    );
  }
}

/// Card de histórico redesenhado
class _HistoryCardRedesigned extends StatelessWidget {
  final DiceRollHistory history;

  const _HistoryCardRedesigned({required this.history});

  @override
  Widget build(BuildContext context) {
    final timeStr = '${history.timestamp.hour.toString().padLeft(2, '0')}:'
        '${history.timestamp.minute.toString().padLeft(2, '0')}';

    return RitualCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      glowEffect: false,
      ritualCorners: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.ritualRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.ritualRed.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  history.formula,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ritualRed,
                    fontFamily: 'SpaceMono',
                  ),
                ),
              ),
              const Spacer(),
              Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.coldGray,
                  fontFamily: 'SpaceMono',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Detalhes dos dados
          ...history.result.rolls.map((roll) {
            if (roll.numberOfDice > 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Text(
                      '${roll.numberOfDice}d${roll.sides}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.coldGray,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '[${roll.results.join(', ')}]',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.paleWhite,
                          fontFamily: 'SpaceMono',
                        ),
                      ),
                    ),
                    Text(
                      '= ${roll.total}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.mutagenGreen,
                        fontFamily: 'SpaceMono',
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }).toList(),

          const SizedBox(height: 8),
          const Divider(color: AppTheme.coldGray, height: 1),
          const SizedBox(height: 12),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'TOTAL: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.coldGray,
                  fontFamily: 'Montserrat',
                  letterSpacing: 1,
                ),
              ),
              Text(
                '${history.result.total}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ritualRed,
                  fontFamily: 'BebasNeue',
                ),
              ),
            ],
          ),
        ],
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

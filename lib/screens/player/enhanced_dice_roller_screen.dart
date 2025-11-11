import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Rolador de Dados 3D Ultra Aprimorado
/// Com animações físicas realistas, efeitos de partículas e detecção de críticos
class EnhancedDiceRollerScreen extends StatefulWidget {
  const EnhancedDiceRollerScreen({super.key});

  @override
  State<EnhancedDiceRollerScreen> createState() => _EnhancedDiceRollerScreenState();
}

class _EnhancedDiceRollerScreenState extends State<EnhancedDiceRollerScreen>
    with TickerProviderStateMixin {
  final List<DiceRollResult> _history = [];
  final Random _random = Random();

  int _selectedDice = 20;
  int _modifier = 0;
  int _diceCount = 1;
  DiceRollResult? _lastRoll;
  bool _isRolling = false;

  late AnimationController _diceAnimationController;
  late AnimationController _resultAnimationController;
  late AnimationController _particleAnimationController;

  @override
  void initState() {
    super.initState();

    _diceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _particleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _diceAnimationController.dispose();
    _resultAnimationController.dispose();
    _particleAnimationController.dispose();
    super.dispose();
  }

  Future<void> _rollDice() async {
    if (_isRolling) return;

    setState(() {
      _isRolling = true;
    });

    // Animar dados rolando
    _diceAnimationController.forward(from: 0);
    _particleAnimationController.forward(from: 0);

    // Aguarda a animação
    await Future.delayed(const Duration(milliseconds: 800));

    // Calcula resultado
    final rolls = <int>[];
    for (int i = 0; i < _diceCount; i++) {
      rolls.add(_random.nextInt(_selectedDice) + 1);
    }

    final sum = rolls.reduce((a, b) => a + b);
    final total = sum + _modifier;

    // Detecta críticos e falhas
    final isCriticalSuccess = _detectCriticalSuccess(rolls);
    final isCriticalFailure = _detectCriticalFailure(rolls);

    final result = DiceRollResult(
      diceType: _selectedDice,
      diceCount: _diceCount,
      modifier: _modifier,
      rolls: rolls,
      total: total,
      timestamp: DateTime.now(),
      isCriticalSuccess: isCriticalSuccess,
      isCriticalFailure: isCriticalFailure,
    );

    setState(() {
      _lastRoll = result;
      _history.insert(0, result);

      if (_history.length > 100) {
        _history.removeLast();
      }

      _isRolling = false;
    });

    // Anima resultado
    _resultAnimationController.forward(from: 0);
  }

  bool _detectCriticalSuccess(List<int> rolls) {
    if (_selectedDice == 20 && rolls.contains(20)) return true;
    if (rolls.every((r) => r == _selectedDice)) return true;
    return false;
  }

  bool _detectCriticalFailure(List<int> rolls) {
    if (_selectedDice == 20 && rolls.contains(1)) return true;
    if (rolls.every((r) => r == 1)) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColors.darkGray,
        title: Text(
          'ROLADOR DE DADOS 3D',
          style: AppTextStyles.uppercase.copyWith(fontSize: 14),
        ),
        iconTheme: const IconThemeData(color: AppColors.lightGray),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            color: AppColors.scarletRed,
            onPressed: _showHistoryModal,
            tooltip: 'Histórico',
          ),
        ],
      ),
      body: Column(
        children: [
          // Área de resultado com animação
          _buildResultArea(),

          // Controles
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDiceSelector(),
                  const SizedBox(height: 24),
                  // Quantidade e Modificador lado a lado
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDiceCountControl()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModifierControl()),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildRollButton(),
                  const SizedBox(height: 32),
                  _buildStats(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultArea() {
    Color bgColor = AppColors.darkGray;
    Color textColor = AppColors.scarletRed;
    Color borderColor = AppColors.scarletRed;

    if (_lastRoll != null) {
      if (_lastRoll!.isCriticalSuccess) {
        bgColor = AppColors.conhecimentoGreen.withOpacity(0.1);
        textColor = AppColors.conhecimentoGreen;
        borderColor = AppColors.conhecimentoGreen;
      } else if (_lastRoll!.isCriticalFailure) {
        bgColor = AppColors.neonRed.withOpacity(0.1);
        textColor = AppColors.neonRed;
        borderColor = AppColors.neonRed;
      }
    }

    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: borderColor.withOpacity(0.5), width: 2),
        ),
      ),
      child: Stack(
        children: [
          // Partículas de fundo
          if (_isRolling)
            ...List.generate(15, (index) {
              return Positioned(
                left: _random.nextDouble() * MediaQuery.of(context).size.width,
                top: _random.nextDouble() * 200,
                child: AnimatedBuilder(
                  animation: _particleAnimationController,
                  builder: (context, child) {
                    final progress = _particleAnimationController.value;
                    return Opacity(
                      opacity: (1 - progress).clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(
                          (_random.nextDouble() - 0.5) * 100 * progress,
                          progress * 150,
                        ),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: borderColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

          // Dados animados
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Múltiplos dados rolando
                if (_isRolling)
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: List.generate(_diceCount.clamp(1, 5), (index) {
                      return AnimatedBuilder(
                        animation: _diceAnimationController,
                        builder: (context, child) {
                          final progress = _diceAnimationController.value;
                          final rotation = progress * 4 * pi + (index * 0.5);
                          final scale = 0.5 + (sin(progress * pi) * 0.5);
                          final translateY = -sin(progress * pi) * 40;

                          return Transform.translate(
                            offset: Offset(0, translateY),
                            child: Transform.scale(
                              scale: scale,
                              child: Transform.rotate(
                                angle: rotation,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: borderColor.withOpacity(0.2),
                                    border: Border.all(color: borderColor, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: borderColor.withOpacity(0.5),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'D$_selectedDice',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: borderColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),

                // Resultado final
                if (!_isRolling && _lastRoll != null)
                  AnimatedBuilder(
                    animation: _resultAnimationController,
                    builder: (context, child) {
                      final progress = _resultAnimationController.value;
                      final scale = 0.5 + (progress * 0.5);
                      final opacity = progress;

                      return Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          child: Column(
                            children: [
                              // Badge de crítico
                              if (_lastRoll!.isCriticalSuccess)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.conhecimentoGreen.withOpacity(0.2),
                                    border: Border.all(color: AppColors.conhecimentoGreen, width: 2),
                                  ),
                                  child: Text(
                                    '⭐ CRÍTICO! ⭐',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.conhecimentoGreen,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ).animate(onPlay: (controller) => controller.repeat())
                                    .shimmer(duration: 1500.ms, color: AppColors.conhecimentoGreen.withOpacity(0.5)),

                              if (_lastRoll!.isCriticalFailure)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.neonRed.withOpacity(0.2),
                                    border: Border.all(color: AppColors.neonRed, width: 2),
                                  ),
                                  child: Text(
                                    '💀 FALHA CRÍTICA! 💀',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.neonRed,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 16),

                              // Número grande
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: textColor.withOpacity(0.1),
                                  border: Border.all(color: textColor, width: 3),
                                  boxShadow: _lastRoll!.isCriticalSuccess || _lastRoll!.isCriticalFailure
                                      ? [
                                          BoxShadow(
                                            color: textColor.withOpacity(0.6),
                                            blurRadius: 30,
                                            spreadRadius: 10,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  _lastRoll!.total.toString(),
                                  style: TextStyle(
                                    fontSize: 80,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    height: 1.0,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Fórmula
                              Text(
                                _buildFormula(_lastRoll!),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.silver,
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Rolagens individuais
                              Wrap(
                                spacing: 8,
                                children: _lastRoll!.rolls.map((roll) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.deepBlack,
                                      border: Border.all(color: textColor.withOpacity(0.5)),
                                    ),
                                    child: Text(
                                      roll.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                if (!_isRolling && _lastRoll == null)
                  Column(
                    children: [
                      Icon(
                        Icons.casino,
                        size: 64,
                        color: AppColors.silver.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ROLE OS DADOS',
                        style: AppTextStyles.uppercase.copyWith(
                          color: AppColors.silver.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiceSelector() {
    final diceTypes = [4, 6, 8, 10, 12, 20, 100];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TIPO DE DADO',
          style: AppTextStyles.uppercase.copyWith(
            fontSize: 12,
            color: AppColors.lightGray,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: diceTypes.map((dice) {
            final isSelected = _selectedDice == dice;
            return GestureDetector(
              onTap: () => setState(() => _selectedDice = dice),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.scarletRed.withOpacity(0.2) : AppColors.darkGray,
                  border: Border.all(
                    color: isSelected ? AppColors.scarletRed : AppColors.silver.withOpacity(0.3),
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDiceIcon(dice, isSelected),
                    const SizedBox(height: 4),
                    Text(
                      'D$dice',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.scarletRed : AppColors.silver,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDiceIcon(int diceType, bool isSelected) {
    // Tenta carregar imagem PNG primeiro
    final imagePath = 'assets/images/dice/d$diceType.png';

    return Image.asset(
      imagePath,
      width: 32,
      height: 32,
      fit: BoxFit.contain, // Garante que a imagem se ajuste sem distorcer
      color: isSelected ? AppColors.scarletRed : AppColors.silver,
      colorBlendMode: BlendMode.modulate,
      errorBuilder: (context, error, stackTrace) {
        // Se falhar ao carregar, mostra ícone padrão
        return Icon(
          Icons.casino,
          size: 32,
          color: isSelected ? AppColors.scarletRed : AppColors.silver,
        );
      },
    );
  }

  Widget _buildDiceCountControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUANTIDADE (${_diceCount}X)',
          style: AppTextStyles.uppercase.copyWith(
            fontSize: 12,
            color: AppColors.lightGray,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: _diceCount > 1 ? () => setState(() => _diceCount--) : null,
              icon: const Icon(Icons.remove_circle),
              color: AppColors.scarletRed,
              iconSize: 32,
              disabledColor: AppColors.silver.withOpacity(0.2),
            ),
            Expanded(
              child: Slider(
                value: _diceCount.toDouble(),
                min: 1,
                max: 20,
                divisions: 19,
                activeColor: AppColors.scarletRed,
                inactiveColor: AppColors.silver.withOpacity(0.3),
                onChanged: (value) => setState(() => _diceCount = value.toInt()),
              ),
            ),
            IconButton(
              onPressed: _diceCount < 20 ? () => setState(() => _diceCount++) : null,
              icon: const Icon(Icons.add_circle),
              color: AppColors.scarletRed,
              iconSize: 32,
              disabledColor: AppColors.silver.withOpacity(0.2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModifierControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MODIFICADOR (${_modifier >= 0 ? '+' : ''}$_modifier)',
          style: AppTextStyles.uppercase.copyWith(
            fontSize: 12,
            color: AppColors.lightGray,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: _modifier > -20 ? () => setState(() => _modifier--) : null,
              icon: const Icon(Icons.remove_circle),
              color: AppColors.magenta,
              iconSize: 32,
              disabledColor: AppColors.silver.withOpacity(0.2),
            ),
            Expanded(
              child: Slider(
                value: _modifier.toDouble(),
                min: -20,
                max: 20,
                divisions: 40,
                activeColor: AppColors.magenta,
                inactiveColor: AppColors.silver.withOpacity(0.3),
                onChanged: (value) => setState(() => _modifier = value.toInt()),
              ),
            ),
            IconButton(
              onPressed: _modifier < 20 ? () => setState(() => _modifier++) : null,
              icon: const Icon(Icons.add_circle),
              color: AppColors.magenta,
              iconSize: 32,
              disabledColor: AppColors.silver.withOpacity(0.2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRollButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: _isRolling ? null : _rollDice,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.scarletRed,
          disabledBackgroundColor: AppColors.darkGray,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.casino,
              size: 32,
              color: _isRolling ? AppColors.silver.withOpacity(0.5) : AppColors.lightGray,
            ),
            const SizedBox(width: 16),
            Text(
              _isRolling ? 'ROLANDO...' : 'ROLAR DADOS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: _isRolling ? AppColors.silver.withOpacity(0.5) : AppColors.lightGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    if (_history.isEmpty) return const SizedBox.shrink();

    final totals = _history.map((r) => r.total).toList();
    final average = totals.reduce((a, b) => a + b) / totals.length;
    final highest = totals.reduce((a, b) => a > b ? a : b);
    final lowest = totals.reduce((a, b) => a < b ? a : b);
    final criticalCount = _history.where((r) => r.isCriticalSuccess).length;
    final failureCount = _history.where((r) => r.isCriticalFailure).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ESTATÍSTICAS',
          style: AppTextStyles.uppercase.copyWith(
            fontSize: 12,
            color: AppColors.lightGray,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            border: Border.all(color: AppColors.energiaYellow.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem('MÉDIA', average.toStringAsFixed(1), AppColors.energiaYellow),
              ),
              Expanded(
                child: _buildStatItem('MAIOR', highest.toString(), AppColors.conhecimentoGreen),
              ),
              Expanded(
                child: _buildStatItem('MENOR', lowest.toString(), AppColors.neonRed),
              ),
              Expanded(
                child: _buildStatItem('CRÍTICOS', '$criticalCount/$failureCount', AppColors.magenta),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: color.withOpacity(0.7),
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  void _showHistoryModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.deepBlack,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.deepBlack,
            border: Border(
              top: BorderSide(color: AppColors.scarletRed, width: 3),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkGray,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.scarletRed.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HISTÓRICO (${_history.length})',
                      style: AppTextStyles.title,
                    ),
                    Row(
                      children: [
                        if (_history.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() => _history.clear());
                              Navigator.pop(context);
                            },
                            child: Text(
                              'LIMPAR',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.neonRed,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          color: AppColors.silver,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Lista de histórico
              Expanded(
                child: _history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: AppColors.silver.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'NENHUMA ROLAGEM AINDA',
                              style: AppTextStyles.uppercase.copyWith(
                                color: AppColors.silver.withOpacity(0.5),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _history.length,
                        itemBuilder: (context, index) =>
                            _buildHistoryItem(_history[index], index),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistory() {
    if (_history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HISTÓRICO (${_history.length})',
              style: AppTextStyles.uppercase.copyWith(
                fontSize: 12,
                color: AppColors.lightGray,
              ),
            ),
            if (_history.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _history.clear()),
                child: Text(
                  'LIMPAR',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.neonRed,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(min(_history.length, 10), (index) {
          final roll = _history[index];
          return _buildHistoryItem(roll, index);
        }),
      ],
    );
  }

  Widget _buildHistoryItem(DiceRollResult roll, int index) {
    Color color = AppColors.scarletRed;
    if (roll.isCriticalSuccess) color = AppColors.conhecimentoGreen;
    if (roll.isCriticalFailure) color = AppColors.neonRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border(
          left: BorderSide(color: color, width: 4),
          top: BorderSide(color: AppColors.silver.withOpacity(0.2)),
          right: BorderSide(color: AppColors.silver.withOpacity(0.2)),
          bottom: BorderSide(color: AppColors.silver.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(
                roll.total.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _buildFormula(roll),
                      style: AppTextStyles.uppercase.copyWith(
                        fontSize: 11,
                        color: AppColors.silver,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (roll.isCriticalSuccess)
                      Text(
                        '⭐',
                        style: TextStyle(fontSize: 14),
                      ),
                    if (roll.isCriticalFailure)
                      Text(
                        '💀',
                        style: TextStyle(fontSize: 14),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Rolagens: ${roll.rolls.join(', ')}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.silver.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 50).ms).fadeIn(duration: 200.ms).slideX(begin: -0.1, end: 0);
  }

  String _buildFormula(DiceRollResult roll) {
    String formula = '${roll.diceCount}D${roll.diceType}';
    if (roll.modifier != 0) {
      formula += roll.modifier > 0 ? ' +${roll.modifier}' : ' ${roll.modifier}';
    }
    return formula;
  }
}

// =============================================================================
// MODEL
// =============================================================================
class DiceRollResult {
  final int diceType;
  final int diceCount;
  final int modifier;
  final List<int> rolls;
  final int total;
  final DateTime timestamp;
  final bool isCriticalSuccess;
  final bool isCriticalFailure;

  DiceRollResult({
    required this.diceType,
    required this.diceCount,
    required this.modifier,
    required this.rolls,
    required this.total,
    required this.timestamp,
    this.isCriticalSuccess = false,
    this.isCriticalFailure = false,
  });
}

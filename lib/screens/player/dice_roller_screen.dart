import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Tela de Rolagem de Dados com Histórico
class DiceRollerScreen extends StatefulWidget {
  const DiceRollerScreen({super.key});

  @override
  State<DiceRollerScreen> createState() => _DiceRollerScreenState();
}

class _DiceRollerScreenState extends State<DiceRollerScreen>
    with SingleTickerProviderStateMixin {
  final List<DiceRoll> _history = [];
  final Random _random = Random();
  late AnimationController _rollAnimationController;
  late Animation<double> _rollAnimation;

  int _selectedDice = 20;
  int _modifier = 0;
  int _diceCount = 1;
  int? _lastResult;

  @override
  void initState() {
    super.initState();
    _rollAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _rollAnimation = CurvedAnimation(
      parent: _rollAnimationController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _rollAnimationController.dispose();
    super.dispose();
  }

  void _rollDice() {
    final rolls = <int>[];
    for (int i = 0; i < _diceCount; i++) {
      rolls.add(_random.nextInt(_selectedDice) + 1);
    }

    final sum = rolls.reduce((a, b) => a + b);
    final total = sum + _modifier;

    setState(() {
      _lastResult = total;
      _history.insert(
        0,
        DiceRoll(
          diceType: _selectedDice,
          diceCount: _diceCount,
          modifier: _modifier,
          rolls: rolls,
          total: total,
          timestamp: DateTime.now(),
        ),
      );

      // Limita histórico a 50 entradas
      if (_history.length > 50) {
        _history.removeLast();
      }
    });

    _rollAnimationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColors.darkGray,
        title: Text(
          'DADOS',
          style: AppTextStyles.title.copyWith(fontSize: 16),
        ),
        centerTitle: true,
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
          // Resultado atual
          _buildResultSection(),

          // Seletor de dados
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SELECIONE O DADO', style: AppTextStyles.title),
                  const SizedBox(height: 16),
                  _buildDiceSelector(),
                  const SizedBox(height: 32),
                  // Quantidade e Modificador lado a lado
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('QUANTIDADE', style: AppTextStyles.title),
                            const SizedBox(height: 16),
                            _buildDiceCountSelector(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('MODIFICADOR', style: AppTextStyles.title),
                            const SizedBox(height: 16),
                            _buildModifierSelector(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildRollButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border(
          bottom: BorderSide(color: AppColors.scarletRed.withOpacity(0.3), width: 2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'RESULTADO',
            style: AppTextStyles.uppercase.copyWith(
              fontSize: 12,
              color: AppColors.silver,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _rollAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (_rollAnimation.value * 0.2),
                child: child,
              );
            },
            child: Text(
              _lastResult?.toString() ?? '—',
              style: AppTextStyles.title.copyWith(
                fontSize: 72,
                color: AppColors.scarletRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_lastResult != null && _history.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _buildRollFormula(_history.first),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.silver,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiceSelector() {
    final diceTypes = [4, 6, 8, 10, 12, 20, 100];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: diceTypes.map((dice) {
        final isSelected = _selectedDice == dice;
        return _buildDiceOption(
          'D$dice',
          dice,
          isSelected,
          () => setState(() => _selectedDice = dice),
        );
      }).toList(),
    );
  }

  Widget _buildDiceOption(String label, int value, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.scarletRed.withOpacity(0.2) : AppColors.darkGray,
          border: Border.all(
            color: isSelected ? AppColors.scarletRed : AppColors.silver.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDiceIcon(value, isSelected),
            const SizedBox(height: 4),
            Text(
              label,
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
  }

  Widget _buildDiceIcon(int diceType, bool isSelected) {
    // Tenta carregar imagem PNG primeiro
    final imagePath = 'assets/images/dice/d$diceType.png';

    return Image.asset(
      imagePath,
      width: 40,
      height: 40,
      fit: BoxFit.contain, // Garante que a imagem se ajuste sem distorcer
      color: isSelected ? AppColors.scarletRed : AppColors.silver,
      colorBlendMode: BlendMode.modulate,
      errorBuilder: (context, error, stackTrace) {
        // Se falhar ao carregar, usa CustomPaint
        return CustomPaint(
          size: const Size(40, 40),
          painter: DicePainter(
            diceType: diceType,
            color: isSelected ? AppColors.scarletRed : AppColors.silver,
          ),
        );
      },
    );
  }

  Widget _buildDiceCountSelector() {
    return Row(
      children: [
        IconButton(
          onPressed: _diceCount > 1
              ? () => setState(() => _diceCount--)
              : null,
          icon: const Icon(Icons.remove),
          color: AppColors.scarletRed,
          disabledColor: AppColors.silver.withOpacity(0.3),
        ),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.darkGray,
              border: Border.all(color: AppColors.scarletRed),
            ),
            child: Center(
              child: Text(
                '$_diceCount',
                style: AppTextStyles.title.copyWith(
                  fontSize: 24,
                  color: AppColors.scarletRed,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: _diceCount < 20
              ? () => setState(() => _diceCount++)
              : null,
          icon: const Icon(Icons.add),
          color: AppColors.scarletRed,
          disabledColor: AppColors.silver.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildModifierSelector() {
    return Row(
      children: [
        IconButton(
          onPressed: _modifier > -10
              ? () => setState(() => _modifier--)
              : null,
          icon: const Icon(Icons.remove),
          color: AppColors.scarletRed,
          disabledColor: AppColors.silver.withOpacity(0.3),
        ),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.darkGray,
              border: Border.all(color: AppColors.magenta),
            ),
            child: Center(
              child: Text(
                _modifier >= 0 ? '+$_modifier' : '$_modifier',
                style: AppTextStyles.title.copyWith(
                  fontSize: 24,
                  color: AppColors.magenta,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: _modifier < 20
              ? () => setState(() => _modifier++)
              : null,
          icon: const Icon(Icons.add),
          color: AppColors.scarletRed,
          disabledColor: AppColors.silver.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildRollButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _rollDice,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.scarletRed,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.casino, size: 24),
            const SizedBox(width: 12),
            Text(
              'ROLAR $_diceCount${_diceCount > 1 ? 'X' : ''} D$_selectedDice${_modifier != 0 ? ' ${_modifier >= 0 ? '+' : ''}$_modifier' : ''}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
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
                    Text('HISTÓRICO', style: AppTextStyles.title),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: AppColors.silver,
                      onPressed: () => Navigator.pop(context),
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
                            _buildHistoryItem(_history[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistory() {
    if (_history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          border: Border.all(color: AppColors.silver.withOpacity(0.3)),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: AppColors.silver.withOpacity(0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'NENHUMA ROLAGEM AINDA',
                style: AppTextStyles.uppercase.copyWith(
                  color: AppColors.silver.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _history.map((roll) => _buildHistoryItem(roll)).toList(),
    );
  }

  Widget _buildHistoryItem(DiceRoll roll) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border.all(color: AppColors.silver.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Resultado
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.scarletRed.withOpacity(0.2),
              border: Border.all(color: AppColors.scarletRed, width: 2),
            ),
            child: Center(
              child: Text(
                roll.total.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.scarletRed,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Detalhes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _buildRollFormula(roll),
                  style: AppTextStyles.uppercase.copyWith(
                    fontSize: 12,
                    color: AppColors.silver,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rolagens: ${roll.rolls.join(', ')}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.silver.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(roll.timestamp),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.silver.withOpacity(0.5),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildRollFormula(DiceRoll roll) {
    String formula = roll.diceCount > 1
        ? '${roll.diceCount}D${roll.diceType}'
        : 'D${roll.diceType}';

    if (roll.modifier != 0) {
      formula += roll.modifier >= 0
          ? ' +${roll.modifier}'
          : ' ${roll.modifier}';
    }

    return formula;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Agora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else {
      return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

// =============================================================================
// CUSTOM PAINTER: Dice Shapes
// =============================================================================
class DicePainter extends CustomPainter {
  final int diceType;
  final Color color;

  DicePainter({required this.diceType, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    switch (diceType) {
      case 4: // D4 - Tetrahedron (triangle)
        final path = Path();
        path.moveTo(center.dx, size.height * 0.15);
        path.lineTo(size.width * 0.85, size.height * 0.8);
        path.lineTo(size.width * 0.15, size.height * 0.8);
        path.close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, paint);
        // Inner lines
        canvas.drawLine(
          Offset(center.dx, size.height * 0.15),
          Offset(center.dx, size.height * 0.6),
          paint..strokeWidth = 1.5,
        );
        break;

      case 6: // D6 - Cube
        final cubeSize = size.width * 0.5;
        final offset = (size.width - cubeSize) / 2;

        // Front face
        final rect = Rect.fromLTWH(offset, offset + 5, cubeSize, cubeSize);
        canvas.drawRect(rect, fillPaint);
        canvas.drawRect(rect, paint);

        // Top face (parallelogram)
        final topPath = Path();
        topPath.moveTo(offset, offset + 5);
        topPath.lineTo(offset + 10, offset);
        topPath.lineTo(offset + cubeSize + 10, offset);
        topPath.lineTo(offset + cubeSize, offset + 5);
        topPath.close();
        canvas.drawPath(topPath, fillPaint);
        canvas.drawPath(topPath, paint);

        // Right face
        final rightPath = Path();
        rightPath.moveTo(offset + cubeSize, offset + 5);
        rightPath.lineTo(offset + cubeSize + 10, offset);
        rightPath.lineTo(offset + cubeSize + 10, offset + cubeSize);
        rightPath.lineTo(offset + cubeSize, offset + cubeSize + 5);
        rightPath.close();
        canvas.drawPath(rightPath, fillPaint);
        canvas.drawPath(rightPath, paint);
        break;

      case 8: // D8 - Octahedron (diamond)
        final path = Path();
        path.moveTo(center.dx, size.height * 0.1);
        path.lineTo(size.width * 0.8, center.dy);
        path.lineTo(center.dx, size.height * 0.9);
        path.lineTo(size.width * 0.2, center.dy);
        path.close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, paint);
        // Cross lines
        canvas.drawLine(
          Offset(center.dx, size.height * 0.1),
          Offset(center.dx, size.height * 0.9),
          paint..strokeWidth = 1.5,
        );
        canvas.drawLine(
          Offset(size.width * 0.2, center.dy),
          Offset(size.width * 0.8, center.dy),
          paint..strokeWidth = 1.5,
        );
        break;

      case 10: // D10 - Pentagon
        final path = Path();
        for (int i = 0; i < 5; i++) {
          final angle = (i * 2 * pi / 5) - pi / 2;
          final x = center.dx + (size.width * 0.4) * cos(angle);
          final y = center.dy + (size.height * 0.4) * sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, paint);
        // Center to vertices
        for (int i = 0; i < 5; i += 2) {
          final angle = (i * 2 * pi / 5) - pi / 2;
          final x = center.dx + (size.width * 0.4) * cos(angle);
          final y = center.dy + (size.height * 0.4) * sin(angle);
          canvas.drawLine(center, Offset(x, y), paint..strokeWidth = 1.5);
        }
        break;

      case 12: // D12 - Dodecahedron (hexagon)
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (i * 2 * pi / 6) - pi / 2;
          final x = center.dx + (size.width * 0.4) * cos(angle);
          final y = center.dy + (size.height * 0.4) * sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, paint);
        // Inner hexagon
        final innerPath = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (i * 2 * pi / 6) - pi / 2;
          final x = center.dx + (size.width * 0.2) * cos(angle);
          final y = center.dy + (size.height * 0.2) * sin(angle);
          if (i == 0) {
            innerPath.moveTo(x, y);
          } else {
            innerPath.lineTo(x, y);
          }
        }
        innerPath.close();
        canvas.drawPath(innerPath, paint..strokeWidth = 1.5);
        break;

      case 20: // D20 - Icosahedron (complex)
        // Outer triangle
        final outerPath = Path();
        for (int i = 0; i < 3; i++) {
          final angle = (i * 2 * pi / 3) - pi / 2;
          final x = center.dx + (size.width * 0.42) * cos(angle);
          final y = center.dy + (size.height * 0.42) * sin(angle);
          if (i == 0) {
            outerPath.moveTo(x, y);
          } else {
            outerPath.lineTo(x, y);
          }
        }
        outerPath.close();
        canvas.drawPath(outerPath, fillPaint);
        canvas.drawPath(outerPath, paint);

        // Inner inverted triangle
        final innerPath = Path();
        for (int i = 0; i < 3; i++) {
          final angle = (i * 2 * pi / 3) + pi / 2;
          final x = center.dx + (size.width * 0.25) * cos(angle);
          final y = center.dy + (size.height * 0.25) * sin(angle);
          if (i == 0) {
            innerPath.moveTo(x, y);
          } else {
            innerPath.lineTo(x, y);
          }
        }
        innerPath.close();
        canvas.drawPath(innerPath, paint..strokeWidth = 1.5);

        // Center lines
        for (int i = 0; i < 3; i++) {
          final angle = (i * 2 * pi / 3) - pi / 2;
          final x = center.dx + (size.width * 0.42) * cos(angle);
          final y = center.dy + (size.height * 0.42) * sin(angle);
          canvas.drawLine(center, Offset(x, y), paint..strokeWidth = 1.5);
        }
        break;

      case 100: // D100 - Two overlapping squares
        final size1 = size.width * 0.35;
        final size2 = size.width * 0.35;

        // First square (bottom-left)
        final rect1 = Rect.fromLTWH(
          size.width * 0.15,
          size.height * 0.25,
          size1,
          size1,
        );
        canvas.drawRect(rect1, fillPaint);
        canvas.drawRect(rect1, paint);

        // Second square (top-right, overlapping)
        final rect2 = Rect.fromLTWH(
          size.width * 0.35,
          size.height * 0.15,
          size2,
          size2,
        );
        canvas.drawRect(rect2, fillPaint);
        canvas.drawRect(rect2, paint);

        // Draw "00" and "%" indicators
        final textPainter = TextPainter(
          text: TextSpan(
            text: '%',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(size.width * 0.4, size.height * 0.25),
        );
        break;
    }
  }

  @override
  bool shouldRepaint(DicePainter oldDelegate) {
    return oldDelegate.diceType != diceType || oldDelegate.color != color;
  }
}

// =============================================================================
// MODEL: DiceRoll
// =============================================================================
class DiceRoll {
  final int diceType;
  final int diceCount;
  final int modifier;
  final List<int> rolls;
  final int total;
  final DateTime timestamp;

  DiceRoll({
    required this.diceType,
    required this.diceCount,
    required this.modifier,
    required this.rolls,
    required this.total,
    required this.timestamp,
  });
}

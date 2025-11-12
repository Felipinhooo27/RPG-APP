import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';

/// Badge hexagonal para mostrar resultados (usado no histórico e outras áreas)
class HexagonResultBadge extends StatelessWidget {
  final int value;
  final bool isSmall; // true = histórico (32px), false = normal (48px)

  const HexagonResultBadge({
    super.key,
    required this.value,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = isSmall ? 32.0 : 48.0;
    final fontSize = isSmall ? 14.0 : 20.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hexágono vermelho sólido
          CustomPaint(
            size: Size(size, size),
            painter: _HexagonResultPainter(
              color: AppColors.scarletRed,
            ),
          ),

          // Número branco dentro
          Text(
            '$value',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter para hexágono sólido vermelho
class _HexagonResultPainter extends CustomPainter {
  final Color color;

  _HexagonResultPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Cria o path do hexágono
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - (math.pi / 2); // Rotação para flat-top
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Preenchimento sólido
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Shadow/glow sutil
    final glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

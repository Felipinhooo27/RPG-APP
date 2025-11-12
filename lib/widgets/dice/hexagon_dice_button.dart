import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import 'dice_shape_painters.dart';

/// Botão de dado em formato hexagonal para a Barra do Arsenal
class HexagonDiceButton extends StatelessWidget {
  final int faces; // 4, 6, 8, 10, 12, 20, 100
  final int count; // Quantos desse tipo foram selecionados
  final VoidCallback onTap;
  final bool isModifier; // Se true, é o botão ±

  const HexagonDiceButton({
    super.key,
    required this.faces,
    required this.count,
    required this.onTap,
    this.isModifier = false,
  });

  /// Retorna cor vibrante do Google Dice Roller para cada tipo de dado
  Color _getDiceColor(int faces) {
    switch (faces) {
      case 4:
        return const Color(0xFF00BCD4); // Azul-piscina (Cyan)
      case 6:
        return const Color(0xFF9C27B0); // Roxo
      case 8:
        return const Color(0xFF673AB7); // Roxo/Violeta
      case 10:
        return const Color(0xFFE91E63); // Rosa/Magenta
      case 12:
        return const Color(0xFFF44336); // Vermelho
      case 20:
        return const Color(0xFFFFEB3B); // Amarelo
      case 100:
      default:
        return const Color(0xFFFF9800); // Laranja
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = count > 0;
    final baseColor = isModifier ? const Color(0xFF2a2a2a) : _getDiceColor(faces);
    final fillColor = isSelected ? baseColor : baseColor.withOpacity(0.3);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Forma geométrica específica (ou hexágono para modificador)
            if (isModifier)
              // Modificador usa hexágono simples
              CustomPaint(
                size: const Size(52, 60),
                painter: _HexagonPainter(
                  fillColor: fillColor,
                  strokeColor: isSelected ? baseColor : Colors.transparent,
                  strokeWidth: isSelected ? 3 : 0,
                  hasGlow: isSelected,
                ),
              )
            else
              // Dados usam formas específicas
              DiceShapeWidget(
                faces: faces,
                color: fillColor,
                size: 52,
                hasGlow: isSelected,
                strokeWidth: isSelected ? 3 : 0,
              ),

            // Número do dado
            Text(
              isModifier ? (count == 0 ? '±' : (count > 0 ? '+$count' : '$count')) : '$faces',
              style: TextStyle(
                fontSize: isModifier ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),

            // Badge de contagem (canto superior direito)
            if (count > 0 && !isModifier)
              Positioned(
                top: 2,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.scarletRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${count}x',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Painter para desenhar hexágono
class _HexagonPainter extends CustomPainter {
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final bool hasGlow;

  _HexagonPainter({
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
    required this.hasGlow,
  });

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

    // Preenchimento
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Glow (se selecionado)
    if (hasGlow && strokeWidth > 0) {
      final glowPaint = Paint()
        ..color = strokeColor.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(path, glowPaint);
    }

    // Contorno
    if (strokeWidth > 0) {
      final strokePaint = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

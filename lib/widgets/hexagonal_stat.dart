import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

/// Display de atributo em formato hexagonal (típico de RPG)
class HexagonalStat extends StatelessWidget {
  final String label;
  final int value;
  final int modifier;
  final Color? color;
  final bool showModifier;
  final VoidCallback? onTap;
  final double size;

  const HexagonalStat({
    super.key,
    required this.label,
    required this.value,
    required this.modifier,
    this.color,
    this.showModifier = true,
    this.onTap,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.ritualRed;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hexágono
          CustomPaint(
            size: Size(size, size),
            painter: _HexagonPainter(
              color: effectiveColor,
              borderWidth: 2.5,
            ),
            child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value.toString(),
                      style: TextStyle(
                        fontSize: size * 0.35,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.paleWhite,
                        fontFamily: 'SpaceMono',
                      ),
                    ),
                    if (showModifier)
                      Text(
                        modifier >= 0 ? '+$modifier' : '$modifier',
                        style: TextStyle(
                          fontSize: size * 0.2,
                          fontWeight: FontWeight.w600,
                          color: effectiveColor,
                          fontFamily: 'SpaceMono',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 400.ms),

          const SizedBox(height: 8),

          // Label
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: AppTheme.coldGray,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter para desenhar hexágono
class _HexagonPainter extends CustomPainter {
  final Color color;
  final double borderWidth;

  _HexagonPainter({
    required this.color,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.obscureGray
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = _createHexagonPath(size);

    // Desenha brilho
    canvas.drawPath(path, glowPaint);

    // Desenha preenchimento
    canvas.drawPath(path, paint);

    // Desenha borda
    canvas.drawPath(path, borderPaint);
  }

  Path _createHexagonPath(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2 - borderWidth;

    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - (math.pi / 6); // -30 graus para começar no topo
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Grid de 6 atributos principais (FOR, AGI, VIG, INT, PRE, VIG)
class AttributeGrid extends StatelessWidget {
  final int forca;
  final int agilidade;
  final int vigor;
  final int inteligencia;
  final int presenca;
  final Function(String attribute)? onAttributeTap;

  const AttributeGrid({
    super.key,
    required this.forca,
    required this.agilidade,
    required this.vigor,
    required this.inteligencia,
    required this.presenca,
    this.onAttributeTap,
  });

  int _getModifier(int value) {
    return ((value - 10) / 2).floor();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        HexagonalStat(
          label: 'FOR',
          value: forca,
          modifier: _getModifier(forca),
          color: AppTheme.ritualRed,
          onTap: () => onAttributeTap?.call('FOR'),
        ),
        HexagonalStat(
          label: 'AGI',
          value: agilidade,
          modifier: _getModifier(agilidade),
          color: AppTheme.mutagenGreen,
          onTap: () => onAttributeTap?.call('AGI'),
        ),
        HexagonalStat(
          label: 'VIG',
          value: vigor,
          modifier: _getModifier(vigor),
          color: AppTheme.etherealPurple,
          onTap: () => onAttributeTap?.call('VIG'),
        ),
        HexagonalStat(
          label: 'INT',
          value: inteligencia,
          modifier: _getModifier(inteligencia),
          color: AppTheme.chaoticMagenta,
          onTap: () => onAttributeTap?.call('INT'),
        ),
        HexagonalStat(
          label: 'PRE',
          value: presenca,
          modifier: _getModifier(presenca),
          color: AppTheme.alertYellow,
          onTap: () => onAttributeTap?.call('PRE'),
        ),
      ],
    );
  }
}

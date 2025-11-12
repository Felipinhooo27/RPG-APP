import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/dice_pool.dart';
import '../core/theme/app_colors.dart';

/// Widget que desenha um dado programaticamente
class DiceWidget extends StatelessWidget {
  final DiceType diceType;
  final int? faceValue; // Se null, mostra o tipo, se não, mostra o valor
  final double size;
  final Color? color;

  const DiceWidget({
    Key? key,
    required this.diceType,
    this.faceValue,
    required this.size,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DicePainter(
        diceType: diceType,
        faceValue: faceValue,
        color: color ?? _getDefaultColor(),
      ),
    );
  }

  Color _getDefaultColor() {
    switch (diceType) {
      case DiceType.d4:
        return AppColors.conhecimentoGreen;
      case DiceType.d6:
        return AppColors.preGold;
      case DiceType.d8:
        return AppColors.silver;
      case DiceType.d10:
        return const Color(0xFFB50D0D); // Vermelho escuro
      case DiceType.d12:
        return AppColors.magenta;
      case DiceType.d20:
        return AppColors.scarletRed;
      case DiceType.d100:
        return AppColors.preGold;
    }
  }
}

class _DicePainter extends CustomPainter {
  final DiceType diceType;
  final int? faceValue;
  final Color color;

  _DicePainter({
    required this.diceType,
    this.faceValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    // Desenha a forma do dado
    _drawDiceShape(canvas, center, radius);

    // Desenha o número
    _drawNumber(canvas, size);
  }

  void _drawDiceShape(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    switch (diceType) {
      case DiceType.d20:
        _drawPolygon(canvas, center, radius, 6, paint, borderPaint); // Hexágono
        break;
      case DiceType.d12:
        _drawPolygon(canvas, center, radius, 5, paint, borderPaint); // Pentágono
        break;
      case DiceType.d10:
        _drawDiamond(canvas, center, radius, paint, borderPaint); // Diamante
        break;
      case DiceType.d100:
        _drawDiamond(canvas, center, radius, paint, borderPaint); // Diamante
        break;
      case DiceType.d8:
        _drawPolygon(canvas, center, radius, 8, paint, borderPaint); // Octógono
        break;
      case DiceType.d6:
        _drawSquare(canvas, center, radius, paint, borderPaint); // Quadrado
        break;
      case DiceType.d4:
        _drawTriangle(canvas, center, radius, paint, borderPaint); // Triângulo
        break;
    }
  }

  void _drawPolygon(Canvas canvas, Offset center, double radius, int sides,
      Paint paint, Paint borderPaint) {
    final path = Path();
    final angle = (math.pi * 2) / sides;

    for (int i = 0; i < sides; i++) {
      final x = center.dx + radius * math.cos(angle * i - math.pi / 2);
      final y = center.dy + radius * math.sin(angle * i - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  void _drawSquare(Canvas canvas, Offset center, double radius, Paint paint,
      Paint borderPaint) {
    final rect = Rect.fromCenter(
      center: center,
      width: radius * 1.8,
      height: radius * 1.8,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      borderPaint,
    );
  }

  void _drawTriangle(Canvas canvas, Offset center, double radius, Paint paint,
      Paint borderPaint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx - radius * 0.866, center.dy + radius * 0.5);
    path.lineTo(center.dx + radius * 0.866, center.dy + radius * 0.5);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  void _drawDiamond(Canvas canvas, Offset center, double radius, Paint paint,
      Paint borderPaint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx + radius, center.dy);
    path.lineTo(center.dx, center.dy + radius);
    path.lineTo(center.dx - radius, center.dy);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  void _drawNumber(Canvas canvas, Size size) {
    final String text = faceValue?.toString() ?? _getDiceLabel();

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: faceValue != null ? size.width * 0.4 : size.width * 0.3,
      fontWeight: FontWeight.bold,
      fontFamily: 'monospace',
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);
  }

  String _getDiceLabel() {
    switch (diceType) {
      case DiceType.d4:
        return '4';
      case DiceType.d6:
        return '6';
      case DiceType.d8:
        return '8';
      case DiceType.d10:
        return '10';
      case DiceType.d12:
        return '12';
      case DiceType.d20:
        return '20';
      case DiceType.d100:
        return '100';
    }
  }

  @override
  bool shouldRepaint(covariant _DicePainter oldDelegate) {
    return oldDelegate.diceType != diceType ||
        oldDelegate.faceValue != faceValue ||
        oldDelegate.color != color;
  }
}

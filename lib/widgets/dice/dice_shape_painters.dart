import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Painter para triângulo equilátero (d4, d8, d20)
class TrianglePainter extends CustomPainter {
  final Color fillColor;
  final bool hasGlow;
  final double strokeWidth;

  TrianglePainter({
    required this.fillColor,
    this.hasGlow = false,
    this.strokeWidth = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Cria triângulo equilátero apontando para cima
    final path = Path();
    for (int i = 0; i < 3; i++) {
      // 3 vértices, começando do topo
      final angle = (2 * math.pi / 3) * i - (math.pi / 2);
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

    // Glow effect
    if (hasGlow) {
      final glowPaint = Paint()
        ..color = fillColor.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(path, glowPaint);
    }

    // Contorno
    if (strokeWidth > 0) {
      final strokePaint = Paint()
        ..color = fillColor.withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter para quadrado (d6)
class SquarePainter extends CustomPainter {
  final Color fillColor;
  final bool hasGlow;
  final double strokeWidth;

  SquarePainter({
    required this.fillColor,
    this.hasGlow = false,
    this.strokeWidth = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sideLength = size.width * 0.85; // Um pouco menor para não tocar as bordas
    final offset = (size.width - sideLength) / 2;

    // Cria quadrado rotacionado 45 graus (como um diamante)
    final center = Offset(size.width / 2, size.height / 2);
    final halfSide = sideLength / 2;

    final path = Path();
    // Topo
    path.moveTo(center.dx, offset);
    // Direita
    path.lineTo(size.width - offset, center.dy);
    // Baixo
    path.lineTo(center.dx, size.height - offset);
    // Esquerda
    path.lineTo(offset, center.dy);
    path.close();

    // Preenchimento
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Glow effect
    if (hasGlow) {
      final glowPaint = Paint()
        ..color = fillColor.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(path, glowPaint);
    }

    // Contorno
    if (strokeWidth > 0) {
      final strokePaint = Paint()
        ..color = fillColor.withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter para pipa/quadrilátero (d10)
class KitePainter extends CustomPainter {
  final Color fillColor;
  final bool hasGlow;
  final double strokeWidth;

  KitePainter({
    required this.fillColor,
    this.hasGlow = false,
    this.strokeWidth = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width;
    final height = size.height;

    // Cria forma de pipa (kite)
    final path = Path();
    // Topo (ponto afiado)
    path.moveTo(center.dx, height * 0.15);
    // Direita
    path.lineTo(width * 0.75, center.dy);
    // Baixo (ponto afiado mais longo)
    path.lineTo(center.dx, height * 0.9);
    // Esquerda
    path.lineTo(width * 0.25, center.dy);
    path.close();

    // Preenchimento
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Glow effect
    if (hasGlow) {
      final glowPaint = Paint()
        ..color = fillColor.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(path, glowPaint);
    }

    // Contorno
    if (strokeWidth > 0) {
      final strokePaint = Paint()
        ..color = fillColor.withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter para pentágono (d12)
class PentagonPainter extends CustomPainter {
  final Color fillColor;
  final bool hasGlow;
  final double strokeWidth;

  PentagonPainter({
    required this.fillColor,
    this.hasGlow = false,
    this.strokeWidth = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Cria pentágono regular
    final path = Path();
    for (int i = 0; i < 5; i++) {
      // 5 vértices, começando do topo
      final angle = (2 * math.pi / 5) * i - (math.pi / 2);
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

    // Glow effect
    if (hasGlow) {
      final glowPaint = Paint()
        ..color = fillColor.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(path, glowPaint);
    }

    // Contorno
    if (strokeWidth > 0) {
      final strokePaint = Paint()
        ..color = fillColor.withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter para hexágono (d100)
class HexagonPainter extends CustomPainter {
  final Color fillColor;
  final bool hasGlow;
  final double strokeWidth;

  HexagonPainter({
    required this.fillColor,
    this.hasGlow = false,
    this.strokeWidth = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Cria hexágono flat-top
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - (math.pi / 2);
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

    // Glow effect
    if (hasGlow) {
      final glowPaint = Paint()
        ..color = fillColor.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(path, glowPaint);
    }

    // Contorno
    if (strokeWidth > 0) {
      final strokePaint = Paint()
        ..color = fillColor.withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget helper que retorna o painter correto para cada tipo de dado
class DiceShapeWidget extends StatelessWidget {
  final int faces;
  final Color color;
  final double size;
  final bool hasGlow;
  final double strokeWidth;
  final Widget? child;

  const DiceShapeWidget({
    super.key,
    required this.faces,
    required this.color,
    required this.size,
    this.hasGlow = false,
    this.strokeWidth = 0,
    this.child,
  });

  CustomPainter _getPainter() {
    switch (faces) {
      case 4:
        return TrianglePainter(
          fillColor: color,
          hasGlow: hasGlow,
          strokeWidth: strokeWidth,
        );
      case 6:
        return SquarePainter(
          fillColor: color,
          hasGlow: hasGlow,
          strokeWidth: strokeWidth,
        );
      case 8:
        return TrianglePainter(
          fillColor: color,
          hasGlow: hasGlow,
          strokeWidth: strokeWidth,
        );
      case 10:
        return KitePainter(
          fillColor: color,
          hasGlow: hasGlow,
          strokeWidth: strokeWidth,
        );
      case 12:
        return PentagonPainter(
          fillColor: color,
          hasGlow: hasGlow,
          strokeWidth: strokeWidth,
        );
      case 20:
        return TrianglePainter(
          fillColor: color,
          hasGlow: hasGlow,
          strokeWidth: strokeWidth,
        );
      case 100:
      default:
        return HexagonPainter(
          fillColor: color,
          hasGlow: hasGlow,
          strokeWidth: strokeWidth,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _getPainter(),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

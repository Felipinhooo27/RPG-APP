import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

/// SVG-based dice widgets for Hexatombe
/// Minimalist design with clean geometric shapes

class DiceSvg extends StatelessWidget {
  final DiceType type;
  final double size;
  final Color? color;
  final int? value; // Current value shown on die
  final bool isRolling;

  const DiceSvg({
    super.key,
    required this.type,
    this.size = 80,
    this.color,
    this.value,
    this.isRolling = false,
  });

  @override
  Widget build(BuildContext context) {
    final diceColor = color ?? AppTheme.scarletRed;

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedRotation(
        turns: isRolling ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        child: CustomPaint(
          painter: _DicePainter(
            type: type,
            color: diceColor,
            value: value,
          ),
        ),
      ),
    );
  }
}

enum DiceType { d4, d6, d8, d10, d12, d20, d100 }

class _DicePainter extends CustomPainter {
  final DiceType type;
  final Color color;
  final int? value;

  _DicePainter({
    required this.type,
    required this.color,
    this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.miter;

    final fillPaint = Paint()
      ..color = AppTheme.deepBlack
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.2;

    switch (type) {
      case DiceType.d4:
        _drawD4(canvas, size, center, radius, paint, fillPaint);
        break;
      case DiceType.d6:
        _drawD6(canvas, size, center, radius, paint, fillPaint);
        break;
      case DiceType.d8:
        _drawD8(canvas, size, center, radius, paint, fillPaint);
        break;
      case DiceType.d10:
        _drawD10(canvas, size, center, radius, paint, fillPaint);
        break;
      case DiceType.d12:
        _drawD12(canvas, size, center, radius, paint, fillPaint);
        break;
      case DiceType.d20:
        _drawD20(canvas, size, center, radius, paint, fillPaint);
        break;
      case DiceType.d100:
        _drawD100(canvas, size, center, radius, paint, fillPaint);
        break;
    }

    // Draw value if provided
    if (value != null) {
      _drawValue(canvas, center, size.width);
    }
  }

  void _drawD4(Canvas canvas, Size size, Offset center, double radius, Paint paint, Paint fillPaint) {
    // Tetrahedron (4-sided pyramid)
    final path = Path();

    // Triangle base
    final top = Offset(center.dx, center.dy - radius);
    final bottomLeft = Offset(center.dx - radius * 0.87, center.dy + radius * 0.5);
    final bottomRight = Offset(center.dx + radius * 0.87, center.dy + radius * 0.5);

    path.moveTo(top.dx, top.dy);
    path.lineTo(bottomLeft.dx, bottomLeft.dy);
    path.lineTo(bottomRight.dx, bottomRight.dy);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    // Center lines to show 3D
    canvas.drawLine(top, center, paint);
    canvas.drawLine(bottomLeft, center, paint);
    canvas.drawLine(bottomRight, center, paint);
  }

  void _drawD6(Canvas canvas, Size size, Offset center, double radius, Paint paint, Paint fillPaint) {
    // Cube (6-sided die)
    final cubeSize = radius * 1.2;

    // Front face
    final frontPath = Path();
    frontPath.moveTo(center.dx - cubeSize / 2, center.dy - cubeSize / 2);
    frontPath.lineTo(center.dx + cubeSize / 2, center.dy - cubeSize / 2);
    frontPath.lineTo(center.dx + cubeSize / 2, center.dy + cubeSize / 2);
    frontPath.lineTo(center.dx - cubeSize / 2, center.dy + cubeSize / 2);
    frontPath.close();

    canvas.drawPath(frontPath, fillPaint);
    canvas.drawPath(frontPath, paint);

    // Top face (isometric)
    final topPath = Path();
    topPath.moveTo(center.dx - cubeSize / 2, center.dy - cubeSize / 2);
    topPath.lineTo(center.dx, center.dy - cubeSize / 2 - cubeSize * 0.3);
    topPath.lineTo(center.dx + cubeSize / 2 + cubeSize * 0.3, center.dy - cubeSize / 2);
    topPath.lineTo(center.dx + cubeSize / 2, center.dy - cubeSize / 2);
    topPath.close();

    canvas.drawPath(topPath, fillPaint);
    canvas.drawPath(topPath, paint);

    // Right face
    final rightPath = Path();
    rightPath.moveTo(center.dx + cubeSize / 2, center.dy - cubeSize / 2);
    rightPath.lineTo(center.dx + cubeSize / 2 + cubeSize * 0.3, center.dy - cubeSize / 2);
    rightPath.lineTo(center.dx + cubeSize / 2 + cubeSize * 0.3, center.dy + cubeSize / 2);
    rightPath.lineTo(center.dx + cubeSize / 2, center.dy + cubeSize / 2);
    rightPath.close();

    canvas.drawPath(rightPath, fillPaint);
    canvas.drawPath(rightPath, paint);
  }

  void _drawD8(Canvas canvas, Size size, Offset center, double radius, Paint paint, Paint fillPaint) {
    // Octahedron (8-sided die) - two pyramids
    final path = Path();

    // Top pyramid
    final top = Offset(center.dx, center.dy - radius);
    final left = Offset(center.dx - radius * 0.7, center.dy);
    final right = Offset(center.dx + radius * 0.7, center.dy);
    final bottom = Offset(center.dx, center.dy + radius);

    // Draw diamond shape
    path.moveTo(top.dx, top.dy);
    path.lineTo(left.dx, left.dy);
    path.lineTo(bottom.dx, bottom.dy);
    path.lineTo(right.dx, right.dy);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    // Center lines
    canvas.drawLine(top, bottom, paint);
    canvas.drawLine(left, right, paint);
  }

  void _drawD10(Canvas canvas, Size size, Offset center, double radius, Paint paint, Paint fillPaint) {
    // Pentagonal trapezohedron (10-sided die)
    final path = Path();
    final sides = 5;

    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle) * 0.8;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    // Top and bottom points
    final top = Offset(center.dx, center.dy - radius * 1.2);
    final bottom = Offset(center.dx, center.dy + radius * 1.2);

    // Lines to top
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle) * 0.8;
      canvas.drawLine(Offset(x, y), top, paint);
    }
  }

  void _drawD12(Canvas canvas, Size size, Offset center, double radius, Paint paint, Paint fillPaint) {
    // Dodecahedron (12-sided die) - pentagon-based
    final path = Path();
    final sides = 5;

    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle) * 0.9;
      final y = center.dy + radius * math.sin(angle) * 0.9;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    // Inner pentagon
    final innerPath = Path();
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - math.pi / 2;
      final x = center.dx + radius * 0.5 * math.cos(angle);
      final y = center.dy + radius * 0.5 * math.sin(angle);

      if (i == 0) {
        innerPath.moveTo(x, y);
      } else {
        innerPath.lineTo(x, y);
      }
    }
    innerPath.close();
    canvas.drawPath(innerPath, paint);

    // Connect outer to inner
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - math.pi / 2;
      final outer = Offset(
        center.dx + radius * 0.9 * math.cos(angle),
        center.dy + radius * 0.9 * math.sin(angle),
      );
      final inner = Offset(
        center.dx + radius * 0.5 * math.cos(angle),
        center.dy + radius * 0.5 * math.sin(angle),
      );
      canvas.drawLine(outer, inner, paint);
    }
  }

  void _drawD20(Canvas canvas, Size size, Offset center, double radius, Paint paint, Paint fillPaint) {
    // Icosahedron (20-sided die) - triangular faces
    final path = Path();
    final sides = 6;

    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

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
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides);
      final x = center.dx + radius * 0.6 * math.cos(angle);
      final y = center.dy + radius * 0.6 * math.sin(angle);

      if (i == 0) {
        innerPath.moveTo(x, y);
      } else {
        innerPath.lineTo(x, y);
      }
    }
    innerPath.close();
    canvas.drawPath(innerPath, paint);

    // Radial lines
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides);
      final outer = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, outer, paint);
    }
  }

  void _drawD100(Canvas canvas, Size size, Offset center, double radius, Paint paint, Paint fillPaint) {
    // Similar to d10 but with "00" markings
    _drawD10(canvas, size, center, radius, paint, fillPaint);

    // Add "%" symbol or "00" indicator
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '%',
        style: TextStyle(
          color: AppTheme.silver,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          fontFamily: 'SpaceMono',
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx + radius * 0.5,
        center.dy - radius * 0.8,
      ),
    );
  }

  void _drawValue(Canvas canvas, Offset center, double size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: value.toString(),
        style: TextStyle(
          color: color,
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
          fontFamily: 'BebasNeue',
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_DicePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.type != type;
  }
}

/// Animated dice roll widget
class AnimatedDice extends StatefulWidget {
  final DiceType type;
  final int? result;
  final bool isRolling;
  final double size;
  final Color? color;

  const AnimatedDice({
    super.key,
    required this.type,
    this.result,
    this.isRolling = false,
    this.size = 100,
    this.color,
  });

  @override
  State<AnimatedDice> createState() => _AnimatedDiceState();
}

class _AnimatedDiceState extends State<AnimatedDice>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (widget.isRolling) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedDice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling && !oldWidget.isRolling) {
      _controller.repeat();
    } else if (!widget.isRolling && oldWidget.isRolling) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * math.pi,
          child: DiceSvg(
            type: widget.type,
            size: widget.size,
            color: widget.color,
            value: widget.isRolling ? null : widget.result,
            isRolling: widget.isRolling,
          ),
        );
      },
    );
  }
}

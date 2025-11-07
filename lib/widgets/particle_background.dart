import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

/// Background com partículas flutuantes para atmosfera ocultista
class ParticleBackground extends StatefulWidget {
  final int particleCount;
  final Color? particleColor;
  final double minSize;
  final double maxSize;
  final double speed;
  final bool showLines; // Linhas conectando partículas próximas (efeito Matrix/ritual)

  const ParticleBackground({
    super.key,
    this.particleCount = 50,
    this.particleColor,
    this.minSize = 1.0,
    this.maxSize = 3.0,
    this.speed = 0.5,
    this.showLines = true,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _particles = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeParticles();
  }

  void _initializeParticles() {
    final size = MediaQuery.of(context).size;
    _particles = List.generate(widget.particleCount, (index) {
      return Particle(
        x: _random.nextDouble() * size.width,
        y: _random.nextDouble() * size.height,
        size: widget.minSize + _random.nextDouble() * (widget.maxSize - widget.minSize),
        velocityX: (_random.nextDouble() - 0.5) * widget.speed,
        velocityY: (_random.nextDouble() - 0.5) * widget.speed,
        opacity: 0.3 + _random.nextDouble() * 0.4,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        _updateParticles();
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            color: widget.particleColor ?? AppTheme.ritualRed,
            showLines: widget.showLines,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  void _updateParticles() {
    final size = MediaQuery.of(context).size;
    for (var particle in _particles) {
      particle.x += particle.velocityX;
      particle.y += particle.velocityY;

      // Wrap around edges
      if (particle.x < 0) particle.x = size.width;
      if (particle.x > size.width) particle.x = 0;
      if (particle.y < 0) particle.y = size.height;
      if (particle.y > size.height) particle.y = 0;
    }
  }
}

class Particle {
  double x;
  double y;
  final double size;
  final double velocityX;
  final double velocityY;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.velocityX,
    required this.velocityY,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color color;
  final bool showLines;
  static const double _lineConnectionDistance = 120.0;

  _ParticlePainter({
    required this.particles,
    required this.color,
    required this.showLines,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Desenha linhas de conexão primeiro (atrás das partículas)
    if (showLines) {
      _drawConnections(canvas);
    }

    // Desenha partículas
    final paint = Paint()..color = color;

    for (var particle in particles) {
      paint.color = color.withOpacity(particle.opacity);

      // Partícula principal
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );

      // Brilho suave ao redor
      final glowPaint = Paint()
        ..color = color.withOpacity(particle.opacity * 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * 2,
        glowPaint,
      );
    }
  }

  void _drawConnections(Canvas canvas) {
    final linePaint = Paint()
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final p1 = particles[i];
        final p2 = particles[j];

        final dx = p1.x - p2.x;
        final dy = p1.y - p2.y;
        final distance = math.sqrt(dx * dx + dy * dy);

        if (distance < _lineConnectionDistance) {
          final opacity = (1 - distance / _lineConnectionDistance) * 0.15;
          linePaint.color = color.withOpacity(opacity);

          canvas.drawLine(
            Offset(p1.x, p1.y),
            Offset(p2.x, p2.y),
            linePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}

/// Background com gradiente e partículas (ready-to-use)
class HexatombeBackground extends StatelessWidget {
  final Widget child;
  final bool showParticles;
  final Gradient? gradient;

  const HexatombeBackground({
    super.key,
    required this.child,
    this.showParticles = true,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradiente de fundo
        Container(
          decoration: BoxDecoration(
            gradient: gradient ??
                const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.abyssalBlack,
                    AppTheme.obscureGray,
                    AppTheme.abyssalBlack,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
          ),
        ),

        // Partículas
        if (showParticles)
          const Positioned.fill(
            child: ParticleBackground(
              particleCount: 40,
              particleColor: AppTheme.ritualRed,
              minSize: 1.0,
              maxSize: 2.5,
              speed: 0.3,
              showLines: true,
            ),
          ),

        // Conteúdo
        child,
      ],
    );
  }
}

/// Vinheta escura nas bordas (efeito de foco central)
class VignetteOverlay extends StatelessWidget {
  final double intensity;

  const VignetteOverlay({
    super.key,
    this.intensity = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Colors.transparent,
              AppTheme.abyssalBlack.withOpacity(intensity),
            ],
            stops: const [0.3, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Padrão de linhas rituais de fundo (grid)
class RitualGridPattern extends StatelessWidget {
  final Color color;
  final double spacing;
  final double opacity;

  const RitualGridPattern({
    super.key,
    this.color = AppTheme.ritualRed,
    this.spacing = 40.0,
    this.opacity = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RitualGridPainter(
        color: color.withOpacity(opacity),
        spacing: spacing,
      ),
      size: Size.infinite,
    );
  }
}

class _RitualGridPainter extends CustomPainter {
  final Color color;
  final double spacing;

  _RitualGridPainter({
    required this.color,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Linhas verticais
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Linhas horizontais
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RitualGridPainter oldDelegate) => false;
}

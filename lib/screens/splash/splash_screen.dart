import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../mode_selection/mode_selection_screen.dart';

/// Splash Screen com animação espetacular de 7 dados SVG
/// D4, D6, D8, D10, D12, D20, D100 em orbital colorido
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _orbitalController;
  late AnimationController _entranceController;

  bool _canSkip = false;

  // Configuração dos 7 dados
  final List<Map<String, dynamic>> _diceConfig = [
    {
      'asset': 'assets/images/dice/d20.svg',
      'color': const Color(0xFFB50D0D),
      'angle': 0.0,
      'size': 60.0,
      'delay': 0.0,
    },
    {
      'asset': 'assets/images/dice/d4.svg',
      'color': const Color(0xFF00E676),
      'angle': math.pi * 2 / 7 * 1,
      'size': 40.0,
      'delay': 0.1,
    },
    {
      'asset': 'assets/images/dice/d6.svg',
      'color': const Color(0xFFFFD700),
      'angle': math.pi * 2 / 7 * 2,
      'size': 45.0,
      'delay': 0.2,
    },
    {
      'asset': 'assets/images/dice/d8.svg',
      'color': const Color(0xFF9E9E9E),
      'angle': math.pi * 2 / 7 * 3,
      'size': 42.0,
      'delay': 0.3,
    },
    {
      'asset': 'assets/images/dice/d10.svg',
      'color': const Color(0xFFFF1744),
      'angle': math.pi * 2 / 7 * 4,
      'size': 44.0,
      'delay': 0.4,
    },
    {
      'asset': 'assets/images/dice/d12.svg',
      'color': const Color(0xFFD500F9),
      'angle': math.pi * 2 / 7 * 5,
      'size': 46.0,
      'delay': 0.5,
    },
    {
      'asset': 'assets/images/dice/d100.svg',
      'color': const Color(0xFFFF006E),
      'angle': math.pi * 2 / 7 * 6,
      'size': 48.0,
      'delay': 0.6,
    },
  ];

  @override
  void initState() {
    super.initState();

    // Animação de rotação individual dos dados
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Animação de escala (pulsação)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Animação de fade do título
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    // Animação orbital (dados girando em círculo)
    _orbitalController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Animação de entrada (staggered entrance)
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    // Permite skip após 2.5s
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() => _canSkip = true);
      }
    });

    // Navega automaticamente após 3s
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToModeSelection();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    _orbitalController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _navigateToModeSelection() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ModeSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: GestureDetector(
        onTap: _canSkip ? _navigateToModeSelection : null,
        child: Stack(
          children: [
            // Partículas de fundo
            ..._buildParticles(),

            // Conteúdo principal
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Sistema orbital de dados SVG
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: Stack(
                      children: [
                        // Círculo orbital de fundo
                        Center(
                          child: AnimatedBuilder(
                            animation: _scaleController,
                            builder: (context, child) {
                              return Container(
                                width: 200 + (_scaleController.value * 20),
                                height: 200 + (_scaleController.value * 20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.scarletRed.withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/icons/simbolodesangue.png',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.contain,
                                    color: AppColors.scarletRed,
                                    colorBlendMode: BlendMode.srcIn,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Dados em órbita
                        ..._buildOrbitalDice(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Título HEXATOMBE (Imagem)
                  FadeTransition(
                    opacity: _fadeController,
                    child: Image.asset(
                      'assets/images/icons/hexatombe.png',
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtítulo
                  FadeTransition(
                    opacity: _fadeController,
                    child: Text(
                      'ORDEM PARANORMAL RPG',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.silver,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Loading dots
                  _buildLoadingDots(),
                ],
              ),
            ),

            // Skip hint
            if (_canSkip)
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Center(
                    child: Text(
                      'TOQUE PARA CONTINUAR',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.silver.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Constrói os dados em órbita com animações
  List<Widget> _buildOrbitalDice() {
    return _diceConfig.map((dice) {
      return AnimatedBuilder(
        animation: Listenable.merge([
          _orbitalController,
          _rotationController,
          _entranceController,
        ]),
        builder: (context, child) {
          // Ângulo orbital (rotação em torno do centro)
          final orbitalAngle =
              dice['angle'] + (_orbitalController.value * 2 * math.pi);

          // Raio da órbita
          final radius = 100.0;

          // Posição X e Y na órbita
          final x = 140 + (radius * math.cos(orbitalAngle)) - (dice['size'] / 2);
          final y = 140 + (radius * math.sin(orbitalAngle)) - (dice['size'] / 2);

          // Entrada staggered (cada dado aparece com delay)
          final entranceProgress = ((_entranceController.value - dice['delay']) / 0.4)
              .clamp(0.0, 1.0);
          final entranceScale = Curves.elasticOut.transform(entranceProgress);
          final entranceOpacity = entranceProgress;

          // Rotação individual do dado
          final rotation = _rotationController.value * 2 * math.pi;

          return Positioned(
            left: x,
            top: y,
            child: Opacity(
              opacity: entranceOpacity,
              child: Transform.scale(
                scale: entranceScale,
                child: Transform.rotate(
                  angle: rotation,
                  child: Container(
                    width: dice['size'],
                    height: dice['size'],
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: (dice['color'] as Color).withOpacity(0.6),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      dice['asset'],
                      width: dice['size'],
                      height: dice['size'],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  /// Constrói as partículas de fundo
  List<Widget> _buildParticles() {
    return List.generate(15, (index) {
      final random = math.Random(index);
      return Positioned(
        left: random.nextDouble() * 400,
        top: random.nextDouble() * 800,
        child: AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) {
            return Opacity(
              opacity: 0.05 + (random.nextDouble() * 0.15),
              child: Container(
                width: 3 + (random.nextDouble() * 3),
                height: 3 + (random.nextDouble() * 3),
                decoration: BoxDecoration(
                  color: random.nextBool()
                      ? AppColors.scarletRed
                      : AppColors.magenta,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      );
    });
  }

  /// Constrói os dots de loading
  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            final delay = index * 0.33;
            final value =
                ((_rotationController.value + delay) % 1.0).clamp(0.0, 1.0);
            final opacity = 0.3 + (math.sin(value * math.pi) * 0.7);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.scarletRed.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

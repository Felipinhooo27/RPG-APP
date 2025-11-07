import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/particle_background.dart';
import 'mode_selection_screen.dart';

/// Professional splash screen with animated D20 dice and ritual effects
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _controller.forward();

    // Navigate after 3 seconds
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!_navigated && mounted) {
        _navigated = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ModeSelectionScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.abyssalBlack,
      body: GestureDetector(
        onTap: () {
          // Allow tap to skip
          if (!_navigated && mounted) {
            _navigated = true;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ModeSelectionScreen()),
            );
          }
        },
        child: Stack(
          children: [
            // Particle background
            const ParticleBackground(),

            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated D20 dice
                  _buildAnimatedDice(),

                  const SizedBox(height: 60),

                  // HEXATOMBE text
                  _buildTitle(),

                  const SizedBox(height: 20),

                  // Loading indicator
                  _buildLoadingIndicator(),
                ],
              ),
            ),

            // Tap to continue hint (appears near end)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Toque para continuar',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.coldGray,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 2500.ms, duration: 500.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedDice() {
    return Container(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ritual circle glow
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.ritualRed.withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: 2000.ms,
                color: AppTheme.ritualRed.withOpacity(0.5),
              )
              .fadeIn(duration: 300.ms),

          // D20 dice icon
          Icon(
            Icons.casino,
            size: 80,
            color: AppTheme.ritualRed,
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 500.ms)
              .scale(delay: 300.ms, duration: 500.ms, begin: const Offset(0.5, 0.5))
              .then()
              .rotate(
                duration: 1500.ms,
                begin: 0,
                end: 1,
                curve: Curves.elasticOut,
              ),

          // Ritual circle rings
          ...List.generate(3, (index) {
            final size = 120.0 + (index * 30);
            final delay = 500 + (index * 200);
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.ritualRed.withOpacity(0.3 - (index * 0.1)),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(delay: delay.ms, duration: 500.ms)
                .scale(
                  delay: delay.ms,
                  duration: 2000.ms,
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                )
                .fadeOut(duration: 500.ms);
          }),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          AppTheme.ritualRed,
          AppTheme.alertYellow,
          AppTheme.ritualRed,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(bounds),
      child: Text(
        'HEXATOMBE',
        style: GoogleFonts.bebasNeue(
          fontSize: 56,
          fontWeight: FontWeight.w900,
          letterSpacing: 8,
          color: Colors.white,
          height: 1.0,
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 1500.ms, duration: 800.ms)
        .slideY(
          delay: 1500.ms,
          begin: 0.3,
          end: 0,
          duration: 800.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.ritualRed,
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .fadeIn(delay: (2000 + index * 200).ms, duration: 400.ms)
            .fadeOut(delay: (2000 + index * 200).ms, duration: 400.ms);
      }),
    );
  }
}

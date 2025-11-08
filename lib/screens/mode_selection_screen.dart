import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/ritual_card.dart';
import 'player_home_screen.dart';
import 'master_dashboard_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.abyssGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Atmospheric particles effect (subtle)
              _AtmosphericBackground(),

              // Main content
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hexatombe Logo/Title
                      _buildTitle(context),

                      const SizedBox(height: 48),

                      // Mode Selection Cards
                      _ModeCard(
                        icon: Icons.person_outline,
                        title: 'JOGADOR',
                        subtitle: 'Gerencie seus personagens',
                        description: 'Crie fichas, role dados e controle seu inventário',
                        accentColor: AppTheme.ritualRed,
                        onPressed: () {
                          Navigator.push(
                            context,
                            _createRoute(const PlayerHomeScreen()),
                          );
                        },
                      ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(
                            begin: 0.3,
                            end: 0,
                            duration: 600.ms,
                            curve: Curves.easeOut,
                          ),

                      const SizedBox(height: 20),

                      _ModeCard(
                        icon: Icons.shield_outlined,
                        title: 'MESTRE',
                        subtitle: 'Controle total da campanha',
                        description: 'Gerencie personagens, combate e anotações',
                        accentColor: AppTheme.chaoticMagenta,
                        onPressed: () {
                          Navigator.push(
                            context,
                            _createRoute(const MasterDashboardScreen()),
                          );
                        },
                      ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideY(
                            begin: 0.3,
                            end: 0,
                            duration: 600.ms,
                            curve: Curves.easeOut,
                          ),

                      const SizedBox(height: 32),

                      // Footer
                      Text(
                        'Felipe Pontes Herculani Alves - 20224254\nGabriel Lentini Linhares Marques - 20232582\nVicenzo Guizi Pulici - 20224604',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          color: AppTheme.coldGray,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 700.ms, duration: 600.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      children: [
        // Hexatombe symbol (simplified ritual circle)
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.ritualRed.withOpacity(0.35),
                blurRadius: 8,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppTheme.ritualRed.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Inner circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.ritualRed.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              // Center symbol
              Icon(
                Icons.auto_stories_outlined,
                size: 48,
                color: AppTheme.ritualRed,
              ),
            ],
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            )
            .fadeIn(duration: 800.ms)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: 2000.ms,
              curve: Curves.easeInOut,
            ),

        const SizedBox(height: 32),

        // Title
        Text(
          'HEXATOMBE',
          style: GoogleFonts.bebasNeue(
            fontSize: 56,
            letterSpacing: 4,
            color: AppTheme.paleWhite,
            height: 1,
            shadows: [
              Shadow(
                color: AppTheme.ritualRed.withOpacity(0.5),
                blurRadius: 20,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(
              begin: -0.2,
              end: 0,
              duration: 800.ms,
            ),

        const SizedBox(height: 8),

        Text(
          'Feito pelos alunos do CCO Noturno\n6º Período 2025',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: AppTheme.limestoneGray,
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
      ],
    );
  }

  // Custom page transition
  Route _createRoute(Widget destination) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.1);
        const end = Offset.zero;
        const curve = Curves.easeOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        var fadeAnimation = animation.drive(Tween(begin: 0.0, end: 1.0));

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}

/// Atmospheric floating particles background
class _AtmosphericBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-left particle
        Positioned(
          top: 50,
          left: 30,
          child: _FloatingParticle(size: 4, delay: 0),
        ),
        // Top-right particle
        Positioned(
          top: 100,
          right: 50,
          child: _FloatingParticle(size: 6, delay: 1000),
        ),
        // Bottom-left particle
        Positioned(
          bottom: 150,
          left: 60,
          child: _FloatingParticle(size: 5, delay: 1500),
        ),
        // Bottom-right particle
        Positioned(
          bottom: 200,
          right: 40,
          child: _FloatingParticle(size: 3, delay: 500),
        ),
        // Center particles
        Positioned(
          top: 250,
          left: 100,
          child: _FloatingParticle(size: 4, delay: 2000),
        ),
        Positioned(
          top: 300,
          right: 80,
          child: _FloatingParticle(size: 5, delay: 2500),
        ),
      ],
    );
  }
}

class _FloatingParticle extends StatelessWidget {
  final double size;
  final int delay;

  const _FloatingParticle({required this.size, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.ritualRed.withOpacity(0.3),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ritualRed.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .fadeIn(delay: delay.ms, duration: 2000.ms)
        .then()
        .fadeOut(duration: 2000.ms)
        .moveY(
          begin: 0,
          end: -20,
          duration: 4000.ms,
          curve: Curves.easeInOut,
        );
  }
}

/// Large mode selection card with RitualCard for modern Hexatombe design
class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color accentColor;
  final VoidCallback onPressed;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.accentColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return RitualCard(
      glowEffect: true,
      glowColor: accentColor,
      onTap: onPressed,
      padding: const EdgeInsets.all(24),
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          // Icon container with dynamic border radius (7px for consistency)
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(7),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.35),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 36,
              color: accentColor,
            ),
          ),

          const SizedBox(width: 20),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.bebasNeue(
                    fontSize: 32,
                    letterSpacing: 2,
                    color: AppTheme.paleWhite,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.coldGray,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Arrow icon
          Icon(
            Icons.arrow_forward_rounded,
            color: accentColor,
            size: 24,
          ),
        ],
      ),
    );
  }
}

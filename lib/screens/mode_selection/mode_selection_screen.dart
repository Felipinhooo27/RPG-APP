import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/hexatombe_ui_components.dart';
import '../character_selection/character_selection_screen.dart';
import '../master/master_dashboard_screen.dart';

/// Tela de seleção de modo: JOGADOR vs MESTRE
/// Design minimalista estilo "dossiê paranormal"
class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: GrungeBackground(
        opacity: 0.06,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Logo HEXATOMBE
                  Image.asset(
                    'assets/images/icons/hexatombe.png',
                    height: 280,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 16),

                  // Subtítulo
                  Text(
                    'Feito pelos alunos do CCO Noturno',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.silver.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    '6º Período 2025',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.silver.withValues(alpha: 0.7),
                    ),
                  ),

                  const Spacer(),

                  // Divisor superior
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: GrungeDivider(
                      color: AppColors.scarletRed.withValues(alpha: 0.3),
                      height: 2,
                      heavy: false,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Entrada JOGADOR
                  _ModeEntry(
                    icon: Icons.casino_outlined,
                    title: 'JOGADOR',
                    subtitle: 'Gerencie seus personagens',
                    description: 'Crie fichas, role dados e controle seu inventário',
                    onTap: () => _navigateToCharacterSelection(context, false),
                  ),

                  const SizedBox(height: 20),

                  // Divisor Grunge entre opções
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: GrungeDivider(
                      color: AppColors.scarletRed,
                      height: 3,
                      heavy: true,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Entrada MESTRE
                  _ModeEntry(
                    icon: Icons.menu_book_outlined,
                    title: 'MESTRE',
                    subtitle: 'Controle total da campanha',
                    description: 'Gerencie personagens, combate e anotações',
                    onTap: () => _navigateToCharacterSelection(context, true),
                  ),

                  const SizedBox(height: 32),

                  // Divisor inferior
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: GrungeDivider(
                      color: AppColors.scarletRed.withValues(alpha: 0.3),
                      height: 2,
                      heavy: false,
                    ),
                  ),

                  const Spacer(),

                  // Créditos (estilo typewriter)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Felipe Pontes Herculani Alves - 20224254',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: AppColors.silver,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Gabriel Lentini Linhares Marques - 20232582',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: AppColors.silver,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Vicenzo Guizi Pulici - 20224604',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: AppColors.silver,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToCharacterSelection(BuildContext context, bool isMasterMode) {
    if (isMasterMode) {
      // Master vai direto pro dashboard
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MasterDashboardScreen(
            userId: 'master_001',
          ),
        ),
      );
    } else {
      // Player vai pra seleção de personagem
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CharacterSelectionScreen(
            userId: 'player_001',
            isMasterMode: false,
          ),
        ),
      );
    }
  }
}

/// Widget de entrada de modo (design minimalista inline)
class _ModeEntry extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final VoidCallback onTap;

  const _ModeEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.onTap,
  });

  @override
  State<_ModeEntry> createState() => _ModeEntryState();
}

class _ModeEntryState extends State<_ModeEntry> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.only(left: 20, right: 16, top: 16, bottom: 16),
        decoration: BoxDecoration(
          color: _isPressed
              ? AppColors.darkGray.withValues(alpha: 0.8)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: AppColors.scarletRed,
              width: _isPressed ? 6 : 4,
            ),
            top: BorderSide(
              color: AppColors.silver.withValues(alpha: _isPressed ? 0.3 : 0.15),
              width: 1,
            ),
            bottom: BorderSide(
              color: AppColors.silver.withValues(alpha: _isPressed ? 0.3 : 0.15),
              width: 1,
            ),
            right: BorderSide(
              color: AppColors.silver.withValues(alpha: _isPressed ? 0.3 : 0.15),
              width: 1,
            ),
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: AppColors.scarletRed.withValues(alpha: 0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Ícone temático (SEM container)
            Icon(
              widget.icon,
              size: 40,
              color: AppColors.scarletRed,
            ),

            const SizedBox(width: 20),

            // Textos (hierarquia tipográfica)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título GRANDE
                  Text(
                    widget.title,
                    style: AppTextStyles.uppercase.copyWith(
                      fontSize: 24,
                      letterSpacing: 2.5,
                      color: AppColors.lightGray,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Subtítulo médio
                  Text(
                    widget.subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.scarletRed,
                      fontSize: 11,
                      letterSpacing: 1.0,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Descrição pequena
                  Text(
                    widget.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.silver.withValues(alpha: 0.7),
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Seta
            Icon(
              Icons.arrow_forward,
              color: AppColors.scarletRed,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

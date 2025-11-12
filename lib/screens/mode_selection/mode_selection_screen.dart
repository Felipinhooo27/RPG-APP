import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../character_selection/character_selection_screen.dart';
import '../master/master_dashboard_screen.dart';

/// Tela de seleção de modo: JOGADOR vs MESTRE
/// Design exatamente como a referência fornecida
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
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Título HEXATOMBE (Imagem)
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
                    color: AppColors.silver.withOpacity(0.7),
                  ),
                ),
                Text(
                  '6º Período 2025',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.silver.withOpacity(0.7),
                  ),
                ),

                const Spacer(),

                // Card JOGADOR
                _ModeCard(
                  icon: Icons.person_outline,
                  title: 'JOGADOR',
                  subtitle: 'Gerencie seus personagens',
                  description:
                      'Crie fichas, role dados e controle\nseu inventário',
                  color: AppColors.scarletRed,
                  onTap: () => _navigateToCharacterSelection(context, false),
                ),

                const SizedBox(height: 24),

                // Card MESTRE
                _ModeCard(
                  icon: Icons.shield_outlined,
                  title: 'MESTRE',
                  subtitle: 'Controle total da campanha',
                  description:
                      'Gerencie personagens, combate\ne anotações',
                  color: AppColors.magenta,
                  onTap: () => _navigateToCharacterSelection(context, true),
                ),

                const Spacer(),

                // Créditos no footer
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Felipe Pontes Herculani Alves - 20224254',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.silver.withOpacity(0.5),
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gabriel Lentini Linhares Marques - 20232582',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.silver.withOpacity(0.5),
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vicenzo Guizi Pulici - 20224604',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.silver.withOpacity(0.5),
                          fontSize: 10,
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
    );
  }

  void _navigateToCharacterSelection(BuildContext context, bool isMasterMode) {
    if (isMasterMode) {
      // Master vai direto pro dashboard
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MasterDashboardScreen(
            userId: 'master_001',
          ),
        ),
      );
    } else {
      // Player vai pra seleção de personagem
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CharacterSelectionScreen(
            userId: 'player_001',
            isMasterMode: false,
          ),
        ),
      );
    }
  }
}

/// Widget do card de modo (Jogador ou Mestre)
class _ModeCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
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
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          border: Border.all(
            color: widget.color.withOpacity(_isPressed ? 1.0 : 0.5),
            width: _isPressed ? 3 : 2,
          ),
          boxShadow: [
            if (_isPressed)
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
          ],
        ),
        child: Row(
          children: [
            // Ícone com glow
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: 48,
                color: widget.color,
              ),
            ),

            const SizedBox(width: 20),

            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    widget.title,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 28,
                      color: widget.color,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Subtítulo
                  Text(
                    widget.subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: widget.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Descrição
                  Text(
                    widget.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.silver.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Seta
            Icon(
              Icons.arrow_forward,
              color: widget.color,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

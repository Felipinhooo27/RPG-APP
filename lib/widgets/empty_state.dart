import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'hex_button.dart';

/// Beautiful empty state widget with icon, message, and optional action
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  const EmptyState.noCharacters({
    super.key,
    String? actionLabel,
    VoidCallback? onAction,
  })  : icon = Icons.person_add_outlined,
        title = 'Nenhum Personagem',
        message = 'Crie seu primeiro personagem para começar sua jornada no paranormal',
        actionLabel = actionLabel ?? 'Criar Personagem',
        onAction = onAction;

  const EmptyState.noItems({
    super.key,
    String? actionLabel,
    VoidCallback? onAction,
  })  : icon = Icons.inventory_2_outlined,
        title = 'Inventário Vazio',
        message = 'Este personagem ainda não possui itens',
        actionLabel = actionLabel ?? 'Adicionar Item',
        onAction = onAction;

  const EmptyState.noNotes({
    super.key,
    String? actionLabel,
    VoidCallback? onAction,
  })  : icon = Icons.note_outlined,
        title = 'Nenhuma Anotação',
        message = 'Registre informações importantes da sua sessão',
        actionLabel = actionLabel ?? 'Nova Anotação',
        onAction = onAction;

  const EmptyState.noCombat({
    super.key,
  })  : icon = Icons.shield_outlined,
        title = 'Nenhum Combate Ativo',
        message = 'Adicione personagens e role iniciativa para começar',
        actionLabel = null,
        onAction = null;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.industrialGray,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.coldGray.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppTheme.limestoneGray,
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .fadeIn(duration: 500.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 1500.ms,
                  curve: Curves.easeInOut,
                ),

            const SizedBox(height: 24),

            // Title
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: AppTheme.limestoneGray,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.coldGray,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              HexButton.primary(
                label: actionLabel!,
                onPressed: onAction,
                icon: Icons.add,
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(
                    begin: 0.3,
                    end: 0,
                    duration: 500.ms,
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

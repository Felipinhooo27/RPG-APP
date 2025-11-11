import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Card elaborado com tema ritual/ocultista
/// Adaptado para tema Hexatombe
class RitualCard extends StatefulWidget {
  final Widget child;
  final bool glowEffect;
  final Color? glowColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool ritualCorners; // Cantos com símbolos rituais
  final bool pulsate; // Efeito de pulsação

  const RitualCard({
    super.key,
    required this.child,
    this.glowEffect = false,
    this.glowColor,
    this.padding,
    this.margin,
    this.onTap,
    this.width,
    this.height,
    this.ritualCorners = true,
    this.pulsate = false,
  });

  @override
  State<RitualCard> createState() => _RitualCardState();
}

class _RitualCardState extends State<RitualCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveGlowColor = widget.glowColor ?? AppColors.neonRed;

    Widget cardContent = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin ?? const EdgeInsets.all(8),
      padding: widget.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: widget.glowEffect
              ? effectiveGlowColor
              : AppColors.silver.withOpacity(0.3),
          width: widget.glowEffect ? 2 : 1,
        ),
        boxShadow: widget.glowEffect
            ? [
                BoxShadow(
                  color: effectiveGlowColor.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: effectiveGlowColor.withOpacity(0.2),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.silver.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
      ),
      child: Stack(
        children: [
          // Símbolos rituais nos cantos (se habilitado)
          if (widget.ritualCorners) ...[
            _buildRitualCorner(Alignment.topLeft),
            _buildRitualCorner(Alignment.topRight),
            _buildRitualCorner(Alignment.bottomLeft),
            _buildRitualCorner(Alignment.bottomRight),
          ],

          // Conteúdo principal
          widget.child,
        ],
      ),
    );

    // Adiciona animação de pulsação se habilitada
    if (widget.pulsate) {
      cardContent = cardContent
          .animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          )
          .shimmer(
            duration: 2000.ms,
            color: effectiveGlowColor.withOpacity(0.1),
          );
    }

    // Adiciona interatividade se onTap fornecido
    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap!();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }

  /// Constrói um símbolo ritual no canto
  Widget _buildRitualCorner(Alignment alignment) {
    return Positioned(
      top: alignment.y < 0 ? 8 : null,
      bottom: alignment.y > 0 ? 8 : null,
      left: alignment.x < 0 ? 8 : null,
      right: alignment.x > 0 ? 8 : null,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (widget.glowColor ?? AppColors.neonRed).withOpacity(0.5),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (widget.glowColor ?? AppColors.neonRed).withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
}

/// Card grande para destaque (usar início de seção, etc.)
class RitualCardLarge extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? icon;
  final VoidCallback? onTap;
  final Color? accentColor;

  const RitualCardLarge({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.neonRed;

    return RitualCard(
      glowEffect: true,
      glowColor: color,
      onTap: onTap,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                border: Border.all(color: color),
              ),
              child: icon,
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTextStyles.uppercase.copyWith(
                    fontSize: 20,
                    color: color,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.silver,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward, color: color),
        ],
      ),
    );
  }
}

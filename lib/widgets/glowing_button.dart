import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

enum GlowingButtonStyle { primary, secondary, danger, occult }

/// Botão com efeito de brilho elaborado
class GlowingButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final GlowingButtonStyle style;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final bool pulsateGlow;
  final double? width;
  final double? height;

  const GlowingButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style = GlowingButtonStyle.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.pulsateGlow = false,
    this.width,
    this.height,
  });

  const GlowingButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.pulsateGlow = false,
    this.width,
    this.height,
  }) : style = GlowingButtonStyle.primary;

  const GlowingButton.occult({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.pulsateGlow = true,
    this.width,
    this.height,
  }) : style = GlowingButtonStyle.occult;

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.pulsateGlow) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Color get backgroundColor {
    switch (widget.style) {
      case GlowingButtonStyle.primary:
        return AppTheme.ritualRed;
      case GlowingButtonStyle.secondary:
        return AppTheme.etherealPurple;
      case GlowingButtonStyle.danger:
        return AppTheme.alertYellow;
      case GlowingButtonStyle.occult:
        return AppTheme.chaoticMagenta;
    }
  }

  Color get glowColor {
    return backgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    final effectiveWidth = widget.fullWidth ? double.infinity : widget.width;

    return GestureDetector(
      onTapDown: isDisabled || widget.isLoading ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled || widget.isLoading
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed!();
            },
      onTapCancel: isDisabled || widget.isLoading ? null : () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: effectiveWidth,
        height: widget.height ?? 56,
        transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Camada de brilho externa
            if (!isDisabled)
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  final glowIntensity = widget.pulsateGlow
                      ? 0.2 + (_glowController.value * 0.3)
                      : _isPressed
                          ? 0.1
                          : 0.3;

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withOpacity(glowIntensity),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: glowColor.withOpacity(glowIntensity * 0.5),
                          blurRadius: 48,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  );
                },
              ),

            // Botão principal
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDisabled
                      ? [
                          AppTheme.coldGray.withOpacity(0.3),
                          AppTheme.industrialGray.withOpacity(0.3),
                        ]
                      : [
                          backgroundColor,
                          backgroundColor.withOpacity(0.8),
                        ],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: isDisabled
                        ? AppTheme.coldGray.withOpacity(0.3)
                        : backgroundColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isDisabled || widget.isLoading ? null : widget.onPressed,
                  borderRadius: BorderRadius.circular(8),
                  splashColor: AppTheme.paleWhite.withOpacity(0.1),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _getHorizontalPadding(),
                      vertical: _getVerticalPadding(),
                    ),
                    child: _buildContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getHorizontalPadding() {
    final height = widget.height ?? 56;
    if (height <= 44) return 12;
    if (height <= 50) return 16;
    return 24;
  }

  double _getVerticalPadding() {
    final height = widget.height ?? 56;
    if (height <= 44) return 8;
    if (height <= 50) return 12;
    return 16;
  }

  double _getFontSize() {
    final height = widget.height ?? 56;
    if (height <= 44) return 12;
    if (height <= 50) return 14;
    return 16;
  }

  double _getIconSize() {
    final height = widget.height ?? 56;
    if (height <= 44) return 16;
    if (height <= 50) return 18;
    return 22;
  }

  double _getIconSpacing() {
    final height = widget.height ?? 56;
    if (height <= 44) return 6;
    if (height <= 50) return 8;
    return 12;
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: _getIconSize(),
          height: _getIconSize(),
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppTheme.paleWhite),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: _getIconSize(),
            color: AppTheme.paleWhite,
          ),
          SizedBox(width: _getIconSpacing()),
        ],
        Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            fontSize: _getFontSize(),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: AppTheme.paleWhite,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }
}

/// Botão circular grande para dados
class DiceButton extends StatefulWidget {
  final String diceType; // "d4", "d6", "d8", "d10", "d12", "d20"
  final VoidCallback onPressed;
  final bool selected;

  const DiceButton({
    super.key,
    required this.diceType,
    required this.onPressed,
    this.selected = false,
  });

  @override
  State<DiceButton> createState() => _DiceButtonState();
}

class _DiceButtonState extends State<DiceButton> {
  bool _isPressed = false;

  IconData get diceIcon {
    // TODO: Substituir por SVG personalizado
    return Icons.casino_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.selected
                  ? [AppTheme.ritualRed, AppTheme.chaoticMagenta]
                  : [AppTheme.obscureGray, AppTheme.industrialGray],
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: AppTheme.ritualRed.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppTheme.coldGray.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                diceIcon,
                size: 40,
                color: AppTheme.paleWhite,
              ),
              const SizedBox(height: 4),
              Text(
                widget.diceType.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.paleWhite,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

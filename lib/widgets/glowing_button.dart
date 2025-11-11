import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';

enum GlowingButtonStyle { primary, secondary, danger, occult }

/// Botão com efeito de brilho elaborado
/// Adaptado para tema Hexatombe
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
        return AppColors.neonRed;
      case GlowingButtonStyle.secondary:
        return AppColors.medoPurple;
      case GlowingButtonStyle.danger:
        return AppColors.energiaYellow;
      case GlowingButtonStyle.occult:
        return AppColors.magenta;
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
                      borderRadius: BorderRadius.zero,
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
                color: isDisabled
                    ? AppColors.darkGray
                    : backgroundColor,
                borderRadius: BorderRadius.zero,
                border: Border.all(
                  color: isDisabled ? AppColors.silver.withOpacity(0.3) : backgroundColor,
                  width: 2,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isDisabled || widget.isLoading ? null : widget.onPressed,
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
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightGray),
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
            color: AppColors.lightGray,
          ),
          SizedBox(width: _getIconSpacing()),
        ],
        Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            fontSize: _getFontSize(),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: AppColors.lightGray,
          ),
        ),
      ],
    );
  }
}

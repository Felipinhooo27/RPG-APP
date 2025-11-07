import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

enum HexButtonVariant { primary, secondary, danger, ghost }

/// Custom Hexatombe-styled button with press animations
class HexButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final HexButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final double? width;
  final double? height;
  final bool enableHaptic;

  const HexButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = HexButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.width,
    this.height,
    this.enableHaptic = true,
  });

  const HexButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.width,
    this.height,
    this.enableHaptic = true,
  }) : variant = HexButtonVariant.primary;

  const HexButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.width,
    this.height,
    this.enableHaptic = true,
  }) : variant = HexButtonVariant.secondary;

  const HexButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.width,
    this.height,
    this.enableHaptic = true,
  }) : variant = HexButtonVariant.danger;

  const HexButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.width,
    this.height,
    this.enableHaptic = true,
  }) : variant = HexButtonVariant.ghost;

  @override
  State<HexButton> createState() => _HexButtonState();
}

class _HexButtonState extends State<HexButton> {
  bool _isPressed = false;

  Color get backgroundColor {
    switch (widget.variant) {
      case HexButtonVariant.primary:
        return AppTheme.ritualRed;
      case HexButtonVariant.secondary:
        return AppTheme.etherealPurple;
      case HexButtonVariant.danger:
        return AppTheme.alertYellow.withOpacity(0.2);
      case HexButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color get foregroundColor {
    switch (widget.variant) {
      case HexButtonVariant.primary:
      case HexButtonVariant.secondary:
        return AppTheme.paleWhite;
      case HexButtonVariant.danger:
        return AppTheme.alertYellow;
      case HexButtonVariant.ghost:
        return AppTheme.ritualRed;
    }
  }

  BorderSide get borderSide {
    switch (widget.variant) {
      case HexButtonVariant.ghost:
        return const BorderSide(color: AppTheme.ritualRed, width: 1.6);
      case HexButtonVariant.danger:
        return const BorderSide(color: AppTheme.alertYellow, width: 1.6);
      default:
        return BorderSide.none;
    }
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  void _onTap() {
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    final effectiveWidth = widget.fullWidth ? double.infinity : widget.width;

    Widget buttonChild = widget.isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(foregroundColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: foregroundColor),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: foregroundColor,
                ),
              ),
            ],
          );

    return GestureDetector(
      onTapDown: isDisabled || widget.isLoading ? null : _onTapDown,
      onTapUp: isDisabled || widget.isLoading ? null : _onTapUp,
      onTapCancel: isDisabled || widget.isLoading ? null : _onTapCancel,
      onTap: isDisabled || widget.isLoading ? null : _onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: effectiveWidth,
        height: widget.height ?? 48,
        decoration: BoxDecoration(
          color: isDisabled ? backgroundColor.withOpacity(0.5) : backgroundColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.fromBorderSide(borderSide),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        alignment: Alignment.center,
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        child: buttonChild,
      ).animate(target: _isPressed ? 1 : 0).scaleXY(
            begin: 1.0,
            end: 0.95,
            duration: 100.ms,
          ),
    );
  }
}

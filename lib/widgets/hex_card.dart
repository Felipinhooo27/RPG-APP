import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum HexCardVariant { default_, ritual, occult, danger, success }

/// Custom Hexatombe-styled card with optional glowing border
class HexCard extends StatelessWidget {
  final Widget child;
  final HexCardVariant variant;
  final bool enableGlow;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? elevation;
  final Color? customColor;
  final Color? customBorderColor;

  const HexCard({
    super.key,
    required this.child,
    this.variant = HexCardVariant.default_,
    this.enableGlow = false,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation,
    this.customColor,
    this.customBorderColor,
  });

  const HexCard.ritual({
    super.key,
    required this.child,
    this.enableGlow = true,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation,
  })  : variant = HexCardVariant.ritual,
        customColor = null,
        customBorderColor = null;

  const HexCard.occult({
    super.key,
    required this.child,
    this.enableGlow = true,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation,
  })  : variant = HexCardVariant.occult,
        customColor = null,
        customBorderColor = null;

  const HexCard.danger({
    super.key,
    required this.child,
    this.enableGlow = true,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation,
  })  : variant = HexCardVariant.danger,
        customColor = null,
        customBorderColor = null;

  const HexCard.success({
    super.key,
    required this.child,
    this.enableGlow = false,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation,
  })  : variant = HexCardVariant.success,
        customColor = null,
        customBorderColor = null;

  Color get borderColor {
    if (customBorderColor != null) return customBorderColor!;
    switch (variant) {
      case HexCardVariant.default_:
        return AppTheme.industrialGray;
      case HexCardVariant.ritual:
        return AppTheme.ritualRed;
      case HexCardVariant.occult:
        return AppTheme.chaoticMagenta;
      case HexCardVariant.danger:
        return AppTheme.alertYellow;
      case HexCardVariant.success:
        return AppTheme.mutagenGreen;
    }
  }

  Color get backgroundColor {
    if (customColor != null) return customColor!;
    return AppTheme.obscureGray;
  }

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: enableGlow
            ? [
                BoxShadow(
                  color: borderColor.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 0),
                ),
              ]
            : [
                BoxShadow(
                  color: borderColor.withOpacity(0.3),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: AppTheme.abyssalBlack.withOpacity(0.5),
                  blurRadius: elevation ?? 4,
                  offset: Offset(0, (elevation ?? 4) / 2),
                ),
              ],
      ),
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        splashColor: borderColor.withOpacity(0.1),
        highlightColor: borderColor.withOpacity(0.05),
        child: cardContent,
      );
    }

    return cardContent;
  }
}

/// Card specifically for character stats with attribute hexagons
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? modifier;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.modifier,
    this.color,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HexCard(
      padding: const EdgeInsets.all(12),
      customBorderColor: color ?? AppTheme.industrialGray,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 24,
              color: color ?? AppTheme.limestoneGray,
            ),
          if (icon != null) const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: AppTheme.coldGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color ?? AppTheme.paleWhite,
              fontFamily: 'SpaceMono',
            ),
          ),
          if (modifier != null) ...[
            const SizedBox(height: 2),
            Text(
              modifier!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: (color ?? AppTheme.limestoneGray).withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

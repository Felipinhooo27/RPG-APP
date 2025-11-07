import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum HexBadgeVariant { primary, secondary, success, warning, danger, neutral }

/// Small badge/chip for displaying tags, classes, levels, etc.
class HexBadge extends StatelessWidget {
  final String label;
  final HexBadgeVariant variant;
  final IconData? icon;
  final bool small;
  final Color? customColor;

  const HexBadge({
    super.key,
    required this.label,
    this.variant = HexBadgeVariant.neutral,
    this.icon,
    this.small = false,
    this.customColor,
  });

  const HexBadge.primary({
    super.key,
    required this.label,
    this.icon,
    this.small = false,
  })  : variant = HexBadgeVariant.primary,
        customColor = null;

  const HexBadge.secondary({
    super.key,
    required this.label,
    this.icon,
    this.small = false,
  })  : variant = HexBadgeVariant.secondary,
        customColor = null;

  const HexBadge.success({
    super.key,
    required this.label,
    this.icon,
    this.small = false,
  })  : variant = HexBadgeVariant.success,
        customColor = null;

  const HexBadge.warning({
    super.key,
    required this.label,
    this.icon,
    this.small = false,
  })  : variant = HexBadgeVariant.warning,
        customColor = null;

  const HexBadge.danger({
    super.key,
    required this.label,
    this.icon,
    this.small = false,
  })  : variant = HexBadgeVariant.danger,
        customColor = null;

  Color get backgroundColor {
    if (customColor != null) return customColor!.withOpacity(0.15);
    switch (variant) {
      case HexBadgeVariant.primary:
        return AppTheme.ritualRed.withOpacity(0.15);
      case HexBadgeVariant.secondary:
        return AppTheme.etherealPurple.withOpacity(0.15);
      case HexBadgeVariant.success:
        return AppTheme.mutagenGreen.withOpacity(0.15);
      case HexBadgeVariant.warning:
        return AppTheme.alertYellow.withOpacity(0.15);
      case HexBadgeVariant.danger:
        return AppTheme.ritualRed.withOpacity(0.2);
      case HexBadgeVariant.neutral:
        return AppTheme.industrialGray;
    }
  }

  Color get borderColor {
    if (customColor != null) return customColor!;
    switch (variant) {
      case HexBadgeVariant.primary:
        return AppTheme.ritualRed;
      case HexBadgeVariant.secondary:
        return AppTheme.etherealPurple;
      case HexBadgeVariant.success:
        return AppTheme.mutagenGreen;
      case HexBadgeVariant.warning:
        return AppTheme.alertYellow;
      case HexBadgeVariant.danger:
        return AppTheme.ritualRed;
      case HexBadgeVariant.neutral:
        return AppTheme.coldGray;
    }
  }

  Color get textColor {
    if (customColor != null) return customColor!;
    switch (variant) {
      case HexBadgeVariant.primary:
        return AppTheme.ritualRed;
      case HexBadgeVariant.secondary:
        return AppTheme.etherealPurple;
      case HexBadgeVariant.success:
        return AppTheme.mutagenGreen;
      case HexBadgeVariant.warning:
        return AppTheme.alertYellow;
      case HexBadgeVariant.danger:
        return AppTheme.ritualRed;
      case HexBadgeVariant.neutral:
        return AppTheme.limestoneGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: small ? 10 : 12,
              color: textColor,
            ),
            SizedBox(width: small ? 3 : 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: small ? 9 : 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Larger badge variant for prominent display (e.g., character class)
class HexBadgeLarge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const HexBadgeLarge({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 6,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

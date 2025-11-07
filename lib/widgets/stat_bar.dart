import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

enum StatType { hp, pe, ps, xp }

/// Animated stat bar for HP, PE (Energy), PS (Sanity), and XP
class StatBar extends StatelessWidget {
  final String label;
  final int current;
  final int maximum;
  final StatType type;
  final bool showNumbers;
  final bool showPercentage;
  final double height;
  final bool animate;

  const StatBar({
    super.key,
    required this.label,
    required this.current,
    required this.maximum,
    required this.type,
    this.showNumbers = true,
    this.showPercentage = false,
    this.height = 24,
    this.animate = true,
  });

  const StatBar.hp({
    super.key,
    required int current,
    required int maximum,
    bool showNumbers = true,
    bool showPercentage = false,
    double height = 24,
    bool animate = true,
  })  : label = 'PV',
        current = current,
        maximum = maximum,
        type = StatType.hp,
        showNumbers = showNumbers,
        showPercentage = showPercentage,
        height = height,
        animate = animate;

  const StatBar.pe({
    super.key,
    required int current,
    required int maximum,
    bool showNumbers = true,
    bool showPercentage = false,
    double height = 24,
    bool animate = true,
  })  : label = 'PE',
        current = current,
        maximum = maximum,
        type = StatType.pe,
        showNumbers = showNumbers,
        showPercentage = showPercentage,
        height = height,
        animate = animate;

  const StatBar.ps({
    super.key,
    required int current,
    required int maximum,
    bool showNumbers = true,
    bool showPercentage = false,
    double height = 24,
    bool animate = true,
  })  : label = 'PS',
        current = current,
        maximum = maximum,
        type = StatType.ps,
        showNumbers = showNumbers,
        showPercentage = showPercentage,
        height = height,
        animate = animate;

  Color get primaryColor {
    switch (type) {
      case StatType.hp:
        return AppTheme.ritualRed;
      case StatType.pe:
        return AppTheme.etherealPurple;
      case StatType.ps:
        return AppTheme.alertYellow;
      case StatType.xp:
        return AppTheme.mutagenGreen;
    }
  }

  Color get secondaryColor {
    switch (type) {
      case StatType.hp:
        return AppTheme.chaoticMagenta;
      case StatType.pe:
        return AppTheme.chaoticMagenta;
      case StatType.ps:
        return const Color(0xFFD18F40);
      case StatType.xp:
        return const Color(0xFF56AB55);
    }
  }

  double get percentage {
    if (maximum == 0) return 0;
    return (current / maximum).clamp(0.0, 1.0);
  }

  bool get isCritical {
    return percentage <= 0.25;
  }

  bool get isWarning {
    return percentage <= 0.5 && percentage > 0.25;
  }

  @override
  Widget build(BuildContext context) {
    final percentText = '${(percentage * 100).toInt()}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label and numbers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: AppTheme.limestoneGray,
              ),
            ),
            if (showNumbers || showPercentage)
              Text(
                showPercentage ? percentText : '$current / $maximum',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SpaceMono',
                  color: isCritical
                      ? AppTheme.alertYellow
                      : isWarning
                          ? AppTheme.limestoneGray
                          : AppTheme.paleWhite,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),

        // Progress bar
        Container(
          height: height,
          decoration: BoxDecoration(
            color: AppTheme.industrialGray,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.coldGray.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: Stack(
              children: [
                // Filled portion with gradient
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: isCritical
                          ? [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .fadeIn(
                      duration: 300.ms,
                    )
                    .shimmer(
                      duration: isCritical ? 1000.ms : 0.ms,
                      color: AppTheme.paleWhite.withOpacity(0.3),
                    ),

                // Center text (optional)
                if (showPercentage && height >= 20)
                  Center(
                    child: Text(
                      percentText,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.paleWhite,
                        shadows: [
                          Shadow(
                            color: AppTheme.abyssalBlack,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact version of StatBar for smaller spaces
class CompactStatBar extends StatelessWidget {
  final String label;
  final int current;
  final int maximum;
  final Color color;

  const CompactStatBar({
    super.key,
    required this.label,
    required this.current,
    required this.maximum,
    required this.color,
  });

  double get percentage {
    if (maximum == 0) return 0;
    return (current / maximum).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 32,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.coldGray,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.industrialGray,
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: FractionallySizedBox(
                widthFactor: percentage,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 48,
          child: Text(
            '$current/$maximum',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'SpaceMono',
              color: AppTheme.paleWhite,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

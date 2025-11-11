import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';

/// Hexatombe-themed loading spinner with ritual circle animation
class HexLoading extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;

  const HexLoading({
    super.key,
    this.size = 48,
    this.color,
    this.message,
  });

  const HexLoading.small({
    super.key,
    this.color,
  })  : size = 24,
        message = null;

  const HexLoading.large({
    super.key,
    this.color,
    this.message,
  }) : size = 64;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.neonRed;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating ring
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: effectiveColor.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),

              // Inner pulsing circle
              Container(
                width: size * 0.6,
                height: size * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: effectiveColor.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: effectiveColor.withOpacity(0.5),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 1000.ms,
                    curve: Curves.easeInOut,
                  )
                  .fadeIn(duration: 500.ms)
                  .then()
                  .fadeOut(duration: 500.ms),

              // Spinning indicator
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(effectiveColor),
                ),
              ),
            ],
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.silver,
            ),
          ),
        ],
      ],
    );
  }
}

/// Full-screen loading overlay
class HexLoadingOverlay extends StatelessWidget {
  final String? message;

  const HexLoadingOverlay({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.deepBlack.withOpacity(0.8),
      child: Center(
        child: HexLoading.large(
          message: message,
        ),
      ),
    );
  }
}

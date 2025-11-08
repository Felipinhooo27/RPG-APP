import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget de loading moderno e compacto
class Loading extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const Loading({
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppTheme.mutagenGreen,
        ),
      ),
    );
  }
}

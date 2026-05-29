import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class SkBigNumber extends StatelessWidget {
  const SkBigNumber(
    this.value, {
    super.key,
    this.size = 64,
    this.color = AppColors.text,
    this.weight = FontWeight.w600,
    this.shadows,
  });

  final String value;
  final double size;
  final Color color;
  final FontWeight weight;
  final List<Shadow>? shadows;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: AppTypography.bigNumber(
        size: size,
        color: color,
        weight: weight,
      ).copyWith(shadows: shadows),
    );
  }
}

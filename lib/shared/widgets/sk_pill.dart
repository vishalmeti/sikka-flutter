import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class SkPill extends StatelessWidget {
  const SkPill({
    super.key,
    required this.label,
    this.color = AppColors.muted,
    this.bgColor,
    this.borderColor,
    this.icon,
    this.fontSize = 11,
    this.padding,
  });

  final String label;
  final Color color;
  final Color? bgColor;
  final Color? borderColor;
  final Widget? icon;
  final double fontSize;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.transparent,
        border: Border.all(color: borderColor ?? AppColors.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 6)],
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontSans,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

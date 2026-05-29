import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum SkButtonMode { gold, teal, ghost }

class SkButton extends StatelessWidget {
  const SkButton({
    super.key,
    required this.label,
    this.onTap,
    this.mode = SkButtonMode.gold,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final SkButtonMode mode;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, borderColor) = switch (mode) {
      SkButtonMode.gold => (AppColors.gold, AppColors.bg, Colors.transparent),
      SkButtonMode.teal => (AppColors.teal, AppColors.bg, Colors.transparent),
      SkButtonMode.ghost => (AppColors.surface, AppColors.text, AppColors.border),
    };

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTypography.fontSans,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

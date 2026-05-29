import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'sk_icons.dart';

class SkCircleButton extends StatelessWidget {
  const SkCircleButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color,
    this.bgColor,
    this.size = 36,
    this.badge = false,
  });

  final SkIconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final Color? bgColor;
  final double size;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bgColor ?? AppColors.surface,
              border: Border.all(color: AppColors.border),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SkIcon(icon, size: 16, color: color ?? AppColors.textDim),
          ),
          if (badge)
            Positioned(
              top: 6,
              right: 8,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.coral,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

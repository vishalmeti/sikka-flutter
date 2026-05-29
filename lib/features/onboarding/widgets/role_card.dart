import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class RoleCard extends StatelessWidget {
  const RoleCard({
    super.key,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final SkIconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: selected ? AppColors.surfaceHi : AppColors.surface,
            border: Border.all(
              color: selected ? AppColors.gold : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.goldDim : AppColors.surface,
                      border: Border.all(
                        color: selected ? Colors.transparent : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: SkIcon(
                      icon,
                      size: 18,
                      color: selected ? AppColors.gold : AppColors.textDim,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppTypography.fontSans,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppTypography.fontSans,
                      fontSize: 11.5,
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              if (selected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const SkIcon(
                      SkIconData.check,
                      size: 11,
                      color: AppColors.bg,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

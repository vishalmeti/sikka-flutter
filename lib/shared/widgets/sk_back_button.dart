import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'sk_icons.dart';

class SkBackButton extends StatelessWidget {
  const SkBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: const SkIcon(SkIconData.back, size: 16, color: AppColors.textDim),
      ),
    );
  }
}

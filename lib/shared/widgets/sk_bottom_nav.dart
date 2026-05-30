import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'sk_icons.dart';

class SkBottomNav extends StatelessWidget {
  const SkBottomNav({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  final int activeIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    ('Home', SkIconData.home),
    ('Scan', SkIconData.scan),
    ('Stores', SkIconData.store),
    ('You', SkIconData.user),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bg.withValues(alpha: 0.85),
            border: const Border(
              top: BorderSide(color: AppColors.border),
            ),
          ),
          padding: EdgeInsets.only(
            top: 10,
            bottom: bottomPad + 6,
            left: 8,
            right: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final isActive = i == activeIndex;
              final (label, iconData) = _items[i];
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SkIcon(
                        iconData,
                        size: 22,
                        color: isActive ? AppColors.text : AppColors.muted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label.toUpperCase(),
                        style: TextStyle(
                          fontFamily: AppTypography.fontSans,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: isActive ? AppColors.text : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

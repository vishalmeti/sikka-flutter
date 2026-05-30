import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

enum StoresView { list, map }

/// Segmented "List / Map" pill used on the Stores tab.
class StoresViewToggle extends StatelessWidget {
  const StoresViewToggle({
    super.key,
    required this.view,
    required this.onChanged,
  });

  final StoresView view;
  final ValueChanged<StoresView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0x0FF0EFE9),
        border: Border.all(color: AppColors.borderHi),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SegButton(
            label: 'List',
            icon: SkIconData.list,
            active: view == StoresView.list,
            onTap: () => onChanged(StoresView.list),
          ),
          _SegButton(
            label: 'Map',
            icon: SkIconData.pin,
            active: view == StoresView.map,
            onTap: () => onChanged(StoresView.map),
          ),
        ],
      ),
    );
  }
}

class _SegButton extends StatelessWidget {
  const _SegButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final SkIconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColors.bg : AppColors.textDim;
    return Material(
      color: active ? AppColors.gold : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SkIcon(icon, size: 14, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.fontSans,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

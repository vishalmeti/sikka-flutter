import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';

class ActivityData {
  const ActivityData({
    required this.kind,
    required this.store,
    required this.amount,
    required this.when,
    required this.sub,
  });

  final String kind; // 'earn' | 'redeem' | 'bonus'
  final String store;
  final int amount;
  final String when;
  final String sub;
}

/// A single recent-activity row, designed to sit inside a wrapping card.
/// The caller is responsible for the card surface and horizontal padding;
/// the row only draws the inter-row divider when [showDivider] is true
/// (i.e. for every row except the first).
class ActivityRow extends StatelessWidget {
  const ActivityRow({
    super.key,
    required this.activity,
    this.showDivider = true,
  });

  final ActivityData activity;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final isEarn = activity.kind == 'earn' || activity.kind == 'bonus';
    final color = isEarn ? AppColors.gold : AppColors.teal;
    final sign = isEarn ? '+' : '−';
    final tag = activity.kind == 'bonus'
        ? 'Bonus'
        : isEarn
            ? 'Earned'
            : 'Redeemed';

    final iconData = activity.kind == 'bonus'
        ? SkIconData.zap
        : isEarn
            ? SkIconData.arrowUp
            : SkIconData.arrowDown;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(top: BorderSide(color: AppColors.border))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.bg,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: SkIcon(iconData, size: 15, color: color),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.store,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$tag • ${activity.when}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${fmtNumber(activity.amount)}',
                style: TextStyle(
                  fontFamily: AppTypography.fontMono,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                activity.sub,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

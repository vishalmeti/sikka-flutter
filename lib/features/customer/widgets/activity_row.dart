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

  final String kind; // 'earn', 'redeem', 'bonus'
  final String store;
  final int amount;
  final String when;
  final String sub;
}

class ActivityRow extends StatelessWidget {
  const ActivityRow({super.key, required this.activity});

  final ActivityData activity;

  @override
  Widget build(BuildContext context) {
    final isEarn = activity.kind == 'earn' || activity.kind == 'bonus';
    final color = isEarn ? AppColors.gold : AppColors.teal;
    final sign = isEarn ? '+' : '−';
    final tag = activity.kind == 'bonus'
        ? 'Bonus'
        : activity.kind == 'redeem'
            ? 'Redeem'
            : 'Earn';

    final iconData = activity.kind == 'bonus'
        ? SkIconData.zap
        : isEarn
            ? SkIconData.arrowUp
            : SkIconData.arrowDown;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: SkIcon(iconData, size: 14, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.store,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      tag,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
                    ),
                    Container(
                      width: 2,
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: const BoxDecoration(
                        color: AppColors.muted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        activity.when,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
                      ),
                    ),
                  ],
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
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                activity.sub.toUpperCase(),
                style: AppTypography.label.copyWith(fontSize: 10.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

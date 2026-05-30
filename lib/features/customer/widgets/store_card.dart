import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';

class StoreCardData {
  const StoreCardData({
    required this.name,
    required this.tier,
    required this.coins,
    required this.progress,
    required this.visits,
  });

  final String name;
  final String tier;
  final int coins;
  final double progress;
  final int visits;
}

/// Horizontal store card used in the home "Your Stores" rail.
/// Sized for the centered-hero (01b) layout — 156px wide, 26px balance.
/// Tap opens the store detail screen via [onTap].
class StoreCard extends StatelessWidget {
  const StoreCard({super.key, required this.store, this.onTap});

  final StoreCardData store;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: 156,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHi,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const SkIcon(
                  SkIconData.store,
                  size: 16,
                  color: AppColors.textDim,
                ),
              ),
              SkTierRing(
                tier: store.tier,
                size: 36,
                progress: store.progress,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            store.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 7),
          SkBigNumber(fmtNumber(store.coins), size: 26, color: AppColors.gold),
          const SizedBox(height: 6),
          Text(
            'SIKKA • ${store.visits} VISITS',
            style: AppTypography.label.copyWith(fontSize: 10.5),
          ),
        ],
      ),
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';

/// Compact wallet pill placed in the top-right of Home & Stores.
/// Shows the user's total Sikka balance and opens the wallet sheet on tap.
class WalletButton extends StatelessWidget {
  const WalletButton({
    super.key,
    required this.total,
    required this.onTap,
  });

  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.goldFaint,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 40,
          padding: const EdgeInsets.fromLTRB(13, 0, 7, 0),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.goldDim),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fmtNumber(total),
                style: TextStyle(
                  fontFamily: AppTypography.fontMono,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const SkIcon(
                  SkIconData.wallet,
                  size: 15,
                  color: AppColors.bg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

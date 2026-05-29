import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../widgets/hero_balance_card.dart';
import '../widgets/store_card.dart';
import '../widgets/activity_row.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _stores = [
    StoreCardData(name: 'Ramesh Stores', tier: 'gold', coins: 847, progress: 0.85, visits: 12),
    StoreCardData(name: 'Sharma Kirana', tier: 'silver', coins: 312, progress: 0.62, visits: 7),
    StoreCardData(name: 'Patel General', tier: 'silver', coins: 188, progress: 0.38, visits: 4),
    StoreCardData(name: 'Anand Provisions', tier: 'bronze', coins: 64, progress: 0.32, visits: 2),
  ];

  static const _activity = [
    ActivityData(kind: 'earn', store: 'Ramesh Stores', amount: 47, when: 'Today, 6:42 PM', sub: '₹235 spent'),
    ActivityData(kind: 'earn', store: 'Sharma Kirana', amount: 22, when: 'Yesterday, 8:11 PM', sub: '₹110 spent'),
    ActivityData(kind: 'redeem', store: 'Ramesh Stores', amount: 200, when: 'Yesterday, 12:30 PM', sub: '₹40 discount'),
    ActivityData(kind: 'earn', store: 'Patel General', amount: 35, when: 'Mon, 7:24 PM', sub: '₹175 spent'),
    ActivityData(kind: 'bonus', store: 'Ramesh Stores', amount: 100, when: 'Sun, 5:18 PM', sub: '5-visit milestone'),
  ];

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          // Top bar
          Padding(
            padding: EdgeInsets.only(
              top: topPad + 6,
              left: 24,
              right: 24,
              bottom: 8,
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GOOD EVENING',
                      style: AppTypography.label,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Aarav',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Streak
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.coralDim,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SkIcon(SkIconData.flame, size: 12, color: AppColors.coral),
                      const SizedBox(width: 5),
                      Text(
                        '14',
                        style: TextStyle(
                          fontFamily: AppTypography.fontMono,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.coral,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const SkCircleButton(icon: SkIconData.bell),
              ],
            ),
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const HeroBalanceCard(),
                  const SizedBox(height: 32),
                  // Your Stores
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SkLabel('Your Stores'),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'All 4',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textDim,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const SkIcon(SkIconData.chevronRight, size: 11, color: AppColors.textDim),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 174,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _stores.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => StoreCard(store: _stores[i]),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Activity
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SkLabel('Activity'),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'This week',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textDim,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const SkIcon(SkIconData.chevronDown, size: 11, color: AppColors.textDim),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  ..._activity.map((a) => ActivityRow(activity: a)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

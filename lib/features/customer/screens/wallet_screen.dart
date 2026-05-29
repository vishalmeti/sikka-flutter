import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';

class _TxData {
  const _TxData(this.date, this.label, this.amount, this.kind);
  final String date, label, kind;
  final int amount;
}

class _Milestone {
  const _Milestone(this.label, this.unlocked);
  final String label;
  final bool unlocked;
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const _transactions = [
    _TxData('27 May', 'Spent ₹235', 47, 'earn'),
    _TxData('24 May', 'Redeemed', 200, 'redeem'),
    _TxData('22 May', '5-visit bonus', 100, 'bonus'),
    _TxData('21 May', 'Spent ₹140', 28, 'earn'),
    _TxData('18 May', 'Spent ₹385', 77, 'earn'),
    _TxData('14 May', 'Spent ₹95', 19, 'earn'),
    _TxData('11 May', 'Welcome bonus', 50, 'bonus'),
  ];

  static const _milestones = [
    _Milestone('First visit', true),
    _Milestone('5 visits', true),
    _Milestone('₹1k spent', true),
    _Milestone('10 visits', false),
    _Milestone('Gold tier', false),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Column(
            children: [
              SkTopBar(
                leading: const SkBackButton(),
                title: 'Store wallet',
                trailing: SkCircleButton(
                  icon: SkIconData.more,
                  onTap: () {},
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      _buildHero(),
                      const SizedBox(height: 28),
                      _buildTierBar(),
                      const SizedBox(height: 28),
                      _buildMilestones(),
                      const SizedBox(height: 32),
                      _buildTransactions(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Fixed redeem button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: bottomPad + 6,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.bg.withValues(alpha: 0.92),
                  ],
                  stops: const [0, 0.3],
                ),
              ),
              child: SkButton(
                label: 'Redeem 847 Sikka = ₹170',
                icon: const SkIcon(SkIconData.coin, size: 14, color: AppColors.bg),
                onTap: () {
                  Navigator.of(context).pushNamed('/redeem');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 0.7,
                  colors: [AppColors.goldDim, Colors.transparent],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.goldFaint,
                  border: Border.all(color: AppColors.goldDim),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SkIcon(SkIconData.trophy, size: 12, color: AppColors.gold),
                    const SizedBox(width: 6),
                    Text(
                      'GOLD TIER · 12 VISITS',
                      style: AppTypography.label.copyWith(color: AppColors.gold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ramesh Stores',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Connaught Place · since Jan 2025',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 32),
              SkBigNumber(
                '847',
                size: 72,
                color: AppColors.gold,
                shadows: [Shadow(color: AppColors.goldDim, blurRadius: 24)],
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: AppTypography.mono,
                  children: [
                    const TextSpan(text: 'Sikka · '),
                    TextSpan(
                      text: '≈ ₹170',
                      style: AppTypography.mono.copyWith(color: AppColors.teal),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTierBar() {
    const current = 847;
    const silver = 500;
    const gold = 1000;
    const pct = current / gold;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SkLabel('Tier Progress'),
              RichText(
                text: TextSpan(
                  style: AppTypography.mono.copyWith(fontSize: 11.5),
                  children: [
                    TextSpan(
                      text: fmtNumber(gold - current),
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' to Gold'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 14,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final trackWidth = constraints.maxWidth;
                final fillWidth =
                    (pct * trackWidth).clamp(0.0, trackWidth).toDouble();
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Background track
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 4,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHi,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    // Fill
                    Positioned(
                      left: 0,
                      top: 4,
                      child: Container(
                        height: 6,
                        width: fillWidth,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.bronze, AppColors.silver, AppColors.gold],
                            stops: [0, 0.6, 1],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    // Current marker
                    Positioned(
                      left: (fillWidth - 7).clamp(0.0, trackWidth - 14).toDouble(),
                      top: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 2),
                          boxShadow: [
                            BoxShadow(color: AppColors.goldDim, blurRadius: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('BRONZE · 0', style: AppTypography.label.copyWith(color: AppColors.bronze)),
              Text('SILVER · ${fmtNumber(silver)}', style: AppTypography.label.copyWith(color: AppColors.silver)),
              Text('GOLD · ${fmtNumber(gold)}', style: AppTypography.label.copyWith(color: AppColors.gold.withValues(alpha: 0.6))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestones() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkLabel('Milestones'),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _milestones.map((m) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: m.unlocked ? AppColors.goldFaint : AppColors.surface,
                      border: Border.all(
                        color: m.unlocked ? AppColors.goldDim : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SkIcon(
                          m.unlocked ? SkIconData.check : SkIconData.lock,
                          size: 12,
                          color: m.unlocked ? AppColors.gold : AppColors.muted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          m.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: m.unlocked ? AppColors.gold : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactions() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SkLabel('Transactions'),
              Text(
                '${_transactions.length} events',
                style: AppTypography.mono.copyWith(fontSize: 11.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ..._transactions.asMap().entries.map((entry) {
          final i = entry.key;
          final tx = entry.value;
          final isEarn = tx.kind != 'redeem';
          final color = isEarn ? AppColors.gold : AppColors.teal;
          final sign = isEarn ? '+' : '−';

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
            decoration: BoxDecoration(
              border: i < _transactions.length - 1
                  ? const Border(bottom: BorderSide(color: AppColors.border))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.date,
                      style: TextStyle(
                        fontFamily: AppTypography.fontMono,
                        fontSize: 12,
                        color: AppColors.muted,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tx.label,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$sign${fmtNumber(tx.amount)}',
                  style: TextStyle(
                    fontFamily: AppTypography.fontMono,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

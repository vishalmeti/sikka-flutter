import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';

class _VisitDay {
  const _VisitDay(this.day, this.count, {this.today = false});
  final String day;
  final int count;
  final bool today;
}

class _Customer {
  const _Customer(this.rank, this.name, this.coins, this.visits, this.last);
  final int rank, coins, visits;
  final String name, last;
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _remaining = 2 * 3600 + 14 * 60 + 28; // seconds
  Timer? _timer;

  static const _visits = [
    _VisitDay('Mon', 18),
    _VisitDay('Tue', 24),
    _VisitDay('Wed', 31),
    _VisitDay('Thu', 22),
    _VisitDay('Fri', 38),
    _VisitDay('Sat', 47),
    _VisitDay('Sun', 29, today: true),
  ];

  static const _loyalty = [
    _Customer(1, 'Aarav Mehta', 847, 12, '2h ago'),
    _Customer(2, 'Priya Sharma', 612, 9, 'Today'),
    _Customer(3, 'Rohan Singh', 488, 8, '1d ago'),
    _Customer(4, 'Diya Kapoor', 312, 6, '1d ago'),
    _Customer(5, 'Vikram Iyer', 244, 5, '3d ago'),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining > 0) {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _countdown {
    final h = (_remaining ~/ 3600).toString().padLeft(2, '0');
    final m = ((_remaining % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Column(
            children: [
              // Top bar
              Padding(
                padding: EdgeInsets.only(top: topPad + 6, left: 24, right: 24, bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: const SkIcon(SkIconData.store, size: 16, color: AppColors.gold),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('OWNER', style: AppTypography.label),
                        const SizedBox(height: 1),
                        const Text(
                          'Ramesh Stores',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const SkCircleButton(icon: SkIconData.bell, badge: true),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // GMV hero
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SkLabel("Today's GMV"),
                            const SizedBox(height: 14),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '₹',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontMono,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.muted,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const SkBigNumber('18,420', size: 56),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SkIcon(SkIconData.arrowUp, size: 11, color: AppColors.success),
                                      const SizedBox(width: 4),
                                      Text(
                                        '+12.4%',
                                        style: TextStyle(
                                          fontFamily: AppTypography.fontMono,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.success,
                                          fontFeatures: const [FontFeature.tabularFigures()],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'vs. last Sunday',
                                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Approve redemption CTA
                      _buildApproveCta(),
                      const SizedBox(height: 20),
                      // Bar chart
                      _buildBarChart(),
                      const SizedBox(height: 24),
                      // Active offer
                      _buildActiveOffer(),
                      const SizedBox(height: 28),
                      // Loyalty leaderboard
                      _buildLoyalty(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Create offer FAB
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: bottomPad + 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.bg.withValues(alpha: 0.92)],
                  stops: const [0, 0.3],
                ),
              ),
              child: SkButton(
                label: 'Create new offer',
                icon: const SkIcon(SkIconData.plus, size: 16, color: AppColors.bg),
                onTap: () {
                  Navigator.of(context).pushNamed('/create-offer');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApproveCta() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.tealDim,
          border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const SkAvatar(name: 'Priya Sharma', size: 32, bgColor: AppColors.tealDim),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Priya wants to redeem 250 Sikka',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '= ₹50 off · waiting at counter',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textDim),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Approve',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final maxCount = _visits.map((v) => v.count).reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SkLabel('Visits this week'),
              RichText(
                text: TextSpan(
                  style: AppTypography.mono.copyWith(fontSize: 12),
                  children: [
                    const TextSpan(
                      text: '209',
                      style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(text: ' total '),
                    const TextSpan(text: '· ', style: TextStyle(color: AppColors.muted)),
                    const TextSpan(
                      text: '+18%',
                      style: TextStyle(color: AppColors.success),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 116,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _visits.map((v) {
                final h = (v.count / maxCount) * 100;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${v.count}',
                          style: TextStyle(
                            fontFamily: AppTypography.fontMono,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: v.today ? AppColors.gold : AppColors.muted,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: h,
                          decoration: BoxDecoration(
                            color: v.today ? AppColors.gold : AppColors.surfaceHi,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: v.today
                                ? [BoxShadow(color: AppColors.goldDim, blurRadius: 14)]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          v.day.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: v.today ? AppColors.gold : AppColors.muted,
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

  Widget _buildActiveOffer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 0.6,
                    colors: [AppColors.coralDim, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.coral,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: AppColors.coral, blurRadius: 8)],
                              ),
                            ),
                            const SizedBox(width: 8),
                            SkLabel('Live offer', color: AppColors.coral),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '2× Sikka on weekend',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sat–Sun · all customers',
                          style: TextStyle(fontSize: 12.5, color: AppColors.textDim),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SkLabel('Ends in'),
                        const SizedBox(height: 6),
                        Text(
                          _countdown,
                          style: TextStyle(
                            fontFamily: AppTypography.fontMono,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.coral,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      _offerStat('Triggered', '34', AppColors.text),
                      const SizedBox(width: 24),
                      _offerStat('Extra spend', '₹2,840', AppColors.teal),
                      const SizedBox(width: 24),
                      _offerStat('Cost', '+568 sk', AppColors.gold),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _offerStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkLabel(label),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTypography.fontMono,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildLoyalty() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SkLabel('Loyalty leaderboard'),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('All 47', style: TextStyle(fontSize: 11.5, color: AppColors.textDim)),
                  const SizedBox(width: 4),
                  const SkIcon(SkIconData.chevronRight, size: 11, color: AppColors.textDim),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ..._loyalty.map((c) => _loyaltyRow(c)),
      ],
    );
  }

  Widget _loyaltyRow(_Customer c) {
    final tier = c.coins >= 500 ? 'gold' : c.coins >= 200 ? 'silver' : 'bronze';
    final tierColor = AppColors.tierColor(tier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '${c.rank}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontMono,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: c.rank <= 3 ? AppColors.gold : AppColors.muted,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 12),
          SkAvatar(name: c.name, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
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
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: tierColor,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(tier, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                    const Text(' · ', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                    Text('${c.visits} visits', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                    const Text(' · ', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                    Text(c.last, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                  ],
                ),
              ],
            ),
          ),
          Text(
            fmtNumber(c.coins),
            style: TextStyle(
              fontFamily: AppTypography.fontMono,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';

/// One swipeable view inside the home hero (e.g. "All stores",
/// "This month", "Ramesh Stores"). Each page renders its own
/// scope label, big balance number, and rupee-value pill.
class HeroBalancePage {
  const HeroBalancePage({required this.scope, required this.coins});

  /// Caption shown above the big number, e.g. "Aarav • All stores".
  final String scope;

  /// Coin balance shown as the big gold number.
  final int coins;
}

/// Centered balance hero with a horizontally-swipeable [PageView] and
/// page dots below.
///
/// The warm gradient + radial glow that sit behind this hero are owned by
/// [HomeScreen] so they can extend up behind the top bar; this widget
/// paints only the foreground content.
class HeroBalanceCard extends StatefulWidget {
  const HeroBalanceCard({
    super.key,
    required this.pages,
    this.redeemRate = 2,
  });

  final List<HeroBalancePage> pages;

  /// Coins per ₹1 (backend REDEEM_RATE). Rupee value = coins / redeemRate.
  final double redeemRate;

  @override
  State<HeroBalanceCard> createState() => _HeroBalanceCardState();
}

class _HeroBalanceCardState extends State<HeroBalanceCard> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _rupees(int coins) =>
      widget.redeemRate > 0 ? (coins / widget.redeemRate).floor() : 0;

  void _jumpTo(int i) {
    _controller.animateToPage(
      i,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.pages.isEmpty
        ? const [HeroBalancePage(scope: 'All stores', coins: 0)]
        : widget.pages;
    final activeIndex = _index.clamp(0, pages.length - 1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 46, 24, 0),
      child: Column(
        children: [
          SizedBox(
            height: 178,
            child: PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (i) => setState(() => _index = i),
              physics: pages.length > 1
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              itemBuilder: (_, i) => _HeroPage(
                page: pages[i],
                rupees: _rupees(pages[i].coins),
              ),
            ),
          ),
          const SizedBox(height: 22),
          if (pages.length > 1)
            _PageDots(
              count: pages.length,
              active: activeIndex,
              onTap: _jumpTo,
            ),
        ],
      ),
    );
  }
}

class _HeroPage extends StatelessWidget {
  const _HeroPage({required this.page, required this.rupees});

  final HeroBalancePage page;
  final int rupees;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          page.scope,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDim,
          ),
        ),
        const SizedBox(height: 14),
        SkBigNumber(
          fmtNumber(page.coins),
          size: 72,
          color: AppColors.gold,
          shadows: const [
            Shadow(color: AppColors.goldDim, blurRadius: 28),
          ],
        ),
        const SizedBox(height: 18),
        _ValuePill(rupees: rupees),
      ],
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.rupees});

  final int rupees;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0x1AF0EFE9),
        border: Border.all(color: AppColors.borderHi),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '≈ ${fmtRupee(rupees)} value',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.text,
            ),
          ),
          const SizedBox(width: 7),
          const SkIcon(
            SkIconData.chevronDown,
            size: 13,
            color: AppColors.text,
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.count,
    required this.active,
    this.onTap,
  });

  final int count;
  final int active;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap == null ? null : () => onTap!(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: i == active ? 7 : 6,
                height: i == active ? 7 : 6,
                decoration: BoxDecoration(
                  color: i == active
                      ? AppColors.gold
                      : const Color(0x38F0EFE9),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

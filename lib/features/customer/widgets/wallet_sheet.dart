import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/store_model.dart';

/// Modal bottom sheet showing the user's total Sikka balance broken down
/// by store. Opened from the WalletButton in the top-right of Home/Stores.
class WalletSheet extends StatelessWidget {
  const WalletSheet({
    super.key,
    required this.stores,
    required this.redeemRate,
    required this.onOpenStore,
    required this.onRedeem,
  });

  final List<StoreModel> stores;
  final double redeemRate;
  final ValueChanged<StoreModel> onOpenStore;
  final VoidCallback onRedeem;

  static const double _maxHeightFraction = 0.92;

  /// Show the wallet sheet via [showModalBottomSheet]. The sheet sizes
  /// itself to its content up to 92% of the screen.
  static Future<void> show(
    BuildContext context, {
    required List<StoreModel> stores,
    required double redeemRate,
    required ValueChanged<StoreModel> onOpenStore,
    required VoidCallback onRedeem,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      useSafeArea: false,
      builder: (_) => WalletSheet(
        stores: stores,
        redeemRate: redeemRate,
        onOpenStore: onOpenStore,
        onRedeem: onRedeem,
      ),
    );
  }

  int get _total => stores.fold<int>(0, (s, e) => s + e.coins);
  int get _valueRupees => redeemRate > 0 ? (_total / redeemRate).floor() : 0;

  int _storeRupees(int coins) =>
      redeemRate > 0 ? (coins / redeemRate).floor() : 0;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height * _maxHeightFraction;
    final sorted = [...stores]..sort((a, b) => b.coins.compareTo(a.coins));

    return Padding(
      padding: EdgeInsets.only(top: media.padding.top + 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.bg,
            border: Border(
              top: BorderSide(color: AppColors.borderHi),
              left: BorderSide(color: AppColors.borderHi),
              right: BorderSide(color: AppColors.borderHi),
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Hero(
                total: _total,
                valueRupees: _valueRupees,
                storeCount: stores.length,
                onClose: () => Navigator.of(context).maybePop(),
              ),
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  shrinkWrap: true,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 2, bottom: 10),
                      child: SkLabel('Balance by store'),
                    ),
                    for (final s in sorted) ...[
                      _BalanceRow(
                        store: s,
                        rupees: _storeRupees(s.coins),
                        onTap: () {
                          Navigator.of(context).maybePop();
                          onOpenStore(s);
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
              _RedeemBar(
                onTap: () {
                  Navigator.of(context).maybePop();
                  onRedeem();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.total,
    required this.valueRupees,
    required this.storeCount,
    required this.onClose,
  });

  final int total;
  final int valueRupees;
  final int storeCount;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -1.1),
                  radius: 0.7,
                  colors: [AppColors.goldDim, Colors.transparent],
                  stops: const [0, 0.6],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderHi,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SkLabel('Sikka Wallet'),
                  GestureDetector(
                    onTap: onClose,
                    behavior: HitTestBehavior.opaque,
                    child: const SkIcon(
                      SkIconData.close,
                      size: 20,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkBigNumber(
                    fmtNumber(total),
                    size: 56,
                    color: AppColors.gold,
                    shadows: const [
                      Shadow(color: AppColors.goldDim, blurRadius: 26),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'sikka',
                      style: TextStyle(
                        fontFamily: AppTypography.fontMono,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '≈ ${fmtRupee(valueRupees)} to spend across $storeCount stores',
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textDim,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({
    required this.store,
    required this.rupees,
    required this.onTap,
  });

  final StoreModel store;
  final int rupees;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              _StoreInitialsTile(store: store, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_capitalize(store.tier)} · ${store.area}',
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
                    fmtNumber(store.coins),
                    style: TextStyle(
                      fontFamily: AppTypography.fontMono,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '≈ ${fmtRupee(rupees)}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// Square tile showing a store's initials, with a subtle accent-tinted
/// gradient background. Used in the wallet sheet and rich store cards.
class _StoreInitialsTile extends StatelessWidget {
  const _StoreInitialsTile({required this.store, this.size = 40});

  final StoreModel store;
  final double size;

  @override
  Widget build(BuildContext context) {
    return StoreInitialsTile(
      initials: store.initials,
      accent: store.accent,
      size: size,
    );
  }
}

/// Public initials tile — kept here so the wallet sheet and the rich store
/// card can share the exact same accent treatment without each rolling its
/// own version.
class StoreInitialsTile extends StatelessWidget {
  const StoreInitialsTile({
    super.key,
    required this.initials,
    required this.accent,
    this.size = 40,
    this.radius,
    this.fontSize,
  });

  final String initials;
  final Color accent;
  final double size;
  final double? radius;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.16),
            accent.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.27)),
        borderRadius: BorderRadius.circular(radius ?? size * 0.275),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: AppTypography.fontMono,
          fontSize: fontSize ?? size * 0.35,
          fontWeight: FontWeight.w600,
          color: accent,
        ),
      ),
    );
  }
}

class _RedeemBar extends StatelessWidget {
  const _RedeemBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SkButton(
        label: 'Redeem Sikka',
        icon: const SkIcon(SkIconData.coin, size: 16, color: AppColors.bg),
        onTap: onTap,
      ),
    );
  }
}

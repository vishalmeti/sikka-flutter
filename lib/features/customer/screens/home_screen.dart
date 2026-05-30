import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/dashboard_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/navigation/customer_shell.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../core/utils/formatters.dart';
import '../models/store_catalog.dart';
import '../models/store_model.dart';
import '../state/customer_home_store.dart';
import '../widgets/activity_row.dart';
import '../widgets/hero_balance_card.dart';
import '../widgets/store_card.dart';
import '../widgets/wallet_button.dart';
import '../widgets/wallet_sheet.dart';
import 'store_detail_screen.dart';

/// Customer home — centered-hero (01b · Home + Stores) layout.
///
/// Structure (top → bottom):
///   • Warm gold radial gradient backdrop (fades into the app bg)
///   • Top bar: avatar · "Search stores" pill · WalletButton
///   • Centered balance hero with rupee-value pill + page dots
///   • Your Stores horizontal scroll (tap → detail; all → Stores tab)
///   • Recent Activity card with rows + "See all activity"
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerHomeStore>().load();
    });
  }

  Future<void> _onRefresh() async {
    final store = context.read<CustomerHomeStore>();
    await store.refresh();
    if (!mounted || store.error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(store.error!)),
    );
  }

  void _goToStores() => CustomerShell.goToStores(context);

  void _openStore(StoreModel store) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StoreDetailScreen(store: store)),
    );
  }

  void _openWallet(List<StoreModel> enriched, double redeemRate) {
    WalletSheet.show(
      context,
      stores: enriched,
      redeemRate: redeemRate,
      onOpenStore: _openStore,
      onRedeem: () => Navigator.of(context).pushNamed('/redeem'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerHomeStore>();
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _HeroBackdrop(),
          ),
          Column(
            children: [
              _TopBar(
                topPad: topPad,
                userName: store.data?.userName,
                total: store.data?.totalCoins ?? 0,
                onSearch: _goToStores,
                onOpenWallet: () => _openWallet(
                  _enrichedStores(store.data),
                  store.data?.redeemRate ?? 2,
                ),
              ),
              Expanded(child: _buildBody(store)),
            ],
          ),
        ],
      ),
    );
  }

  List<StoreModel> _enrichedStores(CustomerDashboard? data) {
    if (data == null || data.stores.isEmpty) {
      return StoreCatalog.instance.demoStores();
    }
    return StoreCatalog.instance.enrichAll(data.stores);
  }

  Widget _buildBody(CustomerHomeStore store) {
    if (store.isLoading && !store.hasData) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }
    if (store.error != null && !store.hasData) {
      return _ErrorView(store: store);
    }
    final data = store.data;
    if (data == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.gold,
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        child: _buildContent(data),
      ),
    );
  }

  /// Builds the swipeable hero pages from the dashboard payload.
  ///
  /// Page 1 (always): user's grand total across all stores.
  /// Page 2 (if any activity): coins earned in the current calendar month.
  /// Page 3 (if 2+ stores): the store with the highest balance — so users
  /// with a single store don't see a duplicate page.
  List<HeroBalancePage> _buildHeroPages(CustomerDashboard data) {
    final firstName = _firstName(data.userName);
    String scope(String label) =>
        firstName.isEmpty ? label : '$firstName • $label';

    final pages = <HeroBalancePage>[
      HeroBalancePage(
        scope: scope('All stores'),
        coins: data.totalCoins,
      ),
    ];

    if (data.activity.isNotEmpty) {
      pages.add(HeroBalancePage(
        scope: scope('This month'),
        coins: _earnedThisMonth(data.activity),
      ));
    }

    if (data.stores.length >= 2) {
      final top =
          data.stores.reduce((a, b) => a.coins >= b.coins ? a : b);
      pages.add(HeroBalancePage(
        scope: scope(top.name),
        coins: top.coins,
      ));
    }

    return pages;
  }

  String _firstName(String full) {
    final trimmed = full.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  int _earnedThisMonth(List<DashboardActivity> activity) {
    final now = DateTime.now();
    var total = 0;
    for (final a in activity) {
      if (a.coinDelta <= 0) continue;
      if (a.timestamp.year != now.year) continue;
      if (a.timestamp.month != now.month) continue;
      total += a.coinDelta;
    }
    return total;
  }

  Widget _buildContent(CustomerDashboard data) {
    final enriched = StoreCatalog.instance.enrichAll(data.stores);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeSlideIn(
          delay: const Duration(milliseconds: 60),
          child: HeroBalanceCard(
            pages: _buildHeroPages(data),
            redeemRate: data.redeemRate,
          ),
        ),
        const SizedBox(height: 36),
        FadeSlideIn(
          delay: const Duration(milliseconds: 220),
          child: _SectionHeader(
            label: 'Your Stores',
            trailing: 'All ${data.stores.length}',
            showChevron: true,
            onTap: _goToStores,
          ),
        ),
        const SizedBox(height: 13),
        _StoresRail(stores: enriched, onOpen: _openStore),
        const SizedBox(height: 30),
        FadeSlideIn(
          delay: const Duration(milliseconds: 360),
          child: const _SectionHeader(label: 'Recent Activity'),
        ),
        const SizedBox(height: 13),
        _ActivityCard(activity: data.activity),
      ],
    );
  }
}

// ── backdrop ──────────────────────────────────────────────────────────────

/// Warm linear-gradient panel + soft gold radial glow that sits behind the
/// top of the screen, fading into [AppColors.bg].
class _HeroBackdrop extends StatelessWidget {
  const _HeroBackdrop();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 540,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.26, 0.88],
                colors: [
                  Color(0xFF221B0D),
                  Color(0xFF181308),
                  AppColors.bg,
                ],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.18),
            child: Container(
              width: 360,
              height: 360,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  radius: 0.5,
                  colors: [AppColors.goldDim, Colors.transparent],
                  stops: [0.0, 0.68],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── top bar ───────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.topPad,
    required this.userName,
    required this.total,
    required this.onSearch,
    required this.onOpenWallet,
  });

  final double topPad;
  final String? userName;
  final int total;
  final VoidCallback onSearch;
  final VoidCallback onOpenWallet;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, topPad + 6, 18, 8),
      child: Row(
        children: [
          _AvatarWithDot(name: userName),
          const SizedBox(width: 10),
          Expanded(child: _SearchField(onTap: onSearch)),
          const SizedBox(width: 10),
          WalletButton(total: total, onTap: onOpenWallet),
        ],
      ),
    );
  }
}

class _AvatarWithDot extends StatelessWidget {
  const _AvatarWithDot({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SkAvatar(name: name ?? '', size: 38),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: AppColors.coral,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.bg, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x12F0EFE9),
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderHi),
            borderRadius: BorderRadius.circular(19),
          ),
          child: Row(
            children: [
              const SkIcon(SkIconData.search, size: 17, color: AppColors.textDim),
              const SizedBox(width: 9),
              Text(
                'Search stores',
                style: const TextStyle(fontSize: 14, color: AppColors.textDim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── section header ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    this.trailing,
    this.showChevron = false,
    this.onTap,
  });

  final String label;
  final String? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasTrailing = trailing != null;
    final trailingChild = hasTrailing
        ? Row(
            children: [
              Text(
                trailing!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textDim,
                ),
              ),
              if (showChevron) ...[
                const SizedBox(width: 4),
                const SkIcon(
                  SkIconData.chevronRight,
                  size: 12,
                  color: AppColors.textDim,
                ),
              ],
            ],
          )
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SkLabel(label),
          if (trailingChild != null)
            onTap == null
                ? trailingChild
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTap,
                    child: trailingChild,
                  ),
        ],
      ),
    );
  }
}

// ── stores rail ───────────────────────────────────────────────────────────

class _StoresRail extends StatelessWidget {
  const _StoresRail({required this.stores, required this.onOpen});

  final List<StoreModel> stores;
  final ValueChanged<StoreModel> onOpen;

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) {
      return const _EmptyHint(
        message: 'No stores yet. Scan a store QR to start earning.',
      );
    }
    return SizedBox(
      height: 162,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: stores.length,
        separatorBuilder: (_, __) => const SizedBox(width: 11),
        itemBuilder: (_, i) {
          final s = stores[i];
          return FadeSlideIn(
            delay: Duration(milliseconds: 260 + i * 90),
            offset: 24,
            child: StoreCard(
              store: StoreCardData(
                name: s.name,
                tier: s.tier,
                coins: s.coins,
                progress: s.progress,
                visits: s.visits,
              ),
              onTap: () => onOpen(s),
            ),
          );
        },
      ),
    );
  }
}

// ── activity card ─────────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final List<DashboardActivity> activity;

  @override
  Widget build(BuildContext context) {
    if (activity.isEmpty) {
      return const _EmptyHint(message: 'No activity yet.');
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
        child: Column(
          children: [
            for (var i = 0; i < activity.length; i++)
              FadeSlideIn(
                delay: Duration(milliseconds: 420 + i * 70),
                offset: 12,
                child: ActivityRow(
                  activity: ActivityData(
                    kind: activity[i].kind,
                    store: activity[i].storeName ?? 'Sikka',
                    amount: activity[i].coinDelta.abs(),
                    when: fmtRelativeTime(activity[i].timestamp),
                    sub: activity[i].label,
                  ),
                  showDivider: i != 0,
                ),
              ),
            _SeeAllButton(onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _SeeAllButton extends StatelessWidget {
  const _SeeAllButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 11),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              'See all activity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── misc ──────────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        message,
        style: const TextStyle(fontSize: 13, color: AppColors.muted),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.store});

  final CustomerHomeStore store;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              store.error ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textDim),
            ),
            const SizedBox(height: 16),
            SkButton(label: 'Retry', onTap: store.retry),
          ],
        ),
      ),
    );
  }
}

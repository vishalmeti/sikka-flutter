import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/dashboard_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';
import '../state/customer_home_store.dart';
import '../widgets/activity_row.dart';
import '../widgets/hero_balance_card.dart';
import '../widgets/store_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerHomeStore>();
    final data = store.data;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildTopBar(topPad, data),
          Expanded(child: _buildBody(store)),
        ],
      ),
    );
  }

  Widget _buildBody(CustomerHomeStore store) {
    if (store.isLoading && !store.hasData) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }
    if (store.error != null && !store.hasData) {
      return _buildError(store);
    }
    final data = store.data;
    if (data == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.gold,
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildContent(data),
      ),
    );
  }

  Widget _buildContent(CustomerDashboard data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        HeroBalanceCard(
          coins: data.totalCoins,
          progress: data.overallProgress,
          redeemRate: data.redeemRate,
        ),
        const SizedBox(height: 32),
        _sectionHeader('Your Stores', trailing: 'All ${data.stores.length}'),
        const SizedBox(height: 14),
        _buildStores(data.stores),
        const SizedBox(height: 32),
        _sectionHeader('Activity', trailing: 'Recent'),
        const SizedBox(height: 6),
        _buildActivity(data.activity),
      ],
    );
  }

  Widget _buildStores(List<DashboardStore> stores) {
    if (stores.isEmpty) {
      return _emptyHint('No stores yet. Scan a store QR to start earning.');
    }
    return SizedBox(
      height: 174,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: stores.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final s = stores[i];
          return StoreCard(
            store: StoreCardData(
              name: s.name,
              tier: s.tier,
              coins: s.coins,
              progress: s.tierProgress,
              visits: s.visits,
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivity(List<DashboardActivity> activity) {
    if (activity.isEmpty) {
      return _emptyHint('No activity yet.');
    }
    return Column(
      children: activity
          .map((a) => ActivityRow(
                activity: ActivityData(
                  kind: a.kind,
                  store: a.storeName ?? 'Sikka',
                  amount: a.coinDelta.abs(),
                  when: fmtRelativeTime(a.timestamp),
                  sub: a.label,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildTopBar(double topPad, CustomerDashboard? data) {
    return Padding(
      padding: EdgeInsets.only(top: topPad + 6, left: 24, right: 24, bottom: 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting(), style: AppTypography.label),
              const SizedBox(height: 2),
              Text(
                data?.userName ?? '',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (data != null && data.streakDays > 0) ...[
            _streakPill(data.streakDays),
            const SizedBox(width: 8),
          ],
          const SkCircleButton(icon: SkIconData.bell),
        ],
      ),
    );
  }

  Widget _streakPill(int days) {
    return Container(
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
            '$days',
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
    );
  }

  Widget _sectionHeader(String title, {required String trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SkLabel(title),
          Text(
            trailing,
            style: TextStyle(fontSize: 11.5, color: AppColors.textDim),
          ),
        ],
      ),
    );
  }

  Widget _emptyHint(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        message,
        style: TextStyle(fontSize: 13, color: AppColors.muted),
      ),
    );
  }

  Widget _buildError(CustomerHomeStore store) {
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
            SkButton(
              label: 'Retry',
              onTap: () => store.retry(),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'GOOD MORNING';
    if (h < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }
}

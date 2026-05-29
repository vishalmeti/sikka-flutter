import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/api/owner_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';
import '../state/owner_dashboard_store.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _timer;
  DateTime? _offerEndsAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerDashboardStore>().load();
    });
    // Ticks the live-offer countdown once a second (only while one is active).
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _offerEndsAt != null) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final store = context.read<OwnerDashboardStore>();
    await store.refresh();
    if (!mounted || store.error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(store.error!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<OwnerDashboardStore>();
    final data = store.data;
    _offerEndsAt = data?.activeOffer?.endsAt;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopBar(topPad, data?.store?.name),
              Expanded(child: _buildBody(store)),
            ],
          ),
          if (data?.store != null) _buildFab(bottomPad),
        ],
      ),
    );
  }

  Widget _buildBody(OwnerDashboardStore store) {
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
        padding: const EdgeInsets.only(bottom: 100),
        child: _buildContent(data),
      ),
    );
  }

  Widget _buildContent(OwnerDashboard data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGmvHero(data),
        if (data.pendingRedemptions.top != null) ...[
          _buildApproveCta(data.pendingRedemptions),
          const SizedBox(height: 20),
        ] else
          const SizedBox(height: 4),
        _buildBarChart(data.weekVisits, data.weekTotal),
        const SizedBox(height: 24),
        if (data.activeOffer != null) ...[
          _buildActiveOffer(data.activeOffer!),
          const SizedBox(height: 28),
        ],
        _buildLoyalty(data.leaderboard),
      ],
    );
  }

  Widget _buildGmvHero(OwnerDashboard data) {
    return Padding(
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
              SkBigNumber(fmtNumber(data.todayGmv), size: 56),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.todayVisits == 1
                ? '1 visit today'
                : '${data.todayVisits} visits today',
            style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildApproveCta(OwnerPending pending) {
    final top = pending.top!;
    final firstName = top.customerName.split(' ').first;
    final extra = pending.count > 1 ? ' · +${pending.count - 1} more waiting' : '';

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
            SkAvatar(name: top.customerName, size: 32, bgColor: AppColors.tealDim),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$firstName wants to redeem ${fmtNumber(top.coins)} Sikka',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '= ${fmtRupee(top.rupeeValue)} off$extra',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textDim),
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

  Widget _buildBarChart(List<OwnerVisitDay> visits, int weekTotal) {
    final maxCount =
        visits.fold<int>(0, (m, v) => v.count > m ? v.count : m);

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
                    TextSpan(
                      text: '$weekTotal',
                      style: const TextStyle(
                          color: AppColors.text, fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(text: ' total'),
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
              children: visits.map((v) {
                final h = maxCount == 0 ? 0.0 : (v.count / maxCount) * 100;
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

  Widget _buildActiveOffer(OwnerActiveOffer offer) {
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
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
                      Text(
                        offer.title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _offerTypeLabel(offer.offerType),
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textDim),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SkLabel('Ends in'),
                    const SizedBox(height: 6),
                    Text(
                      _countdown(offer.endsAt),
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
          ),
        ],
      ),
    );
  }

  Widget _buildLoyalty(List<OwnerLeader> leaders) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SkLabel('Loyalty leaderboard'),
              if (leaders.isNotEmpty)
                Text('Top ${leaders.length}',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textDim)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (leaders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'No customers yet.',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          )
        else
          ...leaders.map(_loyaltyRow),
      ],
    );
  }

  Widget _loyaltyRow(OwnerLeader c) {
    final tierColor = AppColors.tierColor(c.tier);
    final last =
        c.lastVisitDate != null ? fmtRelativeTime(c.lastVisitDate!) : '—';

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
          SkAvatar(name: c.customerName, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.customerName,
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
                    Text(c.tier, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                    const Text(' · ', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                    Text('${c.visits} visits', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                    const Text(' · ', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                    Flexible(
                      child: Text(
                        last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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

  Widget _buildTopBar(double topPad, String? storeName) {
    return Padding(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OWNER', style: AppTypography.label),
                const SizedBox(height: 1),
                Text(
                  storeName ?? 'My Store',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const SkCircleButton(icon: SkIconData.bell, badge: true),
        ],
      ),
    );
  }

  Widget _buildFab(double bottomPad) {
    return Positioned(
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
          onTap: () => Navigator.of(context).pushNamed('/create-offer'),
        ),
      ),
    );
  }

  Widget _buildError(OwnerDashboardStore store) {
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
            SkButton(label: 'Retry', onTap: () => store.retry()),
          ],
        ),
      ),
    );
  }

  String _offerTypeLabel(String type) {
    switch (type) {
      case 'double_coins':
        return 'Double Sikka';
      case 'bonus_coins':
        return 'Bonus Sikka';
      case 'spend_and_earn':
        return 'Spend & earn';
      default:
        return 'All customers';
    }
  }

  String _countdown(DateTime endsAt) {
    var secs = endsAt.difference(DateTime.now()).inSeconds;
    if (secs < 0) secs = 0;
    final days = secs ~/ 86400;
    if (days >= 1) {
      final hours = (secs % 86400) ~/ 3600;
      return '${days}d ${hours}h';
    }
    final h = (secs ~/ 3600).toString().padLeft(2, '0');
    final m = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

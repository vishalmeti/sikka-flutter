import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/store_catalog.dart';
import '../models/store_model.dart';
import '../state/customer_home_store.dart';
import '../widgets/store_card_rich.dart';
import '../widgets/stores_map_view.dart';
import '../widgets/stores_view_toggle.dart';
import '../widgets/wallet_button.dart';
import '../widgets/wallet_sheet.dart';
import 'store_detail_screen.dart';

/// "Stores" tab — searchable directory of every store the shopper earns at.
///
/// Layout (top → bottom):
///   • Header: title + WalletButton
///   • List/Map view toggle (right aligned)
///   • Search field (list view only)
///   • Filter chips (All / Offers / Open now / Gold)
///   • Body: list of [StoreCardRich] or stylized map
class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  static const _chips = ['All', 'Offers', 'Open now', 'Gold'];

  final _searchController = TextEditingController();
  String _query = '';
  String _filter = 'All';
  StoresView _view = StoresView.list;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Stores to render. Uses the live dashboard data when present, falling
  /// back to the demo catalog so the tab is renderable pre-login or on a
  /// fresh install. Either way, results pass through the same enrichment
  /// pipeline so the UI sees a consistent [StoreModel].
  List<StoreModel> _stores(CustomerHomeStore store) {
    final live = store.data?.stores;
    if (live == null || live.isEmpty) return StoreCatalog.instance.demoStores();
    return StoreCatalog.instance.enrichAll(live);
  }

  Iterable<StoreModel> _applyFilters(List<StoreModel> stores) {
    final q = _query.trim().toLowerCase();
    return stores.where((s) {
      final matchesQ = q.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          s.category.toLowerCase().contains(q) ||
          s.area.toLowerCase().contains(q);
      final matchesF = switch (_filter) {
        'Offers' => s.offers.isNotEmpty,
        'Open now' => s.isOpen,
        'Gold' => s.tier == 'gold',
        _ => true,
      };
      return matchesQ && matchesF;
    });
  }

  void _openStore(StoreModel store) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StoreDetailScreen(store: store)),
    );
  }

  void _openWallet(List<StoreModel> stores, double redeemRate) {
    WalletSheet.show(
      context,
      stores: stores,
      redeemRate: redeemRate,
      onOpenStore: _openStore,
      onRedeem: () => Navigator.of(context).pushNamed('/redeem'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeStore = context.watch<CustomerHomeStore>();
    final stores = _stores(homeStore);
    final filtered = _applyFilters(stores).toList(growable: false);
    final total = stores.fold<int>(0, (s, e) => s + e.coins);
    final redeemRate = homeStore.data?.redeemRate ?? 2;
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
                placesCount: filtered.length,
                total: total,
                onOpenWallet: () => _openWallet(stores, redeemRate),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: StoresViewToggle(
                    view: _view,
                    onChanged: (v) => setState(() => _view = v),
                  ),
                ),
              ),
              if (_view == StoresView.list) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: _SearchField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ],
              _FilterChips(
                chips: _chips,
                active: _filter,
                onTap: (c) => setState(() => _filter = c),
              ),
              Expanded(
                child: _view == StoresView.list
                    ? _ListBody(
                        stores: filtered,
                        query: _query,
                        onOpen: _openStore,
                      )
                    : StoresMapView(
                        stores: filtered,
                        onOpenStore: _openStore,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.topPad,
    required this.placesCount,
    required this.total,
    required this.onOpenWallet,
  });

  final double topPad;
  final int placesCount;
  final int total;
  final VoidCallback onOpenWallet;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, topPad + 6, 20, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stores',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$placesCount places you earn at',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textDim,
                  ),
                ),
              ],
            ),
          ),
          WalletButton(total: total, onTap: onOpenWallet),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0x12F0EFE9),
        border: Border.all(color: AppColors.borderHi),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SkIcon(SkIconData.search, size: 18, color: AppColors.textDim),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: AppColors.gold,
              style: const TextStyle(
                fontSize: 14.5,
                color: AppColors.text,
              ),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search stores, areas, categories',
                hintStyle: TextStyle(
                  fontSize: 14.5,
                  color: AppColors.textDim,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: const SkIcon(
                SkIconData.close,
                size: 16,
                color: AppColors.muted,
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.chips,
    required this.active,
    required this.onTap,
  });

  final List<String> chips;
  final String active;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = chips[i];
          final on = c == active;
          return Material(
            color: on ? AppColors.gold : const Color(0x0FF0EFE9),
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: () => onTap(c),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: on ? AppColors.gold : AppColors.borderHi,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  c,
                  style: TextStyle(
                    fontFamily: AppTypography.fontSans,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                    color: on ? AppColors.bg : AppColors.textDim,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ListBody extends StatelessWidget {
  const _ListBody({
    required this.stores,
    required this.query,
    required this.onOpen,
  });

  final List<StoreModel> stores;
  final String query;
  final ValueChanged<StoreModel> onOpen;

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) {
      return _EmptyState(query: query);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
      itemCount: stores.length,
      separatorBuilder: (_, __) => const SizedBox(height: 11),
      itemBuilder: (_, i) => FadeSlideIn(
        delay: Duration(milliseconds: 60 + i * 50),
        offset: 12,
        child: StoreCardRich(
          store: stores[i],
          onTap: () => onOpen(stores[i]),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final hasQuery = query.trim().isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: 0.6,
              child: const SkIcon(
                SkIconData.search,
                size: 30,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasQuery
                  ? 'No stores match "$query"'
                  : 'No stores in this filter',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Warm hero wash + soft gold glow shared by Stores and Home.
class _HeroBackdrop extends StatelessWidget {
  const _HeroBackdrop();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.26, 0.9],
                colors: [
                  Color(0xFF221B0D),
                  Color(0xFF181308),
                  AppColors.bg,
                ],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.6),
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

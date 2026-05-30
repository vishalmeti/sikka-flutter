import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/store_catalog.dart';
import '../models/store_model.dart';
import '../state/customer_home_store.dart';
import '../widgets/offer_card.dart';
import '../widgets/stylized_map.dart';
import '../widgets/wallet_sheet.dart';
import 'scan_screen.dart';

/// Detail page for a single store.
///
/// Layout (top → bottom):
///   • Map header (stylized) with overlaid back button + ETA + open-in-maps
///   • Overlapping header card (logo + name + status + rating)
///   • Action row (Directions / Call / Scan & Pay)
///   • "Your standing here" card → opens wallet sheet on tap
///   • Live offers list
///   • About rows (address, hours, phone, visits/reviews)
///   • Sticky pay bar at the bottom
class StoreDetailScreen extends StatelessWidget {
  const StoreDetailScreen({super.key, required this.store});

  final StoreModel store;

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openScan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const ScanScreen(),
      ),
    );
  }

  void _openWallet(BuildContext context) {
    final home = context.read<CustomerHomeStore>();
    final data = home.data;
    final stores = data == null || data.stores.isEmpty
        ? StoreCatalog.instance.demoStores()
        : StoreCatalog.instance.enrichAll(data.stores);
    WalletSheet.show(
      context,
      stores: stores,
      redeemRate: data?.redeemRate ?? 2,
      onOpenStore: (s) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => StoreDetailScreen(store: s)),
        );
      },
      onRedeem: () => Navigator.of(context).pushNamed('/redeem'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 90 + bottomPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MapHeader(
                        store: store,
                        onBack: () => Navigator.of(context).maybePop(),
                        onOpenMaps: () => _open(store.mapsUrl),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -26),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          child: _StoreHeaderCard(store: store),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: _ActionRow(
                          onDirections: () => _open(store.mapsUrl),
                          onCall: () => _open(store.phoneUrl),
                          onScan: () => _openScan(context),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: _SectionTitle('Your standing here'),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 11, 20, 0),
                        child: _StandingCard(
                          store: store,
                          onTap: () => _openWallet(context),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 22, 20, 0),
                        child: _LiveOffersHeader(count: store.offers.length),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 11, 20, 0),
                        child: _OffersSection(store: store),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 22, 20, 0),
                        child: _SectionTitle('About'),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 11, 20, 24),
                        child: _AboutCard(
                          store: store,
                          onCall: () => _open(store.phoneUrl),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _StickyPayBar(
              store: store,
              onScan: () => _openScan(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ── map header ──────────────────────────────────────────────────────────────

class _MapHeader extends StatelessWidget {
  const _MapHeader({
    required this.store,
    required this.onBack,
    required this.onOpenMaps,
  });

  final StoreModel store;
  final VoidCallback onBack;
  final VoidCallback onOpenMaps;

  static const double _height = 248;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: _height,
      child: Stack(
        children: [
          Positioned.fill(
            child: StylizedMap(seed: store.lat + store.lng),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF221B0D).withValues(alpha: 0.45),
                      Colors.transparent,
                      const Color(0xFF0A0A0F).withValues(alpha: 0.55),
                    ],
                    stops: const [0, 0.38, 1],
                  ),
                ),
              ),
            ),
          ),
          // central pin
          Align(
            alignment: const Alignment(0, -0.2),
            child: _DetailPin(store: store),
          ),
          // back button
          Positioned(
            top: topPad,
            left: 16,
            child: _GlassIconButton(
              icon: SkIconData.back,
              onTap: onBack,
            ),
          ),
          // ETA chip
          Positioned(
            left: 16,
            bottom: 40,
            child: _GlassChip(
              icon: SkIconData.navigation,
              iconColor: AppColors.teal,
              text: '${store.walkingEtaMinutes} min · ${store.distance}',
            ),
          ),
          // open in maps
          Positioned(
            right: 16,
            bottom: 40,
            child: GestureDetector(
              onTap: onOpenMaps,
              child: const _GlassChip(
                icon: SkIconData.navigation,
                iconColor: AppColors.text,
                text: 'Open in Maps',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailPin extends StatelessWidget {
  const _DetailPin({required this.store});
  final StoreModel store;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xD10A0A0F),
            border: Border.all(color: AppColors.borderHi),
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x800A0A0F),
                blurRadius: 22,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            store.name,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Transform.rotate(
          angle: 0.7854, // 45°
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                center: Alignment(-0.3, -0.4),
                colors: [
                  Color(0xFFF0D680),
                  AppColors.gold,
                  Color(0xFF8A7330),
                ],
                stops: [0, 0.65, 1],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(999),
                topRight: Radius.circular(999),
                bottomLeft: Radius.circular(999),
                bottomRight: Radius.circular(2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Transform.rotate(
                angle: -0.7854,
                child: const SkIcon(
                  SkIconData.store,
                  size: 17,
                  color: Color(0xFF4A3A14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap});
  final SkIconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xB30A0A0F),
          border: Border.all(color: AppColors.borderHi),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: SkIcon(icon, size: 18, color: AppColors.text),
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({
    required this.icon,
    required this.text,
    required this.iconColor,
  });

  final SkIconData icon;
  final String text;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xB30A0A0F),
        border: Border.all(color: AppColors.borderHi),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SkIcon(icon, size: 13, color: iconColor),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

// ── header card ─────────────────────────────────────────────────────────────

class _StoreHeaderCard extends StatelessWidget {
  const _StoreHeaderCard({required this.store});
  final StoreModel store;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StoreInitialsTile(
            initials: store.initials,
            accent: store.accent,
            size: 56,
            radius: 16,
            fontSize: 19,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${store.category} · ${store.area}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textDim,
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    _StatusDot(open: store.isOpen),
                    const SizedBox(width: 12),
                    const SkIcon(SkIconData.star,
                        size: 12, color: AppColors.gold),
                    const SizedBox(width: 5),
                    Text(
                      store.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      store.distance,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
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
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.open});
  final bool open;

  @override
  Widget build(BuildContext context) {
    final color = open ? AppColors.success : AppColors.coral;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          open ? 'Open' : 'Closed',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── action row ──────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.onDirections,
    required this.onCall,
    required this.onScan,
  });

  final VoidCallback onDirections;
  final VoidCallback onCall;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: SkIconData.navigation,
            label: 'Directions',
            onTap: onDirections,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionTile(
            icon: SkIconData.phone,
            label: 'Call',
            onTap: onCall,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionTile(
            icon: SkIconData.scan,
            label: 'Scan & Pay',
            onTap: onScan,
            primary: true,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final SkIconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final fg = primary ? AppColors.bg : AppColors.text;
    return Material(
      color: primary ? AppColors.gold : AppColors.surface,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            border: Border.all(
              color: primary ? AppColors.gold : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkIcon(icon, size: 17, color: fg),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: primary ? AppColors.bg : AppColors.textDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── section titles ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: SkLabel(text),
    );
  }
}

class _LiveOffersHeader extends StatelessWidget {
  const _LiveOffersHeader({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SkLabel('Live offers'),
          if (count > 0)
            Text(
              '$count active',
              style: TextStyle(
                fontFamily: AppTypography.fontMono,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.coral,
              ),
            ),
        ],
      ),
    );
  }
}

// ── standing card ───────────────────────────────────────────────────────────

class _StandingCard extends StatelessWidget {
  const _StandingCard({required this.store, required this.onTap});
  final StoreModel store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final redeemRate = context.watch<CustomerHomeStore>().data?.redeemRate ?? 2;
    final value = redeemRate > 0 ? (store.coins / redeemRate).floor() : 0;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(18),
            gradient: const RadialGradient(
              center: Alignment(0, -1.2),
              radius: 1.0,
              colors: [AppColors.goldDim, Colors.transparent],
            ),
          ),
          child: Row(
            children: [
              SkTierRing(
                tier: store.tier,
                size: 62,
                progress: store.progress,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          fmtNumber(store.coins),
                          style: TextStyle(
                            fontFamily: AppTypography.fontMono,
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                            letterSpacing: -0.6,
                            height: 1,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'SIKKA',
                            style: AppTypography.label.copyWith(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textDim,
                        ),
                        children: [
                          TextSpan(text: '≈ ${fmtRupee(value)} value · '),
                          TextSpan(
                            text: '${_capitalize(store.tier)} tier',
                            style: TextStyle(
                              color: store.tierColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SkIcon(SkIconData.chevronRight,
                  size: 18, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── offers ──────────────────────────────────────────────────────────────────

class _OffersSection extends StatelessWidget {
  const _OffersSection({required this.store});
  final StoreModel store;

  @override
  Widget build(BuildContext context) {
    if (store.offers.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Opacity(
              opacity: 0.6,
              child: const SkIcon(SkIconData.tag,
                  size: 22, color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            const Text(
              'No live offers right now',
              style: TextStyle(fontSize: 13, color: AppColors.textDim),
            ),
            const SizedBox(height: 3),
            const Text(
              'You still earn Sikka on every scan',
              style: TextStyle(fontSize: 11.5, color: AppColors.muted),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < store.offers.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          OfferCard(
            offer: store.offers[i],
            storeInitials: store.initials,
          ),
        ],
      ],
    );
  }
}

// ── about ───────────────────────────────────────────────────────────────────

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.store, required this.onCall});
  final StoreModel store;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _AboutRow(
            icon: SkIconData.pin,
            label: store.address,
            sub: '${store.distance} away',
            first: true,
          ),
          _AboutRow(
            icon: SkIconData.clock,
            label: store.hours,
            sub: store.isOpen ? 'Open now' : 'Currently closed',
            subColor: store.isOpen ? AppColors.success : AppColors.coral,
          ),
          _AboutRow(
            icon: SkIconData.phone,
            label: store.phone.isEmpty ? 'No phone listed' : store.phone,
            sub: store.phone.isEmpty ? null : 'Tap to call',
            onTap: store.phone.isEmpty ? null : onCall,
          ),
          _AboutRow(
            icon: SkIconData.coin,
            label: '${store.visits} visits · last ${store.lastVisit}',
            sub: '${store.reviews} reviews',
          ),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({
    required this.icon,
    required this.label,
    this.sub,
    this.subColor,
    this.onTap,
    this.first = false,
  });

  final SkIconData icon;
  final String label;
  final String? sub;
  final Color? subColor;
  final VoidCallback? onTap;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: first
            ? null
            : const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          SkIcon(icon, size: 15, color: AppColors.textDim),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
                if (sub != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    sub!,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: subColor ?? AppColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            const SkIcon(
              SkIconData.chevronRight,
              size: 14,
              color: AppColors.muted,
            ),
        ],
      ),
    );
    if (onTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

// ── sticky pay bar ──────────────────────────────────────────────────────────

class _StickyPayBar extends StatelessWidget {
  const _StickyPayBar({required this.store, required this.onScan});

  final StoreModel store;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final shortName = store.name.split(' ').first;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 10),
      decoration: BoxDecoration(
        color: AppColors.bg.withValues(alpha: 0.92),
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SkButton(
        label: 'Scan & Pay at $shortName',
        icon: const SkIcon(SkIconData.scan, size: 18, color: AppColors.bg),
        onTap: onScan,
      ),
    );
  }
}

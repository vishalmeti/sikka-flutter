import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/store_model.dart';
import 'stylized_map.dart';
import 'wallet_sheet.dart' show StoreInitialsTile;

/// Map view for the Stores tab: stylized city grid + gold pins for each
/// store, with a synced horizontal rail of cards at the bottom (the
/// "Google Maps places" interaction).
class StoresMapView extends StatefulWidget {
  const StoresMapView({
    super.key,
    required this.stores,
    required this.onOpenStore,
  });

  final List<StoreModel> stores;
  final ValueChanged<StoreModel> onOpenStore;

  @override
  State<StoresMapView> createState() => _StoresMapViewState();
}

class _StoresMapViewState extends State<StoresMapView> {
  static const double _cardSpacing = 12;
  static const double _railSidePad = 32;
  static const double _railBottomGap = 14;

  late final PageController _railController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _railController = PageController(viewportFraction: 0.86);
    _railController.addListener(_syncFromRail);
  }

  @override
  void didUpdateWidget(covariant StoresMapView old) {
    super.didUpdateWidget(old);
    if (_selectedIndex >= widget.stores.length) {
      _selectedIndex = widget.stores.isEmpty ? 0 : widget.stores.length - 1;
    }
  }

  @override
  void dispose() {
    _railController.removeListener(_syncFromRail);
    _railController.dispose();
    super.dispose();
  }

  void _syncFromRail() {
    if (!_railController.hasClients) return;
    final page = _railController.page;
    if (page == null) return;
    final nearest = page.round().clamp(0, widget.stores.length - 1);
    if (nearest != _selectedIndex) {
      setState(() => _selectedIndex = nearest);
    }
  }

  void _selectFromPin(int index) {
    if (index < 0 || index >= widget.stores.length) return;
    setState(() => _selectedIndex = index);
    if (_railController.hasClients) {
      _railController.animateToPage(
        index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  _MapBounds _bounds() {
    if (widget.stores.isEmpty) {
      return const _MapBounds(
        latMin: 12.9, latMax: 13.0, lngMin: 77.59, lngMax: 77.65);
    }
    double latMin = double.infinity, latMax = -double.infinity;
    double lngMin = double.infinity, lngMax = -double.infinity;
    for (final s in widget.stores) {
      latMin = s.lat < latMin ? s.lat : latMin;
      latMax = s.lat > latMax ? s.lat : latMax;
      lngMin = s.lng < lngMin ? s.lng : lngMin;
      lngMax = s.lng > lngMax ? s.lng : lngMax;
    }
    // Avoid degenerate bounds when all points share a coordinate.
    if (latMin == latMax) { latMin -= 0.01; latMax += 0.01; }
    if (lngMin == lngMax) { lngMin -= 0.01; lngMax += 0.01; }
    return _MapBounds(
        latMin: latMin, latMax: latMax, lngMin: lngMin, lngMax: lngMax);
  }

  @override
  Widget build(BuildContext context) {
    final bounds = _bounds();
    return Stack(
      children: [
        // backdrop
        Positioned.fill(
          child: StylizedMap(
            seed: widget.stores.isEmpty ? 12.95 : widget.stores.first.lat +
                widget.stores.first.lng,
            rotation: -16,
          ),
        ),
        // warm wash + gold glow blend
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.4),
                  radius: 0.55,
                  colors: [AppColors.goldFaint, Colors.transparent],
                  stops: [0, 1],
                ),
              ),
            ),
          ),
        ),
        // legend
        Positioned(
          top: 12,
          left: 20,
          child: _LegendChip(count: widget.stores.length),
        ),
        // "you" marker — center of map
        const Center(child: _YouMarker()),
        // pins
        ...List.generate(widget.stores.length, (i) {
          final s = widget.stores[i];
          final pos = _project(s.lat, s.lng, bounds);
          return _PinPositioned(
            relative: pos,
            child: _MapPin(
              store: s,
              active: i == _selectedIndex,
              onTap: () => _selectFromPin(i),
            ),
          );
        }),
        // bottom rail
        if (widget.stores.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: _railBottomGap,
            height: 132,
            child: PageView.builder(
              controller: _railController,
              padEnds: false,
              itemCount: widget.stores.length,
              itemBuilder: (_, i) => Padding(
                padding: EdgeInsets.fromLTRB(
                  i == 0 ? _railSidePad : _cardSpacing / 2,
                  0,
                  i == widget.stores.length - 1 ? _railSidePad : _cardSpacing / 2,
                  0,
                ),
                child: _MapRailCard(
                  store: widget.stores[i],
                  active: i == _selectedIndex,
                  onOpen: () => widget.onOpenStore(widget.stores[i]),
                ),
              ),
            ),
          ),
        if (widget.stores.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'No stores match this filter',
                style: TextStyle(fontSize: 14, color: AppColors.textDim),
              ),
            ),
          ),
      ],
    );
  }

  /// Project lat/lng to a relative position (0..1 within the panel) with
  /// padding so pins never hug the frame edges.
  Offset _project(double lat, double lng, _MapBounds b) {
    const padX = 0.17, padY = 0.20;
    final nx = (lng - b.lngMin) / ((b.lngMax - b.lngMin));
    final ny = (b.latMax - lat) / ((b.latMax - b.latMin));
    return Offset(
      padX + nx * (1 - 2 * padX),
      padY + ny * (1 - 2 * padY),
    );
  }
}

class _MapBounds {
  const _MapBounds({
    required this.latMin,
    required this.latMax,
    required this.lngMin,
    required this.lngMax,
  });
  final double latMin, latMax, lngMin, lngMax;
}

class _PinPositioned extends StatelessWidget {
  const _PinPositioned({required this.relative, required this.child});

  final Offset relative;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final x = relative.dx * c.maxWidth;
        final y = relative.dy * c.maxHeight;
        return Positioned(
          left: x - 23,
          top: y - 44,
          child: child,
        );
      },
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.store,
    required this.active,
    required this.onTap,
  });

  final StoreModel store;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = active ? 46.0 : 34.0;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 46,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (active)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xDC0A0A0F),
                    border: Border.all(color: AppColors.borderHi),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x800A0A0F),
                          blurRadius: 22,
                          offset: Offset(0, 8)),
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
              ),
            Transform.rotate(
              angle: 0.7854, // 45°
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.4),
                    colors: active
                        ? const [
                            Color(0xFFF4DE92),
                            AppColors.gold,
                            Color(0xFF7E6A2C),
                          ]
                        : [
                            store.accent,
                            store.accent.withValues(alpha: 0.8),
                            store.accent.withValues(alpha: 0.4),
                          ],
                    stops: const [0, 0.62, 1],
                  ),
                  border: Border.all(
                    color: Colors.white
                        .withValues(alpha: active ? 0.30 : 0.18),
                    width: 1.5,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(999),
                    topRight: Radius.circular(999),
                    bottomLeft: Radius.circular(999),
                    bottomRight: Radius.circular(3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.55),
                      blurRadius: active ? 20 : 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Transform.rotate(
                    angle: -0.7854,
                    child: Text(
                      store.tierLetter,
                      style: TextStyle(
                        fontFamily: AppTypography.fontMono,
                        fontSize: active ? 13 : 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF33280C),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _YouMarker extends StatelessWidget {
  const _YouMarker();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.teal,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.bg, width: 2.5),
              boxShadow: const [
                BoxShadow(color: AppColors.tealDim, blurRadius: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xB30A0A0F),
        border: Border.all(color: AppColors.borderHi),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendDot(color: AppColors.teal),
          const SizedBox(width: 6),
          const Text(
            'You',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textDim,
            ),
          ),
          Container(
            width: 1,
            height: 12,
            color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),
          _LegendDot(color: AppColors.gold),
          const SizedBox(width: 6),
          Text(
            '$count stores',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _MapRailCard extends StatelessWidget {
  const _MapRailCard({
    required this.store,
    required this.active,
    required this.onOpen,
  });

  final StoreModel store;
  final bool active;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final offer = store.featuredOffer;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: active ? AppColors.goldDim : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.40),
                blurRadius: active ? 30 : 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StoreInitialsTile(
                    initials: store.initials,
                    accent: store.accent,
                    size: 46,
                    radius: 13,
                    fontSize: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                store.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: store.isOpen
                                    ? AppColors.success
                                    : AppColors.muted,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const SkIcon(SkIconData.star,
                                size: 11, color: AppColors.gold),
                            const SizedBox(width: 3),
                            Text(
                              store.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('·',
                                style: TextStyle(color: AppColors.muted)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${store.category} · ${store.distance}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SkTierRing(
                    tier: store.tier,
                    size: 38,
                    progress: store.progress,
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  Text(
                    fmtNumber(store.coins),
                    style: TextStyle(
                      fontFamily: AppTypography.fontMono,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      'SIKKA',
                      style: AppTypography.label.copyWith(fontSize: 10),
                    ),
                  ),
                  const Spacer(),
                  if (offer != null) ...[
                    _RailOfferPill(offer: offer),
                    const SizedBox(width: 8),
                  ],
                  const Text(
                    'Open',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDim,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const SkIcon(SkIconData.chevronRight,
                      size: 13, color: AppColors.textDim),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailOfferPill extends StatelessWidget {
  const _RailOfferPill({required this.offer});
  final StoreOffer offer;

  @override
  Widget build(BuildContext context) {
    final hot = offer.hot;
    final fg = hot ? AppColors.coral : AppColors.gold;
    final bg = hot ? AppColors.coralDim : AppColors.goldFaint;
    final br = hot ? const Color(0x4DFF5C3A) : AppColors.goldDim;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: br),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SkIcon(SkIconData.tag, size: 11, color: fg),
          const SizedBox(width: 6),
          Text(
            offer.tag,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

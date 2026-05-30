import 'package:flutter/material.dart';

import '../../../core/api/dashboard_api.dart';
import 'store_model.dart';

/// Locally-known metadata for a store (location, hours, accent, offers).
///
/// The dashboard API returns only the dynamic per-user fields (coins, tier,
/// progress, visits). [StoreCatalog] merges these "facts about the store"
/// with the live values to produce a [StoreModel] the UI can render fully.
class StoreCatalogEntry {
  const StoreCatalogEntry({
    required this.id,
    required this.name,
    required this.initials,
    required this.accent,
    required this.category,
    required this.area,
    required this.address,
    required this.distance,
    required this.lat,
    required this.lng,
    required this.isOpen,
    required this.hours,
    required this.phone,
    required this.rating,
    required this.reviews,
    required this.lastVisit,
    required this.offers,
  });

  final String id;
  final String name;
  final String initials;
  final Color accent;
  final String category;
  final String area;
  final String address;
  final String distance;
  final double lat;
  final double lng;
  final bool isOpen;
  final String hours;
  final String phone;
  final double rating;
  final int reviews;
  final String lastVisit;
  final List<StoreOffer> offers;
}

/// In-memory catalog of store metadata. Seeded with the design's example
/// stores so the experience works without an API for these details — but
/// `_StoreSynth` provides deterministic fallbacks for any unknown store so
/// the UI never breaks if the backend introduces a new store first.
class StoreCatalog {
  StoreCatalog._();

  static final StoreCatalog instance = StoreCatalog._();

  static const List<StoreCatalogEntry> _seed = [
    StoreCatalogEntry(
      id: 'ramesh',
      name: 'Ramesh Stores',
      initials: 'RS',
      accent: Color(0xFFC9A84C),
      category: 'Kirana & Groceries',
      area: 'Indiranagar',
      address: 'Shop 14, 100ft Road, Indiranagar',
      distance: '0.4 km',
      lat: 12.9719,
      lng: 77.6412,
      isOpen: true,
      hours: '8:00 AM – 10:00 PM',
      phone: '+91 98450 11247',
      rating: 4.8,
      reviews: 312,
      lastVisit: 'Today, 6:42 PM',
      offers: [
        StoreOffer(
          tag: 'FLAT 10%',
          title: '10% off on bills above ₹500',
          subtitle: 'Auto-applied at checkout · Today only',
          hot: true,
          ends: 'Ends in 5h',
        ),
        StoreOffer(
          tag: '2×',
          title: 'Double Sikka on dairy',
          subtitle: 'Milk, curd & paneer earn 2× coins',
        ),
      ],
    ),
    StoreCatalogEntry(
      id: 'sharma',
      name: 'Sharma Kirana',
      initials: 'SK',
      accent: Color(0xFF4C9A84),
      category: 'Daily Needs',
      area: 'Koramangala',
      address: '5th Block, Koramangala',
      distance: '1.2 km',
      lat: 12.9352,
      lng: 77.6245,
      isOpen: true,
      hours: '7:00 AM – 11:00 PM',
      phone: '+91 98801 33421',
      rating: 4.6,
      reviews: 188,
      lastVisit: 'Yesterday, 8:11 PM',
      offers: [
        StoreOffer(
          tag: 'FREE',
          title: 'Free home delivery over ₹300',
          subtitle: 'Within 2 km · No coupon needed',
        ),
      ],
    ),
    StoreCatalogEntry(
      id: 'patel',
      name: 'Patel General',
      initials: 'PG',
      accent: Color(0xFF9A7BC9),
      category: 'General Store',
      area: 'HSR Layout',
      address: 'Sector 2, HSR Layout',
      distance: '2.1 km',
      lat: 12.9116,
      lng: 77.6389,
      isOpen: true,
      hours: '9:00 AM – 9:00 PM',
      phone: '+91 99006 55872',
      rating: 4.5,
      reviews: 94,
      lastVisit: '3 days ago',
      offers: [
        StoreOffer(
          tag: '₹50 OFF',
          title: '₹50 off your next scan',
          subtitle: 'Min bill ₹400 · One-time',
          hot: true,
          ends: '2 days left',
        ),
      ],
    ),
    StoreCatalogEntry(
      id: 'green',
      name: 'Green Leaf Mart',
      initials: 'GL',
      accent: Color(0xFF5FA84C),
      category: 'Fruits & Vegetables',
      area: 'BTM Layout',
      address: '16th Main, BTM 2nd Stage',
      distance: '2.8 km',
      lat: 12.9166,
      lng: 77.6101,
      isOpen: true,
      hours: '6:00 AM – 10:00 PM',
      phone: '+91 91085 22109',
      rating: 4.7,
      reviews: 142,
      lastVisit: '2 weeks ago',
      offers: [
        StoreOffer(
          tag: '15%',
          title: '15% off fresh produce',
          subtitle: 'Before 11 AM · Daily',
          hot: true,
          ends: 'Mornings only',
        ),
      ],
    ),
    StoreCatalogEntry(
      id: 'iqbal',
      name: 'Iqbal Bakery',
      initials: 'IB',
      accent: Color(0xFFC97B3D),
      category: 'Bakery & Snacks',
      area: 'Frazer Town',
      address: 'Mosque Road, Frazer Town',
      distance: '4.0 km',
      lat: 13.0010,
      lng: 77.6190,
      isOpen: false,
      hours: '7:00 AM – 9:30 PM',
      phone: '+91 98452 71630',
      rating: 4.9,
      reviews: 506,
      lastVisit: '5 days ago',
      offers: [
        StoreOffer(
          tag: 'BOGO',
          title: 'Buy 1 Get 1 on cakes',
          subtitle: 'Weekends · Eggless included',
        ),
      ],
    ),
    StoreCatalogEntry(
      id: 'anand',
      name: 'Anand Provisions',
      initials: 'AP',
      accent: Color(0xFF6B6A72),
      category: 'Provisions',
      area: 'Jayanagar',
      address: '4th Block, Jayanagar',
      distance: '3.4 km',
      lat: 12.9250,
      lng: 77.5938,
      isOpen: false,
      hours: '8:00 AM – 9:00 PM',
      phone: '+91 98863 40027',
      rating: 4.3,
      reviews: 61,
      lastVisit: '1 week ago',
      offers: [],
    ),
  ];

  /// All catalog stores, in the order they should appear when the backend
  /// hasn't returned any data (demo / first-launch state).
  List<StoreCatalogEntry> get seed => List.unmodifiable(_seed);

  /// Lookup a catalog entry by id or by case-insensitive name match.
  StoreCatalogEntry? lookup({String? id, String? name}) {
    for (final e in _seed) {
      if (id != null && e.id == id) return e;
      if (name != null && e.name.toLowerCase() == name.toLowerCase()) return e;
    }
    return null;
  }

  /// Merge a live [DashboardStore] with locally-known details. Falls back to
  /// deterministic synthesized values for stores not in the catalog.
  StoreModel enrich(DashboardStore live) {
    final entry = lookup(id: live.id, name: live.name);
    final synth = _StoreSynth(live);
    return StoreModel(
      id: live.id,
      name: live.name,
      initials: entry?.initials ?? synth.initials,
      accent: entry?.accent ?? synth.accent,
      category: entry?.category ?? 'Kirana store',
      tier: live.tier,
      coins: live.coins,
      progress: live.tierProgress,
      visits: live.visits,
      area: entry?.area ?? '—',
      address: entry?.address ?? '—',
      distance: entry?.distance ?? '—',
      lat: entry?.lat ?? 0,
      lng: entry?.lng ?? 0,
      isOpen: entry?.isOpen ?? true,
      hours: entry?.hours ?? 'Hours unavailable',
      phone: entry?.phone ?? '',
      rating: entry?.rating ?? 0,
      reviews: entry?.reviews ?? 0,
      lastVisit: entry?.lastVisit ?? 'Recently',
      offers: entry?.offers ?? const [],
    );
  }

  /// Convenience: enrich a whole list of dashboard stores in order.
  List<StoreModel> enrichAll(Iterable<DashboardStore> stores) =>
      stores.map(enrich).toList(growable: false);

  /// Build a demo list from the seed catalog — used when the backend hasn't
  /// returned any stores yet but we still want to render the UI.
  List<StoreModel> demoStores() {
    return _seed
        .map((e) => StoreModel(
              id: e.id,
              name: e.name,
              initials: e.initials,
              accent: e.accent,
              category: e.category,
              tier: _demoTierFor(e.id),
              coins: _demoCoinsFor(e.id),
              progress: _demoProgressFor(e.id),
              visits: _demoVisitsFor(e.id),
              area: e.area,
              address: e.address,
              distance: e.distance,
              lat: e.lat,
              lng: e.lng,
              isOpen: e.isOpen,
              hours: e.hours,
              phone: e.phone,
              rating: e.rating,
              reviews: e.reviews,
              lastVisit: e.lastVisit,
              offers: e.offers,
            ))
        .toList();
  }

  // ── demo defaults (mirror the design dataset) ────────────────────────────

  static const _demoCoins = {
    'ramesh': 847,
    'sharma': 312,
    'patel': 188,
    'green': 64,
    'iqbal': 140,
    'anand': 64,
  };
  static const _demoVisits = {
    'ramesh': 12,
    'sharma': 7,
    'patel': 4,
    'green': 2,
    'iqbal': 5,
    'anand': 2,
  };
  static const _demoProgress = {
    'ramesh': 0.85,
    'sharma': 0.62,
    'patel': 0.38,
    'green': 0.32,
    'iqbal': 0.5,
    'anand': 0.28,
  };
  static const _demoTier = {
    'ramesh': 'gold',
    'sharma': 'silver',
    'patel': 'silver',
    'green': 'bronze',
    'iqbal': 'silver',
    'anand': 'bronze',
  };
  int _demoCoinsFor(String id) => _demoCoins[id] ?? 100;
  int _demoVisitsFor(String id) => _demoVisits[id] ?? 1;
  double _demoProgressFor(String id) => _demoProgress[id] ?? 0.3;
  String _demoTierFor(String id) => _demoTier[id] ?? 'bronze';
}

/// Synthesized fallback values for stores not in the catalog. Keeps the UI
/// renderable even if the backend returns a brand-new store before the
/// frontend catalog has been updated.
class _StoreSynth {
  _StoreSynth(this._live);
  final DashboardStore _live;

  static const _palette = [
    Color(0xFFC9A84C),
    Color(0xFF4C9A84),
    Color(0xFF9A7BC9),
    Color(0xFF5FA84C),
    Color(0xFFC97B3D),
    Color(0xFFC95F8A),
  ];

  String get initials {
    final parts = _live.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '··';
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    final p = parts[0];
    return (p.length >= 2 ? p.substring(0, 2) : p).toUpperCase();
  }

  Color get accent {
    var hash = 0;
    for (final c in _live.id.codeUnits) {
      hash = (hash * 31 + c) & 0x7fffffff;
    }
    return _palette[hash % _palette.length];
  }
}

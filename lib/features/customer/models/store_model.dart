import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A live offer at a store. Surfaced on store cards and the store detail page.
class StoreOffer {
  const StoreOffer({
    required this.tag,
    required this.title,
    required this.subtitle,
    this.hot = false,
    this.ends,
  });

  /// Compact label like "FLAT 10%", "2×", "FREE", "₹50 OFF".
  final String tag;
  final String title;
  final String subtitle;

  /// Time-sensitive offers render with the coral accent + countdown.
  final bool hot;

  /// Human-readable "ends" copy. When it contains a number of hours
  /// (e.g. "Ends in 5h"), the UI shows a live HH:MM:SS countdown.
  final String? ends;

  /// Hours remaining if [ends] mentions a "Nh" duration.
  int? get endsInHours {
    final e = ends;
    if (e == null) return null;
    final match = RegExp(r'(\d+)\s*h', caseSensitive: false).firstMatch(e);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  /// Short coupon code derived from store + tag, used after the user claims.
  String codeFor(String storeInitials) {
    final raw = ('SK$storeInitials$tag').toUpperCase();
    final letters = raw.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return letters.substring(0, letters.length.clamp(0, 8));
  }
}

/// Rich store representation used by the Stores tab and Store detail screen.
///
/// The dashboard endpoint returns a minimal shape (`DashboardStore`). The
/// catalog ([StoreCatalog]) merges that live data with locally-known
/// details (location, hours, offers) and synthesizes sensible defaults
/// for anything missing so the UI never has to handle nulls.
class StoreModel {
  const StoreModel({
    required this.id,
    required this.name,
    required this.initials,
    required this.accent,
    required this.category,
    required this.tier,
    required this.coins,
    required this.progress,
    required this.visits,
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
  final String tier;
  final int coins;

  /// 0..1 progress to the next tier.
  final double progress;
  final int visits;
  final String area;
  final String address;
  final String distance; // e.g. "0.4 km"
  final double lat;
  final double lng;
  final bool isOpen;
  final String hours;
  final String phone;
  final double rating;
  final int reviews;
  final String lastVisit;
  final List<StoreOffer> offers;

  /// First "hot" offer, otherwise the first offer, otherwise null.
  StoreOffer? get featuredOffer {
    if (offers.isEmpty) return null;
    return offers.firstWhere((o) => o.hot, orElse: () => offers.first);
  }

  Color get tierColor => AppColors.tierColor(tier);

  String get tierLetter {
    switch (tier) {
      case 'gold':
        return 'G';
      case 'silver':
        return 'S';
      case 'bronze':
        return 'B';
      default:
        return tier.isEmpty ? '·' : tier[0].toUpperCase();
    }
  }

  /// Distance in km parsed from [distance] (e.g. "0.4 km" → 0.4).
  double get distanceKm {
    final m = RegExp(r'([\d.]+)').firstMatch(distance);
    if (m == null) return 0.5;
    return double.tryParse(m.group(1)!) ?? 0.5;
  }

  /// Walking ETA in whole minutes; clamped at 2 min minimum.
  int get walkingEtaMinutes {
    final eta = (distanceKm * 12).round();
    return eta < 2 ? 2 : eta;
  }

  /// `tel:` URL for the store phone number.
  String get phoneUrl => 'tel:${phone.replaceAll(RegExp(r'\s'), '')}';

  /// Google Maps deep link for the store coordinates.
  String get mapsUrl =>
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
}

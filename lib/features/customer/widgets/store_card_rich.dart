import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/store_model.dart';
import 'wallet_sheet.dart' show StoreInitialsTile;

/// Full-width rich store card used in the Stores tab list.
///
/// Layout (top → bottom):
///   • Row 1: initials tile · name + open dot · category · distance · tier ring
///   • Row 2: coin balance · spacer · active-offer pill (or "Visited X")
class StoreCardRich extends StatelessWidget {
  const StoreCardRich({
    super.key,
    required this.store,
    required this.onTap,
  });

  final StoreModel store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(store: store),
              const SizedBox(height: 13),
              _Footer(store: store),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.store});

  final StoreModel store;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        StoreInitialsTile(
          initials: store.initials,
          accent: store.accent,
          size: 50,
          radius: 14,
          fontSize: 17,
        ),
        const SizedBox(width: 13),
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
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: store.isOpen ? AppColors.success : AppColors.muted,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      store.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '·',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(width: 6),
                  const SkIcon(
                    SkIconData.pin,
                    size: 11,
                    color: AppColors.textDim,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    store.distance,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textDim,
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
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.store});

  final StoreModel store;

  @override
  Widget build(BuildContext context) {
    final offer = store.featuredOffer;
    return Row(
      children: [
        Text(
          fmtNumber(store.coins),
          style: TextStyle(
            fontFamily: AppTypography.fontMono,
            fontSize: 18,
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
            style: AppTypography.label.copyWith(fontSize: 10.5),
          ),
        ),
        const Spacer(),
        if (offer != null)
          _OfferTagPill(offer: offer)
        else
          Text(
            'Visited ${store.lastVisit}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.muted,
            ),
          ),
      ],
    );
  }
}

class _OfferTagPill extends StatelessWidget {
  const _OfferTagPill({required this.offer});

  final StoreOffer offer;

  @override
  Widget build(BuildContext context) {
    final hot = offer.hot;
    final color = hot ? AppColors.coral : AppColors.gold;
    final bg = hot ? AppColors.coralDim : AppColors.goldFaint;
    final borderColor =
        hot ? const Color(0x4DFF5C3A) : AppColors.goldDim;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 168),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SkIcon(SkIconData.tag, size: 11, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                offer.tag,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

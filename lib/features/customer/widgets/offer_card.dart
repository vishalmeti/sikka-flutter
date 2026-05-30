import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/store_model.dart';

/// Live offer card with optional countdown timer.
///
/// Visually mimics a perforated ticket: rounded corners with two notches
/// punched on the left edge between the title row and the action row.
/// Tapping "Claim" reveals the coupon code derived from the offer + store.
class OfferCard extends StatefulWidget {
  const OfferCard({
    super.key,
    required this.offer,
    required this.storeInitials,
  });

  final StoreOffer offer;
  final String storeInitials;

  @override
  State<OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<OfferCard> {
  bool _claimed = false;

  @override
  Widget build(BuildContext context) {
    final hot = widget.offer.hot;
    final accent = hot ? AppColors.coral : AppColors.gold;
    final hasEnds = widget.offer.ends != null;
    final actionable = hot || hasEnds;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: hot
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x24FF5C3A),
                    Color(0x0AFF5C3A),
                  ],
                )
              : null,
          color: hot ? null : AppColors.surface,
          border: Border.all(
            color: hot ? const Color(0x4DFF5C3A) : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(offer: widget.offer, accent: accent),
            if (actionable)
              _ActionRow(
                hot: hot,
                accent: accent,
                claimed: _claimed,
                code: widget.offer.codeFor(widget.storeInitials),
                onClaim: () => setState(() => _claimed = true),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.offer, required this.accent});

  final StoreOffer offer;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final hot = offer.hot;
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TagBadge(offer: offer, hot: hot),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  offer.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textDim,
                  ),
                ),
                if (offer.ends != null) ...[
                  const SizedBox(height: 8),
                  _EndsChip(offer: offer, accent: accent),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.offer, required this.hot});

  final StoreOffer offer;
  final bool hot;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: hot ? AppColors.coral : AppColors.goldFaint,
        border: hot ? null : Border.all(color: AppColors.goldDim),
        borderRadius: BorderRadius.circular(13),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          offer.tag,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppTypography.fontMono,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: hot ? AppColors.bg : AppColors.gold,
          ),
        ),
      ),
    );
  }
}

class _EndsChip extends StatefulWidget {
  const _EndsChip({required this.offer, required this.accent});

  final StoreOffer offer;
  final Color accent;

  @override
  State<_EndsChip> createState() => _EndsChipState();
}

class _EndsChipState extends State<_EndsChip> {
  Timer? _timer;
  int _secondsLeft = 0;
  bool get _isCountdown => widget.offer.endsInHours != null;

  @override
  void initState() {
    super.initState();
    final hours = widget.offer.endsInHours;
    if (hours != null) {
      _secondsLeft = hours * 3600;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _secondsLeft = _secondsLeft > 0 ? _secondsLeft - 1 : 0);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final color = widget.accent;
    if (_isCountdown) {
      final h = _secondsLeft ~/ 3600;
      final m = (_secondsLeft % 3600) ~/ 60;
      final s = _secondsLeft % 60;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SkIcon(SkIconData.clock, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            '${_pad(h)}:${_pad(m)}:${_pad(s)}',
            style: TextStyle(
              fontFamily: AppTypography.fontMono,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: 0.3,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'LEFT',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: color.withValues(alpha: 0.85),
            ),
          ),
        ],
      );
    }
    // Static ends copy (e.g. "2 days left", "Mornings only").
    final muted = widget.offer.hot ? AppColors.coral : AppColors.muted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkIcon(SkIconData.clock, size: 12, color: muted),
        const SizedBox(width: 5),
        Text(
          widget.offer.ends!,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: muted,
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.hot,
    required this.accent,
    required this.claimed,
    required this.code,
    required this.onClaim,
  });

  final bool hot;
  final Color accent;
  final bool claimed;
  final String code;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final divider = hot ? const Color(0x52FF5C3A) : AppColors.borderHi;
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 11, 15, 11),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: divider, style: BorderStyle.solid),
        ),
      ),
      child: claimed
          ? Row(
              children: [
                const SkIcon(SkIconData.check,
                    size: 14, color: AppColors.success),
                const SizedBox(width: 6),
                const Text(
                  'Claimed',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0x0FF0EFE9),
                    border: Border.all(color: AppColors.borderHi),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    code,
                    style: TextStyle(
                      fontFamily: AppTypography.fontMono,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                const Expanded(
                  child: Text(
                    'Tap to claim — auto-applies on your next scan',
                    style: TextStyle(fontSize: 12, color: AppColors.textDim),
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    onTap: onClaim,
                    borderRadius: BorderRadius.circular(999),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Claim',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1,
                          color: AppColors.bg,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'sk_coin.dart';
import 'sk_warp_field.dart';

/// Branded loading view — the Sikka coin drifting through hyperspace, with an
/// optional uppercase status caption beneath it.
///
/// Intentionally size-agnostic: drop it into a full-screen `Scaffold.body`
/// (see `LoadingScreen`), into a sheet, or into any sized box. The coin scales
/// to its constraints unless an explicit [coinSize] is given.
///
/// ```dart
/// const SkLoadingView()                                 // visual only
/// SkLoadingView(message: 'Signing you in')              // with caption
/// SkLoadingView(showWarp: false, coinSize: 120)         // coin only, inline
/// ```
class SkLoadingView extends StatelessWidget {
  const SkLoadingView({
    super.key,
    this.message,
    this.coinSize,
    this.showWarp = true,
  });

  /// Optional caption rendered below the coin. Caller-supplied text is
  /// uppercased for the label treatment.
  final String? message;

  /// Override the auto-calculated coin diameter. Null = fit to constraints.
  final double? coinSize;

  /// When false, only the coin (and its halo) renders. Useful for overlays
  /// where the warp background would clash with surrounding chrome.
  final bool showWarp;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.hasBoundedWidth ? constraints.maxWidth : 360.0;
        final h = constraints.hasBoundedHeight ? constraints.maxHeight : 640.0;
        final auto = math.min(w * 0.58, h * 0.34).clamp(120.0, 260.0);
        final size = coinSize ?? auto.toDouble();

        return Stack(
          fit: StackFit.expand,
          children: [
            if (showWarp) const Positioned.fill(child: SkWarpField()),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkCoin(size: size),
                  if (message != null) ...[
                    const SizedBox(height: 28),
                    Text(
                      message!.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.fontMono,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.8,
                        color: AppColors.gold,
                        shadows: const [
                          Shadow(
                            color: Color(0xCC050508),
                            blurRadius: 12,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Dark, on-brand stylized "city" backdrop. Renders a deterministic
/// pseudo-random street grid, two thicker avenues, and a sprinkling of
/// blocks. The look is entirely self-contained (no network maps).
///
/// [seed] controls the random layout — passing the same seed gives the same
/// pattern, so a given store always renders identically.
class StylizedMap extends StatelessWidget {
  const StylizedMap({
    super.key,
    required this.seed,
    this.rotation,
  });

  /// Deterministic seed (e.g. `lat + lng`).
  final double seed;

  /// Override the grid rotation in degrees. Defaults to a value derived
  /// from the seed.
  final double? rotation;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(seed: seed, rotation: rotation),
      child: const SizedBox.expand(),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.seed, this.rotation});

  final double seed;
  final double? rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final rng = _Rng(((seed * 1000).abs().floor()) % 997);

    final rot = rotation ?? (-22 + rng.next() * 44);
    final ox = -40 + rng.next() * 40;
    final oy = -30 + rng.next() * 30;
    final gapV = 46 + rng.next() * 14;
    final gapH = 50 + rng.next() * 16;
    final parkX = rng.next() * width * 0.5;
    final parkY = rng.next() * height * 0.5;
    final av1Pos = (rng.next() * gapV * 3).floor().toDouble() + ox;
    final av2Pos = (rng.next() * gapH * 3).floor().toDouble() + oy;

    // Base background — warm radial center fading to near-black.
    final bgRect = Offset.zero & size;
    final bgGradient = RadialGradient(
      center: const Alignment(0, -0.16),
      radius: 0.6,
      colors: const [Color(0xFF1B1810), AppColors.bg],
    ).createShader(bgRect);
    canvas.drawRect(bgRect, Paint()..shader = bgGradient);

    canvas.save();
    final center = Offset(width / 2, height / 2);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rot * math.pi / 180);
    canvas.translate(-center.dx, -center.dy);

    // park
    final parkPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.10);
    final parkRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(parkX, parkY, 120, 86),
      const Radius.circular(10),
    );
    canvas.drawRRect(parkRect, parkPaint);
    canvas.drawRRect(
      parkRect,
      Paint()
        ..color = AppColors.teal.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // water band
    canvas.drawRect(
      Rect.fromLTWH(-60, oy + gapH * 4, width + 160, 22),
      Paint()..color = const Color(0x1F466E96),
    );

    // minor roads
    final minor = Paint()
      ..color = const Color(0x17F0EFE9)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (var x = -120.0; x < width + 120; x += gapV) {
      canvas.drawLine(
        Offset(x + ox, -80),
        Offset(x + ox, height + 80),
        minor,
      );
    }
    for (var y = -120.0; y < height + 120; y += gapH) {
      canvas.drawLine(
        Offset(-80, y + oy),
        Offset(width + 80, y + oy),
        minor,
      );
    }

    // two thicker avenues with gold tint
    canvas.drawLine(
      Offset(av1Pos, -80),
      Offset(av1Pos, height + 80),
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.30)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke,
    );
    canvas.drawLine(
      Offset(-80, av2Pos),
      Offset(width + 80, av2Pos),
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.22)
        ..strokeWidth = 4.5
        ..style = PaintingStyle.stroke,
    );

    // building blocks
    final blockFill = Paint()..color = const Color(0x09F0EFE9);
    final blockBorder = Paint()
      ..color = const Color(0x0DF0EFE9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    for (var i = 0; i < 22; i++) {
      final bx = -40 + rng.next() * (width + 80);
      final by = -40 + rng.next() * (height + 80);
      final bw = 12 + rng.next() * 26;
      final bh = 12 + rng.next() * 26;
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, bw, bh),
        const Radius.circular(2),
      );
      canvas.drawRRect(r, blockFill);
      canvas.drawRRect(r, blockBorder);
    }

    canvas.restore();

    // vignette
    final vignette = RadialGradient(
      center: const Alignment(0, -0.16),
      radius: 0.62,
      colors: const [Color(0x00000000), Color(0xB80A0A0F)],
      stops: const [0.55, 1.0],
    ).createShader(bgRect);
    canvas.drawRect(bgRect, Paint()..shader = vignette);
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) =>
      seed != oldDelegate.seed || rotation != oldDelegate.rotation;
}

class _Rng {
  _Rng(this._state);
  int _state;

  /// Deterministic 0..1 pseudo-random — same algorithm as the JSX prototype.
  double next() {
    _state = (_state * 16807) % 2147483647;
    return (_state % 1000) / 1000.0;
  }
}

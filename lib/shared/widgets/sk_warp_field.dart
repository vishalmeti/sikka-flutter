import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/theme/app_colors.dart';

/// Full-bleed hyperspace background: streaks of indigo/blue light flying past
/// the viewer, seeded with the Sikka gold + teal. Painted on every tick so the
/// streaks read as real motion. Reusable as the bed of the welcome hero or
/// the app's animated loading screen.
class SkWarpField extends StatefulWidget {
  const SkWarpField({super.key});

  @override
  State<SkWarpField> createState() => _SkWarpFieldState();
}

class _SkWarpFieldState extends State<SkWarpField>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _StarField _field = _StarField();
  Duration _last = Duration.zero;
  double _haloPhase = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (_last == Duration.zero) {
      _last = elapsed;
      return;
    }
    final dt = (elapsed - _last).inMicroseconds / Duration.microsecondsPerSecond;
    _last = elapsed;
    _field.update(dt);
    _haloPhase = (elapsed.inMicroseconds / Duration.microsecondsPerSecond) %
        (math.pi * 2 * 1000);
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Halo pulse: 6s ease-in-out, opacity 0.55 ↔ 0.85, scale 1 ↔ 1.08
    final haloT = 0.5 - 0.5 * math.cos((_haloPhase / 6) * 2 * math.pi);
    final haloOpacity = 0.55 + 0.30 * haloT;
    final haloScale = 1.0 + 0.08 * haloT;

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Deep-space backdrop + streaks
          Container(color: const Color(0xFF050508)),
          RepaintBoundary(
            child: CustomPaint(painter: _WarpPainter(_field)),
          ),
          // Central blue bloom at the vanishing point
          Positioned.fill(
            child: Align(
              alignment: const Alignment(0, -0.16),
              child: Transform.scale(
                scale: haloScale,
                child: Opacity(
                  opacity: haloOpacity,
                  child: const _CenterBloom(),
                ),
              ),
            ),
          ),
          // Warm gold pool under the coin
          const Positioned.fill(
            child: Align(
              alignment: Alignment(0, 0.32),
              child: _GoldPool(),
            ),
          ),
          // Top + bottom vignette so chrome/text stays legible
          const Positioned.fill(
            child: IgnorePointer(child: _Vignette()),
          ),
        ],
      ),
    );
  }
}

class _CenterBloom extends StatelessWidget {
  const _CenterBloom();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 320,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color(0x47788CFF),
            Color(0x1A5064DC),
            Color(0x00000000),
          ],
          stops: [0.0, 0.38, 0.68],
        ),
      ),
    );
  }
}

class _GoldPool extends StatelessWidget {
  const _GoldPool();
  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Container(
        width: 360,
        height: 240,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.goldDim,
              Color(0x00000000),
            ],
            stops: [0.0, 0.62],
          ),
        ),
      ),
    );
  }
}

class _Vignette extends StatelessWidget {
  const _Vignette();
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xC7050508), // top — 0.78 alpha
            Color(0x00050508),
            Color(0x00050508),
            Color(0x8C050508), // 0.55
            Color(0xE6050508), // 0.90
          ],
          stops: [0.0, 0.26, 0.60, 0.84, 1.0],
        ),
      ),
    );
  }
}

class _Star {
  double x = 0, y = 0, z = 0, speed = 0, size = 0;
  Color color = Colors.white;
}

class _StarField extends ChangeNotifier {
  static const int _count = 460;
  static const double _focal = 230;

  final List<_Star> stars = [];
  Size _size = Size.zero;

  static const List<Color> _palette = [
    Color(0xFF2A3FB0), Color(0xFF2A3FB0),
    Color(0xFF3552D8), Color(0xFF3552D8),
    Color(0xFF4F6BFF),
    Color(0xFF6E86FF),
    Color(0xFF1E2A78),
    Color(0xFF8FA2FF),
    Color(0xFFC9A84C), // gold
    Color(0xFFE6C66A), // gold highlight
    Color(0xFF4C9A84), // teal
    Color(0xFFF0EFE9), // warm white
  ];

  static final math.Random _rng = math.Random();

  void ensureInit(Size size) {
    if (size == _size && stars.isNotEmpty) return;
    _size = size;
    stars
      ..clear()
      ..addAll(List.generate(_count, (_) => _makeStar(size, initial: true)));
  }

  _Star _makeStar(Size size, {required bool initial}) {
    final s = _Star();
    _reset(s, size, initial: initial);
    return s;
  }

  void _reset(_Star s, Size size, {required bool initial}) {
    s.x = (_rng.nextDouble() * 2 - 1) * size.width;
    s.y = (_rng.nextDouble() * 2 - 1) * size.height;
    s.z = initial
        ? _rng.nextDouble() * size.width + _focal
        : size.width + _focal;
    s.speed = 8 + _rng.nextDouble() * 13;
    s.color = _palette[_rng.nextInt(_palette.length)];
    s.size = 0.6 + _rng.nextDouble() * 1.7;
  }

  void update(double dt) {
    if (_size == Size.zero) return;
    final step = dt * 60; // normalize to 60fps "units"
    for (final s in stars) {
      s.z -= s.speed * step;
      if (s.z < _focal * 0.5) {
        _reset(s, _size, initial: false);
      }
    }
    notifyListeners();
  }
}

class _WarpPainter extends CustomPainter {
  _WarpPainter(this.field) : super(repaint: field);
  final _StarField field;

  @override
  void paint(Canvas canvas, Size size) {
    field.ensureInit(size);
    final cx = size.width * 0.5;
    final cy = size.height * 0.42;
    const focal = _StarField._focal;

    final paint = Paint()
      ..blendMode = BlendMode.plus
      ..strokeCap = StrokeCap.round;

    for (final s in field.stars) {
      // Fixed streak length per frame — keeps trails consistent across refresh
      // rates (120Hz phones would otherwise draw very short stubs).
      final pz = s.z + s.speed * 1.4;
      final k = focal / s.z;
      final pk = focal / pz;
      final sx = cx + s.x * k;
      final sy = cy + s.y * k;
      final px = cx + s.x * pk;
      final py = cy + s.y * pk;

      if (sx < -40 || sx > size.width + 40 || sy < -40 || sy > size.height + 40) {
        continue;
      }

      final depth = 1 - s.z / (size.width + focal);
      final lw = math.max(0.5, s.size * depth * 2.6);
      final alpha = math.min(1.0, depth * 1.25) * 0.9;

      paint
        ..strokeWidth = lw
        ..color = s.color.withValues(alpha: alpha);
      canvas.drawLine(Offset(px, py), Offset(sx, sy), paint);
    }
  }

  @override
  bool shouldRepaint(_WarpPainter old) => false;
}

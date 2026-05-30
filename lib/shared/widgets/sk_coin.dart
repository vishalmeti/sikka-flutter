import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Animated gold Sikka coin, tilted toward the camera with a gentle bob +
/// drift. The face carries the Devanagari "स" glyph with an inner ring, a
/// sweeping specular sheen, and a top-left highlight. Reusable as the
/// welcome hero, the loading screen's centerpiece, or any "branded waiting
/// moment" in the product.
class SkCoin extends StatefulWidget {
  const SkCoin({super.key, this.size = 236});

  final double size;

  @override
  State<SkCoin> createState() => _SkCoinState();
}

class _SkCoinState extends State<SkCoin>
    with TickerProviderStateMixin {
  late final AnimationController _bob;
  late final AnimationController _drift;
  late final AnimationController _sheen;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6500),
    )..repeat();
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    )..repeat();
    _sheen = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    )..repeat();
  }

  @override
  void dispose() {
    _bob.dispose();
    _drift.dispose();
    _sheen.dispose();
    super.dispose();
  }

  // 0 → 1 → 0 sinusoidal oscillation
  double _swing(double t) => 0.5 - 0.5 * math.cos(t * 2 * math.pi);

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final boxSize = size * 1.4;

    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bob, _drift, _sheen]),
        builder: (context, _) {
          final bobT = _swing(_bob.value);
          final driftT = _swing(_drift.value);

          final bobY = _lerp(8, -14, bobT);
          final rx = _lerp(58, 54, driftT) * math.pi / 180;
          final rz = _lerp(-7, 6, driftT) * math.pi / 180;
          final ry = _lerp(-9, 8, driftT) * math.pi / 180;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Soft glow halo
              IgnorePointer(child: _HaloGlow(size: size)),
              // Ground shadow (stays flat, doesn't tilt with the disc)
              Positioned(
                bottom: boxSize * 0.10,
                child: IgnorePointer(child: _GroundShadow(width: size * 1.05)),
              ),
              // Bob + tilted, drifting disc
              Transform.translate(
                offset: Offset(0, bobY),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0014)
                    ..rotateX(rx)
                    ..rotateZ(rz)
                    ..rotateY(ry),
                  child: _CoinDisc(size: size, sheenT: _sheen.value),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}

class _HaloGlow extends StatelessWidget {
  const _HaloGlow({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        width: size * 1.5,
        height: size * 1.1,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [AppColors.goldDim, Color(0x00000000)],
            stops: [0.0, 0.64],
          ),
        ),
      ),
    );
  }
}

class _GroundShadow extends StatelessWidget {
  const _GroundShadow({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 10),
      child: Container(
        width: width,
        height: width * 0.30,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xB3000000), Color(0x00000000)],
            stops: [0.0, 0.72],
          ),
        ),
      ),
    );
  }
}

class _CoinDisc extends StatelessWidget {
  const _CoinDisc({required this.size, required this.sheenT});

  final double size;
  final double sheenT;

  static const int _layers = 14; // stacked rim slices that simulate thickness
  static const double _thickness = 24; // px depth of the disc

  @override
  Widget build(BuildContext context) {
    // The thickness layers stack from the back of the disc (deepest z, darkest)
    // forward to the face. Each layer is a small reeded disc translated in Z.
    final stack = <Widget>[];
    for (int i = _layers - 1; i >= 0; i--) {
      final f = i / (_layers - 1); // 0 = front, 1 = back
      final z = -f * _thickness;
      final lit = 1 - f * 0.55;
      stack.add(
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..translateByDouble(0.0, 0.0, z, 1.0),
          child: CustomPaint(
            size: Size.square(size),
            painter: _ReededPainter(lit: lit),
          ),
        ),
      );
    }
    // Front rim — sits just above the stack
    stack.add(
      Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..translateByDouble(0.0, 0.0, 1.0, 1.0),
        child: CustomPaint(
          size: Size.square(size),
          painter: _ReededPainter(lit: 1.0, rimHighlight: true),
        ),
      ),
    );
    // Face
    stack.add(
      Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..translateByDouble(0.0, 0.0, 2.0, 1.0),
        child: _CoinFace(size: size - 18, sheenT: sheenT),
      ),
    );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(alignment: Alignment.center, children: stack),
    );
  }
}

class _ReededPainter extends CustomPainter {
  _ReededPainter({required this.lit, this.rimHighlight = false});

  final double lit;
  final bool rimHighlight;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // Alternating gold-light / gold-dark pie slices give the reeded
    // (milled) coin edge. 256 slices ≈ 1.4° each — matches the design spec.
    const segments = 256;
    final angleStep = 2 * math.pi / segments;
    // Start so the slices align consistently across stacked layers.
    const startOffset = -math.pi / 2;

    final hi = Color.fromARGB(
      255,
      (202 * lit).round().clamp(0, 255),
      (168 * lit).round().clamp(0, 255),
      (76 * lit).round().clamp(0, 255),
    );
    final lo = Color.fromARGB(
      255,
      (124 * lit).round().clamp(0, 255),
      (100 * lit).round().clamp(0, 255),
      (40 * lit).round().clamp(0, 255),
    );

    final paint = Paint()..style = PaintingStyle.fill;
    final rect = Rect.fromCircle(center: center, radius: radius);

    for (int i = 0; i < segments; i++) {
      paint.color = i.isEven ? hi : lo;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(rect, startOffset + i * angleStep, angleStep + 0.002, false)
        ..close();
      canvas.drawPath(path, paint);
    }

    if (rimHighlight) {
      // Subtle warm-white highlight band that sits on the front rim.
      final highlightPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0x40FFF0C8);
      canvas.drawCircle(center, radius - 0.6, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(_ReededPainter old) =>
      old.lit != lit || old.rimHighlight != rimHighlight;
}

class _CoinFace extends StatelessWidget {
  const _CoinFace({required this.size, required this.sheenT});

  final double size;
  final double sheenT;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            // Base gradient (top-left highlight → deep gold rim)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.24, -0.40),
                    radius: 0.85,
                    colors: [
                      Color(0xFFF6E29A),
                      Color(0xFFE6C66A),
                      Color(0xFFC9A84C),
                      Color(0xFF9A7E36),
                      Color(0xFF7D6429),
                    ],
                    stops: [0.0, 0.26, 0.56, 0.82, 1.0],
                  ),
                  border: Border.fromBorderSide(
                    BorderSide(color: Color(0x807C6428), width: 2),
                  ),
                ),
              ),
            ),
            // Bottom rim darkening (approximates the inset shadow at the base)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(0, 0.7),
                      radius: 0.85,
                      colors: const [Color(0x00000000), Color(0x8C3C2C0C)],
                      stops: const [0.55, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // Inner ring detail
            Padding(
              padding: EdgeInsets.all(size * 0.12),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0x73796428),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            // Embossed स glyph
            Center(
              child: Text(
                'स',
                style: TextStyle(
                  fontFamily: AppTypography.fontMono,
                  fontSize: size * 0.46,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8A6C26),
                  letterSpacing: -1,
                  height: 1,
                  shadows: const [
                    Shadow(
                      color: Color(0x8CFFF5CD),
                      offset: Offset(0, 1.5),
                    ),
                    Shadow(
                      color: Color(0x80322408),
                      offset: Offset(0, -1),
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            // Top-left highlight blob
            Positioned(
              left: size * 0.14,
              top: size * 0.10,
              width: size * 0.46,
              height: size * 0.34,
              child: IgnorePointer(
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0x99FFFAE4), Color(0x00000000)],
                        stops: [0.0, 0.70],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Moving specular sheen
            Positioned.fill(
              child: IgnorePointer(child: _Sheen(size: size, t: sheenT)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sheen extends StatelessWidget {
  const _Sheen({required this.size, required this.t});

  final double size;
  final double t;

  @override
  Widget build(BuildContext context) {
    final sheenWidth = size * 0.46;
    // -130% to 230% of own width, mapped to parent-relative x.
    final translateX = sheenWidth * (-1.3 + 3.6 * t);
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Stack(
        children: [
          Positioned(
            left: translateX,
            top: 0,
            width: sheenWidth,
            height: size,
            child: Transform.rotate(
              angle: 8 * math.pi / 180,
              alignment: Alignment.center,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0x00000000),
                      Color(0x8CFFFAE1),
                      Color(0x00000000),
                    ],
                  ),
                  backgroundBlendMode: BlendMode.screen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

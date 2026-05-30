import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// A "living" gold medallion for the You screen.
///
/// Layers (back → front):
///   • Pulsing radial glow halo
///   • Static dashed outer orbit circle
///   • Tier-progress arc (open ring)
///   • Three small "S" coins orbiting on the dashed ring at independent phases
///   • Central gold coin with the member's initials
///
/// Idle motion: subtle breathing (scale), gentle Y bob, and a slow orbit
/// rotation. Tap the central coin to fire a spring + a "+1" riser.
class LivingAvatar extends StatefulWidget {
  const LivingAvatar({
    super.key,
    required this.initials,
    this.tier = 'gold',
    this.progress = 1.0,
    this.size = 240,
  });

  final String initials;
  final String tier;
  final double progress;
  final double size;

  @override
  State<LivingAvatar> createState() => _LivingAvatarState();
}

class _LivingAvatarState extends State<LivingAvatar>
    with TickerProviderStateMixin {
  late final AnimationController _breath;
  late final AnimationController _bob;
  late final AnimationController _orbit;
  late final AnimationController _glow;
  late final AnimationController _tap;

  final List<_Riser> _risers = [];
  int _riserSeq = 0;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat(reverse: true);
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5400),
    )..repeat(reverse: true);
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 14000),
    )..repeat();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
    _tap = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      lowerBound: 0,
      upperBound: 1,
    );
  }

  @override
  void dispose() {
    _breath.dispose();
    _bob.dispose();
    _orbit.dispose();
    _glow.dispose();
    _tap.dispose();
    for (final r in _risers) {
      r.controller.dispose();
    }
    _risers.clear();
    super.dispose();
  }

  void _onTap() {
    _tap.forward(from: 0);
    final id = _riserSeq++;
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    final riser = _Riser(id: id, controller: ctrl);
    setState(() => _risers.add(riser));
    ctrl.forward();
    ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        ctrl.dispose();
        if (mounted) setState(() => _risers.removeWhere((r) => r.id == id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final color = AppColors.tierColor(widget.tier);

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_breath, _bob, _orbit, _glow, _tap]),
        builder: (context, _) {
          final breathT = Curves.easeInOut.transform(_breath.value);
          final bobT = Curves.easeInOut.transform(_bob.value);
          final glowT = Curves.easeInOut.transform(_glow.value);
          final tapT = _tap.value;
          // Spring: quick out, easy settle
          final tapScale = 1 +
              (tapT < 0.45
                      ? Curves.easeOutCubic.transform(tapT / 0.45) * 0.08
                      : (1 - Curves.easeOutCubic.transform((tapT - 0.45) / 0.55)) *
                          0.08);

          final breathScale = 1 + 0.025 * breathT;
          final bobY = (bobT - 0.5) * 8;
          final glowAlpha = 0.45 + 0.35 * glowT;
          final tapGlow = (1 - tapT).clamp(0.0, 1.0) * tapT * 4; // 0→1→0 spike

          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing radial glow halo
              IgnorePointer(
                child: Opacity(
                  opacity: glowAlpha,
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Container(
                      width: size * 0.92,
                      height: size * 0.92,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [AppColors.goldDim, Color(0x00000000)],
                          stops: [0.0, 0.72],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Tap-flash glow
              if (tapGlow > 0.01)
                IgnorePointer(
                  child: Opacity(
                    opacity: (tapGlow * 0.4).clamp(0.0, 0.6),
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        width: size * 0.82,
                        height: size * 0.82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [color.withValues(alpha: 0.7), const Color(0x00000000)],
                            stops: const [0.0, 0.7],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // Dashed outer orbit
              CustomPaint(
                size: Size.square(size),
                painter: _DashedRingPainter(
                  color: color.withValues(alpha: 0.35),
                  radius: size * 0.46,
                ),
              ),
              // Tier-progress open ring
              CustomPaint(
                size: Size.square(size),
                painter: _ProgressArcPainter(
                  color: color,
                  trackColor: AppColors.border,
                  radius: size * 0.36,
                  progress: widget.progress.clamp(0.0, 1.0),
                ),
              ),
              // Orbiting mini coins (back → front by Z position)
              ..._buildOrbitCoins(size, color),
              // Center coin with breathing + bob + tap spring
              Transform.translate(
                offset: Offset(0, bobY),
                child: Transform.scale(
                  scale: breathScale * tapScale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _onTap,
                    child: _CenterCoin(
                      size: size * 0.55,
                      initials: widget.initials,
                    ),
                  ),
                ),
              ),
              // Risers
              ..._risers.map((r) => _RiserView(controller: r.controller, color: color)),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildOrbitCoins(double size, Color color) {
    // Three coins, evenly distributed in phase but at different orbit radii
    // and speeds so they don't feel mechanically symmetrical.
    final orbitT = _orbit.value;
    final base = orbitT * 2 * math.pi;
    final radius = size * 0.46;
    final radiusInner = size * 0.43;
    final coins = [
      _OrbitSpec(phase: base, radius: radius, dy: 0, miniSize: 18),
      _OrbitSpec(
        phase: base * 0.82 + math.pi * 0.66,
        radius: radiusInner,
        dy: 0,
        miniSize: 16,
      ),
      _OrbitSpec(
        phase: -base * 1.1 + math.pi * 1.33,
        radius: radius,
        dy: 0,
        miniSize: 17,
      ),
    ];

    return [
      for (final c in coins)
        Transform.translate(
          offset: Offset(
            math.cos(c.phase) * c.radius,
            math.sin(c.phase) * c.radius + c.dy,
          ),
          child: _MiniCoin(size: c.miniSize, color: color),
        ),
    ];
  }
}

class _OrbitSpec {
  const _OrbitSpec({
    required this.phase,
    required this.radius,
    required this.dy,
    required this.miniSize,
  });

  final double phase;
  final double radius;
  final double dy;
  final double miniSize;
}

class _Riser {
  _Riser({required this.id, required this.controller});

  final int id;
  final AnimationController controller;
}

class _RiserView extends StatelessWidget {
  const _RiserView({required this.controller, required this.color});

  final AnimationController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        final eased = Curves.easeOutCubic.transform(t);
        final opacity = (1 - t).clamp(0.0, 1.0);
        return IgnorePointer(
          child: Transform.translate(
            offset: Offset(0, -40 * eased - 20),
            child: Opacity(
              opacity: opacity,
              child: Text(
                '+1',
                style: TextStyle(
                  fontFamily: AppTypography.fontMono,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CenterCoin extends StatelessWidget {
  const _CenterCoin({required this.size, required this.initials});

  final double size;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer rim
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.22, -0.35),
                radius: 0.95,
                colors: [
                  Color(0xFFF6E29A),
                  Color(0xFFE6C66A),
                  Color(0xFFC9A84C),
                  Color(0xFF8C7232),
                ],
                stops: [0.0, 0.32, 0.66, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
              border: Border.fromBorderSide(
                BorderSide(color: Color(0xFF7C6428), width: 1.5),
              ),
            ),
          ),
          // Inner face inset
          Padding(
            padding: EdgeInsets.all(size * 0.08),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.2, -0.35),
                  radius: 0.95,
                  colors: [
                    Color(0xFFEBCE76),
                    Color(0xFFD2AC4E),
                    Color(0xFF9D7C2E),
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
                border: Border.fromBorderSide(
                  BorderSide(color: Color(0x66785A1E), width: 1),
                ),
              ),
            ),
          ),
          // Top-left highlight blob
          Positioned(
            left: size * 0.14,
            top: size * 0.10,
            width: size * 0.44,
            height: size * 0.30,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0xB3FFFAE4), Color(0x00000000)],
                      stops: [0.0, 0.72],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bottom inset shadow
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(0, 0.75),
                    radius: 0.9,
                    colors: const [Color(0x00000000), Color(0x77382808)],
                    stops: const [0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Initials
          Text(
            initials,
            style: TextStyle(
              fontFamily: AppTypography.fontMono,
              fontSize: size * 0.32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF3A2C0C),
              letterSpacing: -1,
              height: 1,
              shadows: const [
                Shadow(
                  color: Color(0x80FFF1C8),
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCoin extends StatelessWidget {
  const _MiniCoin({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.4),
          radius: 0.9,
          colors: [
            Color(0xFFF6E29A),
            Color(0xFFD2AC4E),
            Color(0xFF8C7232),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x55000000),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.fromBorderSide(
          BorderSide(color: color.withValues(alpha: 0.5), width: 0.6),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        'S',
        style: TextStyle(
          fontFamily: AppTypography.fontMono,
          fontSize: size * 0.5,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF3A2C0C),
          height: 1,
        ),
      ),
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  _DashedRingPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    const segments = 56;
    const gapRatio = 0.5;
    final step = 2 * math.pi / segments;
    final arcLen = step * (1 - gapRatio);
    for (int i = 0; i < segments; i++) {
      final start = i * step;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        arcLen,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) =>
      old.color != color || old.radius != radius;
}

class _ProgressArcPainter extends CustomPainter {
  _ProgressArcPainter({
    required this.color,
    required this.trackColor,
    required this.radius,
    required this.progress,
  });

  final Color color;
  final Color trackColor;
  final double radius;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(center, radius, track);

    final fg = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 3 / 2,
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.85),
          color,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Leave a small gap to feel like an "open" ring even at full progress.
    final sweep = (2 * math.pi - 0.45) * progress;
    canvas.drawArc(rect, -math.pi / 2 + 0.05, sweep, false, fg);
  }

  @override
  bool shouldRepaint(_ProgressArcPainter old) =>
      old.color != color ||
      old.trackColor != trackColor ||
      old.radius != radius ||
      old.progress != progress;
}

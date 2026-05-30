import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';

class HeroBalanceCard extends StatefulWidget {
  const HeroBalanceCard({
    super.key,
    this.coins = 0,
    this.progress = 0,
    this.redeemRate = 2,
  });

  final int coins;

  /// Progress toward the next tier, 0..1.
  final double progress;

  /// Coins per ₹1 (backend REDEEM_RATE). Rupee value = coins / redeemRate.
  final double redeemRate;

  @override
  State<HeroBalanceCard> createState() => _HeroBalanceCardState();
}

class _HeroBalanceCardState extends State<HeroBalanceCard>
    with SingleTickerProviderStateMixin {
  // Lazy-initialized so hot reload across field changes stays safe.
  late final AnimationController _beam = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  int _displayedFrom = 0;

  @override
  void didUpdateWidget(covariant HeroBalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coins != widget.coins) {
      _displayedFrom = oldWidget.coins;
    }
  }

  @override
  void dispose() {
    _beam.dispose();
    super.dispose();
  }

  int get _rupeeValue =>
      widget.redeemRate > 0 ? (widget.coins / widget.redeemRate).floor() : 0;

  String _progressLabel(double progress) => progress >= 1
      ? 'Top tier reached'
      : '${(progress * 100).round()}% to next tier';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Static radial gold glow (centered, circular).
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.54,
                    colors: [
                      AppColors.goldDim.withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Ring + rotating sweep beam (animates with progress + spin).
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: widget.progress.clamp(0, 1)),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, animatedProgress, __) {
              return AnimatedBuilder(
                animation: _beam,
                builder: (_, __) {
                  return SizedBox(
                    width: 300,
                    height: 300,
                    child: CustomPaint(
                      painter: _RingPainter(
                        progress: animatedProgress,
                        beamAngle: _beam.value * 2 * math.pi,
                        color: AppColors.gold,
                        bgColor: AppColors.border,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // Content.
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SkLabel('Total Sikka Balance'),
              const SizedBox(height: 16),
              TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: _displayedFrom.toDouble(),
                  end: widget.coins.toDouble(),
                ),
                duration: const Duration(milliseconds: 1100),
                curve: Curves.easeOutCubic,
                builder: (_, value, __) {
                  return SkBigNumber(
                    fmtNumber(value.round()),
                    size: 68,
                    color: AppColors.gold,
                    shadows: [
                      Shadow(color: AppColors.goldDim, blurRadius: 24),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: widget.progress.clamp(0, 1)),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, animatedProgress, __) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '≈ ${fmtRupee(_rupeeValue)}',
                        style: AppTypography.mono,
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                      Text(
                        _progressLabel(animatedProgress),
                        style: AppTypography.mono,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Paints the balance ring: base circle, glow halo, progress arc, and a
/// rotating "comet head" beam that travels along the ring.
class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.beamAngle,
    required this.color,
    required this.bgColor,
  });

  final double progress;
  final double beamAngle;
  final Color color;
  final Color bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Soft outer glow halo.
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius, glowPaint);

    // 2. Base ring (faint background).
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, bgPaint);

    // 3. Crisp progress arc.
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );

    // 4. Rotating beam — a bright hot spot that travels along the ring.
    final beamPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        transform: GradientRotation(beamAngle - math.pi / 2),
        colors: [
          Colors.transparent,
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.35),
          color.withValues(alpha: 0.95),
          color.withValues(alpha: 0.35),
          color.withValues(alpha: 0.0),
          Colors.transparent,
        ],
        stops: const [0.0, 0.78, 0.88, 0.92, 0.96, 0.99, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center, radius, beamPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      progress != old.progress || beamAngle != old.beamAngle;
}

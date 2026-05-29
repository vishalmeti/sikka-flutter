import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';

class HeroBalanceCard extends StatefulWidget {
  const HeroBalanceCard({
    super.key,
    this.coins = 1247,
    this.monthlyProgress = 0.68,
  });

  final int coins;
  final double monthlyProgress;

  @override
  State<HeroBalanceCard> createState() => _HeroBalanceCardState();
}

class _HeroBalanceCardState extends State<HeroBalanceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

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
          // Radial gold glow
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.6,
                    colors: [AppColors.goldDim, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          // Shimmer band
          Positioned(
            left: -20,
            right: -20,
            top: 60,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.goldFaint,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Revolving progress arc
          RotationTransition(
            turns: _spin,
            child: SizedBox(
              width: 300,
              height: 300,
              child: CustomPaint(
                painter: _ProgressArcPainter(
                  progress: widget.monthlyProgress,
                  color: AppColors.gold,
                  bgColor: AppColors.border,
                ),
              ),
            ),
          ),
          // Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SkLabel('Total Sikka Balance'),
              const SizedBox(height: 16),
              SkBigNumber(
                fmtNumber(widget.coins),
                size: 68,
                color: AppColors.gold,
                shadows: [
                  Shadow(color: AppColors.goldDim, blurRadius: 24),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '≈ ${fmtRupee((widget.coins * 0.2).floor())}',
                    style: AppTypography.mono,
                  ),
                  Text(
                    ' • ',
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                  Text(
                    '${(widget.monthlyProgress * 100).round()}% of monthly target',
                    style: AppTypography.mono,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressArcPainter extends CustomPainter {
  _ProgressArcPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  final double progress;
  final Color color;
  final Color bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressArcPainter old) => progress != old.progress;
}

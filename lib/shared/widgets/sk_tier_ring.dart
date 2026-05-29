import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class SkTierRing extends StatelessWidget {
  const SkTierRing({
    super.key,
    required this.tier,
    this.size = 44,
    this.progress = 1.0,
    this.child,
  });

  final String tier;
  final double size;
  final double progress;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.tierColor(tier);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              color: color,
              progress: progress,
              borderColor: AppColors.border,
            ),
          ),
          if (child != null)
            child!
          else
            Text(
              tier[0].toUpperCase(),
              style: TextStyle(
                fontFamily: AppTypography.fontMono,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.color,
    required this.progress,
    required this.borderColor,
  });

  final Color color;
  final double progress;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final bgPaint = Paint()
      ..color = borderColor
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
  bool shouldRepaint(_RingPainter oldDelegate) =>
      color != oldDelegate.color || progress != oldDelegate.progress;
}

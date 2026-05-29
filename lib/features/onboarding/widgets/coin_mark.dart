import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class CoinMark extends StatelessWidget {
  const CoinMark({super.key, this.size = 84});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.goldDim, Colors.transparent],
                radius: 0.65,
              ),
            ),
          ),
          CustomPaint(
            size: Size(size, size),
            painter: _CoinMarkPainter(),
          ),
          Text(
            'स',
            style: TextStyle(
              fontFamily: AppTypography.fontMono,
              fontSize: size * 0.21,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke;

    paint
      ..strokeWidth = 1.2
      ..color = AppColors.gold.withValues(alpha: 0.4);
    canvas.drawCircle(center, size.width * 0.458, paint);

    paint
      ..strokeWidth = 1.4
      ..color = AppColors.gold.withValues(alpha: 0.7);
    canvas.drawCircle(center, size.width * 0.354, paint);

    paint
      ..strokeWidth = 1.6
      ..color = AppColors.gold;
    canvas.drawCircle(center, size.width * 0.229, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

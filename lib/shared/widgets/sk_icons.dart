import 'package:flutter/material.dart';

enum SkIconData {
  home,
  scan,
  wallet,
  user,
  flame,
  coin,
  arrowUp,
  arrowDown,
  chevronRight,
  chevronDown,
  check,
  lock,
  bell,
  plus,
  trophy,
  zap,
  store,
  qr,
  close,
  flash,
  gallery,
  back,
  share,
  sms,
  mail,
  more,
  whatsapp,
  copy,
  search,
  chart,
}

class SkIcon extends StatelessWidget {
  const SkIcon(this.icon, {super.key, this.size = 22, this.color});

  final SkIconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? Colors.white;
    return CustomPaint(
      size: Size(size, size),
      painter: _SkIconPainter(icon: icon, color: c),
    );
  }
}

class _SkIconPainter extends CustomPainter {
  _SkIconPainter({required this.icon, required this.color});

  final SkIconData icon;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.width;
    final scale = s / 24.0;

    canvas.save();
    canvas.scale(scale, scale);

    switch (icon) {
      case SkIconData.home:
        final path = Path()
          ..moveTo(3.5, 11)
          ..lineTo(12, 4)
          ..lineTo(20.5, 11)
          ..lineTo(20.5, 20)
          ..cubicTo(20.5, 20.55, 20.05, 21, 19.5, 21)
          ..lineTo(14.5, 21)
          ..lineTo(14.5, 14)
          ..lineTo(9.5, 14)
          ..lineTo(9.5, 21)
          ..lineTo(4.5, 21)
          ..cubicTo(3.95, 21, 3.5, 20.55, 3.5, 20)
          ..close();
        canvas.drawPath(path, paint);

      case SkIconData.scan:
        _drawScanIcon(canvas, paint);

      case SkIconData.wallet:
        final path = Path()
          ..moveTo(3, 7)
          ..lineTo(18, 7)
          ..cubicTo(19.1, 7, 20, 7.9, 20, 9)
          ..lineTo(20, 18)
          ..cubicTo(20, 19.1, 19.1, 20, 18, 20)
          ..lineTo(5, 20)
          ..cubicTo(3.9, 20, 3, 19.1, 3, 18)
          ..lineTo(3, 7)
          ..close();
        canvas.drawPath(path, paint);
        final path2 = Path()
          ..moveTo(3, 7)
          ..lineTo(5, 4)
          ..lineTo(16, 4)
          ..lineTo(18, 7);
        canvas.drawPath(path2, paint);
        canvas.drawCircle(
          const Offset(16, 13.5),
          1.2,
          paint..style = PaintingStyle.fill,
        );
        paint.style = PaintingStyle.stroke;

      case SkIconData.user:
        canvas.drawCircle(const Offset(12, 8), 4, paint);
        final path = Path()
          ..moveTo(4, 21)
          ..cubicTo(5.5, 17, 8.5, 15, 12, 15)
          ..cubicTo(15.5, 15, 18.5, 17, 20, 21);
        canvas.drawPath(path, paint);

      case SkIconData.flame:
        paint.style = PaintingStyle.fill;
        final path = Path()
          ..moveTo(12, 2)
          ..cubicTo(12, 2, 11, 5, 9, 7)
          ..cubicTo(7, 9, 6, 10, 6, 14)
          ..cubicTo(6, 17.31, 8.69, 20, 12, 20)
          ..cubicTo(15.31, 20, 18, 17.31, 18, 14)
          ..cubicTo(18, 12, 17, 10.5, 15.5, 9)
          ..cubicTo(13, 7.5, 13, 5.5, 12, 2)
          ..close();
        canvas.drawPath(path, paint);
        paint.style = PaintingStyle.stroke;

      case SkIconData.coin:
        canvas.drawCircle(const Offset(12, 12), 9, paint..strokeWidth = 1.4);
        canvas.drawCircle(
          const Offset(12, 12),
          6,
          paint..color = color.withValues(alpha: 0.5),
        );
        paint.color = color;

      case SkIconData.arrowUp:
        final path = Path()
          ..moveTo(7, 17)
          ..lineTo(17, 7);
        canvas.drawPath(path, paint);
        final path2 = Path()
          ..moveTo(9, 7)
          ..lineTo(17, 7)
          ..lineTo(17, 15);
        canvas.drawPath(path2, paint);

      case SkIconData.arrowDown:
        final path = Path()
          ..moveTo(7, 7)
          ..lineTo(17, 17);
        canvas.drawPath(path, paint);
        final path2 = Path()
          ..moveTo(7, 15)
          ..lineTo(7, 7)
          ..lineTo(15, 7);
        canvas.drawPath(path2, paint);

      case SkIconData.chevronRight:
        final path = Path()
          ..moveTo(9, 5)
          ..lineTo(16, 12)
          ..lineTo(9, 19);
        canvas.drawPath(path, paint);

      case SkIconData.chevronDown:
        final path = Path()
          ..moveTo(5, 9)
          ..lineTo(12, 16)
          ..lineTo(19, 9);
        canvas.drawPath(path, paint);

      case SkIconData.check:
        paint.strokeWidth = 2;
        final path = Path()
          ..moveTo(4, 12)
          ..lineTo(9, 17)
          ..lineTo(20, 6);
        canvas.drawPath(path, paint);

      case SkIconData.lock:
        canvas.drawRRect(
          RRect.fromLTRBR(5, 11, 19, 20, const Radius.circular(1.5)),
          paint,
        );
        final path = Path()
          ..moveTo(8, 11)
          ..lineTo(8, 7)
          ..cubicTo(8, 4.79, 9.79, 3, 12, 3)
          ..cubicTo(14.21, 3, 16, 4.79, 16, 7)
          ..lineTo(16, 11);
        canvas.drawPath(path, paint);

      case SkIconData.bell:
        final path = Path()
          ..moveTo(6, 9)
          ..cubicTo(6, 5.69, 8.69, 3, 12, 3)
          ..cubicTo(15.31, 3, 18, 5.69, 18, 9)
          ..lineTo(18, 13)
          ..lineTo(20, 16)
          ..lineTo(4, 16)
          ..lineTo(6, 13)
          ..close();
        canvas.drawPath(path, paint);
        final path2 = Path()
          ..moveTo(10, 19)
          ..cubicTo(10, 20.1, 10.9, 21, 12, 21)
          ..cubicTo(13.1, 21, 14, 20.1, 14, 19);
        canvas.drawPath(path2, paint);

      case SkIconData.plus:
        paint.strokeWidth = 1.8;
        canvas.drawLine(const Offset(12, 5), const Offset(12, 19), paint);
        canvas.drawLine(const Offset(5, 12), const Offset(19, 12), paint);

      case SkIconData.trophy:
        paint.strokeWidth = 1.5;
        final path = Path()
          ..moveTo(8, 4)
          ..lineTo(16, 4)
          ..lineTo(16, 10)
          ..cubicTo(16, 12.21, 14.21, 14, 12, 14)
          ..cubicTo(9.79, 14, 8, 12.21, 8, 10)
          ..close();
        canvas.drawPath(path, paint);
        canvas.drawLine(const Offset(9, 18), const Offset(15, 18), paint);
        canvas.drawLine(const Offset(10, 15), const Offset(10, 18), paint);
        canvas.drawLine(const Offset(14, 15), const Offset(14, 18), paint);

      case SkIconData.zap:
        paint.style = PaintingStyle.fill;
        final path = Path()
          ..moveTo(13, 2)
          ..lineTo(4, 14)
          ..lineTo(10, 14)
          ..lineTo(9, 22)
          ..lineTo(18, 10)
          ..lineTo(12, 10)
          ..lineTo(13, 2)
          ..close();
        canvas.drawPath(path, paint);
        paint.style = PaintingStyle.stroke;

      case SkIconData.store:
        paint.strokeWidth = 1.5;
        final path = Path()
          ..moveTo(3, 8)
          ..lineTo(5, 4)
          ..lineTo(19, 4)
          ..lineTo(21, 8)
          ..moveTo(3, 8)
          ..lineTo(3, 19)
          ..lineTo(21, 19)
          ..lineTo(21, 8)
          ..moveTo(3, 8)
          ..lineTo(21, 8)
          ..moveTo(8, 13)
          ..lineTo(11, 13)
          ..lineTo(11, 18)
          ..lineTo(8, 18)
          ..close();
        canvas.drawPath(path, paint);

      case SkIconData.close:
        canvas.drawLine(const Offset(6, 6), const Offset(18, 18), paint);
        canvas.drawLine(const Offset(18, 6), const Offset(6, 18), paint);

      case SkIconData.flash:
        final path = Path()
          ..moveTo(13, 2)
          ..lineTo(4, 14)
          ..lineTo(10, 14)
          ..lineTo(9, 22)
          ..lineTo(18, 10)
          ..lineTo(12, 10)
          ..lineTo(13, 2)
          ..close();
        canvas.drawPath(path, paint);

      case SkIconData.gallery:
        paint.strokeWidth = 1.5;
        canvas.drawRRect(
          RRect.fromLTRBR(3, 5, 21, 19, const Radius.circular(1.5)),
          paint,
        );
        canvas.drawCircle(const Offset(9, 11), 1.5, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        final path = Path()
          ..moveTo(3, 17)
          ..lineTo(8, 12)
          ..lineTo(13, 17)
          ..lineTo(16, 14)
          ..lineTo(21, 19);
        canvas.drawPath(path, paint);

      case SkIconData.back:
        final path = Path()
          ..moveTo(15, 5)
          ..lineTo(8, 12)
          ..lineTo(15, 19);
        canvas.drawPath(path, paint);

      case SkIconData.share:
        canvas.drawCircle(const Offset(6, 12), 2.5, paint);
        canvas.drawCircle(const Offset(18, 6), 2.5, paint);
        canvas.drawCircle(const Offset(18, 18), 2.5, paint);
        canvas.drawLine(const Offset(8, 11), const Offset(16, 7), paint);
        canvas.drawLine(const Offset(8, 13), const Offset(16, 17), paint);

      case SkIconData.sms:
        final path = Path()
          ..moveTo(3, 5)
          ..lineTo(21, 5)
          ..lineTo(21, 17)
          ..lineTo(8, 17)
          ..lineTo(3, 21)
          ..close();
        canvas.drawPath(path, paint);

      case SkIconData.mail:
        canvas.drawRRect(
          RRect.fromLTRBR(3, 5, 21, 19, const Radius.circular(1.5)),
          paint,
        );
        final path = Path()
          ..moveTo(3, 7)
          ..lineTo(12, 13)
          ..lineTo(21, 7);
        canvas.drawPath(path, paint);

      case SkIconData.more:
        paint.strokeWidth = 2;
        canvas.drawCircle(const Offset(5, 12), 1, paint..style = PaintingStyle.fill);
        canvas.drawCircle(const Offset(12, 12), 1, paint);
        canvas.drawCircle(const Offset(19, 12), 1, paint);
        paint.style = PaintingStyle.stroke;

      case SkIconData.whatsapp:
        final path = Path()
          ..moveTo(20, 12)
          ..cubicTo(20, 7.58, 16.42, 4, 12, 4)
          ..cubicTo(7.58, 4, 4, 7.58, 4, 12)
          ..cubicTo(4, 14.38, 4.79, 16.56, 6.16, 18.28)
          ..lineTo(4, 20)
          ..lineTo(7.72, 18.6);
        canvas.drawPath(path, paint);

      case SkIconData.copy:
        canvas.drawRRect(
          RRect.fromLTRBR(9, 9, 20, 20, const Radius.circular(2)),
          paint,
        );
        final path = Path()
          ..moveTo(5, 15)
          ..lineTo(5, 5)
          ..cubicTo(5, 4.45, 5.45, 4, 6, 4)
          ..lineTo(15, 4);
        canvas.drawPath(path, paint);

      case SkIconData.qr:
        paint.strokeWidth = 1.5;
        canvas.drawRect(const Rect.fromLTWH(4, 4, 6, 6), paint);
        canvas.drawRect(const Rect.fromLTWH(14, 4, 6, 6), paint);
        canvas.drawRect(const Rect.fromLTWH(4, 14, 6, 6), paint);
        canvas.drawRect(const Rect.fromLTWH(14, 14, 2, 2), paint);
        canvas.drawRect(const Rect.fromLTWH(18, 14, 2, 2), paint);
        canvas.drawRect(const Rect.fromLTWH(14, 18, 2, 2), paint);
        canvas.drawRect(const Rect.fromLTWH(18, 18, 2, 2), paint);

      case SkIconData.search:
        paint.strokeWidth = 1.7;
        canvas.drawCircle(const Offset(11, 11), 7, paint);
        canvas.drawLine(const Offset(20, 20), const Offset(16.5, 16.5), paint);

      case SkIconData.chart:
        paint.strokeWidth = 1.7;
        canvas.drawLine(const Offset(6, 14), const Offset(6, 18), paint);
        canvas.drawLine(const Offset(12, 9), const Offset(12, 18), paint);
        canvas.drawLine(const Offset(18, 5), const Offset(18, 18), paint);
    }

    canvas.restore();
  }

  void _drawScanIcon(Canvas canvas, Paint paint) {
    canvas.drawLine(const Offset(4, 8), const Offset(4, 5), paint);
    canvas.drawLine(const Offset(4, 5), const Offset(7, 5), paint);
    canvas.drawLine(const Offset(16, 4), const Offset(19, 4), paint);
    canvas.drawLine(const Offset(20, 4), const Offset(20, 7), paint);
    canvas.drawLine(const Offset(20, 16), const Offset(20, 19), paint);
    canvas.drawLine(const Offset(20, 20), const Offset(17, 20), paint);
    canvas.drawLine(const Offset(8, 20), const Offset(5, 20), paint);
    canvas.drawLine(const Offset(4, 20), const Offset(4, 17), paint);
    canvas.drawLine(const Offset(4, 12), const Offset(20, 12), paint);
  }

  @override
  bool shouldRepaint(_SkIconPainter oldDelegate) =>
      icon != oldDelegate.icon || color != oldDelegate.color;
}

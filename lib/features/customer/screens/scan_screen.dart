import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  String _amount = '235';
  bool _paid = false;
  late AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  int get _earnAmount => ((double.tryParse(_amount) ?? 0) * 0.2).round();

  void _onKeyTap(String key) {
    setState(() {
      if (key == '⌫') {
        _amount = _amount.length <= 1 ? '0' : _amount.substring(0, _amount.length - 1);
      } else if (key == '.') {
        if (!_amount.contains('.')) _amount = '${_amount.isEmpty ? '0' : _amount}.';
      } else {
        if (_amount == '0') {
          _amount = key;
        } else if (_amount.length < 7) {
          _amount += key;
        }
      }
    });
  }

  void _onPay() {
    setState(() => _paid = true);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _paid = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final num = double.tryParse(_amount) ?? 0;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Camera background simulation
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF08080C), Color(0xFF0A0A0F), Color(0xFF050507)],
                ),
              ),
            ),
          ),
          // Perspective lines overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.015,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.transparent, Colors.white, Colors.transparent],
                    stops: const [0, 0.01, 0.02, 0.03],
                    tileMode: TileMode.repeated,
                  ),
                ),
              ),
            ),
          ),
          // Gold reticle
          if (!_paid)
            Positioned(
              top: topPad + 100,
              left: 0,
              right: 0,
              child: Center(
                child: _GoldReticle(animation: _sweepController),
              ),
            ),
          // Coin burst on pay
          if (_paid)
            Positioned(
              top: topPad + 100,
              left: 0,
              right: 0,
              child: const Center(child: _CoinBurst()),
            ),
          // Top chrome
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SkTopBar(
                  leading: SkCircleButton(
                    icon: SkIconData.close,
                    bgColor: AppColors.bg.withValues(alpha: 0.6),
                    color: AppColors.text,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SkCircleButton(
                        icon: SkIconData.flash,
                        bgColor: AppColors.bg.withValues(alpha: 0.6),
                        color: AppColors.text,
                      ),
                      const SizedBox(width: 8),
                      SkCircleButton(
                        icon: SkIconData.gallery,
                        bgColor: AppColors.bg.withValues(alpha: 0.6),
                        color: AppColors.text,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const SkLabel('Point at QR code'),
              ],
            ),
          ),
          // Bottom sheet
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.92),
                border: Border.all(color: AppColors.borderHi),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x0AFFFFFF), offset: Offset(0, 1)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      width: 36,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.borderHi,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Store header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHi,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const SkIcon(SkIconData.store, size: 16, color: AppColors.gold),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SkLabel('Paying'),
                              const SizedBox(height: 3),
                              const Text(
                                'Ramesh Stores',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SkPill(
                          label: 'Gold tier',
                          color: AppColors.gold,
                          borderColor: AppColors.goldDim,
                          bgColor: AppColors.goldFaint,
                          icon: const SkIcon(SkIconData.coin, size: 10, color: AppColors.gold),
                        ),
                      ],
                    ),
                  ),
                  // Amount display
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₹',
                          style: TextStyle(
                            fontFamily: AppTypography.fontMono,
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _amount.isEmpty ? '0' : _amount,
                          style: TextStyle(
                            fontFamily: AppTypography.fontMono,
                            fontSize: 56,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                            letterSpacing: -1.5,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Earn preview
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.goldFaint,
                      border: Border.all(color: AppColors.goldDim),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SkIcon(SkIconData.coin, size: 12, color: AppColors.gold),
                        const SizedBox(width: 8),
                        Text(
                          'You\'ll earn ',
                          style: TextStyle(
                            fontFamily: AppTypography.fontMono,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gold,
                          ),
                        ),
                        Text(
                          '$_earnAmount',
                          style: TextStyle(
                            fontFamily: AppTypography.fontMono,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          ' Sikka',
                          style: TextStyle(
                            fontFamily: AppTypography.fontMono,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Numpad
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _Numpad(onTap: _onKeyTap),
                  ),
                  const SizedBox(height: 14),
                  // Pay button
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomPad + 16),
                    child: SkButton(
                      label: _paid ? '✓ Paid' : 'Pay ${fmtRupee(num.toInt())}',
                      onTap: _onPay,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldReticle extends StatelessWidget {
  const _GoldReticle({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(220, 220),
            painter: _ReticlePainter(),
          ),
          // Sweep line
          AnimatedBuilder(
            animation: animation,
            builder: (_, __) {
              final v = animation.value;
              final y = (v * 208) + 6;
              final opacity = v < 0.15 || v > 0.85 ? 0.0 : 1.0;
              return Positioned(
                left: 4,
                right: 4,
                top: y,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, AppColors.gold, Colors.transparent],
                      ),
                      boxShadow: [BoxShadow(color: AppColors.gold, blurRadius: 8)],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    const arm = 22.0;

    // Top-left
    canvas.drawLine(Offset.zero, Offset(arm, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, arm), paint);
    // Top-right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - arm, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, arm), paint);
    // Bottom-left
    canvas.drawLine(Offset(0, size.height), Offset(arm, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - arm), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - arm, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - arm), paint);
    // Center dot
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      1.5,
      paint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CoinBurst extends StatefulWidget {
  const _CoinBurst();

  @override
  State<_CoinBurst> createState() => _CoinBurstState();
}

class _CoinBurstState extends State<_CoinBurst> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_CoinParticle> _coins;

  @override
  void initState() {
    super.initState();
    final rng = math.Random();
    _coins = List.generate(14, (i) {
      final angle = (i / 14) * math.pi * 2 + rng.nextDouble() * 0.3;
      final dist = 120 + rng.nextDouble() * 80;
      return _CoinParticle(
        dx: math.cos(angle) * dist,
        dy: math.sin(angle) * dist - 40,
        size: 10 + rng.nextDouble() * 6,
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Stack(
            clipBehavior: Clip.none,
            children: _coins.map((c) {
              final t = _controller.value;
              final opacity = t < 0.15 ? t / 0.15 : 1.0 - ((t - 0.15) / 0.85);
              return Positioned(
                left: 110 + c.dx * t - c.size / 2,
                top: 110 + c.dy * t - c.size / 2,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Container(
                    width: c.size,
                    height: c.size,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.gold, blurRadius: 10),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _CoinParticle {
  const _CoinParticle({required this.dx, required this.dy, required this.size});
  final double dx, dy, size;
}

class _Numpad extends StatelessWidget {
  const _Numpad({required this.onTap});

  final ValueChanged<String> onTap;

  static const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', '⌫'];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      childAspectRatio: 2.2,
      children: _keys.map((k) {
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () => onTap(k),
            borderRadius: BorderRadius.circular(10),
            child: Center(
              child: Text(
                k,
                style: TextStyle(
                  fontFamily: AppTypography.fontMono,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

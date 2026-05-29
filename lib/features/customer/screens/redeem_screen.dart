import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';

class RedeemScreen extends StatefulWidget {
  const RedeemScreen({super.key});

  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  static const _maxCoins = 340;
  static const _coinToRupee = 0.2;
  double _coins = 200;
  bool _confirming = false;

  int get _rupees => (_coins * _coinToRupee).floor();

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Column(
            children: [
              SkTopBar(
                leading: const SkBackButton(),
                title: 'Redeem at Ramesh Stores',
                trailing: SkCircleButton(
                  icon: SkIconData.close,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Available balance
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SkLabel('Available balance'),
                            Text(
                              '${fmtNumber(_maxCoins)} Sikka = ${fmtRupee((_maxCoins * _coinToRupee).floor())}',
                              style: TextStyle(
                                fontFamily: AppTypography.fontMono,
                                fontSize: 13,
                                color: AppColors.gold,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Hero discount display
                      Container(
                        margin: const EdgeInsets.all(24),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      radius: 0.7,
                                      colors: [AppColors.tealDim, Colors.transparent],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                const SkLabel('You\'ll get a discount of'),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '₹',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontMono,
                                        fontSize: 36,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.teal,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$_rupees',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontMono,
                                        fontSize: 84,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -2,
                                        color: AppColors.teal,
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                        height: 1,
                                        shadows: [Shadow(color: AppColors.tealDim, blurRadius: 28)],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${fmtNumber(_coins.round())} Sikka',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontMono,
                                        fontSize: 13,
                                        color: AppColors.gold,
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                    const Text(' melts into ', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                                    Text(
                                      fmtRupee(_rupees),
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontMono,
                                        fontSize: 13,
                                        color: AppColors.teal,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Slider section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SkLabel('Choose amount'),
                            Row(
                              children: [50, 100, 'Max'].map((p) {
                                final val = p == 'Max' ? _maxCoins.toDouble() : (p as int).toDouble();
                                final active = _coins == val;
                                return Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: GestureDetector(
                                    onTap: () => setState(() => _coins = val),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: active ? AppColors.goldFaint : Colors.transparent,
                                        border: Border.all(
                                          color: active ? AppColors.goldDim : AppColors.border,
                                        ),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        p == 'Max' ? 'Max' : '${p} sk',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: active ? AppColors.gold : AppColors.textDim,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.gold,
                            inactiveTrackColor: AppColors.surfaceHi,
                            thumbColor: AppColors.gold,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                            overlayColor: AppColors.goldDim,
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: _coins,
                            min: 0,
                            max: _maxCoins.toDouble(),
                            divisions: _maxCoins ~/ 10,
                            onChanged: (v) => setState(() => _coins = v),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0 SIKKA', style: AppTypography.label),
                            Text('${fmtNumber(_maxCoins)} SIKKA', style: AppTypography.label),
                          ],
                        ),
                      ),
                      // Breakdown
                      Container(
                        margin: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            _breakdownRow('Sikka spent', '−${fmtNumber(_coins.round())}', AppColors.gold, true),
                            _breakdownRow('Balance after', '${fmtNumber(_maxCoins - _coins.round())} sk', AppColors.text, true),
                            _breakdownRow('Discount applied', fmtRupee(_rupees), AppColors.teal, false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: bottomPad + 6),
                child: SkButton(
                  label: 'Confirm redemption',
                  mode: SkButtonMode.teal,
                  onTap: () {
                    setState(() => _confirming = true);
                    Future.delayed(const Duration(milliseconds: 2200), () {
                      if (mounted) setState(() => _confirming = false);
                    });
                  },
                ),
              ),
            ],
          ),
          if (_confirming) const _MeltAnimation(),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, String value, Color valueColor, bool showBorder) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(bottom: BorderSide(color: AppColors.border))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textDim)),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.fontMono,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _MeltAnimation extends StatefulWidget {
  const _MeltAnimation();

  @override
  State<_MeltAnimation> createState() => _MeltAnimationState();
}

class _MeltAnimationState extends State<_MeltAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_MeltCoin> _coins;

  @override
  void initState() {
    super.initState();
    _coins = List.generate(10, (i) {
      final angle = (i / 10) * math.pi * 2;
      const r = 110.0;
      return _MeltCoin(
        x0: math.cos(angle) * r,
        y0: math.sin(angle) * r,
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value;
        final rupeeScale = t < 0.6 ? 0.0 : ((t - 0.6) / 0.15).clamp(0.0, 1.15);
        final finalScale = t > 0.75 ? 1.0 : rupeeScale;

        return Container(
          color: AppColors.bg.withValues(alpha: 0.6),
          child: Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ..._coins.asMap().entries.map((e) {
                    final c = e.value;
                    final coinT = (t * 1.2 - e.key * 0.04).clamp(0.0, 1.0);
                    final scale = coinT < 0.7 ? 1.0 - coinT * 0.8 : 0.0;
                    final x = c.x0 * (1 - coinT);
                    final y = c.y0 * (1 - coinT);
                    return Positioned(
                      left: 120 + x - 9,
                      top: 120 + y - 9,
                      child: Opacity(
                        opacity: scale.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: scale.clamp(0.0, 1.0),
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: AppColors.gold, blurRadius: 10)],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  Transform.scale(
                    scale: finalScale,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '₹',
                        style: TextStyle(
                          fontFamily: AppTypography.fontMono,
                          fontSize: 60,
                          fontWeight: FontWeight.w700,
                          color: AppColors.bg,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MeltCoin {
  const _MeltCoin({required this.x0, required this.y0});
  final double x0, y0;
}

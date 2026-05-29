import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class CreateOfferScreen extends StatefulWidget {
  const CreateOfferScreen({super.key});

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  String _type = '2x';
  int _days = 3;
  int _multiplier = 2;
  int _bonusValue = 50;
  int _spendThreshold = 500;

  int get _previewValue => switch (_type) {
        '2x' => _multiplier,
        'bonus' => _bonusValue,
        _ => _spendThreshold,
      };

  int get _reach => switch (_type) {
        '2x' => 43,
        'bonus' => 28,
        _ => 19,
      };

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
                leading: SkCircleButton(
                  icon: SkIconData.close,
                  color: AppColors.text,
                  onTap: () => Navigator.of(context).pop(),
                ),
                title: 'Create offer',
                trailing: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Save draft',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDim,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Offer type
                      _FormField(
                        label: 'Offer type',
                        child: _buildTypeToggle(),
                      ),
                      // Type-specific controls
                      if (_type == '2x')
                        _FormField(
                          label: 'Multiplier',
                          hint: '${_multiplier}× coins earned per ₹100 spend',
                          child: _buildStepper(
                            value: _multiplier,
                            suffix: '× Sikka',
                            min: 2,
                            max: 5,
                            onChanged: (v) => setState(() => _multiplier = v),
                          ),
                        ),
                      if (_type == 'bonus')
                        _FormField(
                          label: 'Bonus coins',
                          hint: 'Awarded on next visit',
                          child: _buildStepper(
                            value: _bonusValue,
                            suffix: 'Sikka',
                            min: 20,
                            max: 500,
                            onChanged: (v) => setState(() => _bonusValue = (v ~/ 10) * 10),
                          ),
                        ),
                      if (_type == 'spend')
                        _FormField(
                          label: 'Spend threshold',
                          hint: 'Get 100 bonus Sikka',
                          child: _buildStepper(
                            value: _spendThreshold,
                            suffix: '₹',
                            min: 100,
                            max: 5000,
                            onChanged: (v) => setState(() => _spendThreshold = (v ~/ 50) * 50),
                          ),
                        ),
                      // Duration
                      _FormField(
                        label: 'Duration',
                        child: _buildDurationPicker(),
                      ),
                      // Estimated reach
                      _buildReachCard(),
                      const SizedBox(height: 24),
                      // Customer preview
                      _FormField(
                        label: 'Customer preview',
                        child: _buildPreviewCard(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Publish button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: bottomPad + 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.bg.withValues(alpha: 0.94)],
                  stops: const [0, 0.3],
                ),
              ),
              child: SkButton(
                label: 'Publish offer',
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    final options = [
      ('2x', 'Multiplier', '2×'),
      ('bonus', 'Bonus', '●'),
      ('spend', 'Spend & earn', '₹+'),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: options.map((o) {
          final active = o.$1 == _type;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _type = o.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: active ? AppColors.surfaceHi : Colors.transparent,
                  border: Border.all(
                    color: active ? AppColors.borderHi : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      o.$3,
                      style: TextStyle(
                        fontFamily: AppTypography.fontMono,
                        fontSize: o.$1 == '2x' ? 18 : 15,
                        fontWeight: FontWeight.w600,
                        color: active ? AppColors.gold : AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      o.$2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                        color: active ? AppColors.text : AppColors.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStepper({
    required int value,
    required String suffix,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4, right: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: AppTypography.fontMono,
                fontSize: 17,
                color: AppColors.text,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              children: [
                TextSpan(text: '$value'),
                TextSpan(
                  text: suffix,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _stepperBtn('−', () {
                if (value > min) onChanged(value - 1);
              }, false),
              const SizedBox(width: 2),
              _stepperBtn('+', () {
                if (value < max) onChanged(value + 1);
              }, true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepperBtn(String label, VoidCallback onTap, bool isPrimary) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.gold : AppColors.surfaceHi,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: isPrimary ? AppColors.bg : AppColors.text,
          ),
        ),
      ),
    );
  }

  Widget _buildDurationPicker() {
    final options = [
      (1, '1 day'),
      (3, '3 days'),
      (7, '1 week'),
      (30, '1 month'),
    ];

    return Row(
      children: options.map((o) {
        final active = o.$1 == _days;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: o.$1 == 30 ? 0 : 6),
            child: GestureDetector(
              onTap: () => setState(() => _days = o.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: active ? AppColors.goldFaint : AppColors.surface,
                  border: Border.all(
                    color: active ? AppColors.goldDim : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  o.$2,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: active ? AppColors.gold : AppColors.textDim,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReachCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkLabel('Estimated reach'),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  SkBigNumber('$_reach', size: 26),
                  const SizedBox(width: 5),
                  const Text(
                    'regulars notified',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ],
          ),
          // Avatar pile
          SizedBox(
            width: 120,
            height: 28,
            child: Stack(
              children: ['AM', 'PS', 'RS', 'DK', '+'].asMap().entries.map((e) {
                final i = e.key;
                final s = e.value;
                return Positioned(
                  left: i * 20.0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: s == '+'
                          ? AppColors.surfaceHi
                          : [AppColors.goldDim, AppColors.tealDim, AppColors.surfaceHi, AppColors.surfaceHi][i],
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bg, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      s == '+' ? '+${_reach - 4}' : s,
                      style: TextStyle(
                        fontFamily: AppTypography.fontMono,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    final (title, sub) = switch (_type) {
      '2x' => ('${_previewValue}× Sikka on every spend', 'Ramesh Stores · ends in ${_days}d'),
      'bonus' => ('Bonus $_previewValue Sikka on next visit', 'Ramesh Stores · ends in ${_days}d'),
      _ => ('Spend ₹$_previewValue → earn 100 bonus Sikka', 'Ramesh Stores · ends in ${_days}d'),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topLeft,
                    radius: 0.7,
                    colors: [AppColors.goldDim, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.goldFaint,
                  border: Border.all(color: AppColors.goldDim),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: const SkIcon(SkIconData.zap, size: 18, color: AppColors.gold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SkLabel('Live', color: AppColors.gold),
                        Container(
                          width: 2,
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.muted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Text(
                          'just now',
                          style: TextStyle(fontSize: 11, color: AppColors.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      sub,
                      style: const TextStyle(fontSize: 12, color: AppColors.textDim),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({required this.label, this.hint, required this.child});

  final String label;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkLabel(label),
              if (hint != null)
                Text(
                  hint!,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

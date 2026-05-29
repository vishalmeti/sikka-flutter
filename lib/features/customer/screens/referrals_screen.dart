import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';

class _Referral {
  const _Referral(this.name, this.phone, this.status, this.when, this.reward);
  final String name, phone, status, when;
  final int reward;
}

class ReferralsScreen extends StatefulWidget {
  const ReferralsScreen({super.key});

  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen> {
  String _filter = 'all';
  bool _copied = false;

  static const _referrals = [
    _Referral('Priya Mehta', '+91 98••• ••42', 'paid', 'Yesterday', 200),
    _Referral('Vikram Singh', '+91 98••• ••18', 'paid', '3 days ago', 200),
    _Referral('Neha Krishnan', '+91 98••• ••07', 'signed', '4 days ago', 0),
    _Referral('Rohan Iyer', '+91 98••• ••91', 'signed', '6 days ago', 0),
    _Referral('Anjali Desai', '+91 98••• ••55', 'invited', 'Last week', 0),
    _Referral('Karan Sharma', '+91 98••• ••03', 'paid', '2 weeks ago', 200),
  ];

  List<_Referral> get _filtered {
    switch (_filter) {
      case 'pending':
        return _referrals.where((r) => r.status != 'paid').toList();
      case 'paid':
        return _referrals.where((r) => r.status == 'paid').toList();
      default:
        return _referrals;
    }
  }

  int get _totalEarned => _referrals.where((r) => r.status == 'paid').fold(0, (s, r) => s + r.reward);
  int get _paidCount => _referrals.where((r) => r.status == 'paid').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          SkTopBar(
            leading: const SkBackButton(),
            title: 'Refer & Earn',
            trailing: SkCircleButton(
              icon: SkIconData.more,
              onTap: () {},
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  _buildHero(),
                  const SizedBox(height: 24),
                  _buildCodeCard(),
                  const SizedBox(height: 28),
                  _buildHowItWorks(),
                  const SizedBox(height: 28),
                  _buildReferralList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                    center: const Alignment(0, -0.2),
                    radius: 0.7,
                    colors: [AppColors.goldDim, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              const SkLabel('Earned from referrals'),
              const SizedBox(height: 14),
              SkBigNumber(
                fmtNumber(_totalEarned),
                size: 56,
                color: AppColors.gold,
                shadows: [Shadow(color: AppColors.goldDim, blurRadius: 24)],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_paidCount friends paid',
                    style: AppTypography.mono.copyWith(fontSize: 12.5),
                  ),
                  const Text(' • ', style: TextStyle(color: AppColors.muted)),
                  Text(
                    '≈ ${fmtRupee((_totalEarned * 0.2).floor())}',
                    style: AppTypography.mono.copyWith(fontSize: 12.5),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCodeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: SkLabel('Your code'),
          ),
          // Code display
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.goldDim,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AARAV-247',
                      style: TextStyle(
                        fontFamily: AppTypography.fontMono,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                        letterSpacing: 1.5,
                        shadows: [Shadow(color: AppColors.goldDim, blurRadius: 16)],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'sikka.app/r/AARAV-247',
                      style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => _copied = true);
                    Future.delayed(const Duration(milliseconds: 1400), () {
                      if (mounted) setState(() => _copied = false);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _copied ? AppColors.goldFaint : Colors.transparent,
                      border: Border.all(
                        color: _copied ? AppColors.goldDim : AppColors.borderHi,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SkIcon(
                          _copied ? SkIconData.check : SkIconData.copy,
                          size: 13,
                          color: _copied ? AppColors.gold : AppColors.text,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _copied ? 'Copied' : 'Copy',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _copied ? AppColors.gold : AppColors.text,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Share buttons
          Row(
            children: [
              _shareButton('WhatsApp', SkIconData.whatsapp, AppColors.teal),
              const SizedBox(width: 8),
              _shareButton('SMS', SkIconData.sms, AppColors.text),
              const SizedBox(width: 8),
              _shareButton('Email', SkIconData.mail, AppColors.text),
              const SizedBox(width: 8),
              _shareButton('More', SkIconData.more, AppColors.text),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shareButton(String label, SkIconData icon, Color iconColor) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHi,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: SkIcon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 14),
            child: SkLabel('How it works'),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _stepRow('01', 'Share your code', 'Send your link to friends in any app', SkIconData.share, false),
                _stepRow('02', 'Friend signs up', 'They join Sikka with your code', SkIconData.user, false),
                _stepRow('03', 'You both earn', 'When they make their first paid scan', SkIconData.coin, true),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.tealDim,
              border: Border.all(color: AppColors.teal.withValues(alpha: 0.28)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SkIcon(SkIconData.zap, size: 14, color: AppColors.teal),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      text: 'Your friend also gets ',
                      style: TextStyle(fontSize: 12, color: AppColors.text),
                      children: [
                        TextSpan(
                          text: '100 Sikka',
                          style: TextStyle(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' as a welcome bonus.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepRow(String num, String title, String sub, SkIconData icon, bool showBadge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: num != '01'
            ? const Border(top: BorderSide(color: AppColors.border))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceHi,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: SkIcon(
              icon,
              size: 14,
              color: icon == SkIconData.coin ? AppColors.gold : AppColors.textDim,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      num,
                      style: TextStyle(
                        fontFamily: AppTypography.fontMono,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.textDim)),
              ],
            ),
          ),
          if (showBadge)
            SkPill(
              label: '+200 sk',
              color: AppColors.gold,
              bgColor: AppColors.goldFaint,
              borderColor: AppColors.goldDim,
            ),
        ],
      ),
    );
  }

  Widget _buildReferralList() {
    final filtered = _filtered;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkLabel('Your referrals · ${_referrals.length}'),
              Row(
                children: ['all', 'pending', 'paid'].map((f) {
                  final active = _filter == f;
                  final label = f[0].toUpperCase() + f.substring(1);
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: active ? AppColors.goldFaint : Colors.transparent,
                          border: Border.all(
                            color: active ? AppColors.goldDim : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
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
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: filtered.asMap().entries.map((entry) {
                final i = entry.key;
                final r = entry.value;
                return _referralRow(r, i == 0);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _referralRow(_Referral r, bool isFirst) {
    final statusStyle = switch (r.status) {
      'paid' => (AppColors.gold, AppColors.goldFaint, AppColors.goldDim, 'Paid'),
      'signed' => (AppColors.teal, AppColors.tealDim, AppColors.teal.withValues(alpha: 0.28), 'Signed up'),
      _ => (AppColors.muted, Colors.transparent, AppColors.border, 'Invited'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isFirst ? null : const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          SkAvatar(name: r.name, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${r.phone} · ${r.when}',
                  style: TextStyle(
                    fontFamily: AppTypography.fontMono,
                    fontSize: 11,
                    color: AppColors.muted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          if (r.reward > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${fmtNumber(r.reward)}',
                  style: TextStyle(
                    fontFamily: AppTypography.fontMono,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                SkPill(
                  label: statusStyle.$4,
                  color: statusStyle.$1,
                  bgColor: statusStyle.$2,
                  borderColor: statusStyle.$3,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  fontSize: 10,
                ),
              ],
            )
          else
            SkPill(
              label: statusStyle.$4,
              color: statusStyle.$1,
              bgColor: statusStyle.$2,
              borderColor: statusStyle.$3,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
        ],
      ),
    );
  }
}

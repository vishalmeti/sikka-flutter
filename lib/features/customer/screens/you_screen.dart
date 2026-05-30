import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/dashboard_api.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';
import '../state/customer_home_store.dart';
import '../widgets/living_avatar.dart';

class _MenuItem {
  const _MenuItem(this.label, this.sub, this.icon, this.iconColor);
  final String label;
  final String? sub;
  final SkIconData icon;
  final Color iconColor;
}

class YouScreen extends StatefulWidget {
  const YouScreen({super.key});

  @override
  State<YouScreen> createState() => _YouScreenState();
}

class _YouScreenState extends State<YouScreen> {
  bool _notifications = true;
  bool _sounds = true;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().user;
    final data = context.watch<CustomerHomeStore>().data;
    final topPad = MediaQuery.of(context).padding.top;

    if (user == null) return const SizedBox.shrink();

    final displayName =
        (user.name != null && user.name!.isNotEmpty) ? user.name! : user.username;
    final initials = _initialsOf(displayName);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const Positioned(top: 0, left: 0, right: 0, child: _HeroBackdrop()),
          Column(
            children: [
              _buildTopBar(context, topPad),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 60),
                        child: _buildHero(
                          name: displayName,
                          initials: initials,
                          maskedPhone: _maskPhone(user.username),
                          progress: data?.overallProgress ?? 1.0,
                          tier: _currentTier(data),
                        ),
                      ),
                      const SizedBox(height: 22),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 200),
                        child: _buildStats(data),
                      ),
                      const SizedBox(height: 14),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 280),
                        child: _buildStreakBanner(data?.streakDays ?? 0),
                      ),
                      const SizedBox(height: 22),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 360),
                        child: _buildPreferences(),
                      ),
                      const SizedBox(height: 18),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 440),
                        child: _buildAccountMenu(context),
                      ),
                      const SizedBox(height: 18),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 520),
                        child: _buildSupportMenu(context),
                      ),
                      const SizedBox(height: 22),
                      _buildSignOut(context),
                      const SizedBox(height: 18),
                      const _VersionFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── top bar ─────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context, double topPad) {
    return Padding(
      padding: EdgeInsets.only(top: topPad + 6, left: 24, right: 20, bottom: 4),
      child: Row(
        children: [
          const Text(
            'You',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          SkCircleButton(
            icon: SkIconData.pencil,
            onTap: () => _comingSoon(context, 'Edit profile'),
          ),
        ],
      ),
    );
  }

  // ── hero (avatar + identity + tap hint) ─────────────────────────────────

  Widget _buildHero({
    required String name,
    required String initials,
    required String maskedPhone,
    required double progress,
    required String tier,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          LivingAvatar(
            initials: initials,
            tier: tier,
            progress: progress.clamp(0.0, 1.0),
            size: 240,
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            maskedPhone,
            style: AppTypography.mono.copyWith(
              fontSize: 13,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TierPill(tier: tier),
              const SizedBox(width: 8),
              SkPill(
                label: _memberSinceLabel(),
                color: AppColors.textDim,
                borderColor: AppColors.borderHi,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                fontSize: 12,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tap the coin',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '✦',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── stats card ──────────────────────────────────────────────────────────

  Widget _buildStats(CustomerDashboard? data) {
    final coins = data?.totalCoins ?? 0;
    final redeemRate = data?.redeemRate ?? 2;
    final coinsRupees = redeemRate > 0 ? (coins / redeemRate).floor() : 0;
    final storesCount = data?.stores.length ?? 0;
    final savedRupees = data == null
        ? 0
        : ((data.totalEarned - data.totalCoins).clamp(0, 1 << 31) / (redeemRate > 0 ? redeemRate : 1))
            .floor();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _StatColumn(
                value: data == null ? '—' : fmtNumber(coins),
                valueColor: AppColors.gold,
                sub: data == null ? ' ' : '≈ ${fmtRupee(coinsRupees)}',
                label: 'SIKKA',
              ),
            ),
            const _StatDivider(),
            Expanded(
              child: _StatColumn(
                value: data == null ? '—' : '$storesCount',
                valueColor: AppColors.text,
                sub: 'of ${storesCount < 6 ? 6 : storesCount + 2} near you',
                label: 'STORES',
              ),
            ),
            const _StatDivider(),
            Expanded(
              child: _StatColumn(
                value: data == null ? '—' : fmtRupee(savedRupees),
                valueColor: AppColors.teal,
                sub: 'lifetime',
                label: 'SAVED',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── streak banner ───────────────────────────────────────────────────────

  Widget _buildStreakBanner(int streakDays) {
    final weeks = streakDays <= 0 ? 0 : ((streakDays + 6) ~/ 7);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0x1AFF5C3A),
          border: Border.all(color: AppColors.coralDim),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const SkIcon(SkIconData.flame, size: 20, color: AppColors.coral),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weeks <= 0
                        ? 'Start a shopping streak'
                        : '$weeks-week shopping streak',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    weeks <= 0
                        ? 'Visit any store this week to begin'
                        : 'Visit any store this week to keep it alive',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textDim,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${weeks <= 0 ? 0 : weeks}',
              style: TextStyle(
                fontFamily: AppTypography.fontMono,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.coral,
                letterSpacing: -0.6,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── preferences ─────────────────────────────────────────────────────────

  Widget _buildPreferences() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: SkLabel('Preferences'),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _ToggleRow(
                  icon: SkIconData.bell,
                  iconColor: AppColors.textDim,
                  title: 'Notifications',
                  sub: 'Coin drops, offers & milestones',
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                  isFirst: true,
                ),
                _ToggleRow(
                  icon: SkIconData.zap,
                  iconColor: AppColors.gold,
                  title: 'Sound & haptics',
                  sub: 'Coin chimes on earn',
                  value: _sounds,
                  onChanged: (v) => setState(() => _sounds = v),
                  isFirst: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── menus ───────────────────────────────────────────────────────────────

  Widget _buildAccountMenu(BuildContext context) {
    const items = [
      _MenuItem('Personal information', 'Name, username', SkIconData.user, AppColors.textDim),
      _MenuItem('Linked stores', null, SkIconData.store, AppColors.textDim),
      _MenuItem('Payments & redemptions', null, SkIconData.wallet, AppColors.teal),
      _MenuItem('Privacy & security', null, SkIconData.lock, AppColors.textDim),
    ];
    return _menuGroup(context, 'Account', items);
  }

  Widget _buildSupportMenu(BuildContext context) {
    const items = [
      _MenuItem('Help & support', null, SkIconData.mail, AppColors.textDim),
      _MenuItem('About Sikka', null, SkIconData.coin, AppColors.gold),
    ];
    return _menuGroup(context, 'Support', items);
  }

  Widget _menuGroup(BuildContext context, String title, List<_MenuItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: SkLabel(title),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: items
                  .asMap()
                  .entries
                  .map((e) => _menuRow(context, e.value, e.key == 0))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuRow(BuildContext context, _MenuItem item, bool isFirst) {
    return InkWell(
      onTap: () => _comingSoon(context, item.label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isFirst ? null : const Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.surfaceHi,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: SkIcon(item.icon, size: 16, color: item.iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (item.sub != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.sub!,
                      style: const TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ],
              ),
            ),
            const SkIcon(SkIconData.chevronRight, size: 16, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  // ── sign out ────────────────────────────────────────────────────────────

  Widget _buildSignOut(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => _confirmSignOut(context),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.coralDim),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              'Sign out',
              style: TextStyle(
                fontFamily: AppTypography.fontSans,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: AppColors.coral,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final auth = context.read<AuthState>();
    final homeStore = context.read<CustomerHomeStore>();
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Sign out?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        content: const Text(
          'You will need to sign in again to access your wallet.',
          style: TextStyle(fontSize: 13.5, color: AppColors.textDim, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Sign out',
              style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await auth.signOut();
    homeStore.clear();
    navigator.pushNamedAndRemoveUntil('/welcome', (_) => false);
  }

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceHi,
          content: Text(
            '$label · coming soon',
            style: const TextStyle(color: AppColors.text, fontSize: 13),
          ),
        ),
      );
  }

  // ── helpers ─────────────────────────────────────────────────────────────

  String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '··';
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    final single = parts[0];
    return (single.length >= 2 ? single.substring(0, 2) : single).toUpperCase();
  }

  /// Render the phone-like username as "+91 98•••••47" if it looks like a
  /// 10-digit number; otherwise show "@username" verbatim.
  String _maskPhone(String username) {
    final digits = username.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 8) {
      final head = digits.substring(0, 2);
      final tail = digits.substring(digits.length - 2);
      return '+91 $head•••••$tail';
    }
    return '@$username';
  }

  String _currentTier(CustomerDashboard? data) {
    if (data == null || data.stores.isEmpty) return 'gold';
    // Highest tier among joined stores; gold > silver > bronze.
    const rank = {'gold': 3, 'silver': 2, 'bronze': 1};
    var best = 'bronze';
    var bestRank = 0;
    for (final s in data.stores) {
      final r = rank[s.tier] ?? 0;
      if (r > bestRank) {
        bestRank = r;
        best = s.tier;
      }
    }
    return best;
  }

  String _memberSinceLabel() {
    // No createdAt on UserProfile yet — show a friendly placeholder that
    // matches the design's "Since Jan 2025" treatment.
    return 'Since Jan 2025';
  }
}

// ── tier pill (gold/silver/bronze + trophy icon) ────────────────────────────

class _TierPill extends StatelessWidget {
  const _TierPill({required this.tier});

  final String tier;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.tierColor(tier);
    final label = '${tier.toUpperCase()} MEMBER';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SkIcon(SkIconData.trophy, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontSans,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── stats card pieces ───────────────────────────────────────────────────────

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.value,
    required this.valueColor,
    required this.sub,
    required this.label,
  });

  final String value;
  final Color valueColor;
  final String sub;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTypography.fontMono,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: valueColor,
            letterSpacing: -0.5,
            height: 1,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          sub,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.muted,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        SkLabel(label),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 56,
      color: AppColors.border,
    );
  }
}

// ── toggle row ──────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.sub,
    required this.value,
    required this.onChanged,
    required this.isFirst,
  });

  final SkIconData icon;
  final Color iconColor;
  final String title;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: isFirst ? null : const Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceHi,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: SkIcon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            _SkSwitch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _SkSwitch extends StatelessWidget {
  const _SkSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    const width = 46.0;
    const height = 26.0;
    const knob = 20.0;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: width,
        height: height,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.gold : AppColors.surfaceHi,
          border: Border.all(
            color: value ? AppColors.gold : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: knob,
            height: knob,
            decoration: BoxDecoration(
              color: value ? const Color(0xFF1A1306) : AppColors.text,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── version footer ──────────────────────────────────────────────────────────

class _VersionFooter extends StatelessWidget {
  const _VersionFooter();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Sikka v0.1.0 · MVP',
      style: AppTypography.mono.copyWith(fontSize: 11, color: AppColors.muted),
    );
  }
}

// ── hero backdrop ───────────────────────────────────────────────────────────

/// Warm gradient panel + radial gold glow that sits behind the top of the
/// page, fading into [AppColors.bg]. Matches the home screen's treatment so
/// the You page feels visually consistent.
class _HeroBackdrop extends StatelessWidget {
  const _HeroBackdrop();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 460,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.32, 0.94],
                colors: [
                  Color(0xFF1B1408),
                  Color(0xFF130E06),
                  AppColors.bg,
                ],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.2),
            child: Container(
              width: 360,
              height: 360,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  radius: 0.5,
                  colors: [AppColors.goldDim, Colors.transparent],
                  stops: [0.0, 0.7],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

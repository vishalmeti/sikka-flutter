import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/dashboard_api.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';
import '../state/customer_home_store.dart';

class _MenuItem {
  const _MenuItem(this.label, this.sub, this.icon, this.iconColor);
  final String label;
  final String? sub;
  final SkIconData icon;
  final Color iconColor;
}

class YouScreen extends StatelessWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().user;
    final data = context.watch<CustomerHomeStore>().data;
    final topPad = MediaQuery.of(context).padding.top;

    // While signing out the user briefly becomes null as we navigate away.
    if (user == null) return const SizedBox.shrink();

    final displayName =
        (user.name != null && user.name!.isNotEmpty) ? user.name! : user.username;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildTopBar(context, topPad),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  _buildHero(displayName, user.username, data?.overallProgress ?? 1.0),
                  const SizedBox(height: 28),
                  _buildStats(data),
                  const SizedBox(height: 28),
                  _buildAccountMenu(context),
                  const SizedBox(height: 24),
                  _buildSupportMenu(context),
                  const SizedBox(height: 28),
                  _buildSignOut(context),
                  const SizedBox(height: 20),
                  const _VersionFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, double topPad) {
    return Padding(
      padding: EdgeInsets.only(top: topPad + 6, left: 24, right: 24, bottom: 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SkLabel('Account'),
              SizedBox(height: 2),
              Text(
                'You',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          SkCircleButton(
            icon: SkIconData.more,
            onTap: () => _comingSoon(context, 'Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(String name, String username, double progress) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.4),
                  radius: 0.6,
                  colors: [AppColors.goldDim, Colors.transparent],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              SkTierRing(
                tier: 'gold',
                size: 96,
                progress: progress.clamp(0.0, 1.0),
                child: SkAvatar(name: name, size: 76),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '@$username',
                style: AppTypography.mono.copyWith(
                  fontSize: 12.5,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats(CustomerDashboard? data) {
    final coins = data == null ? '—' : fmtNumber(data.totalCoins);
    final streak = data == null ? '—' : '${data.streakDays}';
    final stores = data == null ? '—' : '${data.stores.length}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _statTile('Sikka', coins, AppColors.gold),
          const SizedBox(width: 10),
          _statTile('Day streak', streak, AppColors.coral),
          const SizedBox(width: 10),
          _statTile('Stores', stores, AppColors.text),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: AppTypography.fontMono,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: -0.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 6),
            SkLabel(label),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountMenu(BuildContext context) {
    const items = [
      _MenuItem('Personal information', 'Name, username', SkIconData.user, AppColors.textDim),
      _MenuItem('Notifications', null, SkIconData.bell, AppColors.textDim),
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
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceHi,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: SkIcon(item.icon, size: 15, color: item.iconColor),
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
}

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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/sk_coin.dart';
import '../../../shared/widgets/sk_icons.dart';
import '../../../shared/widgets/sk_warp_field.dart';

/// Animated welcome screen — a Sikka coin drifting through hyperspace
/// while gold + indigo streaks fly past. Bottom CTAs route into log-in /
/// sign-up after the visitor picks Shopper or Store owner.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _role = 'customer';

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenH = media.size.height;
    // Tighten the coin a touch on shorter screens so it doesn't crowd CTAs.
    final coinSize = (screenH * 0.30).clamp(196.0, 246.0);
    final isOwner = _role == 'owner';

    return Scaffold(
      backgroundColor: const Color(0xFF050508),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Hyperspace + vignettes
          const Positioned.fill(child: SkWarpField()),

          // Coin — drifting in the lower-centre (~60% from top of screen)
          Positioned.fill(
            child: Align(
              alignment: const Alignment(0, 0.20),
              child: IgnorePointer(child: SkCoin(size: coinSize)),
            ),
          ),

          // Foreground chrome
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _BrandRow(),
                  const SizedBox(height: 22),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: _Headline(),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.only(left: 24, right: 24),
                    child: _Subtitle(),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _RoleSelector(
                      role: _role,
                      onChanged: (r) => setState(() => _role = r),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _CtaRow(
                      isOwner: isOwner,
                      onLogin: () => _go(context, '/login'),
                      onSignup: () => _go(context, '/register'),
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

  void _go(BuildContext context, String route) {
    context.read<AuthState>().setPendingRole(_role);
    Navigator.of(context).pushNamed(route);
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 4, 24, 0),
      child: Row(
        children: [
          _BrandGlyph(size: 22),
          SizedBox(width: 10),
          Text(
            'Welcome to Sikka',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandGlyph extends StatelessWidget {
  const _BrandGlyph({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment(-0.28, -0.40),
          colors: [
            Color(0xFFF2DD8E),
            AppColors.gold,
            Color(0xFF7D6429),
          ],
          stops: [0.0, 0.60, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldDim,
            blurRadius: 10,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'स',
        style: TextStyle(
          fontFamily: AppTypography.fontMono,
          fontSize: size * 0.5,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF6F5826),
          height: 1,
        ),
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    return Text(
      'EARN EVERY\nTIME YOU\nSHOP LOCAL',
      style: TextStyle(
        fontFamily: AppTypography.fontMono,
        fontWeight: FontWeight.w700,
        fontSize: 42,
        height: 1.02,
        letterSpacing: -1.6,
        color: AppColors.text,
        shadows: const [
          Shadow(
            color: Color(0xB3050508),
            blurRadius: 24,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Text(
        'One gold coin, accepted across every kirana you already visit.',
        style: TextStyle(
          fontFamily: AppTypography.fontSans,
          fontSize: 14.5,
          height: 1.5,
          color: AppColors.textDim,
          shadows: const [
            Shadow(
              color: Color(0xCC050508),
              blurRadius: 12,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.role, required this.onChanged});

  final String role;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xB814141A), // matches log-in button surface
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderHi),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RoleSegment(
              label: 'Shopper',
              icon: SkIconData.user,
              selected: role == 'customer',
              accent: AppColors.gold,
              accentDim: AppColors.goldDim,
              onTap: () => onChanged('customer'),
            ),
          ),
          Expanded(
            child: _RoleSegment(
              label: 'Store owner',
              icon: SkIconData.store,
              selected: role == 'owner',
              accent: AppColors.teal,
              accentDim: AppColors.tealDim,
              onTap: () => onChanged('owner'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleSegment extends StatelessWidget {
  const _RoleSegment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.accent,
    required this.accentDim,
    required this.onTap,
  });

  final String label;
  final SkIconData icon;
  final bool selected;
  final Color accent;
  final Color accentDim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? accentDim : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? accent : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkIcon(
                icon,
                size: 14,
                color: selected ? accent : AppColors.textDim,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.fontSans,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                  color: selected ? AppColors.text : AppColors.textDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CtaRow extends StatelessWidget {
  const _CtaRow({
    required this.isOwner,
    required this.onLogin,
    required this.onSignup,
  });

  final bool isOwner;
  final VoidCallback onLogin;
  final VoidCallback onSignup;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _LoginButton(onTap: onLogin)),
        const SizedBox(width: 12),
        Expanded(child: _SignupButton(onTap: onSignup, isOwner: isOwner)),
      ],
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xB814141A), // ~72% surface
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.borderHi, width: 1),
          ),
          child: Text(
            'Log in',
            style: TextStyle(
              fontFamily: AppTypography.fontSans,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _SignupButton extends StatelessWidget {
  const _SignupButton({required this.onTap, required this.isOwner});
  final VoidCallback onTap;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final topColor =
        isOwner ? const Color(0xFF7AC9B0) : const Color(0xFFE6C66A);
    final bottomColor = isOwner ? AppColors.teal : AppColors.gold;
    final shadowColor = isOwner ? AppColors.tealDim : AppColors.goldDim;
    final textColor =
        isOwner ? const Color(0xFF07140F) : const Color(0xFF1A1407);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [topColor, bottomColor],
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 26,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            'Sign up',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../widgets/coin_mark.dart';
import '../widgets/role_card.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _role = 'shopper';

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Ambient gold glow
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 480,
                height: 480,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [AppColors.goldFaint, Colors.transparent],
                    radius: 0.6,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: topPad + 40,
              left: 24,
              right: 24,
              bottom: bottomPad + 20,
            ),
            child: Column(
              children: [
                const CoinMark(size: 84),
                const SizedBox(height: 20),
                Text(
                  'Sikka',
                  style: TextStyle(
                    fontFamily: AppTypography.fontMono,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                    letterSpacing: -1,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 260,
                  child: Text(
                    'Loyalty coins from the kirana stores you already shop at.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontSans,
                      fontSize: 13,
                      color: AppColors.textDim,
                      letterSpacing: 0.1,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 44),
                Align(
                  alignment: Alignment.centerLeft,
                  child: const SkLabel('I am a…'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    RoleCard(
                      label: 'Shopper',
                      subtitle: 'Earn coins where I buy',
                      icon: SkIconData.user,
                      selected: _role == 'shopper',
                      onTap: () => setState(() => _role = 'shopper'),
                    ),
                    const SizedBox(width: 10),
                    RoleCard(
                      label: 'Store owner',
                      subtitle: 'Run my own kirana',
                      icon: SkIconData.store,
                      selected: _role == 'owner',
                      onTap: () => setState(() => _role = 'owner'),
                    ),
                  ],
                ),
                const Spacer(),
                SkButton(
                  label: 'Continue',
                  mode: _role == 'owner' ? SkButtonMode.teal : SkButtonMode.gold,
                  icon: SkIcon(
                    SkIconData.chevronRight,
                    size: 14,
                    color: AppColors.bg,
                  ),
                  onTap: () {
                    context
                        .read<AuthState>()
                        .setPendingRole(_role == 'owner' ? 'owner' : 'customer');
                    Navigator.of(context).pushNamed('/login');
                  },
                ),
                const SizedBox(height: 14),
                Text.rich(
                  TextSpan(
                    text: 'By continuing you agree to our ',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: 'Terms',
                        style: TextStyle(
                          color: AppColors.textDim,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.border,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: AppColors.textDim,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.border,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

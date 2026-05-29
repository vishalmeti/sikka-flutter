import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/widgets.dart';
import '../../features/customer/screens/home_screen.dart';
import '../../features/customer/screens/scan_screen.dart';
import '../../features/customer/screens/wallet_screen.dart';
import '../../features/customer/screens/referrals_screen.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _currentIndex = 0;

  void _onNavTap(int i) {
    if (i == 1) {
      // Scan is a full-screen modal, not a tab
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const ScanScreen(),
        ),
      );
      return;
    }
    setState(() => _currentIndex = i > 1 ? i - 1 : i);
  }

  @override
  Widget build(BuildContext context) {
    final screens = const [
      HomeScreen(),
      WalletScreen(),
      ReferralsScreen(),
    ];

    // Map tab index to nav bar highlight index
    final navIndex = _currentIndex == 0 ? 0 : _currentIndex + 1;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SkBottomNav(
        activeIndex: navIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

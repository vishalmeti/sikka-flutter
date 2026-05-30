import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/widgets.dart';
import '../../features/customer/screens/home_screen.dart';
import '../../features/customer/screens/scan_screen.dart';
import '../../features/customer/screens/stores_screen.dart';
import '../../features/customer/screens/you_screen.dart';

/// Bottom-tab shell for the customer app.
///
/// Tabs: Home · Scan · Stores · You. Scan is a full-screen modal rather
/// than a tab — tapping it pushes [ScanScreen] over the shell and the
/// previously-selected tab stays highlighted while the modal is open.
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => CustomerShellState();

  /// Navigate to the Stores tab from anywhere within the shell. Falls back
  /// to a no-op when the call site is outside the shell.
  static void goToStores(BuildContext context) {
    context.findAncestorStateOfType<CustomerShellState>()?._select(
      _CustomerTab.stores,
    );
  }
}

enum _CustomerTab { home, stores, you }

class CustomerShellState extends State<CustomerShell> {
  _CustomerTab _tab = _CustomerTab.home;

  void _select(_CustomerTab t) {
    if (t == _tab) return;
    setState(() => _tab = t);
  }

  void _onNavTap(int i) {
    switch (i) {
      case 0:
        _select(_CustomerTab.home);
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => const ScanScreen(),
          ),
        );
      case 2:
        _select(_CustomerTab.stores);
      case 3:
        _select(_CustomerTab.you);
    }
  }

  int get _navIndex {
    switch (_tab) {
      case _CustomerTab.home:
        return 0;
      case _CustomerTab.stores:
        return 2;
      case _CustomerTab.you:
        return 3;
    }
  }

  int get _stackIndex {
    switch (_tab) {
      case _CustomerTab.home:
        return 0;
      case _CustomerTab.stores:
        return 1;
      case _CustomerTab.you:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: _stackIndex,
        children: const [
          HomeScreen(),
          StoresScreen(),
          YouScreen(),
        ],
      ),
      bottomNavigationBar: SkBottomNav(
        activeIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

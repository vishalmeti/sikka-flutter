import 'package:flutter/material.dart';
import '../../features/onboarding/screens/loading_screen.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/onboarding/screens/login_screen.dart';
import '../../features/onboarding/screens/register_screen.dart';
import '../../features/customer/screens/redeem_screen.dart';
import '../../features/owner/screens/dashboard_screen.dart';
import '../../features/owner/screens/create_offer_screen.dart';
import '../../features/profile/screens/phone_entry_screen.dart';
import 'customer_shell.dart';

class AppRouter {
  /// Lets non-widget code (e.g. the API client's session-expiry handler)
  /// drive navigation, since routing here is imperative rather than
  /// auth-state driven.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/welcome':
        return _build(const WelcomeScreen());
      case '/login':
        return _build(const LoginScreen());
      case '/register':
        return _build(const RegisterScreen());
      case '/loading':
        final args = settings.arguments as Map<String, dynamic>?;
        return _build(LoadingScreen(message: args?['message'] as String?));
      case '/customer':
        return _build(const CustomerShell());
      case '/redeem':
        return _build(const RedeemScreen());
      case '/owner':
        return _build(const DashboardScreen());
      case '/create-offer':
        return _build(const CreateOfferScreen());
      case '/verify-phone':
        return _build(const PhoneEntryScreen());
      default:
        return _build(const WelcomeScreen());
    }
  }

  static MaterialPageRoute<dynamic> _build(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}

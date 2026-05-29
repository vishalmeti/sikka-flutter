import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sikka/core/api/api_client.dart';
import 'package:sikka/core/api/auth_api.dart';
import 'package:sikka/core/api/dashboard_api.dart';
import 'package:sikka/core/auth/auth_state.dart';
import 'package:sikka/core/auth/auth_storage.dart';
import 'package:sikka/features/customer/screens/home_screen.dart';
import 'package:sikka/features/customer/state/customer_home_store.dart';

/// Call once at the top of a test's setUp. Stops google_fonts from trying to
/// fetch fonts over the network (which is blocked in the test sandbox) and
/// gives AuthStorage an empty, in-memory SharedPreferences to work against.
void initTestHarness() {
  GoogleFonts.config.allowRuntimeFetching = false;
  SharedPreferences.setMockInitialValues({});
}

/// An [AuthApi] whose network calls are replaced by canned results/errors.
class FakeAuthApi extends AuthApi {
  FakeAuthApi() : super(ApiClient(baseUrl: 'http://test.local/api'));

  AuthResult? loginResult;
  AuthResult? registerResult;
  Object? loginError;
  Object? registerError;

  int loginCalls = 0;
  int registerCalls = 0;
  String? lastUsername;
  String? lastPassword;
  String? lastRole;
  String? lastName;

  @override
  Future<AuthResult> login({required String username, required String password}) async {
    loginCalls++;
    lastUsername = username;
    lastPassword = password;
    if (loginError != null) throw loginError!;
    return loginResult!;
  }

  @override
  Future<AuthResult> register({
    required String username,
    required String password,
    required String role,
    String? name,
  }) async {
    registerCalls++;
    lastUsername = username;
    lastPassword = password;
    lastRole = role;
    lastName = name;
    if (registerError != null) throw registerError!;
    return registerResult!;
  }
}

/// A [DashboardApi] with a controllable [fetch]. Set [gate] to hold the call
/// pending (for loading-state tests), [failTimes]/[error] to throw on the
/// first N calls, and [result] for the value returned afterwards.
class FakeDashboardApi extends DashboardApi {
  FakeDashboardApi() : super(ApiClient(baseUrl: 'http://test.local/api'));

  int calls = 0;
  int failTimes = 0;
  Object? error;
  CustomerDashboard? result;
  Completer<CustomerDashboard>? gate;

  @override
  Future<CustomerDashboard> fetch() async {
    calls++;
    if (gate != null) return gate!.future;
    if (calls <= failTimes) throw error!;
    return result!;
  }
}

Future<AuthState> makeAuthState({String? pendingRole}) async {
  final state = AuthState(AuthStorage());
  await state.bootstrap();
  if (pendingRole != null) await state.setPendingRole(pendingRole);
  return state;
}

AuthResult authResult({
  String role = 'customer',
  String username = 'asha',
  String? name = 'Asha',
}) {
  return AuthResult(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    user: UserProfile(id: 'u1', username: username, name: name, role: role),
  );
}

CustomerDashboard dashboard({
  String userName = 'Vishal',
  int totalCoins = 540,
  int totalEarned = 620,
  double overallProgress = 0.6,
  double redeemRate = 2,
  int streakDays = 7,
  List<DashboardStore>? stores,
  List<DashboardActivity>? activity,
}) {
  return CustomerDashboard(
    userName: userName,
    totalCoins: totalCoins,
    totalEarned: totalEarned,
    overallProgress: overallProgress,
    redeemRate: redeemRate,
    streakDays: streakDays,
    stores: stores ??
        [
          DashboardStore(
            id: 's1',
            name: 'Sri Lakshmi Stores',
            coins: 540,
            totalEarned: 620,
            tier: 'gold',
            tierProgress: 0.8,
            visits: 4,
          ),
        ],
    activity: activity ??
        [
          DashboardActivity(
            id: 'a1',
            kind: 'earn',
            storeName: 'Sri Lakshmi Stores',
            coinDelta: 60,
            label: 'Earned on ₹1,200',
            timestamp: DateTime(2026, 5, 30, 9),
          ),
        ],
  );
}

/// Marker screens the onboarding flows navigate to, so a test can assert
/// "navigated to the customer/owner home" without pulling in the real screens.
class StubScreen extends StatelessWidget {
  const StubScreen(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text(label)));
}

const stubRoutes = <String, WidgetBuilder>{};

Widget wrapOnboarding({
  required Widget child,
  required AuthApi authApi,
  required AuthState authState,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthState>.value(value: authState),
      Provider<AuthApi>.value(value: authApi),
    ],
    child: MaterialApp(
      home: child,
      routes: {
        '/register': (_) => const StubScreen('REGISTER STUB'),
        '/customer': (_) => const StubScreen('CUSTOMER STUB'),
        '/owner': (_) => const StubScreen('OWNER STUB'),
      },
    ),
  );
}

Widget wrapHome({required CustomerHomeStore store}) {
  return ChangeNotifierProvider<CustomerHomeStore>.value(
    value: store,
    child: MaterialApp(
      // google_fonts can't fetch in the sandbox, so the fallback font renders
      // a few px taller than Inter and overflows the fixed-height StoreCard.
      // Nudge the text scale down so layout matches the real (Inter) app.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.9)),
        child: child!,
      ),
      home: const HomeScreen(),
    ),
  );
}

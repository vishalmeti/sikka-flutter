import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/api/api_exception.dart';
import 'core/api/auth_api.dart';
import 'core/api/dashboard_api.dart';
import 'core/api/owner_api.dart';
import 'core/api/profile_api.dart';
import 'core/auth/auth_state.dart';
import 'core/auth/auth_storage.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/customer/state/customer_home_store.dart';
import 'features/owner/state/owner_dashboard_store.dart';
import 'shared/navigation/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0A0F),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  GoogleFonts.config.allowRuntimeFetching = true;

  runApp(const SikkaApp());
}

class SikkaApp extends StatefulWidget {
  const SikkaApp({super.key});

  @override
  State<SikkaApp> createState() => _SikkaAppState();
}

class _SikkaAppState extends State<SikkaApp> {
  AuthState? _authState;
  AuthApi? _authApi;
  DashboardApi? _dashboardApi;
  OwnerApi? _ownerApi;
  ProfileApi? _profileApi;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final authState = AuthState(AuthStorage());
    try {
      await authState.bootstrap();
    } catch (e, st) {
      debugPrint('Auth bootstrap failed: $e\n$st');
    }
    // AuthApi talks to the public + refresh endpoints, so it uses a bare client
    // with no auto-refresh — that also stops the refresh call from recursing
    // back into a refresh. Feature APIs use a client that silently refreshes a
    // 401'd access token and replays the request.
    final authApi = AuthApi(ApiClient());
    final apiClient = ApiClient(
      tokenProvider: () => authState.accessToken,
      onRefresh: () => _refreshSession(authApi, authState),
    );
    final dashboardApi = DashboardApi(apiClient);
    final ownerApi = OwnerApi(apiClient);
    final profileApi = ProfileApi(apiClient);

    if (!mounted) return;
    setState(() {
      _authState = authState;
      _authApi = authApi;
      _dashboardApi = dashboardApi;
      _ownerApi = ownerApi;
      _profileApi = profileApi;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.dark.copyWith(
      textTheme: GoogleFonts.interTextTheme(AppTheme.dark.textTheme),
    );

    final authState = _authState;
    final authApi = _authApi;
    final dashboardApi = _dashboardApi;
    final ownerApi = _ownerApi;
    final profileApi = _profileApi;
    if (authState == null ||
        authApi == null ||
        dashboardApi == null ||
        ownerApi == null ||
        profileApi == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const Scaffold(
          backgroundColor: AppColors.bg,
          body: SizedBox.shrink(),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthState>(
          create: (_) => authState,
          lazy: false,
        ),
        Provider<AuthApi>(
          create: (_) => authApi,
          lazy: false,
        ),
        Provider<DashboardApi>(
          create: (_) => dashboardApi,
          lazy: false,
        ),
        Provider<OwnerApi>(
          create: (_) => ownerApi,
          lazy: false,
        ),
        Provider<ProfileApi>(
          create: (_) => profileApi,
          lazy: false,
        ),
        ChangeNotifierProvider<CustomerHomeStore>(
          create: (ctx) => CustomerHomeStore(ctx.read<DashboardApi>()),
        ),
        ChangeNotifierProvider<OwnerDashboardStore>(
          create: (ctx) => OwnerDashboardStore(ctx.read<OwnerApi>()),
        ),
      ],
      child: MaterialApp(
        title: 'Sikka',
        debugShowCheckedModeBanner: false,
        theme: theme,
        navigatorKey: AppRouter.navigatorKey,
        initialRoute: _pickInitialRoute(authState),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }

  String _pickInitialRoute(AuthState state) {
    if (state.isAuthenticated) {
      return state.user!.role == 'owner' ? '/owner' : '/customer';
    }
    return '/welcome';
  }
}

/// Exchanges the stored refresh token for a new access token. Returns true when
/// the session was renewed (the next request can retry), false when it could
/// not be — in which case the user is signed out and sent back to /welcome.
Future<bool> _refreshSession(AuthApi authApi, AuthState authState) async {
  final refreshToken = authState.refreshToken;
  if (refreshToken == null || refreshToken.isEmpty) {
    await _expireSession(authState);
    return false;
  }
  try {
    final tokens = await authApi.refresh(refreshToken);
    await authState.updateTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return true;
  } on ApiException {
    await _expireSession(authState);
    return false;
  }
}

Future<void> _expireSession(AuthState authState) async {
  await authState.signOut();
  AppRouter.navigatorKey.currentState
      ?.pushNamedAndRemoveUntil('/welcome', (_) => false);
}

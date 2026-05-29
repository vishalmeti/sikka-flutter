import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/api/auth_api.dart';
import 'core/api/dashboard_api.dart';
import 'core/api/owner_api.dart';
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
    final apiClient = ApiClient(tokenProvider: () => authState.accessToken);
    final authApi = AuthApi(apiClient);
    final dashboardApi = DashboardApi(apiClient);
    final ownerApi = OwnerApi(apiClient);

    if (!mounted) return;
    setState(() {
      _authState = authState;
      _authApi = authApi;
      _dashboardApi = dashboardApi;
      _ownerApi = ownerApi;
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
    if (authState == null ||
        authApi == null ||
        dashboardApi == null ||
        ownerApi == null) {
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

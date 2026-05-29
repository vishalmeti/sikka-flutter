import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/auth_api.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final username = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter your username and password');
      return;
    }

    final api = context.read<AuthApi>();
    final auth = context.read<AuthState>();

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final result = await api.login(username: username, password: password);
      await auth.saveSession(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        user: result.user,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        result.user.role == 'owner' ? '/owner' : '/customer',
        (_) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final role = context.watch<AuthState>().pendingRole ?? 'customer';
    final accent = role == 'owner' ? AppColors.teal : AppColors.gold;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          SkTopBar(
            leading: const SkBackButton(),
            trailing: Text(
              'WELCOME BACK',
              style: TextStyle(
                fontFamily: AppTypography.fontSans,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                color: AppColors.muted,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 36),
                  const SkLabel('Sign in'),
                  const SizedBox(height: 12),
                  Text(
                    'Welcome back',
                    style: TextStyle(
                      fontFamily: AppTypography.fontSans,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                      letterSpacing: -0.6,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Log in to your Sikka account.',
                    style: TextStyle(
                      fontFamily: AppTypography.fontSans,
                      fontSize: 13,
                      color: AppColors.textDim,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AuthTextField(
                    controller: _usernameController,
                    hint: 'Username',
                    leadingIcon: SkIconData.user,
                    autofocus: true,
                    enabled: !_submitting,
                    hasError: _error != null,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                      LengthLimitingTextInputFormatter(20),
                    ],
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: _passwordController,
                    hint: 'Password',
                    leadingIcon: SkIconData.lock,
                    obscure: true,
                    enabled: !_submitting,
                    hasError: _error != null,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 10),
                  if (_error != null)
                    Row(
                      children: [
                        const SkIcon(SkIconData.lock, size: 11, color: AppColors.coral),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.coral,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 32),
                  SkButton(
                    label: _submitting ? 'Logging in…' : 'Log in',
                    mode: role == 'owner' ? SkButtonMode.teal : SkButtonMode.gold,
                    onTap: _submitting ? null : _submit,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: _submitting
                          ? null
                          : () => Navigator.of(context).pushNamed('/register'),
                      behavior: HitTestBehavior.opaque,
                      child: Text.rich(
                        TextSpan(
                          text: 'New to Sikka?  ',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                          children: [
                            TextSpan(
                              text: 'Create account',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: bottomPad + 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

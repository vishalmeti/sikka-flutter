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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validate(String name, String username, String password) {
    if (name.length < 2) return 'Enter your name (at least 2 characters)';
    if (!RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(username)) {
      return 'Username must be 3–20 letters, numbers or _';
    }
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text;

    final validationError = _validate(name, username, password);
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    final api = context.read<AuthApi>();
    final auth = context.read<AuthState>();
    final role = auth.pendingRole ?? 'customer';

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final result = await api.register(
        username: username,
        password: password,
        role: role,
        name: name,
      );
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
    final roleLabel = role == 'owner' ? 'Store owner' : 'Shopper';
    final roleIcon = role == 'owner' ? SkIconData.store : SkIconData.user;
    final accent = role == 'owner' ? AppColors.teal : AppColors.gold;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          SkTopBar(
            leading: const SkBackButton(),
            trailing: Text(
              'CREATE ACCOUNT',
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
                  const SkLabel('New account'),
                  const SizedBox(height: 12),
                  Text(
                    'Create your\naccount',
                    style: TextStyle(
                      fontFamily: AppTypography.fontSans,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                      letterSpacing: -0.6,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SkIcon(roleIcon, size: 12, color: accent),
                        const SizedBox(width: 8),
                        Text(
                          'Signing up as $roleLabel',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AuthTextField(
                    controller: _nameController,
                    hint: 'Your full name',
                    leadingIcon: SkIconData.user,
                    autofocus: true,
                    enabled: !_submitting,
                    hasError: _error != null,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: _usernameController,
                    hint: 'Username',
                    leadingIcon: SkIconData.lock,
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
                    )
                  else
                    Text(
                      'Pick a username you\'ll remember. At least 6-character password.',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 28),
                  SkButton(
                    label: _submitting ? 'Creating account…' : 'Create account',
                    mode: role == 'owner' ? SkButtonMode.teal : SkButtonMode.gold,
                    onTap: _submitting ? null : _submit,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: _submitting ? null : () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: Text.rich(
                        TextSpan(
                          text: 'Already have an account?  ',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign in',
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/profile_api.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

/// Step 2 of the phone-link flow: the user enters the 6-digit code we
/// dispatched via Zavu. On success we persist the freshly-linked phone
/// into AuthState and pop back to the YOU page.
class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({
    super.key,
    required this.phone,
    required this.resendInSec,
    required this.devMode,
  });

  final String phone;
  final int resendInSec;
  final bool devMode;

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _controller = TextEditingController();
  bool _submitting = false;
  bool _resending = false;
  String? _error;
  String? _info;
  int _resendIn = 0;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _info = widget.devMode
        ? 'Dev mode: SMS provider not configured — the code was logged to the server console.'
        : null;
    _startResendTimer(widget.resendInSec);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startResendTimer(int seconds) {
    _ticker?.cancel();
    setState(() => _resendIn = seconds);
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_resendIn <= 1) {
          _resendIn = 0;
          t.cancel();
        } else {
          _resendIn -= 1;
        }
      });
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final code = _controller.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _error = 'Enter the 6-digit code');
      return;
    }

    final api = context.read<ProfileApi>();
    final auth = context.read<AuthState>();

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final user = await api.verifyPhoneOtp(phone: widget.phone, code: code);
      await auth.updateUser(user);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.surfaceHi,
            content: Text(
              'Phone verified · ${_maskPhone(widget.phone)}',
              style: const TextStyle(color: AppColors.text, fontSize: 13),
            ),
          ),
        );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not verify. Try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resend() async {
    if (_resending || _resendIn > 0) return;
    setState(() {
      _resending = true;
      _error = null;
      _info = null;
    });
    try {
      final result = await context.read<ProfileApi>().sendPhoneOtp(widget.phone);
      if (!mounted) return;
      _startResendTimer(result.resendInSec);
      setState(() {
        _info = result.devMode
            ? 'Dev mode: new code logged to the server console.'
            : 'New code sent to ${_maskPhone(widget.phone)}';
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not resend. Try again.');
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          SkTopBar(
            leading: const SkBackButton(),
            trailing: Text(
              'ENTER CODE',
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
                  const SkLabel('Verify'),
                  const SizedBox(height: 12),
                  Text(
                    'Enter the\n6-digit code',
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
                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontFamily: AppTypography.fontSans,
                        fontSize: 13,
                        color: AppColors.textDim,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'Sent via SMS to '),
                        TextSpan(
                          text: _maskPhone(widget.phone),
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: '. '),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _CodeInput(
                    controller: _controller,
                    enabled: !_submitting,
                    hasError: _error != null,
                    onChanged: () {
                      if (_error != null) setState(() => _error = null);
                    },
                    onSubmitted: _submit,
                  ),
                  const SizedBox(height: 10),
                  if (_error != null)
                    _Hint(text: _error!, color: AppColors.coral)
                  else if (_info != null)
                    _Hint(text: _info!, color: AppColors.textDim)
                  else
                    _Hint(
                      text: 'The code expires in 5 minutes.',
                      color: AppColors.muted,
                    ),
                  const SizedBox(height: 28),
                  SkButton(
                    label: _submitting ? 'Verifying…' : 'Verify',
                    mode: SkButtonMode.gold,
                    onTap: _submitting ? null : _submit,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: (_resending || _resendIn > 0) ? null : _resend,
                      behavior: HitTestBehavior.opaque,
                      child: Text.rich(
                        TextSpan(
                          text: "Didn't get it?  ",
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                          children: [
                            TextSpan(
                              text: _resending
                                  ? 'Resending…'
                                  : _resendIn > 0
                                      ? 'Resend in ${_resendIn}s'
                                      : 'Resend code',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _resendIn > 0
                                    ? AppColors.textDim
                                    : AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: bottomPad + 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _maskPhone(String e164) {
    final digits = e164.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 6) return e164;
    final head = digits.substring(digits.length - 10, digits.length - 8);
    final tail = digits.substring(digits.length - 2);
    return '+91 $head•••••$tail';
  }
}

class _CodeInput extends StatelessWidget {
  const _CodeInput({
    required this.controller,
    required this.enabled,
    required this.hasError,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool hasError;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: hasError ? AppColors.coral : AppColors.borderHi,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        textAlign: TextAlign.center,
        onChanged: (_) => onChanged(),
        onSubmitted: (_) => onSubmitted(),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        style: TextStyle(
          fontFamily: AppTypography.fontMono,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 8,
          color: AppColors.text,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '••••••',
          hintStyle: TextStyle(
            color: AppColors.muted,
            letterSpacing: 8,
            fontSize: 28,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SkIcon(SkIconData.bell, size: 11, color: color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 11.5, color: color, height: 1.4),
          ),
        ),
      ],
    );
  }
}

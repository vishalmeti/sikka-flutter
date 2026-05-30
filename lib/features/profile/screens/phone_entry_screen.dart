import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/profile_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import 'otp_verify_screen.dart';

/// Step 1 of the phone-link flow: collect a 10-digit Indian mobile, fire
/// /profile/phone/send-otp, and push the OTP screen if Zavu accepts.
class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _controller = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final digits = _controller.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10 || !RegExp(r'^[6-9]').hasMatch(digits)) {
      setState(() => _error = 'Enter a valid 10-digit Indian mobile');
      return;
    }
    final phone = '+91$digits';

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final result = await context.read<ProfileApi>().sendPhoneOtp(phone);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OtpVerifyScreen(
            phone: phone,
            resendInSec: result.resendInSec,
            devMode: result.devMode,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not send code. Try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
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
              'VERIFY PHONE',
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
                  const SkLabel('Phone'),
                  const SizedBox(height: 12),
                  Text(
                    'Link your\nphone number',
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
                    'We will send a 6-digit code via SMS. '
                    'Each phone can be linked to one Sikka account.',
                    style: TextStyle(
                      fontFamily: AppTypography.fontSans,
                      fontSize: 13,
                      color: AppColors.textDim,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _PhoneInput(
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
                    Row(
                      children: [
                        const SkIcon(SkIconData.lock,
                            size: 11, color: AppColors.coral),
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
                      'Standard SMS rates apply.',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 28),
                  SkButton(
                    label: _submitting ? 'Sending code…' : 'Send code',
                    mode: SkButtonMode.gold,
                    onTap: _submitting ? null : _submit,
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
}

class _PhoneInput extends StatelessWidget {
  const _PhoneInput({
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
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 12),
            child: SkIcon(SkIconData.user, size: 16, color: AppColors.muted),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceHi,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+91',
              style: TextStyle(
                fontFamily: AppTypography.fontMono,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              autofocus: true,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onChanged: (_) => onChanged(),
              onSubmitted: (_) => onSubmitted(),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: TextStyle(
                fontFamily: AppTypography.fontMono,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppColors.text,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '98••••••••',
                hintStyle: TextStyle(color: AppColors.muted, letterSpacing: 1.2),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4, vertical: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

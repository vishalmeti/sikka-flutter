import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

/// Styled text field used across the login and register screens.
/// When [obscure] is true it manages its own show/hide toggle.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.leadingIcon,
    this.enabled = true,
    this.hasError = false,
    this.obscure = false,
    this.autofocus = false,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final SkIconData? leadingIcon;
  final bool enabled;
  final bool hasError;
  final bool obscure;
  final bool autofocus;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: widget.hasError ? AppColors.coral : AppColors.borderHi,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          if (widget.leadingIcon != null)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: SkIcon(widget.leadingIcon!, size: 16, color: AppColors.muted),
            ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
              obscureText: widget.obscure && _hidden,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              textCapitalization: widget.textCapitalization,
              textInputAction: widget.textInputAction,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: TextStyle(
                fontFamily: AppTypography.fontSans,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle: const TextStyle(color: AppColors.muted),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
              ),
            ),
          ),
          if (widget.obscure)
            GestureDetector(
              onTap: () => setState(() => _hidden = !_hidden),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  _hidden ? 'Show' : 'Hide',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

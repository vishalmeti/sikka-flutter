import 'package:flutter/material.dart';

class SkTopBar extends StatelessWidget {
  const SkTopBar({
    super.key,
    this.title,
    this.leading,
    this.trailing,
  });

  final String? title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(
        top: topPadding + 6,
        left: 24,
        right: 24,
        bottom: 8,
      ),
      child: Row(
        children: [
          if (leading != null) leading!,
          if (title != null) ...[
            const Spacer(),
            Text(
              title!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            const Spacer(),
          ] else
            const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

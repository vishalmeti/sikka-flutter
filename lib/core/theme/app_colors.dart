import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color bg = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF13131A);
  static const Color surfaceHi = Color(0xFF1A1A22);

  static const Color border = Color(0x0FF0EFE9); // 6% white
  static const Color borderHi = Color(0x1AF0EFE9); // 10% white

  static const Color gold = Color(0xFFC9A84C);
  static const Color goldDim = Color(0x2EC9A84C); // 18%
  static const Color goldFaint = Color(0x14C9A84C); // 8%

  static const Color teal = Color(0xFF4C9A84);
  static const Color tealDim = Color(0x2E4C9A84); // 18%

  static const Color coral = Color(0xFFFF5C3A);
  static const Color coralDim = Color(0x29FF5C3A); // 16%

  static const Color text = Color(0xFFF0EFE9);
  static const Color textDim = Color(0x9EF0EFE9); // 62%
  static const Color muted = Color(0xFF6B6A72);

  static const Color success = Color(0xFF3DDC84);
  static const Color silver = Color(0xFFB8B8C0);
  static const Color bronze = Color(0xFFC57B3D);

  static Color tierColor(String tier) {
    switch (tier) {
      case 'gold':
        return gold;
      case 'silver':
        return silver;
      case 'bronze':
        return bronze;
      default:
        return muted;
    }
  }
}

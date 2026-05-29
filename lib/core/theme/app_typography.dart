import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static String get fontSans => GoogleFonts.inter().fontFamily!;
  static String get fontMono => GoogleFonts.spaceGrotesk().fontFamily!;

  static TextStyle get heading => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    letterSpacing: -0.6,
    height: 1.15,
  );

  static TextStyle get title => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    letterSpacing: -0.2,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textDim,
    height: 1.5,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  static TextStyle get label => GoogleFonts.inter(
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.6,
    color: AppColors.muted,
  );

  static TextStyle bigNumber({
    double size = 64,
    Color color = AppColors.text,
    FontWeight weight = FontWeight.w600,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: size,
      fontWeight: weight,
      height: 1,
      letterSpacing: -size * 0.025,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle get mono => GoogleFonts.spaceGrotesk(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textDim,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

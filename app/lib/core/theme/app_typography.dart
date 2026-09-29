import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography definitions for the Moments design system.
///
/// Uses [GoogleFonts.plusJakartaSans] for punchy, expressive headings
/// and [GoogleFonts.inter] for crystal-clear readability across body and caption text.
abstract class AppTypography {
  /// Builds a [TextTheme] for the given [brightness] and primary text color.
  static TextTheme createTextTheme(Color primaryTextColor, Color secondaryTextColor) {
    final headingFont = GoogleFonts.plusJakartaSans;
    final bodyFont = GoogleFonts.inter;

    return TextTheme(
      // Display: Hero moments, big titles
      displayLarge: headingFont(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: primaryTextColor,
        height: 1.15,
      ),
      displayMedium: headingFont(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.7,
        color: primaryTextColor,
        height: 1.2,
      ),
      displaySmall: headingFont(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: primaryTextColor,
        height: 1.25,
      ),

      // Headlines: Screen headers & section banners
      headlineLarge: headingFont(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: primaryTextColor,
      ),
      headlineMedium: headingFont(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: primaryTextColor,
      ),
      headlineSmall: headingFont(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: primaryTextColor,
      ),

      // Titles: Card titles, modal headers, list headers
      titleLarge: headingFont(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: primaryTextColor,
      ),
      titleMedium: headingFont(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: primaryTextColor,
      ),
      titleSmall: headingFont(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),

      // Body: General readable text
      bodyLarge: bodyFont(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: primaryTextColor,
        height: 1.45,
      ),
      bodyMedium: bodyFont(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
        height: 1.4,
      ),
      bodySmall: bodyFont(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
        height: 1.35,
      ),

      // Labels: Badges, buttons, timestamps
      labelLarge: headingFont(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: primaryTextColor,
      ),
      labelMedium: headingFont(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: secondaryTextColor,
      ),
      labelSmall: headingFont(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: secondaryTextColor,
      ),
    );
  }
}

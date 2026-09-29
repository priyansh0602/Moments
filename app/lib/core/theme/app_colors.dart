import 'package:flutter/material.dart';

/// Semantic color tokens for the Moments design system.
///
/// Supports dark-first theming tailored for late-night music listening
/// and snippet curation.
abstract class AppColors {
  // Brand Accents
  static const Color primary = Color(0xFFFF5E3A); // Sunset Coral
  static const Color primaryContainer = Color(0xFF3D160C);
  static const Color primaryLight = Color(0xFFFF8264);
  static const Color accent = Color(0xFFFFB800); // Warm Amber
  static const Color accentViolet = Color(0xFF9D4EDD); // Electric Violet

  // Dark Theme Palette (Default)
  static const Color darkBackground = Color(0xFF0D0C11);
  static const Color darkSurface = Color(0xFF16151E);
  static const Color darkSurfaceVariant = Color(0xFF22202E);
  static const Color darkSurfaceSubtle = Color(0xFF2E2B3E);
  static const Color darkTextPrimary = Color(0xFFF7F7F9);
  static const Color darkTextSecondary = Color(0xFFA5A4B2);
  static const Color darkTextMuted = Color(0xFF6B6A78);
  static const Color darkDivider = Color(0xFF252332);
  static const Color darkBorder = Color(0xFF333044);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF8F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0EFF5);
  static const Color lightSurfaceSubtle = Color(0xFFE5E4EE);
  static const Color lightTextPrimary = Color(0xFF131217);
  static const Color lightTextSecondary = Color(0xFF5A5866);
  static const Color lightTextMuted = Color(0xFF8F8D9C);
  static const Color lightDivider = Color(0xFFE5E4ED);
  static const Color lightBorder = Color(0xFFD6D4E2);

  // Feedback Colors
  static const Color success = Color(0xFF32D74B);
  static const Color error = Color(0xFFFF453A);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color info = Color(0xFF0A84FF);

  // Functional Player & Waveform Colors
  static const Color waveformPlayed = Color(0xFFFF5E3A);
  static const Color waveformUnplayed = Color(0xFF3F3D4E);
  static const Color miniPlayerDarkBg = Color(0xFF1C1A26);
  static const Color miniPlayerLightBg = Color(0xFFFFFFFF);
}

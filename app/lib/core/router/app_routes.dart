/// Centralized constants for all application route paths and names.
abstract class AppRoutes {
  /// Startup splash screen while checking session.
  static const String splash = '/splash';

  /// Authentication screen (Google OAuth).
  static const String signIn = '/sign-in';

  /// New user handle onboarding screen.
  static const String onboardingUsername = '/onboarding/username';

  /// Main tab shell screens.
  static const String search = '/search';
  static const String moments = '/moments';
  static const String groups = '/groups';
  static const String profile = '/profile';

  /// Profile editing screen.
  static const String editProfile = '/profile/edit';

  /// Expanded full player route (top-level modal screen).
  static const String player = '/player';

  /// Placeholder selected song preview screen (Phase 4).
  static const String songPreview = '/song/preview';
}

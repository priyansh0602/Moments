/// Centralized constants for all application route paths and names.
abstract class AppRoutes {
  /// Startup splash screen while checking session.
  static const String splash = '/splash';

  /// Authentication screens.
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';

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
}

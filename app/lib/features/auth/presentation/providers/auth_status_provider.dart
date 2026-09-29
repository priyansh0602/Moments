import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/core/config/supabase_provider.dart';
import 'package:moments/features/profile/presentation/providers/profile_provider.dart';

/// The high-level authentication and onboarding status of the app.
enum AppAuthStatus {
  /// Session is being resolved from local storage / Supabase on boot.
  loading,

  /// No user is signed in.
  unauthenticated,

  /// User is signed in, but needs to complete onboarding (set real username).
  needsOnboarding,

  /// User is signed in with a completed profile.
  authenticated,
}

/// Combined state model for router redirection and auth gating.
class AuthStatusState {
  const AuthStatusState({
    required this.status,
    this.userId,
    this.username,
  });

  final AppAuthStatus status;
  final String? userId;
  final String? username;

  bool get isLoading => status == AppAuthStatus.loading;
  bool get isAuthenticated => status == AppAuthStatus.authenticated;
  bool get isUnauthenticated => status == AppAuthStatus.unauthenticated;
  bool get needsOnboarding => status == AppAuthStatus.needsOnboarding;
}

/// Listenable that notifies GoRouter when auth status or onboarding changes.
class AuthStatusNotifier extends ChangeNotifier {
  AuthStatusNotifier(this._ref) {
    _ref.listen<AsyncValue<dynamic>>(
      authStateChangesProvider,
      (previous, next) => notifyListeners(),
    );
    _ref.listen<AsyncValue<dynamic>>(
      currentUserProfileProvider,
      (previous, next) => notifyListeners(),
    );
  }

  final Ref _ref;
}

final authStatusNotifierProvider = Provider<AuthStatusNotifier>((ref) {
  return AuthStatusNotifier(ref);
});

/// Computes the current [AuthStatusState] reactively.
final authStatusProvider = Provider<AuthStatusState>((ref) {
  final currentUser = ref.watch(currentAuthUserProvider);

  // 1. Not authenticated -> direct to sign-in
  if (currentUser == null) {
    return const AuthStatusState(status: AppAuthStatus.unauthenticated);
  }

  // 2. User is authenticated, check their profile status
  final profileAsync = ref.watch(currentUserProfileProvider);

  if (profileAsync.isLoading) {
    return AuthStatusState(
      status: AppAuthStatus.loading,
      userId: currentUser.id,
    );
  }

  final profile = profileAsync.value;

  // 3. User authenticated but requires real username
  if (profile == null || profile.isPlaceholderUsername) {
    return AuthStatusState(
      status: AppAuthStatus.needsOnboarding,
      userId: currentUser.id,
      username: profile?.username,
    );
  }

  // 4. Authenticated & fully onboarded
  return AuthStatusState(
    status: AppAuthStatus.authenticated,
    userId: currentUser.id,
    username: profile.username,
  );
});

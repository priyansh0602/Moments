import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/features/auth/data/auth_repository.dart';
import 'package:moments/features/profile/presentation/providers/profile_provider.dart';

/// Provider exposing the [AuthController] for executing authentication actions.
final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

/// Controller managing async UI states (loading, errors, success) for Google OAuth.
class AuthController extends AsyncNotifier<void> {
  bool _isOAuthInProgress = false;

  /// Whether an OAuth browser flow is currently awaiting user action or redirect.
  bool get isOAuthInProgress => _isOAuthInProgress;

  @override
  Future<void> build() async {
    // Initial state is idle (AsyncData(null))
  }

  /// Trigger Supabase Google OAuth sign-in flow.
  Future<bool> signInWithGoogle() async {
    state = const AsyncLoading();
    _isOAuthInProgress = true;
    try {
      final launched =
          await ref.read(authRepositoryProvider).signInWithGoogle();
      if (!launched) {
        _isOAuthInProgress = false;
        state = const AsyncData(null);
        return false;
      }
      // Note: Keep state in AsyncLoading until callback completes or user cancels.
      return true;
    } catch (e, st) {
      _isOAuthInProgress = false;
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Called by DeepLinkService when an OAuth callback URI is detected.
  void onCallbackReceived() {
    _isOAuthInProgress = false;
    // Keep loading active while exchanging session and fetching profile
    state = const AsyncLoading();
  }

  /// Called if deep-link token exchange fails.
  void setError(String errorMessage) {
    _isOAuthInProgress = false;
    state = AsyncError(Exception(errorMessage), StackTrace.current);
  }

  /// Called when the user returns to the app without completing OAuth (cancelled).
  void cancelSignIn() {
    if (_isOAuthInProgress) {
      _isOAuthInProgress = false;
      state = const AsyncData(null);
    }
  }

  /// Terminate session and sign out.
  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
      ref.invalidate(currentUserProfileProvider);
    });
  }
}

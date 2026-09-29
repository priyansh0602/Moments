import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/features/auth/data/auth_repository.dart';
import 'package:moments/features/profile/presentation/providers/profile_provider.dart';

/// Provider exposing the [AuthController] for executing authentication actions.
final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

/// Controller managing async UI states (loading, errors, success) for auth forms.
class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Initial state is idle (AsyncData(null))
  }

  /// Sign in with email and password.
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithEmail(
            email: email,
            password: password,
          );
      // Invalidate profile so fresh data is loaded
      ref.invalidate(currentUserProfileProvider);
    });
    return !state.hasError;
  }

  /// Register a new account with email and password.
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signUpWithEmail(
            email: email,
            password: password,
          );
      ref.invalidate(currentUserProfileProvider);
    });
    return !state.hasError;
  }

  /// Trigger Supabase Google OAuth sign-in flow.
  Future<bool> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      ref.invalidate(currentUserProfileProvider);
    });
    return !state.hasError;
  }

  /// Request a password reset link.
  Future<bool> resetPassword(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).resetPassword(email);
    });
    return !state.hasError;
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

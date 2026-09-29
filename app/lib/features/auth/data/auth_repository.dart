import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/core/config/supabase_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

/// Repository encapsulating all Supabase Authentication operations.
class AuthRepository {
  /// Creates an [AuthRepository].
  const AuthRepository(this._client);

  final SupabaseClient _client;

  /// The redirect URL used by OAuth and password reset flows for deep linking.
  static const String redirectUrl = 'moments://login-callback';

  /// Currently logged in [User], or `null` if unauthenticated.
  User? get currentUser => _client.auth.currentUser;

  /// Current active [Session], or `null`.
  Session? get currentSession => _client.auth.currentSession;

  /// Stream of authentication state events.
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Sign up a new user using email and password.
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw const AuthException('Unable to complete registration. Please try again.');
    }
  }

  /// Sign in an existing user with email and password.
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw const AuthException('Unable to sign in. Please verify your connection.');
    }
  }

  /// Sign in with Google using Supabase OAuth.
  Future<bool> signInWithGoogle() async {
    try {
      return await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : redirectUrl,
      );
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw const AuthException('Failed to initiate Google sign-in. Please try again.');
    }
  }

  /// Send a password reset email.
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: kIsWeb ? null : redirectUrl,
      );
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw const AuthException('Unable to send password reset email. Please try again.');
    }
  }

  /// Sign out the current user and terminate session.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Error during sign out: $e');
    }
  }

  /// Translates raw Supabase AuthExceptions into secure, user-friendly messages.
  AuthException _mapAuthException(AuthException exception) {
    final message = exception.message.toLowerCase();
    final code = exception.code?.toLowerCase() ?? '';

    if (code == 'invalid_credentials' ||
        message.contains('invalid login credentials') ||
        message.contains('invalid claim')) {
      return const AuthException('Incorrect email or password.');
    }

    if (code == 'user_already_exists' || message.contains('user already registered')) {
      return const AuthException('An account with this email already exists.');
    }

    if (code == 'weak_password' || message.contains('password should be at least')) {
      return const AuthException('Password must be at least 8 characters long.');
    }

    if (code == 'over_email_send_rate_limit' || message.contains('rate limit')) {
      return const AuthException('Too many attempts. Please wait a moment and try again.');
    }

    return AuthException(exception.message);
  }
}

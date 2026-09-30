import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/core/config/supabase_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

/// Repository encapsulating Google OAuth Supabase Authentication operations.
class AuthRepository {
  /// Creates an [AuthRepository].
  const AuthRepository(this._client);

  final SupabaseClient _client;

  /// The redirect URL used by OAuth flows for deep linking.
  static const String redirectUrl = 'moments://login-callback';

  /// Currently logged in [User], or `null` if unauthenticated.
  User? get currentUser => _client.auth.currentUser;

  /// Current active [Session], or `null`.
  Session? get currentSession => _client.auth.currentSession;

  /// Stream of authentication state events.
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Sign in with Google using Supabase OAuth.
  Future<bool> signInWithGoogle() async {
    final targetRedirect = kIsWeb ? null : redirectUrl;
    debugPrint('[AuthRepository] signInWithGoogle initiated. redirectTo: "$targetRedirect"');
    try {
      final result = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: targetRedirect,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      debugPrint('[AuthRepository] signInWithOAuth returned: $result');
      return result;
    } on AuthException catch (e, st) {
      debugPrint('[AuthRepository] AuthException during signInWithOAuth: ${e.message}\n$st');
      throw _mapAuthException(e);
    } catch (e, st) {
      debugPrint('[AuthRepository] Unexpected exception during signInWithOAuth: $e\n$st');
      throw const AuthException(
        'Failed to initiate Google sign-in. Please try again.',
      );
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

  /// Translates raw Supabase AuthExceptions for OAuth.
  AuthException _mapAuthException(AuthException exception) {
    final message = exception.message.toLowerCase();
    if (message.contains('canceled') || message.contains('cancelled')) {
      return const AuthException('Google sign-in was canceled.');
    }
    return AuthException(exception.message);
  }
}

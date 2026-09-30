import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for accessing the active [SupabaseClient] instance.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  try {
    return Supabase.instance.client;
  } catch (e) {
    throw StateError(
      'Supabase client accessed before initialization: $e',
    );
  }
});

/// Stream provider for listening to authentication state changes live across the app.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  try {
    final client = ref.watch(supabaseClientProvider);
    return client.auth.onAuthStateChange;
  } catch (_) {
    return const Stream.empty();
  }
});

/// Provider exposing the currently active [Session], if any.
final currentSessionProvider = Provider<Session?>((ref) {
  try {
    final authStateAsync = ref.watch(authStateChangesProvider);
    final client = ref.watch(supabaseClientProvider);
    final session = authStateAsync.value?.session ?? client.auth.currentSession;
    return session;
  } catch (_) {
    return null;
  }
});

/// Provider exposing the currently authenticated Supabase [User], if any.
/// Reactively updates on all auth state events.
final currentAuthUserProvider = Provider<User?>((ref) {
  try {
    final authStateAsync = ref.watch(authStateChangesProvider);
    final client = ref.watch(supabaseClientProvider);
    return authStateAsync.value?.session?.user ?? client.auth.currentUser;
  } catch (_) {
    return null;
  }
});

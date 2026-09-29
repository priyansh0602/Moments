import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for accessing the active [SupabaseClient] instance.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
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

/// Provider exposing the currently authenticated Supabase [User], if any.
final currentAuthUserProvider = Provider<User?>((ref) {
  try {
    final client = ref.watch(supabaseClientProvider);
    return client.auth.currentUser;
  } catch (_) {
    return null;
  }
});

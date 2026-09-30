import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/core/config/supabase_provider.dart';
import 'package:moments/features/profile/domain/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for accessing the [ProfileRepository].
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseClientProvider));
});

/// Exception thrown when updating a profile that does not exist in the database.
class ProfileNotFoundException implements Exception {
  /// Creates a [ProfileNotFoundException].
  const ProfileNotFoundException(this.message);

  /// Error message describing the missing profile condition.
  final String message;

  @override
  String toString() => 'ProfileNotFoundException: $message';
}

/// Repository handling all profile reads, updates, and username availability queries.
class ProfileRepository {
  /// Creates a [ProfileRepository].
  const ProfileRepository(this._client);

  final SupabaseClient _client;

  /// Fetches a user profile by user [id]. Returns `null` if not found.
  Future<UserProfile?> getProfile(String id) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data == null) return null;
      return UserProfile.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Checks whether a [username] is available.
  ///
  /// Respects public SELECT policy from Phase 2.
  /// If [excludeUserId] is supplied, matches against that user's own profile are ignored.
  Future<bool> isUsernameAvailable(String username, {String? excludeUserId}) async {
    final cleanUsername = username.trim().toLowerCase();
    if (cleanUsername.length < 3) return false;

    try {
      final query = _client
          .from('profiles')
          .select('id')
          .eq('username', cleanUsername);

      final matches = await query;
      if (matches.isEmpty) return true;

      if (excludeUserId != null) {
        return matches.every((row) => row['id'] == excludeUserId);
      }
      return false;
    } catch (e) {
      // In case of network error, treat conservatively as unavailable
      return false;
    }
  }

  /// Updates profile metadata allowed under `profiles_update_own` policy.
  Future<UserProfile> updateProfile({
    required String id,
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (username != null) updates['username'] = username.trim().toLowerCase();
    if (displayName != null) updates['display_name'] = displayName.trim();
    if (bio != null) updates['bio'] = bio.trim();
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl.trim();

    final response = await _client
        .from('profiles')
        .update(updates)
        .eq('id', id)
        .select()
        .maybeSingle();

    if (response == null) {
      throw ProfileNotFoundException(
        'Profile row not found for user ID: $id. The initial account trigger may not have executed.',
      );
    }

    return UserProfile.fromJson(response);
  }
}

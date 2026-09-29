import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/core/config/supabase_provider.dart';
import 'package:moments/features/profile/data/profile_repository.dart';
import 'package:moments/features/profile/domain/models/user_profile.dart';

/// Provider managing the active authenticated user's profile state.
final currentUserProfileProvider =
    AsyncNotifierProvider<CurrentUserProfileNotifier, UserProfile?>(
  CurrentUserProfileNotifier.new,
);

/// Notifier providing reactive access and updates to the current user's profile.
class CurrentUserProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    // Re-run whenever auth state or active user changes
    final authUser = ref.watch(currentAuthUserProvider);
    if (authUser == null) return null;

    final repository = ref.watch(profileRepositoryProvider);
    return repository.getProfile(authUser.id);
  }

  /// Refreshes the user profile from Supabase.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authUser = ref.read(currentAuthUserProvider);
      if (authUser == null) return null;
      return ref.read(profileRepositoryProvider).getProfile(authUser.id);
    });
  }

  /// Updates profile metadata and immediately sets the new state.
  Future<UserProfile?> updateProfile({
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    final current = state.value;
    if (current == null) return null;

    state = const AsyncLoading();
    final updated = await ref.read(profileRepositoryProvider).updateProfile(
          id: current.id,
          username: username,
          displayName: displayName,
          bio: bio,
          avatarUrl: avatarUrl,
        );

    state = AsyncData(updated);
    return updated;
  }
}

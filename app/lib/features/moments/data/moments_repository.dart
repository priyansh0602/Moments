import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/core/config/supabase_provider.dart';
import 'package:moments/features/moments/domain/models/moment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for accessing the [MomentsRepository].
final momentsRepositoryProvider = Provider<MomentsRepository>((ref) {
  return MomentsRepository(ref.watch(supabaseClientProvider));
});

/// Generic exception thrown for failures in [MomentsRepository].
class MomentsRepositoryException implements Exception {
  /// Creates a [MomentsRepositoryException].
  const MomentsRepositoryException(this.message, {this.cause});

  /// Error message describing the failure.
  final String message;

  /// Underlying error or exception cause, if any.
  final Object? cause;

  @override
  String toString() => 'MomentsRepositoryException: $message${cause != null ? ' (cause: $cause)' : ''}';
}

/// Repository managing persistence for Moments against the Supabase `moments` table.
class MomentsRepository {
  /// Creates a [MomentsRepository].
  const MomentsRepository(this._client);

  final SupabaseClient _client;

  /// Inserts a new Moment row owned by the currently authenticated user.
  ///
  /// Throws [MomentsRepositoryException] if user is unauthenticated or the insert fails.
  Future<Moment> createMoment({
    required String videoId,
    required String title,
    required String artist,
    required String thumbnailUrl,
    required double startSeconds,
    required double endSeconds,
    bool isPublic = true,
  }) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw const MomentsRepositoryException(
        'User must be authenticated to create a Moment.',
      );
    }

    try {
      final response = await _client
          .from('moments')
          .insert({
            'user_id': currentUserId,
            'video_id': videoId,
            'song_title': title,
            'artist': artist,
            'thumbnail_url': thumbnailUrl,
            'start_seconds': startSeconds,
            'end_seconds': endSeconds,
            'is_public': isPublic,
          })
          .select()
          .single();

      return Moment.fromJson(response);
    } catch (e) {
      throw MomentsRepositoryException(
        'Failed to save Moment: $e',
        cause: e,
      );
    }
  }

  /// Fetches the currently authenticated user's Moments, ordered newest first with pagination.
  Future<List<Moment>> getMyMoments({
    int limit = 20,
    int offset = 0,
  }) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      return const [];
    }

    try {
      final response = await _client
          .from('moments')
          .select()
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final list = response as List<dynamic>;
      return list
          .map((json) => Moment.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw MomentsRepositoryException(
        'Failed to load Moments: $e',
        cause: e,
      );
    }
  }

  /// Deletes a Moment by [momentId].
  ///
  /// Enforces RLS (`moments_delete_own`) so only the owning user can delete.
  Future<void> deleteMoment(String momentId) async {
    try {
      await _client.from('moments').delete().eq('id', momentId);
    } catch (e) {
      throw MomentsRepositoryException(
        'Failed to delete Moment: $e',
        cause: e,
      );
    }
  }

  /// Updates trim points or visibility on a Moment.
  ///
  /// Enforces RLS (`moments_update_own`) so only the owning user can update.
  Future<Moment> updateMoment(
    String momentId, {
    double? startSeconds,
    double? endSeconds,
    bool? isPublic,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (startSeconds != null) updates['start_seconds'] = startSeconds;
      if (endSeconds != null) updates['end_seconds'] = endSeconds;
      if (isPublic != null) updates['is_public'] = isPublic;

      final response = await _client
          .from('moments')
          .update(updates)
          .eq('id', momentId)
          .select()
          .single();

      return Moment.fromJson(response);
    } catch (e) {
      throw MomentsRepositoryException(
        'Failed to update Moment: $e',
        cause: e,
      );
    }
  }
}

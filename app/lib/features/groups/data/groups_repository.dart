import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/core/config/supabase_provider.dart';
import 'package:moments/features/groups/domain/models/group_item.dart';
import 'package:moments/features/groups/domain/models/moment_group.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for accessing the [GroupsRepository].
final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  return GroupsRepository(ref.watch(supabaseClientProvider));
});

/// Generic exception thrown for failures in [GroupsRepository].
class GroupsRepositoryException implements Exception {
  /// Creates a [GroupsRepositoryException].
  const GroupsRepositoryException(this.message, {this.cause});

  /// Error message describing the failure.
  final String message;

  /// Underlying error or exception cause, if any.
  final Object? cause;

  @override
  String toString() =>
      'GroupsRepositoryException: $message${cause != null ? ' (cause: $cause)' : ''}';
}

/// Specialized exception thrown when attempting to add a Moment to a group that already contains it.
class MomentAlreadyInGroupException implements Exception {
  /// Creates a [MomentAlreadyInGroupException].
  const MomentAlreadyInGroupException(
      [this.message = 'This Moment is already in this group.']);

  /// Error message.
  final String message;

  @override
  String toString() => message;
}

/// Repository managing persistence for Moment Groups and their ordered items against Supabase.
class GroupsRepository {
  /// Creates a [GroupsRepository].
  const GroupsRepository(this._client);

  final SupabaseClient _client;

  /// Inserts a new [MomentGroup] row owned by the currently authenticated user.
  ///
  /// Throws [GroupsRepositoryException] if user is unauthenticated or the insert fails.
  Future<MomentGroup> createGroup({
    required String name,
    String? description,
    String? coverThumbnailUrl,
    bool isPublic = false,
  }) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw const GroupsRepositoryException(
        'User must be authenticated to create a Group.',
      );
    }

    try {
      final response = await _client
          .from('moment_groups')
          .insert({
            'user_id': currentUserId,
            'name': name.trim(),
            if (description != null && description.trim().isNotEmpty)
              'description': description.trim(),
            if (coverThumbnailUrl != null && coverThumbnailUrl.trim().isNotEmpty)
              'cover_thumbnail_url': coverThumbnailUrl.trim(),
            'is_public': isPublic,
          })
          .select('*, moment_group_items(count)')
          .single();

      return MomentGroup.fromJson(response);
    } catch (e) {
      throw GroupsRepositoryException(
        'Failed to create Group: $e',
        cause: e,
      );
    }
  }

  /// Fetches the currently authenticated user's groups, ordered newest first with item counts.
  Future<List<MomentGroup>> getMyGroups() async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      return const [];
    }

    try {
      final response = await _client
          .from('moment_groups')
          .select('*, moment_group_items(count)')
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false);

      final list = response as List<dynamic>;
      return list
          .map((json) => MomentGroup.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw GroupsRepositoryException(
        'Failed to load Groups: $e',
        cause: e,
      );
    }
  }

  /// Updates a group's metadata (name, description, cover, visibility).
  ///
  /// Enforces RLS (`moment_groups_update_own`) so only the owning user can update.
  Future<MomentGroup> updateGroup(
    String groupId, {
    String? name,
    String? description,
    String? coverThumbnailUrl,
    bool? isPublic,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (name != null) updates['name'] = name.trim();
      if (description != null) updates['description'] = description.trim();
      if (coverThumbnailUrl != null) {
        updates['cover_thumbnail_url'] = coverThumbnailUrl.trim();
      }
      if (isPublic != null) updates['is_public'] = isPublic;

      final response = await _client
          .from('moment_groups')
          .update(updates)
          .eq('id', groupId)
          .select('*, moment_group_items(count)')
          .single();

      return MomentGroup.fromJson(response);
    } catch (e) {
      throw GroupsRepositoryException(
        'Failed to update Group: $e',
        cause: e,
      );
    }
  }

  /// Deletes a group by [groupId].
  ///
  /// Cascades to all [GroupItem] join rows via foreign key, leaving underlying moments intact.
  Future<void> deleteGroup(String groupId) async {
    try {
      await _client.from('moment_groups').delete().eq('id', groupId);
    } catch (e) {
      throw GroupsRepositoryException(
        'Failed to delete Group: $e',
        cause: e,
      );
    }
  }

  /// Fetches ordered items in a group joined with their [Moment] details.
  Future<List<GroupItem>> getGroupItems(String groupId) async {
    try {
      final response = await _client
          .from('moment_group_items')
          .select('*, moments(*)')
          .eq('group_id', groupId)
          .order('position', ascending: true);

      final list = response as List<dynamic>;
      return list
          .map((json) => GroupItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw GroupsRepositoryException(
        'Failed to load Group items: $e',
        cause: e,
      );
    }
  }

  /// Adds a Moment to a group with next sequential position.
  ///
  /// Throws [MomentAlreadyInGroupException] if the Moment is already in the group.
  Future<GroupItem> addMomentToGroup(String groupId, String momentId) async {
    try {
      // 1. Calculate next sequential position
      final items = await _client
          .from('moment_group_items')
          .select('position')
          .eq('group_id', groupId)
          .order('position', ascending: false)
          .limit(1);

      final nextPosition = items.isNotEmpty
          ? ((items.first['position'] as num?)?.toInt() ?? -1) + 1
          : 0;

      // 2. Insert into join table
      final response = await _client
          .from('moment_group_items')
          .insert({
            'group_id': groupId,
            'moment_id': momentId,
            'position': nextPosition,
          })
          .select('*, moments(*)')
          .single();

      return GroupItem.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505' ||
          e.message.contains('moment_group_items_group_moment_unique') ||
          e.message.contains('duplicate key')) {
        throw const MomentAlreadyInGroupException(
          'This Moment is already in this group.',
        );
      }
      throw GroupsRepositoryException(
        'Failed to add Moment to group: ${e.message}',
        cause: e,
      );
    } catch (e) {
      if (e is MomentAlreadyInGroupException) rethrow;
      final msg = e.toString();
      if (msg.contains('23505') ||
          msg.contains('moment_group_items_group_moment_unique') ||
          msg.contains('duplicate key')) {
        throw const MomentAlreadyInGroupException(
          'This Moment is already in this group.',
        );
      }
      throw GroupsRepositoryException(
        'Failed to add Moment to group: $e',
        cause: e,
      );
    }
  }

  /// Removes a Moment from a group without deleting the underlying Moment.
  Future<void> removeMomentFromGroup(String groupId, String momentId) async {
    try {
      await _client
          .from('moment_group_items')
          .delete()
          .eq('group_id', groupId)
          .eq('moment_id', momentId);
    } catch (e) {
      throw GroupsRepositoryException(
        'Failed to remove Moment from group: $e',
        cause: e,
      );
    }
  }

  /// Safely reorders items within a group by writing fresh 0-indexed sequential positions.
  ///
  /// Uses a single batch upsert on (group_id, moment_id) avoiding intermediate collision states.
  Future<void> reorderGroupItems(
    String groupId,
    List<String> orderedMomentIds,
  ) async {
    if (orderedMomentIds.isEmpty) return;

    try {
      final updates = [
        for (int i = 0; i < orderedMomentIds.length; i++)
          {
            'group_id': groupId,
            'moment_id': orderedMomentIds[i],
            'position': i,
          }
      ];

      await _client.from('moment_group_items').upsert(
            updates,
            onConflict: 'group_id,moment_id',
          );
    } catch (e) {
      throw GroupsRepositoryException(
        'Failed to reorder Group items: $e',
        cause: e,
      );
    }
  }
}

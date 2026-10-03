import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/features/groups/data/groups_repository.dart';
import 'package:moments/features/groups/domain/models/moment_group.dart';

/// The status of the user's Groups list retrieval.
enum MyGroupsStatus {
  /// Initial idle state.
  initial,

  /// Loading groups.
  loading,

  /// Successfully loaded groups.
  success,

  /// An error occurred while fetching groups.
  error,
}

/// State representation for the Groups screen.
class MyGroupsState {
  /// Creates a [MyGroupsState].
  const MyGroupsState({
    this.status = MyGroupsStatus.initial,
    this.groups = const [],
    this.errorMessage,
  });

  /// Current status.
  final MyGroupsStatus status;

  /// List of loaded groups.
  final List<MomentGroup> groups;

  /// Error message if status is error.
  final String? errorMessage;

  bool get isInitial => status == MyGroupsStatus.initial;
  bool get isLoading => status == MyGroupsStatus.loading;
  bool get isSuccess => status == MyGroupsStatus.success;
  bool get isError => status == MyGroupsStatus.error;
  bool get isEmpty => !isLoading && groups.isEmpty;

  /// Copies state with optional updated properties.
  MyGroupsState copyWith({
    MyGroupsStatus? status,
    List<MomentGroup>? groups,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MyGroupsState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier managing user's Moment Groups, creations, updates, and optimistic deletions.
class MyGroupsNotifier extends Notifier<MyGroupsState> {
  bool _isFetching = false;

  GroupsRepository get _repository => ref.read(groupsRepositoryProvider);

  @override
  MyGroupsState build() {
    Future.microtask(() => loadGroups());
    return const MyGroupsState(status: MyGroupsStatus.loading);
  }

  /// Loads the user's groups.
  Future<void> loadGroups({bool isRefresh = false}) async {
    if (_isFetching && !isRefresh) return;
    _isFetching = true;

    if (!isRefresh) {
      state = state.copyWith(
        status: MyGroupsStatus.loading,
        clearError: true,
      );
    }

    try {
      final items = await _repository.getMyGroups();
      state = state.copyWith(
        status: MyGroupsStatus.success,
        groups: items,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: MyGroupsStatus.error,
        errorMessage: e is GroupsRepositoryException ? e.message : e.toString(),
      );
    } finally {
      _isFetching = false;
    }
  }

  /// Creates a new group and prepends it to the list.
  Future<MomentGroup?> createGroup({
    required String name,
    String? description,
    String? coverThumbnailUrl,
    bool isPublic = false,
  }) async {
    try {
      final created = await _repository.createGroup(
        name: name,
        description: description,
        coverThumbnailUrl: coverThumbnailUrl,
        isPublic: isPublic,
      );
      state = state.copyWith(
        status: MyGroupsStatus.success,
        groups: [created, ...state.groups],
      );
      return created;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e is GroupsRepositoryException ? e.message : e.toString(),
      );
      return null;
    }
  }

  /// Updates an existing group with optimistic UI update and rollback on failure.
  Future<bool> updateGroup(
    String groupId, {
    String? name,
    String? description,
    String? coverThumbnailUrl,
    bool? isPublic,
  }) async {
    final previousGroups = state.groups;
    final index = previousGroups.indexWhere((g) => g.id == groupId);
    if (index == -1) return false;

    final target = previousGroups[index];
    final updated = target.copyWith(
      name: name ?? target.name,
      description: description ?? target.description,
      coverThumbnailUrl: coverThumbnailUrl ?? target.coverThumbnailUrl,
      isPublic: isPublic ?? target.isPublic,
    );

    // Optimistic update
    final newList = List<MomentGroup>.from(previousGroups);
    newList[index] = updated;
    state = state.copyWith(groups: newList);

    try {
      final saved = await _repository.updateGroup(
        groupId,
        name: name,
        description: description,
        coverThumbnailUrl: coverThumbnailUrl,
        isPublic: isPublic,
      );
      final finalIndex = state.groups.indexWhere((g) => g.id == groupId);
      if (finalIndex != -1) {
        final confirmedList = List<MomentGroup>.from(state.groups);
        confirmedList[finalIndex] = saved;
        state = state.copyWith(groups: confirmedList);
      }
      return true;
    } catch (e) {
      // Rollback
      state = state.copyWith(
        groups: previousGroups,
        errorMessage: 'Failed to update Group. Rolled back.',
      );
      return false;
    }
  }

  /// Deletes a group with optimistic removal and rollback on failure.
  Future<bool> deleteGroup(String groupId) async {
    final previousGroups = state.groups;
    final index = previousGroups.indexWhere((g) => g.id == groupId);
    if (index == -1) return false;

    // Optimistic removal
    final updatedList = List<MomentGroup>.from(previousGroups)..removeAt(index);
    state = state.copyWith(groups: updatedList);

    try {
      await _repository.deleteGroup(groupId);
      return true;
    } catch (e) {
      state = state.copyWith(
        groups: previousGroups,
        errorMessage: 'Failed to delete Group. Rolled back.',
      );
      return false;
    }
  }

  /// Adjusts the in-memory moment count for a group when moments are added or removed.
  void adjustMomentCount(String groupId, int delta) {
    final index = state.groups.indexWhere((g) => g.id == groupId);
    if (index == -1) return;

    final target = state.groups[index];
    final newCount = (target.momentCount + delta).clamp(0, 999999);
    final updated = target.copyWith(momentCount: newCount);

    final newList = List<MomentGroup>.from(state.groups);
    newList[index] = updated;
    state = state.copyWith(groups: newList);
  }
}

/// Provider exposing [MyGroupsState] and operations.
final myGroupsProvider =
    NotifierProvider<MyGroupsNotifier, MyGroupsState>(
  MyGroupsNotifier.new,
);
